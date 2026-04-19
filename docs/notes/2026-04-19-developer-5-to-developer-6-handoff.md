# Developer-5 to Developer-6 Handoff

Date: 2026-04-19

Project path:

`C:\my_work\MoonBit_Competition\GitHub\MoonAP-MB-server2`

## Current Mission

MoonAP is the MoonBit Agent Playground:

1. A user describes an APP in natural language.
2. MoonAP sends the task to an LLM route.
3. The LLM returns MoonBit source.
4. MoonAP compiles the source to WebAssembly.
5. The browser runs the resulting APP locally.
6. A good APP can be saved as a reusable MoonAP-SKILL.

The v0.1 demo target is not "a FASTQ-only tool". FASTQ generator/analyzer are important proof cases, but the platform abstraction must stay generic: LLM-generated MoonBit programs, browser-local runtimes, and reusable SKILL packaging.

## Architecture Principles to Preserve

- Large user data must stay in the browser. Do not send large files or private file contents to the LLM.
- Cloud-SKILL-Hub is for discovery and installation only. It is not the place where SKILLs run.
- Local-SKILL-Hub and Personal-SKILL-Set are where SKILLs actually run.
- Keep Simulated LLM GPT-5.4 as an optional route. The competition demo may depend on it when real model access is unstable.
- Keep Real API routes. NVIDIA and ZAI/GLM are important targets, and the UI now supports custom providers.
- Do not hard-code MoonAP as a FASTQ app. Add runtime profiles/contracts as generic platform capabilities.
- Prefer structured runtime contracts over one-off prompt keyword hacks whenever possible.
- On Windows, prefer the existing path normalization and platform helpers. Avoid raw string path joining where a helper or library exists.

## Current Git State at Handoff

Developer-5 was interrupted after context compression while finishing the generic SKILL reuse and Cloud Hub publishing work. The worktrees are **not clean**. Do not revert these changes; they are the current forward work.

Main repo current status:

```text
 M cmd/web_app/main.mbt
 M web/app-live.js
 M web/app-live.js.map
 M web/app.js
 M web/app.js.map
?? tools/publish-demo-skills.ps1
?? tools/test-skill-flow.ps1
```

Cloud SKILL-Hub repo current status at:

`C:\my_work\MoonBit_Competition\GitHub\MoonAP-SKILL-Hub`

```text
 M index.json
?? demo/
```

The Cloud Hub changes contain generated demo utility SKILL folders/zips under `demo/utilities/` and matching `index.json` entries. They have not yet been committed/pushed.

Most recent committed main-repo commits before the interrupted work:

- `aac92ae Use latest chat content for simulated prompt classification`
- `ac11a21 Reset runtime state between demo prompts`
- `3c1ced5 Preserve escaped JSON fields in runtime results`
- `85e606f Promote generic runtime specs from demo prompts`
- `1c3e8f1 Classify simulated prompts from user message`
- `baf7b83 Cover v0.1 demo prompts with generic runtimes`
- `f3f030d Generalize simulated unit conversion forms`
- `31088dd Automate simulated LLM demo responses`

Do not revert these unless the user explicitly asks.

## Developer-4 Changes Already Inherited

Developer-4 recently:

- Removed the webpage top-right `Experiment` button.
- Reworked LLM config into `Real API` / `Simulated API` tabs.
- Added a custom provider section for real APIs.
- Added Gemini presets:
  - `gemini-3-flash-preview`
  - `gemini-3.1-flash-lite-preview`
- Increased LLM API test timeout from 8s to 30s.
- Fixed normal prompts accidentally falling into `/api/agent/context`.
- Fixed generic runtime missing form inputs for Celsius/Fahrenheit and two-number sum.
- Fixed frontend `resultMode is not defined`.
- Synced `web/app.js` and `web/app-live.js`.

## Developer-5 Main Changes

Developer-5 focused on making v0.1 demo prompts stable without turning MoonAP into a pile of one-off examples.

Important implementation idea:

- Use a runtime contract embedded in generated MoonBit source comments:
  - `MOONAP_RUNTIME_SPEC_BEGIN`
  - JSON runtime spec
  - `MOONAP_RUNTIME_SPEC_END`
- The server extracts this contract and passes it to the browser as `runtime_spec` / `runtime_ui`.
- The browser renders generic form fields from the contract and sends form input back for browser-local runtime execution.

This is the core abstraction that should be extended rather than replaced.

### Simulated LLM Demo Coverage

The automated simulated route now covers these v0.1 demo prompts:

1. Celsius to Fahrenheit converter.
2. Minutes to seconds, or seconds to minutes converter.
3. Two-number sum.
4. BMI calculator.
5. Circle area/circumference calculator.
6. Loan payment calculator.
7. Tip calculator.
8. JSON formatter and validator.
9. Text analyzer.
10. CSV analyzer.
11. Large FASTQ generator.
12. Large FASTQ analyzer.

