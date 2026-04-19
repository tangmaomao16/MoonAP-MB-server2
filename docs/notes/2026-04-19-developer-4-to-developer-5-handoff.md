# Developer-4 to Developer-5 Handoff

Date: 2026-04-19

Project: MoonAP-MB-server2 / MoonAP: MoonBit Agent Playground

## Current Product State

MoonAP lets a user describe an APP in natural language, routes the request to an LLM, receives MoonBit source for `cmd/main/main.mbt`, compiles it to WebAssembly, runs the result in the user's browser, and optionally saves the workflow as a reusable MoonAP SKILL.

The main validated v0.1 demo path is bioinformatics:

- `large-fastq-generator`: browser-local FastQ file generation.
- `large-fastq-analyzer`: browser-local chunked FastQ analysis.
- Personal-SKILL export and reuse works.
- Cloud-SKILL-Hub discovery, Local-SKILL-Hub installation, and local reuse have been manually tested by the user.
- Large file contents must stay in the browser. The server and LLM should receive only metadata / summary metrics.

## Work Completed By Developer-4

### Runtime UI Fixes

Earlier in this session, the generated APP runtime flow had two visibility bugs:

- After LLM code generation and wasm compilation, the user did not see the next "Runtime ready" UI.
- After browser-local FastQ analysis completed, the user did not see the result/report actions.

These were fixed in `cmd/web_app/main.mbt` and compiled to:

- `web/app.js`
- `web/app.js.map`
- `web/app-live.js`
- `web/app-live.js.map`

Important runtime-related changes already present:

- `browser_remember_runtime_request(raw)` records runtime requests.
- `browser_remember_runtime_result(raw)` records runtime results.
- Runtime result card logic no longer depends on `browser_has_last_artifact_source`.
- Runtime cards scroll into view after becoming ready.
- Personal/Local SKILL `large-fastq-analysis` now renders a result card and report/download actions after execution.
- `Start new APP` exists on the runtime result card and clears/ignores the old runtime request id.

### FastQ Analyzer Fixes

The analyzer flow was improved so the report contains structured metrics and works for large browser-local files:

- The chunk parser no longer counts a trailing empty line as a real line.
- Runtime result payload includes structured fields such as `A_count`, `C_count`, `G_count`, `T_count`, `N_count`, read lengths, and preview reads.
- Dialog checkbox reading for SKILL analysis was fixed.
- Report page typography was changed away from the old serif style to a modern sans-serif stack.

### Current Active UI Change

The latest user request was:

1. Remove the top-right `Experiment` button from the MoonAP page.
2. Redesign the LLM configuration UI so Real API and Simulated API are displayed as tabs rather than stacked sections.
3. Default the LLM Router dialog to the Real API tab.
4. Keep Simulated API available for future development/demo use.
5. Add a Real API custom provider area where users can manually enter:
   - provider
   - endpoint URL
   - model name
   - API key

Implemented source changes:

- `cmd/server/main.mbt`
  - Removed the `Experiment` button from generated HTML.
  - Reworked `llmDialog` HTML into `Real API` and `Simulated API` tab panels.
  - Added `Custom provider` fields under Real API.
  - Added CSS for `.router-tabs`, `.router-tab`, `.router-tab-panel`, `.router-custom-fields`, and `.router-row-custom`.

- `cmd/web_app/main.mbt`
  - Bumped LLM router profile version to `6`.
  - Changed simulated OpenAI/GPT-5.4 default to disabled.
  - Added tab switching logic with `localStorage["moonap.llm.router.activeTab"]`.
  - Added custom provider read/save support using `providerName` and `custom: true`.
  - Preserves custom endpoint URL instead of normalizing it to known provider defaults.
  - Prefixes custom keys if the user enters a known provider name such as `openai` or `gemini`, avoiding accidental provider-specific routing behavior.
  - LLM summary/onboarding labels now prefer `providerName`.
  - Save validation now requires enabled provider + model + endpoint URL + API key.
  - A hidden/no-op `browser_on_click("#experimentButton", ...)` binding remains only to keep `show_experiment_entry()` referenced and avoid MoonBit unused warnings. The button itself is gone from HTML.

Generated files updated from the web app build:

- `web/app.js`
- `web/app.js.map`
- `web/app-live.js`
- `web/app-live.js.map`

## Verification Performed

Commands that passed:

- `moon fmt`
- `tools\moon-msvc.cmd build cmd\web_app --target js`
- `Copy-Item ... web\app*.js...` after escalation because the sandbox denied writes to generated web files.
- `tools\restart-moonap-server.cmd`
- HTTP health check: `Invoke-WebRequest http://127.0.0.1:3000/` returned `200`.

