# MoonAP MB Server

MoonAP MB Server is the clean MoonBit-first restart of MoonAP: a MoonBit Agent Playground where natural language is routed into MoonBit task kernels, compiled to WebAssembly, and executed against browser-local files.

This first milestone intentionally keeps the server small and native:

- MoonBit owns health, route policy, LLM policy, file privacy policy, task kernel protocol, skill registry, and normalized agent context.
- MoonBit `moonbitlang/async/http` owns the HTTP server.
- Local file contents are not sent to cloud LLMs by default.

Product entry:

> MoonAP: MoonBit Agent Playground. Set LLM API and chat, or use SKILL.

The app starts in SKILL-only mode until the user configures and validates a cloud LLM API. Prebuilt skills remain available without LLM access.

## Future formal verification gate

MoonAP reserves an off-by-default option for MoonBit 0.9 formal verification. When this future feature is implemented, LLM-generated MoonBit code can pass through a `moon prove` step before WebAssembly compilation. This is currently exposed only as policy and UI state; it does not execute verification yet.

## SKILL stores

- `MoonAP-SKILL-Hub/`: public, GitHub-hosted prebuilt skills.
- `Personal-MoonAP-SKILL-Set`: planned local user directory with the same layout for reusable validated LLM-generated MoonBit programs.

Each skill folder follows the Anthropic-style pattern:

```text
SKILL.md
moonap.skill.json
program/
```

Current starter skills:

- `research/bioinformatics/fastq-base-counter`: default `target_base = N`.
- `research/bioinformatics/fastq-generator`: default `read_count = 10000`, `read_length = 150`, `n_rate = 0.01`.
- `finance/accounting/excel-max-amount-row`: default `amount_column = amount`, `operation = max_row`.
- `games/board-games/gomoku`: default `play_mode = single_player`, `board_size = 15`.

## Large-file MVP

MoonAP now includes a browser-local FastQ path:

- `FastQ Generator` downloads a deterministic demo file without asking the LLM to print file contents.
- `FastQ Base Counter` reads the selected file in 4 MB browser chunks, counts `N` bases in sequence lines, and reports `uploaded_bytes = 0`.

See `docs/large-file-runtime.md` for the demo script and runtime notes.

## Commands

Use the MSVC wrapper on Windows so MoonBit native packages such as `moonbitlang/async` compile with Visual Studio instead of MinGW:

```cmd
tools\moon-msvc.cmd test
tools\moon-msvc.cmd run cmd/server --target native
```

Shortcut for the server:

```cmd
tools\moon-server-msvc.cmd
```

Start the server in the background and return immediately:

```cmd
tools\start-moonap-bg.cmd
```

Stop the background server:

```cmd
tools\stop-moonap-server.cmd
```

```powershell
moon add moonbitlang/async
moon test
moon build cmd/web_app --target js
Copy-Item _build\js\debug\build\cmd\web_app\web_app.js web\app.js -Force
Copy-Item _build\js\debug\build\cmd\web_app\web_app.js.map web\app.js.map -Force
moon run cmd/server --target native
```

The development server serves the web UI at `http://127.0.0.1:3000`.

## MoonBit-first frontend

The browser app source lives in `cmd/web_app/main.mbt` and is compiled with MoonBit's JavaScript backend. The generated `web/app.js` file is served by the native MoonBit server; browser DOM and `fetch` are only thin JS FFI host calls.
