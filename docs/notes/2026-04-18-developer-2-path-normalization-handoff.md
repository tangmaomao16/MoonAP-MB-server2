# Developer-2 Path Normalization Handoff

Date: 2026-04-18

This note records the first completed step of the MoonAP cross-platform path cleanup, so Developer-3 can continue from a clean boundary.

## Why This Work Started

The user explicitly wants MoonAP to eventually work not only on Windows, but also on macOS and Linux Ubuntu.

The main immediate risk is not only OS-specific startup scripts, but also path handling assumptions scattered across:

- MoonBit server code
- browser-side JS embedded in `cmd/web_app/main.mbt`
- ZIP install / extraction logic
- Cloud catalog path fields such as `folder_path` and `zip_path`

The user asked that this be solved in layers and that a MoonBit path library should be used rather than relying only on ad-hoc string splitting.

## Chosen Path Library

I added this MoonBit community package:

- `illusory0x0/path@0.2.0`

It was installed with:

```powershell
moon add illusory0x0/path
```

Files changed for dependency wiring:

- [moon.mod.json](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/moon.mod.json)
- [moon.pkg](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/moon.pkg)

## Layering Decision

I used this layering rule.

### 1. Protocol / virtual paths

These should always normalize to forward slashes:

- `folder_path`
- `zip_path`
- GitHub repository-relative paths
- ZIP internal entry paths

These are not supposed to follow host OS separators.

### 2. MoonBit shared helper layer

I added reusable helpers in:

- [moonap_mb_server.mbt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/moonap_mb_server.mbt)

Current helpers:

- `normalize_virtual_path(path : String) -> String`
- `path_last_segment(path : String) -> String`

Design:

- first try `@path.Path::parse(...)`
- if parse fails, fall back to a conservative legacy normalization path

This keeps current behavior resilient even if the input string is not a valid fully-typed filesystem path for the library.

### 3. Browser local filesystem access

For browser local writes, we still should not hand-build platform OS paths.

The current approach continues to use:

- `getDirectoryHandle(...)`
- `getFileHandle(...)`

with relative path segments.

That is the correct direction for cross-platform browser-local storage.

## What Was Actually Changed

### A. Server-side `run_id_from_dir`

This function previously did:

```moonbit
for part in dir.split("/") { ... }
```

which was fragile for Windows-style paths.

It now uses:

- `@core.path_last_segment(dir)`

in:

- [cmd/server/main.mbt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/cmd/server/main.mbt)

This is the first real MoonBit code path migrated away from hardcoded `/` splitting.

### B. Shared MoonBit helpers added

In:

- [moonap_mb_server.mbt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/moonap_mb_server.mbt)

I added:

- `is_path_separator_char`
- `string_has_path_separator_at`
- `legacy_last_path_segment`
- `normalize_virtual_path`
- `path_last_segment`

This is intended to become the common entry point for future MoonBit-side path cleanup.

### C. Tests added

In:

- [moonap_mb_server_test.mbt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/moonap_mb_server_test.mbt)

I added tests for:

- Windows and Unix last-segment extraction
- virtual path normalization to forward slashes

### D. Cloud / ZIP / Local install path cleanup in browser JS

In:

- [cmd/web_app/main.mbt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/cmd/web_app/main.mbt)

I did a first targeted cleanup for the most important path-sensitive flow:

- Cloud catalog normalization
- ZIP path inference
- Cloud install to Local SKILL Hub
- ZIP entry extraction
- target folder path creation

Specifically, I introduced local JS helpers inside the relevant functions:

- `normalizeVirtualPath`
- `splitVirtualPath`
- `lastVirtualSegment`

These now normalize:

- `folder_path`
- `zip_path`
- ZIP entry paths
- install target subpaths

This is important because we already saw real ZIP entries with Windows-style backslashes.

## Verification Status

### Successful

These succeeded after the path-library integration:

```powershell
moon fmt
moon info -p tangmaomao16/moonap_mb_server
tools\moon-msvc.cmd build cmd\web_app --target js
tools\moon-msvc.cmd build cmd\server --target native
tools\restart-moonap-server.cmd
```

Health endpoint check also succeeded:

- [http://127.0.0.1:3000/api/health](http://127.0.0.1:3000/api/health)

At the time of writing, local MoonAP server restarted successfully with:

- PID `41220`

### Known failure that is not caused by this path work

`moon test -p tangmaomao16/moonap_mb_server` still fails in this environment.

The failure is currently dominated by:

- `moonbitlang/async` native Windows C toolchain issues under MinGW
- Windows C symbol / header availability mismatches
- unrelated existing native/backend constraints

This test failure is not the same as the path changes breaking project code.

## Important Current Limitation

This round only cleaned the first layer.

It did **not** yet fully replace every path assumption in `cmd/web_app/main.mbt`.

There are still many browser-side inline JS blocks using ad-hoc path manipulation. The current cleanup only touched the most important path-sensitive install/catalog flow.

## Recommended Next Steps For Developer-3

### 1. Continue replacing high-risk path code in layers

Next best candidates:

- more `split("/")` usage in `cmd/web_app/main.mbt`
- any remaining path-last-segment logic
- any path values persisted to browser state

Do **not** try to rewrite the entire file at once.

### 2. Keep the current rule clear

Use this rule consistently:

- protocol / catalog / ZIP / repo paths use normalized `/`
- browser local file writes use handle traversal, not OS-path string concatenation

### 3. Audit Windows-only validation rules

There is still at least one area where the frontend uses Windows-invalid filename characters as the generic rule for all platforms.

That is safe but overly restrictive for macOS/Linux users.

This should be cleaned later, but it is lower priority than path normalization in actual runtime flows.

### 4. Separate “path cleanup” from “browser compatibility”

Do not conflate these two issues:

- path separator normalization
- File System Access API browser support

Even with perfect path handling, browser-local SKILL Hub still depends heavily on Chromium-style browser support.

## Suggested Developer-3 Reading Order

Read these in order:

1. [2026-04-18-developer-2-skill-hub-zip-handoff.md](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/docs/notes/2026-04-18-developer-2-skill-hub-zip-handoff.md)
2. [2026-04-18-developer-2-path-normalization-handoff.md](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/docs/notes/2026-04-18-developer-2-path-normalization-handoff.md)
3. [2026-04-18-developer-2-personal-skill-and-server-ops.md](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/docs/notes/2026-04-18-developer-2-personal-skill-and-server-ops.md)

## Handoff Summary

This step completed:

- community path package selection and integration
- first MoonBit shared helper layer for path normalization
- first real server-side migration away from hardcoded `/`
- first targeted browser-side cleanup for Cloud/ZIP/Local install flow

This step did **not** complete:

- full browser-side path cleanup
- macOS/Linux startup scripts
- broad browser compatibility fallback for local filesystem features

