# MoonAP Flow Recap and Large FastQ Analyzer Plan

Date: 2026-04-19

This note records the current MoonAP end-to-end state after the `large-fastq-generator` flow was tested successfully, and prepares the next implementation track: `large-fastq-analyzer`.

## Executive Summary

The MoonAP core product loop has now been validated with a real large-file SKILL sample:

```text
Natural-language prompt
-> LLM-generated MoonBit source
-> MoonBit compile to WebAssembly
-> browser-local runtime execution
-> large-file streamed output
-> Save APP as SKILL
-> publish folder + zip to Cloud-SKILL-Hub
-> install Cloud SKILL into Local-SKILL-Hub
-> reuse installed Local SKILL
-> browser-local streamed output again
```

The concrete validated sample is:

- `large-fastq-generator`
- generated and reused through MoonAP
- saved as Personal SKILL
- published to Cloud-SKILL-Hub
- installed into Local-SKILL-Hub
- reused from Local-SKILL-Hub
- generated a 1GB-level FastQ output file in the browser with progress feedback

Latest user-confirmed generated file:

```text
C:\my_work\MoonBit_Competition\MoonAP-generated-result-files\fastq\moonap-output-1G-2.fastq
```

## Current User-Facing Workflow

### 1. Create an app from natural language

The user enters a task prompt in MoonAP, for example a request for a browser-local large FastQ generator.

MoonAP then:

- calls the configured LLM route, usually Simulated GPT-5.4 during demos;
- captures generated MoonBit source;
- compiles it to WebAssembly;
- prepares a runtime request.

### 2. Run the generated app

For `large-file-generation`, MoonAP shows a browser-local runtime UI with FastQ-oriented fields:

- output FastQ file name
- target size in MB
- read length
- read header prefix
- random seed
- N base rate
- quality character

The user chooses an output file/location before running. MoonAP uses the browser File System Access API, so it stores a browser `FileSystemFileHandle`, not a Windows/macOS/Linux path string.

During execution, MoonAP shows a foreground progress card with:

- writing/reading status;
- percent complete;
- processed bytes versus target bytes;
- chunk count;
- record/line count;
- reminder that file contents stay in the browser.

### 3. Save APP as SKILL

After a successful runtime result, the user can save the app as a Personal SKILL.

MoonAP saves:

```text
Personal-SKILL-Set/
  <skill-name>/
    SKILL.md
    program/main.wasm
    program/main.mbt
  <skill-name>.zip
```

The zip is intentionally same-level with the folder. This is also the required Cloud-SKILL-Hub publishing shape.

### 4. Publish to Cloud-SKILL-Hub

The Cloud-SKILL-Hub maintainer should publish both:

- the SKILL folder;
- the same-level same-name zip.

The official catalog `index.json` must include a catalog entry with:

- `folder_path`
- `zip_path`
- `task_kind`
- optionally `runtime_spec`

The Cloud-SKILL-Hub is for discovery and install only.

### 5. Install and reuse

The user opens MoonAP's SKILL panel:

```text
Cloud-SKILL-Hub
-> select a public SKILL
-> install to Local-SKILL-Hub
-> select the installed Local SKILL
-> configure parameters
-> run locally in the browser
```

Important product rule:

- Cloud SKILLs should not show the runtime parameter form.
- Cloud SKILLs should only show install information and an install action.
- Local SKILLs and Personal SKILLs show runtime parameters and can run.

This rule was corrected after the user noticed that Cloud `large-fastq-generator` was showing the runtime form too early.

## Current Architecture

### SKILL layers

MoonAP has three SKILL layers:

```text
Personal-SKILL-Set
User-created reusable SKILLs saved from MoonAP runtime results.

Local-SKILL-Hub
Installed public SKILLs. This is where public SKILLs actually run.

Cloud-SKILL-Hub
Official public catalog. This is only for discovery and installation.
```

### Public SKILL package shape

