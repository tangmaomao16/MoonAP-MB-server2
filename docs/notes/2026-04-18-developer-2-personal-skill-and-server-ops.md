# Developer-2 Notes - Personal SKILL Reuse and Server Operations

## Metadata
- Authoring thread: `Developer-2`
- Workspace: `C:\my_work\MoonBit_Competition\GitHub\MoonAP-MB-server2`
- Written at: `2026-04-18 Asia/Shanghai`

## Why this note exists

This note records the practical implementation details discovered while continuing the
`Personal SKILL` reuse work and while fixing local Windows server rebuild/restart issues.

It is intended to help a future `Developer-3` thread resume quickly when the current
thread context becomes too large or slow.

## Scope completed in this round

### 1. Personal SKILL save flow now records real local folder handles

Current browser-side behavior:

- Saving a `Personal SKILL` still writes the exported skill folder:
  - `SKILL.md`
  - `program/main.wasm`
  - optional `program/main.mbt`
- The browser also stores a local directory handle for the saved skill in IndexedDB.
- `localStorage` is still used, but only as a lightweight index / fallback metadata store.

Important design point:

- `localStorage` is **not** the source of truth for Personal SKILL content.
- The real source of truth is the local skill folder plus its `SKILL.md`.

### 2. Personal SKILL list now tries to read real `SKILL.md`

Current browser-side list behavior:

- The `Personal-SKILL-Set` area loads saved entries from the local index.
- For each entry, MoonAP tries to reopen the saved directory handle from IndexedDB.
- If successful, MoonAP reads `SKILL.md` and derives:
  - `name`
  - `description`
  - `task_kind`
  - `runtime_mode`
  - `result_mode`
  - `runtime_spec`
- If reopening fails, the card still appears, but as an unavailable local skill.

This is the first real step from:

`saved record`

toward:

`reusable local skill object`

### 3. Personal SKILL click now loads real skill content before opening dialog

When the user clicks a `Personal SKILL` card:

- MoonAP first loads the corresponding local folder handle
- reads and parses `SKILL.md`
- caches the parsed skill object
- then opens the runtime dialog using the loaded skill metadata

Current runtime dialog behavior:

- Personal skill dialogs prefer loaded `runtime_spec`
- dialog title and summary use the loaded skill's real `name` and `description`
- fields are generated from the saved `runtime_spec`

### 4. Personal SKILL rerun wiring is only partially complete

Current state:

- `fastq-generator` personal skills can reuse the existing browser-side generator path
- `fastq-analysis` personal skills are routed to the current FastQ analysis path
- other task kinds are not yet wired for rerun

Important limitation:

- This is **not yet** a fully general artifact-runtime executor.
- It is still using the current task-specific browser bridges for rerun.

That is acceptable for now, but the next developer should treat it as an intermediate step.

## Important implementation details

## Personal SKILL storage model

Current implementation uses two layers:

### Layer 1: lightweight index

Stored in browser `localStorage`:

- skill id
- display name
- description fallback
- task metadata fallback
- saved time
- export root display name

This layer is used for:

- quick rendering fallback
- remembering the list of user-created skills

### Layer 2: real folder handle

Stored in browser IndexedDB:

- local directory handle for each saved skill folder

This layer is used for:

- reopening the actual local skill folder
- reading real `SKILL.md`
- later reading actual artifacts from `program/`

### Why this split exists

Browser file system handles should not be stuffed directly into `localStorage`.
The correct browser persistence path is IndexedDB.

## `SKILL.md` parsing strategy

Current parser extracts three things:

1. frontmatter
2. `# Key Attributes`
3. `# Runtime Spec`

Current expectations:

- frontmatter contains:
  - `name`
  - `description`
- `# Key Attributes` contains lines like:
  - `- task kind: fastq-generator`
  - `- runtime mode: form`
  - `- result mode: download`
  - `- wasm path: program/main.wasm`
- `# Runtime Spec` contains a fenced `json` block

Current parser is intentionally lightweight and string-based. It is not a full Markdown parser.

## Known pitfalls discovered

### 1. Multiple `ensurePersonalSkillRuntime()` implementations can drift

This happened in this round.

There were two browser-side implementations of the Personal SKILL runtime helper:

- one used during save
- one used during list/read

At one point:

- save-side helper exposed `putHandle`
- list/read-side helper exposed `getHandle`

Because both shared the same global runtime object name, whichever initialized first
could shadow the other and cause runtime errors such as:

`putHandle is not a function`

Lesson:

- if this helper evolves further, it should eventually be consolidated into one shared implementation
- until then, check both call sites together before editing

### 2. Minimal shell can silently hide SKILL panel content

Root cause of the "click SKILL button and nothing appears" bug:

- startup logic enters minimal shell mode
- minimal shell writes inline `style.display = "none"` onto `#modePanel`
- later, clicking `SKILL` only toggled the `is-open` class
- CSS class alone cannot override the existing inline hidden style

Fix applied:

