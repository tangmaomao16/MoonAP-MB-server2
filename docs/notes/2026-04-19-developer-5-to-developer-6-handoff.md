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

Developer-5 left the worktree clean after committing the latest fix.

Most recent commits at handoff:

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

## Validation Already Run

The following passed after the latest fix:

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
3. Confirm the local server is running at `http://127.0.0.1:3000`.
4. Manually test the three most important browser paths:
   - Celsius converter.
   - JSON formatter.
   - Text analyzer immediately after JSON formatter.
5. If stable, move to release preparation:
   - README fresh-clone instructions.
   - Check `.gitignore` does not include local run artifacts.
   - Verify no large generated files are tracked.
   - Verify SKILL-Hub publish/install/reuse story still works.
6. Only then consider broadening demo prompt coverage.

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

## Suggested Handoff Prompt for Developer-6

When starting Developer-6, tell it:

```text
You are Developer-6. Read docs/notes/2026-04-19-developer-5-to-developer-6-handoff.md, docs/notes/README.md, and AGENTS.md. Run git status --short. Do not revert Developer-5 commits. First confirm the browser demo paths for Celsius, JSON formatter, and text analyzer-after-JSON. Then continue MoonAP v0.1 release preparation.
```

