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
