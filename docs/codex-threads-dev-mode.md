# Codex-threads-dev Mode

`Codex-threads-dev mode` is a proposed MoonAP development mode for fast end-to-end product iteration using multiple coordinated Codex threads inside one shared workspace.

The purpose is not just to demo one request. The purpose is to systematize a software-development workflow where different roles in the MoonAP product loop are simulated in parallel:

- MoonAP developer
- human user
- cloud LLM

Over time, this mode should help MoonAP reach the full intended flow:

1. user enters natural language
2. MoonAP gets MoonBit code from the cloud LLM
3. MoonAP compiles MoonBit to WebAssembly
4. MoonAP runs the WebAssembly program
5. user gets the result
6. user can choose to save the MoonBit source and WebAssembly artifact as a SKILL

## Why A Dedicated Mode Is Worth It

The current `Codex-demo mode` already proved one important point:

- a local bridge can replace the real cloud LLM while preserving the real MoonAP compile and assessment pipeline

But `Codex-demo mode` is still only one slice of the full product process.

`Codex-threads-dev mode` would generalize that idea into a structured development environment where multiple product roles are simulated in parallel with stable interfaces.

This matters because MoonAP is not a simple one-shot generator. It is a multi-stage system:

- interaction
- planning
- code generation
- compile feedback
- semantic feedback
- runtime execution
- result delivery
- SKILL packaging

That kind of system benefits from role separation.

## Proposed Threads

### Thread 1: Developer Thread

Role:

- software engineer for MoonAP
- owns source-code changes
- starts and stops MoonAP server
- defines and maintains shared simulation protocols
- inspects logs and artifacts after each run

Responsibilities:

- code changes in `cmd/server`, `cmd/web_app`, `tools`, and shared runtime logic
- run lifecycle management
- log retention and run directories
- orchestration of the development workflow

Only this thread should:

- modify MoonAP source code
- start or stop the background server
- perform git actions

### Thread 2: Human User Thread

Role:

- simulated human user
- represents the browser-side operator of MoonAP

Responsibilities:

- choose providers / modes
- submit prompts
- inspect visible outputs
- provide semantic feedback
- decide whether to save output as a SKILL

This thread should simulate what a real user can do, not what a repo maintainer can do.

### Thread 3: Cloud LLM Thread

Role:

- simulated remote GPT-5.4 model

Responsibilities:

- read LLM request payloads
- return MoonBit code
- return repair responses
- later, return user-feedback-guided revisions

This thread should behave like a model endpoint, not like a developer editing the codebase directly.

## Core Design Principle

The threads should coordinate through explicit local protocols, not through informal conversation alone.

That means each role should have:

- a stable input surface
- a stable output surface
- a limited write scope

This is the key to making the mode repeatable.

## Proposed Protocol Layers

### 1. LLM Simulation Protocol

This already exists in the current prototype:

- `logs/runs/<run-id>/codex-demo/inbox/`
- `logs/runs/<run-id>/codex-demo/outbox/`
- `logs/runs/<run-id>/codex-demo/state/`

This protocol should become the official LLM-thread interface for `Codex-threads-dev mode`.

### 2. Human Simulation Protocol

This should be added next.

Recommended run-local directory:

- `logs/runs/<run-id>/human-sim/`

Suggested structure:

- `actions/`
- `observations/`
- `feedback/`
- `state/`

Example action files:

- `submit-prompt-<ts>.json`
- `save-router-<ts>.json`
- `refresh-page-<ts>.json`
- `save-skill-<ts>.json`

Example observation files:

- `artifact-card-<ts>.json`
- `result-panel-<ts>.json`
- `ui-summary-<ts>.md`

Example feedback files:

- `semantic-feedback-<ts>.md`
- `accept-output-<ts>.json`
- `reject-output-<ts>.json`

### 3. Runtime Execution Protocol

MoonAP eventually needs a stable protocol for running compiled WebAssembly and reporting results.

Recommended run-local directory:

- `logs/runs/<run-id>/runtime-exec/`

Suggested contents:

- `input.json`
- `stdout.txt`
- `result.json`
- `preview.json`
- `error.txt`

