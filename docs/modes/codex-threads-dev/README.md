# Codex-threads-dev Mode Handbook

This directory contains the canonical operating documents for `Codex-threads-dev mode`.

Read in this order:

1. [Mode Overview](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/docs/modes/codex-threads-dev-mode.md)
2. [Protocol Spec](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/docs/modes/codex-threads-dev/protocol-spec.md)
3. [Developer Thread Guide](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/docs/modes/codex-threads-dev/developer-thread.md)
4. [Simulated User Thread Guide](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/docs/modes/codex-threads-dev/simulated-user-thread.md)
5. [Simulated LLM Thread Guide](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/docs/modes/codex-threads-dev/simulated-llm-thread.md)
6. [Human-sim Action Examples](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/docs/modes/codex-threads-dev/human-sim-action-examples.md)
7. [Human-sim Feedback Examples](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/docs/modes/codex-threads-dev/human-sim-feedback-examples.md)

## Current Principle

`Codex-threads-dev mode` is the formal multi-role development mode.

- the developer thread owns MoonAP
- the simulated user thread owns user actions and semantic feedback
- the simulated LLM thread owns model responses

The threads should coordinate through local files and run-local manifests, not by ad hoc role mixing.