FASTQ generator/analyzer remain special larger browser-local workflows. The smaller utility demos use the generic form runtime contract path.

### Prompt Classification Fixes

Earlier, simulated LLM classification could be polluted by the system prompt. Example:

- System prompt mentioned both `text-analysis` and `json-formatter`.
- User prompt asked for a text analyzer.
- The simulated route sometimes generated JSON formatter source anyway.

Developer-5 fixed this in `cmd/server/main.mbt` by making `llm_sim_user_prompt_haystack` use the latest chat `content` field as the current user task. This keeps the system prompt from stealing classification.

The key function is near:

`cmd/server/main.mbt`, `llm_sim_user_prompt_haystack`

### Runtime State Reset Fixes

Developer-5 also fixed stale runtime state between demo prompts. This mattered because the browser could show the previous APP's runtime UI after starting a new prompt. `Start new APP` now clears artifact/runtime state more reliably, and watcher ordering was adjusted to avoid stale UI reuse.

If a user reports "I asked for text analyzer but still see JSON formatter", first verify they are on a build including `ac11a21` and `aac92ae`, then ask them to press `Ctrl+F5` and use `Start new APP`.

### JSON Pretty-Print Fix

JSON formatter previously mishandled escaped quotes inside the JSON input string, causing pretty-print output like:

```text
{
  \
```

Developer-5 fixed JSON field extraction/unescaping so escaped `\"`, `\\`, `\n`, `\r`, and `\t` are preserved correctly through the runtime request path.

## Late Developer-5 Work: Generic SKILL Reuse

After the earlier commits above, Developer-5 started fixing the remaining SKILL story:

1. Save generated APP as Personal SKILL.
2. Reuse that Personal SKILL.
3. Publish to Cloud-SKILL-Hub.
4. Install from Cloud into Local-SKILL-Hub.
5. Reuse the Local SKILL.

The user manually confirmed this full flow for `large-fastq-analyzer2`:

- Personal save: passed.
- Personal reuse: passed.
- Cloud install: passed.
- Local reuse: passed.

Then Developer-5 moved on to make the **generic demo utility SKILLs** reusable too, not just FASTQ-specific SKILLs.

### Main Repo Changes Not Yet Committed

`cmd/web_app/main.mbt` now includes a generic Personal/Local SKILL runner path:

- `browser_open_skill_dialog` reads `runtime_spec` from saved SKILL metadata.
- File input UI is selected from the runtime spec instead of being FASTQ-only.
- CSV-style file SKILLs use a browser-local file picker and keep file contents in the browser.
- Personal and Local SKILLs with unknown/small generic task kinds call a new `browser_run_dialog_generic_skill(...)` frontend bridge instead of falling back to the old demo text.
- Existing large FASTQ generator/analyzer special paths are preserved.

The new generic runner currently supports:

- `tool_kind=text-analysis`
- `tool_kind=json-formatter`
- `analysis_type=csv-summary` / file-mode CSV summary
- form calculators driven by `computed_outputs` or `outputs` expressions, including functions like `pow`, `sqrt`, `abs`, `min`, and `max`
- simple fallback cases for Celsius conversion and two-number sum

Generated JS has already been synced into:

- `web/app-live.js`
- `web/app.js`
- the two source maps

### New Main Repo Scripts Not Yet Committed

`tools/test-skill-flow.ps1`

- Validates Personal, Local, and Cloud SKILL directories.
- Checks `SKILL.md`, `program/main.mbt`, `program/main.wasm`, sibling zip files, and Cloud `index.json` consistency.
- Supports `-SkillName`, `-Strict`, `-RequireLatestSave`, and `-RequireLocalInstall`.

`tools/publish-demo-skills.ps1`

- Generates and publishes 10 generic demo utility SKILLs into the Cloud Hub.
- It calls the simulated GPT-5.4 route, compiles generated MoonBit, copies `main.mbt`/`main.wasm`, writes `SKILL.md`, creates zip archives, and updates Cloud `index.json`.
- It is PowerShell 5.1 compatible; do not reintroduce PowerShell 7-only operators such as `??`.

Generated Cloud demo skills:

1. `celsius-fahrenheit-converter`
2. `minutes-seconds-converter`
3. `two-number-sum`
4. `bmi-calculator`
5. `circle-calculator`
6. `loan-payment-calculator`
7. `tip-calculator`
8. `json-formatter-validator`
9. `text-analyzer`
10. `csv-summary-analyzer`

Together with the existing FASTQ generator/analyzer entries, the 12 v0.1 demo categories are represented in Cloud-SKILL-Hub.