The served HTML was checked and confirmed:

- No `experimentButton` appears in the topbar.
- `routerTabReal` exists.
- `routerPanelSimulated` exists.
- `routerProviderCustom` exists.

Important note: one later parallel tool run was interrupted by the user because the UI appeared stuck. The server restart part completed with exit code `0`, but the parallel `node --check` commands were aborted before their outputs returned. Earlier in the same change set, `node --check web\app-live.js` and `node --check web\app.js` had passed before the final one-line validation tweak. Developer-5 should rerun them once:

- `node --check web\app-live.js`
- `node --check web\app.js`

## Current Git Status

At the time of this handoff, expected modified files are:

- `cmd/server/main.mbt`
- `cmd/web_app/main.mbt`
- `web/app-live.js`
- `web/app-live.js.map`
- `web/app.js`
- `web/app.js.map`
- `docs/notes/2026-04-19-developer-4-to-developer-5-handoff.md`

Do not revert these unless the user explicitly asks.

## Recommended Immediate Next Checks

Developer-5 should do these before continuing v0.1 release work:

1. Run `node --check web\app-live.js`.
2. Run `node --check web\app.js`.
3. Refresh `http://127.0.0.1:3000/` in Chrome/Edge.
4. Click `LLM`.
5. Confirm the default visible tab is `Real API`.
6. Confirm `Simulated API` appears only after clicking its tab.
7. Confirm `Custom provider` fields enable after checking its checkbox.
8. If using simulated mode for internal testing, click `Simulated API`, enable OpenAI/GPT-5.4 simulated, save, then continue testing.
9. Test a generic non-FastQ prompt such as `Build an app where the user enters a Celsius temperature and gets the Fahrenheit temperature.`; it should enter LLM MoonBit codegen, not the old `/api/agent/context` path.

## Latest Submit-Flow Fix

After the first handoff draft, Developer-4 found that generic prompts could repeatedly show:

- `Provider: chat`
- `Stage: context`
- `Result: ready`
- `Context normalized by MoonBit frontend and native server.`
- `No LLM prompt captured yet.`

Root cause: `submit_message()` only routed selected keywords such as `fastq`, `generator`, `synthetic`, and MoonBit benchmark phrases into `run_llm_moonbit_codegen`. A generic prompt like a Celsius-to-Fahrenheit app did not match those keywords, so it fell through to the legacy `/api/agent/context` demo endpoint. That endpoint returns placeholder `chat` context, not an LLM codegen attempt.

Fix: once LLM config exists, `submit_message()` now routes all ordinary natural-language APP prompts to `run_llm_moonbit_codegen`, while preserving the special FastQ-file runtime path and `moonbit benchmark` shortcut. The obsolete `context_path()` and `active_skill_from_context()` helpers were removed from `cmd/web_app/main.mbt`.

## Auto-Compaction Checkpoint

Developer-4's context auto-compacted again while investigating repeated `chat/context ready` UI states. Preserve these exact conclusions:

- The repeated `Context normalized by MoonBit frontend and native server.` state was not a real LLM generation failure.
- It happened because generic prompts such as `Build an app where the user enters a Celsius temperature and gets the Fahrenheit temperature.` fell through to the old `/api/agent/context` path instead of entering `run_llm_moonbit_codegen`.
- The right-side `No LLM prompt captured yet.` text is the giveaway: no LLM system/user prompt was sent for those attempts.
- The server's old context endpoint intentionally returns placeholder context. With no hint query it returns `active_skill: "chat"` and `content: "chat"`, which is why the Details panel showed `Provider: chat`, `Stage: context`, `Result: ready`.
- Current `submit_message()` behavior should be:
  - Empty prompt: ask user to enter a task.
  - No usable LLM config: open LLM dialog and return.
  - Formal verification toggle: warn that MoonBit 0.9 `moon prove` is future work, then continue.
  - Browser has a FastQ file and prompt/file name indicates FastQ: run browser-local FastQ runtime.
  - `moonbit benchmark`: run benchmark shortcut.
  - Everything else: call `run_llm_moonbit_codegen("MoonBit Task", message, ..., false)`.

Important current line anchor after formatting:

- `cmd/web_app/main.mbt`, around lines `8145-8180`, contains the corrected `submit_message()` route.

Real API status at this checkpoint:

