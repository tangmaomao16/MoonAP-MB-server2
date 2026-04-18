# Developer-3 Notes - Real LLM API Environment and Proxy Pitfalls

## Metadata
- Authoring thread: `Developer-3`
- Workspace: `C:\my_work\MoonBit_Competition\GitHub\MoonAP-MB-server2`
- Written at: `2026-04-18 Asia/Shanghai`

## Why this note exists

This note records an important operational lesson discovered while switching MoonAP
from `Simulated LLM GPT-5.4` back to real cloud model APIs.

At first glance, it looked like:

- `Simulated LLM GPT-5.4` could run the full MoonAP flow
- `NVIDIA` and `ZAI` failed during `llm-api-test`

It was tempting to suspect:

- broken provider configuration
- wrong model names
- wrong prompt strategy
- regression in MoonAP router logic

That was **not** the real cause.

The main issue was the **local server process environment** on Windows, especially
when MoonAP was started from within the current Codex / sandboxed session.

## Short conclusion

Real API failures in this round were caused primarily by **environment contamination**,
not by MoonAP router configuration.

Specifically:

1. the current Codex environment injected broken proxy variables
2. the MoonAP server process inherited those proxy variables
3. the inherited proxy settings broke outbound HTTPS requests
4. after starting MoonAP server in a cleaner environment, both:
   - `nvidia/meta/llama-4-maverick-17b-128e-instruct`
   - `zai/glm-5.1`
   passed `llm-api-test`

This means:

- MoonAP router/provider wiring was fundamentally OK
- CORS was still a blocker for browser-direct experiments, so browser-direct is not
  the solution
- the right fix was to clean the **server-side process environment**

## Symptoms observed

### Initial browser-visible failure

In the MoonAP details panel, `llm-api-test` showed errors like:

- `TlsError("No credentials are available in the security package")`

After adding a temporary `curl.exe` fallback in the server proxy, another clue
appeared:

- `curl: (7) Failed to connect ... via 127.0.0.1`

This was the first strong sign that the problem was not simply provider auth.

### Important interpretation

These errors happened **before provider response**.

That means the request failed in:

- local MoonBit HTTP/TLS layer
- or local process environment / proxy layer

and **not** inside NVIDIA/ZAI application logic.

## Root cause details

### 1. Broken proxy variables were present in the current process environment

During investigation, the shell environment contained proxy variables like:

```text
ALL_PROXY=http://127.0.0.1:9
HTTP_PROXY=http://127.0.0.1:9
HTTPS_PROXY=http://127.0.0.1:9
GIT_HTTP_PROXY=http://127.0.0.1:9
GIT_HTTPS_PROXY=http://127.0.0.1:9
```

These values are effectively unusable for MoonAP's real provider traffic.

If MoonAP server is started from a process that inherits them, outbound API requests
can fail in misleading ways.

### 2. User-level Windows Internet proxy was also enabled

The machine also showed a user Internet proxy setting like:

```text
ProxyEnable = 1
ProxyServer = 127.0.0.1:26001
```

This added more confusion to the investigation because some tools would mention
`127.0.0.1` in their error output.

### 3. The current Codex run context mattered

The most important practical lesson is:

- a MoonAP server started from inside the current Codex / sandboxed environment may
  inherit a networking environment that is **not representative of normal local use**

This can make real cloud API tests look like:

- MoonAP is broken
- provider config is wrong

when the actual problem is just inherited process environment.

## What was verified during debugging

### Step 1: local proxy route really was the failure point

`Simulated LLM GPT-5.4` worked because it stays local and does not depend on real
outbound HTTPS.

`NVIDIA` and `ZAI` failed only on the real-provider path.

### Step 2: provider wiring itself was not the issue

Once MoonAP server was started in a cleaner environment, direct probe requests sent
through `/api/llm/proxy` reached the providers successfully.

Minimal invalid-token probes returned real provider responses:

- NVIDIA returned `401 Unauthorized`
- ZAI returned `401 token invalid`

This was a crucial proof point:

- the request path was reaching the real provider
- URL and route shape were valid
- remaining failures were no longer local TLS bootstrap failures

### Step 3: browser UI test succeeded again

After restarting MoonAP server in the cleaner environment, browser `llm-api-test`
for:

