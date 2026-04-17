# Excel Max Amount Row

## Description

Find the row with the maximum numeric value in an amount column from browser-local spreadsheet data.

## When To Use

Use this skill when the user asks for financial or accounting extraction from Excel or CSV data, especially "largest amount", "maximum transaction", or similar wording.

## Inputs

- `file`: XLSX, XLS, or CSV data selected in the browser.
- `amount_column`: column used for numeric comparison. Default: `amount`.
- `operation`: extraction operation. Default: `max_row`.

## Privacy

Spreadsheet contents stay in the browser. The LLM may receive intent and metadata only unless the user explicitly approves upload.

## Program

MoonBit sources live in `program/`. The runtime protocol is `structured-rows`.