- NVIDIA `meta/llama-4-maverick-17b-128e-instruct` has repeatedly failed simple MoonBit generation in this project, hallucinating Rust/JS-like imports and non-MoonBit APIs.
- Gemini API tests may time out or rate-limit on the user's free-tier Google AI Studio project. The router test timeout was already increased from `8s` to `30s`.
- Gemini 3 model IDs currently exposed in the Gemini preset are `gemini-3-flash-preview` and `gemini-3.1-flash-lite-preview`, plus `gemini-2.5-flash`.
- The product direction from the user is to avoid complex prompt adapters and overly clever repair systems for v0.1. Prefer trusting strong models and keeping MoonAP generic.
- Simulated GPT-5.4 remains the reliable internal/demo path, but public default UI should guide users toward Real API first.

If Developer-5 resumes from here, the highest-value browser test is:

1. Open `http://127.0.0.1:3000/`.
2. Configure at least one usable LLM provider, or enable Simulated API for internal testing.
3. Submit `Build an app where the user enters a Celsius temperature and gets the Fahrenheit temperature.`
4. Confirm Details shows an LLM prompt mode and captured system/user prompts, not `No LLM prompt captured yet`.
5. Confirm the process enters LLM/codegen/compile stages rather than `chat/context/ready`.

## Generic Form Runtime Fix

After the auto-compaction checkpoint, Developer-4 tested Simulated LLM GPT-5.4 with prompts like:

- `Build an app where the user enters a Celsius temperature and gets the Fahrenheit temperature.`
- `Build an app where the user enters two number and gets the sum.`

The runtime card appeared, but there was no user input form and clicking `Run runtime step` failed with `resultMode is not defined`.

Root causes:

- `browser_record_demo_runtime_result()` used `resultMode` near its report handling branch but did not define it in that function scope.
- Server-side `runtime_spec_json_for_task_kind("generic-task")` returned a generic action with `fields: []`, so the browser had no parameters to render for ordinary non-FastQ apps.

Fixes:

- `cmd/web_app/main.mbt`: defined `const resultMode = String(runtimeRequest.result_mode || "text");` inside `browser_record_demo_runtime_result()`.
- `cmd/server/main.mbt`: runtime registration now calls `runtime_spec_json_for_context(task_kind, original_prompt, source_text)` instead of only `runtime_spec_json_for_task_kind(task_kind)`.
- Generic Celsius-to-Fahrenheit prompts now receive a `celsius` float input field.
- Generic two-number sum prompts now receive `number_a` and `number_b` float input fields.
- Other generic prompts now receive at least one `input_text` field.
- Generic runtime result generation now displays submitted inputs and computes simple Celsius/Fahrenheit or two-number sum preview results for these two generic smoke-test cases.

Verification after this fix:

- `moon fmt` passed.
- `tools\moon-msvc.cmd build cmd\web_app --target js` passed.
- `node --check web\app-live.js` passed.
- `node --check web\app.js` passed.
- `tools\restart-moonap-server.cmd` completed successfully.

Note: a direct parallel `tools\moon-msvc.cmd build cmd\server --target native` attempt reached C/linking but failed because Windows could not overwrite the locked `server.lib`. The restart script handled the rebuild/restart path successfully afterward.

## v0.1 Release Work Still Needed

The highest-priority release risk is fresh-clone startup:

- The current server historically served the built JS from `_build/js/debug/build/cmd/web_app/web_app.js`.
- A fresh GitHub clone may not have `_build`.
- For v0.1, ensure either:
  - startup builds the web app before serving, or
  - server falls back to committed `web/app-live.js`, or
  - README/start script clearly performs the build step.

Recommended v0.1 finishing list:

- Make a single reliable Windows startup path, ideally `tools\restart-moonap-server.cmd` or a friendlier wrapper.
- Rewrite README for external developers: prerequisites, clone, build, run, browser URL, Real API configuration, Simulated API developer mode, SKILL usage.
- Add troubleshooting for:
  - Chrome/Edge requirement for File System Access API.
  - Windows MSVC/MoonBit setup.
  - Port `3000` already in use.
  - LLM API test failure.
  - Simulated API is not the public default anymore.
- Ensure `.gitignore` excludes local build/cache/runtime folders and any personal SKILL directories.
- Decide whether to commit generated `web/app*.js` as v0.1 distribution artifacts.
- Run a clean-clone rehearsal before GitHub release.

## Caution For Future Work

- Do not send user file contents to the LLM. Keep browser-local file processing as the default for large input files.
- Do not remove Simulated API. It is intentionally hidden behind a tab but remains important for demos and local development.
- Avoid broad rewrites of `cmd/web_app/main.mbt`; it is large and contains many browser runtime bridges. Prefer narrow patches.
- If changing LLM provider storage, preserve compatibility with `moonap.llm.router.v1` in localStorage.
- When changing server HTML, remember the running server must be rebuilt/restarted before the browser sees it.