Cloud-published SKILLs should use:

```text
domain/subdomain/skill-name/
domain/subdomain/skill-name.zip
```

Example:

```text
bioinformatics/sequencing/large-fastq-generator/
bioinformatics/sequencing/large-fastq-generator.zip
```

The zip may include a root folder:

```text
large-fastq-generator/
  SKILL.md
  program/main.wasm
  program/main.mbt
```

MoonAP's Cloud installer strips the root folder when appropriate during installation.

### Path handling policy

MoonBit/server/shared path normalization uses `illusory0x0/path`.

Browser-side behavior is intentionally different:

- actual user-selected files are browser handles, not OS path strings;
- ZIP/SKILL entries use MoonAP virtual paths with `/`;
- suggested output filenames are sanitized by a centralized browser filename helper.

Do not hardcode Windows path semantics into browser runtime logic.

## Large-File Runtime Status

### `large-file-generation`

Status: validated with `large-fastq-generator`.

Current behavior:

- browser-local streamed output;
- no full-file buffering;
- no file contents sent to LLM;
- save picker before running;
- progress card during execution;
- Personal SKILL reuse works;
- Cloud -> Local install and Local reuse works.

### `large-file-analysis`

Status: scaffold exists, but FastQ-specific analyzer is not complete.

Current generic analysis behavior:

- browser-local chunked file reading;
- line-boundary carry strategy;
- search text and preview line fields;
- generic report output.

This is not enough for `large-fastq-analyzer`. The next track should make the analyzer FastQ-aware while preserving the platform-level large-file analysis contract.

## Next Target: `large-fastq-analyzer`

### Goal

Implement and validate a new SKILL:

```text
large-fastq-analyzer
```

It should analyze 1GB-level FastQ files in the browser using chunked local reading without sending file contents to the LLM or buffering the full file.

### User-facing behavior

The user should be able to:

1. open MoonAP;
2. enter a prompt asking for a large FastQ analyzer;
3. let MoonAP generate and compile MoonBit code;
4. see a FastQ analysis-oriented runtime UI;
5. choose a local `.fastq` or `.fq` file;
6. run browser-local chunked analysis;
7. watch progress in the foreground progress card;
8. receive a summary report;
9. save the app as a Personal SKILL;
10. publish folder + zip to Cloud-SKILL-Hub;
11. install it into Local-SKILL-Hub;
12. reuse it from Local-SKILL-Hub.

### Suggested runtime fields

The analyzer UI should not use only generic `search_text` and `preview_lines`.

Suggested fields:

- `max_preview_reads`
- `count_bases`
- `count_n_bases`
- `validate_fastq_structure`
- `quality_char_min`
- `quality_char_max`
- `report_top_k_read_lengths`

For a first minimum viable version, use:

- `max_preview_reads`
- `validate_fastq_structure`
- `count_bases`

### Suggested report metrics

Minimum viable report:

- file name
- file size bytes
- chunk count
- total lines
- estimated read count
- total bases
- A count
- C count
- G count
- T count
- N count
- other base count
- min read length
- max read length
- average read length
- malformed record count
- preview reads

Optional later metrics:

- quality character min/max;
- per-read quality length mismatch count;
- GC rate;
- N rate;
- first malformed record index.

### Implementation plan

#### Phase 1: Runtime spec and classification

Update the runtime profile and server runtime spec so FastQ analyzer prompts resolve to a FastQ-aware large-file analysis profile.

Recommended task kind strategy:

- add or use `large-fastq-analysis` if a distinct task kind is useful;
- otherwise keep `large-file-analysis` but add a `domain_profile: "fastq"` field in runtime spec.

The user-facing name should be:

```text
large-fastq-analyzer
```

Prefer a distinct task kind if it simplifies UI and SKILL reuse:

```text
large-fastq-analysis
```

But keep the `io_contract.host_capability` as:

