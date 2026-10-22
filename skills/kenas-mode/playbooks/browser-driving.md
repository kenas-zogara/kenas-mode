# Playbook: browser-driving

**When.** You are driving the running app for a behavioural, visual, or e2e check. This covers `qa-test`, `ui-ux-test`, `e2e-test`, the runtime checks in [eval](eval.md), and code-freeze evidence.

**Use.** Chrome DevTools MCP (`mcp__chrome-devtools__*`) by default. It is faster than Claude-in-Chrome and gives the CDP control below.

**What to point it at.** A local dev server, pointed at the regional dev API. Read [worktree-workspace](worktree-workspace.md) first, because a worktree's port is not 3000 or 3004 and a server already listening is probably another worktree's. The deployed dev hosts (`tw.dev.flexii.net`, `hk.dev.flexii.net`, `sg.dev.flexii.net`, and the `admin.*` ones) sit behind a Google Workspace SSO wall ("Flexii Secure Access") that the e2e `storageState` cannot pass. An agent cannot reach them unattended, so a check against the deployed build needs the user to log in.

**How**

- The CDP control is `emulate` for offline, throttling, CPU, and viewport, the `initScript` option on `navigate_page` to set state before the app boots, and precise `list_network_requests` and `list_console_messages`.
- Register it with `--isolated`, so each server gets its own temporary Chrome profile. Without it, every session shares `$HOME/.cache/chrome-devtools-mcp/chrome-profile`, the second worktree takes the `SingletonLock`, and the other worktree's server drops silently. Verified: two `--isolated` servers get separate profiles under `$TMPDIR/puppeteer_dev_chrome_profile-*`. `--pageIdRouting`, on by default, handles concurrency within one browser.
- Isolation costs nothing, because the e2e `storageState` supplies the login, not Chrome's profile.
- Auth. Follow `qa-test` step 4, which owns it: `persist:session` injection for flex-store, and headed Playwright with `admin-sg-admin.json` for flex-admin, whose login is an httpOnly cookie that `initScript` cannot carry. Playwright types the password, you do not.
- Another role's login. Before you ask the user for a worker or store login, read the endpoint's authorization check in the backend source. Many endpoints enforce ownership only for worker tokens and accept an admin token, which you can mint yourself.
- In a worktree, `packages/e2e/.env` does not exist until the setup script has run, so there are no credentials to inject. See [worktree-workspace](worktree-workspace.md) before you authenticate.
- First-time setup. Run `claude mcp add chrome-devtools --scope user -- npx -y chrome-devtools-mcp@latest --isolated`, then restart the session to load its tools. Every session shares the registration, so a fixed `--userDataDir` would only move the collision.
- If no browser driver connects, say so and stop. Do not report a behavioural or visual result you did not observe.
- Fallback. If the MCP dies mid-session and will not reload, headed Playwright from `packages/e2e` gives the same CDP control.
- A screenshot on a PR goes through `gh pr edit --attach`, never a browser. See [pr-evidence](pr-evidence.md).
- Other browser work that is not app testing, such as reading a page in your own logged-in Chrome, goes through Orca's `computer-use` skill (`orca computer ...`). Claude-in-Chrome is off by default (`claudeInChromeDefaultEnabled: false` in `~/.claude.json`) because it was slow. Use it only when the user turns it on with `/chrome`.
- Mobile too. Check every UI screen at a phone width (`emulate` with a 390×844 viewport) as well as at desktop width. Column headers that squash and become unreadable are the regression this catches.
- Nothing cut off. On every screen you check, run `.agents/skills/ui-ux-test/detect-clipping.js` as `qa-test` step 5 and `ui-ux-test` step 4 say. The accessibility snapshot reports a badge's full text even when CSS cuts it, and a shrunken screenshot hides a few pixels of spill. PR #4726 passed both `qa-test` and `ui-ux-test` this way, and a reviewer found the badge overflow.
- Teardown. Close every page or tab you opened. With DevTools MCP, run `list_pages`, then `close_page` on each page you created. With Claude-in-Chrome, run `tabs_close_mcp` on your tabs, never the user's. Stop any dev server you started and confirm the port is free with `lsof -nP -iTCP:<port> -sTCP:LISTEN`. Report teardown as a step with its evidence. An open page keeps an isolated Chrome running until the session ends.

**Who signs off.** The agent reproduces problems and gathers evidence. The user gives the aesthetic verdict, so show the screenshot rather than declaring a UI correct. After a fix, capture your own screenshot before reporting it done, especially for a text or label change, which most often silently does not land.

**Supersedes.** Nothing in the repo. `qa-test` owns the driver and auth. This playbook adds the `--isolated` reasoning, the SSO limit on deployed dev hosts, teardown, and the Orca route for everyday browser work.

**Graduation.** Once proven, move this to a repo skill named `drive-browser` under `.agents/skills`, point the skills above at it by path, and delete this file.
