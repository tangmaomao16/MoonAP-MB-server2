# Codex-threads-dev Protocol Spec

This document defines the shared interfaces between the three Codex threads.

## Roles

- developer thread
- simulated user thread
- simulated LLM thread

## Global Rules

- all three threads share one workspace
- only the developer thread edits MoonAP source code
- only the developer thread starts or stops the MoonAP server
- only the developer thread performs git actions
- simulated threads write only within their protocol directories

## Thread Toggles

The intended mode toggles are:

- `enable_simulated_user_thread`
- `enable_simulated_llm_thread`

Default values:

- simulated user thread: enabled
- simulated LLM thread: enabled

## Run-Local Layout

Each MoonAP server run should create a dedicated run directory:

- `logs/runs/<run-id>/`

The run manifest should expose these protocol roots:

- `codex_demo_root`
- `human_sim_root`
- `runtime_exec_root`
- `skill_export_root`

Bootstrap endpoint:

- `/api/codex-threads-dev/manifest`

## LLM Simulation Protocol

Request side:

- `codex-demo/inbox/*.json`
- `codex-demo/inbox/*.txt`

Response side:

- `codex-demo/outbox/*.response.txt`
- `codex-demo/outbox/*.error.txt`

State side:

- `codex-demo/state/latest-request.txt`

## Human Simulation Protocol

Action side:

- `human-sim/actions/*.json`

Feedback side:

- `human-sim/feedback/*.md`
- `human-sim/feedback/*.json`

Observation side:

- `human-sim/observations/*.json`
- `human-sim/observations/*.md`

State side:

- `human-sim/state/*.json`

Bootstrap write endpoints:

- `/api/human-sim/actions`
- `/api/human-sim/feedback`

## Runtime Execution Protocol

Reserved for wasm execution:

- `runtime-exec/input.json`
- `runtime-exec/result.json`
- `runtime-exec/stdout.txt`
- `runtime-exec/error.txt`
- `runtime-exec/preview.json`

## SKILL Export Protocol

Reserved for accepted outputs:

- `skill-export/skill-manifest.json`
- `skill-export/program/main.mbt`
- `skill-export/program/main.wasm`
- `skill-export/SKILL.md`
- `skill-export/save-decision.json`

## Minimal Action Types

The simulated user thread should begin with these action shapes:

- `submit-prompt`
- `refresh-page`
- `save-router`
- `request-save-skill`

## Minimal Feedback Types

The simulated user thread should begin with these feedback shapes:

- `accept-output`
- `reject-output`
- `semantic-feedback`

## Logging Recommendation

Every protocol write should be observable in `moonap-runtime.log` with:

- `kind`
- `label`
- `text`

That keeps the three-thread workflow debuggable.