## Validation Already Run

The following passed after the earlier committed demo prompt fixes:

```powershell
moon fmt
tools\restart-moonap-server.cmd
tools\test-demo-prompts.ps1
tools\moon-msvc.cmd build cmd\server --release
node --check web\app.js
node --check web\app-live.js
git status --short
```

`tools\test-demo-prompts.ps1` reported all 12 demo prompts as OK and also checked sequential registration:

- JSON formatter registered `json_text`.
- Text analyzer registered `text-analysis` immediately after JSON formatter.

Direct simulated LLM proxy reproduction also passed:

- Request body had a system message mentioning both JSON formatter and text analyzer.
- User message asked for text analyzer.
- Response contained `text-analysis`.
- Response did not contain `json-formatter`.

The following also passed after the late generic SKILL runner edits:

```powershell
moon fmt
tools\moon-msvc.cmd build cmd\web_app --target js
node --check web\app.js
node --check web\app-live.js
powershell -ExecutionPolicy Bypass -File tools\test-demo-prompts.ps1
tools\moon-msvc.cmd build cmd\server --release
powershell -ExecutionPolicy Bypass -File tools\test-skill-flow.ps1
```

`tools\test-demo-prompts.ps1` passed all 12 demo prompts after the generic SKILL runner edits.

`tools\test-skill-flow.ps1` saw 14 Cloud catalog entries after `tools\publish-demo-skills.ps1` generated the 10 demo utility SKILLs.

Important: the server restart command was started during the interrupted turn and appears to have exited successfully, but Developer-6 should rerun it before browser testing to remove doubt:

```powershell
tools\restart-moonap-server.cmd
```

## Important Windows Notes

- Do not prefer `tools\start-moonap-bg.cmd`; it has hung multiple times.
- Prefer:

```powershell
tools\restart-moonap-server.cmd
```

- If server build fails because `server.exe` or `server.lib` is locked, inspect processes first:

```powershell
Get-Process server
```

- Confirm it is the local MoonAP server before stopping it.
- Usual validation commands:

```powershell
moon fmt
tools\moon-msvc.cmd build cmd\web_app --target js
tools\moon-msvc.cmd build cmd\server --release
node --check web\app.js
node --check web\app-live.js
tools\test-demo-prompts.ps1
```

- `moon info` and `moon test` have not been stable enough in this Windows environment to be the only source of truth.

## Current User-Facing Test Script

For manual browser testing after a restart:

1. Open `http://127.0.0.1:3000`.
2. Press `Ctrl+F5`.
3. Click `Start new APP`.
4. Use Simulated LLM GPT-5.4.
5. Try these prompts:

```text
Build an app where the user enters a Celsius temperature and gets the Fahrenheit temperature.
```

Expected:

- Runtime UI has `Celsius temperature`.
- Button says `Convert temperature`.
- Enter `25`.
- Result shows `77` Fahrenheit.

```text
Build a JSON formatter and validator.
```

Expected:

- Runtime UI has `JSON text`.
- Button says `Format JSON`.
- Enter `{"hello":"moonap","count":2}`.
- Result shows valid JSON and a pretty-printed object.

```text
Build a text analyzer that counts characters, words, lines, and estimated reading time.
```

Expected:

- Runtime UI has `Text`.
- Button says `Analyze text`.
- Result shows characters, words, lines, and estimated reading time.

```text
Build a CSV analyzer that reports row count, column names, missing values, and numeric column summaries.
```

Expected:

- Runtime UI has `CSV text`.
- Button says `Analyze CSV`.
- Result reports rows/columns/missing values/numeric summaries.

## Browser Automation Status

Developer-5 checked whether `playwright` was locally available:

```powershell
node -e "try { require('playwright'); console.log('playwright:yes') } catch (e) { console.log('playwright:no') }"
```

It returned:

```text
playwright:no
```

So the latest verification was API/build/script based, not real browser-click automation. If Developer-6 adds browser automation, keep it local and lightweight; do not make the release depend on a large network install unless the user approves.

## Next Best Work for Developer-6

Recommended order:

1. Re-read this handoff, `docs/notes/README.md`, and `AGENTS.md`.
2. Run `git status --short`.
3. Do not assume the interrupted `restart-moonap-server.cmd` run is enough; rerun:

```powershell
tools\restart-moonap-server.cmd
```

4. Commit and push the Cloud SKILL-Hub repo if inspection looks right:

```powershell
cd C:\my_work\MoonBit_Competition\GitHub\MoonAP-SKILL-Hub
git status --short
git diff --stat
git add .
git commit -m "Publish generic demo utility skills"
git push
```

5. Commit the main repo generic SKILL runner work if browser smoke tests pass:

