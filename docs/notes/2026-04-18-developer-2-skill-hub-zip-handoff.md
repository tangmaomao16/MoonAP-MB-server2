# Developer-2 SKILL Hub ZIP Handoff

Date: 2026-04-18

This note is for handing off the current MoonAP `SKILL Hub` implementation state to the next Codex session / thread Developer-3.

## Scope

This handoff covers the following active feature area:

- `Personal-SKILL-Set`
- `Local-SKILL-Hub`
- `Cloud-SKILL-Hub`
- ZIP-based SKILL export and ZIP-based Cloud SKILL install

The goal is to let Developer-3 continue without re-reading the full prior thread context.

## Main Repos

- MoonAP main project:
  [C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2)
- Official public SKILL repo:
  [https://github.com/tangmaomao16/MoonAP-SKILL-Hub](https://github.com/tangmaomao16/MoonAP-SKILL-Hub)

## Primary File To Continue From

Most of the current implementation lives in:

- [cmd/web_app/main.mbt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/cmd/web_app/main.mbt)

This file now contains:

- Personal SKILL save/export logic
- Personal SKILL reload logic
- Local SKILL Hub directory selection and scan logic
- Cloud SKILL Hub catalog fetch logic
- Cloud SKILL Hub install logic
- The browser-side ZIP runtime used for save/install

## Current Product Model

MoonAP currently splits reusable skills into three areas:

1. `Personal-SKILL-Set`
   User-generated reusable skills saved from MoonAP runtime results.

2. `Local-SKILL-Hub`
   User-selected local public skill directory. Installed public skills are expected to live here.

3. `Cloud-SKILL-Hub`
   Public official catalog loaded from the GitHub repo `MoonAP-SKILL-Hub`.

Important product rule already agreed with the user:

- Cloud is for discovery and install.
- Local is the place where public skills are actually used.
- Personal is for user-created reusable skills.

## Current ZIP Design

The current agreed design is:

- When saving a SKILL from MoonAP, save both:
  - `skill-folder/`
  - `skill-folder.zip`
- The ZIP sits at the same directory level as the folder.

Example:

```text
Personal-SKILL-Set/
  fastq-generator/
  fastq-generator.zip
```

For public official skills in the GitHub repo, the same convention is expected:

```text
bioinformatics/sequencing/fastq-generator/
bioinformatics/sequencing/fastq-generator.zip
```

## What Was Just Implemented

### 1. Save APP as SKILL now supports ZIP export

The save dialog now includes a default-checked option:

- `Also generate a .zip package for publishing or sharing`

When checked, export writes:

- `SKILL.md`
- `program/main.wasm`
- optional `program/main.mbt`
- same-level `.zip`

This behavior is implemented in:

- [cmd/web_app/main.mbt](C:/my_work/MoonBit_Competition/GitHub/MoonAP-MB-server2/cmd/web_app/main.mbt)

Look for:

- `browser_open_skill_export_dialog`
- `browser_on_skill_export_confirm`
- `browser_request_skill_save`

### 2. Browser-side ZIP runtime was added

A lightweight JS ZIP runtime is now embedded in `cmd/web_app/main.mbt`.

It currently provides:

- ZIP creation for export
- ZIP extraction for install

Implementation entry:

- `browser_ensure_skill_zip_runtime`

Important details:

- ZIP creation currently writes `store` entries only
- ZIP extraction supports:
  - method `0` (store)
  - method `8` (deflate) through `DecompressionStream("deflate-raw")`

This means the installer should work with typical ZIPs, assuming the browser supports `DecompressionStream`.

### 3. Cloud install is now ZIP-based

Previously there was a temporary raw-file install implementation that fetched:

- `SKILL.md`
- `program/main.wasm`
- optional `program/main.mbt`

That temporary path was replaced because it would lose future nested assets/files.

Now `browser_install_cloud_skill`:

1. resolves ZIP download URL
2. downloads ZIP bytes
3. extracts all files/directories
4. writes them into the selected `Local-SKILL-Hub` root

### 4. Cloud catalog ZIP URL fallback

Cloud catalog normalization now assumes:

- if `zip_url` is present, use it
- else if `zip_path` is present, build raw GitHub URL from it
- else if `folder_path` is present, infer:
  - `folder_path + ".zip"`

So for:

- `bioinformatics/sequencing/fastq-generator`

MoonAP will infer:

- `bioinformatics/sequencing/fastq-generator.zip`

and construct:

- `https://raw.githubusercontent.com/tangmaomao16/MoonAP-SKILL-Hub/main/bioinformatics/sequencing/fastq-generator.zip`

## Current Official Cloud Catalog State

The official repo currently has at least one skill entry:

- `fastq-generator`

The catalog is read from:

- [https://raw.githubusercontent.com/tangmaomao16/MoonAP-SKILL-Hub/main/index.json](https://raw.githubusercontent.com/tangmaomao16/MoonAP-SKILL-Hub/main/index.json)

MoonAP currently supports catalog formats:

- root array
- object with `skills`
- object with `entries`

## Important Known Constraint

Cloud install now expects the ZIP file to actually exist in the public repo.

If the repo only contains:

- `bioinformatics/sequencing/fastq-generator/`

but does **not** contain:

- `bioinformatics/sequencing/fastq-generator.zip`

then `Install to Local SKILL Hub` will fail with a ZIP fetch error.

So the next operational requirement is:

- the `MoonAP-SKILL-Hub maintainer` session must generate and push ZIPs alongside skill folders

## What Still Needs Work

The system is much closer to complete, but not fully polished yet.

### A. Public repo workflow still needs ZIP publishing discipline

The public repo maintainer must now keep both:

- skill folder
- same-level ZIP

This is a content/process requirement, not just a UI requirement.

### B. Local public skill execution coverage is still limited

In `Local-SKILL-Hub`, clicking a local public skill can open metadata and attempt rerun, but execution wiring is only ready for a small subset:

- `fastq-generator`
- `fastq-analysis`

Other task kinds still need runtime wiring.

Look at:

- `execute_dialog_skill()`

### C. ZIP export currently packages only the files MoonAP itself knows about

For `Save APP as SKILL`, the generated ZIP currently includes:

- `SKILL.md`
- `program/main.wasm`
- optional `program/main.mbt`

This is correct for the current generated Personal SKILL structure.

But if later Personal SKILL export gains:

- `assets/`
- nested resources
- screenshots
- extra config files

then the export ZIP builder will need to include them too.

### D. `moon info` is not usable for this JS-only frontend package

Project instructions say to run `moon info && moon fmt`, but for this package:

- `moon info` fails because `cmd/web_app/main.mbt` contains many `extern "js"` blocks and native backend does not support them

This is a known project/tooling mismatch, not a new regression from this feature work.

Current practical validation path is:

- `moon fmt`
- `tools/moon-msvc.cmd build cmd/web_app --target js`
- `tools/restart-moonap-server.cmd`

## Recommended Immediate Next Steps For Developer-3

### 1. Verify ZIP export end-to-end

Use MoonAP UI:

1. generate a task like FastQ generator
2. click `Save APP as SKILL`
3. keep ZIP checkbox enabled
4. export into a test local folder
5. verify both are generated:
   - folder
   - same-level `.zip`

### 2. Verify Cloud install end-to-end

Precondition:

- ensure `MoonAP-SKILL-Hub` repo contains the skill ZIP in the expected same-level path

Then test:

1. open `Cloud-SKILL-Hub`
2. click the official skill card
3. click `Install to Local SKILL Hub`
4. choose a local hub folder
5. verify the ZIP is downloaded, extracted, and written into Local Hub
6. verify the installed skill appears under `Local-SKILL-Hub`

### 3. Verify Local rerun

For `fastq-generator`, confirm:

1. it appears in `Local-SKILL-Hub`
2. clicking it opens the dialog
3. running it still works through the existing runtime bridge

### 4. Coordinate with `MoonAP-SKILL-Hub maintainer`

Ask that session to:

- generate same-level ZIPs for public skills
- keep them updated
- optionally add `zip_path` in `index.json`

Even though MoonAP now has a fallback inference rule, explicit `zip_path` is cleaner.

## Useful Commands

Rebuild frontend JS:

```powershell
tools\moon-msvc.cmd build cmd/web_app --target js
```

Restart local MoonAP server:

```powershell
tools\restart-moonap-server.cmd
```

## Last Known Local Runtime State

At the time of writing, MoonAP server was restarted successfully and reported:

- PID `10712`

This may change later; it is only a last known value.

## Handoff Summary

Developer-3 should assume:

- SKILL Hub three-layer model is already in place
- Cloud catalog read path is already working
- ZIP architecture is now the intended distribution/install model
- save/export and install code was just moved onto ZIP logic
- the main remaining work is validation, polish, and broader task-kind coverage

