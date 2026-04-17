# 2026-04-17 GPT-5.4 FastQ Codegen Milestone

## Summary

This milestone records the first clean `Codex-threads-dev mode` success where:

- the simulated LLM thread was switched away from the old scripted keyword-template path
- the `GPT-5.4` codegen prompt was reduced to an extremely small system prompt plus the raw user request
- one explicit wake-up instruction to the simulated LLM thread was enough
- MoonAP produced MoonBit code that compiled under `wasm-gc`
- MoonAP's system assessment marked the FastQ task as passed

This was a `codegen` success, not a later repair-only rescue.

## Exact Timestamps

Primary success timestamps:

- Request file created:
  - local workspace timestamp: `2026-04-17 20:45:37` in `Asia/Shanghai (UTC+08:00)`
  - file: [llm-sim-13420903537499.json](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/logs/runs/run-13420901188313/llm-sim/inbox/llm-sim-13420903537499.json)

- Response file created:
  - local workspace timestamp: `2026-04-17 20:47:56` in `Asia/Shanghai (UTC+08:00)`
  - file: [llm-sim-13420903537499.response.txt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/logs/runs/run-13420901188313/llm-sim/outbox/llm-sim-13420903537499.response.txt)

- Benchmark pass recorded in runtime log:
  - UTC log timestamp: `2026-04-17T12:47:56.908Z`
  - corresponding `Asia/Shanghai (UTC+08:00)` time: `2026-04-17 20:47:56.908`
  - log file: [moonap-runtime.log](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/logs/runs/run-13420901188313/moonap-runtime.log)

Active run manifest for this milestone:

- [logs/current-run.json](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/logs/current-run.json)
  - `run_id = run-13420901188313`

## Prompt Shape Used

### System prompt

```text
You are an AI coder.
You only write MoonBit code.
Your job is to write MoonBit code for the user's task.
Return only the full contents of cmd/main/main.mbt.
```

### User prompt

```text
Generate a FastQ file generator.
```

This was intentionally reduced to the raw user request only.

## Request Evidence

The request JSON for the successful generation shows:

- `stage = codegen`
- `model = gpt-5.4`
- only two messages:
  - one short system message
  - one raw user request message

Evidence:

- [llm-sim-13420903537499.json](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/logs/runs/run-13420901188313/llm-sim/inbox/llm-sim-13420903537499.json)
- [llm-sim-13420903537499.txt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/logs/runs/run-13420901188313/llm-sim/inbox/llm-sim-13420903537499.txt)

## Generated MoonBit Code

The simulated LLM thread returned this MoonBit source:

```moonbit
fn next_seed(seed : Int) -> Int {
  (seed * 1664525 + 1013904223) % 2147483647
}

fn pick_base(seed : Int) -> String {
  let value = seed % 5
  if value == 0 {
    "A"
  } else if value == 1 {
    "C"
  } else if value == 2 {
    "G"
  } else if value == 3 {
    "T"
  } else {
    "N"
  }
}

fn build_sequence(seed : Int, length : Int, acc : String) -> (String, Int) {
  if length == 0 {
    (acc, seed)
  } else {
    let next = next_seed(seed)
    build_sequence(next, length - 1, acc + pick_base(next))
  }
}

fn build_quality(length : Int, acc : String) -> String {
  if length == 0 {
    acc
  } else {
    build_quality(length - 1, acc + "I")
  }
}

fn build_record(seed : Int, index : Int, read_length : Int) -> (String, Int) {
  let (sequence, next) = build_sequence(seed, read_length, "")
  let quality = build_quality(read_length, "")
  let header = "@moonap_read_" + index.to_string()
  let record = header + "\n" + sequence + "\n+\n" + quality + "\n"
  (record, next)
}

fn build_fastq(seed : Int, count : Int, read_length : Int, index : Int, acc : String) -> String {
  if count == 0 {
    acc
  } else {
    let (record, next) = build_record(seed, index, read_length)
    build_fastq(next, count - 1, read_length, index + 1, acc + record)
  }
}

fn main {
  ignore(build_fastq(42, 4, 24, 1, ""))
}
```

Primary response file:

- [llm-sim-13420903537499.response.txt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/logs/runs/run-13420901188313/llm-sim/outbox/llm-sim-13420903537499.response.txt)

## Observed Product Outcome

MoonAP recorded:

- native compile success
- wasm artifact generation
- benchmark assessment success
- FastQ quality pass

Most important runtime-log entries:

- `moonbit-wasm-compile succeeded`
- `moonbit-benchmark-check succeeded`
- `FastQ Generator task passed`

The runtime log also records the benchmark explanation:

> Compile succeeded and the generated MoonBit source shows the expected FastQ structure: a header, sequence logic, plus line, and quality generation without imports.

## Why This Milestone Matters

This experiment strongly suggests that the following combination is healthier for `GPT-5.4` than the older heavy prompt style:

- very small system prompt
- raw user request as the codegen user prompt
- simulated LLM thread operating in request-driven mode instead of scripted keyword-template mode

In earlier failures, the simulated LLM thread admitted it was:

- not truly reading `raw_body.messages`
- using scripted keyword matching
- returning canned FastQ or `unsupported task` paths

This milestone happened only after that old scripted path was explicitly disabled and the thread was told to use `raw_body.messages` as the only source of truth.

An additional observation from the same testing cycle:

- the simulated LLM thread reported that it behaved most reliably when it was awakened with one very short per-request instruction instead of a long worker-burst policy reminder
- the preferred operational template became:

```text
Handle the latest llm-sim request.
First read /api/llm-sim/latest-request, then fully read raw_body.messages, generate the response only from those messages, write it to reply_path, and reply handled <request_id>.
```

This is now the preferred day-to-day testing instruction for the simulated LLM thread.

## Current Limits

This milestone proves a clean `codegen` success for the FastQ case.

It does not yet prove:

- stable Excel task success
- stable browser-game task success
- real browser-side runtime execution for generated wasm
- final SKILL export acceptance flow

Those should be recorded as separate experiments.