```text
chunked-local-analysis
```

#### Phase 2: Browser executor

Extend the browser large-file analysis executor so that when runtime spec indicates FastQ analysis, it parses records in groups of four lines:

```text
@header
sequence
+
quality
```

Important constraints:

- handle chunk boundaries correctly;
- keep a carry buffer for partial lines;
- never store all reads;
- update progress after each chunk;
- keep only small preview data;
- keep counters in memory.

#### Phase 3: SKILL reuse wiring

Personal/Local SKILL reuse should support the analyzer's task kind or domain profile.

The dialog should:

- show input-file selection before `Run`;
- show analyzer parameters;
- not show output save location unless a downloadable report is added;
- run only after a local file is selected.

#### Phase 4: Save and publish

After browser testing succeeds:

- save APP as Personal SKILL;
- verify `SKILL.md`;
- verify zip;
- publish folder + zip to `MoonAP-SKILL-Hub`;
- add catalog entry;
- test Cloud -> Local install;
- test Local reuse on the 1GB FastQ file.

## Recommended Browser Test Prompt

Use Simulated GPT-5.4 first.

Suggested prompt:

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

## Developer Notes Before Coding

Before implementing, inspect:

- `cmd/web_app/main.mbt`
- `cmd/server/main.mbt`

Important existing areas:

- browser runtime profile registry;
- `runLargeFileAnalysisPayload`;
- `browser_run_fastq_counter`;
- `execute_dialog_skill`;
- Cloud/Local/Personal SKILL dialog behavior;
- server `runtime_task_kind_from_context`;
- server `runtime_spec_json_for_task_kind`.

Do not regress the validated `large-fastq-generator` flow.

Do not make Cloud SKILLs directly runnable. Cloud remains install-only.

Do not hardcode OS file paths for input or output. Use browser file handles and virtual SKILL paths.

## Implementation Update

Developer-3 started implementing the `large-fastq-analyzer` platform path on 2026-04-19.

Implemented in `cmd/server/main.mbt`:

- added task kind classification for `large-fastq-analysis`;
- added runtime mode `file` and result mode `report`;
- added a FastQ-aware runtime spec with `domain_profile: "fastq"`;
- added browser-local chunked analysis contract metadata.

Implemented in `cmd/web_app/main.mbt`:

- added the `large-fastq-analysis` runtime profile;
- added a browser-local chunked FastQ parser for direct runtime execution;
- changed the FastQ analyzer runtime UI from raw `true`/`false` text fields to checkbox controls;
- added field help text for preview count, structure validation, and base counting;
- added an explicit `Choose input FastQ file` selector to the runtime-ready card;
- added platform-level report delivery buttons for report-mode runtime results: `Open report`, `Save report`, and `Download raw JSON`;
- added a browser-local HTML report renderer for FastQ analysis metrics and preview reads;
- added Personal/Local SKILL dialog input file selection before `Run`;
- added Personal/Local SKILL reuse execution for `large-fastq-analysis`;
- added foreground progress updates while the browser reads a large FastQ file;
- added result JSON with read count, base count, A/C/G/T/N/other metrics, read-length stats, malformed-record count, and preview reads;
- added export descriptions for `large-fastq-analysis`.

Validation run:

- `moon fmt` passed.
- `tools\moon-msvc.cmd build cmd\web_app --target js` passed.
- `tools\moon-msvc.cmd build cmd\server --release` passed after stopping the previously running locked `server.exe`.
- `tools\restart-moonap-server.cmd` completed.
- `http://127.0.0.1:3000/api/health` returned `ok: true`.

Known caveats:

- The debug server build can fail with a locked `server.lib` while a server process is running.
- The direct browser test for `large-fastq-analyzer` still needs user validation through MoonAP UI.
- After validation, save the generated APP as `large-fastq-analyzer`, verify the Personal SKILL, then publish folder + same-level zip to the Cloud SKILL Hub.