- `nvidia/meta/llama-4-maverick-17b-128e-instruct`
- `zai/glm-5.1`

returned:

- `OK`

and the details panel showed:

- `Result: succeeded`

## Code and script changes made

### 1. `tools\start-moonap-bg.cmd`

This script was updated so that MoonAP server starts with a cleaner environment.

Current behavior now removes common proxy variables before launching `server.exe`,
including:

- `HTTP_PROXY`
- `HTTPS_PROXY`
- `ALL_PROXY`
- `GIT_HTTP_PROXY`
- `GIT_HTTPS_PROXY`
- lower-case variants

This is the most important durable fix from this debugging round.

### 2. `cmd/server/main.mbt`

A temporary and useful defensive improvement was added:

- if direct `@http.post(...)` fails before provider response
- MoonAP now attempts a `curl.exe` fallback

This fallback is useful for diagnosis and may continue to help on some Windows setups.

However, the deeper lesson is still:

- process environment matters more than provider configuration when failures occur
  before provider response

### 3. `cmd/server/moon.pkg`

Imports were extended to support the fallback path:

- `moonbitlang/async/process`
- `moonbitlang/core/string`

## Important things future developers should remember

### 1. Do not jump to prompt/model conclusions too early

If `llm-api-test` fails with errors like:

- `TlsError(...)`
- `No credentials are available in the security package`
- `via 127.0.0.1`
- `Failed to connect before provider response`

then first inspect:

- inherited proxy environment
- current Windows proxy configuration
- how the MoonAP server process was started

Do **not** first assume:

- NVIDIA model is wrong
- ZAI model is wrong
- prompt template is too heavy
- MoonBit codegen ability is the problem

Those may matter later, but not at this stage.

### 2. Browser-direct real API mode is still not the answer here

This round reconfirmed an earlier constraint:

- browser-direct real API calls are blocked by CORS in the relevant provider scenarios

So even if server-side proxying becomes temporarily painful, the correct direction is
still:

- keep MoonAP real LLM traffic going through the local server proxy

### 3. Server start path matters

Preferred operator path remains:

```cmd
tools\restart-moonap-server.cmd
```

But if a future debugging session is happening from a constrained environment, confirm
that the launched process is not inheriting bad proxy variables.

### 4. If the debug build directory gets stuck, release build can help

During this round, Windows linker locks also appeared in the debug build output,
including:

- `LNK1104`
- `LNK1114`

When that happened, a practical workaround was:

- build and run the `release` server executable

This is not the conceptual fix for the API issue, but it can unblock verification work.

## Recommended debugging checklist for future real LLM failures

If `Simulated GPT-5.4` works but real providers fail:

1. Check whether the error happens before provider response
2. Check shell environment for:
   - `HTTP_PROXY`
   - `HTTPS_PROXY`
   - `ALL_PROXY`
   - `GIT_HTTP_PROXY`
   - `GIT_HTTPS_PROXY`
3. Check Windows Internet proxy / WinHTTP proxy state
4. Confirm how MoonAP server was started
5. Probe `/api/llm/proxy` with a minimal external URL
6. Probe provider endpoints with intentionally invalid tokens

Interpretation:

- if invalid-token probes return provider `401`, networking is basically working
- if failures still happen before provider response, keep investigating local process
  environment

## Recommended commands

### Inspect environment proxy variables

```cmd
cmd /c set | findstr /I proxy
```

### Inspect WinHTTP proxy

```powershell
netsh winhttp show proxy
```

### Inspect user Internet proxy

```powershell
Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' |
  Select-Object ProxyEnable,ProxyServer,AutoConfigURL
```

### Restart MoonAP server with the standard scripts

```cmd
tools\restart-moonap-server.cmd
```

### Health check

```powershell
Invoke-WebRequest -UseBasicParsing http://127.0.0.1:3000/api/health
```

## Final lesson

For MoonAP real LLM testing on Windows, there are now two distinct truths:

- `Simulated LLM GPT-5.4` is still the stable demo path and should be preserved
- real-provider testing is viable, but only if the local MoonAP server process is
  started in a sane networking environment

If `NVIDIA` and `ZAI` suddenly stop working while `Simulated GPT-5.4` still works,
the first question should now be:

`What environment did the current MoonAP server process inherit?`
