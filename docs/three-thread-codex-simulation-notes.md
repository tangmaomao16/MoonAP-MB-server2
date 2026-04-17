# Three-Thread Codex Simulation Notes

This note captures a possible multi-thread simulation setup for MoonAP inside one shared workspace.

## Goal

Use three Codex threads with different roles:

1. Thread 1: MoonAP developer
   Owns code changes, starts and stops the MoonAP server, maintains runtime logs, and evolves the local bridge code.

2. Thread 2: simulated human user
   Performs browser-like actions, submits prompts, checks UI-visible results, and records user feedback.

3. Thread 3: simulated cloud LLM (`GPT-5.4`)
   Reads MoonAP requests from a shared interface and writes model responses back.

The purpose is not only to demo MoonAP, but to exercise the full product loop:

- user interaction
- LLM generation
- compile and repair
- assessment
- iterative improvement

## Feasibility

This plan is workable, with one important constraint:

- Codex threads do not natively "call each other" as first-class peers.

So the simulation should be built around shared files, logs, and small local protocols. In practice, that is still enough to simulate the three roles well.

## Recommended Role Boundaries

### Thread 1: MoonAP Developer

Responsibilities:

- start MoonAP server in background
- own `cmd/server`, `cmd/web_app`, `tools/`, and runtime wiring
- define file-based simulation interfaces
- inspect logs after each test
- avoid doing user-role or LLM-role work except when debugging the protocol itself

Owns these interfaces:

- `logs/current-run.json`
- `logs/runs/<run-id>/moonap-runtime.log`
- `logs/runs/<run-id>/codex-demo/`

### Thread 2: Simulated Human User

Responsibilities:

- act like the browser user
- choose provider / model
- submit natural-language prompts
- observe visible results
- provide human feedback such as:
  - "this output is closer"
  - "the generated FastQ still looks wrong"
  - "the game compiles but is not fun"

This thread should not patch the MoonAP codebase unless you explicitly want it to.

### Thread 3: Simulated Cloud LLM

Responsibilities:

- monitor MoonAP request files
- read `stage`, prompt payload, and any repair/assessment context
- write source-only responses to the paired response file
- never directly modify MoonAP code unless the protocol explicitly asks for it

This thread should behave like a remote model, not like a repo maintainer.

## Core Simulation Interfaces

The current `Codex-demo mode` already proves the main LLM bridge:

- request files in `codex-demo/inbox/`
- response files in `codex-demo/outbox/`
- run-local logs in `moonap-runtime.log`

That can remain the Thread 1 <-> Thread 3 protocol.

What is still missing for a clean three-thread setup is a better Thread 1 <-> Thread 2 protocol.

## Recommended Human-Simulation Interface

Add a dedicated run-local folder such as:

- `logs/runs/<run-id>/human-sim/`

Inside it:

- `actions/`
  Browser-like actions requested by Thread 2 or recorded from Thread 2.
- `observations/`
  What the simulated user saw or concluded.
- `feedback/`
  Human semantic feedback for future user-assessment loops.
- `state/`
  Current browser-side state snapshot.

Suggested action file types:

- `open-home.json`
- `save-router.json`
- `submit-prompt.json`
- `click-repair.json`
- `refresh-page.json`

Suggested observation file types:

- `ui-summary.json`
- `artifact-card.txt`
- `result-panel.txt`
- `details-log.txt`

## Two Ways to Simulate the Browser

### Option A: Real browser operations

Thread 2 really opens the site and interacts with the UI.

Pros:

- closest to real usage
- catches UI state problems
- catches `localStorage` and browser-only issues

Cons:

- harder to automate
- depends on what the Codex thread can actually drive in the environment

### Option B: Browser-equivalent command actions

Thread 2 uses commands or helper scripts to hit the same MoonAP endpoints and write browser-state equivalents.

Pros:

- easier to automate
- easier to replay
- easier to store as artifacts

Cons:

- not a full UI test
- may miss DOM and browser-storage bugs

For now, Option B is more controllable. Later, Option A can be layered on top.

## Best Practical Plan

Use a hybrid approach:

- Thread 1 keeps the real MoonAP server and the real compile/repair pipeline.
- Thread 2 simulates user intent through small action files or helper commands.
- Thread 3 simulates the cloud LLM through the existing inbox/outbox bridge.

This gives us realistic end-to-end testing without requiring perfect GUI automation.

## Minimal Protocol Proposal

### Developer -> Human Sim

Thread 1 writes:

- `human-sim/state/browser-context.json`
- `human-sim/state/router-config.json`
- `human-sim/state/latest-artifact.json`

### Human Sim -> Developer

Thread 2 writes:

- `human-sim/actions/submit-prompt-<ts>.json`
- `human-sim/actions/toggle-provider-<ts>.json`
- `human-sim/feedback/user-feedback-<ts>.md`

Thread 1 can consume these files or provide a helper script that converts them into actual MoonAP requests.

### Developer -> LLM Sim

Already implemented:

- `codex-demo/inbox/*.txt`
- `codex-demo/outbox/*.response.txt`
- `codex-demo/outbox/*.error.txt`

### LLM Sim -> Developer

Already implemented:

- response file writing
- repair-stage response support

## Why This Can Work Well

This setup separates three different feedback sources:

1. compiler feedback
2. system assessment feedback
3. human semantic feedback

That is exactly the direction MoonAP needs.

The current code now supports:

- codegen
- compile repair
- system assessment
- quality repair

The next natural layer is:

- human feedback repair

And Thread 2 is a good simulation stand-in for that future product role.

## Suggested Future Extension

Add a new repair trigger after system assessment:

- if user feedback exists and is marked actionable, prefer `user-repair`
- otherwise use `quality-repair`

That would create three repair classes:

- `compile-repair`
- `quality-repair`
- `user-repair`

Each should be logged separately.

## Important Risks

### Shared workspace race conditions

All three threads share the same repo, so they can step on each other.

Mitigations:

- Thread 1 is the only thread allowed to modify MoonAP source code.
- Thread 2 only writes `human-sim/` artifacts.
- Thread 3 only writes `codex-demo/outbox/` artifacts.

### Git lock conflicts

Concurrent git operations can easily collide.

Mitigation:

- only Thread 1 performs git actions

### Background server ownership

The running `server.exe` should belong to Thread 1 only.

Mitigation:

- Thread 1 is the only thread allowed to start or stop the MoonAP server

### Browser-state drift

If Thread 2 uses command-based simulation instead of a real browser, `localStorage`-dependent behavior may diverge.

Mitigation:

- keep router and session state snapshots in files
- periodically validate with a real browser pass

## Recommendation

Yes, this three-thread plan is feasible.

The cleanest version is:

- Thread 1 owns MoonAP and the runtime protocol
- Thread 2 owns simulated human actions and human feedback
- Thread 3 owns LLM responses only

The key to making it stable is not "more intelligence", but clearer shared interfaces.

## Recommended Next Implementation Step

If we proceed with this design, the next code addition should be:

- a `human-sim/` run-local protocol

That would make the three-thread setup symmetrical:

- human inbox/outbox-like actions
- LLM inbox/outbox-like actions
- one developer thread orchestrating the real MoonAP pipeline
