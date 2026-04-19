# Developer-3 to Developer-4 Handoff

Date: 2026-04-19

This note is for the next main MoonAP development session, `Developer-4`.

Developer-3's context is getting large. If this session becomes slow, Developer-4 should use this file as the first operational handoff, then read the deeper linked notes only as needed.

## Repository

Main repo:

```text
C:\my_work\MoonBit_Competition\GitHub\MoonAP-MB-server2
```

Official public SKILL Hub repo:

```text
C:\my_work\MoonBit_Competition\GitHub\MoonAP-SKILL-Hub
https://github.com/tangmaomao16/MoonAP-SKILL-Hub
```

Personal SKILL root used by the user:

```text
C:\my_work\MoonBit_Competition\MoonAP-SKILL\Personal-SKILL-Set
```

Known generated result root:

```text
C:\my_work\MoonBit_Competition\MoonAP-generated-result-files
```

## Required Reading Order

Read these first:

1. `docs/notes/2026-04-19-developer-3-to-developer-4-handoff.md`
2. `docs/notes/2026-04-19-developer-3-flow-recap-and-large-fastq-analyzer-plan.md`
3. `docs/notes/2026-04-19-developer-3-large-file-runtime-handoff.md`
4. `docs/notes/2026-04-18-developer-2-skill-hub-zip-handoff.md`
5. `docs/notes/2026-04-18-developer-2-path-normalization-handoff.md`

## Current Product State

MoonAP is a browser-local MoonBit APP/SKILL platform:

- user enters natural language;
- LLM or Simulated LLM generates MoonBit code;
- MoonAP compiles MoonBit to WebAssembly;
- browser-local runtime runs the APP;
- user can save the APP as a Personal SKILL;
- public SKILLs can be installed from Cloud-SKILL-Hub into Local-SKILL-Hub;
- Local and Personal SKILLs are the places where reusable SKILLs actually run.

The three-layer SKILL architecture remains:

- `Personal-SKILL-Set`: user-saved local reusable SKILLs.
- `Local-SKILL-Hub`: installed public SKILLs, runnable locally.
- `Cloud-SKILL-Hub`: discovery and install only, not directly runnable.

Cloud SKILLs must remain install-only. Do not show runtime parameter forms for Cloud entries before installation.

## Confirmed User-Validated Flow

The `large-fastq-generator` flow is validated end-to-end from the user's browser:

- Simulated GPT-5.4 generated a large FastQ generator.
- MoonAP compiled it.
- Browser-local large-file generation wrote a 1GB-scale FastQ file with progress.
- User confirmed this output:

```text
C:\my_work\MoonBit_Competition\MoonAP-generated-result-files\fastq\moonap-output-1G-2.fastq
```

- User saved it as a Personal SKILL:

```text
C:\my_work\MoonBit_Competition\MoonAP-SKILL\Personal-SKILL-Set\large-fastq-generator
```

- Zip export exists and the SKILL was published to Cloud-SKILL-Hub.
- User installed it from Cloud into Local-SKILL-Hub.
- User confirmed the installed Local SKILL can be reused.

This is the current best proof that the MoonAP full workflow works.

## Recent Developer-3 Work

The newest work is `large-fastq-analyzer` and platform-level report delivery.

Changed files currently include:

- `cmd/web_app/main.mbt`
- `cmd/server/main.mbt`
- `docs/notes/README.md`
- `docs/notes/2026-04-19-developer-3-flow-recap-and-large-fastq-analyzer-plan.md`
- this handoff file

### Server Changes

In `cmd/server/main.mbt`, Developer-3 added:

- task kind `large-fastq-analysis`;
- runtime mode `file`;
- result mode `report`;
- FastQ-aware runtime spec with:

```json
{
  "domain_profile": "fastq",
  "io_contract": {
    "host_capability": "chunked-local-analysis",
    "input_mode": "streaming-text",
    "output_mode": "report",
    "carry_strategy": "fastq-record-boundary"
  }
}
```

- user-facing fields:

```text
max_preview_reads
validate_fastq_structure
count_bases
```

The boolean fields were changed to `type: "bool"` so the UI can render checkboxes instead of raw `true` / `false` text inputs.

### Web App Changes

In `cmd/web_app/main.mbt`, Developer-3 added:

- runtime profile `large-fastq-analysis`;
- browser-local chunked FastQ parsing;
- progress card updates during large-file analysis;
- `Choose input FastQ file` selector in the runtime-ready card;
- checkbox rendering for bool runtime fields;
- Personal/Local SKILL dialog input-file selection for `large-fastq-analysis`;
- Personal/Local SKILL execution path for `large-fastq-analysis`;
- platform-level report delivery for `result_mode: "report"`:

```text
Open report
Save report
Download raw JSON
```

The report viewer is browser-local. It builds an HTML report from the structured runtime result payload.

## Large FastQ Analyzer Test Prompt

Use Simulated GPT-5.4 first.

Recommended prompt:

