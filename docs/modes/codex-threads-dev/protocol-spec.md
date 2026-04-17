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

- `llm_sim_root`
- `human_sim_root`
- `runtime_exec_root`
- `skill_export_root`

Bootstrap endpoint:

- `/api/codex-threads-dev/manifest`
- `/api/codex-threads-dev/coordination`

## LLM Simulation Protocol

Request side:

- `llm-sim/inbox/*.json`
- `llm-sim/inbox/*.txt`

Response side:

- `llm-sim/outbox/*.response.txt`
- `llm-sim/outbox/*.error.txt`

State side:

- `llm-sim/state/latest-request.txt`
- `llm-sim/state/latest-response-status.json`

Bootstrap read endpoints:

- `/api/llm-sim/latest-request`
- `/api/llm-sim/latest-response`

Developer-side processing endpoint:

- `/api/llm-sim/process-latest-response`

Current endpoint-behavior rule:

- the simulated LLM thread should behave like a remote model endpoint, not like a MoonAP developer
- request `messages` are the source of truth for codegen and repair behavior
- if the request contains conversation history, the simulated LLM thread should continue that history rather than inventing a separate repair strategy
- the simulated LLM thread must not replace request handling with keyword-triggered canned templates

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

Bootstrap read endpoints:

- `/api/human-sim/latest-action`
- `/api/human-sim/latest-feedback`
- `/api/human-sim/latest-intent`

Intent status write endpoint:

- `/api/human-sim/intent-status`

Current normalized state files:

- `human-sim/state/latest-action.json`
- `human-sim/state/latest-feedback.md`
- `human-sim/state/latest-intent.json`
- `human-sim/state/latest-intent-status.json`

## Runtime Execution Protocol

Current compile-bridge outputs:

- `runtime-exec/latest-raw-response.txt`
- `runtime-exec/latest-source.mbt`
- `runtime-exec/latest-compile-report.json`
- `runtime-exec/latest-request.json`
- `runtime-exec/latest-result.json`
- `runtime-exec/requests/<request-id>/raw-response.txt`
- `runtime-exec/requests/<request-id>/main.mbt`
- `runtime-exec/requests/<request-id>/compile-report.json`
- `runtime-exec/requests/<request-id>/runtime-request.json`
- `runtime-exec/requests/<request-id>/result.json`
- `runtime-exec/requests/<request-id>/stdout.txt`
- `runtime-exec/requests/<request-id>/error.txt`
- `runtime-exec/requests/<request-id>/preview.json`

Reserved next step for wasm execution:

- `runtime-exec/input.json`
- `runtime-exec/result.json`
- `runtime-exec/stdout.txt`
- `runtime-exec/error.txt`
- `runtime-exec/preview.json`

Runtime endpoints:

- `/api/runtime-exec/latest-request`
- `/api/runtime-exec/latest-result`
- `/api/task/execute`

## SKILL Export Protocol

Reserved for accepted outputs:

- `skill-export/skill-manifest.json`
- `skill-export/program/main.mbt`
- `skill-export/program/main.wasm`
- `skill-export/SKILL.md`
- `skill-export/save-decision.json`

Current explicit save-decision endpoints:

- `/api/skill-export/save-decision`

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

## Coordination View

To reduce manual orchestration, MoonAP now exposes:

- `/api/codex-threads-dev/coordination`

It returns:

- whether the developer thread currently needs to act
- whether the simulated LLM thread currently needs to reply
- whether the simulated user thread currently needs to submit runtime feedback or a save decision
- a `wake_order` array showing which thread should be nudged first
- short one-shot prompts that can be pasted into the target thread

The `simulated_llm.prompt` text should nudge one bounded endpoint-style turn:

- read the latest request once
- if the request is new, answer it through `reply_path`
- do not rewrite MoonAP policy in the chat reply

## Current Automated Bridge

The current lowest-friction three-thread flow is:

1. simulated user thread writes `submit-prompt` through `/api/human-sim/actions`
2. developer thread calls `/api/human-sim/dispatch-latest-intent`
3. simulated LLM thread reads `/api/llm-sim/latest-request` or `llm-sim/state/latest-request.txt`
4. simulated LLM thread writes `reply_path`
5. developer thread calls `/api/llm-sim/process-latest-response`
6. MoonAP writes compile artifacts into `runtime-exec/` and human-readable observations into `human-sim/observations/`
7. if compile succeeds, MoonAP writes `runtime-exec/latest-request.json`
8. browser or simulated user thread reports runtime results through `/api/task/execute`
9. only after the user accepts the result should save intent be recorded through `/api/skill-export/save-decision`
