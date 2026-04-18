# Developer Handoff - 2026-04-18

## Handoff Metadata
- Authoring thread: `Developer-1` (current overloaded thread)
- Intended receiver: new `Developer-1` Codex thread
- Workspace: `C:\my_work\MoonBit_Competition\GitHub\MoonAP-MB-server2`
- Local timezone for this note: `Asia/Shanghai (UTC+08:00)`
- Handoff written at: `2026-04-18 22:55 Asia/Shanghai`

## What Is Already Working

### End-to-end FastQ generation flow
The following user-visible flow is now working in the browser:

1. User opens MoonAP site.
2. User submits `Generate a FastQ file generator.`
3. `Simulated LLM thread` handles the latest `llm-sim` request.
4. MoonAP compiles generated MoonBit to wasm.
5. Benchmark / system assessment can pass.
6. Browser shows runtime panel for FastQ generation.
7. User fills runtime parameters and clicks run.
8. Browser generates and downloads a `.fastq` file locally.
9. MoonAP records runtime result.
10. User can click `Save to Personal-SKILL-Set`.

This is the main milestone that has been demonstrated repeatedly.

### Prompt strategy that worked
For `GPT-5.4`, the best-performing `codegen` path is now very simple:

- Minimal system prompt:
  - `You are an AI coder.`
  - `You only write MoonBit code.`
  - `Your job is to write MoonBit code for the user's task.`
  - `Return only the full contents of cmd/main/main.mbt.`
- `codegen` user prompt:
  - raw user text only

Important:
- `codegen` should stay minimal for `GPT-5.4`.
- `compile-repair` was changed toward conversation-style repair.
- `quality-repair` was also simplified for `GPT-5.4`, but this path may still need refinement later.

### Simulated LLM thread operating model
The previous scripted / keyword-template worker path was diagnosed as the main source of false failures.

The `Simulated LLM thread` should now be used in a request-driven way:

```text
处理当前最新的 llm-sim request。先读取 /api/llm-sim/latest-request，完整读取 raw_body.messages，只按这些 messages 生成响应，写到 reply_path。完成后只回复 handled <request_id>。
```

Important lessons learned:
- Do not ask the simulated LLM thread to do long philosophical worker loops.
- Do not ask it to classify tasks itself.
- Do not let it use canned FastQ / unsupported-task template logic.
- Best practice is: browser first creates the request, then the human wakes the simulated LLM thread once.

## Current Architecture Direction

### Lightweight runtime abstraction
We deliberately rejected an over-engineered runtime platform design.

Current intended abstraction is the lightweight one documented in:
- `C:\my_work\MoonBit_Competition\GitHub\MoonAP-MB-server2\docs\architecture\lightweight-task-runtime-abstraction.md`

Core objects:
- `task_kind`
- `runtime_mode`
- `runtime_spec`
- `result_mode`

Task kinds currently considered:
- `fastq-generator`
- `fastq-analysis`
- `excel-generator`
- `finance-report-analysis`
- `browser-game`
- `generic`

Current state:
- FastQ runtime form already moved toward schema-driven rendering.
- Other task kinds still mostly have placeholders / skeleton handling.

### SKILL format direction
We aligned on a minimal Anthropic/OpenAI-compatible folder shape:

```text
<skill-name>/
  SKILL.md
  program/
    main.wasm
    main.mbt   # optional but recommended
```

Important design choices:
- Canonical internal form = folder
- External convenience export/import later can be zip
- `SKILL.md` is the main source of truth
- Avoid duplicate content across multiple sidecar JSON files unless truly necessary

Current `SKILL.md` direction:
- frontmatter only:
  - `name`
  - `description`
- no repeated title line
- top-level body sections should use `#`, not `##`, because there is no title heading above them
- intended body sections:
  - `# Key Attributes`
  - `# Inputs`
  - `# Output`
  - `# Runtime Spec`

Related doc:
- `C:\my_work\MoonBit_Competition\GitHub\MoonAP-MB-server2\docs\architecture\moonap-skill-folder-spec.md`

## Current Browser UX State

### Runtime panel
FastQ runtime panel now supports:
- schema-driven parameter form
- rerun after runtime success
- download buttons
- save-as-skill button

User feedback already received:
1. Primary action color must be obvious to users; black implied unclear meaning.
2. Saving a SKILL must give explicit UI feedback, not silent background save.
3. Save button should remain after one save, because user may save again with another name/path.
4. Run button should remain after runtime success.

