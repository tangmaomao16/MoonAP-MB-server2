# MoonAP Project Summary for New Codex Thread

Last updated: 2026-04-17

## 1. Project goal

MoonAP is a MoonBit-first web application for:

- configuring LLM providers in the browser
- asking an LLM to generate MoonBit code
- compiling the generated `cmd/main/main.mbt` to `wasm-gc`
- assessing whether the generated code is not only compilable, but also semantically good enough for the requested task
- showing all steps in the UI via `Details`

Current priority is to get a **reliable first end-to-end demo** running, then continue product development and write the final project documentation.

---

## 2. Current main route

The current default LLM route is intentionally narrowed to two providers:

1. `nvidia / meta/llama-4-maverick-17b-128e-instruct`
2. `zai / glm-5.1`

The router UI has already been refactored into two levels:

- **Level 1**: select providers
- **Level 2**: select models inside each provider

Default checked strong models:

- `meta/llama-4-maverick-17b-128e-instruct`
- `glm-5.1`

Provider order in the UI is intended to keep the strongest demo route on top.

---

## 3. What is already working

### 3.1 LLM Router

- Save works
- API testing works
- usable provider order is shown in `Details`
- local config persistence is working
- runtime logging is wired

### 3.2 Logging

MoonAP now writes runtime information to:

`logs/moonap-runtime.log`

This directory is already ignored by Git via `.gitignore`.

The log is sufficient for debugging:

- codegen start
- compile probe results
- repair rounds
- benchmark or task assessment
- frontend/runtime failures

### 3.3 Benchmark quality checks

Benchmark L1 has a semantic quality check, not just compile success.

Current result:

- L1 can pass
- compile success and semantic assessment are both visible in UI

### 3.4 Onboarding / user flow

The main screen already shows a lightweight onboarding card when the router is ready:

- `Run Benchmark L1`
- `Open SKILL`
- `Edit LLM Router`
- `Open Runtime Log`
- `Download Log`

---

## 4. What has been learned from testing

### 4.1 NVIDIA model behavior

`nvidia/meta/llama-4-maverick-17b-128e-instruct` can do simple MoonBit tasks, but for more complex tasks like FastQ generation it tends to drift into general imperative coding habits:

- `var`
- parameter reassignment
- `while`
- non-MoonBit-stable style

### 4.2 ZAI model behavior

`zai/glm-5.1` is more repairable on simple tasks, but it tends to over-follow compiler hints and can sacrifice the original task semantics to get code compiling.

### 4.3 FastQ Generator status

FastQ Generator currently does **not** pass end-to-end as a good MoonBit task.

Observed pattern:

- first generation may resemble a FastQ program
- repair can make it compile
- but repair may change the program so the output semantics are no longer correct
- result becomes:
  - `compile ok`
  - `quality failed`

This means the current system is still too biased toward **compilability** rather than **task-faithful semantics** for complex tasks.

---

## 5. Latest known blocker before compaction / handoff

The latest runtime failure seen in logs is:

`browser_extract_moonbit_source is not defined`

This is the most recent explicit frontend blocker seen in the runtime log and should be checked first in the new thread if still reproducible.

Relevant log location:

`logs/moonap-runtime.log`

---

## 6. Important implementation files

### UI / browser logic

- `cmd/web_app/main.mbt`

This file contains:

- LLM Router UI behavior
- onboarding actions
- benchmark flow
- FastQ Generator flow
- prompt capture in `Details`
- compile / repair browser-side orchestration
- runtime log appends

### Native web server

- `cmd/server/main.mbt`

This file contains:

- HTTP routes
- static asset serving
- HTML shell
- runtime log endpoints

### Core policies / compile probe

- `moonap_mb_server.mbt`

This file contains:

- router policy
- compile probe
- compile summary classification
- MoonBit source extraction helper

### Current handoff document

- `docs/project-summary-codex-handoff.md`

---

## 7. Verified tooling path on this Windows machine

Do **not** rely on MinGW for native server verification here.

Use the MSVC route:

- `tools\\moon-msvc.cmd check cmd/server --target native`
- `tools\\moon-msvc.cmd build cmd/server --target native`

For frontend:

- `moon build cmd/web_app --target js`
- sync generated JS into `web/app-live.js` if needed
- `node --check web/app-live.js`

Formatting:

- `moon fmt`

---

## 8. Current product strategy

The project should now prioritize:

1. getting the first full demo route stable
2. continuing MoonAP product development
3. only then widening model experiments again if needed

The team decided **not** to keep investing heavily in broad free-model experimentation right now.

The product needs momentum more than more eval breadth.

---

## 9. Immediate next step: Codex-demo mode

The next planned implementation step is:

## **Codex-demo mode**

Goal:

- add a new option inside the LLM API settings
- present it as:
  - provider: `OpenAI`
  - model: `GPT-5.4`
  - API key: prefilled placeholder string
- use it as a **demo-only simulated cloud LLM path**
- keep the rest of MoonAP normal:
  - router UI
  - compile probe
  - repair
  - logging
  - details panel

Important design intent:

- Codex-demo mode is **not** a real external cloud endpoint
- it is a local/demo-only provider path used to unblock the first MoonAP demo
- MoonAP should still behave like a normal product around it

### Why this step is being taken

Because:

- current free models are not reliable enough for a complex MoonBit task like FastQ Generator
- the project needs a demonstrable end-to-end flow soon
- the demo should prove that MoonAP as a system works, even if free-model MoonBit quality remains imperfect

### Expected shape of Codex-demo mode

Minimal viable version:

1. Add `OpenAI / GPT-5.4` into LLM settings
2. Prefill a fixed placeholder API key such as `codex-demo-mode`
3. Route its requests to a local simulated provider path
4. Let MoonAP continue using the same compile / repair / logging flow
5. Use this route to produce high-quality MoonBit demo outputs

---

## 10. Recommendation for the next Codex thread

When the next Codex thread starts, it should:

1. read this handoff file first
2. inspect the latest `logs/moonap-runtime.log`
3. verify whether `browser_extract_moonbit_source is not defined` is still present
4. then immediately begin implementing **Codex-demo mode**

Suggested execution order:

1. add provider row in LLM Router UI
2. add provider/model into router config and policy
3. add a local simulated provider endpoint or proxy interception path
4. verify the end-to-end MoonAP demo flow with that mode

---

## 11. Short status line

**MoonAP is past the early router/debugging phase and is now at the point where the next concrete step is to implement Codex-demo mode to secure the first reliable demo flow.**

