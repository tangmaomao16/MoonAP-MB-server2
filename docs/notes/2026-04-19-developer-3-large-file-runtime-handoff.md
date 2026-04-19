# Developer-3 Large-File Runtime Handoff (2026-04-19)

This note is for the next primary Codex session, especially if Developer-4 takes over.

## Why this note exists

Developer-3 spent a large amount of context on three related tracks:

1. stabilizing real LLM API access on Windows;
2. adding a top-level `Experiment` entry point again;
3. starting a platform-level large-file runtime contract for MoonAP.

The main risk for the next session is not "where is the code?" but "which parts are real platform work, which parts are still transitional, and which failures were environmental rather than architectural."

## High-level state

MoonAP now has an initial platform-level large-file runtime direction, not just FastQ-only sample logic.

The implementation is still transitional, but these pieces are already in place:

- server-side task-kind inference now includes:
  - `large-file-generation`
  - `large-file-analysis`
- server-side runtime specs now include an `io_contract` for these large-file modes;
- browser-side runtime execution can now dispatch on `io_contract.host_capability`, not only legacy `task_kind`;
- there is a browser-local chunked analysis executor;
- there is a browser-local streamed file-generation executor using save picker + writable stream;
- SKILL export descriptions now know about `large-file-generation` and `large-file-analysis`.

This is important: MoonAP still does **not** have a final generic wasm host ABI for arbitrary MoonBit large-file programs. The current state is:

- platform-level runtime contract: partially present;
- browser host executor for that contract: present;
- universal generated-program ABI for chunk callbacks / stream callbacks: not finished.

## Files most relevant to this work

- [cmd/server/main.mbt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/cmd/server/main.mbt)
- [cmd/web_app/main.mbt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/cmd/web_app/main.mbt)
- [docs/notes/2026-04-18-developer-3-real-llm-api-environment-note.md](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/docs/notes/2026-04-18-developer-3-real-llm-api-environment-note.md)

## What was implemented

### 1. Top-right Experiment button

The old SKILL-panel experiment entry had effectively disappeared from the user's path, so a top-right `Experiment` button was added beside `Details`.

Relevant behavior:

- server HTML now renders `experimentButton`;
- web app binds that button to open the `free-llm-eval` run plan directly;
- this was added because the user wants easy manual testing, not hidden experimental tooling.

### 2. Real LLM API environment notes

The "real provider API suddenly broke again" problem happened more than once.

The important conclusion is unchanged:

- simulated `moonap://llm-sim` can work even when real HTTPS providers fail;
- real NVIDIA / ZAI / other providers can fail if the local MoonAP server is restarted inside a polluted or restricted execution environment;
- the recurring pattern was Windows environment / proxy / TLS related, not provider routing logic itself.

The dedicated environment note already records the detailed story:

- [2026-04-18-developer-3-real-llm-api-environment-note.md](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/docs/notes/2026-04-18-developer-3-real-llm-api-environment-note.md)

### 3. Free LLM FastQ Eval robustness

The experiment harness was made less fragile so that writeback failures do not instantly kill the whole experiment.

The specific adjustment was on the browser side:

- persistence of JSON and markdown results now records warnings instead of failing the entire eval immediately.

This made the `Free LLM FastQ Eval` path usable again for manual testing.

### 4. Large-file runtime contract

The large-file runtime work was intentionally framed as platform work, not a FastQ-only hack.

Server-side task routing now includes:

- `large-file-generation`
- `large-file-analysis`

Server-side runtime specs now expose `io_contract` data such as:

- `protocol: "moonap.large-file.v1"`
- `browser_local_only`
- `llm_receives_file_contents: false`
- `host_capability`
- `input_mode`
- `output_mode`
- `chunk_size_bytes`

Current host capabilities introduced:

- `chunked-local-analysis`
- `streamed-local-generation`

Browser-side runtime execution now uses these capabilities to choose execution path:

- chunked browser-local reading for analysis;
- streamed browser-local writing for large output generation.

## Important current bug and partial fix

### Symptom observed by the user

The user tested with Simulated GPT-5.4 using a prompt like:

`Generate a FastQ generator. Build a browser-local large file generator that can generate up to 1GB FastQ output using streamed local file writing instead of buffering the whole result in memory...`

The LLM eventually generated compilable MoonBit code, but the runtime UI showed:

- `Search text (optional)`
- `Preview lines`
- `Run streaming analysis`