```text
Generate a large FastQ analyzer APP for MoonAP using the large-file analysis runtime profile.

It should analyze browser-local FastQ files up to 1GB using chunked local file reading instead of loading the whole file into memory.

The runtime UI should use FastQ analysis parameters, not generic text search parameters:
- max preview reads
- validate FastQ structure
- count bases

The analyzer should report:
- file name
- file size
- chunk count
- total lines
- estimated read count
- total bases
- A/C/G/T/N/other base counts
- min read length
- max read length
- average read length
- malformed record count
- a small preview of reads

Keep file contents in the browser. Do not send file contents to the LLM.
Return only the MoonBit source code for cmd/main/main.mbt.
```

Expected browser flow after compile:

1. Runtime card should say `Runtime profile Large FastQ analysis`.
2. The card should show `Choose input FastQ file`.
3. Select a `.fastq`, `.fq`, or `.txt` FastQ file.
4. The selected file label should update immediately.
5. `Validate FastQ structure` and `Count A/C/G/T/N bases` should be checkboxes.
6. Click `Run FastQ analysis`.
7. Progress card should appear while the browser reads the file.
8. After completion, user should see:

```text
Run FastQ analysis again
Save APP into SKILL
Download wasm
Download source
Open report
Save report
Download raw JSON
```

Expected report behavior:

- `Open report` opens an HTML report in a new tab.
- `Save report` saves a local `.html` report.
- `Download raw JSON` is for developer/debug use.

## Important UX Decisions

Do not make users rely on `Download raw JSON` as the normal report path.

For report-mode tasks:

- browser should show a readable report path first;
- raw JSON can remain available for debugging;
- plain text download with visible `\n` escapes is not acceptable for the normal user path.

For large files:

- input/output file contents stay in browser;
- LLM receives metadata and code only;
- no hardcoded OS output paths;
- use browser File System Access API where possible;
- show progress during long operations.

## Validation Already Run

Recent commands that passed:

```text
moon fmt
tools\moon-msvc.cmd build cmd\web_app --target js
```

Server health check recently returned:

```json
{
  "ok": true,
  "name": "MoonAP",
  "server": "MoonBit-first minimal server",
  "moonbit_owned": true,
  "version": "0.1.0"
}
```

Earlier in the same implementation track, this also passed after stopping a locked server process:

```text
tools\moon-msvc.cmd build cmd\server --release
tools\restart-moonap-server.cmd
```

## Known Environment Issues

Avoid using:

```text
tools\start-moonap-bg.cmd
```

It has repeatedly caused hangs in this thread.

Prefer:

```text
tools\restart-moonap-server.cmd
```

Known server build lock issue:

- debug server build may fail because `_build\native\debug\build\cmd\server\server.lib` is locked;
- release build may fail if `_build\native\release\build\cmd\server\server.exe` is currently running;
- use `Get-Process server` to find the process;
- stop only the MoonAP server process when necessary;
- then rebuild and restart.

`moon info` and `moon test` are not always clean in this repo:

- `moon info` may fail because native backend sees JS externs in `cmd/web_app`;
- `moon test` can fail on Windows MinGW/MSVC dependency friction from `moonbitlang/async`.

Use `moon fmt` and targeted builds as the reliable validation path unless the user specifically asks for deeper test work.

## Current Risks / Items Developer-4 Should Check

1. Browser-test `Open report` and `Save report` after a new `large-fastq-analyzer` run.
2. Confirm `Download raw JSON` is clearly secondary and not confusing for the user.
3. Confirm report HTML displays real line breaks and preview reads correctly.
4. Confirm Personal SKILL save after analyzer run captures the right `task_kind` and `runtime_spec`.
5. Confirm saved `large-fastq-analyzer` Personal SKILL can be rerun from SKILL page.
6. Publish `large-fastq-analyzer` to Cloud-SKILL-Hub only after Personal SKILL reuse is validated.
7. Test Cloud -> Local install and Local reuse for analyzer.

## Suggested Next Work

Recommended immediate path:

1. Ask the user to refresh MoonAP with `Ctrl+F5`.
2. Have the user run `large-fastq-analyzer` again on the 64MB FastQ test file.
3. Verify `Open report`.
4. Verify `Save report`.
5. Save APP as SKILL named:

```text
large-fastq-analyzer
```

6. Verify it appears in Personal-SKILL-Set.
7. Reuse it from SKILL page.
8. If good, prepare instructions for MoonAP-SKILL-Hub maintainer:

```text
Please publish the Personal SKILL folder:
C:\my_work\MoonBit_Competition\MoonAP-SKILL\Personal-SKILL-Set\large-fastq-analyzer

Use the public SKILL Hub layout:
bioinformatics/sequencing/large-fastq-analyzer/
bioinformatics/sequencing/large-fastq-analyzer.zip

Add/update index.json so Cloud-SKILL-Hub can discover and install it.
Cloud entry should be install-only. Runtime should occur only after install into Local-SKILL-Hub.
```

## Coding Notes

Use `apply_patch` for manual edits.

Do not revert user changes.

When changing paths, prefer the existing cross-platform path handling and the MoonBit path library already introduced earlier:

```text
illusory0x0/path
```

Do not add fastq-only hacks where a platform-level runtime/report mechanism is appropriate.

Do not make Cloud SKILL directly runnable.

Keep Simulated GPT-5.4 as a selectable route because the user may need it for live competition demos.

