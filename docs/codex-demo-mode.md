# Codex-demo Mode

`Codex-demo mode` lets MoonAP run the normal MoonBit artifact pipeline without calling a real cloud LLM.

The browser still talks to the MoonAP server through the normal router UI. The difference is that the selected provider is intercepted locally, the request is written to a run-specific inbox file, and Codex can answer by writing MoonBit source back to the paired outbox file.

## What Is Real vs Simulated

Real parts of the pipeline:

- browser UI and router configuration
- `/api/llm/proxy` request flow inside MoonAP
- MoonBit artifact capture
- native compile probe
- compile-repair loop
- system assessment / benchmark assessment
- runtime logging

Simulated part:

- the cloud LLM response

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

- `moonap-runtime.log`: append-only runtime log for that server session
- `codex-demo/inbox/`: pending Codex-demo requests
- `codex-demo/outbox/`: response and error files
- `codex-demo/state/latest-request.txt`: pointer to the newest request file

## Request File Format

Each request file contains:

- `request_id`
- `provider`
- `model`
- `stage`
- `reply_path`
- `error_path`
- `raw_body`

`stage` is currently one of:

- `codegen`
- `repair`

Future system-assessment-driven repairs can reuse the same bridge.

## Response Contract

To fulfill a Codex-demo request, write the full `cmd/main/main.mbt` contents to the request's `reply_path`.

Rules:

- write source code only
- do not write markdown fences
- do not write explanations
- prefer ASCII output
- avoid UTF-8 BOM

If the request cannot be fulfilled, write an error message to `error_path`.

## Current Automatic Loops

MoonAP now supports two automatic feedback loops:

1. compile repair
   Triggered when native MoonBit compilation fails.

2. quality repair
   Triggered when compilation succeeds but system assessment fails.

The quality-repair branch reuses the current router provider and feeds machine-detected task feedback back into the repair prompt.

## Demo Flow

1. Start MoonAP server in background.
2. Open `http://127.0.0.1:3000`.
3. Select `OpenAI / gpt-5.4`.
4. Enter a prompt such as `Generate a FastQ file generator`.
5. MoonAP writes a request into the active run's `codex-demo/inbox/`.
6. Codex writes MoonBit source to the matching `reply_path`.
7. MoonAP continues through compile, repair, assessment, and wasm generation.

## Verified Result

This mode has been verified for the FastQ demo path:

- natural-language request from browser
- Codex-demo code generation
- automatic compile repair
- native wasm artifact generation
- system assessment pass for the FastQ task
