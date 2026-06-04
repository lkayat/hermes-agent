# AGENTS.md — Operating Rules for Local Agents
**Read this at the START of every run.** You are a capable executor; your weak spots are *diagnosis* and *editing large
files*. These rules keep you out of the loops that have cost the most time. Follow them literally.

## 1. Evidence before theory  (failure mode #1)
- NEVER explain a failure with a guess. Before you state a cause, CAPTURE it:
  - Build / type error → run `npx tsc --noEmit` and read the **first** error. Fix that exact line.
  - "Nothing changed after my edit" → add `console.log('MARKER-'+Date.now())`, save, confirm it reaches the browser.
- BANNED theories (almost never true here): **"browser cache" / "stale bundle"** — `next dev` (Turbopack) hot-reloads
  on every save and Playwright uses a fresh context, so cache is NOT your problem. **"Must be a TS error"** without the
  compiler output is not a diagnosis.
- ONE attempt per theory. If it doesn't work, STOP, re-read the real error/log, and report what you **saw** (verbatim).
  Do not try variations of the same guess.

## 2. Protect the files  (failure mode #2: corrupting code)
- Make the SMALLEST change that fixes the problem. Re-read the surrounding lines before editing.
- CHECKPOINT before risky multi-edit work: `git add -A && git commit -m "wip: checkpoint"`.
- If an edit corrupts a file (a function/brace goes missing, it won't parse), **DO NOT hand-repair it.** Run
  `git checkout -- <file>` to restore the last good version, then redo the change deliberately. Hand-stitching a mangled
  file is the single biggest time sink — revert instead.
- Don't mix many surgical patches AND a full-file rewrite of the same file in one sitting. Pick one approach.

## 3. Definition of done — the gate
- You are NOT done until **`./scripts/preflight.sh` passes.** Run it before reporting. If it fails, the error it prints
  is your next task — never report "done" over a failing gate.
- "Done" = committed **and pushed** (`git log origin/<branch> -1` shows your commit) · gate green · no `/tmp` paths in
  source · assets under `public/assets/`.

## 4. Stay in your lane
- Visual / UX quality is judged by **Leo**, never by you or the vision model. When a task says "stop for sign-off",
  STOP and report screenshots — do not self-approve or merge a guessed look.
- Never fabricate output (no invented screenshots, logs, or test results). An honest failure beats a fake success.
- Mark anything you need from Leo as `PENDING-LEO` and move on. Stop retrying a card after 2 real attempts.
