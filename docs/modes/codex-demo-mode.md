# Codex-demo Mode

`Codex-demo mode` is a transitional MoonAP mode for locally simulating the cloud LLM while keeping the rest of the MoonAP pipeline real.

It exists to help us quickly validate:

- prompt routing
- MoonBit code generation
- compile and repair loops
- system assessment
- wasm artifact generation

## What It Is

In this mode, MoonAP still behaves like a normal product flow from the browser's perspective, but the selected LLM provider is intercepted locally.

MoonAP writes each LLM request into a run-local request file, and a local actor writes the MoonBit response back to a paired response file.

## Important Limitation

`Codex-demo mode` is not the final development model.

In the temporary implementation we used during this session, the same Codex thread effectively played two roles:

- MoonAP developer
- simulated cloud LLM

That was useful for fast prototyping, but it is not the correct long-term structure.

The correct long-term structure is [Codex Threads Dev Mode](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/docs/modes/codex-threads-dev-mode.md), where the developer role and the LLM role are split into separate Codex threads.

## What Is Real vs Simulated

Real parts of the pipeline:

- browser UI and router configuration
- `/api/llm/proxy` flow inside MoonAP
- MoonBit artifact capture
- native compile probe
- compile repair
- system assessment
- runtime logging

Simulated part:

- cloud LLM response

## Router Settings

Use the built-in router entry:

- provider: `OpenAI`
- model: `gpt-5.4`
- base URL: `moonap://codex-demo`
- API key: `codex-demo-mode`

## Runtime Layout

Each MoonAP server start creates a fresh timestamped run directory under `logs/runs/`.

MoonAP also writes [current-run.json](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/logs/current-run.json), which points to the active run:

- `run_id`
- `root`
- `runtime_log`
- `codex_demo_root`

Inside one run directory:

- `moonap-runtime.log`
- `codex-demo/inbox/`
- `codex-demo/outbox/`
- `codex-demo/state/latest-request.txt`

## Request Contract

Each request file includes:

- `request_id`
- `provider`
- `model`
- `stage`
- `reply_path`
- `error_path`
- `raw_body`

Current `stage` values:

- `codegen`
- `repair`

## Response Contract

To fulfill a request, write the full `cmd/main/main.mbt` contents to `reply_path`.

Rules:

- source code only
- no markdown fences
- no explanations
- prefer ASCII
- avoid UTF-8 BOM

If the request fails, write the error to `error_path`.

## Current Verified Path

This mode has already been used to verify the FastQ demo path:

- browser prompt submission
- local simulated LLM response
- automatic compile repair
- real wasm artifact generation
- system assessment pass

## Position In The Roadmap

`Codex-demo mode` should now be treated as a useful lower-level building block.

It is not the final multi-role development mode. It is the LLM-simulation slice that `Codex-threads-dev mode` can reuse.
