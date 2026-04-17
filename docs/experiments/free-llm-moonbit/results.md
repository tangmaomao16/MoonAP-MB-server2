# Free LLM models ability of generating MoonBit code

Last updated: 2026-04-16T15:54:43.158Z

## Current summary

| Provider | Model | API | API ms | L1 | L2 | L3 | Notes |
| --- | --- | --- | ---: | --- | --- | --- | --- |
| gemini | gemini-3-flash-preview | failed |  | not-run | not-run | not-run | Timed out after 8s |
| gemini | gemini-3.1-flash-lite-preview | failed |  | not-run | not-run | not-run | Timed out after 8s |
| gemini | gemini-2.5-flash | failed |  | not-run | not-run | not-run | Timed out after 8s |
| gemini | gemini-2.5-flash-lite | failed |  | not-run | not-run | not-run | Timed out after 8s |
| gemini | gemini-2-flash-lite | failed |  | not-run | not-run | not-run | Timed out after 8s |
| gemini | gemini-2-flash | failed |  | not-run | not-run | not-run | Timed out after 8s |
| zai | glm-5.1 | ok | 3524 | assist-pass (2 repairs) | assist-pass (1 repairs) | fail | Not yet reliable for MoonBit benchmark L3. |
| zai | glm-5-turbo | ok | 926 | fail | fail | fail | Not yet reliable for MoonBit benchmark L3. |
| zai | glm-5 | ok | 1163 | fail | fail | assist-pass (2 repairs) | Usable with compiler-guided repair. |
| zai | glm-4.7 | ok | 687 | fail | fail | fail | Not yet reliable for MoonBit benchmark L3. |
| zai | glm-4.7-flash | failed |  | not-run | not-run | not-run | Timed out after 8s |
| zai | glm-4.7-flashx | ok | 1956 | fail | fail | fail | Not yet reliable for MoonBit benchmark L3. |
| zai | glm-4-flashx-250414 | ok | 392 | fail | fail | fail | Not yet reliable for MoonBit benchmark L3. |
| zai | glm-4-long | ok | 502 | fail | fail | fail | Not yet reliable for MoonBit benchmark L3. |
| zai | glm-4.6 | ok | 655 | fail | fail | fail | Not yet reliable for MoonBit benchmark L3. |
| zai | glm-4.5-airx | ok | 485 | fail | fail | fail | Not yet reliable for MoonBit benchmark L3. |
| zai | glm-4.5-air | ok | 587 | fail | fail | fail | Not yet reliable for MoonBit benchmark L3. |
| nvidia | qwen/qwen2.5-coder-32b-instruct | ok | 414 | fail | fail | fail | Not yet reliable for MoonBit benchmark L3. |
| nvidia | meta/llama-4-maverick-17b-128e-instruct | ok | 517 | assist-pass (1 repairs) | assist-pass (1 repairs) | assist-pass (1 repairs) | Usable with compiler-guided repair. |
| nvidia | meta/llama-4-scout-17b-16e-instruct | failed |  | not-run | not-run | not-run | LLM request failed (410) |
| nvidia | meta/llama-3.3-70b-instruct | ok | 3178 | fail | fail | fail | Not yet reliable for MoonBit benchmark L3. |
| siliconflow | Qwen/Qwen2-7B-Instruct | failed |  | not-run | not-run | not-run | LLM request failed (403) |
| siliconflow | THUDM/glm-4-9b-chat | failed |  | not-run | not-run | not-run | LLM request failed (403) |
| siliconflow | internlm/internlm2_5-7b-chat | ok | 332 | fail | fail | fail | Not yet reliable for MoonBit benchmark L3. |
| siliconflow | mistralai/Mistral-7B-Instruct-v0.2 | failed |  | not-run | not-run | not-run | LLM request failed (403) |
| siliconflow | THUDM/chatglm3-6b | failed |  | not-run | not-run | not-run | LLM request failed (403) |
| siliconflow | deepseek-ai/DeepSeek-R1-Distill-Qwen-32B | ok | 903 | fail | fail | fail | Not yet reliable for MoonBit benchmark L3. |
| openrouter | qwen/qwen3-coder:free | failed |  | not-run | not-run | not-run | Provider returned error |
| openrouter | nvidia/nemotron-3-super-120b-a12b:free | ok | 1881 | fail | assist-pass (1 repairs) | fail | Not yet reliable for MoonBit benchmark L3. |
| openrouter | openrouter/free | ok | 6268 | fail | fail | fail | Not yet reliable for MoonBit benchmark L3. |
| openrouter | openrouter/auto | ok | 3804 | fail | fail | fail | Not yet reliable for MoonBit benchmark L3. |

## Raw JSON

See `artifacts/moonbit-eval-results.json` for the full structured record.