```powershell
cd C:\my_work\MoonBit_Competition\GitHub\MoonAP-MB-server2
git status --short
git add cmd\web_app\main.mbt web\app-live.js web\app-live.js.map web\app.js web\app.js.map tools\publish-demo-skills.ps1 tools\test-skill-flow.ps1 docs\notes\2026-04-19-developer-5-to-developer-6-handoff.md
git commit -m "Run generic skills from saved runtime specs"
```

6. Manually test the important browser SKILL paths:
   - `JSON Formatter Validator` installed from Cloud into Local, then run locally.
   - `CSV Summary Analyzer` installed from Cloud into Local, choose a local `.csv`, then run locally.
   - one computed form SKILL, e.g. `Celsius Fahrenheit Converter` or `Two Number Sum`, installed from Cloud into Local, then run locally.

7. If those are stable, move to release preparation:
   - README fresh-clone instructions.
   - Check `.gitignore` does not include local run artifacts.
   - Verify no large generated files are tracked.
   - Verify SKILL-Hub publish/install/reuse story is documented.

Do not manually repeat the full Personal/Cloud/Local SKILL lifecycle for all 12 prompt tasks unless the user explicitly wants a marathon. The generic SKILL runner is the abstraction; one representative for each runtime mode is the useful test:

- computed form
- text/JSON tool form
- browser-local file input
- large FASTQ special workflow

## Known Risks and How to Think About Them

### Risk: More demo prompts can become keyword soup

The project already supports 12 demos. Adding many more by simply inserting `if haystack.contains(...)` will become brittle.

Preferred direction:

- Keep adding explicit runtime profiles only for high-value demo categories.
- Move toward a structured intent/schema layer:
  - task category
  - input fields
  - output fields
  - runtime action
  - browser-local safety constraints
- Let generated MoonBit carry this via `MOONAP_RUNTIME_SPEC`.

### Risk: Browser state can make fixed bugs look unfixed

Because the page is a live single-page app, stale runtime state and cached JS can mislead testing. For user reports:

1. Ask for `Ctrl+F5`.
2. Ask them to click `Start new APP`.
3. Check `runtime_spec.tool_kind` in the latest `logs/runs/.../runtime-exec/latest-request.json`.

If that file has the wrong `tool_kind`, the bug is server/codegen/classification. If it is correct but UI is wrong, the bug is frontend state/rendering.

### Risk: Real LLM route may produce MoonBit that does not compile

The simulated route is deterministic enough for demos. Real API route still needs stronger repair loops and model-specific prompt tuning. Keep the route, but do not assume every arbitrary real LLM output is demo-ready.

### Risk: FASTQ workflows must remain browser-local

Do not regress large file handling by sending file contents to the server/LLM. The large FASTQ analyzer should read file chunks in the browser and return analysis/report artifacts.

### Risk: Path handling on Windows

Earlier developers already found path bugs around slash/backslash differences and duplicated escaping. Keep using the existing path normalization helpers and platform APIs where available. Avoid building important paths with raw string concatenation. For scripts, prefer PowerShell path cmdlets such as `Join-Path`, `Resolve-Path`, and `Split-Path`.

The SKILL roots that matter in this environment are:

- Personal: `C:\my_work\MoonBit_Competition\MoonAP-SKILL\Personal-SKILL-Set`
- Local: `C:\my_work\MoonBit_Competition\MoonAP-SKILL\Local-SKILL-Hub`
- Cloud repo: `C:\my_work\MoonBit_Competition\GitHub\MoonAP-SKILL-Hub`

### Risk: Browser permission prompts cannot be fully headless

Cloud install and browser-local file workflows involve browser file/directory permission prompts. API and filesystem scripts can verify generated SKILL packages, Cloud catalog entries, and installed folder contents, but the user may still need to manually approve browser permission dialogs.

Recommended shared test:

1. Developer runs build/restart and validates files with `tools\test-skill-flow.ps1`.
2. User opens the browser, refreshes the Cloud catalog, installs a representative SKILL, and grants the directory/file picker permission.
3. Developer validates the installed Local SKILL folder with `tools\test-skill-flow.ps1 -SkillName <name> -RequireLocalInstall -Strict`.
4. User clicks Run in the browser to confirm real UI reuse.

## Suggested Handoff Prompt for Developer-6

When starting Developer-6, tell it:

```text
You are Developer-6. Read docs/notes/2026-04-19-developer-5-to-developer-6-handoff.md, docs/notes/README.md, and AGENTS.md. Run git status --short. Do not revert Developer-5 commits. First confirm the browser demo paths for Celsius, JSON formatter, and text analyzer-after-JSON. Then continue MoonAP v0.1 release preparation.
```