That means the runtime was being treated as `large-file-analysis`, not `large-file-generation`.

### Root cause

The browser runtime UI was not the main bug. The misclassification happened earlier on the server side.

The runtime request log for that run showed:

- `task_kind: "large-file-analysis"`
- `runtime_mode: "file"`
- analysis-shaped runtime spec

So the wrong runtime UI was simply the consequence of a wrong task-kind inference.

### Fix applied

`runtime_task_kind_from_context(...)` in [cmd/server/main.mbt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/cmd/server/main.mbt) was updated so that:

- large-file detection uses lowercased prompt/source/title text;
- generation signals include words such as:
  - `generate`
  - `generator`
  - `create`
  - `output`
  - `write`
  - `writing`
  - `save file`
  - `save picker`
- analysis signals include words such as:
  - `analy`
  - `inspect`
  - `count`
  - `scan`
  - `parse`
  - `report`
- if both large-file and generation are present, generation now wins before analysis.

This change was compiled, release-built, and the local server health endpoint was confirmed healthy afterward.

### What still needs verification

Developer-3 fixed the inference logic and restarted the server, but the user had not yet re-run the exact prompt after the patched server became healthy.

So the remaining required verification is simple:

1. hard refresh the browser;
2. rerun the same large-file-generation prompt;
3. confirm the runtime UI now shows generation-oriented fields such as:
   - output name
   - target size in MB
   - line template
   - line length
4. confirm it no longer shows analysis-only fields.

If it still misroutes after a hard refresh, inspect the newest:

- `logs/runs/<run-id>/runtime-exec/latest-request.json`

and check `task_kind`.

## What is real platform progress vs. what is still temporary

### Real progress

- browser-local large-file IO is now explicitly part of runtime spec;
- generation and analysis are no longer expressed only as FastQ sample branches;
- browser runtime can dispatch by declared host capability;
- MoonAP can now describe a generic browser-local streamed generation mode to LLM-produced apps and SKILLs.

### Still temporary / not fully generalized

- there is still no final universal wasm ABI for stream callbacks;
- generated MoonBit code is not yet guaranteed to conform to a strict chunk-processing interface;
- task-kind inference is still heuristic text classification;
- this large-file runtime path is platform-shaped now, but not fully "contract-complete."

## Practical advice for Developer-4

If Developer-4 takes over, the best next steps are:

1. verify the prompt routing fix with the exact user prompt;
2. if correct, save a SKILL from the resulting large-file generator path;
3. inspect the resulting `SKILL.md` runtime section to ensure the new `io_contract` survives export/reopen;
4. only then move on to a more explicit ABI or prompt-template upgrade.

Do **not** assume that a wrong runtime UI means the browser executor is wrong. First inspect the logged runtime request and confirm which `task_kind` the server emitted.

## Recommended handoff summary in one sentence

MoonAP now has an initial platform-level browser-local large-file runtime contract, but the current frontier bug was server-side prompt-to-task-kind misclassification, not wasm execution itself.

## Update After Context Compression Warning

This section records the later Developer-3 work after the original note above. It should be treated as the latest handoff state if a Developer-4 session takes over.

### User-facing flow now verified by the user

The user used Simulated GPT-5.4 to generate a large FastQ generator with a prompt asking for browser-local streamed writing up to 1GB.

The app reached the runtime-ready UI with generation-oriented fields, and the user successfully generated:

- `C:\my_work\MoonBit_Competition\MoonAP-generated-result-files\fastq\moonap-output-64M.fastq`

The user then saved the generated app as a Personal SKILL:

- `C:\my_work\MoonBit_Competition\MoonAP-SKILL\Personal-SKILL-Set\large-fastq-generator`

The saved `SKILL.md` was inspected and looked correct. It records:

- `task kind: large-file-generation`
- `runtime mode: form`
- `result mode: download`
- runtime spec fields for FastQ generation.

### Important UX clarification

When the user runs a direct large-file generation runtime or reuses `large-fastq-generator` from the SKILL panel, the UI should show a `Choose output file/location` button before `Run`.

The intended UX is:

1. the user opens the generated runtime or SKILL;
2. the user edits generation parameters;
3. the user clicks `Choose output file/location`;
4. the browser's native save-file picker opens;
5. the selected browser `FileSystemFileHandle` is stored on the runtime card or dialog;
6. the user clicks `Run`;
7. MoonAP writes directly to the preselected file handle.

