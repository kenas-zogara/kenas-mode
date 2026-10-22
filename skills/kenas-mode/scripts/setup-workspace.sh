#!/usr/bin/env bash
# Per-workspace dev setup for flex-store Orca worktrees.
#
# Personal tooling. It lives in the kenas-mode skill, not in the repo, because
# it wires one person's Orca setup to one repo's layout. The repo half of this
# is the VITE_<APP>_PORT override in each app's vite.config.ts, which is shared
# and stays there.
#
# Wire it as the flex-store Orca project's setup script
# (Settings -> flex-store -> Setup script):
#   pnpm install && bash ~/.claude/skills/kenas-mode/scripts/setup-workspace.sh
#
# A new Orca worktree is a git worktree, so the gitignored (never-committed)
# apps/<app>/.env and packages/e2e/.env from the main checkout do not come
# along. This does two things, both idempotent:
#   1. Copies each .env from the main checkout, so the workspace has the shared
#      local-dev config and the e2e credentials the browser login needs.
#   2. Picks a free 1000-port band (4000, 5000, ...) and writes each app's
#      VITE_<APP>_PORT into apps/<app>/.env.local. Vite reads it and layers it
#      over .env. The main checkout keeps the 3000 band.
#
# Secrets (e.g. VITE_FIREBASE_API_KEY) live in the main checkout's .env, which
# is gitignored and copied over by step 1. Keep them there, not in git.
#
# The band is chosen from currently-listening ports, which means "next free
# band above the running workspaces". Two idle workspaces can land on the same
# band; strictPort then makes the second vite fail loudly rather than silently
# share. Upgrade path if that bites: persist a counter.
set -euo pipefail

# Orca runs the setup hook with the new workspace as the working directory, so
# resolve the repo from there. Deriving it from $0 would point into ~/.claude.
root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "orca: not inside a git worktree, nothing to do" >&2
  exit 0
}
cd "$root"

apps=(flex-store flex-pro flex-account flex-admin)
defaults=(3000 3002 3003 3004) # base 3000 band; workspace N uses default + N*1000
envs=(apps/flex-store apps/flex-pro apps/flex-account apps/flex-admin packages/e2e)

# This script knows one repo's layout. Anywhere else, do nothing.
if [ ! -d apps/flex-store ]; then
  echo "orca: $(basename "$root") is not flex-store, skipping" >&2
  exit 0
fi

# --git-common-dir resolves to the main checkout even from a linked worktree.
main=$(cd "$(git rev-parse --git-common-dir)/.." && pwd)

# The main checkout keeps the 3000 band and already has its .env. Assigning it a
# band here would move its ports out from under every other tool.
if [ "$main" = "$PWD" ]; then
  echo "orca: main checkout keeps the 3000 band, nothing to do" >&2
  exit 0
fi

for dir in "${envs[@]}"; do
  [ -f "$main/$dir/.env" ] && cp "$main/$dir/.env" "$dir/.env" || : # set -e: a missing .env must not abort
done

port_busy() { lsof -nP -iTCP:"$1" -sTCP:LISTEN >/dev/null 2>&1; }

N=1
while [ "$N" -le 20 ]; do
  free=1
  for d in "${defaults[@]}"; do port_busy "$((d + N * 1000))" && { free=0; break; }; done
  [ "$free" -eq 1 ] && break
  N=$((N + 1))
done

upsert() { # file key value
  local f=$1 k=$2 v=$3
  touch "$f"
  if grep -qE "^${k}=" "$f"; then
    sed -i.bak -E "s|^${k}=.*|${k}=${v}|" "$f" && rm -f "$f.bak"
  else
    printf '%s=%s\n' "$k" "$v" >>"$f"
  fi
}

for i in "${!apps[@]}"; do
  app=${apps[$i]}
  suffix=$(printf '%s' "${app#flex-}" | tr '[:lower:]' '[:upper:]') # flex-store -> STORE
  upsert "apps/$app/.env.local" "VITE_${suffix}_PORT" "$((defaults[i] + N * 1000))"
done

echo "orca: workspace on port band $((3000 + N * 1000)) (N=$N)"
