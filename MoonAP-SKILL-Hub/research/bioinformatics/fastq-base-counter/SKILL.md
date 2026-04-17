# FastQ Base Counter

## Description

Count a selected nucleotide base in a browser-local FastQ file. This skill is intended for quick quality-control style checks without uploading file contents.

## When To Use

Use this skill when the user asks to count bases, especially `N`, in `.fastq` or `.fq` files.

## Inputs

- `file`: FastQ or FQ file selected in the browser.
- `target_base`: base to count. Default: `N`. Allowed values: `A`, `C`, `G`, `T`, `N`.

## Privacy

File contents stay in the browser. The LLM may receive intent and metadata only unless the user explicitly approves upload.

## Program

MoonBit sources live in `program/`. The runtime protocol is `streaming-bytes`.