If the user skips `Choose output file/location`, `Run` should stop with a clear message asking for an output file first. Do not open the native save picker from the run button, because the user needs an explicit pre-run target-selection step for predictable demos and long writes.

The generated file is saved wherever the user chooses in that save picker. MoonAP intentionally does **not** invent or silently use an OS path. This is especially important for cross-platform behavior and browser security.

If the user asks "where did the SKILL output go?", the correct answer is:

1. the browser save dialog decides the destination;
2. if no save dialog appeared, the run did not reach the browser-local streamed writer;
3. inspect the right-side Process/State panels and browser permissions;
4. do not assume a server-side output path exists.

### Personal/Local SKILL large-file reuse is now wired

Before this update, `execute_dialog_skill()` only had special handling for older `fastq-generator` and `fastq-analysis` task kinds. A saved Personal SKILL with `task kind: large-file-generation` opened a dialog but had no real large-file streamed writer path behind `Run`.

This is now fixed in [cmd/web_app/main.mbt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/cmd/web_app/main.mbt):

- `browser_run_dialog_large_file_generation(...)` implements browser-local streamed FastQ generation from SKILL dialog fields;
- `execute_dialog_skill()` calls it for Personal SKILLs when `personal_task_kind == "large-file-generation"`;
- `execute_dialog_skill()` also calls it for Local SKILLs when `personal_task_kind == "large-file-generation"`.
- `browser_open_skill_dialog(...)` shows `Choose output file/location` for `large-file-generation` SKILLs.
- `cmd/server/main.mbt` also includes the same initial dialog HTML, because the dialog usually exists before `browser_open_skill_dialog(...)` runs.

The SKILL reuse path reads these dialog params:

- `output_name`
- `target_size_mb`
- `read_length`
- `read_header_prefix`
- `random_seed`
- `n_rate`
- `quality_char`

The browser writer generates FastQ records incrementally and writes chunks through `showSaveFilePicker()` plus `createWritable()`. It does not buffer the whole output file in memory.

### Large-file generation fields were made FastQ-friendly

The earlier generic labels `Line template` and `Line length` confused the user because the generated app was clearly a FastQ generator. The current `large-file-generation` profile now exposes:

- `Output FastQ file name`
- `Target size in MB`
- `Read length`
- `Read header prefix`
- `Random seed`
- `N base rate`
- `Quality character`

This exists in both:

- browser profile registry in [cmd/web_app/main.mbt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/cmd/web_app/main.mbt)
- server runtime spec in [cmd/server/main.mbt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/cmd/server/main.mbt)

This is still a transitional compromise: the platform-level profile is `large-file-generation`, but the current default field set is FastQ-oriented because FastQ is the competition demo/sample path. Future work should allow LLM-produced `moonap_runtime_spec()` to contribute app-specific fields in a more generic way.

### Two-stage LLM adaptation exists but is still minimal

Developer-3 implemented a minimal two-stage generation strategy:

1. Stage 1 asks the LLM for normal compilable MoonBit code.
2. If the compiled artifact appears to be a large-file task, Stage 2 asks the active LLM route to adapt the already-compiling code to MoonAP's large-file runtime contract.

Relevant browser functions:

- `browser_should_adapt_last_artifact_for_large_file_runtime()`
- `browser_adapt_last_artifact_for_large_file_runtime(...)`
- `run_moonap_runtime_adaptation()`

For generation, the Stage 2 prompt asks for:

- `fn moonap_runtime_spec() -> String`
- `fn moonap_preview(params_json : String) -> String`
- `fn moonap_generate_chunk(params_json : String, start_index : Int, max_bytes : Int) -> String`

For analysis, the Stage 2 prompt asks for:

- `fn moonap_runtime_spec() -> String`
- `fn moonap_init(params_json : String) -> String`
- `fn moonap_analyze_chunk(state_json : String, chunk_text : String) -> String`
- `fn moonap_finish(state_json : String) -> String`

Current limitation: the browser host still uses its own large-file executor for the demonstrated FastQ generation path. The final universal WASM callback ABI is not complete.

### Path handling and cross-platform boundary

The user explicitly reminded Developer-3 to prioritize cross-platform libraries/packages for path handling.

Current state:

