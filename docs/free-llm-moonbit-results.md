# Free LLM Models Ability of Generating MoonBit Code

Status: draft

## Executive Summary

TBD

## Final Recommendation

### Default development model

TBD

### Backup model

TBD

## Benchmark definition

- `L1`: smallest valid MoonBit program returning `"hello moonbit"`
- `L2`: one helper + `main`
- `L3`: simple control flow and deterministic string construction

## Minimal prompt used in the experiment

### System prompt

```text
You write MoonBit code.
Return only cmd/main/main.mbt.
No markdown fences.
No explanations.
```

### User prompt

Task-only benchmark prompt. No MoonBit primer. No extra protocol.

## Model matrix

| Provider | Model | API reachable | Timeout/stall | L1 raw | L1 assisted | L2 raw | L2 assisted | L3 raw | L3 assisted | Typical rounds | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |

## Provider notes

### Gemini

TBD

### ZAI

TBD

### NVIDIA

TBD

### SiliconFlow

TBD

### OpenRouter

TBD

## Detailed per-model records

### Template

#### Provider / Model

- API reachable:
- API latency:
- Timeout behavior:
- L1:
- L2:
- L3:
- Typical repair rounds:
- Language drift pattern:
- Recommendation:

## Raw result source

The structured raw result file lives at:

- `artifacts/moonbit-eval-results.json`
