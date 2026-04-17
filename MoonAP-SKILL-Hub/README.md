# MoonAP-SKILL-Hub

MoonAP-SKILL-Hub stores prebuilt MoonAP skills. A skill is an Anthropic-style folder with:

- `SKILL.md`: human and agent-readable description, usage, inputs, parameters, privacy notes, and outputs.
- `moonap.skill.json`: machine-readable MoonAP manifest.
- `program/`: MoonBit source code that can be compiled to WebAssembly and run in the browser.

The hub is organized by domain and category:

```text
MoonAP-SKILL-Hub/
  research/bioinformatics/fastq-base-counter/
  finance/accounting/excel-max-amount-row/
  games/board-games/gomoku/
```

Users can install hub skills into a local `Personal-MoonAP-SKILL-Set` with the same folder layout. LLM-generated MoonBit artifacts should become reusable personal skills only after manifest generation, MoonBit compile validation, browser runtime validation, and user approval.