Some of these were already addressed in the latest iterations, but the receiver should verify after hard refresh with the running build, not assume screenshots always matched newest code.

### Save-to-SKILL UX expectation
The user explicitly wants:
- Clicking `Save to Personal-SKILL-Set` should first show a dialog.
- Dialog should let user enter:
  - SKILL name
  - description
  - save location
- Save location should be explicitly chosen by a button, not by a surprising browser popup.
- Confirm should then export/download/save.

## What Is NOT Done Yet

This is the most important unfinished area.

### SKILL export exists, but true SKILL reuse is not fully implemented
Current status:
- Saving/exporting a SKILL folder works in principle.
- Browser runtime and save flow already reaches `skill-export`.
- `SKILL.md` generation has been reworked toward the minimal spec.

But true reusable SKILL behavior is still incomplete:
- `SKILL` tab does not yet fully behave as a real skill runtime browser.
- Saved personal skills are not yet cleanly reloaded and rerun as artifact-driven skills end-to-end.
- The intended path is:
  1. list saved skills
  2. read `SKILL.md`
  3. parse frontmatter and `Runtime Spec`
  4. load `program/main.wasm`
  5. rerender runtime form
  6. run without LLM

This is the next major engineering target.

## Recommended Next Implementation Target

### Primary recommendation
Implement true `fastq-generator` SKILL reuse first, before expanding to other task kinds.

The goal should be:
1. Save FastQ workflow as a SKILL folder.
2. Show it in `SKILL` tab.
3. Click the skill.
4. Load its `SKILL.md`.
5. Parse `Runtime Spec`.
6. Show runtime form.
7. Run `program/main.wasm` (or current browser-local equivalent bridge if wasm execution is still mocked through JS path).
8. Download a new `.fastq`.

This is the missing half of the loop.

### Suggested API shape for SKILL reuse
Keep it light:

- `POST /api/skills/personal/save`
- `GET /api/skills/personal/list`
- `GET /api/skills/personal/read?skill=<id>`
- `POST /api/skills/personal/run`

Principle:
- SKILL rerun must be artifact-driven, not LLM-driven.

## Code Areas To Read First

### Frontend
- `C:\my_work\MoonBit_Competition\GitHub\MoonAP-MB-server2\cmd\web_app\main.mbt`

Pay special attention to:
- runtime card rendering
- runtime request / runtime result handlers
- skill export dialog
- personal skills rendering
- skill dialog opening and execution paths

### Server
- `C:\my_work\MoonBit_Competition\GitHub\MoonAP-MB-server2\cmd\server\main.mbt`

Pay special attention to:
- runtime request registration
- runtime result recording
- skill save decision APIs
- any personal skill listing / reading endpoints if they already exist in partial form

## Important Behavioral Lessons

### 1. Simpler worked better than smarter
We repeatedly learned that making MoonAP “more abstract” too early often made behavior worse.

Use these heuristics:
- prefer smaller prompts
- prefer fewer fields
- prefer one clear source of truth
- prefer one short instruction to the simulated LLM thread

### 2. Avoid duplicated metadata
Do not spread the same SKILL metadata across:
- markdown
- separate json
- UI hardcoded strings

If possible:
- keep canonical metadata in `SKILL.md`
- derive UI from it

### 3. Separate canonical form from convenience packaging
We discussed that:
- canonical internal form = folder
- convenience export/import later = zip

Do not collapse the internal model into “zip only”.

## Suggested Immediate Task List For New Developer Thread

1. Verify current UI state after hard refresh:
   - runtime panel
   - run button persistence
   - save button persistence
   - save dialog behavior
2. Inspect current `Save to Personal-SKILL-Set` implementation and confirm generated `SKILL.md` matches the latest minimal structure.
3. Implement `SKILL` panel reuse path for saved personal `fastq-generator`.
4. Only after that, expand toward the next non-FastQ task kind.

## Testing Notes

For the current main demo flow, use:
- browser prompt: `Generate a FastQ file generator.`
- then wake `Simulated LLM thread` with the short request-driven instruction

Expected visible success path:
- compile succeeds
- runtime panel appears
- user runs generator
- browser downloads `.fastq`
- runtime result card appears
- save-as-skill is available

## Final Recommendation

Do not broaden scope immediately to Excel/game before the following loop is complete:

`LLM generate -> compile -> runtime -> save as SKILL -> open from SKILL -> rerun without LLM`

That loop is the highest-value unfinished work.