This is important because "compile succeeded" is not enough. MoonAP's real value is in program execution and delivered results.

### 4. SKILL Packaging Protocol

When the user accepts the result, MoonAP should be able to package the program as a reusable SKILL.

Recommended directory:

- `logs/runs/<run-id>/skill-export/`

Suggested outputs:

- `skill-manifest.json`
- `program/main.mbt`
- `program/main.wasm`
- `SKILL.md`
- `save-decision.json`

## End-to-End State Machine

`Codex-threads-dev mode` should treat MoonAP as a staged state machine.

Recommended stages:

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

Not every request needs every stage, but the mode should log them consistently.

## What Makes This Better Than Simple Codex-demo Mode

`Codex-demo mode` replaces the cloud LLM.

`Codex-threads-dev mode` would simulate the whole product environment.

That means it can test:

- whether the prompt reaches the model correctly
- whether repair loops work
- whether the wasm artifact actually runs
- whether the returned result is understandable to the user
- whether the user can approve packaging into a SKILL

This is much closer to the real MoonAP vision.

## Full MoonAP Flow Target

The target flow for this mode should be:

1. Thread 2 submits a natural-language task.
2. Thread 1 routes it through MoonAP.
3. Thread 3 returns MoonBit source.
4. Thread 1 compiles to wasm.
5. Thread 1 runs wasm through the runtime execution layer.
6. Thread 2 inspects the result.
7. If needed, Thread 2 provides semantic feedback.
8. Thread 1 turns that feedback into a repair request.
9. Thread 3 returns revised MoonBit.
10. The loop repeats until accepted.
11. Thread 2 chooses whether to save as a SKILL.
12. Thread 1 packages MoonBit + wasm + metadata as a SKILL artifact.

## Recommended Repair Classes

MoonAP should distinguish these repair loops clearly:

- `compile-repair`
- `quality-repair`
- `runtime-repair`
- `user-repair`

These are not the same thing.

### compile-repair

Fixes compiler errors only.

### quality-repair

Fixes machine-detected task-structure failures.

### runtime-repair

Fixes failures or bad outputs observed during actual wasm execution.

### user-repair

Fixes issues reported by the human user, even if compile and runtime both succeeded.

This layered repair architecture fits naturally with the three-thread model.

## Interface Ownership Rules

To avoid chaos, each thread should have a strict write scope.

### Thread 1 writes

- MoonAP source code
- run directories
- orchestration files
- compile/runtime logs
- SKILL packaging outputs

### Thread 2 writes

- `human-sim/actions/`
- `human-sim/feedback/`
- optional user-review artifacts

### Thread 3 writes

- `codex-demo/outbox/`

These boundaries are essential for reliable collaboration.

## Why This Helps Fast Development

This mode would let MoonAP developers iterate on the full product loop without waiting for:

- real external cloud calls
- real end users to be present
- ad hoc manual coordination

It creates a structured local testbed for product development, not just a one-off demo.

That is especially useful while MoonAP is still evolving:

- code generation quality
- compile pipeline
- wasm runtime
- result rendering
- SKILL export

## Short-Term Implementation Roadmap

### Phase 1

Formalize the current LLM bridge as part of `Codex-threads-dev mode`.

Already mostly done:

- `OpenAI / gpt-5.4 / moonap://codex-demo`
- run-local logging
- compile repair
- quality repair

### Phase 2

Add `human-sim/` protocol.

Goal:

- let Thread 2 act without touching MoonAP code
- record user decisions and semantic feedback

### Phase 3

Add wasm runtime execution logging and result capture.

Goal:

- move from "compiled wasm exists" to "program actually ran and produced a result"

### Phase 4

Add SKILL save flow.

Goal:

- package accepted MoonBit + wasm + metadata into a reusable SKILL artifact

## Recommendation

This should be treated as a real MoonAP development mode, not just an experiment.

Recommended name:

- `Codex-threads-dev mode`

Recommended positioning:

- a local multi-role simulation mode for fast MoonAP product development

Recommended immediate next step:

- implement the `human-sim/` protocol first

That will make the three-thread architecture concrete and prepare the way for runtime execution and SKILL packaging.
