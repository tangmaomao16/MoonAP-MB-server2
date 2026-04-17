# FastQ Generator

## Description

Generate deterministic synthetic FastQ data from a compact recipe. This avoids asking an LLM to emit large file contents token by token.

## When To Use

Use this skill when the user needs benchmark or demo FastQ files for testing MoonAP workflows.

## Inputs

- `read_count`: number of reads. Default: `10000`.
- `read_length`: bases per read. Default: `150`.
- `n_rate`: approximate N-base fraction. Default: `0.01`.
- `random_seed`: deterministic seed. Default: `42`.

## Privacy

No user file is required. The generator runs locally and can create files much larger than the prompt that described them.

## Program

MoonBit sources live in `program/`. The runtime protocol is `local-generation`.
