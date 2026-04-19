# MoonAP: MoonBit Agent Playground

MoonAP lets a user describe an APP in natural language, asks an LLM to generate a MoonBit program, compiles that program to WebAssembly, and runs the result in the user's browser. Reusable programs can be saved as MoonAP SKILLs and later run from local SKILL stores.

The v0.1 demo path is bioinformatics, but the platform is not FastQ-only:

- `large-fastq-generator`: browser-local streamed FastQ generation, including 1 GB scale files.
- `large-fastq-analyzer`: browser-local chunked FastQ analysis with read/base/report metrics.
- generic form APPs: simple prompts such as Celsius-to-Fahrenheit or two-number sum produce runtime input fields.
- SKILL reuse: generated APPs can be saved to Personal-SKILL-Set, public SKILLs can be installed from Cloud-SKILL-Hub into Local-SKILL-Hub.

Large input/output file contents stay in the browser. MoonAP sends prompts, source code, metadata, and summary metrics to the server/LLM, not the user's large local files.

## Prerequisites

- Windows 10/11.
- MoonBit toolchain with `moon` on `PATH`.
- Visual Studio Build Tools or Visual Studio C++ workload for MSVC.
- Chrome or Edge for browser features such as the File System Access API.
- Optional: real LLM API keys for NVIDIA, ZAI/GLM, Gemini, SiliconFlow, OpenRouter, or a custom OpenAI-compatible endpoint.

The current Windows development path uses MSVC. Prefer the scripts under `tools\` instead of plain `moon run` for native server work.

## Fresh Clone Start

From the repository root:

```cmd
tools\moon-msvc.cmd build cmd\web_app --target js
tools\restart-moonap-server.cmd
```

Open:

```text
http://127.0.0.1:3000/
```

The server now prefers the built JavaScript bundle at:

```text
_build/js/debug/build/cmd/web_app/web_app.js
```

If `_build` is not present, it falls back to the committed distribution bundle:

```text
web/app-live.js
```

For release builds, keep `web/app-live.js`, `web/app-live.js.map`, `web/app.js`, and `web/app.js.map` synchronized with `cmd/web_app/main.mbt`.

## Common Commands

Format MoonBit source:

```cmd
moon fmt
```

Build the browser app:

```cmd
tools\moon-msvc.cmd build cmd\web_app --target js
```

Build and restart the local server:

```cmd
tools\restart-moonap-server.cmd
```

Check whether a server is already occupying port 3000:

```powershell
Get-Process server -ErrorAction SilentlyContinue
```

Avoid `tools\start-moonap-bg.cmd` as the first choice during active development; it has previously caused confusing background-process hangs. Use `tools\restart-moonap-server.cmd` when a rebuild/restart is needed.

## LLM Configuration

Click `LLM` in the top-left page controls.

MoonAP has two tabs:

- `Real API`: default public path. Configure one or more real providers, including the `Custom provider` area for an OpenAI-compatible endpoint.
- `Simulated API`: local development/demo path for `OpenAI / GPT-5.4 simulated`. Keep this available; it is useful for competition demos and deterministic internal testing.

The router stores keys in browser localStorage on this machine. After saving, MoonAP tests enabled providers and uses only providers that pass.

## Using MoonAP

1. Configure an LLM provider or enable the Simulated API for local testing.
2. Enter a natural-language APP prompt in the message box.
3. MoonAP generates MoonBit source for `cmd/main/main.mbt`.
4. MoonAP compiles the generated program to WebAssembly.
5. The runtime card appears with task-specific browser inputs.
6. Run the APP locally in the browser.
7. If the result looks good, save it as a reusable Personal SKILL.

Smoke-test prompts:

```text
Build an app where the user enters a Celsius temperature and gets the Fahrenheit temperature.
```

```text
Build an app where the user enters two numbers and gets the sum.
```

The first should show a `Celsius temperature` field. The second should show `First number` and `Second number` fields.

## Form Runtime Contract

For ordinary form-style APPs, MoonAP now prefers a declarative runtime contract embedded in the generated MoonBit source:

```moonbit nocheck
///|
/// MOONAP_RUNTIME_SPEC_BEGIN
/// {
///   "mode": "form",
///   "title": "Convert meters to feet",
///   "action_label": "Convert length",
///   "fields": [
///     {"name":"meters","label":"Length in meters","type":"float","default":1,"step":0.01}
///   ],
///   "computed_outputs": [
///     {"name":"feet","label":"Length in feet","expression":"meters * 3.28084","decimals":4}
///   ],
///   "result_template": "Meters: {{meters}}\nFeet: {{feet}}",
///   "summary_template": "Converted {{meters}} meters to {{feet}} feet."
/// }
/// MOONAP_RUNTIME_SPEC_END
fn main {
  println("MoonAP app")
}
```

MoonAP parses this contract, renders the form, evaluates simple arithmetic `computed_outputs`, and displays the result in the runtime card. This avoids adding task-specific host code for every unit conversion or calculator-style APP. Current expressions are intentionally limited to numeric fields with `+`, `-`, `*`, `/`, and parentheses.

## SKILL Model

MoonAP uses three SKILL layers:

- `Personal-SKILL-Set`: user-saved local SKILLs created from validated generated APPs.
- `Local-SKILL-Hub`: installed public SKILLs that run locally.
- `Cloud-SKILL-Hub`: public discovery/install catalog only.

Cloud SKILLs should not run directly. Install them into Local-SKILL-Hub first, then run from the local installed copy.

Published public SKILLs should include both a folder and a same-level ZIP:

```text
bioinformatics/sequencing/large-fastq-generator/
bioinformatics/sequencing/large-fastq-generator.zip
```

## Large Files

Large-file generation and analysis happen in the browser:

- output files are chosen with the browser save picker;
- input files are selected with the browser file picker;
- file contents are streamed/chunked locally;
- the LLM receives no large file contents.

Use Chrome or Edge for the best File System Access API support.

## Troubleshooting

If the page loads but nothing happens after entering a generic prompt, open `Details` and check `LLM prompt mode`. It should show code generation such as `codegen / frontier-direct`, not `No LLM prompt captured yet`.

If the app serves HTML but `/app-live.js` is missing, run:

```cmd
tools\moon-msvc.cmd build cmd\web_app --target js
```

If port 3000 is already in use, stop the local MoonAP server or run:

```cmd
tools\stop-moonap-server.cmd
```

If a server build fails because `server.exe` or `server.lib` is locked, confirm the process is the local MoonAP server before stopping it.

If a real LLM API test fails, try the provider's official console with the same key/model, then return to MoonAP. Gemini free-tier projects may time out or rate-limit; MoonAP's router test timeout is longer, but it cannot fix provider-side limits.

## Known Tooling Notes

`moon info` and `moon test` are not currently the most reliable whole-project checks on this Windows setup. Known causes include JS externs in `cmd/web_app` under native checks and MinGW/MSVC friction in native async dependencies.

Prefer this v0.1 validation path:

```cmd
moon fmt
tools\moon-msvc.cmd build cmd\web_app --target js
node --check web\app-live.js
node --check web\app.js
tools\restart-moonap-server.cmd
```

Then test the browser at `http://127.0.0.1:3000/`.