- when opening the skill panel, MoonAP now clears inline `display` on:
  - `#modePanel`
  - `#privacyStrip`
- then toggles the `is-open` class

Lesson:

- any future shell-mode logic must consider both CSS classes and inline styles

### 3. `taskkill` was not reliable enough for MoonAP server stop on this machine

Observed behavior:

- `taskkill /pid <pid> /f` sometimes reported success
- but the MoonAP `server.exe` process still remained alive and kept locking the rebuilt executable

Stable fix:

- switch stop logic to PowerShell `Stop-Process -Force`
- then poll until the process actually disappears

## Current server operation workflow on Windows

### Problem that had to be solved

When rebuilding `cmd/server`, linker failures occurred because:

- existing `server.exe` was still running
- Windows held the executable open
- linker could not overwrite `_build\native\debug\build\cmd\server\server.exe`

Typical failure looked like:

- `LNK1104: cannot open file ... server.exe`

### Current reliable workflow

Use:

`tools\restart-moonap-server.cmd`

This script now does:

1. stop current MoonAP server on port `3000`
2. wait until the process is really gone
3. rebuild `cmd/server` using MSVC environment through `tools\moon-msvc.cmd`
4. start the built `server.exe` in background
5. wait for `http://127.0.0.1:3000` to answer

### Relevant scripts

- `tools\moon-msvc.cmd`
- `tools\stop-moonap-server.cmd`
- `tools\start-moonap-bg.cmd`
- `tools\restart-moonap-server.cmd`

### Important notes about each script

#### `tools\moon-msvc.cmd`

Purpose:

- loads Visual Studio MSVC environment with `VsDevCmd.bat`
- then runs `moon ...`

Use this for:

- `build`
- `test`
- `run`

Do not assume plain `moon` is enough for this repo on Windows.

#### `tools\stop-moonap-server.cmd`

Current logic:

- finds the listener on local port `3000`
- force-stops it with PowerShell `Stop-Process -Force`
- waits for the process to disappear

#### `tools\start-moonap-bg.cmd`

Current logic:

- checks that `server.exe` exists
- refuses to start if port `3000` is already in use
- starts `server.exe` hidden in the background
- polls `http://127.0.0.1:3000`
- fails if the process exits immediately or health check never succeeds

#### `tools\restart-moonap-server.cmd`

Current logic:

- stop
- build
- start

This is the preferred operator entry point.

## Current UI text changes made in this round

These were updated to match current user feedback:

### Top tagline

Current top tagline:

`MoonAP: MoonBit Agent Playground.`

`Tell, what APP you want to build. Or, directly use an existing SKILL.`

Implemented in:

- `cmd/server/main.mbt`
- `moonap_mb_server.mbt`
- `moonap_mb_server_test.mbt`

### Save button text

Current runtime save button text:

`Save APP into SKILL`

Implemented in:

- `cmd/web_app/main.mbt`

## What is working now

- save current FastQ workflow as Personal SKILL
- reopen the `SKILL` panel after the inline-style visibility bug fix
- show Personal SKILL cards from the saved browser index
- try to read real metadata from local saved `SKILL.md`
- click a Personal SKILL card and open a dialog based on saved metadata
- stable stop/build/restart flow for local MoonAP server on Windows

## What is not done yet

### 1. Full artifact-driven Personal SKILL runtime is not complete

Still missing:

- load and execute saved `program/main.wasm` as the canonical rerun path
- general rerun path for all task kinds
- clean separation between:
  - generated-artifact session state
  - reopened personal-skill state

### 2. Permission-loss recovery UX is incomplete

If browser handle access fails, MoonAP currently degrades the card to an unavailable state.
The UX is still basic.

Still needed later:

- explicit "reconnect local folder" flow
- clearer error messages for revoked permissions

### 3. `MoonAP-SKILL-Hub` unification is intentionally deferred

Current priority is only:

- user-created `Personal SKILL` reuse

Do not expand scope prematurely unless the user explicitly asks.

## Recommended next tasks for Developer-3

1. Verify the new `SKILL` panel behavior after hard refresh
2. Verify saved Personal SKILL cards still appear after browser reload
3. Verify clicking a saved Personal SKILL opens dialog fields from real `SKILL.md`
4. Finish rerun path for saved `fastq-generator`
5. Then generalize rerun logic from task-kind-specific bridges toward a cleaner artifact-driven executor

## Recommended sanity-check commands

### Rebuild and restart local server

```cmd
tools\restart-moonap-server.cmd
```

### Rebuild browser app only

```cmd
tools\moon-msvc.cmd build cmd/web_app --target js
```

### Check whether local server is up

```powershell
Invoke-WebRequest -UseBasicParsing http://127.0.0.1:3000
```

## Final handoff summary

If a future thread takes over, the most important mental model is:

- Personal SKILL reuse is now moving from `saved UI record` toward `real local skill folder`
- the next step is to finish the runtime half of that loop
- on Windows, server rebuild reliability depends on stopping the old `server.exe` cleanly before relinking
