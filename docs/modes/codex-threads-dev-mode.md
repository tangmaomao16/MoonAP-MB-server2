# Codex-threads-dev Mode

`Codex-threads-dev mode` is the proposed full MoonAP development mode for multi-role local simulation.

It is different from `Codex-demo mode`.

## Relationship To Codex-demo Mode

- `Codex-demo mode`
  Simulates only the cloud LLM interface.

- `Codex-threads-dev mode`
  Simulates the broader MoonAP product environment using separate Codex threads for different roles.

So `Codex-demo mode` should be treated as one reusable component inside `Codex-threads-dev mode`, not as the same thing.

## Core Idea

MoonAP is not just a code generator. It is a multi-stage product loop:

1. user enters natural language
2. MoonAP gets MoonBit code from an LLM
3. MoonAP compiles MoonBit to WebAssembly
4. MoonAP runs the WebAssembly program
5. user sees the result
6. user can choose to save the result as a SKILL

`Codex-threads-dev mode` is meant to accelerate development of that whole loop.

## Threads

### Thread 1: MoonAP Developer

Always enabled.

Role:

- owns MoonAP source code
- starts and stops MoonAP server
- maintains logs, protocols, and runtime orchestration
- inspects outputs and fixes system issues

This thread is the only thread that should:

- modify MoonAP source code
- start or stop the background server
- perform git actions

### Thread 2: Simulated Human User

Configurable.

Role:

- acts like the browser user
- submits prompts
- checks visible results
- provides semantic feedback
- decides whether to save as a SKILL

### Thread 3: Simulated Cloud LLM

Configurable.

Role:

- acts like the remote model endpoint
- reads request payloads
- returns MoonBit code or repair responses

## Thread Toggles

The developer thread should always exist.

The configurable toggles should be:

- `enable_simulated_user_thread`
- `enable_simulated_llm_thread`

Default:

- `enable_simulated_user_thread = true`
- `enable_simulated_llm_thread = true`

That means the default development shape is a three-thread setup.

## Why The Toggles Matter

These toggles let MoonAP evolve through realistic stages instead of jumping directly from prototype to production.

### Stage A: Fully Simulated Development

- developer thread: on
- simulated user thread: on
- simulated LLM thread: on

Use this when the full flow is still under construction.

### Stage B: Real User, Simulated LLM

- developer thread: on
- simulated user thread: off
- simulated LLM thread: on

Use this when a real human can operate the browser, but the cloud LLM is still being simulated locally.

### Stage C: Near-Product Validation

- developer thread: on
- simulated user thread: off
- simulated LLM thread: off

Use this when a real human uses the browser and a real cloud LLM is available.

This is close to the intended finished product shape.

## Why This Is Better Than Ad Hoc Role-Playing

Without a formal mode, one Codex thread can end up temporarily impersonating multiple roles.

That is useful for emergency prototyping, but it causes conceptual drift:

- developer logic
- user behavior
- model behavior

become mixed together.

`Codex-threads-dev mode` fixes that by making role separation part of the system design.

## Recommended Protocol Layers

### 1. LLM Simulation Protocol

This is already available and should be reused:

- `logs/runs/<run-id>/codex-demo/inbox/`
- `logs/runs/<run-id>/codex-demo/outbox/`
- `logs/runs/<run-id>/codex-demo/state/`

This becomes the protocol surface for the simulated LLM thread.

### 2. Human Simulation Protocol

This should be added next:

- `logs/runs/<run-id>/human-sim/actions/`
- `logs/runs/<run-id>/human-sim/observations/`
- `logs/runs/<run-id>/human-sim/feedback/`
- `logs/runs/<run-id>/human-sim/state/`

This becomes the protocol surface for the simulated user thread.

Current bootstrap endpoint:

- `/api/human-sim/actions`
- `/api/human-sim/feedback`

### 3. Runtime Execution Protocol

MoonAP still needs a stable protocol for wasm execution and result reporting.

Recommended run-local directory:

- `logs/runs/<run-id>/runtime-exec/`

Suggested artifacts:

- `input.json`
- `result.json`
- `stdout.txt`
- `error.txt`
- `preview.json`

### 4. SKILL Packaging Protocol

Once the result is accepted, MoonAP should package the program into a reusable SKILL.

Recommended run-local directory:

- `logs/runs/<run-id>/skill-export/`

Suggested artifacts:

- `skill-manifest.json`
- `program/main.mbt`
- `program/main.wasm`
- `SKILL.md`
- `save-decision.json`

## Recommended Stage Model

`Codex-threads-dev mode` should log a consistent state machine for each run:

1. `user-intent-captured`
2. `llm-codegen-running`
3. `llm-codegen-succeeded`
4. `compile-running`
5. `compile-failed`
6. `compile-repair-running`
7. `compile-succeeded`
8. `quality-check-running`
9. `quality-failed`
10. `quality-repair-running`
11. `runtime-running`
12. `runtime-succeeded`
13. `user-review-running`
14. `user-repair-running`
15. `skill-save-pending`
16. `skill-saved`

## Repair Classes

MoonAP should distinguish at least four repair loops:

- `compile-repair`
- `quality-repair`
- `runtime-repair`
- `user-repair`

These loops should stay separate because they consume different kinds of feedback.

## Recommended Ownership Rules

To reduce conflicts in one shared workspace:

### Thread 1 writes

- MoonAP source code
- orchestration and runtime files
- compile and runtime logs
- packaged SKILL outputs

### Thread 2 writes

- `human-sim/actions/`
- `human-sim/feedback/`
- user review artifacts

### Thread 3 writes

- `codex-demo/outbox/`

## Immediate Next Step

The next implementation step for `Codex-threads-dev mode` should be:

- add the `human-sim/` protocol

That is the cleanest next milestone because:

- the LLM side already has a working bridge
- the developer role already exists naturally
- the missing structured role is the simulated user

Once `human-sim/` exists, MoonAP can move much faster toward:

- wasm execution
- result delivery
- SKILL saving

## Current Bootstrap Surface

The developer thread can expose a run-local manifest through:

- `/api/codex-threads-dev/manifest`

That manifest should tell the other threads where the active run-local protocol directories are located.