- MoonBit/server/shared path normalization uses `illusory0x0/path`.
- The dependency is declared in [moon.mod.json](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/moon.mod.json) and [moon.pkg](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/moon.pkg).
- `normalize_virtual_path(...)` and `path_last_segment(...)` use `@path.Path::parse(...)` in [moonap_mb_server.mbt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/moonap_mb_server.mbt).
- `cmd/server/main.mbt` also uses `@core.path_last_segment(...)` for a local directory label.

Browser-side behavior is intentionally different:

- real output files are selected through browser `showSaveFilePicker()` file handles;
- MoonAP does not create Windows/macOS/Linux path strings for browser output;
- ZIP/SKILL internal entries use a centralized virtual path helper with `/` because ZIP paths are virtual archive paths, not host OS paths.

Developer-3 also removed duplicated browser filename sanitization and centralized it in:

- `browser_ensure_file_name_runtime()`
- `globalThis.__moonapFileNameRuntime`

Both direct large-file generation and SKILL-dialog large-file generation now call the same:

- `sanitize(...)` for suggested output file names;
- `sanitizeToken(...)` for FastQ header prefixes.

This is not a replacement for OS path libraries. It is only a browser boundary helper for suggested filenames and tokens.

### Commands and verification status

The useful browser build command passed:

```powershell
tools\moon-msvc.cmd build cmd\web_app --target js
```

`moon fmt` passed.

Do **not** overinterpret failures from these full-project commands in the current Windows setup:

```powershell
moon info
moon test
```

Observed failure reasons:

- `moon info` tries to check `cmd/web_app` with native backend, where `extern "js"` is unsupported.
- `moon test` in this environment attempts to compile `moonbitlang/async` with MinGW, but the async Windows C backend currently requires MSVC and fails with Windows API/header errors such as `bcrypt.h` missing.

This means the most reliable verification path for browser changes is currently:

1. `moon fmt`
2. `tools\moon-msvc.cmd build cmd\web_app --target js`
3. browser hard refresh
4. manual browser run/SKILL reuse test

### Avoid restarting the server unnecessarily

The user noticed repeated `tools\start-moonap-bg.cmd` calls caused hangs. Developer-3 should avoid calling it by habit.

Prefer:

- do not restart if only the already-built JS artifact changed and the browser can hard refresh;
- if a server restart is truly needed, use the existing restart script rather than repeatedly starting background instances;
- record whether the server is already healthy before changing process state.

### Current best next manual test

Ask the user to hard-refresh the browser and test the saved Personal SKILL:

1. open SKILL panel;
2. choose `large-fastq-generator`;
3. keep or edit fields;
4. click `Run`;
5. when the browser save dialog opens, choose the output folder and filename;
6. confirm right-side Process/State reaches success and the chosen file exists.

If no save dialog appears, inspect:

- browser support for File System Access API;
- whether the SKILL dialog `data-task-kind` is `large-file-generation`;
- whether `execute_dialog_skill()` reached `browser_run_dialog_large_file_generation(...)`;
- browser console errors.

### Large-file progress UI

The user reported that clicking `Run` on a large-file SKILL caused MoonAP to generate in the background with no obvious visible feedback. Developer-3 added a front-stage large-file progress card for long operations.

Relevant browser runtime:

- `browser_ensure_large_file_progress_runtime()`
- `globalThis.__moonapLargeFileProgressRuntime.update(...)`
- `globalThis.__moonapLargeFileProgressRuntime.error(...)`

The progress card shows:

- operation title, such as writing or reading a large file locally;
- percentage;
- processed bytes versus target/file size when known;
- chunk count;
- read/line count;
- reminder that file contents stay in the browser.

Both large-file paths now call this progress runtime:

- generated app runtime path through the existing `emitProgress(...)`;
- Personal/Local SKILL reuse path through `browser_run_dialog_large_file_generation(...)`.

There is CSS for `.large-file-progress` in [cmd/server/main.mbt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/cmd/server/main.mbt), but Developer-3 also injects the same critical CSS from `browser_ensure_large_file_progress_runtime()` in [cmd/web_app/main.mbt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/cmd/web_app/main.mbt). This is intentional: the local Windows server debug build can get stuck on a locked `_build/.../server.lib`, so the JS-side style injection lets the progress UI work without depending on rebuilding server HTML immediately.

Latest successful verification:

```powershell
moon fmt
tools\moon-msvc.cmd build cmd\web_app --target js
```

Generated JS was inspected and contains:

- `moonapLargeFileProgressStyle`
- `__moonapLargeFileProgressRuntime`
