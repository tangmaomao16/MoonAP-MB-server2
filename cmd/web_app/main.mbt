///|
#cfg(target="js")
extern "js" fn browser_append_message(role : String, text : String) -> Unit =
  #| (role, text) => {
  #|   const messages = document.querySelector("#messages");
  #|   const item = document.createElement("article");
  #|   item.className = `message ${role}`;
  #|   item.textContent = String(text);
  #|   messages?.append(item);
  #| }

///|
#cfg(target="js")
extern "js" fn browser_set_state(text : String) -> Unit =
  #| (text) => {
  #|   const state = document.querySelector("#state");
  #|   if (state) state.textContent = String(text);
  #| }

///|
#cfg(target="js")
extern "js" fn browser_append_runtime_log(
  kind : String,
  label : String,
  text : String,
) -> Unit =
  #| (kind, label, text) => {
  #|   const payload = JSON.stringify({
  #|     ts: new Date().toISOString(),
  #|     kind: String(kind || "event"),
  #|     label: String(label || ""),
  #|     text: String(text || "")
  #|   }) + "\n";
  #|   fetch("/api/logs/moonap-runtime.log", {
  #|     method: "POST",
  #|     headers: { "Content-Type": "text/plain; charset=utf-8" },
  #|     body: payload,
  #|     keepalive: true
  #|   }).catch(() => {});
  #| }

///|
#cfg(target="js")
extern "js" fn browser_extract_moonbit_source(raw : String) -> String =
  #| (raw) => {
  #|   if (!globalThis.__moonapExtractMoonBitSource) {
  #|     globalThis.__moonapExtractMoonBitSource = (value) => {
  #|       const text = String(value || "").trim();
  #|       if (!text) return "";
  #|       const extract = (source, startMarker, endMarker) => {
  #|         const start = source.indexOf(startMarker);
  #|         if (start < 0) return "";
  #|         const after = source.slice(start + startMarker.length).trim();
  #|         if (!after) return "";
  #|         const end = after.indexOf(endMarker);
  #|         if (end < 0) return "";
  #|         return after.slice(0, end).trim();
  #|       };
  #|       const patterns = [
  #|         ["FILE: cmd/main/main.mbt", "END_FILE"],
  #|         ['<moonbit-file path="cmd/main/main.mbt">', "</moonbit-file>"],
  #|         ["```moonbit", "```"],
  #|         ["```mbt", "```"],
  #|         ["```", "```"]
  #|       ];
  #|       for (const [startMarker, endMarker] of patterns) {
  #|         const extracted = extract(text, startMarker, endMarker);
  #|         if (extracted) return extracted;
  #|       }
  #|       return text;
  #|     };
  #|   }
  #|   return globalThis.__moonapExtractMoonBitSource(raw);
  #| }

///|
#cfg(target="js")
extern "js" fn browser_render_artifact_card(
  title : String,
  summary : String,
  meta_json : String,
  allow_compile : Bool,
  allow_repair : Bool,
  allow_save : Bool,
) -> Unit =
  #| (title, summary, metaJson, allowCompile, allowRepair, allowSave) => {
  #|   const root = document.querySelector("#artifactActions");
  #|   if (!root) return;
  #|   const runtimeRequest = globalThis.__moonapLastRuntimeRequest || {};
  #|   const runtimeResult = globalThis.__moonapLastRuntimeResult || {};
  #|   const showTransient = globalThis.__moonapAllowTransientArtifactCard === true;
  #|   if (globalThis.__moonapMinimalShell !== false && !showTransient) {
  #|     root.innerHTML = "";
  #|     root.style.display = "none";
  #|     return;
  #|   }
  #|   let meta = [];
  #|   try {
  #|     const parsed = JSON.parse(String(metaJson || "[]"));
  #|     meta = Array.isArray(parsed) ? parsed : [];
  #|   } catch {
  #|     meta = [];
  #|   }
  #|   root.innerHTML = "";
  #|   root.style.display = "";
  #|   const card = document.createElement("section");
  #|   card.className = "action-card is-open";
  #|   const metaHtml = meta.map((item) => `<span>${String(item)}</span>`).join("");
  #|   const wasmUrl = String(runtimeRequest?.wasm_url || "");
  #|   const sourceUrl = String(runtimeRequest?.source_url || "");
  #|   const compileReportUrl = String(runtimeRequest?.compile_report_url || "");
  #|   const resultUrl = String(runtimeResult?.download_url || "");
  #|   const requestId = String(runtimeRequest?.request_id || "");
  #|   const runtimeReady = String(runtimeRequest?.status || "") === "ready-for-runtime";
  #|   const runtimeDone = String(runtimeResult?.request_id || "") === requestId && String(runtimeResult?.status || "").includes("succeeded");
  #|   const runtimeCard = runtimeReady || runtimeDone;
  #|   if (runtimeCard) {
  #|     card.className += runtimeDone ? " action-card-runtime is-complete" : " action-card-runtime is-awaiting";
  #|     const runtimeUi = runtimeRequest?.runtime_ui && typeof runtimeRequest.runtime_ui === "object" ? runtimeRequest.runtime_ui : {};
  #|     const runtimeFields = Array.isArray(runtimeUi.fields) ? runtimeUi.fields : [];
  #|     const taskKind = String(runtimeRequest?.task_kind || "");
  #|     const isFastqRuntime = taskKind === "fastq-generator";
  #|     const eyebrow = runtimeDone ? "Runtime result" : "Runtime ready";
  #|     const statusHtml = runtimeDone
  #|       ? '<span>result recorded</span><span>ready to save</span>'
  #|       : '<span>wasm prepared</span><span>awaiting local execution</span>';
  #|     const paramsHtml = runtimeReady && !runtimeDone && runtimeFields.length
  #|       ? `<div class="action-card-params">${runtimeFields.map((field) => {
  #|           const name = String(field?.name || "");
  #|           const label = String(field?.label || name || "Parameter");
  #|           const type = String(field?.type || "text");
  #|           const inputType = type === "int" || type === "float" ? "number" : "text";
  #|           const attrs = [
  #|             `id="runtime-field-${name}"`,
  #|             `data-runtime-field="${name}"`,
  #|             `type="${inputType}"`,
  #|             field?.min !== undefined ? `min="${String(field.min)}"` : "",
  #|             field?.max !== undefined ? `max="${String(field.max)}"` : "",
  #|             field?.step !== undefined ? `step="${String(field.step)}"` : "",
  #|             `value="${String(field?.default ?? "")}"`
  #|           ].filter(Boolean).join(" ");
  #|           return `<label><span>${label}</span><input ${attrs} /></label>`;
  #|         }).join("")}</div>`
  #|       : "";
  #|     const primaryAction = runtimeDone
  #|       ? (allowSave ? '<button id="savePersonalSkill" class="primary" type="button">Save to Personal-SKILL-Set</button>' : '')
  #|       : `<button id="recordDemoRuntimeResult" class="primary" type="button">${String(runtimeUi?.primary_action_label || "Run runtime step")}</button>`;
  #|     const secondaryActions = [
  #|       wasmUrl ? '<button id="downloadRuntimeWasm" class="secondary" type="button">Download wasm</button>' : '',
  #|       sourceUrl ? '<button id="downloadRuntimeSource" class="secondary" type="button">Download source</button>' : '',
  #|       resultUrl ? '<button id="downloadRuntimeResult" class="secondary" type="button">Download result</button>' : ''
  #|     ].filter(Boolean).join("");
  #|     card.innerHTML = `
  #|       <div class="action-card-eyebrow">${eyebrow}</div>
  #|       <strong>${String(title)}</strong>
  #|       <small>${String(summary)}</small>
  #|       <div class="action-card-status">${statusHtml}</div>
  #|       ${paramsHtml}
  #|       <div class="action-card-primary">${primaryAction}</div>
  #|       ${secondaryActions ? `<div class="action-card-secondary">${secondaryActions}</div>` : ''}`;
  #|   } else {
  #|     card.innerHTML = `
  #|       <strong>${String(title)}</strong>
  #|       <small>${String(summary)}</small>
  #|       ${metaHtml ? `<div class="action-card-meta">${metaHtml}</div>` : ''}
  #|       <div class="action-card-actions">
  #|         ${allowCompile ? '<button id="compileArtifact" type="button">Run Compile Probe</button>' : ''}
  #|         ${allowRepair ? '<button id="repairArtifact" type="button">Repair with Error Summary</button>' : ''}
  #|         ${allowSave ? '<button id="savePersonalSkill" type="button">Save to Personal-SKILL-Set</button>' : ''}
  #|         ${runtimeReady && !runtimeDone ? '<button id="recordDemoRuntimeResult" type="button">Record Demo Result</button>' : ''}
  #|         ${wasmUrl ? '<button id="downloadRuntimeWasm" class="secondary" type="button">Download wasm</button>' : ''}
  #|         ${sourceUrl ? '<button id="downloadRuntimeSource" class="secondary" type="button">Download source</button>' : ''}
  #|         ${compileReportUrl ? '<button id="downloadCompileReport" class="secondary" type="button">Download compile report</button>' : ''}
  #|         ${resultUrl ? '<button id="downloadRuntimeResult" class="secondary" type="button">Download result</button>' : ''}
  #|         <button id="exportSkillBundle" class="secondary" type="button">Export Source Bundle</button>
  #|       </div>`;
  #|   }
  #|   root.append(card);
  #| }

///|
#cfg(target="js")
extern "js" fn browser_clear_artifact_card() -> Unit =
  #| () => {
  #|   const root = document.querySelector("#artifactActions");
  #|   if (root) {
  #|     root.innerHTML = "";
  #|     if (globalThis.__moonapMinimalShell !== false) root.style.display = "none";
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_set_transient_artifact_card(open : Bool) -> Unit =
  #| (open) => {
  #|   globalThis.__moonapAllowTransientArtifactCard = Boolean(open);
  #|   const root = document.querySelector("#artifactActions");
  #|   if (!root) return;
  #|   if (!open && globalThis.__moonapMinimalShell !== false) {
  #|     root.style.display = "none";
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_download_runtime_artifact(kind : String) -> Unit =
  #| (kind) => {
  #|   const runtimeRequest = globalThis.__moonapLastRuntimeRequest || {};
  #|   const runtimeResult = globalThis.__moonapLastRuntimeResult || {};
  #|   const url = kind === "wasm"
  #|     ? String(runtimeRequest?.wasm_url || "")
  #|     : kind === "source"
  #|       ? String(runtimeRequest?.source_url || "")
  #|       : kind === "compile-report"
  #|         ? String(runtimeRequest?.compile_report_url || "")
  #|         : String(runtimeResult?.download_url || "");
  #|   if (!url) {
  #|     throw new Error(`No runtime artifact URL is available for ${String(kind)}.`);
  #|   }
  #|   const link = document.createElement("a");
  #|   link.href = url;
  #|   link.download = "";
  #|   document.body.append(link);
  #|   link.click();
  #|   link.remove();
  #| }

///|
#cfg(target="js")
extern "js" fn browser_record_demo_runtime_result(
  on_done : (String) -> Unit,
  on_error : (String) -> Unit,
) -> Unit =
  #| async (onDone, onError) => {
  #|   try {
  #|     const runtimeRequest = globalThis.__moonapLastRuntimeRequest;
  #|     if (!runtimeRequest || typeof runtimeRequest !== "object") {
  #|       throw new Error("No runtime request is available yet.");
  #|     }
  #|     const requestId = String(runtimeRequest.request_id || "");
  #|     if (!requestId) throw new Error("MoonAP runtime request_id is missing.");
  #|     const sourceUrl = String(runtimeRequest.source_url || "");
  #|     const wasmUrl = String(runtimeRequest.wasm_url || "");
  #|     const taskKind = String(runtimeRequest.task_kind || "");
  #|     const runtimeUi = runtimeRequest?.runtime_ui && typeof runtimeRequest.runtime_ui === "object" ? runtimeRequest.runtime_ui : {};
  #|     const runtimeFields = Array.isArray(runtimeUi.fields) ? runtimeUi.fields : [];
  #|     const runtimeInputs = {};
  #|     for (const field of runtimeFields) {
  #|       const name = String(field?.name || "");
  #|       if (!name) continue;
  #|       const type = String(field?.type || "text");
  #|       const fallback = field?.default;
  #|       const raw = document.querySelector(`#runtime-field-${name}`)?.value;
  #|       const text = String(raw ?? fallback ?? "");
  #|       runtimeInputs[name] = type === "int"
  #|         ? Number.parseInt(text, 10)
  #|         : type === "float"
  #|           ? Number.parseFloat(text)
  #|           : text;
  #|     }
  #|     const isFastqRuntime = taskKind === "fastq-generator";
  #|     let payload;
  #|     if (isFastqRuntime) {
  #|       const readCount = Math.max(1, Math.min(1000000, Number(runtimeInputs.read_count) || 10000));
  #|       const readLength = Math.max(1, Math.min(10000, Number(runtimeInputs.read_length) || 150));
  #|       const nRate = Math.max(0, Math.min(1, Number(runtimeInputs.n_rate) || 0.01));
  #|       const originalSeed = Number(runtimeInputs.random_seed) || 42;
  #|       let seed = originalSeed;
  #|       const bases = ["A", "C", "G", "T"];
  #|       const rand = () => {
  #|         seed = (seed * 1664525 + 1013904223) >>> 0;
  #|         return seed / 4294967296;
  #|       };
  #|       const chunks = [];
  #|       let nCount = 0;
  #|       let totalBases = 0;
  #|       for (let read = 0; read < readCount; read += 1) {
  #|         let seq = "";
  #|         for (let i = 0; i < readLength; i += 1) {
  #|           totalBases += 1;
  #|           if (rand() < nRate) {
  #|             seq += "N";
  #|             nCount += 1;
  #|           } else {
  #|             seq += bases[Math.floor(rand() * bases.length)];
  #|           }
  #|         }
  #|         chunks.push(`@moonap_${read}\n${seq}\n+\n${"I".repeat(readLength)}\n`);
  #|       }
  #|       const blob = new Blob(chunks, { type: "text/plain;charset=utf-8" });
  #|       const url = URL.createObjectURL(blob);
  #|       const link = document.createElement("a");
  #|       link.href = url;
  #|       link.download = "moonap-demo.fastq";
  #|       document.body.append(link);
  #|       link.click();
  #|       link.remove();
  #|       setTimeout(() => URL.revokeObjectURL(url), 1000);
  #|       payload = {
  #|         run_id: String(runtimeRequest.run_id || ""),
  #|         request_id: requestId,
  #|         status: "runtime-succeeded",
  #|         result_kind: "fastq-file",
  #|         runtime_inputs: runtimeInputs,
  #|         summary: `Generated moonap-demo.fastq with ${readCount} reads of length ${readLength}.`,
  #|         display_text: `FastQ file generated and downloaded in the browser.\nread_count=${readCount}\nread_length=${readLength}\nn_rate=${nRate}\nrandom_seed=${originalSeed}\nexpected_n_count=${nCount}\ntotal_bases=${totalBases}`,
  #|         stdout_text: `Browser-local FastQ generation completed for ${requestId}.`,
  #|         download_name: "",
  #|         download_content: "",
  #|         accepted_for_skill: false
  #|       };
  #|     } else {
  #|       payload = {
  #|         run_id: String(runtimeRequest.run_id || ""),
  #|         request_id: requestId,
  #|         status: "runtime-succeeded",
  #|         result_kind: "text",
  #|         runtime_inputs: runtimeInputs,
  #|         summary: "MoonAP recorded a browser-side demo runtime result for the compiled wasm artifact.",
  #|         display_text: `Demo runtime result recorded for ${requestId}. Source URL: ${sourceUrl || "n/a"}. wasm URL: ${wasmUrl || "n/a"}.`,
  #|         stdout_text: "Demo runtime result recorded from the browser placeholder executor.",
  #|         download_name: "runtime-preview.txt",
  #|         download_content: `MoonAP demo runtime result\nrequest_id: ${requestId}\nsource_url: ${sourceUrl}\nwasm_url: ${wasmUrl}\n`,
  #|         accepted_for_skill: false
  #|       };
  #|     }
  #|     const response = await fetch("/api/task/execute", {
  #|       method: "POST",
  #|       headers: { "Content-Type": "application/json; charset=utf-8" },
  #|       body: JSON.stringify(payload)
  #|     });
  #|     const text = await response.text();
  #|     if (!response.ok) throw new Error(text || `Runtime execute failed (${response.status})`);
  #|     onDone(String(text));
  #|   } catch (error) {
  #|     onError(error instanceof Error ? error.message : String(error));
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_register_runtime_ready(
  on_done : (String) -> Unit,
  on_error : (String) -> Unit,
) -> Unit =
  #| async (onDone, onError) => {
  #|   try {
  #|     const artifact = globalThis.__moonapLastArtifact;
  #|     const compileReport = globalThis.__moonapLastCompileReport;
  #|     const source = String(artifact?.moonbit_source || "");
  #|     if (!source.trim()) throw new Error("No captured MoonBit source is available for runtime registration.");
  #|     if (!compileReport || typeof compileReport !== "object" || compileReport.ok !== true) {
  #|       throw new Error("MoonAP runtime registration requires a successful compile report.");
  #|     }
  #|     const requestStage = artifact?.quality_assessment_used
  #|       ? "quality-repair"
  #|       : artifact?.compile_summary_used
  #|         ? "compile-repair"
  #|         : "browser-direct";
  #|     const envelope = [
  #|       `TASK_TITLE\t${String(artifact?.name || "MoonBit task")}`,
  #|       `ORIGINAL_PROMPT\t${String(artifact?.prompt || "")}`,
  #|       `LLM_PROVIDER\t${String(artifact?.llm_provider || "")}`,
  #|       `LLM_MODEL\t${String(artifact?.llm_model || "")}`,
  #|       `REQUEST_STAGE\t${String(requestStage)}`,
  #|       `COMPILE_OK\t${String(Boolean(compileReport.ok))}`,
  #|       `WASM_PATH\t${String(compileReport.wasm_path || "")}`,
  #|       "SOURCE_BEGIN",
  #|       source,
  #|       "SOURCE_END",
  #|       "COMPILE_REPORT_BEGIN",
  #|       JSON.stringify(compileReport, null, 2),
  #|       "COMPILE_REPORT_END",
  #|       "RAW_RESPONSE_BEGIN",
  #|       String(artifact?.llm_response_preview || ""),
  #|       "RAW_RESPONSE_END"
  #|     ].join("\n");
  #|     fetch("/api/logs/moonap-runtime.log", {
  #|       method: "POST",
  #|       headers: { "Content-Type": "text/plain; charset=utf-8" },
  #|       body: JSON.stringify({
  #|         ts: new Date().toISOString(),
  #|         kind: "runtime-exec",
  #|         label: "runtime-request-register-attempt",
  #|         text: String(artifact?.prompt || "")
  #|       }) + "\n",
  #|       keepalive: true
  #|     }).catch(() => {});
  #|     const response = await fetch("/api/runtime-exec/register-ready", {
  #|       method: "POST",
  #|       headers: { "Content-Type": "text/plain; charset=utf-8" },
  #|       body: envelope
  #|     });
  #|     const text = await response.text();
  #|     if (!response.ok) throw new Error(text || `Runtime registration failed (${response.status})`);
  #|     fetch("/api/logs/moonap-runtime.log", {
  #|       method: "POST",
  #|       headers: { "Content-Type": "text/plain; charset=utf-8" },
  #|       body: JSON.stringify({
  #|         ts: new Date().toISOString(),
  #|         kind: "runtime-exec",
  #|         label: "runtime-request-register-succeeded",
  #|         text: String(text || "")
  #|       }) + "\n",
  #|       keepalive: true
  #|     }).catch(() => {});
  #|     onDone(String(text));
  #|   } catch (error) {
  #|     fetch("/api/logs/moonap-runtime.log", {
  #|       method: "POST",
  #|       headers: { "Content-Type": "text/plain; charset=utf-8" },
  #|       body: JSON.stringify({
  #|         ts: new Date().toISOString(),
  #|         kind: "runtime-exec",
  #|         label: "runtime-request-register-failed",
  #|         text: String(error instanceof Error ? error.message : String(error))
  #|       }) + "\n",
  #|       keepalive: true
  #|     }).catch(() => {});
  #|     onError(error instanceof Error ? error.message : String(error));
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_store_compile_report(raw : String) -> Unit =
  #| (raw) => {
  #|   try {
  #|     globalThis.__moonapLastCompileReport = JSON.parse(String(raw));
  #|   } catch {
  #|     globalThis.__moonapLastCompileReport = String(raw);
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_reset_compile_report() -> Unit =
  #| () => {
  #|   globalThis.__moonapLastCompileReport = null;
  #| }

///|
#cfg(target="js")
extern "js" fn browser_assess_last_benchmark() -> String =
  #| () => {
  #|   const artifact = globalThis.__moonapLastArtifact;
  #|   const source = String(artifact?.moonbit_source || "");
  #|   const name = String(artifact?.name || "");
  #|   const prompt = String(artifact?.prompt || "");
  #|   const combined = `${name}\n${prompt}`;
  #|   const lowerCombined = combined.toLowerCase();
  #|   const levelMatch = combined.match(/Benchmark Level\s+([1-5])/i);
  #|   const level = levelMatch ? Number(levelMatch[1]) : 0;
  #|   const fnNames = Array.from(source.matchAll(/\bfn\s+([A-Za-z_][A-Za-z0-9_]*)/g)).map((item) => String(item[1] || ""));
  #|   const helperNames = fnNames.filter((item) => item !== "main");
  #|   const lower = source.toLowerCase();
  #|   const hasImport = /\bimport\b/.test(lower);
  #|   const hasHelloMoonbit = /hello moonbit/.test(lower);
  #|   const hasABC = /abc/.test(source);
  #|   const hasControlFlow = /\bif\b|\bmatch\b|\bfor\b|\bwhile\b/.test(source);
  #|   const hasRandomness = /\brandom\b|\bseed\b|\blcg\b|\brand_/.test(lower);
  #|   const hasMain = /\bfn\s+main\b/.test(source);
  #|   const isFastqMoonbitTask = lowerCombined.includes("fastq") && lowerCombined.includes("moonbit") && (lowerCombined.includes("generator") || lowerCombined.includes("synthetic read"));
  #|   const hasFastqHeader = source.includes("@SEQ") || source.includes("@moonap") || source.includes("\"@\"");
  #|   const hasFastqPlus = source.includes("\\n+\\n") || source.includes("\"+\"") || source.includes("+\\n");
  #|   const hasQuality = source.includes("IIII") || source.includes("qual");
  #|   const hasSequenceLogic = /A|C|G|T|N/.test(source) && (hasControlFlow || helperNames.length > 0);
  #|   const missingSignals = [];
  #|   const preserveConstraints = ["keep the original task goal", "keep the source import-free when possible", "return only cmd/main/main.mbt", "preserve wasm-gc compatibility"];
  #|   const result = {
  #|     applicable: level > 0 || isFastqMoonbitTask,
  #|     assessment_kind: "system-assessment",
  #|     task_kind: level > 0 ? `benchmark-l${level}` : (isFastqMoonbitTask ? "fastq-generator" : "general-moonbit"),
  #|     level: level,
  #|     pass: false,
  #|     title: "Compile probe succeeded",
  #|     summary: "MoonAP used the native MoonBit toolchain on this machine and produced a real wasm-gc artifact. Browser-local runtime execution is the next implementation step.",
  #|     meta_json: JSON.stringify(["compile probe ok", "real wasm built", "runtime pending"]),
  #|     missing_signals_json: "[]",
  #|     preserve_constraints_json: JSON.stringify(preserveConstraints),
  #|     repair_hint: "Keep the task intent intact while improving the machine-checkable task structure."
  #|   };
  #|   if (level === 1) {
  #|     if (!hasMain) missingSignals.push("define exactly one fn main");
  #|     if (hasImport) missingSignals.push("remove import usage");
  #|     if (!hasHelloMoonbit) missingSignals.push("return text containing hello moonbit");
  #|     if (helperNames.length !== 0) missingSignals.push("avoid helper functions for Benchmark L1");
  #|     const pass = hasMain && !hasImport && hasHelloMoonbit && helperNames.length === 0;
  #|     result.pass = pass;
  #|     result.title = pass ? "Benchmark L1 passed" : "Compile succeeded, but Benchmark L1 failed";
  #|     result.summary = pass
  #|       ? "Compile succeeded and the generated MoonBit source matches the Level 1 checks: one main function, no imports, no helper functions, and hello moonbit is returned."
  #|       : "Compile succeeded, but the generated source does not fully match Level 1. MoonAP expected one main function, no imports, no helpers, and a return value containing hello moonbit.";
  #|     result.meta_json = JSON.stringify(pass
  #|       ? ["benchmark l1", "compile ok", "quality pass"]
  #|       : ["benchmark l1", "compile ok", "quality failed"]);
  #|     result.repair_hint = "Benchmark L1 should be a single-file MoonBit program with one main function, no imports, no helpers, and a return value that visibly contains hello moonbit.";
  #|   } else if (level === 2) {
  #|     const helper = helperNames.length === 1 ? helperNames[0] : "";
  #|     const mainCallsHelper = helper !== "" && source.includes(`${helper}(`);
  #|     if (!hasMain) missingSignals.push("define fn main");
  #|     if (hasImport) missingSignals.push("remove import usage");
  #|     if (!hasHelloMoonbit) missingSignals.push("return text containing hello moonbit");
  #|     if (helperNames.length !== 1) missingSignals.push("define exactly one helper function");
  #|     if (!mainCallsHelper) missingSignals.push("have main call the helper function");
  #|     const pass = hasMain && !hasImport && hasHelloMoonbit && helperNames.length === 1 && mainCallsHelper;
  #|     result.pass = pass;
  #|     result.title = pass ? "Benchmark L2 passed" : "Compile succeeded, but Benchmark L2 failed";
  #|     result.summary = pass
  #|       ? "Compile succeeded and the generated MoonBit source matches the Level 2 checks: exactly one helper function returns hello moonbit and main calls that helper."
  #|       : "Compile succeeded, but the generated source does not fully match Level 2. MoonAP expected exactly one helper function, no imports, hello moonbit, and main calling the helper.";
  #|     result.meta_json = JSON.stringify(pass
  #|       ? ["benchmark l2", "compile ok", "quality pass"]
  #|       : ["benchmark l2", "compile ok", "quality failed"]);
  #|     result.repair_hint = "Benchmark L2 should keep one helper function that produces hello moonbit, with main delegating to that helper and no imports.";
  #|   } else if (level === 3) {
  #|     if (!hasMain) missingSignals.push("define fn main");
  #|     if (hasImport) missingSignals.push("remove import usage");
  #|     if (!hasABC) missingSignals.push("return text containing ABC");
  #|     if (!hasControlFlow) missingSignals.push("include simple control flow");
  #|     if (hasRandomness) missingSignals.push("remove randomness");
  #|     const pass = hasMain && !hasImport && hasABC && hasControlFlow && !hasRandomness;
  #|     result.pass = pass;
  #|     result.title = pass ? "Benchmark L3 passed" : "Compile succeeded, but Benchmark L3 failed";
  #|     result.summary = pass
  #|       ? "Compile succeeded and the generated MoonBit source matches the Level 3 checks: main returns ABC, uses simple control flow, and avoids imports or randomness."
  #|       : "Compile succeeded, but the generated source does not fully match Level 3. MoonAP expected main to return ABC using simple control flow, with no imports or randomness.";
  #|     result.meta_json = JSON.stringify(pass
  #|       ? ["benchmark l3", "compile ok", "quality pass"]
  #|       : ["benchmark l3", "compile ok", "quality failed"]);
  #|     result.repair_hint = "Benchmark L3 should visibly implement ABC with deterministic control flow and no imports or randomness.";
  #|   } else if (isFastqMoonbitTask) {
  #|     if (!hasMain) missingSignals.push("define fn main");
  #|     if (hasImport) missingSignals.push("remove import usage");
  #|     if (!hasFastqHeader) missingSignals.push("emit a visible FastQ header such as @SEQ or @moonap");
  #|     if (!hasFastqPlus) missingSignals.push("emit a plus line between sequence and quality");
  #|     if (!hasQuality) missingSignals.push("generate an explicit quality string such as IIII or qual");
  #|     if (!hasSequenceLogic) missingSignals.push("include visible sequence-generation logic over A/C/G/T/N");
  #|     const pass = hasMain && !hasImport && hasFastqHeader && hasFastqPlus && hasQuality && hasSequenceLogic;
  #|     result.pass = pass;
  #|     result.title = pass ? "FastQ Generator task passed" : "Compile succeeded, but FastQ Generator task failed";
  #|     result.summary = pass
  #|       ? "Compile succeeded and the generated MoonBit source shows the expected FastQ structure: a header, sequence logic, plus line, and quality generation without imports."
  #|       : "Compile succeeded, but the generated MoonBit source does not yet look like a usable FastQ generator. MoonAP expected visible FastQ structure, sequence-generation logic, and a quality line without imports.";
  #|     result.meta_json = JSON.stringify(pass
  #|       ? ["fastq generator", "compile ok", "quality pass"]
  #|       : ["fastq generator", "compile ok", "quality failed"]);
  #|     result.repair_hint = "Keep the program compiling, but make the MoonBit source visibly look like a FastQ generator with header, sequence, plus line, and quality generation.";
  #|   }
  #|   result.missing_signals_json = JSON.stringify(missingSignals);
  #|   return JSON.stringify(result);
  #| }

///|
#cfg(target="js")
extern "js" fn browser_set_benchmark_assessment(raw : String) -> Unit =
  #| (raw) => {
  #|   globalThis.__moonapBenchmarkAssessment = String(raw || "");
  #| }

///|
#cfg(target="js")
extern "js" fn browser_repair_last_artifact_with_system_assessment(
  knowledge_pack : String,
  on_done : (String) -> Unit,
  on_error : (String) -> Unit,
) -> Unit =
  #| async (knowledgePack, onDone, onError) => {
  #|   try {
  #|     const artifact = globalThis.__moonapLastArtifact;
  #|     const source = String(artifact?.moonbit_source || "");
  #|     if (!source.trim()) throw new Error("No captured MoonBit source is available for quality repair.");
  #|     let assessment = {};
  #|     try {
  #|       assessment = JSON.parse(String(globalThis.__moonapBenchmarkAssessment || "{}"));
  #|     } catch {
  #|       assessment = {};
  #|     }
  #|     if (!assessment || typeof assessment !== "object") throw new Error("No system assessment is available yet.");
  #|     const readRouter = () => {
  #|       try {
  #|         const parsed = JSON.parse(localStorage.getItem("moonap.llm.router.v1") || "{}");
  #|         return parsed && typeof parsed === "object" ? parsed : {};
  #|       } catch {
  #|         return {};
  #|       }
  #|     };
  #|     const saved = readRouter();
  #|     const providers = Array.isArray(saved.providers) ? saved.providers.filter((item) => item.enabled && String(item.apiKey || "").trim() !== "" && String(item.test_status || "") !== "failed") : [];
  #|     if (providers.length === 0) throw new Error("No enabled LLM provider is available in the router.");
  #|     const cursor = Number.isFinite(saved.cursor) ? saved.cursor : 0;
  #|     const start = ((cursor % providers.length) + providers.length) % providers.length;
  #|     const ordered = providers.slice(start).concat(providers.slice(0, start));
  #|     const proxyPost = async (url, headers, body) => {
  #|       const envelope = [
  #|         `URL\t${String(url)}`,
  #|         ...Object.entries(headers || {}).map(([key, value]) => `HEADER\t${String(key)}\t${String(value).replace(/\r?\n/g, " ")}`),
  #|         "BODY",
  #|         String(body)
  #|       ].join("\n");
  #|       const response = await fetch("/api/llm/proxy", {
  #|         method: "POST",
  #|         headers: { "Content-Type": "text/plain; charset=utf-8" },
  #|         body: envelope
  #|       });
  #|       const text = await response.text();
  #|       let json = {};
  #|       try {
  #|         json = JSON.parse(text);
  #|       } catch {
  #|         const plain = String(text || "")
  #|           .replace(/<script[\s\S]*?<\/script>/gi, " ")
  #|           .replace(/<style[\s\S]*?<\/style>/gi, " ")
  #|           .replace(/<[^>]+>/g, " ")
  #|           .replace(/\s+/g, " ")
  #|           .trim();
  #|         const summarized = plain || `MoonAP proxy returned non-JSON (${response.status})`;
  #|         throw new Error(`Provider returned non-JSON (${response.status}): ${summarized.slice(0, 240)}`);
  #|       }
  #|       if (!response.ok) {
  #|         const detail = json?.error?.detail ? ` ${String(json.error.detail)}` : "";
  #|         throw new Error((json?.error?.message || `LLM request failed (${response.status})`) + detail);
  #|       }
  #|       return json;
  #|     };
  #|     const updatePrompts = (modeText, systemPromptText, userPromptText) => {
  #|       const setText = (selector, value) => {
  #|         const node = document.querySelector(selector);
  #|         if (node) node.textContent = String(value);
  #|       };
  #|       setText("#promptMode", modeText || "No LLM prompt captured yet.");
  #|       setText("#promptSystem", systemPromptText || "No LLM prompt captured yet.");
  #|       setText("#promptUser", userPromptText || "No LLM prompt captured yet.");
  #|     };
  #|     let missingSignals = [];
  #|     let preserveConstraints = [];
  #|     try { missingSignals = JSON.parse(String(assessment?.missing_signals_json || "[]")); } catch {}
  #|     try { preserveConstraints = JSON.parse(String(assessment?.preserve_constraints_json || "[]")); } catch {}
  #|     const originalTask = String(artifact?.prompt || "Generate MoonBit code for the requested task.");
  #|     const buildQualityRepairPrompts = (llm) => {
  #|       const modelName = String(llm?.model || "");
  #|       const isGpt54 = modelName.toLowerCase().includes("gpt-5.4");
  #|       if (isGpt54) {
  #|         const systemPrompt = [
  #|           "You are an AI coder.",
  #|           "You only write MoonBit code.",
  #|           "Your job is to improve MoonBit code for the user's task after compile already succeeded.",
  #|           "Return only the full contents of cmd/main/main.mbt."
  #|         ].join("\\n");
  #|         const userPrompt = [
  #|           `Original task: ${originalTask}`,
  #|           "",
  #|           "System assessment:",
  #|           `- task_kind: ${String(assessment?.task_kind || "general-moonbit")}`,
  #|           `- title: ${String(assessment?.title || "System assessment failed")}`,
  #|           `- summary: ${String(assessment?.summary || "")}`,
  #|           `- repair_hint: ${String(assessment?.repair_hint || "")}`,
  #|           "",
  #|           "Missing signals:",
  #|           ...(Array.isArray(missingSignals) && missingSignals.length > 0 ? missingSignals.map((item) => `- ${String(item)}`) : ["- none listed; improve conservatively"]),
  #|           "",
  #|           "Constraints to preserve:",
  #|           ...(Array.isArray(preserveConstraints) && preserveConstraints.length > 0 ? preserveConstraints.map((item) => `- ${String(item)}`) : ["- preserve the original task goal", "- keep wasm-gc compatibility"]),
  #|           "",
  #|           "Current source:",
  #|           source,
  #|           "",
  #|           "Revise the source so it still compiles and better satisfies the system assessment.",
  #|           "Return the full corrected cmd/main/main.mbt file and nothing else."
  #|         ].join("\\n");
  #|         return {
  #|           modeText: "quality-repair / frontier-direct",
  #|           systemPrompt,
  #|           userPrompt
  #|         };
  #|       }
  #|       const systemPrompt = [
  #|         "You are improving MoonBit code for MoonAP after the native compile probe already succeeded.",
  #|         "Target language: MoonBit 0.9.",
  #|         "Return ONLY the revised contents of cmd/main/main.mbt.",
  #|         "Do NOT return markdown fences, explanations, bullet lists, moon.pkg, or moon.mod.json.",
  #|         "Any non-code text is a failed repair.",
  #|         "Preserve compilability under wasm-gc while improving the task-specific quality signals.",
  #|         "Preserve the original task goal."
  #|       ].join("\\n");
  #|       const userPrompt = [
  #|         "Read this MoonBit 0.9 primer first and follow it strictly:",
  #|         String(knowledgePack || ""),
  #|         "",
  #|         `Original task: ${originalTask}`,
  #|         "",
  #|         "System assessment after a successful compile:",
  #|         `- task_kind: ${String(assessment?.task_kind || "general-moonbit")}`,
  #|         `- title: ${String(assessment?.title || "System assessment failed")}`,
  #|         `- summary: ${String(assessment?.summary || "")}`,
  #|         `- repair_hint: ${String(assessment?.repair_hint || "")}`,
  #|         "",
  #|         "Machine-detected missing signals:",
  #|         ...(Array.isArray(missingSignals) && missingSignals.length > 0 ? missingSignals.map((item) => `- ${String(item)}`) : ["- none listed; improve task structure conservatively"]),
  #|         "",
  #|         "Constraints to preserve:",
  #|         ...(Array.isArray(preserveConstraints) && preserveConstraints.length > 0 ? preserveConstraints.map((item) => `- ${String(item)}`) : ["- preserve the original task goal", "- keep wasm-gc compatibility"]),
  #|         "",
  #|         "Current source:",
  #|         source,
  #|         "",
  #|         "Please revise the source so it still compiles and better satisfies the system assessment.",
  #|         "Return the full corrected cmd/main/main.mbt file and nothing else."
  #|       ].join("\\n");
  #|       return {
  #|         modeText: "quality-repair / full",
  #|         systemPrompt,
  #|         userPrompt
  #|       };
  #|     };
  #|     const requestJson = async (llm) => {
  #|       const promptPack = buildQualityRepairPrompts(llm);
  #|       const systemPrompt = promptPack.systemPrompt;
  #|       const userPrompt = promptPack.userPrompt;
  #|       updatePrompts(promptPack.modeText, systemPrompt, userPrompt);
  #|       if (llm.provider === "gemini") {
  #|         const url = `${llm.baseUrl}/v1beta/models/${encodeURIComponent(llm.model)}:generateContent`;
  #|         const json = await proxyPost(url, {
  #|           "Content-Type": "application/json",
  #|           "x-goog-api-key": String(llm.apiKey || "")
  #|         }, JSON.stringify({
  #|           system_instruction: { parts: [{ text: systemPrompt }] },
  #|           contents: [{ role: "user", parts: [{ text: userPrompt }] }],
  #|           generationConfig: { temperature: 0.1 }
  #|         }));
  #|         const text = (json?.candidates?.[0]?.content?.parts || []).map((part) => String(part?.text || "")).join("\\n").trim();
  #|         if (!text) throw new Error("Gemini returned no revised MoonBit source.");
  #|         return { source: text, raw: json };
  #|       }
  #|       const rawBaseUrl = String(llm.baseUrl || "").trim();
  #|       const baseUrl = rawBaseUrl.endsWith("/") ? rawBaseUrl.slice(0, -1) : rawBaseUrl;
  #|       let url = `${baseUrl}/chat/completions`;
  #|       if (llm.provider === "zai") {
  #|         if (baseUrl.endsWith("/chat/completions")) {
  #|           url = baseUrl;
  #|         } else if (baseUrl === "https://open.bigmodel.cn" || baseUrl === "https://open.bigmodel.cn/") {
  #|           url = "https://open.bigmodel.cn/api/paas/v4/chat/completions";
  #|         } else if (!baseUrl.includes("/api/paas/v4")) {
  #|           url = `${baseUrl}/api/paas/v4/chat/completions`;
  #|         }
  #|       }
  #|       const headers = {
  #|         "Content-Type": "application/json",
  #|         "Authorization": `Bearer ${String(llm.apiKey || "")}`
  #|       };
  #|       if (llm.provider === "openrouter") {
  #|         headers["HTTP-Referer"] = "http://127.0.0.1:3000";
  #|         headers["X-Title"] = "MoonAP";
  #|       }
  #|       const json = await proxyPost(url, headers, JSON.stringify({
  #|         model: llm.model,
  #|         messages: [
  #|           { role: "system", content: systemPrompt },
  #|           { role: "user", content: userPrompt }
  #|         ],
  #|         temperature: 0.1
  #|       }));
  #|       const text = String(json?.choices?.[0]?.message?.content || "").trim();
  #|       if (!text) throw new Error(`${llm.provider} returned no revised MoonBit source.`);
  #|       return { source: text, raw: json };
  #|     };
  #|     let repaired = null;
  #|     let selected = null;
  #|     const failures = [];
  #|     for (let index = 0; index < ordered.length; index += 1) {
  #|       const item = ordered[index];
  #|       const llm = {
  #|         provider: item.key,
  #|         model: item.model,
  #|         baseUrl: item.baseUrl,
  #|         apiKey: item.apiKey,
  #|         rotated: providers.length > 1
  #|       };
  #|       try {
  #|         repaired = await requestJson(llm);
  #|         selected = llm;
  #|         const nextCursor = (start + index + 1) % providers.length;
  #|         localStorage.setItem("moonap.llm.router.v1", JSON.stringify({
  #|           providers: Array.isArray(saved.providers) ? saved.providers : providers,
  #|           cursor: nextCursor,
  #|           savedAt: saved.savedAt || new Date().toISOString()
  #|         }));
  #|         break;
  #|       } catch (error) {
  #|         failures.push(`${String(item.key || "provider")}/${String(item.model || "model")}: ${error instanceof Error ? error.message : String(error)}`);
  #|       }
  #|     }
  #|     if (!repaired || !selected) {
  #|       throw new Error(`All enabled providers failed during quality repair. ${failures.join(" | ")}`);
  #|     }
  #|     const cleaned = browser_extract_moonbit_source(String(repaired.source || ""));
  #|     const nextArtifact = {
  #|       ...(artifact || {}),
  #|       moonbit_source: cleaned,
  #|       llm_provider: selected.provider || "unknown",
  #|       llm_model: selected.model || "unknown",
  #|       llm_rotated: Boolean(selected.rotated),
  #|       repair_round: Number(artifact?.repair_round || 0) + 1,
  #|       quality_assessment_used: {
  #|         task_kind: String(assessment?.task_kind || ""),
  #|         title: String(assessment?.title || ""),
  #|         repair_hint: String(assessment?.repair_hint || ""),
  #|         missing_signals_json: String(assessment?.missing_signals_json || "[]")
  #|       },
  #|       llm_response_preview: JSON.stringify(repaired.raw).slice(0, 1200),
  #|       created_at: new Date().toISOString()
  #|     };
  #|     globalThis.__moonapLastArtifact = nextArtifact;
  #|     onDone(JSON.stringify(nextArtifact, null, 2));
  #|   } catch (error) {
  #|     onError(error instanceof Error ? error.message : String(error));
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_next_benchmark_level() -> Int =
  #| () => {
  #|   try {
  #|     const parsed = JSON.parse(globalThis.__moonapBenchmarkAssessment || "{}");
  #|     const level = Number(parsed?.level || 0);
  #|     const pass = Boolean(parsed?.pass);
  #|     if (pass && level >= 1 && level < 3) return level + 1;
  #|   } catch {}
  #|   return 1;
  #| }

///|
#cfg(target="js")
extern "js" fn browser_last_artifact_repair_round() -> Int =
  #| () => Number(globalThis.__moonapLastArtifact?.repair_round || 0)

///|
#cfg(target="js")
extern "js" fn browser_compile_last_artifact(
  formal_verification : Bool,
  on_done : (String) -> Unit,
  on_error : (String) -> Unit,
) -> Unit =
  #| async (formalVerification, onDone, onError) => {
  #|   try {
  #|     const artifact = globalThis.__moonapLastArtifact;
  #|     const source = String(artifact?.moonbit_source || "");
  #|     if (!source.trim()) {
  #|       throw new Error("No captured MoonBit source is available for compile probe.");
  #|     }
  #|     const url = formalVerification ? "/api/artifact/compile?formal=1" : "/api/artifact/compile";
  #|     const response = await fetch(url, {
  #|       method: "POST",
  #|       headers: { "Content-Type": "text/plain; charset=utf-8" },
  #|       body: source
  #|     });
  #|     const text = await response.text();
  #|     if (!response.ok) throw new Error(text || `Compile probe failed (${response.status})`);
  #|     onDone(String(text));
  #|   } catch (error) {
  #|     onError(error instanceof Error ? error.message : String(error));
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_repair_last_artifact_with_compile_summary(
  formal_verification : Bool,
  knowledge_pack : String,
  on_done : (String) -> Unit,
  on_error : (String) -> Unit,
) -> Unit =
  #| async (formalVerification, knowledgePack, onDone, onError) => {
  #|   try {
  #|     const artifact = globalThis.__moonapLastArtifact;
  #|     const report = globalThis.__moonapLastCompileReport;
  #|     const source = String(artifact?.moonbit_source || "");
  #|     if (!source.trim()) throw new Error("No captured MoonBit source is available for repair.");
  #|     if (!report || typeof report !== "object") throw new Error("No compile summary is available yet.");
  #|     const readRouter = () => {
  #|       try {
  #|         const parsed = JSON.parse(localStorage.getItem("moonap.llm.router.v1") || "{}");
  #|         return parsed && typeof parsed === "object" ? parsed : {};
  #|       } catch {
  #|         return {};
  #|       }
  #|     };
  #|     const saved = readRouter();
  #|     const providers = Array.isArray(saved.providers) ? saved.providers.filter((item) => item.enabled && String(item.apiKey || "").trim() !== "" && String(item.test_status || "") !== "failed") : [];
  #|     const repairMode = localStorage.getItem("moonap.repairFeedbackMode") === "summary" ? "summary" : "raw";
  #|     if (providers.length === 0) throw new Error("No enabled LLM provider is available in the router.");
  #|     const cursor = Number.isFinite(saved.cursor) ? saved.cursor : 0;
  #|     const start = ((cursor % providers.length) + providers.length) % providers.length;
  #|     const ordered = providers.slice(start).concat(providers.slice(0, start));
  #|     const proxyPost = async (url, headers, body) => {
  #|       const envelope = [
  #|         `URL\t${String(url)}`,
  #|         ...Object.entries(headers || {}).map(([key, value]) => `HEADER\t${String(key)}\t${String(value).replace(/\r?\n/g, " ")}`),
  #|         "BODY",
  #|         String(body)
  #|       ].join("\n");
  #|       const response = await fetch("/api/llm/proxy", {
  #|         method: "POST",
  #|         headers: { "Content-Type": "text/plain; charset=utf-8" },
  #|         body: envelope
  #|       });
  #|       const text = await response.text();
  #|       let json = {};
  #|       try {
  #|         json = JSON.parse(text);
  #|       } catch {
  #|         const plain = String(text || "")
  #|           .replace(/<script[\s\S]*?<\/script>/gi, " ")
  #|           .replace(/<style[\s\S]*?<\/style>/gi, " ")
  #|           .replace(/<[^>]+>/g, " ")
  #|           .replace(/\s+/g, " ")
  #|           .trim();
  #|         const summarized = plain || `MoonAP proxy returned non-JSON (${response.status})`;
  #|         throw new Error(`Provider returned non-JSON (${response.status}): ${summarized.slice(0, 240)}`);
  #|       }
  #|       if (!response.ok) {
  #|         const detail = json?.error?.detail ? ` ${String(json.error.detail)}` : "";
  #|         throw new Error((json?.error?.message || `LLM request failed (${response.status})`) + detail);
  #|       }
  #|       return json;
  #|     };
  #|     const updatePrompts = (modeText, systemPromptText, userPromptText) => {
  #|       const setText = (selector, value) => {
  #|         const node = document.querySelector(selector);
  #|         if (node) node.textContent = String(value);
  #|       };
  #|       setText("#promptMode", modeText || "No LLM prompt captured yet.");
  #|       setText("#promptSystem", systemPromptText || "No LLM prompt captured yet.");
  #|       setText("#promptUser", userPromptText || "No LLM prompt captured yet.");
  #|     };
  #|     const originalTask = String(artifact?.prompt || "Generate a Personal FastQ Generator in MoonBit.");
  #|     const compilerExcerpt = String(repairMode === "raw" ? (report.output || report.trimmed_output || "") : (report.trimmed_output || report.output || "")).trim();
  #|     const priorConversation = Array.isArray(artifact?.conversation_history)
  #|       ? artifact.conversation_history
  #|           .filter((item) => item && (item.role === "user" || item.role === "assistant") && String(item.content || "").trim() !== "")
  #|           .map((item) => ({ role: String(item.role), content: String(item.content) }))
  #|       : [{ role: "user", content: originalTask }, { role: "assistant", content: source }];
  #|     const buildRepairPrompts = (llm) => {
  #|       const modelName = String(llm?.model || "");
  #|       const isGpt54 = modelName.toLowerCase().includes("gpt-5.4");
  #|       if (isGpt54) {
  #|         const systemPrompt = [
  #|           "You are an AI coder.",
  #|           "You only write MoonBit code.",
  #|           "Your job is to repair MoonBit code for the user's task.",
  #|           "Return only the full contents of cmd/main/main.mbt."
  #|         ].join("\\n");
  #|         const repairUserPrompt = [
  #|           "The previous MoonBit file failed to compile under wasm-gc.",
  #|           "",
  #|           "Compiler error:",
  #|           compilerExcerpt,
  #|           "",
  #|           "Fix the file and return the full corrected cmd/main/main.mbt only."
  #|         ].join("\\n");
  #|         return {
  #|           modeText: "repair / frontier-conversation",
  #|           systemPrompt,
  #|           userPrompt: `${priorConversation.map((item) => `${String(item.role).toUpperCase()}:\n${String(item.content)}`).join("\\n\\n---\\n\\n")}\\n\\n---\\n\\nUSER:\\n${repairUserPrompt}`,
  #|           openaiMessages: [
  #|             { role: "system", content: systemPrompt },
  #|             ...priorConversation,
  #|             { role: "user", content: repairUserPrompt }
  #|           ],
  #|           geminiUserPrompt: `${priorConversation.map((item) => `${String(item.role).toUpperCase()}:\n${String(item.content)}`).join("\\n\\n---\\n\\n")}\\n\\n---\\n\\nUSER:\\n${repairUserPrompt}`
  #|         };
  #|       }
  #|       const systemPrompt = [
  #|         "You are repairing MoonBit code for MoonAP.",
  #|         "Target language: MoonBit 0.9.",
  #|         "Return ONLY the repaired contents of cmd/main/main.mbt.",
  #|         "Do NOT return markdown fences, explanations, bullet lists, quoted compiler messages, moon.pkg, or moon.mod.json.",
  #|         "Do NOT describe the errors before writing code.",
  #|         "Do NOT think aloud. Do NOT say 'Okay', 'I need to', 'Let me', or similar phrases.",
  #|         "Any non-code text is a failed repair.",
  #|         "Keep the task behavior and default parameters unchanged.",
  #|         "Preserve the original task goal, not just compilability.",
  #|         "",
  #|         "Follow the MoonBit primer in the user prompt before using any stale prior memory."
  #|       ].join("\\n");
  #|       const userPrompt = [
  #|         "Read this MoonBit 0.9 primer first and follow it strictly:",
  #|         String(knowledgePack || ""),
  #|         "",
  #|         `Original task: ${originalTask}`,
  #|         "",
  #|         "Current compile summary:",
  #|         `- error_kind: ${String(report.summary_kind || report.stage || "compiler-error")}`,
  #|         `- primary_file: ${String(report.primary_file || "cmd/main/main.mbt")}`,
  #|         `- primary_line: ${String(report.primary_line || 0)}`,
  #|         `- likely_cause: ${String(report.likely_cause || "")}`,
  #|         `- repair_hint: ${String(report.repair_hint || "")}`,
  #|         "",
  #|         repairMode === "raw" ? "Raw compiler output:" : "Trimmed compiler output:",
  #|         compilerExcerpt,
  #|         "",
  #|         "Current source:",
  #|         source,
  #|         "",
  #|         "Please repair only what is needed to make this compile under wasm-gc.",
  #|         "Return the full corrected cmd/main/main.mbt file and nothing else."
  #|       ].join("\\n");
  #|       return {
  #|         modeText: "repair / guided-summary",
  #|         systemPrompt,
  #|         userPrompt,
  #|         openaiMessages: [
  #|           { role: "system", content: systemPrompt },
  #|           { role: "user", content: userPrompt }
  #|         ],
  #|         geminiUserPrompt: userPrompt
  #|       };
  #|     };
  #|     const requestJson = async (llm) => {
  #|       const promptPack = buildRepairPrompts(llm);
  #|       updatePrompts(promptPack.modeText, promptPack.systemPrompt, promptPack.userPrompt);
  #|       if (llm.provider === "gemini") {
  #|         const url = `${llm.baseUrl}/v1beta/models/${encodeURIComponent(llm.model)}:generateContent`;
  #|         const json = await proxyPost(url, {
  #|           "Content-Type": "application/json",
  #|           "x-goog-api-key": String(llm.apiKey || "")
  #|         }, JSON.stringify({
  #|           system_instruction: { parts: [{ text: promptPack.systemPrompt }] },
  #|           contents: [{ role: "user", parts: [{ text: promptPack.geminiUserPrompt }] }],
  #|           generationConfig: { temperature: 0.1 }
  #|         }));
  #|         const text = (json?.candidates?.[0]?.content?.parts || []).map((part) => String(part?.text || "")).join("\\n").trim();
  #|         if (!text) throw new Error("Gemini returned no repaired MoonBit source.");
  #|         return { source: text, raw: json };
  #|       }
  #|       const rawBaseUrl = String(llm.baseUrl || "").trim();
  #|       const baseUrl = rawBaseUrl.endsWith("/") ? rawBaseUrl.slice(0, -1) : rawBaseUrl;
  #|       let url = `${baseUrl}/chat/completions`;
  #|       if (llm.provider === "zai") {
  #|         if (baseUrl.endsWith("/chat/completions")) {
  #|           url = baseUrl;
  #|         } else if (baseUrl === "https://open.bigmodel.cn" || baseUrl === "https://open.bigmodel.cn/") {
  #|           url = "https://open.bigmodel.cn/api/paas/v4/chat/completions";
  #|         } else if (!baseUrl.includes("/api/paas/v4")) {
  #|           url = `${baseUrl}/api/paas/v4/chat/completions`;
  #|         }
  #|       }
  #|       const headers = {
  #|         "Content-Type": "application/json",
  #|         "Authorization": `Bearer ${String(llm.apiKey || "")}`
  #|       };
  #|       if (llm.provider === "openrouter") {
  #|         headers["HTTP-Referer"] = "http://127.0.0.1:3000";
  #|         headers["X-Title"] = "MoonAP";
  #|       }
  #|       const json = await proxyPost(url, headers, JSON.stringify({
  #|         model: llm.model,
  #|         messages: promptPack.openaiMessages,
  #|         temperature: 0.1
  #|       }));
  #|       const text = String(json?.choices?.[0]?.message?.content || "").trim();
  #|       if (!text) throw new Error(`${llm.provider} returned no repaired MoonBit source.`);
  #|       return { source: text, raw: json };
  #|     };
  #|     let repaired = null;
  #|     let selected = null;
  #|     const failures = [];
  #|     for (let index = 0; index < ordered.length; index += 1) {
  #|       const item = ordered[index];
  #|       const llm = {
  #|         provider: item.key,
  #|         model: item.model,
  #|         baseUrl: item.baseUrl,
  #|         apiKey: item.apiKey,
  #|         rotated: providers.length > 1
  #|       };
  #|       try {
  #|         repaired = await requestJson(llm);
  #|         selected = llm;
  #|         const nextCursor = (start + index + 1) % providers.length;
  #|         localStorage.setItem("moonap.llm.router.v1", JSON.stringify({
  #|           providers: Array.isArray(saved.providers) ? saved.providers : providers,
  #|           cursor: nextCursor,
  #|           savedAt: saved.savedAt || new Date().toISOString()
  #|         }));
  #|         break;
  #|       } catch (error) {
  #|         failures.push(`${String(item.key || "provider")}/${String(item.model || "model")}: ${error instanceof Error ? error.message : String(error)}`);
  #|       }
  #|     }
  #|     if (!repaired || !selected) {
  #|       throw new Error(`All enabled providers failed during repair. ${failures.join(" | ")}`);
  #|     }
  #|     const ensureExtractMoonBitSource = () => {
  #|       if (typeof globalThis.__moonapExtractMoonBitSource === "function") return globalThis.__moonapExtractMoonBitSource;
  #|       globalThis.__moonapExtractMoonBitSource = (value) => {
  #|         const text = String(value || "").trim();
  #|         if (!text) return "";
  #|         const extract = (source, startMarker, endMarker) => {
  #|           const start = source.indexOf(startMarker);
  #|           if (start < 0) return "";
  #|           const after = source.slice(start + startMarker.length).trim();
  #|           if (!after) return "";
  #|           const end = after.indexOf(endMarker);
  #|           if (end < 0) return "";
  #|           return after.slice(0, end).trim();
  #|         };
  #|         const patterns = [
  #|           ["FILE: cmd/main/main.mbt", "END_FILE"],
  #|           ['<moonbit-file path="cmd/main/main.mbt">', "</moonbit-file>"],
  #|           ["```moonbit", "```"],
  #|           ["```mbt", "```"],
  #|           ["```", "```"]
  #|         ];
  #|         for (const [startMarker, endMarker] of patterns) {
  #|           const extracted = extract(text, startMarker, endMarker);
  #|           if (extracted) return extracted;
  #|         }
  #|         return text;
  #|       };
  #|       return globalThis.__moonapExtractMoonBitSource;
  #|     };
  #|     const cleaned = ensureExtractMoonBitSource()(String(repaired.source || ""));
  #|     const nextArtifact = {
  #|       ...(artifact || {}),
  #|       moonbit_source: cleaned,
  #|       conversation_history: [
  #|         ...priorConversation,
  #|         { role: "user", content: `Compiler error:\n${compilerExcerpt}` },
  #|         { role: "assistant", content: cleaned }
  #|       ],
  #|       llm_provider: selected.provider || "unknown",
  #|       llm_model: selected.model || "unknown",
  #|       llm_rotated: Boolean(selected.rotated),
  #|       repair_round: Number(artifact?.repair_round || 0) + 1,
  #|       compile_summary_used: {
  #|         summary_kind: String(report.summary_kind || ""),
  #|         primary_file: String(report.primary_file || ""),
  #|         primary_line: Number(report.primary_line || 0),
  #|         repair_hint: String(report.repair_hint || "")
  #|       },
  #|       llm_response_preview: JSON.stringify(repaired.raw).slice(0, 1200),
  #|       created_at: new Date().toISOString()
  #|     };
  #|     globalThis.__moonapLastArtifact = nextArtifact;
  #|     globalThis.__moonapLastCompileReport = null;
  #|     onDone(JSON.stringify(nextArtifact, null, 2));
  #|   } catch (error) {
  #|     onError(error instanceof Error ? error.message : String(error));
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_update_process(
  provider : String,
  stage : String,
  result : String,
  log_text : String,
  source_text : String,
) -> Unit =
  #| (provider, stage, result, logText, sourceText) => {
  #|   const setText = (selector, value) => {
  #|     const node = document.querySelector(selector);
  #|     if (node) node.textContent = String(value);
  #|   };
  #|   setText("#processProvider", provider || "-");
  #|   setText("#processStage", stage || "-");
  #|   setText("#processResult", result || "waiting");
  #|   setText("#processStatus", result || "waiting");
  #|   setText("#processLog", logText || "");
  #|   if (sourceText !== "") setText("#processSource", sourceText || "No generated source yet.");
  #|   const payload = JSON.stringify({
  #|     ts: new Date().toISOString(),
  #|     provider: String(provider || "-"),
  #|     stage: String(stage || "-"),
  #|     result: String(result || "waiting"),
  #|     log_text: String(logText || ""),
  #|     source_text: String(sourceText || "").slice(0, 2000)
  #|   }) + "\n";
  #|   fetch("/api/logs/moonap-runtime.log", {
  #|     method: "POST",
  #|     headers: { "Content-Type": "text/plain; charset=utf-8" },
  #|     body: payload,
  #|     keepalive: true
  #|   }).catch(() => {});
  #| }

///|
#cfg(target="js")
extern "js" fn browser_update_result_panel(raw : String) -> Unit =
  #| (raw) => {
  #|   let data = {};
  #|   try { data = JSON.parse(String(raw)); } catch { data = { status: "error" }; }
  #|   const panel = document.querySelector("#resultPanel");
  #|   if (globalThis.__moonapMinimalShell !== false) {
  #|     if (panel) panel.style.display = "none";
  #|     globalThis.__moonapLastVisibleResult = data;
  #|     return;
  #|   }
  #|   panel?.classList.add("is-open");
  #|   const setText = (selector, value) => {
  #|     const node = document.querySelector(selector);
  #|     if (node) node.textContent = String(value);
  #|   };
  #|   const bytes = (value) => {
  #|     const n = Number(value || 0);
  #|     if (n >= 1073741824) return `${(n / 1073741824).toFixed(2)} GB`;
  #|     if (n >= 1048576) return `${(n / 1048576).toFixed(2)} MB`;
  #|     if (n >= 1024) return `${(n / 1024).toFixed(1)} KB`;
  #|     return `${n} B`;
  #|   };
  #|   const pct = Math.max(0, Math.min(100, Number(data.progress_percent ?? (data.status === "done" ? 100 : 0))));
  #|   const fill = document.querySelector("#progressFill");
  #|   if (fill) fill.style.width = `${pct}%`;
  #|   setText("#resultStatus", data.status || "ready");
  #|   const isRuntime = String(data.status || "").startsWith("runtime") || String(data.status || "").includes("ready-for-runtime");
  #|   setText("#resultTitle", isRuntime
  #|     ? (data.status === "ready-for-runtime" ? "MoonAP runtime request is ready" : "MoonAP runtime result")
  #|     : (data.status === "generated" ? "Synthetic FastQ generated locally" : "Browser-local FastQ analysis"));
  #|   setText("#metricFile", data.file_name || data.download_name || "-");
  #|   setText("#metricProcessed", bytes(data.bytes_processed ?? data.file_size_bytes ?? 0));
  #|   setText("#metricReads", data.reads_seen ?? data.read_count ?? "0");
  #|   setText("#metricTarget", data.target_base_count ?? data.expected_n_count ?? "0");
  #|   setText("#metricBases", data.total_bases ?? data.summary ?? "0");
  #|   setText("#metricUploaded", bytes(data.uploaded_bytes ?? 0));
  #| }

///|
#cfg(target="js")
extern "js" fn browser_watch_runtime_protocol(
  on_request : (String) -> Unit,
  on_result : (String) -> Unit,
  on_save_decision : (String) -> Unit,
) -> Unit =
  #| (onRequest, onResult, onSaveDecision) => {
  #|   const poll = async () => {
  #|     try {
  #|       const requestText = await fetch("/api/runtime-exec/latest-request").then((response) => response.text());
  #|       if (requestText && requestText !== globalThis.__moonapLastRuntimeRequestText) {
  #|         globalThis.__moonapLastRuntimeRequestText = requestText;
  #|         try { globalThis.__moonapLastRuntimeRequest = JSON.parse(requestText); } catch {}
  #|         onRequest(String(requestText));
  #|       }
  #|     } catch {}
  #|     try {
  #|       const resultText = await fetch("/api/runtime-exec/latest-result").then((response) => response.text());
  #|       if (resultText && resultText !== globalThis.__moonapLastRuntimeResultText) {
  #|         globalThis.__moonapLastRuntimeResultText = resultText;
  #|         try { globalThis.__moonapLastRuntimeResult = JSON.parse(resultText); } catch {}
  #|         onResult(String(resultText));
  #|       }
  #|     } catch {}
  #|     try {
  #|       const decisionText = await fetch("/api/skill-export/save-decision").then((response) => response.text());
  #|       if (decisionText && decisionText !== globalThis.__moonapLastSkillSaveDecisionText) {
  #|         globalThis.__moonapLastSkillSaveDecisionText = decisionText;
  #|         try { globalThis.__moonapLastSkillSaveDecision = JSON.parse(decisionText); } catch {}
  #|         onSaveDecision(String(decisionText));
  #|       }
  #|     } catch {}
  #|   };
  #|   if (!globalThis.__moonapRuntimeWatcherStarted) {
  #|     globalThis.__moonapRuntimeWatcherStarted = true;
  #|     poll();
  #|     setInterval(poll, 2000);
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_request_skill_save(
  on_done : (String) -> Unit,
  on_error : (String) -> Unit,
) -> Unit =
  #| async (onDone, onError) => {
  #|   try {
  #|     const runtimeResult = globalThis.__moonapLastRuntimeResult;
  #|     if (!runtimeResult || typeof runtimeResult !== "object") {
  #|       throw new Error("No runtime result is available yet.");
  #|     }
  #|     const requestId = String(runtimeResult.request_id || "");
  #|     const status = String(runtimeResult.status || "");
  #|     if (!requestId || !status.includes("succeeded")) {
  #|       throw new Error("MoonAP requires a successful runtime result before saving as a SKILL.");
  #|     }
  #|     const response = await fetch("/api/skill-export/save-decision", {
  #|       method: "POST",
  #|       headers: { "Content-Type": "application/json; charset=utf-8" },
  #|       body: JSON.stringify({
  #|         request_id: requestId,
  #|         decision: "accepted-save-skill",
  #|         reason: "User accepted the runtime result and wants to reuse this workflow as a SKILL."
  #|       })
  #|     });
  #|     const text = await response.text();
  #|     if (!response.ok) throw new Error(text || `Skill save decision failed (${response.status})`);
  #|     onDone(String(text));
  #|   } catch (error) {
  #|     onError(error instanceof Error ? error.message : String(error));
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_message_value() -> String =
  #| () => String(document.querySelector("#message")?.value || "").trim()

///|
#cfg(target="js")
extern "js" fn browser_prepare_message_input(default_text : String) -> Unit =
  #| (defaultText) => {
  #|   const textarea = document.querySelector("#message");
  #|   if (!textarea) return;
  #|   const applyTone = () => {
  #|     textarea.classList.toggle("suggested", String(textarea.value || "") === String(defaultText));
  #|   };
  #|   if (String(textarea.value || "").trim() === "") {
  #|     textarea.value = String(defaultText);
  #|   }
  #|   applyTone();
  #|   if (!textarea.dataset.moonapPrepared) {
  #|     textarea.addEventListener("input", applyTone);
  #|     textarea.dataset.moonapPrepared = "true";
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_enable_minimal_shell() -> Unit =
  #| () => {
  #|   globalThis.__moonapMinimalShell = true;
  #|   const hide = (selector) => {
  #|     const node = document.querySelector(selector);
  #|     if (node) node.style.display = "none";
  #|   };
  #|   hide("#onboardingCard");
  #|   hide("#resultPanel");
  #|   hide("#artifactActions");
  #|   hide("#modePanel");
  #|   hide("#privacyStrip");
  #|   const shell = document.querySelector(".app-shell");
  #|   shell?.classList.remove("details-open");
  #|   const drawer = document.querySelector("#detailsDrawer");
  #|   if (drawer) drawer.style.display = "";
  #|   const detailsButton = document.querySelector("#detailsToggle");
  #|   if (detailsButton) detailsButton.style.display = "";
  #| }

///|
#cfg(target="js")
extern "js" fn browser_restore_formal_verification() -> Unit =
  #| () => {
  #|   const enabled = localStorage.getItem("moonap.formalVerification") === "true";
  #|   const mainToggle = document.querySelector("#formalVerification");
  #|   const dialogToggle = document.querySelector("#routerFormalVerification");
  #|   if (mainToggle) mainToggle.checked = enabled;
  #|   if (dialogToggle) dialogToggle.checked = enabled;
  #| }

///|
#cfg(target="js")
extern "js" fn browser_toggle_details() -> Unit =
  #| () => {
  #|   const root = document.querySelector(".app-shell");
  #|   const button = document.querySelector("#detailsToggle");
  #|   if (!root || !button) return;
  #|   const open = !root.classList.contains("details-open");
  #|   root.classList.toggle("details-open", open);
  #|   button.setAttribute("aria-expanded", open ? "true" : "false");
  #| }

///|
#cfg(target="js")
extern "js" fn browser_file_name() -> String =
  #| () => {
  #|   const file = document.querySelector("#fileInput")?.files?.[0];
  #|   return String(file?.name || "");
  #| }

///|
#cfg(target="js")
extern "js" fn browser_has_file() -> Bool =
  #| () => Boolean(document.querySelector("#fileInput")?.files?.[0])

///|
#cfg(target="js")
extern "js" fn browser_formal_verification_enabled() -> Bool =
  #| () => Boolean(document.querySelector("#formalVerification")?.checked)

///|
#cfg(target="js")
extern "js" fn browser_run_fastq_counter(
  target_base : String,
  on_progress : (String) -> Unit,
  on_done : (String) -> Unit,
  on_error : (String) -> Unit,
) -> Unit =
  #| async (targetBase, onProgress, onDone, onError) => {
  #|   try {
  #|     const file = document.querySelector("#fileInput")?.files?.[0];
  #|     if (!file) {
  #|       onError("Choose a FastQ file first.");
  #|       return;
  #|     }
  #|     const chunkSize = 4 * 1024 * 1024;
  #|     const target = String(targetBase || "N").toUpperCase();
  #|     let offset = 0;
  #|     let carry = "";
  #|     let lineMod = 0;
  #|     let readCount = 0;
  #|     let sequenceLines = 0;
  #|     let totalBases = 0;
  #|     let targetCount = 0;
  #|     const started = performance.now();
  #|     const countLine = (line) => {
  #|       sequenceLines += 1;
  #|       totalBases += line.length;
  #|       for (let i = 0; i < line.length; i += 1) {
  #|         if (line[i].toUpperCase() === target) targetCount += 1;
  #|       }
  #|     };
  #|     while (offset < file.size) {
  #|       const end = Math.min(offset + chunkSize, file.size);
  #|       const text = await file.slice(offset, end).text();
  #|       const merged = carry + text;
  #|       const hasFinalNewline = merged.endsWith("\n") || merged.endsWith("\r");
  #|       const lines = merged.split(/\r?\n/);
  #|       carry = hasFinalNewline ? "" : String(lines.pop() || "");
  #|       for (const line of lines) {
  #|         if (lineMod === 1) countLine(line);
  #|         if (lineMod === 3) readCount += 1;
  #|         lineMod = (lineMod + 1) % 4;
  #|       }
  #|       offset = end;
  #|       const pct = file.size === 0 ? 100 : Math.floor((offset / file.size) * 100);
  #|       onProgress(JSON.stringify({
  #|         status: "counting",
  #|         file_name: file.name,
  #|         file_size_bytes: file.size,
  #|         chunk_size_bytes: chunkSize,
  #|         bytes_processed: offset,
  #|         progress_percent: pct,
  #|         uploaded_bytes: 0,
  #|         llm_receives_file_contents: false,
  #|         target_base: target
  #|       }, null, 2));
  #|       await new Promise((resolve) => setTimeout(resolve, 0));
  #|     }
  #|     if (carry.length > 0) {
  #|       if (lineMod === 1) countLine(carry);
  #|       if (lineMod === 3) readCount += 1;
  #|     }
  #|     const elapsedMs = Math.round(performance.now() - started);
  #|     onDone(JSON.stringify({
  #|       status: "done",
  #|       file_name: file.name,
  #|       file_size_bytes: file.size,
  #|       reads_seen: readCount,
  #|       sequence_lines: sequenceLines,
  #|       total_bases: totalBases,
  #|       target_base: target,
  #|       target_base_count: targetCount,
  #|       target_base_fraction: totalBases === 0 ? 0 : targetCount / totalBases,
  #|       elapsed_ms: elapsedMs,
  #|       uploaded_bytes: 0,
  #|       llm_receives_file_contents: false,
  #|       privacy: "File contents stayed in this browser."
  #|     }, null, 2));
  #|   } catch (error) {
  #|     onError(error instanceof Error ? error.message : String(error));
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_generate_fastq_sample(
  read_count : Int,
  read_length : Int,
  n_rate_text : String,
  seed_value : Int,
  on_done : (String) -> Unit,
  on_error : (String) -> Unit,
) -> Unit =
  #| (readCountRaw, readLengthRaw, nRateText, seedRaw, onDone, onError) => {
  #|   try {
  #|     if (globalThis.__moonapAllowDownload !== "dialog-run") {
  #|       throw new Error("Download blocked: open the SKILL settings dialog and click Run.");
  #|     }
  #|     globalThis.__moonapAllowDownload = "";
  #|     const readCount = Math.max(1, Math.min(1000000, Number(readCountRaw) || 10000));
  #|     const readLength = Math.max(1, Math.min(10000, Number(readLengthRaw) || 150));
  #|     const nRate = Math.max(0, Math.min(1, Number(nRateText) || 0.01));
  #|     const originalSeed = Number(seedRaw) || 42;
  #|     let seed = originalSeed;
  #|     const bases = ["A", "C", "G", "T"];
  #|     const rand = () => {
  #|       seed = (seed * 1664525 + 1013904223) >>> 0;
  #|       return seed / 4294967296;
  #|     };
  #|     const chunks = [];
  #|     let nCount = 0;
  #|     let totalBases = 0;
  #|     for (let read = 0; read < readCount; read += 1) {
  #|       let seq = "";
  #|       for (let i = 0; i < readLength; i += 1) {
  #|         totalBases += 1;
  #|         if (rand() < nRate) {
  #|           seq += "N";
  #|           nCount += 1;
  #|         } else {
  #|           seq += bases[Math.floor(rand() * bases.length)];
  #|         }
  #|       }
  #|       chunks.push(`@moonap_${read}\n${seq}\n+\n${"I".repeat(readLength)}\n`);
  #|     }
  #|     const blob = new Blob(chunks, { type: "text/plain;charset=utf-8" });
  #|     const url = URL.createObjectURL(blob);
  #|     const link = document.createElement("a");
  #|     link.href = url;
  #|     link.download = "moonap-demo.fastq";
  #|     document.body.append(link);
  #|     link.click();
  #|     link.remove();
  #|     setTimeout(() => URL.revokeObjectURL(url), 1000);
  #|     onDone(JSON.stringify({
  #|       status: "generated",
  #|       file_name: "moonap-demo.fastq",
  #|       read_count: readCount,
  #|       read_length: readLength,
  #|       total_bases: totalBases,
  #|       expected_n_count: nCount,
  #|       n_rate: nRate,
  #|       random_seed: originalSeed,
  #|       llm_output_tokens_for_file_contents: 0,
  #|       note: "LLM would output only this compact recipe; MoonAP generated the file locally."
  #|     }, null, 2));
  #|   } catch (error) {
  #|     onError(error instanceof Error ? error.message : String(error));
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_on_submit(handler : () -> Unit) -> Unit =
  #| (handler) => {
  #|   const form = document.querySelector("#chatForm");
  #|   form?.addEventListener("submit", (event) => {
  #|     event.preventDefault();
  #|     try {
  #|       handler();
  #|     } catch (error) {
  #|       console.error("MoonAP submit handler failed:", error);
  #|       alert(`MoonAP submit failed: ${error instanceof Error ? error.message : String(error)}`);
  #|     }
  #|   });
  #| }

///|
#cfg(target="js")
extern "js" fn browser_on_click(
  selector : String,
  handler : () -> Unit,
) -> Unit =
  #| (selector, handler) => {
  #|   document.querySelector(String(selector))?.addEventListener("click", (event) => {
  #|     event.preventDefault();
  #|     try {
  #|       handler();
  #|     } catch (error) {
  #|       console.error(`MoonAP click handler failed for ${String(selector)}:`, error);
  #|       alert(`MoonAP click failed: ${error instanceof Error ? error.message : String(error)}`);
  #|     }
  #|   });
  #| }

///|
#cfg(target="js")
extern "js" fn browser_on_skill_card_click(handler : (String) -> Unit) -> Unit =
  #| (handler) => {
  #|   document.addEventListener("click", (event) => {
  #|     const card = event.target?.closest?.(".skill-card[data-skill-id]");
  #|     if (!card) return;
  #|     event.preventDefault();
  #|     event.stopPropagation();
  #|     document.querySelectorAll(".skill-card").forEach((card) => card.classList.remove("is-selected"));
  #|     card.classList.add("is-selected");
  #|     try {
  #|       handler(String(card.dataset?.skillId || ""));
  #|     } catch (error) {
  #|       console.error("MoonAP skill click failed:", error);
  #|       alert(`MoonAP skill failed: ${error instanceof Error ? error.message : String(error)}`);
  #|     }
  #|   });
  #| }

///|
#cfg(target="js")
extern "js" fn browser_on_onboarding_action(
  on_run_benchmark : () -> Unit,
  on_open_skill : () -> Unit,
  on_edit_llm : () -> Unit,
  on_open_log : () -> Unit,
  on_download_log : () -> Unit,
) -> Unit =
  #| (onRunBenchmark, onOpenSkill, onEditLlm, onOpenLog, onDownloadLog) => {
  #|   document.addEventListener("click", (event) => {
  #|     const target = event.target?.closest?.("#onboardingRunBenchmark, #onboardingOpenSkill, #onboardingEditLLM, #onboardingOpenLog, #onboardingDownloadLog");
  #|     if (!target) return;
  #|     event.preventDefault();
  #|     event.stopPropagation();
  #|     try {
  #|       if (target.id === "onboardingRunBenchmark") {
  #|         onRunBenchmark();
  #|       } else if (target.id === "onboardingOpenSkill") {
  #|         onOpenSkill();
  #|       } else if (target.id === "onboardingEditLLM") {
  #|         onEditLlm();
  #|       } else if (target.id === "onboardingOpenLog") {
  #|         onOpenLog();
  #|       } else if (target.id === "onboardingDownloadLog") {
  #|         onDownloadLog();
  #|       }
  #|     } catch (error) {
  #|       console.error("MoonAP onboarding action failed:", error);
  #|       alert(`MoonAP onboarding failed: ${error instanceof Error ? error.message : String(error)}`);
  #|     }
  #|   });
  #| }

///|
#cfg(target="js")
extern "js" fn browser_open_skill_dialog(skill_id : String) -> Unit =
  #| (skillId) => {
  #|   let dialog = document.querySelector("#skillDialog");
  #|   if (!dialog) {
  #|     dialog = document.createElement("dialog");
  #|     dialog.id = "skillDialog";
  #|     dialog.className = "skill-dialog";
  #|     dialog.innerHTML = `
  #|       <form method="dialog" class="skill-dialog-body">
  #|         <div class="dialog-head"><span id="dialogScope">SKILL</span><strong id="dialogTitle">Configure SKILL</strong></div>
  #|         <p id="dialogSummary" class="dialog-summary"></p>
  #|         <div id="dialogFields" class="dialog-fields"></div>
  #|         <div class="dialog-actions"><button id="dialogCancel" class="dialog-button" type="button">Cancel</button><button id="dialogRun" class="dialog-button primary" type="button">Run</button></div>
  #|       </form>`;
  #|     document.body.append(dialog);
  #|   }
  #|   const scope = document.querySelector("#dialogScope");
  #|   const title = document.querySelector("#dialogTitle");
  #|   const summary = document.querySelector("#dialogSummary");
  #|   const fields = document.querySelector("#dialogFields");
  #|   const set = (node, value) => { if (node) node.textContent = String(value); };
  #|   if (!dialog || !fields) return;
  #|   fields.innerHTML = "";
  #|   dialog.dataset.skillId = String(skillId);
  #|   const addField = (id, label, value, mode = "numeric") => {
  #|     const item = document.createElement("label");
  #|     item.textContent = label;
  #|     const input = document.createElement("input");
  #|     input.id = `param-${id}`;
  #|     input.value = value;
  #|     input.inputMode = mode;
  #|     item.append(input);
  #|     fields.append(item);
  #|   };
  #|   if (skillId.includes("moonbit.fastq-generator")) {
  #|     set(scope, "SKILL-Hub / MoonBit");
  #|     set(title, "MoonBit FastQ Generator");
  #|     set(summary, "Ask the active LLM router to generate a MoonBit FastQ generator program, then run a real compile probe automatically.");
  #|     addField("readCount", "Read count", "10000");
  #|     addField("readLength", "Read length", "150");
  #|     addField("nRatePerMille", "N rate per mille", "10");
  #|     addField("seed", "Random seed", "42");
  #|   } else if (skillId.includes("fastq-generator")) {
  #|     const personal = skillId.includes("personal.fastq-generator");
  #|     set(scope, personal ? "1.1 Personal-SKILL-Set" : "SKILL-Hub / Research / Synthetic");
  #|     set(title, personal ? "Personal FastQ Generator" : "FastQ Generator");
  #|     set(summary, "Generate deterministic FastQ locally. Confirm parameters before MoonAP downloads the file.");
  #|     addField("readCount", "Read count", "10000");
  #|     addField("readLength", "Read length", "150");
  #|     addField("nRate", "N rate", "0.01", "decimal");
  #|     addField("seed", "Random seed", "42");
  #|   } else if (skillId.includes("moonbit-benchmark")) {
  #|     set(scope, "SKILL-Hub / MoonBit");
  #|     set(title, "MoonBit Benchmark Ladder");
  #|     set(summary, "Start from a tiny MoonBit task and step upward. Use this to check whether the active LLM router can stay in real MoonBit syntax before we try harder jobs.");
  #|     addField("benchmarkLevel", "Benchmark level (1-5)", "1");
  #|   } else if (skillId.includes("free-llm-eval")) {
  #|     set(scope, "SKILL-Hub / Experiments");
  #|     set(title, "Free LLM MoonBit Eval");
  #|     set(summary, "Run L1-L3 MoonBit experiments against every enabled provider/model, then persist raw JSON plus a readable markdown summary.");
  #|     addField("evalMaxLevel", "Max benchmark level (1-3)", "3");
  #|   } else if (skillId.includes("fastq-base-counter")) {
  #|     set(scope, "SKILL-Hub / Research / FastQ");
  #|     set(title, "FastQ Base Counter");
  #|     set(summary, "Count a selected base in a browser-local FastQ file. Select a file with the + button before running.");
  #|     addField("targetBase", "Target base", "N", "text");
  #|   } else if (skillId === "personal") {
  #|     set(scope, "1.1 Personal-SKILL-Set");
  #|     set(title, "Personal-MoonAP-SKILL-Set");
  #|     set(summary, "Local reusable SKILL folders on this computer. Folder selection and save-to-local workflow are planned next.");
  #|   } else {
  #|     set(scope, "1.2 SKILL-Hub");
  #|     set(title, skillId.includes("gomoku") ? "Gomoku" : "Excel Max Amount Row");
  #|     set(summary, "This SKILL is registered in MoonAP-SKILL-Hub. Full execution UI will follow the FastQ MVP.");
  #|   }
  #|   dialog.showModal();
  #| }

///|
#cfg(target="js")
extern "js" fn browser_close_skill_dialog() -> Unit =
  #| () => document.querySelector("#skillDialog")?.close()

///|
#cfg(target="js")
extern "js" fn browser_dialog_skill_id() -> String =
  #| () => String(document.querySelector("#skillDialog")?.dataset?.skillId || "")

///|
#cfg(target="js")
extern "js" fn browser_dialog_param(name : String) -> String =
  #| (name) => String(document.querySelector(`#param-${String(name)}`)?.value || "")

///|
#cfg(target="js")
extern "js" fn browser_dialog_param_int(name : String, fallback : Int) -> Int =
  #| (name, fallback) => {
  #|   const raw = document.querySelector(`#param-${String(name)}`)?.value;
  #|   const value = Number.parseInt(String(raw || ""), 10);
  #|   return Number.isFinite(value) && value > 0 ? value : fallback;
  #| }

///|
#cfg(target="js")
extern "js" fn browser_on_dialog_run(handler : () -> Unit) -> Unit =
  #| (handler) => document.addEventListener("click", (event) => {
  #|   if (event.target?.id === "dialogRun") {
  #|     event.preventDefault();
  #|     event.stopPropagation();
  #|     globalThis.__moonapAllowDownload = "dialog-run";
  #|     handler();
  #|     setTimeout(() => {
  #|       if (globalThis.__moonapAllowDownload === "dialog-run") globalThis.__moonapAllowDownload = "";
  #|     }, 0);
  #|   }
  #| })

///|
#cfg(target="js")
extern "js" fn browser_on_dialog_cancel(handler : () -> Unit) -> Unit =
  #| (handler) => document.addEventListener("click", (event) => {
  #|   if (event.target?.id === "dialogCancel") {
  #|     event.preventDefault();
  #|     handler();
  #|   }
  #| })

///|
#cfg(target="js")
extern "js" fn browser_open_llm_dialog() -> Unit =
  #| () => {
  #|   const parseModelList = (raw) => {
  #|     const seen = new Set();
  #|     const values = String(raw || "")
  #|       .split(/\r?\n|,/)
  #|       .map((item) => String(item || "").trim())
  #|       .filter((item) => item.length > 0);
  #|     return values.filter((item) => {
  #|       const key = item.toLowerCase();
  #|       if (seen.has(key)) return false;
  #|       seen.add(key);
  #|       return true;
  #|     });
  #|   };
  #|   const normalizeProviderEntry = (item) => {
  #|     const key = String(item?.key || "").toLowerCase();
  #|     const model = String(item?.model || "").trim();
  #|     const apiKey = String(item?.apiKey || "").trim();
  #|     const enabled = Boolean(item?.enabled);
  #|     const test_status = String(item?.test_status || "").trim();
  #|     const test_message = String(item?.test_message || "").trim();
  #|     const tested_at = String(item?.tested_at || "").trim();
  #|     let baseUrl = String(item?.baseUrl || "").trim();
  #|     if (key === "gemini") {
  #|       baseUrl = "https://generativelanguage.googleapis.com";
  #|     } else if (key === "openrouter") {
  #|       baseUrl = "https://openrouter.ai/api/v1";
  #|     } else if (key === "zai") {
  #|       baseUrl = "https://open.bigmodel.cn/api/paas/v4";
  #|     } else if (key === "siliconflow") {
  #|       baseUrl = "https://api.siliconflow.cn/v1";
  #|     } else if (key === "openai") {
  #|       baseUrl = "moonap://llm-sim";
  #|     } else if (key === "nvidia") {
  #|       baseUrl = "https://integrate.api.nvidia.com/v1";
  #|     }
  #|     return { key, enabled, model, baseUrl, apiKey, test_status, test_message, tested_at };
  #|   };
  #|   const providerPriority = (provider, model) => {
  #|     const key = String(provider || "").toLowerCase();
  #|     const name = String(model || "").toLowerCase();
  #|     let score = 0;
  #|     if (name.includes("gpt-5.4")) score += 1200;
  #|     else
  #|     if (name.includes("llama-4-maverick-17b-128e-instruct")) score += 1000;
  #|     else if (name.includes("glm-5.1")) score += 900;
  #|     else if (name.includes("gemini-3-flash-preview")) score += 840;
  #|     else if (name.includes("gemini-3.1-flash-lite")) score += 820;
  #|     else if (name.includes("gemini-2.5-flash")) score += 800;
  #|     else if (name.includes("gemini-2.5-flash-lite")) score += 780;
  #|     else if (name.includes("gemini-2-flash-lite")) score += 765;
  #|     else if (name.includes("gemini-2-flash")) score += 760;
  #|     else if (name.includes("glm-5-turbo")) score += 780;
  #|     else if (name === "glm-5" || name.includes("glm-5 ")) score += 770;
  #|     else if (name.includes("glm-4.7")) score += 740;
  #|     else if (name.includes("glm-4-flashx-250414")) score += 735;
  #|     else if (name.includes("glm-4-long")) score += 730;
  #|     else if (name.includes("glm-4.6")) score += 720;
  #|     else if (name.includes("glm-4.5-airx")) score += 700;
  #|     else if (name.includes("glm-4.5-air")) score += 690;
  #|     else if (name.includes("glm-4.7-flashx")) score += 680;
  #|     else if (name.includes("glm-4.7-flash")) score += 670;
  #|     else if (name.includes("qwen2.5-coder-32b-instruct")) score += 620;
  #|     else if (name.includes("llama-4-maverick-17b-128e-instruct")) score += 610;
  #|     else if (name.includes("llama-4-scout-17b-16e-instruct")) score += 600;
  #|     else if (name.includes("llama-3.3-70b-instruct")) score += 590;
  #|     else if (name.includes("qwen2-7b-instruct")) score += 520;
  #|     else if (name.includes("glm-4-9b-chat")) score += 510;
  #|     else if (name.includes("internlm2_5-7b-chat")) score += 500;
  #|     else if (name.includes("mistral-7b-instruct")) score += 490;
  #|     else if (name.includes("chatglm3-6b")) score += 470;
  #|     else if (name.includes("qwen3-coder:free")) score += 300;
  #|     else if (name.includes("nemotron-3-super-120b-a12b:free")) score += 280;
  #|     else if (name.includes("openrouter/free")) score += 200;
  #|     else if (name.includes("openrouter/auto")) score += 180;
  #|     if (key === "openai") score += 120;
  #|     else if (key === "nvidia") score += 90;
  #|     else if (key === "zai") score += 70;
  #|     else if (key === "gemini") score += 40;
  #|     else if (key === "siliconflow") score += 30;
  #|     else if (key === "openrouter") score -= 1000;
  #|     return score;
  #|   };
  #|   const sortMoonBitProviders = (providers) => [...providers].sort((a, b) => providerPriority(b?.key, b?.model) - providerPriority(a?.key, a?.model));
  #|   const expandProviderSpec = (spec) => {
  #|     const models = parseModelList(spec?.modelsText || spec?.model || "");
  #|     if (models.length === 0) {
  #|       return [{ key: spec?.key, enabled: Boolean(spec?.enabled), model: "", baseUrl: spec?.baseUrl, apiKey: spec?.apiKey }];
  #|     }
  #|     return models.map((model) => ({ key: spec?.key, enabled: Boolean(spec?.enabled), model, baseUrl: spec?.baseUrl, apiKey: spec?.apiKey }));
  #|   };
  #|   const readRouter = () => {
  #|     try {
  #|       const parsed = JSON.parse(localStorage.getItem("moonap.llm.router.v1") || "{}");
  #|       return parsed && typeof parsed === "object" ? parsed : {};
  #|     } catch (error) {
  #|       console.warn("MoonAP reset invalid LLM router storage:", error);
  #|       try { localStorage.removeItem("moonap.llm.router.v1"); } catch {}
  #|       return {};
  #|     }
  #|   };
  #|   const routerProfileVersion = 5;
  #|   const providerConfigs = [
  #|     {
  #|       key: "openai",
  #|       enabled: true,
  #|       baseUrl: "moonap://llm-sim",
  #|       models: [
  #|         { id: "gpt-5.4", enabled: true }
  #|       ]
  #|     }
  #|   ];
  #|   const defaults = providerConfigs.flatMap((spec) =>
  #|     spec.models.map((model) => ({
  #|       key: spec.key,
  #|       enabled: Boolean(spec.enabled && model.enabled),
  #|       model: model.id,
  #|       baseUrl: spec.baseUrl,
  #|       apiKey: spec.key === "openai" ? "llm-sim-mode" : ""
  #|     }))
  #|   );
  #|   const saved = readRouter();
  #|   const mergeWithDefaults = (savedProviders, defaultProviders) => {
  #|     const savedNormalized = Array.isArray(savedProviders) ? savedProviders.map(normalizeProviderEntry) : [];
  #|     const defaultNormalized = defaultProviders.map(normalizeProviderEntry);
  #|     const keys = providerConfigs.map((item) => item.key);
  #|     const merged = [];
  #|     for (const key of keys) {
  #|       const defaultsForKey = defaultNormalized.filter((item) => item.key === key && String(item.model || "").trim() !== "");
  #|       const savedForKey = savedNormalized.filter((item) => item.key === key && String(item.model || "").trim() !== "");
  #|       const shared = savedForKey[0] || defaultsForKey[0] || { key, enabled: false, baseUrl: "", apiKey: "" };
  #|       const useSavedToggles = Number(saved?.profile_version || 0) >= routerProfileVersion;
  #|       const seen = new Map();
  #|       for (const item of defaultsForKey) {
  #|         const savedMatch = savedForKey.find((entry) => String(entry.model || "").toLowerCase() === String(item.model || "").toLowerCase());
  #|         seen.set(String(item.model || "").toLowerCase(), {
  #|           ...item,
  #|           enabled: useSavedToggles ? Boolean(savedMatch?.enabled) : Boolean(item.enabled),
  #|           baseUrl: String(shared.baseUrl || item.baseUrl || ""),
  #|           apiKey: String(shared.apiKey || ""),
  #|           test_status: String(savedMatch?.test_status || ""),
  #|           test_message: String(savedMatch?.test_message || ""),
  #|           tested_at: String(savedMatch?.tested_at || "")
  #|         });
  #|       }
  #|       merged.push(...Array.from(seen.values()));
  #|     }
  #|     return sortMoonBitProviders(merged);
  #|   };
  #|   const providers = mergeWithDefaults(saved.providers, defaults);
  #|   try {
  #|     localStorage.setItem("moonap.llm.router.v1", JSON.stringify({ providers, cursor: Number.isFinite(saved.cursor) ? saved.cursor : 0, savedAt: saved.savedAt || new Date().toISOString(), profile_version: routerProfileVersion }));
  #|   } catch {}
  #|   const grouped = {};
  #|   for (const item of providers) {
  #|     const key = String(item.key || "");
  #|     if (!grouped[key]) grouped[key] = [];
  #|     grouped[key].push(item);
  #|   }
  #|   const escapeHtml = (value) => String(value || "")
  #|     .replaceAll("&", "&amp;")
  #|     .replaceAll("<", "&lt;")
  #|     .replaceAll(">", "&gt;")
  #|     .replaceAll("\"", "&quot;");
  #|   const bind = (name, ids) => {
  #|     const items = grouped[name] || defaults.filter((entry) => entry.key === name) || [];
  #|     const item = items[0] || {};
  #|     const enable = document.querySelector(`#${ids.enable}`);
  #|     const model = document.querySelector(`#${ids.model}`);
  #|     const base = document.querySelector(`#${ids.base}`);
  #|     const key = document.querySelector(`#${ids.key}`);
  #|     if (enable) enable.checked = items.some((entry) => Boolean(entry.enabled));
  #|     if (model) {
  #|       model.innerHTML = items.map((entry, index) => {
  #|         const modelId = String(entry.model || "");
  #|         const checkboxId = `routerModelCheck-${name}-${index}`;
  #|         return `<label class="router-model-option" for="${checkboxId}"><input id="${checkboxId}" type="checkbox" data-provider="${name}" value="${escapeHtml(modelId)}" ${entry.enabled ? "checked" : ""} /><span>${escapeHtml(modelId)}</span></label>`;
  #|       }).join("");
  #|     }
  #|     if (base) base.value = String(item.baseUrl || "");
  #|     if (key) key.value = String(item.apiKey || "");
  #|     const syncDisabled = () => {
  #|       const disabled = !Boolean(enable?.checked);
  #|       model?.querySelectorAll("input[type=checkbox]")?.forEach((node) => { node.disabled = disabled; });
  #|       if (model) model.style.opacity = disabled ? "0.55" : "1";
  #|     };
  #|     enable?.addEventListener("change", syncDisabled);
  #|     syncDisabled();
  #|   };
  #|   bind("openai", { enable: "routerEnableOpenAI", model: "routerModelsOpenAI", base: "routerBaseOpenAI", key: "routerKeyOpenAI" });
  #|   document.querySelectorAll(".router-row").forEach((node, index) => {
  #|     node.style.display = index === 0 ? "" : "none";
  #|   });
  #|   const verification = localStorage.getItem("moonap.formalVerification") === "true";
  #|   const toggle = document.querySelector("#routerFormalVerification");
  #|   if (toggle) toggle.checked = verification;
  #|   const repairFeedbackRaw = localStorage.getItem("moonap.repairFeedbackMode") !== "summary";
  #|   const repairFeedbackToggle = document.querySelector("#routerRepairUseRawCompilerOutput");
  #|   if (repairFeedbackToggle) repairFeedbackToggle.checked = repairFeedbackRaw;
  #|   document.querySelector("#llmDialog")?.showModal();
  #| }

///|
#cfg(target="js")
extern "js" fn browser_llm_is_configured() -> Bool =
  #| () => {
  #|   let saved = {};
  #|   try {
  #|     const parsed = JSON.parse(localStorage.getItem("moonap.llm.router.v1") || "{}");
  #|     saved = parsed && typeof parsed === "object" ? parsed : {};
  #|   } catch (error) {
  #|     console.warn("MoonAP reset invalid LLM router storage:", error);
  #|     try { localStorage.removeItem("moonap.llm.router.v1"); } catch {}
  #|   }
  #|   const providers = Array.isArray(saved.providers) ? saved.providers : [];
  #|   return providers.some((item) => item.enabled && String(item.apiKey || "").trim() !== "" && String(item.test_status || "") !== "failed");
  #| }

///|
#cfg(target="js")
extern "js" fn browser_llm_summary() -> String =
  #| () => {
  #|   let saved = {};
  #|   try {
  #|     const parsed = JSON.parse(localStorage.getItem("moonap.llm.router.v1") || "{}");
  #|     saved = parsed && typeof parsed === "object" ? parsed : {};
  #|   } catch (error) {
  #|     console.warn("MoonAP reset invalid LLM router storage:", error);
  #|     try { localStorage.removeItem("moonap.llm.router.v1"); } catch {}
  #|   }
  #|   const providers = Array.isArray(saved.providers) ? saved.providers.filter((item) => item.enabled && String(item.apiKey || "").trim() !== "" && String(item.test_status || "") !== "failed") : [];
  #|   if (providers.length === 0) return "not configured";
  #|   const labels = providers.map((item) => `${item.key}/${item.model}`);
  #|   return `${providers.length} provider(s): ${labels.join(", ")}`;
  #| }

///|
#cfg(target="js")
extern "js" fn browser_render_onboarding() -> Unit =
  #| () => {
  #|   const root = document.querySelector("#onboardingCard");
  #|   if (!root) return;
  #|   if (globalThis.__moonapMinimalShell !== false) {
  #|     root.innerHTML = "";
  #|     root.classList.remove("is-open");
  #|     root.style.display = "none";
  #|     return;
  #|   }
  #|   const benchmarkPrompt = "Write the smallest valid cmd/main/main.mbt that compiles under wasm-gc and returns the string hello moonbit. Return only the file contents.";
  #|   const textarea = document.querySelector("#message");
  #|   const currentValue = String(textarea?.value || "").trim();
  #|   if (textarea && (currentValue === "" || textarea.classList.contains("suggested"))) {
  #|     textarea.value = benchmarkPrompt;
  #|     textarea.classList.add("suggested");
  #|   }
  #|   const readRouter = () => {
  #|     try {
  #|       const parsed = JSON.parse(localStorage.getItem("moonap.llm.router.v1") || "{}");
  #|       return parsed && typeof parsed === "object" ? parsed : {};
  #|     } catch {
  #|       return {};
  #|     }
  #|   };
  #|   const saved = readRouter();
  #|   const providers = Array.isArray(saved.providers) ? saved.providers : [];
  #|   const usable = providers.filter((item) => Boolean(item?.enabled) && String(item?.apiKey || "").trim() !== "" && String(item?.test_status || "") !== "failed");
  #|   const primary = usable[0];
  #|   const primaryLabel = primary ? `${String(primary.key || "")}/${String(primary.model || "")}` : "OpenAI/GPT-5.4 (LLM-sim)";
  #|   let benchmark = {};
  #|   try { benchmark = JSON.parse(globalThis.__moonapBenchmarkAssessment || "{}"); } catch { benchmark = {}; }
  #|   const passedLevel = Number(benchmark?.pass ? benchmark.level || 0 : 0);
  #|   const nextBenchmarkLevel = passedLevel >= 1 && passedLevel < 3 ? passedLevel + 1 : 1;
  #|   const nextBenchmarkLabel = passedLevel >= 1 && passedLevel < 3 ? `Run Benchmark L${nextBenchmarkLevel}` : "Run Benchmark L1";
  #|   const benchmarkSummary = passedLevel >= 1
  #|     ? `MoonAP already verified Benchmark L${passedLevel}. Recommended next step: run L${nextBenchmarkLevel} to keep climbing the quality ladder.`
  #|     : "MoonAP can now route requests through checked providers. Recommended next step: run MoonBit Benchmark Ladder at Level 1 to verify the full generate -> compile flow.";
  #|   const isReady = usable.length > 0;
  #|   root.classList.add("is-open");
  #|   root.innerHTML = isReady
  #|     ? `
  #|       <strong>LLM Router is ready</strong>
  #|       <small>${benchmarkSummary} Current primary route: ${primaryLabel}</small>
  #|       <div class="onboarding-actions">
  #|         <button id="onboardingRunBenchmark" type="button">${nextBenchmarkLabel}</button>
  #|         <button id="onboardingOpenSkill" class="secondary" type="button">Open SKILL</button>
  #|         <button id="onboardingEditLLM" class="secondary" type="button">Edit LLM Router</button>
  #|         <button id="onboardingOpenLog" class="secondary" type="button">Open Runtime Log</button>
  #|         <button id="onboardingDownloadLog" class="secondary" type="button">Download Log</button>
  #|       </div>`
  #|     : `
  #|       <strong>Connect an LLM to begin</strong>
  #|       <small>Use OpenAI / GPT-5.4 LLM-sim for the local multi-thread dev path, or switch to real providers later. After Save, MoonAP will test the checked models and show the usable order in Details.</small>
  #|       <div class="onboarding-actions">
  #|         <button id="onboardingEditLLM" type="button">Open LLM Router</button>
  #|         <button id="onboardingOpenSkill" class="secondary" type="button">Browse SKILL</button>
  #|         <button id="onboardingOpenLog" class="secondary" type="button">Open Runtime Log</button>
  #|       </div>`;
  #| }

///|
#cfg(target="js")
extern "js" fn browser_open_runtime_log() -> Unit =
  #| () => {
  #|   window.open("/api/logs/moonap-runtime.log", "_blank", "noopener,noreferrer");
  #| }

///|
#cfg(target="js")
extern "js" fn browser_download_runtime_log() -> Unit =
  #| async () => {
  #|   try {
  #|     const response = await fetch("/api/logs/moonap-runtime.log");
  #|     const text = await response.text();
  #|     const blob = new Blob([String(text || "")], { type: "text/plain;charset=utf-8" });
  #|     const url = URL.createObjectURL(blob);
  #|     const link = document.createElement("a");
  #|     link.href = url;
  #|     link.download = "moonap-runtime.log";
  #|     document.body.append(link);
  #|     link.click();
  #|     link.remove();
  #|     setTimeout(() => URL.revokeObjectURL(url), 1000);
  #|   } catch (error) {
  #|     throw new Error(`Runtime log download failed: ${error instanceof Error ? error.message : String(error)}`);
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_export_last_artifact_bundle(
  handler : (String) -> Unit,
) -> Unit =
  #| (handler) => document.addEventListener("click", (event) => {
  #|   if (event.target?.id !== "exportSkillBundle") return;
  #|   event.preventDefault();
  #|   event.stopPropagation();
  #|   const artifact = globalThis.__moonapLastArtifact;
  #|   if (!artifact) {
  #|     alert("No generated artifact is ready to export.");
  #|     return;
  #|   }
  #|   const folder = String(artifact?.skill?.folder_name || "personal-fastq-generator");
  #|   const source = String(artifact?.moonbit_source || "");
  #|   const compileReport = globalThis.__moonapLastCompileReport || null;
  #|   const compileOk = compileReport && typeof compileReport === "object" && compileReport.ok === true;
  #|   const compileStatus = compileReport && typeof compileReport === "object"
  #|     ? (compileReport.ok ? "done" : "failed")
  #|     : "pending";
  #|   const skillMd = [
  #|     "# Personal FastQ Generator",
  #|     "",
  #|     "MoonBit source captured by MoonAP from a real LLM response.",
  #|     "",
  #|     "## Current state",
  #|     "- LLM code generation: done",
  #|     `- MoonBit to Wasm compile: ${compileStatus}`,
  #|     "- Browser-local runtime execution: pending",
  #|     "",
  #|     "## Default parameters",
  #|     "- `read_count = 10000`",
  #|     "- `read_length = 150`",
  #|     "- `n_rate = 0.01`",
  #|     "- `random_seed = 42`",
  #|     "",
  #|     "This source bundle was exported from MoonAP for the next implementation step."
  #|   ].join("\\n");
  #|   const manifest = {
  #|     bundle_version: "moonap.source-bundle.v1",
  #|     folder_name: folder,
  #|     exported_at: new Date().toISOString(),
  #|     runtime_ready: false,
  #|     compile_ready: Boolean(compileOk),
  #|     compile_report: compileReport,
  #|     files: [
  #|       { path: "SKILL.md", content: skillMd },
  #|       { path: "moonap.skill.json", content: JSON.stringify(artifact, null, 2) },
  #|       { path: "program/main.mbt", content: source }
  #|     ]
  #|   };
  #|   const blob = new Blob([JSON.stringify(manifest, null, 2)], { type: "application/json;charset=utf-8" });
  #|   const url = URL.createObjectURL(blob);
  #|   const link = document.createElement("a");
  #|   link.href = url;
  #|   link.download = `${folder}.moonap-source-bundle.json`;
  #|   document.body.append(link);
  #|   link.click();
  #|   link.remove();
  #|   setTimeout(() => URL.revokeObjectURL(url), 0);
  #|   try { handler(String(folder)); } catch (error) { console.error("MoonAP export handler failed:", error); }
  #| })

///|
#cfg(target="js")
extern "js" fn browser_on_compile_artifact(handler : () -> Unit) -> Unit =
  #| (handler) => document.addEventListener("click", (event) => {
  #|   if (event.target?.id !== "compileArtifact") return;
  #|   event.preventDefault();
  #|   event.stopPropagation();
  #|   try {
  #|     handler();
  #|   } catch (error) {
  #|     console.error("MoonAP compile probe handler failed:", error);
  #|     alert(`MoonAP compile probe failed: ${error instanceof Error ? error.message : String(error)}`);
  #|   }
  #| })

///|
#cfg(target="js")
extern "js" fn browser_on_llm_save(handler : () -> Unit) -> Unit =
  #| (handler) => document.addEventListener("click", async (event) => {
  #|   if (event.target?.id !== "llmSave") return;
  #|   event.preventDefault();
  #|   event.stopPropagation();
  #|   const routerProfileVersion = 4;
  #|   const parseModelList = (raw) => {
  #|     const seen = new Set();
  #|     const values = String(raw || "")
  #|       .split(/\r?\n|,/)
  #|       .map((item) => String(item || "").trim())
  #|       .filter((item) => item.length > 0);
  #|     return values.filter((item) => {
  #|       const key = item.toLowerCase();
  #|       if (seen.has(key)) return false;
  #|       seen.add(key);
  #|       return true;
  #|     });
  #|   };
  #|   const normalizeProviderEntry = (item) => {
  #|     const key = String(item?.key || "").toLowerCase();
  #|     const model = String(item?.model || "").trim();
  #|     const apiKey = String(item?.apiKey || "").trim();
  #|     const enabled = Boolean(item?.enabled);
  #|     const test_status = String(item?.test_status || "").trim();
  #|     const test_message = String(item?.test_message || "").trim();
  #|     const tested_at = String(item?.tested_at || "").trim();
  #|     let baseUrl = String(item?.baseUrl || "").trim();
  #|     if (key === "gemini") {
  #|       baseUrl = "https://generativelanguage.googleapis.com";
  #|     } else if (key === "openrouter") {
  #|       baseUrl = "https://openrouter.ai/api/v1";
  #|     } else if (key === "zai") {
  #|       baseUrl = "https://open.bigmodel.cn/api/paas/v4";
  #|     } else if (key === "siliconflow") {
  #|       baseUrl = "https://api.siliconflow.cn/v1";
  #|     } else if (key === "openai") {
  #|       baseUrl = "moonap://llm-sim";
  #|     } else if (key === "nvidia") {
  #|       baseUrl = "https://integrate.api.nvidia.com/v1";
  #|     }
  #|     return { key, enabled, model, baseUrl, apiKey, test_status, test_message, tested_at };
  #|   };
  #|   const providerPriority = (provider, model) => {
  #|     const key = String(provider || "").toLowerCase();
  #|     const name = String(model || "").toLowerCase();
  #|     let score = 0;
  #|     if (name.includes("gpt-5.4")) score += 1200;
  #|     else
  #|     if (name.includes("llama-4-maverick-17b-128e-instruct")) score += 1000;
  #|     else if (name.includes("glm-5.1")) score += 900;
  #|     else if (name.includes("gemini-3-flash-preview")) score += 840;
  #|     else if (name.includes("gemini-3.1-flash-lite")) score += 820;
  #|     else if (name.includes("gemini-2.5-flash")) score += 800;
  #|     else if (name.includes("gemini-2.5-flash-lite")) score += 780;
  #|     else if (name.includes("gemini-2-flash-lite")) score += 765;
  #|     else if (name.includes("gemini-2-flash")) score += 760;
  #|     else if (name.includes("glm-5-turbo")) score += 780;
  #|     else if (name === "glm-5" || name.includes("glm-5 ")) score += 770;
  #|     else if (name.includes("glm-4.7")) score += 740;
  #|     else if (name.includes("glm-4-flashx-250414")) score += 735;
  #|     else if (name.includes("glm-4-long")) score += 730;
  #|     else if (name.includes("glm-4.6")) score += 720;
  #|     else if (name.includes("glm-4.5-airx")) score += 700;
  #|     else if (name.includes("glm-4.5-air")) score += 690;
  #|     else if (name.includes("glm-4.7-flashx")) score += 680;
  #|     else if (name.includes("glm-4.7-flash")) score += 670;
  #|     else if (name.includes("qwen2.5-coder-32b-instruct")) score += 620;
  #|     else if (name.includes("llama-4-maverick-17b-128e-instruct")) score += 610;
  #|     else if (name.includes("llama-4-scout-17b-16e-instruct")) score += 600;
  #|     else if (name.includes("llama-3.3-70b-instruct")) score += 590;
  #|     else if (name.includes("qwen2-7b-instruct")) score += 520;
  #|     else if (name.includes("glm-4-9b-chat")) score += 510;
  #|     else if (name.includes("internlm2_5-7b-chat")) score += 500;
  #|     else if (name.includes("mistral-7b-instruct")) score += 490;
  #|     else if (name.includes("chatglm3-6b")) score += 470;
  #|     else if (name.includes("qwen3-coder:free")) score += 300;
  #|     else if (name.includes("nemotron-3-super-120b-a12b:free")) score += 280;
  #|     else if (name.includes("openrouter/free")) score += 200;
  #|     else if (name.includes("openrouter/auto")) score += 180;
  #|     if (key === "openai") score += 120;
  #|     else if (key === "nvidia") score += 90;
  #|     else if (key === "zai") score += 70;
  #|     else if (key === "gemini") score += 40;
  #|     else if (key === "siliconflow") score += 30;
  #|     else if (key === "openrouter") score -= 1000;
  #|     return score;
  #|   };
  #|   const sortMoonBitProviders = (providers) => [...providers].sort((a, b) => providerPriority(b?.key, b?.model) - providerPriority(a?.key, a?.model));
  #|   const collectCheckedModels = (selector) => Array.from(document.querySelectorAll(`${selector} input[type=checkbox]:checked`)).map((node) => String(node.value || "").trim()).filter((value) => value.length > 0);
  #|   const providerSpecs = [
  #|     { key: "openai", enabled: Boolean(document.querySelector("#routerEnableOpenAI")?.checked), models: collectCheckedModels("#routerModelsOpenAI"), baseUrl: String(document.querySelector("#routerBaseOpenAI")?.value || "").trim(), apiKey: String(document.querySelector("#routerKeyOpenAI")?.value || "").trim() },
  #|     { key: "nvidia", enabled: Boolean(document.querySelector("#routerEnableNVIDIA")?.checked), models: collectCheckedModels("#routerModelsNVIDIA"), baseUrl: String(document.querySelector("#routerBaseNVIDIA")?.value || "").trim(), apiKey: String(document.querySelector("#routerKeyNVIDIA")?.value || "").trim() },
  #|     { key: "zai", enabled: Boolean(document.querySelector("#routerEnableZAI")?.checked), models: collectCheckedModels("#routerModelsZAI"), baseUrl: String(document.querySelector("#routerBaseZAI")?.value || "").trim(), apiKey: String(document.querySelector("#routerKeyZAI")?.value || "").trim() },
  #|     { key: "gemini", enabled: Boolean(document.querySelector("#routerEnableGemini")?.checked), models: collectCheckedModels("#routerModelsGemini"), baseUrl: String(document.querySelector("#routerBaseGemini")?.value || "").trim(), apiKey: String(document.querySelector("#routerKeyGemini")?.value || "").trim() },
  #|     { key: "siliconflow", enabled: Boolean(document.querySelector("#routerEnableSiliconFlow")?.checked), models: collectCheckedModels("#routerModelsSiliconFlow"), baseUrl: String(document.querySelector("#routerBaseSiliconFlow")?.value || "").trim(), apiKey: String(document.querySelector("#routerKeySiliconFlow")?.value || "").trim() },
  #|     { key: "openrouter", enabled: Boolean(document.querySelector("#routerEnableOpenRouter")?.checked), models: collectCheckedModels("#routerModelsOpenRouter"), baseUrl: String(document.querySelector("#routerBaseOpenRouter")?.value || "").trim(), apiKey: String(document.querySelector("#routerKeyOpenRouter")?.value || "").trim() }
  #|   ];
  #|   const providers = providerSpecs.flatMap((item) => item.models.map((model) => ({
  #|     key: item.key,
  #|     enabled: Boolean(item.enabled),
  #|     model,
  #|     baseUrl: item.baseUrl,
  #|     apiKey: item.apiKey
  #|   })));
  #|   const sortedProviders = sortMoonBitProviders(providers.map(normalizeProviderEntry));
  #|   const active = sortedProviders.filter((item) => item.enabled && item.apiKey);
  #|   if (active.length === 0) {
  #|     alert("Please enable at least one provider, check at least one model under it, and fill its API key.");
  #|     return;
  #|   }
  #|   const statusNode = document.querySelector("#routerTestStatus");
  #|   const saveButton = document.querySelector("#llmSave");
  #|   const dialog = document.querySelector("#llmDialog");
  #|   const setStatus = (text) => {
  #|     if (statusNode) statusNode.textContent = String(text || "");
  #|   };
  #|   const openDetails = () => {
  #|     const root = document.querySelector(".app-shell");
  #|     const button = document.querySelector("#detailsToggle");
  #|     if (!root || !button) return;
  #|     root.classList.add("details-open");
  #|     button.setAttribute("aria-expanded", "true");
  #|   };
  #|   const updateProcess = (provider, stage, result, logText) => {
  #|     const setText = (selector, value) => {
  #|       const node = document.querySelector(selector);
  #|       if (node) node.textContent = String(value);
  #|     };
  #|     setText("#processProvider", provider || "-");
  #|     setText("#processStage", stage || "-");
  #|     setText("#processResult", result || "waiting");
  #|     setText("#processLog", logText || "");
  #|   };
  #|   const proxyPost = async (url, headers, body) => {
  #|     const envelope = [
  #|       `URL\t${String(url)}`,
  #|       ...Object.entries(headers || {}).map(([key, value]) => `HEADER\t${String(key)}\t${String(value).replace(/\r?\n/g, " ")}`),
  #|       "BODY",
  #|       String(body)
  #|     ].join("\n");
  #|     const controller = new AbortController();
  #|     const timeout = setTimeout(() => controller.abort(), 8000);
  #|     try {
  #|       const response = await fetch("/api/llm/proxy", {
  #|         method: "POST",
  #|         headers: { "Content-Type": "text/plain; charset=utf-8" },
  #|         body: envelope,
  #|         signal: controller.signal
  #|       });
  #|       const text = await response.text();
  #|       let json = {};
  #|       try {
  #|         json = JSON.parse(text);
  #|       } catch {
  #|         const plain = String(text || "").replace(/<script[\s\S]*?<\/script>/gi, " ").replace(/<style[\s\S]*?<\/style>/gi, " ").replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
  #|         throw new Error(`Provider returned non-JSON (${response.status}): ${(plain || text || "").slice(0, 180)}`);
  #|       }
  #|       if (!response.ok) {
  #|         const detail = json?.error?.detail ? ` ${String(json.error.detail)}` : "";
  #|         throw new Error((json?.error?.message || `LLM request failed (${response.status})`) + detail);
  #|       }
  #|       return json;
  #|     } catch (error) {
  #|       if (error && error.name === "AbortError") {
  #|         throw new Error("Timed out after 8s");
  #|       }
  #|       throw error;
  #|     } finally {
  #|       clearTimeout(timeout);
  #|     }
  #|   };
  #|   const testProvider = async (llm) => {
  #|     if (llm.key === "gemini") {
  #|       const url = `${llm.baseUrl}/v1beta/models/${encodeURIComponent(llm.model)}:generateContent`;
  #|       const json = await proxyPost(url, {
  #|         "Content-Type": "application/json",
  #|         "x-goog-api-key": String(llm.apiKey || "")
  #|       }, JSON.stringify({
  #|         contents: [{ role: "user", parts: [{ text: "Reply with OK." }] }],
  #|         generationConfig: { temperature: 0, maxOutputTokens: 8 }
  #|       }));
  #|       const text = (json?.candidates?.[0]?.content?.parts || []).map((part) => String(part?.text || "")).join(" ").trim();
  #|       return text || "OK";
  #|     }
  #|     let urlBase = String(llm.baseUrl || "").trim();
  #|     urlBase = urlBase.endsWith("/") ? urlBase.slice(0, -1) : urlBase;
  #|     let url = `${urlBase}/chat/completions`;
  #|     if (llm.key === "zai") {
  #|       if (urlBase.endsWith("/chat/completions")) {
  #|         url = urlBase;
  #|       } else if (!urlBase.includes("/api/paas/v4")) {
  #|         url = `${urlBase}/api/paas/v4/chat/completions`;
  #|       }
  #|     }
  #|     const headers = {
  #|       "Content-Type": "application/json",
  #|       "Authorization": `Bearer ${String(llm.apiKey || "")}`
  #|     };
  #|     if (llm.key === "openrouter") {
  #|       headers["HTTP-Referer"] = "http://127.0.0.1:3000";
  #|       headers["X-Title"] = "MoonAP";
  #|     }
  #|     const json = await proxyPost(url, headers, JSON.stringify({
  #|       model: llm.model,
  #|       messages: [{ role: "user", content: "Reply with OK." }],
  #|       temperature: 0,
  #|       max_tokens: 8
  #|     }));
  #|     const text = String(json?.choices?.[0]?.message?.content || "").trim();
  #|     return text || "OK";
  #|   };
  #|   localStorage.setItem("moonap.formalVerification", String(Boolean(document.querySelector("#routerFormalVerification")?.checked)));
  #|   localStorage.setItem("moonap.repairFeedbackMode", Boolean(document.querySelector("#routerRepairUseRawCompilerOutput")?.checked) ? "raw" : "summary");
  #|   const enabled = localStorage.getItem("moonap.formalVerification") === "true";
  #|   const mainToggle = document.querySelector("#formalVerification");
  #|   if (mainToggle) mainToggle.checked = enabled;
  #|   if (saveButton) {
  #|     saveButton.disabled = true;
  #|     saveButton.textContent = "Saving...";
  #|   }
  #|   setStatus("Saving router config and testing enabled LLM APIs...");
  #|   openDetails();
  #|   dialog?.close();
  #|   updateProcess(
  #|     "LLM Router",
  #|     "llm-api-test",
  #|     "running",
  #|     "Saving router config and testing enabled LLM APIs..."
  #|   );
  #|   try {
  #|     const lines = [];
  #|     const results = [];
  #|     for (const item of active) {
  #|       const label = `${item.key}/${item.model}`;
  #|       lines.push(`[running] ${label}`);
  #|       setStatus(lines.join("\n"));
  #|       updateProcess("LLM Router", "llm-api-test", "running", lines.join("\n"));
  #|       try {
  #|         const result = await testProvider(item);
  #|         lines[lines.length - 1] = `[ok] ${label} -> ${String(result).slice(0, 80)}`;
  #|         results.push({ key: item.key, model: item.model, ok: true, message: String(result || "OK") });
  #|       } catch (error) {
  #|         const message = error instanceof Error ? error.message : String(error);
  #|         lines[lines.length - 1] = `[failed] ${label} -> ${message}`;
  #|         results.push({ key: item.key, model: item.model, ok: false, message });
  #|       }
  #|       setStatus(lines.join("\n"));
  #|       updateProcess("LLM Router", "llm-api-test", "running", lines.join("\n"));
  #|     }
  #|     const testedAt = new Date().toISOString();
  #|     const providersWithHealth = sortedProviders.map((item) => {
  #|       const match = results.find((result) => result.key === item.key && result.model === item.model);
  #|       if (!item.enabled || !item.apiKey || !item.model) {
  #|         return { ...item, test_status: "skipped", test_message: "Disabled or incomplete.", tested_at: testedAt };
  #|       }
  #|       if (!match) {
  #|         return { ...item, test_status: "failed", test_message: "No test result captured.", tested_at: testedAt };
  #|       }
  #|       return { ...item, test_status: match.ok ? "ok" : "failed", test_message: match.message, tested_at: testedAt };
  #|     });
  #|     const usable = providersWithHealth.filter((item) => item.enabled && item.apiKey && item.test_status === "ok");
  #|     const orderLines = usable.length === 0
  #|       ? ["No enabled provider passed the API test."]
  #|       : usable.map((item, index) => `${index + 1}. ${item.key}/${item.model}`);
  #|     const summary = lines.join("\n") + "\n\nFinal usable provider order:\n" + orderLines.join("\n");
  #|     localStorage.setItem("moonap.llm.router.v1", JSON.stringify({
  #|       providers: providersWithHealth,
  #|       cursor: 0,
  #|       savedAt: testedAt,
  #|       last_test_summary: summary,
  #|       profile_version: routerProfileVersion
  #|     }));
  #|     setStatus(summary);
  #|     updateProcess(
  #|       usable.length === 0 ? "LLM Router" : usable.map((item) => `${item.key}/${item.model}`).join(", "),
  #|       "llm-api-test",
  #|       usable.length === 0 ? "failed" : "succeeded",
  #|       summary
  #|     );
  #|     handler();
  #|   } catch (error) {
  #|     console.error("MoonAP llm save handler failed:", error);
  #|     const message = error instanceof Error ? error.message : String(error);
  #|     setStatus(message);
  #|     updateProcess("LLM Router", "llm-api-test", "failed", message);
  #|     alert(`MoonAP LLM save failed: ${message}`);
  #|   } finally {
  #|     if (saveButton) {
  #|       saveButton.disabled = false;
  #|       saveButton.textContent = "Save";
  #|     }
  #|   }
  #| })

///|
extern "js" fn browser_on_llm_cancel(handler : () -> Unit) -> Unit =
  #| (handler) => document.addEventListener("click", (event) => {
  #|   if (event.target?.id !== "llmCancel") return;
  #|   event.preventDefault();
  #|   document.querySelector("#llmDialog")?.close();
  #|   try {
  #|     handler();
  #|   } catch (error) {
  #|     console.error("MoonAP llm cancel handler failed:", error);
  #|   }
  #| })

///|
#cfg(target="js")
extern "js" fn browser_generate_moonbit_artifact(
  task_title : String,
  prompt : String,
  simple_mode : Bool,
  formal_verification : Bool,
  knowledge_pack : String,
  on_done : (String) -> Unit,
  on_error : (String) -> Unit,
) -> Unit =
  #| async (taskTitle, prompt, simpleMode, formalVerification, knowledgePack, onDone, onError) => {
  #|   try {
  #|     const readRouter = () => {
  #|       try {
  #|         const parsed = JSON.parse(localStorage.getItem("moonap.llm.router.v1") || "{}");
  #|         return parsed && typeof parsed === "object" ? parsed : {};
  #|       } catch (error) {
  #|         console.warn("MoonAP reset invalid LLM router storage:", error);
  #|         try { localStorage.removeItem("moonap.llm.router.v1"); } catch {}
  #|         return {};
  #|       }
  #|     };
  #|     const saved = readRouter();
  #|     const providers = Array.isArray(saved.providers) ? saved.providers.filter((item) => item.enabled && String(item.apiKey || "").trim() !== "" && String(item.test_status || "") !== "failed") : [];
  #|     if (providers.length === 0) {
  #|       throw new Error("No enabled LLM provider is available in the router.");
  #|     }
  #|     const cursor = Number.isFinite(saved.cursor) ? saved.cursor : 0;
  #|     const start = ((cursor % providers.length) + providers.length) % providers.length;
  #|     const ordered = providers.slice(start).concat(providers.slice(0, start));
  #|     const lowerTaskTitle = String(taskTitle || "").toLowerCase();
  #|     const lowerPrompt = String(prompt || "").toLowerCase();
  #|     const inferTaskKind = () => {
  #|       if (lowerPrompt.includes("fastq") || lowerTaskTitle.includes("fastq")) return "fastq-generator";
  #|       if (lowerPrompt.includes("excel") || lowerPrompt.includes("xlsx") || lowerPrompt.includes("spreadsheet")) return "excel-analysis";
  #|       if ((lowerPrompt.includes("browser") && lowerPrompt.includes("game")) || lowerTaskTitle.includes("game")) return "browser-game";
  #|       return "generic-moonbit";
  #|     };
  #|     const taskAdapterLines = (taskKind) => {
  #|       if (taskKind === "fastq-generator") {
  #|         return [
  #|           "- generate one or more valid FastQ records",
  #|           "- each record should include header, sequence, plus line, and quality line"
  #|         ];
  #|       }
  #|       if (taskKind === "excel-analysis") {
  #|         return [
  #|           "- assume the task logic should work on spreadsheet-like tabular input",
  #|           "- keep the result representation simple and easy for MoonAP to inspect or display"
  #|         ];
  #|       }
  #|       if (taskKind === "browser-game") {
  #|         return [
  #|           "- keep the gameplay loop simple and direct",
  #|           "- keep the program structure easy to compile and run inside MoonAP"
  #|         ];
  #|       }
  #|       return [];
  #|     };
  #|     const updatePrompts = (modeText, systemPromptText, userPromptText) => {
  #|       const setText = (selector, value) => {
  #|         const node = document.querySelector(selector);
  #|         if (node) node.textContent = String(value);
  #|       };
  #|       setText("#promptMode", modeText || "No LLM prompt captured yet.");
  #|       setText("#promptSystem", systemPromptText || "No LLM prompt captured yet.");
  #|       setText("#promptUser", userPromptText || "No LLM prompt captured yet.");
  #|     };
  #|     const buildCodegenPrompts = (llm) => {
  #|       const modelName = String(llm?.model || "");
  #|       const isGpt54 = modelName.toLowerCase().includes("gpt-5.4");
  #|       const taskKind = inferTaskKind();
  #|       const adapter = taskAdapterLines(taskKind);
  #|       if (isGpt54) {
  #|         const systemPrompt = [
  #|           "You are an AI coder.",
  #|           "You only write MoonBit code.",
  #|           "Your job is to write MoonBit code for the user's task.",
  #|           "Return only the full contents of cmd/main/main.mbt."
  #|         ].join("\\n");
  #|         return {
  #|           modeText: "codegen / frontier-direct",
  #|           systemPrompt,
  #|           userPrompt: String(prompt || "")
  #|         };
  #|       }
  #|       const systemPrompt = simpleMode
  #|         ? [
  #|             "You write MoonBit code.",
  #|             "Return ONLY cmd/main/main.mbt.",
  #|             "No markdown fences.",
  #|             "No explanations.",
  #|             "Use valid MoonBit syntax only."
  #|           ].join("\\n")
  #|         : [
  #|             "You are generating MoonBit code for MoonAP.",
  #|             "Target language: MoonBit 0.9.",
  #|             "Output contract:",
  #|             "- Return ONLY the contents of cmd/main/main.mbt.",
  #|             "- Do NOT return markdown fences.",
  #|             "- Do NOT return explanations.",
  #|             "- Do NOT return moon.pkg or moon.mod.json.",
  #|             "- Use valid MoonBit syntax only.",
  #|             "- The MoonBit primer in the user prompt overrides stale prior memory."
  #|           ].join("\\n");
  #|       const userPrompt = [
  #|         "Read this MoonBit 0.9 primer first and follow it strictly:",
  #|         String(knowledgePack || ""),
  #|         "",
  #|         `MoonAP task title: ${String(taskTitle || "MoonBit task")}`,
  #|         "",
  #|         String(prompt),
  #|         "",
  #|         "Again: return ONLY cmd/main/main.mbt source."
  #|       ].join("\\n");
  #|       return {
  #|         modeText: simpleMode ? "codegen / simple" : "codegen / guided",
  #|         systemPrompt,
  #|         userPrompt
  #|       };
  #|     };
  #|     const proxyPost = async (url, headers, body) => {
  #|       const envelope = [
  #|         `URL\t${String(url)}`,
  #|         ...Object.entries(headers || {}).map(([key, value]) => `HEADER\t${String(key)}\t${String(value).replace(/\r?\n/g, " ")}`),
  #|         "BODY",
  #|         String(body)
  #|       ].join("\n");
  #|       const response = await fetch("/api/llm/proxy", {
  #|         method: "POST",
  #|         headers: { "Content-Type": "text/plain; charset=utf-8" },
  #|         body: envelope
  #|       });
  #|       const text = await response.text();
  #|       let json = {};
  #|       try {
  #|         json = JSON.parse(text);
  #|       } catch {
  #|         const plain = String(text || "")
  #|           .replace(/<script[\s\S]*?<\/script>/gi, " ")
  #|           .replace(/<style[\s\S]*?<\/style>/gi, " ")
  #|           .replace(/<[^>]+>/g, " ")
  #|           .replace(/\s+/g, " ")
  #|           .trim();
  #|         const summarized = plain || `MoonAP proxy returned non-JSON (${response.status})`;
  #|         throw new Error(`Provider returned non-JSON (${response.status}): ${summarized.slice(0, 240)}`);
  #|       }
  #|       if (!response.ok) {
  #|         const detail = json?.error?.detail ? ` ${String(json.error.detail)}` : "";
  #|         throw new Error((json?.error?.message || `LLM request failed (${response.status})`) + detail);
  #|       }
  #|       return json;
  #|     };
  #|     const requestJson = async (llm) => {
  #|       const promptPack = buildCodegenPrompts(llm);
  #|       updatePrompts(promptPack.modeText, promptPack.systemPrompt, promptPack.userPrompt);
  #|       const codegenConversationHistory = [
  #|         { role: "user", content: String(prompt || "") }
  #|       ];
  #|       if (llm.provider === "gemini") {
  #|         const url = `${llm.baseUrl}/v1beta/models/${encodeURIComponent(llm.model)}:generateContent`;
  #|         const json = await proxyPost(
  #|           url,
  #|           { "Content-Type": "application/json", "x-goog-api-key": String(llm.apiKey || "") },
  #|           JSON.stringify({
  #|             system_instruction: { parts: [{ text: promptPack.systemPrompt }] },
  #|             contents: [{ role: "user", parts: [{ text: promptPack.userPrompt }] }],
  #|             generationConfig: { temperature: 0.2 }
  #|           })
  #|         );
  #|         const text = (json?.candidates?.[0]?.content?.parts || []).map((part) => String(part?.text || "")).join("\\n").trim();
  #|         if (!text) throw new Error("Gemini returned no MoonBit source.");
  #|         return { source: text, raw: json, conversation_history: codegenConversationHistory };
  #|       }
  #|       const rawBaseUrl = String(llm.baseUrl || "").trim();
  #|       const baseUrl = rawBaseUrl.endsWith("/") ? rawBaseUrl.slice(0, -1) : rawBaseUrl;
  #|       let url = `${baseUrl}/chat/completions`;
  #|       if (llm.provider === "zai") {
  #|         if (baseUrl.endsWith("/chat/completions")) {
  #|           url = baseUrl;
  #|         } else if (baseUrl === "https://open.bigmodel.cn" || baseUrl === "https://open.bigmodel.cn/") {
  #|           url = "https://open.bigmodel.cn/api/paas/v4/chat/completions";
  #|         } else if (!baseUrl.includes("/api/paas/v4")) {
  #|           url = `${baseUrl}/api/paas/v4/chat/completions`;
  #|         }
  #|       }
  #|       const headers = {
  #|         "Content-Type": "application/json",
  #|         "Authorization": `Bearer ${String(llm.apiKey || "")}`
  #|       };
  #|       if (llm.provider === "openrouter") {
  #|         headers["HTTP-Referer"] = "http://127.0.0.1:3000";
  #|         headers["X-Title"] = "MoonAP";
  #|       }
  #|       const json = await proxyPost(
  #|         url,
  #|         headers,
  #|         JSON.stringify({
  #|           model: llm.model,
  #|           messages: [
  #|             { role: "system", content: promptPack.systemPrompt },
  #|             { role: "user", content: promptPack.userPrompt }
  #|           ],
  #|           temperature: 0.2
  #|         })
  #|       );
  #|       const text = String(json?.choices?.[0]?.message?.content || "").trim();
  #|       if (!text) throw new Error(`${llm.provider} returned no MoonBit source.`);
  #|       return { source: text, raw: json, conversation_history: codegenConversationHistory };
  #|     };
  #|     let generated = null;
  #|     let llm = null;
  #|     const failures = [];
  #|     for (let index = 0; index < ordered.length; index += 1) {
  #|       const item = ordered[index];
  #|       const candidate = {
  #|         provider: item.key,
  #|         model: item.model,
  #|         baseUrl: item.baseUrl,
  #|         apiKey: item.apiKey,
  #|         rotated: providers.length > 1
  #|       };
  #|       try {
  #|         generated = await requestJson(candidate);
  #|         llm = candidate;
  #|         const nextCursor = (start + index + 1) % providers.length;
  #|         localStorage.setItem("moonap.llm.router.v1", JSON.stringify({
  #|           providers: Array.isArray(saved.providers) ? saved.providers : providers,
  #|           cursor: nextCursor,
  #|           savedAt: saved.savedAt || new Date().toISOString()
  #|         }));
  #|         break;
  #|       } catch (error) {
  #|         failures.push(`${String(item.key || "provider")}/${String(item.model || "model")}: ${error instanceof Error ? error.message : String(error)}`);
  #|       }
  #|     }
  #|     if (!generated || !llm) {
  #|       throw new Error(`All enabled providers failed during code generation. ${failures.join(" | ")}`);
  #|     }
  #|     const ensureExtractMoonBitSource = () => {
  #|       if (typeof globalThis.__moonapExtractMoonBitSource === "function") return globalThis.__moonapExtractMoonBitSource;
  #|       globalThis.__moonapExtractMoonBitSource = (value) => {
  #|         const text = String(value || "").trim();
  #|         if (!text) return "";
  #|         const extract = (source, startMarker, endMarker) => {
  #|           const start = source.indexOf(startMarker);
  #|           if (start < 0) return "";
  #|           const after = source.slice(start + startMarker.length).trim();
  #|           if (!after) return "";
  #|           const end = after.indexOf(endMarker);
  #|           if (end < 0) return "";
  #|           return after.slice(0, end).trim();
  #|         };
  #|         const patterns = [
  #|           ["FILE: cmd/main/main.mbt", "END_FILE"],
  #|           ['<moonbit-file path="cmd/main/main.mbt">', "</moonbit-file>"],
  #|           ["```moonbit", "```"],
  #|           ["```mbt", "```"],
  #|           ["```", "```"]
  #|         ];
  #|         for (const [startMarker, endMarker] of patterns) {
  #|           const extracted = extract(text, startMarker, endMarker);
  #|           if (extracted) return extracted;
  #|         }
  #|         return text;
  #|       };
  #|       return globalThis.__moonapExtractMoonBitSource;
  #|     };
  #|     const source = ensureExtractMoonBitSource()(String(generated.source || ""));
  #|     const slug = String(taskTitle || "moonbit-task")
  #|       .toLowerCase()
  #|       .replace(/[^a-z0-9]+/g, "-")
  #|       .replace(/^-+|-+$/g, "") || "moonbit-task";
  #|     const artifact = {
  #|       schema_version: "moonap.artifact.v1",
  #|       id: slug,
  #|       name: String(taskTitle || "MoonBit Task"),
  #|       prompt: String(prompt),
  #|       llm_provider: llm.provider || "unknown",
  #|       llm_model: llm.model || "unknown",
  #|       llm_rotated: Boolean(llm.rotated),
  #|       stages: [
  #|         { name: "llm-codegen", status: "ok", output: `MoonBit source generated by ${llm.provider}/${llm.model}` },
  #|         { name: "formal-verification", status: formalVerification ? "reserved" : "skipped", output: formalVerification ? "moon prove hook reserved" : "disabled by user/default" },
  #|         { name: "moonbit-wasm-compile", status: "pending", output: "Real MoonBit-to-Wasm compile is the next implementation step." },
  #|         { name: "browser-local-run", status: "pending", output: "Browser-local execution will start after compile is wired." }
  #|       ],
  #|       skill: {
  #|         folder_name: slug,
  #|         description_file: "SKILL.md",
  #|         program_dir: "program",
  #|         parameters: {}
  #|       },
  #|       moonbit_source: source,
  #|       conversation_history: [
  #|         ...(Array.isArray(generated?.conversation_history) ? generated.conversation_history : [{ role: "user", content: String(prompt || "") }]),
  #|         { role: "assistant", content: source }
  #|       ],
  #|       knowledge_pack_version: "moonbit-primer-v1",
  #|       llm_response_preview: JSON.stringify(generated.raw).slice(0, 1200),
  #|       wasm_runtime: {
  #|         target: "wasm-gc",
  #|         browser_local: true,
  #|         uploaded_bytes: 0,
  #|         note: "Pending real compile and runtime execution."
  #|       },
  #|       created_at: new Date().toISOString()
  #|     };
  #|     globalThis.__moonapLastArtifact = artifact;
  #|     onDone(JSON.stringify(artifact, null, 2));
  #|   } catch (error) {
  #|     onError(error instanceof Error ? error.message : String(error));
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_run_free_llm_moonbit_eval(
  max_level : Int,
  on_done : (String) -> Unit,
  on_error : (String) -> Unit,
) -> Unit =
  #| async (maxLevel, onDone, onError) => {
  #|   try {
  #|     if (globalThis.__moonapEvalRunning) {
  #|       throw new Error("A MoonBit experiment run is already in progress.");
  #|     }
  #|     globalThis.__moonapEvalRunning = true;
  #|     const clampLevel = (value) => Math.max(1, Math.min(3, Number(value || 3)));
  #|     const nowIso = () => new Date().toISOString();
  #|     const ensureExtractMoonBitSource = () => {
  #|       if (typeof globalThis.__moonapExtractMoonBitSource === "function") return globalThis.__moonapExtractMoonBitSource;
  #|       globalThis.__moonapExtractMoonBitSource = (value) => {
  #|         const sourceText = String(value || "").trim();
  #|         if (!sourceText) return "";
  #|         const extract = (source, startMarker, endMarker) => {
  #|           const start = source.indexOf(startMarker);
  #|           if (start < 0) return "";
  #|           const after = source.slice(start + startMarker.length).trim();
  #|           if (!after) return "";
  #|           const end = after.indexOf(endMarker);
  #|           if (end < 0) return "";
  #|           return after.slice(0, end).trim();
  #|         };
  #|         const patterns = [
  #|           ["FILE: cmd/main/main.mbt", "END_FILE"],
  #|           ['<moonbit-file path="cmd/main/main.mbt">', "</moonbit-file>"],
  #|           ["```moonbit", "```"],
  #|           ["```mbt", "```"],
  #|           ["```", "```"]
  #|         ];
  #|         for (const [startMarker, endMarker] of patterns) {
  #|           const extracted = extract(sourceText, startMarker, endMarker);
  #|           if (extracted) return extracted;
  #|         }
  #|         return sourceText;
  #|       };
  #|       return globalThis.__moonapExtractMoonBitSource;
  #|     };
  #|     const cleanSource = (text) => ensureExtractMoonBitSource()(String(text || ""));
  #|     const parseModelList = (raw) => {
  #|       const seen = new Set();
  #|       return String(raw || "")
  #|         .split(/\r?\n|,/)
  #|         .map((item) => String(item || "").trim())
  #|         .filter((item) => item.length > 0)
  #|         .filter((item) => {
  #|           const key = item.toLowerCase();
  #|           if (seen.has(key)) return false;
  #|           seen.add(key);
  #|           return true;
  #|         });
  #|     };
  #|     const normalizeProviderEntry = (item) => {
  #|       const key = String(item?.key || "").toLowerCase();
  #|       let baseUrl = String(item?.baseUrl || "").trim();
  #|       if (key === "gemini") baseUrl = "https://generativelanguage.googleapis.com";
  #|       else if (key === "openrouter") baseUrl = "https://openrouter.ai/api/v1";
  #|       else if (key === "zai") baseUrl = "https://open.bigmodel.cn/api/paas/v4";
  #|       else if (key === "siliconflow") baseUrl = "https://api.siliconflow.cn/v1";
  #|       else if (key === "openai") baseUrl = "moonap://llm-sim";
  #|       else if (key === "nvidia") baseUrl = "https://integrate.api.nvidia.com/v1";
  #|       return {
  #|         key,
  #|         provider: key,
  #|         enabled: Boolean(item?.enabled),
  #|         model: String(item?.model || "").trim(),
  #|         baseUrl,
  #|         apiKey: String(item?.apiKey || "").trim()
  #|       };
  #|     };
  #|     const readRouter = () => {
  #|       try {
  #|         const parsed = JSON.parse(localStorage.getItem("moonap.llm.router.v1") || "{}");
  #|         return parsed && typeof parsed === "object" ? parsed : {};
  #|       } catch {
  #|         return {};
  #|       }
  #|     };
  #|     const updatePrompts = (modeText, systemPromptText, userPromptText) => {
  #|       const setText = (selector, value) => {
  #|         const node = document.querySelector(selector);
  #|         if (node) node.textContent = String(value || "");
  #|       };
  #|       setText("#promptMode", modeText || "No LLM prompt captured yet.");
  #|       setText("#promptSystem", systemPromptText || "No LLM prompt captured yet.");
  #|       setText("#promptUser", userPromptText || "No LLM prompt captured yet.");
  #|     };
  #|     const updateProcess = (provider, stage, result, logText, sourceText = "") => {
  #|       const setText = (selector, value) => {
  #|         const node = document.querySelector(selector);
  #|         if (node) node.textContent = String(value || "");
  #|       };
  #|       setText("#processProvider", provider || "-");
  #|       setText("#processStage", stage || "-");
  #|       setText("#processResult", result || "waiting");
  #|       setText("#processLog", logText || "");
  #|       if (sourceText !== "") setText("#processSource", sourceText || "No generated source yet.");
  #|     };
  #|     const proxyPost = async (url, headers, body, timeoutMs) => {
  #|       const envelope = [
  #|         `URL\t${String(url)}`,
  #|         ...Object.entries(headers || {}).map(([key, value]) => `HEADER\t${String(key)}\t${String(value).replace(/\r?\n/g, " ")}`),
  #|         "BODY",
  #|         String(body)
  #|       ].join("\n");
  #|       const controller = new AbortController();
  #|       const timeout = setTimeout(() => controller.abort(), timeoutMs);
  #|       const started = performance.now();
  #|       try {
  #|         const response = await fetch("/api/llm/proxy", {
  #|           method: "POST",
  #|           headers: { "Content-Type": "text/plain; charset=utf-8" },
  #|           body: envelope,
  #|           signal: controller.signal
  #|         });
  #|         const text = await response.text();
  #|         let json = {};
  #|         try {
  #|           json = JSON.parse(text);
  #|         } catch {
  #|           const plain = String(text || "").replace(/<script[\s\S]*?<\/script>/gi, " ").replace(/<style[\s\S]*?<\/style>/gi, " ").replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
  #|           const err = new Error(`Provider returned non-JSON (${response.status}): ${(plain || text || "").slice(0, 240)}`);
  #|           err.nonJson = true;
  #|           err.httpStatus = response.status;
  #|           throw err;
  #|         }
  #|         if (!response.ok) {
  #|           const detail = json?.error?.detail ? ` ${String(json.error.detail)}` : "";
  #|           const err = new Error((json?.error?.message || `LLM request failed (${response.status})`) + detail);
  #|           err.httpStatus = response.status;
  #|           throw err;
  #|         }
  #|         return { json, latencyMs: Math.round(performance.now() - started) };
  #|       } catch (error) {
  #|         if (error && error.name === "AbortError") {
  #|           const timeoutError = new Error(`Timed out after ${Math.round(timeoutMs / 1000)}s`);
  #|           timeoutError.timeout = true;
  #|           throw timeoutError;
  #|         }
  #|         throw error;
  #|       } finally {
  #|         clearTimeout(timeout);
  #|       }
  #|     };
  #|     const compileSource = async (sourceText) => {
  #|       const response = await fetch("/api/artifact/compile", {
  #|         method: "POST",
  #|         headers: { "Content-Type": "text/plain; charset=utf-8" },
  #|         body: String(sourceText || "")
  #|       });
  #|       const text = await response.text();
  #|       return JSON.parse(text);
  #|     };
  #|     const buildMarkdown = (results) => {
  #|       const models = Array.isArray(results?.models) ? results.models : [];
  #|       const formatCell = (benchmark) => {
  #|         if (!benchmark?.attempted) return "not-run";
  #|         if (benchmark?.raw_codegen_pass) return "raw-pass";
  #|         if (benchmark?.assisted_pass) return `assist-pass (${Number(benchmark?.repair_attempts_used || 0)} repairs)`;
  #|         return "fail";
  #|       };
  #|       return [
  #|         "# Free LLM models ability of generating MoonBit code",
  #|         "",
  #|         `Last updated: ${nowIso()}`,
  #|         "",
  #|         "## Current summary",
  #|         "",
  #|         "| Provider | Model | API | API ms | L1 | L2 | L3 | Notes |",
  #|         "| --- | --- | --- | ---: | --- | --- | --- | --- |",
  #|         ...models.map((item) => {
  #|           const note = item?.notes?.final_recommendation_note || item?.api_test?.message || "";
  #|           return `| ${String(item?.provider || "")} | ${String(item?.model || "")} | ${String(item?.api_test?.status || "")} | ${String(item?.api_test?.latency_ms ?? "")} | ${formatCell(item?.benchmarks?.L1)} | ${formatCell(item?.benchmarks?.L2)} | ${formatCell(item?.benchmarks?.L3)} | ${String(note).replace(/\|/g, "/")} |`;
  #|         }),
  #|         "",
  #|         "## Raw JSON",
  #|         "",
  #|         "See `artifacts/moonbit-eval-results.json` for the full structured record."
  #|       ].join("\n");
  #|     };
  #|     const persistResults = async (results) => {
  #|       await fetch("/api/experiments/free-llm-moonbit/results.json", {
  #|         method: "POST",
  #|         headers: { "Content-Type": "application/json; charset=utf-8" },
  #|         body: JSON.stringify(results, null, 2)
  #|       });
  #|       await fetch("/api/experiments/free-llm-moonbit/results.md", {
  #|         method: "POST",
  #|         headers: { "Content-Type": "text/markdown; charset=utf-8" },
  #|         body: buildMarkdown(results)
  #|       });
  #|     };
  #|     const requestMoonBit = async (llm, systemPrompt, userPrompt, timeoutMs, maxTokens = 512, mode = "eval / raw-codegen") => {
  #|       updatePrompts(mode, systemPrompt, userPrompt);
  #|       if (llm.provider === "gemini") {
  #|         const url = `${llm.baseUrl}/v1beta/models/${encodeURIComponent(llm.model)}:generateContent`;
  #|         const { json, latencyMs } = await proxyPost(url, {
  #|           "Content-Type": "application/json",
  #|           "x-goog-api-key": String(llm.apiKey || "")
  #|         }, JSON.stringify({
  #|           system_instruction: { parts: [{ text: systemPrompt }] },
  #|           contents: [{ role: "user", parts: [{ text: userPrompt }] }],
  #|           generationConfig: { temperature: 0, maxOutputTokens: maxTokens }
  #|         }), timeoutMs);
  #|         const text = (json?.candidates?.[0]?.content?.parts || []).map((part) => String(part?.text || "")).join("\n").trim();
  #|         return { source: cleanSource(text), latencyMs };
  #|       }
  #|       const rawBaseUrl = String(llm.baseUrl || "").trim();
  #|       const baseUrl = rawBaseUrl.endsWith("/") ? rawBaseUrl.slice(0, -1) : rawBaseUrl;
  #|       let url = `${baseUrl}/chat/completions`;
  #|       if (llm.provider === "zai" && !baseUrl.endsWith("/chat/completions") && !baseUrl.includes("/api/paas/v4")) {
  #|         url = `${baseUrl}/api/paas/v4/chat/completions`;
  #|       }
  #|       const headers = {
  #|         "Content-Type": "application/json",
  #|         "Authorization": `Bearer ${String(llm.apiKey || "")}`
  #|       };
  #|       if (llm.provider === "openrouter") {
  #|         headers["HTTP-Referer"] = "http://127.0.0.1:3000";
  #|         headers["X-Title"] = "MoonAP";
  #|       }
  #|       const { json, latencyMs } = await proxyPost(url, headers, JSON.stringify({
  #|         model: llm.model,
  #|         messages: [
  #|           { role: "system", content: systemPrompt },
  #|           { role: "user", content: userPrompt }
  #|         ],
  #|         temperature: 0,
  #|         max_tokens: maxTokens
  #|       }), timeoutMs);
  #|       return { source: cleanSource(String(json?.choices?.[0]?.message?.content || "")), latencyMs };
  #|     };
  #|     const benchmarks = [
  #|       {
  #|         id: "L1",
  #|         title: "Smallest valid MoonBit program",
  #|         userPrompt: "Write cmd/main/main.mbt only. main must return the string \"hello moonbit\". No imports. No helper functions."
  #|       },
  #|       {
  #|         id: "L2",
  #|         title: "One helper plus main",
  #|         userPrompt: "Write cmd/main/main.mbt only. Define exactly one helper that returns \"hello moonbit\". main must call the helper and return its result. No imports."
  #|       },
  #|       {
  #|         id: "L3",
  #|         title: "Simple control flow",
  #|         userPrompt: "Write cmd/main/main.mbt only. main must return exactly \"ABC\" using compact deterministic control flow. No imports. No randomness."
  #|       }
  #|     ].slice(0, clampLevel(maxLevel));
  #|     const codegenSystemPrompt = [
  #|       "You write MoonBit code.",
  #|       "Return only cmd/main/main.mbt.",
  #|       "No markdown fences.",
  #|       "No explanations."
  #|     ].join("\n");
  #|     const repairSystemPrompt = [
  #|       "You repair MoonBit code.",
  #|       "Return only cmd/main/main.mbt.",
  #|       "No markdown fences.",
  #|       "No explanations."
  #|     ].join("\n");
  #|     const saved = readRouter();
  #|     const providers = (Array.isArray(saved.providers) ? saved.providers : [])
  #|       .map(normalizeProviderEntry)
  #|       .filter((item) => item.enabled && item.apiKey && item.model);
  #|     if (providers.length === 0) {
  #|       throw new Error("No enabled provider/model with API key is available for the experiment run.");
  #|     }
  #|     const blankBenchmark = () => ({
  #|       attempted: false,
  #|       raw_codegen_pass: false,
  #|       raw_codegen_compile_exit_code: null,
  #|       raw_codegen_compile_summary_kind: "",
  #|       repair_attempts_used: 0,
  #|       assisted_pass: false,
  #|       final_compile_exit_code: null,
  #|       final_compile_summary_kind: "",
  #|       final_source_bytes: null,
  #|       first_codegen_response_latency_ms: null,
  #|       total_time_to_first_compile_success_ms: null
  #|     });
  #|     const results = {
  #|       experiment_name: "Free LLM models ability of generating MoonBit code",
  #|       status: "running",
  #|       generated_at: nowIso(),
  #|       prompt_protocol: {
  #|         system_prompt: codegenSystemPrompt,
  #|         user_prompt_mode: "task-only"
  #|       },
  #|       benchmarks: benchmarks.map((item) => ({ id: item.id, title: item.title, goal: item.userPrompt })),
  #|       models: []
  #|     };
  #|     const routerSummary = `${providers.length} provider(s): ${providers.map((item) => `${item.key}/${item.model}`).join(", ")}`;
  #|     updateProcess(routerSummary, "moonbit-eval", "running", `Starting Free LLM MoonBit Eval across ${providers.length} enabled provider/model entries.`);
  #|     for (const provider of providers) {
  #|       const providerLabel = `${provider.key}/${provider.model}`;
  #|       const modelRecord = {
  #|         provider: provider.key,
  #|         model: provider.model,
  #|         base_url: provider.baseUrl,
  #|         api_test: {
  #|           status: "pending",
  #|           message: "",
  #|           latency_ms: null,
  #|           http_status: null,
  #|           timeout: false,
  #|           non_json_response: false
  #|         },
  #|         benchmarks: { L1: blankBenchmark(), L2: blankBenchmark(), L3: blankBenchmark() },
  #|         notes: {
  #|           stalled_or_long_no_response: false,
  #|           parser_drift_notes: "",
  #|           language_drift_notes: "",
  #|           final_recommendation_note: ""
  #|         }
  #|       };
  #|       results.models.push(modelRecord);
  #|       await persistResults(results);
  #|       updateProcess(providerLabel, "llm-api-test", "running", `Testing API reachability for ${providerLabel}.`);
  #|       try {
  #|         const ping = await requestMoonBit(provider, "Reply with OK.", "Reply with OK.", 8000, 8, "eval / api-test");
  #|         modelRecord.api_test.status = "ok";
  #|         modelRecord.api_test.message = ping.source || "OK";
  #|         modelRecord.api_test.latency_ms = ping.latencyMs;
  #|       } catch (error) {
  #|         modelRecord.api_test.status = "failed";
  #|         modelRecord.api_test.message = error instanceof Error ? error.message : String(error);
  #|         modelRecord.api_test.timeout = Boolean(error?.timeout);
  #|         modelRecord.api_test.non_json_response = Boolean(error?.nonJson);
  #|         modelRecord.api_test.http_status = Number.isFinite(error?.httpStatus) ? Number(error.httpStatus) : null;
  #|         modelRecord.notes.stalled_or_long_no_response = modelRecord.api_test.timeout;
  #|         await persistResults(results);
  #|         updateProcess(providerLabel, "llm-api-test", "failed", modelRecord.api_test.message);
  #|         continue;
  #|       }
  #|       await persistResults(results);
  #|       for (const benchmark of benchmarks) {
  #|         const bench = modelRecord.benchmarks[benchmark.id];
  #|         const benchStart = performance.now();
  #|         bench.attempted = true;
  #|         updateProcess(providerLabel, `moonbit-eval-${benchmark.id.toLowerCase()}`, "running", `Running ${benchmark.id} for ${providerLabel}.`);
  #|         try {
  #|           const generated = await requestMoonBit(provider, codegenSystemPrompt, benchmark.userPrompt, 30000, 512, "eval / raw-codegen");
  #|           bench.first_codegen_response_latency_ms = generated.latencyMs;
  #|           updateProcess(providerLabel, `moonbit-eval-${benchmark.id.toLowerCase()}`, "running", `Compiling raw output for ${benchmark.id}.`, generated.source);
  #|           let compile = await compileSource(generated.source);
  #|           bench.raw_codegen_compile_exit_code = Number.isFinite(compile?.exit_code) ? Number(compile.exit_code) : null;
  #|           bench.raw_codegen_compile_summary_kind = String(compile?.summary_kind || "");
  #|           bench.final_compile_exit_code = Number.isFinite(compile?.exit_code) ? Number(compile.exit_code) : null;
  #|           bench.final_compile_summary_kind = String(compile?.summary_kind || "");
  #|           bench.final_source_bytes = Number.isFinite(compile?.source_bytes) ? Number(compile.source_bytes) : generated.source.length;
  #|           if (compile?.ok === true) {
  #|             bench.raw_codegen_pass = true;
  #|             bench.assisted_pass = true;
  #|             bench.total_time_to_first_compile_success_ms = Math.round(performance.now() - benchStart);
  #|             await persistResults(results);
  #|             continue;
  #|           }
  #|           let repairedSource = generated.source;
  #|           for (let repairRound = 1; repairRound <= 2; repairRound += 1) {
  #|             bench.repair_attempts_used = repairRound;
  #|             const repairUserPrompt = [
  #|               `Benchmark task: ${benchmark.userPrompt}`,
  #|               "",
  #|               "Current source:",
  #|               repairedSource,
  #|               "",
  #|               "Compiler output:",
  #|               String(compile?.output || compile?.trimmed_output || ""),
  #|               "",
  #|               "Repair the file so it compiles. Return only cmd/main/main.mbt."
  #|             ].join("\n");
  #|             const repaired = await requestMoonBit(provider, repairSystemPrompt, repairUserPrompt, 30000, 512, "eval / repair");
  #|             repairedSource = repaired.source;
  #|             updateProcess(providerLabel, `moonbit-eval-${benchmark.id.toLowerCase()}`, "running", `Compile-checking repair round ${repairRound} for ${benchmark.id}.`, repairedSource);
  #|             compile = await compileSource(repairedSource);
  #|             bench.final_compile_exit_code = Number.isFinite(compile?.exit_code) ? Number(compile.exit_code) : null;
  #|             bench.final_compile_summary_kind = String(compile?.summary_kind || "");
  #|             bench.final_source_bytes = Number.isFinite(compile?.source_bytes) ? Number(compile.source_bytes) : repairedSource.length;
  #|             if (compile?.ok === true) {
  #|               bench.assisted_pass = true;
  #|               bench.total_time_to_first_compile_success_ms = Math.round(performance.now() - benchStart);
  #|               break;
  #|             }
  #|           }
  #|           if (!bench.assisted_pass && String(bench.final_compile_summary_kind || "").includes("parse")) {
  #|             modelRecord.notes.parser_drift_notes = `Parser drift reached ${benchmark.id}.`;
  #|           }
  #|         } catch (error) {
  #|           const message = error instanceof Error ? error.message : String(error);
  #|           bench.final_compile_summary_kind = "request-error";
  #|           modelRecord.notes.language_drift_notes = message;
  #|           if (message.toLowerCase().includes("timed out")) {
  #|             modelRecord.notes.stalled_or_long_no_response = true;
  #|           }
  #|         }
  #|         await persistResults(results);
  #|         updateProcess(providerLabel, `moonbit-eval-${benchmark.id.toLowerCase()}`, bench.assisted_pass ? "succeeded" : "failed", `${benchmark.id} result for ${providerLabel}: raw=${bench.raw_codegen_pass ? "pass" : "fail"}, assisted=${bench.assisted_pass ? "pass" : "fail"}, repairs=${Number(bench.repair_attempts_used || 0)}.`);
  #|       }
  #|       const l3 = modelRecord.benchmarks.L3;
  #|       if (l3?.raw_codegen_pass) {
  #|         modelRecord.notes.final_recommendation_note = "Strong first-pass MoonBit candidate.";
  #|       } else if (l3?.assisted_pass) {
  #|         modelRecord.notes.final_recommendation_note = "Usable with compiler-guided repair.";
  #|       } else {
  #|         modelRecord.notes.final_recommendation_note = "Not yet reliable for MoonBit benchmark L3.";
  #|       }
  #|       await persistResults(results);
  #|     }
  #|     results.status = "completed";
  #|     await persistResults(results);
  #|     updateProcess(routerSummary, "moonbit-eval", "succeeded", "Free LLM MoonBit Eval completed. Results were written to artifacts/moonbit-eval-results.json and docs/experiments/free-llm-moonbit/results.md.");
  #|     onDone(JSON.stringify(results, null, 2));
  #|   } catch (error) {
  #|     onError(error instanceof Error ? error.message : String(error));
  #|   } finally {
  #|     globalThis.__moonapEvalRunning = false;
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_on_save_personal_skill(handler : () -> Unit) -> Unit =
  #| (handler) => document.addEventListener("click", (event) => {
  #|   if (event.target?.id !== "savePersonalSkill") return;
  #|   event.preventDefault();
  #|   event.stopPropagation();
  #|   try {
  #|     handler();
  #|   } catch (error) {
  #|     console.error("MoonAP save personal skill handler failed:", error);
  #|     alert(`MoonAP save failed: ${error instanceof Error ? error.message : String(error)}`);
  #|   }
  #| })

///|
#cfg(target="js")
extern "js" fn browser_on_download_runtime_artifact(
  kind : String,
  handler : () -> Unit,
) -> Unit =
  #| (kind, handler) => document.addEventListener("click", (event) => {
  #|   const targetId = kind === "wasm"
  #|     ? "downloadRuntimeWasm"
  #|     : kind === "source"
  #|       ? "downloadRuntimeSource"
  #|       : kind === "compile-report"
  #|         ? "downloadCompileReport"
  #|         : "downloadRuntimeResult";
  #|   if (event.target?.id !== targetId) return;
  #|   event.preventDefault();
  #|   event.stopPropagation();
  #|   try {
  #|     handler();
  #|   } catch (error) {
  #|     alert(`MoonAP runtime download failed: ${error instanceof Error ? error.message : String(error)}`);
  #|   }
  #| })

///|
#cfg(target="js")
extern "js" fn browser_on_record_demo_runtime_result(
  handler : () -> Unit,
) -> Unit =
  #| (handler) => document.addEventListener("click", (event) => {
  #|   if (event.target?.id !== "recordDemoRuntimeResult") return;
  #|   event.preventDefault();
  #|   event.stopPropagation();
  #|   try {
  #|     handler();
  #|   } catch (error) {
  #|     alert(`MoonAP demo runtime execution failed: ${error instanceof Error ? error.message : String(error)}`);
  #|   }
  #| })

///|
#cfg(target="js")
extern "js" fn browser_on_repair_artifact(handler : () -> Unit) -> Unit =
  #| (handler) => document.addEventListener("click", (event) => {
  #|   if (event.target?.id !== "repairArtifact") return;
  #|   event.preventDefault();
  #|   event.stopPropagation();
  #|   try {
  #|     handler();
  #|   } catch (error) {
  #|     alert(`MoonAP repair failed: ${error instanceof Error ? error.message : String(error)}`);
  #|   }
  #| })

///|
#cfg(target="js")
extern "js" fn browser_render_personal_skills() -> Int =
  #| () => {
  #|   const root = document.querySelector("#personalSkillCards");
  #|   if (!root) return 0;
  #|   let skills = [];
  #|   try {
  #|     const parsed = JSON.parse(localStorage.getItem("moonap.personal.skills") || "[]");
  #|     skills = Array.isArray(parsed) ? parsed : [];
  #|   } catch (error) {
  #|     console.warn("MoonAP reset invalid personal skill storage:", error);
  #|     try { localStorage.removeItem("moonap.personal.skills"); } catch {}
  #|   }
  #|   root.innerHTML = "";
  #|   skills = skills.filter((skill) => Boolean(skill?.runtime_ready));
  #|   if (skills.length === 0) {
  #|     const empty = document.createElement("div");
  #|     empty.className = "personal-skill-empty";
  #|     empty.textContent = "No runnable Personal SKILL yet. MoonAP source capture is working; real compile and runtime wiring are the next step before Personal-SKILL-Set becomes reusable.";
  #|     root.append(empty);
  #|     return 0;
  #|   }
  #|   for (const skill of skills) {
  #|     const card = document.createElement("button");
  #|     card.className = "skill-card personal";
  #|     card.type = "button";
  #|     card.dataset.skillId = skill.id || "personal.fastq-generator";
  #|     card.innerHTML = `<span>Local / Generated</span><strong>${skill.name || "Personal FastQ Generator"}</strong><small>Saved locally in this browser. Reusable without LLM.</small>`;
  #|     root.append(card);
  #|   }
  #|   return skills.length;
  #| }

///|
#cfg(target="js")
extern "js" fn browser_set_mode_panel(text : String) -> Unit =
  #| (text) => {
  #|   const panel = document.querySelector("#modePanel");
  #|   if (panel) panel.setAttribute("aria-label", String(text));
  #| }

///|
#cfg(target="js")
extern "js" fn browser_set_skill_panel_open(open : Bool) -> Unit =
  #| (open) => {
  #|   document.querySelector("#modePanel")?.classList.toggle("is-open", Boolean(open));
  #|   document.querySelector("#privacyStrip")?.classList.toggle("is-open", Boolean(open));
  #| }

///|
#cfg(target="js")
extern "js" fn browser_fetch_text(
  path : String,
  on_ok : (String) -> Unit,
  on_error : (String) -> Unit,
) -> Unit =
  #| (path, onOk, onError) => {
  #|   fetch(String(path))
  #|     .then((response) => response.text())
  #|     .then((text) => onOk(String(text)))
  #|     .catch((error) => onError(error instanceof Error ? error.message : String(error)));
  #| }

///|
#cfg(target="js")
extern "js" fn browser_pretty_json(raw : String) -> String =
  #| (raw) => {
  #|   try { return JSON.stringify(JSON.parse(String(raw)), null, 2); }
  #|   catch { return String(raw); }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_artifact_field(raw : String, field : String) -> String =
  #| (raw, field) => {
  #|   try {
  #|     const value = JSON.parse(String(raw))?.[String(field)];
  #|     return value == null ? "" : String(value);
  #|   } catch {
  #|     return "";
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn browser_has_last_artifact_source() -> Bool =
  #| () => String(globalThis.__moonapLastArtifact?.moonbit_source || "").trim() !== ""

///|
#cfg(target="js")
fn context_path(message : String, file_name : String) -> String {
  let hint = (message + " " + file_name).to_lower()
  if hint.contains("fastq") || hint.contains(".fq") {
    "/api/agent/context?fastq"
  } else if hint.contains("csv") {
    "/api/agent/context?csv"
  } else if hint.contains("xlsx") ||
    hint.contains("xls") ||
    hint.contains("excel") {
    "/api/agent/context?xlsx"
  } else if hint.contains("json") {
    "/api/agent/context?json"
  } else if hint.contains("game") {
    "/api/agent/context?game"
  } else {
    "/api/agent/context"
  }
}

///|
#cfg(target="js")
fn active_skill_from_context(raw : String) -> String {
  if raw.contains("\"active_skill\": \"fastq\"") {
    "fastq"
  } else if raw.contains("\"active_skill\": \"csv\"") {
    "csv"
  } else if raw.contains("\"active_skill\": \"spreadsheet\"") {
    "spreadsheet"
  } else if raw.contains("\"active_skill\": \"json\"") {
    "json"
  } else if raw.contains("\"active_skill\": \"game\"") {
    "game"
  } else {
    "chat"
  }
}

///|
#cfg(target="js")
fn show_error(label : String, error : String) -> Unit {
  browser_set_state(label + ": " + error)
  browser_update_process("-", label, "failed", error, "")
  browser_render_artifact_card(
    "MoonAP error", error, "[\"failed\"]", false, false, false,
  )
}

///|
#cfg(target="js")
fn refresh_policies() -> Unit {
  browser_fetch_text(
    "/api/app-state",
    fn(raw) {
      browser_set_state(browser_pretty_json(raw))
      browser_render_onboarding()
    },
    fn(error) { show_error("app-state fetch failed", error) },
  )
}

///|
#cfg(target="js")
fn show_llm_entry() -> Unit {
  browser_set_mode_panel("LLM settings")
  browser_set_skill_panel_open(false)
  browser_open_llm_dialog()
  browser_fetch_text(
    "/api/formal-verification",
    fn(raw) { browser_set_state(browser_pretty_json(raw)) },
    fn(error) { show_error("LLM state fetch failed", error) },
  )
}

///|
#cfg(target="js")
fn show_skill_entry() -> Unit {
  browser_set_mode_panel("MoonAP SKILL Hub")
  browser_set_skill_panel_open(true)
  ignore(browser_render_personal_skills())
  browser_fetch_text(
    "/api/skills",
    fn(raw) { browser_set_state(browser_pretty_json(raw)) },
    fn(error) { show_error("SKILL hub fetch failed", error) },
  )
}

///|
#cfg(target="js")
fn show_skill_run_plan(skill_id : String) -> Unit {
  browser_open_skill_dialog(skill_id)
}

///|
#cfg(target="js")
fn execute_dialog_skill() -> Unit {
  let skill_id = browser_dialog_skill_id()
  browser_close_skill_dialog()
  if skill_id.contains("moonbit-benchmark") {
    run_moonbit_benchmark(browser_dialog_param_int("benchmarkLevel", 1))
    return
  }
  if skill_id.contains("free-llm-eval") {
    run_free_llm_moonbit_eval(browser_dialog_param_int("evalMaxLevel", 3))
    return
  }
  if skill_id.contains("moonbit.fastq-generator") {
    run_moonbit_fastq_generator()
    return
  }
  if skill_id.contains("fastq-base-counter") {
    run_fastq_counter()
    return
  }
  if skill_id.contains("fastq-generator") {
    run_fastq_generator()
    return
  }
  let path = if skill_id.contains("finance") {
    "/api/skills/run-plan?finance"
  } else if skill_id.contains("generator") {
    "/api/skills/run-plan?generator"
  } else if skill_id.contains("gomoku") || skill_id.contains("game") {
    "/api/skills/run-plan?gomoku"
  } else if skill_id == "personal" {
    "/api/personal-skill-set"
  } else {
    "/api/skills/run-plan?fastq"
  }
  browser_fetch_text(
    path,
    fn(raw) { browser_set_state(browser_pretty_json(raw)) },
    fn(error) { show_error("SKILL plan fetch failed", error) },
  )
}

///|
#cfg(target="js")
fn run_llm_moonbit_codegen(
  task_title : String,
  prompt : String,
  source_summary : String,
  simple_mode : Bool,
) -> Unit {
  browser_clear_artifact_card()
  browser_reset_compile_report()
  browser_set_benchmark_assessment("")
  browser_update_process(
    browser_llm_summary(),
    "llm-codegen",
    "running",
    "Submitting prompt to the next enabled provider in the router with the MoonBit primer injected into the user prompt.",
    "",
  )
  browser_generate_moonbit_artifact(
    task_title,
    prompt,
    simple_mode,
    browser_formal_verification_enabled(),
    moonbit_llm_primer_v1(),
    fn(result) {
      browser_set_state(browser_pretty_json(result))
      browser_append_runtime_log(
        "artifact",
        "llm-codegen-result",
        browser_pretty_json(result),
      )
      let provider = browser_artifact_field(result, "llm_provider")
      let model = browser_artifact_field(result, "llm_model")
      let source = browser_artifact_field(result, "moonbit_source")
      browser_update_process(
        if provider == "" {
          browser_llm_summary()
        } else if model == "" {
          provider
        } else {
          provider + "/" + model
        },
        "llm-codegen",
        "succeeded",
        "Real LLM response received. MoonBit source captured after the MoonBit primer injection. Compile/run remains pending until the next implementation step.",
        if source == "" {
          "No generated source returned."
        } else {
          source
        },
      )
      browser_render_artifact_card(
        task_title + " source is ready",
        source_summary,
        "[\"real LLM response\",\"source captured\",\"compile starting\"]",
        true,
        false,
        false,
      )
      run_compile_probe()
    },
    fn(error) { show_error("LLM MoonBit artifact generation failed", error) },
  )
}

///|
#cfg(target="js")
fn moonbit_llm_primer_v1() -> String {
  [
    "MoonBit 0.9 Primer for general LLMs:", "Treat MoonBit as its own language. Do not borrow syntax from Rust, C, C++, Go, Java, Python, TypeScript, or OCaml.",
    "", "MoonAP task constraints:", "1. Generate ONLY cmd/main/main.mbt. The build system already creates moon.mod.json and moon.pkg.",
    "2. Return source code only. No explanations, no markdown fences, no shell commands, no extra files.",
    "3. The target is `moon build cmd/main --target wasm-gc`, so keep the file self-contained.",
    "", "Core MoonBit 0.9 habits:", "4. Use MoonBit block style. The entry point should be `fn main { ... }`.",
    "5. Prefer the smallest valid solution that satisfies the task.", "6. Add helper functions only when they are clearly needed.",
    "7. If you are unsure about a library API, avoid that API and solve the task with basic language constructs.",
    "", "Tiny valid examples to imitate:", "fn main {", "  \"hello moonbit\"", "}",
    "", "fn greet(name : String) -> String {", "  \"hello \" + name", "}", "", "fn main {",
    "  greet(\"moonbit\")", "}", "", "Important syntax expectations:", "8. Use MoonBit type names like `Int`, `String`, `Bool`. Do not use `i32`, `u32`, `f32`, `usize`, or `char`.",
    "9. Do not write Rust-style imports like `import std::fmt;` or `use std::...`. In MoonAP tasks, do not write imports unless the task explicitly requires them.",
    "10. Do not write Rust mutation or collection syntax like `mut`, `let mut`, `String::new()`, `Vec`, `format!`, `println!`, `push_str`, or `as Type` casts.",
    "11. Do not write numeric suffixes like `42u32`, `1usize`, or `3.14f32`.", "12. Do not invent package declarations, trait syntax, impl blocks, or extra module files unless the task explicitly asks for them.",
    "", "Generation strategy:", "13. First write the smallest compilable MoonBit program that satisfies the task.",
    "14. Then add only the minimum helper functions or bindings needed by the requested behavior.",
    "15. When in doubt, choose simpler code over more abstract code.",
  ]
  .iter()
  .join("\n")
}

///|
#cfg(target="js")
fn clamp_moonbit_benchmark_level(level : Int) -> Int {
  if level < 1 {
    1
  } else if level > 5 {
    5
  } else {
    level
  }
}

///|
#cfg(target="js")
fn moonbit_benchmark_title(level : Int) -> String {
  "MoonBit Benchmark L" + clamp_moonbit_benchmark_level(level).to_string()
}

///|
#cfg(target="js")
fn moonbit_benchmark_prompt(level : Int) -> String {
  let current = clamp_moonbit_benchmark_level(level)
  if current == 1 {
    [
      "MoonBit Benchmark Level 1.", "Write the smallest valid `cmd/main/main.mbt` that compiles under wasm-gc.",
      "Required behavior:", "- `main` returns the string `hello moonbit`", "- no helper functions",
      "- no imports", "- keep the file tiny", "Return only the file contents.",
    ]
    .iter()
    .join("\n")
  } else if current == 2 {
    [
      "MoonBit Benchmark Level 2.", "Write `cmd/main/main.mbt` with exactly one helper function plus `main`.",
      "Required behavior:", "- helper function returns the string `hello moonbit`",
      "- `main` calls the helper and returns the result", "- no imports", "- keep the file tiny and valid for wasm-gc compile",
      "Return only the file contents.",
    ]
    .iter()
    .join("\n")
  } else if current == 3 {
    [
      "MoonBit Benchmark Level 3.", "Write `cmd/main/main.mbt` that builds a fixed string using simple control flow.",
      "Required behavior:", "- return exactly `ABC` from `main`", "- no imports",
      "- no randomness", "- keep the implementation compact and valid for wasm-gc compile",
      "Return only the file contents.",
    ]
    .iter()
    .join("\n")
  } else if current == 4 {
    [
      "MoonBit Benchmark Level 4.", "Write `cmd/main/main.mbt` with two helper functions that thread a small deterministic integer state value.",
      "Required behavior:", "- one helper updates an integer state", "- one helper turns the state into a single base from `A`, `C`, `G`, `T`",
      "- `main` returns a fixed 12-character DNA string generated from seed 42",
      "- no imports", "- no floating point types", "- keep the code compact and valid for wasm-gc compile",
      "Return only the file contents.",
    ]
    .iter()
    .join("\n")
  } else {
    [
      "MoonBit Benchmark Level 5.", "Write `cmd/main/main.mbt` for a tiny deterministic synthetic read generator.",
      "Required behavior:", "- return one 4-line FastQ record as a String", "- header must be `@moonap_benchmark_0`",
      "- sequence length must be 12", "- quality line must be twelve `I` characters",
      "- deterministic output from seed 42", "- no imports", "- keep the code compact and valid for wasm-gc compile",
      "Return only the file contents.",
    ]
    .iter()
    .join("\n")
  }
}

///|
#cfg(target="js")
fn run_moonbit_benchmark(level : Int) -> Unit {
  let current = clamp_moonbit_benchmark_level(level)
  browser_append_message(
    "assistant",
    "Running " +
    moonbit_benchmark_title(current) +
    ". We will use this to check whether the current LLM router can stay in valid MoonBit before we try harder tasks.",
  )
  run_llm_moonbit_codegen(
    moonbit_benchmark_title(current),
    moonbit_benchmark_prompt(current),
    "MoonAP received benchmark source from the active router provider and is now starting a real native compile probe automatically.",
    true,
  )
}

///|
#cfg(target="js")
fn run_free_llm_moonbit_eval(max_level : Int) -> Unit {
  let current = if max_level < 1 {
    1
  } else if max_level > 3 {
    3
  } else {
    max_level
  }
  browser_append_message(
    "assistant",
    "Starting Free LLM MoonBit Eval. We will run the enabled provider/model entries against benchmark levels L1-L" +
    current.to_string() +
    " with minimal prompts, then persist raw JSON plus a markdown summary.",
  )
  browser_update_process(
    browser_llm_summary(),
    "moonbit-eval",
    "running",
    "Preparing the experiment harness. Results will be persisted to artifacts/moonbit-eval-results.json and docs/experiments/free-llm-moonbit/results.md.",
    "",
  )
  browser_run_free_llm_moonbit_eval(
    current,
    fn(result) {
      browser_set_state(browser_pretty_json(result))
      browser_render_artifact_card(
        "Free LLM MoonBit Eval finished", "MoonAP completed the current experiment pass and wrote both raw JSON and a markdown summary file.",
        "[\"experiment complete\",\"json persisted\",\"markdown persisted\"]", false,
        false, false,
      )
    },
    fn(error) { show_error("Free LLM MoonBit Eval failed", error) },
  )
}

///|
#cfg(target="js")
fn run_fastq_generator() -> Unit {
  browser_clear_artifact_card()
  let read_count = browser_dialog_param_int("readCount", 10000)
  let read_length = browser_dialog_param_int("readLength", 150)
  let seed_value = browser_dialog_param_int("seed", 42)
  let n_rate_text = browser_dialog_param("nRate")
  browser_generate_fastq_sample(
    read_count,
    read_length,
    n_rate_text,
    seed_value,
    fn(result) {
      browser_set_state(browser_pretty_json(result))
      browser_update_result_panel(result)
    },
    fn(error) { show_error("FastQ generator failed", error) },
  )
}

///|
#cfg(target="js")
fn run_moonbit_fastq_generator() -> Unit {
  let read_count = browser_dialog_param_int("readCount", 10000)
  let read_length = browser_dialog_param_int("readLength", 150)
  let seed_value = browser_dialog_param_int("seed", 42)
  let n_rate_per_mille = browser_dialog_param_int("nRatePerMille", 10)
  browser_append_message(
    "assistant", "Running MoonBit FastQ Generator. We will ask the active LLM router to generate a MoonBit program, then run a real compile probe and a basic FastQ structure check.",
  )
  run_llm_moonbit_codegen(
    "MoonBit FastQ Generator",
    [
      "Generate a Personal FastQ Generator in MoonBit.",
      "Write ONLY cmd/main/main.mbt so that `moon build cmd/main --target wasm-gc` succeeds.",
      "The program should return a String containing deterministic FastQ records.",
      "Keep these defaults in the source:",
      "- read_count = " + read_count.to_string(),
      "- read_length = " + read_length.to_string(),
      "- n_rate_per_mille = " + n_rate_per_mille.to_string(),
      "- seed = " + seed_value.to_string(),
      "Requirements:",
      "- generate valid 4-line FastQ records: header, sequence, plus line, quality",
      "- sequence uses only A, C, G, T, N",
      "- quality line uses I characters",
      "- deterministic from the seed",
      "- no imports",
      "- keep the code as simple and compact as possible",
      "Return only the file contents.",
    ]
    .iter()
    .join("\n"),
    "MoonAP received a MoonBit FastQ generator candidate from the active router provider and is now starting a real native compile probe automatically.",
    true,
  )
}

///|
#cfg(target="js")
fn max_auto_repair_rounds() -> Int {
  2
}

///|
#cfg(target="js")
fn maybe_auto_repair_after_compile_failure(
  summary_kind : String,
  repair_hint : String,
  summary_excerpt : String,
) -> Bool {
  let repair_round = browser_last_artifact_repair_round()
  let max_rounds = max_auto_repair_rounds()
  if repair_hint == "" || repair_round >= max_rounds {
    false
  } else {
    let next_round = repair_round + 1
    let log_text = if summary_excerpt == "" {
      repair_hint
    } else {
      summary_excerpt + "\nRepair hint: " + repair_hint
    }
    let detected_kind = if summary_kind == "" {
      "compiler-error"
    } else {
      summary_kind
    }
    browser_update_process(
      browser_llm_summary(),
      "compile-repair",
      "running",
      "Compile probe failed. MoonAP is auto-repairing round " +
      next_round.to_string() +
      "/" +
      max_rounds.to_string() +
      " using Compile-Error Summarizer v1.\n" +
      log_text,
      "",
    )
    browser_render_artifact_card(
      "Compile probe failed, auto-repairing",
      "MoonAP detected " +
      detected_kind +
      " and automatically started repair round " +
      next_round.to_string() +
      "/" +
      max_rounds.to_string() +
      ".",
      "[\"auto repair\",\"round " +
      next_round.to_string() +
      "\",\"" +
      detected_kind +
      "\"]",
      false,
      false,
      false,
    )
    run_repair_from_compile_summary()
    true
  }
}

///|
#cfg(target="js")
fn maybe_auto_repair_after_quality_failure(
  assessment_title : String,
  assessment_summary : String,
  assessment_hint : String,
  missing_signals_json : String,
) -> Bool {
  let repair_round = browser_last_artifact_repair_round()
  let max_rounds = max_auto_repair_rounds()
  if repair_round >= max_rounds {
    false
  } else {
    let next_round = repair_round + 1
    let detected_title = if assessment_title == "" {
      "System assessment failed"
    } else {
      assessment_title
    }
    let missing_excerpt = if missing_signals_json == "" ||
      missing_signals_json == "[]" {
      ""
    } else {
      "\nMissing signals: " + missing_signals_json
    }
    let hint_excerpt = if assessment_hint == "" {
      missing_excerpt
    } else {
      "\nRepair hint: " + assessment_hint + missing_excerpt
    }
    let log_text = "Compile probe succeeded, but system assessment failed. MoonAP is auto-repairing round " +
      next_round.to_string() +
      "/" +
      max_rounds.to_string() +
      " using the captured benchmark feedback.\n" +
      assessment_summary +
      hint_excerpt
    browser_update_process(
      browser_llm_summary(),
      "quality-repair",
      "running",
      log_text,
      "",
    )
    browser_render_artifact_card(
      "Compile succeeded, auto-repairing quality",
      "MoonAP kept the compiled artifact, but the system assessment still failed. Starting quality repair round " +
      next_round.to_string() +
      "/" +
      max_rounds.to_string() +
      ".",
      "[\"quality repair\",\"round " +
      next_round.to_string() +
      "\",\"" +
      detected_title.replace_all(old="\"", new="'") +
      "\"]",
      false,
      false,
      false,
    )
    run_repair_from_system_assessment()
    true
  }
}

///|
#cfg(target="js")
fn run_compile_probe() -> Unit {
  browser_clear_artifact_card()
  browser_update_process(
    browser_llm_summary(),
    "moonbit-wasm-compile",
    "running",
    "Submitting captured MoonBit source to the native MoonAP compile probe.",
    "",
  )
  browser_compile_last_artifact(
    browser_formal_verification_enabled(),
    fn(result) {
      browser_store_compile_report(result)
      browser_set_state(browser_pretty_json(result))
      browser_append_runtime_log(
        "compile",
        "compile-report",
        browser_pretty_json(result),
      )
      let ok = browser_artifact_field(result, "ok")
      let stage = browser_artifact_field(result, "stage")
      let output = browser_artifact_field(result, "output")
      let wasm_path = browser_artifact_field(result, "wasm_path")
      let summary_kind = browser_artifact_field(result, "summary_kind")
      let repair_hint = browser_artifact_field(result, "repair_hint")
      let summary_excerpt = browser_artifact_field(result, "summary_excerpt")
      browser_update_process(
        browser_llm_summary(),
        if stage == "" {
          "moonbit-wasm-compile"
        } else {
          stage
        },
        if ok == "true" {
          "succeeded"
        } else {
          "failed"
        },
        if ok == "true" || summary_excerpt == "" {
          output
        } else if repair_hint == "" {
          summary_excerpt
        } else {
          summary_excerpt + "\nRepair hint: " + repair_hint
        },
        if wasm_path == "" {
          "No wasm artifact was produced."
        } else {
          "Wasm artifact: " + wasm_path
        },
      )
      if ok == "true" {
        browser_register_runtime_ready(
          fn(raw) { on_runtime_request_ready(raw) },
          fn(error) {
            browser_append_runtime_log(
              "runtime-exec", "runtime-request-register-failed", error,
            )
          },
        )
        let benchmark_assessment = browser_assess_last_benchmark()
        browser_append_runtime_log(
          "benchmark", "benchmark-assessment", benchmark_assessment,
        )
        let benchmark_applicable = browser_artifact_field(
          benchmark_assessment, "applicable",
        )
        browser_set_benchmark_assessment(benchmark_assessment)
        if benchmark_applicable == "true" {
          let benchmark_title = browser_artifact_field(
            benchmark_assessment, "title",
          )
          let benchmark_summary = browser_artifact_field(
            benchmark_assessment, "summary",
          )
          let benchmark_meta_json = browser_artifact_field(
            benchmark_assessment, "meta_json",
          )
          let benchmark_pass = browser_artifact_field(
            benchmark_assessment, "pass",
          )
          browser_update_process(
            browser_llm_summary(),
            "moonbit-benchmark-check",
            if benchmark_pass == "true" {
              "succeeded"
            } else {
              "failed"
            },
            benchmark_summary,
            "",
          )
          let benchmark_hint = browser_artifact_field(
            benchmark_assessment, "repair_hint",
          )
          let benchmark_missing_signals_json = browser_artifact_field(
            benchmark_assessment, "missing_signals_json",
          )
          if benchmark_pass != "true" &&
            maybe_auto_repair_after_quality_failure(
              benchmark_title, benchmark_summary, benchmark_hint, benchmark_missing_signals_json,
            ) {
            ()
          } else {
            browser_render_artifact_card(
              benchmark_title, benchmark_summary, benchmark_meta_json, true, false,
              false,
            )
            browser_render_onboarding()
          }
        } else {
          browser_render_artifact_card(
            "Compile probe succeeded", "MoonAP used the native MoonBit toolchain on this machine and produced a real wasm-gc artifact. Browser-local runtime execution is the next implementation step.",
            "[\"compile probe ok\",\"real wasm built\",\"runtime pending\"]", true,
            false, false,
          )
          browser_render_onboarding()
        }
      } else if maybe_auto_repair_after_compile_failure(
          summary_kind, repair_hint, summary_excerpt,
        ) {
        ()
      } else {
        browser_render_artifact_card(
          "Compile probe failed",
          if repair_hint == "" {
            "MoonAP attempted a real native compile and returned the true compiler output. Review Details and iterate on the generated source."
          } else {
            "MoonAP summarized the compiler failure, exhausted the current auto-repair budget, and kept the true compiler output for inspection."
          },
          "[\"compile failed\",\"true compiler output\",\"" +
          summary_kind +
          "\",\"" +
          summary_excerpt.replace_all(old="\"", new="'") +
          "\"]",
          true,
          false,
          false,
        )
      }
    },
    fn(error) { show_error("compile probe failed", error) },
  )
}

///|
#cfg(target="js")
fn run_repair_from_compile_summary() -> Unit {
  browser_clear_artifact_card()
  browser_update_process(
    browser_llm_summary(),
    "compile-repair",
    "running",
    "Submitting the captured compiler failure back to the next enabled provider together with the MoonBit primer.",
    "",
  )
  browser_repair_last_artifact_with_compile_summary(
    browser_formal_verification_enabled(),
    moonbit_llm_primer_v1(),
    fn(result) {
      browser_set_state(browser_pretty_json(result))
      browser_append_runtime_log(
        "artifact",
        "repair-result",
        browser_pretty_json(result),
      )
      let provider = browser_artifact_field(result, "llm_provider")
      let model = browser_artifact_field(result, "llm_model")
      let source = browser_artifact_field(result, "moonbit_source")
      let repair_round = browser_artifact_field(result, "repair_round")
      browser_update_process(
        if provider == "" {
          browser_llm_summary()
        } else if model == "" {
          provider
        } else {
          provider + "/" + model
        },
        "compile-repair",
        "succeeded",
        "Compile-Error Summarizer v1 injected the first compiler failure into a repair prompt. MoonAP captured a repaired MoonBit source and will run the compile probe again automatically.",
        if source == "" {
          "No repaired source returned."
        } else {
          source
        },
      )
      browser_render_artifact_card(
        "Repaired source is ready",
        "MoonAP generated repair round " +
        repair_round +
        " from the summarized compiler failure and is now re-running the native compile probe.",
        "[\"repair round " +
        repair_round +
        "\",\"compile summary v1\",\"compile starting\"]",
        true,
        false,
        false,
      )
      run_compile_probe()
    },
    fn(error) { show_error("MoonBit compile repair failed", error) },
  )
}

///|
#cfg(target="js")
fn run_repair_from_system_assessment() -> Unit {
  browser_clear_artifact_card()
  browser_update_process(
    browser_llm_summary(),
    "quality-repair",
    "running",
    "Submitting the captured system assessment back to the next enabled provider.",
    "",
  )
  browser_repair_last_artifact_with_system_assessment(
    moonbit_llm_primer_v1(),
    fn(result) {
      browser_set_state(browser_pretty_json(result))
      browser_append_runtime_log(
        "artifact",
        "quality-repair-result",
        browser_pretty_json(result),
      )
      let provider = browser_artifact_field(result, "llm_provider")
      let model = browser_artifact_field(result, "llm_model")
      let source = browser_artifact_field(result, "moonbit_source")
      let repair_round = browser_artifact_field(result, "repair_round")
      browser_update_process(
        if provider == "" {
          browser_llm_summary()
        } else if model == "" {
          provider
        } else {
          provider + "/" + model
        },
        "quality-repair",
        "succeeded",
        "MoonAP injected the current system assessment into a quality-repair prompt. The revised MoonBit source will now be compiled again automatically.",
        if source == "" {
          "No revised source returned."
        } else {
          source
        },
      )
      browser_render_artifact_card(
        "Quality-repaired source is ready",
        "MoonAP generated repair round " +
        repair_round +
        " from the system assessment and is now re-running the native compile probe.",
        "[\"quality repair round " +
        repair_round +
        "\",\"system assessment\",\"compile starting\"]",
        true,
        false,
        false,
      )
      run_compile_probe()
    },
    fn(error) { show_error("MoonBit quality repair failed", error) },
  )
}

///|
#cfg(target="js")
fn run_fastq_counter() -> Unit {
  browser_clear_artifact_card()
  if !browser_has_file() {
    browser_append_message(
      "assistant", "Choose a FastQ file with the + button first, then run FastQ Base Counter. File contents will stay in this browser.",
    )
    return
  }
  browser_run_fastq_counter(
    browser_dialog_param("targetBase"),
    fn(progress) {
      browser_set_state(browser_pretty_json(progress))
      browser_update_result_panel(progress)
    },
    fn(result) {
      browser_set_state(browser_pretty_json(result))
      browser_update_result_panel(result)
    },
    fn(error) { show_error("FastQ analysis failed", error) },
  )
}

///|
#cfg(target="js")
fn on_runtime_request_ready(raw : String) -> Unit {
  let request_id = browser_artifact_field(raw, "request_id")
  let status = browser_artifact_field(raw, "status")
  let wasm_path = browser_artifact_field(raw, "wasm_path")
  if !browser_has_last_artifact_source() {
    return
  }
  if request_id == "" || status == "" || status == "empty" {
    return
  }
  browser_set_transient_artifact_card(true)
  browser_set_state(browser_pretty_json(raw))
  browser_update_result_panel(raw)
  browser_update_process(
    browser_llm_summary(),
    "runtime-exec",
    if status == "" {
      "ready"
    } else {
      status
    },
    "MoonAP compiled a wasm artifact and prepared the next runtime-execution request. Browser display or downloadable output is the next step.",
    if wasm_path == "" {
      "No wasm path recorded yet."
    } else {
      "Wasm artifact: " + wasm_path
    },
  )
  browser_render_artifact_card(
    "Runtime execution is ready", "MoonAP has a compiled wasm artifact and is now waiting for browser-local execution or a simulated runtime result.",
    "[\"runtime ready\",\"browser display pending\",\"download allowed\"]", false,
    false, false,
  )
}

///|
#cfg(target="js")
fn on_runtime_result_ready(raw : String) -> Unit {
  let request_id = browser_artifact_field(raw, "request_id")
  let status = browser_artifact_field(raw, "status")
  let summary = browser_artifact_field(raw, "summary")
  let display_text = browser_artifact_field(raw, "display_text")
  let download_name = browser_artifact_field(raw, "download_name")
  if !browser_has_last_artifact_source() {
    return
  }
  if request_id == "" || status == "" || status == "empty" {
    return
  }
  browser_set_transient_artifact_card(true)
  browser_set_state(browser_pretty_json(raw))
  browser_update_result_panel(raw)
  browser_update_process(
    browser_llm_summary(),
    "runtime-exec",
    if status == "" {
      "runtime-succeeded"
    } else {
      status
    },
    if summary == "" {
      "MoonAP received a runtime result."
    } else {
      summary
    },
    if display_text == "" {
      if download_name == "" {
        "No browser-visible runtime preview was recorded."
      } else {
        "Downloadable result: " + download_name
      }
    } else {
      display_text
    },
  )
  browser_render_artifact_card(
    "Runtime result is ready", "Review the runtime output. If it looks good, you can now save this workflow as a reusable Personal SKILL.",
    "[\"runtime succeeded\",\"result visible\",\"user review pending\"]", false,
    false, true,
  )
}

///|
#cfg(target="js")
fn on_skill_save_decision(raw : String) -> Unit {
  let request_id = browser_artifact_field(raw, "request_id")
  let decision = browser_artifact_field(raw, "decision")
  let reason = browser_artifact_field(raw, "reason")
  if !browser_has_last_artifact_source() {
    return
  }
  if request_id == "" ||
    decision == "" ||
    decision == "pending" ||
    decision == "unset" {
    ()
  } else {
    browser_set_transient_artifact_card(true)
    browser_set_state(browser_pretty_json(raw))
    browser_update_process(
      browser_llm_summary(),
      "skill-export",
      decision,
      if reason == "" {
        "MoonAP recorded the user's save decision."
      } else {
        reason
      },
      "",
    )
    browser_render_artifact_card(
      "SKILL save decision recorded",
      if reason == "" {
        "MoonAP recorded the current save-to-SKILL decision."
      } else {
        reason
      },
      "[\"skill decision\",\"recorded\"]",
      false,
      false,
      false,
    )
  }
}

///|
#cfg(target="js")
fn submit_message() -> Unit {
  let message = browser_message_value()
  let file_name = browser_file_name()
  if message == "" {
    browser_append_message("assistant", "Please enter a task first.")
    return
  }
  browser_append_message("user", message)
  if !browser_llm_is_configured() {
    browser_append_message(
      "assistant", "LLM API is not configured yet. Please save provider, model, and API key first. You can still use SKILL without LLM.",
    )
    browser_open_llm_dialog()
    return
  }
  if browser_formal_verification_enabled() {
    browser_append_message(
      "assistant", "Formal verification is reserved for a future MoonBit 0.9 moon prove step and is not executed yet.",
    )
  }
  if browser_has_file() &&
    (
      message.to_lower().contains("fastq") ||
      file_name.to_lower().contains(".fq")
    ) {
    run_fastq_counter()
    return
  }
  if message.to_lower().contains("fastq") ||
    message.to_lower().contains("generator") ||
    message.to_lower().contains("synthetic") ||
    message.to_lower().contains("moonbit benchmark") ||
    (
      message.to_lower().contains("moonbit") &&
      (
        message.to_lower().contains("write") ||
        message.to_lower().contains("generate") ||
        message.to_lower().contains("compile") ||
        message.to_lower().contains("benchmark")
      )
    ) {
    if message.to_lower().contains("moonbit benchmark") {
      run_moonbit_benchmark(1)
    } else {
      run_llm_moonbit_codegen(
        "MoonBit Task", message, "MoonAP received MoonBit source from the active router provider and is now starting a real native compile probe automatically.",
        false,
      )
    }
    return
  }
  browser_fetch_text(
    context_path(message, file_name),
    fn(raw) {
      browser_set_state(browser_pretty_json(raw))
      let skill = active_skill_from_context(raw)
      browser_update_process(
        skill, "context", "ready", "Context normalized by MoonBit frontend and native server.",
        "",
      )
    },
    fn(error) { show_error("context fetch failed", error) },
  )
}

///|
#cfg(target="js")
fn main {
  ignore(browser_extract_moonbit_source(""))
  browser_enable_minimal_shell()
  browser_prepare_message_input("Generate a FastQ file generator.")
  browser_on_submit(fn() { submit_message() })
  browser_on_click("#detailsToggle", fn() { browser_toggle_details() })
  browser_on_click("#llmButton", fn() { show_llm_entry() })
  browser_on_click("#skillButton", fn() { show_skill_entry() })
  browser_on_onboarding_action(
    fn() { run_moonbit_benchmark(browser_next_benchmark_level()) },
    fn() { show_skill_entry() },
    fn() { show_llm_entry() },
    fn() { browser_open_runtime_log() },
    fn() { browser_download_runtime_log() },
  )
  browser_on_skill_card_click(fn(skill_id) { show_skill_run_plan(skill_id) })
  browser_on_dialog_run(fn() { execute_dialog_skill() })
  browser_on_dialog_cancel(fn() { browser_close_skill_dialog() })
  browser_on_llm_save(fn() { browser_render_onboarding() })
  browser_on_llm_cancel(fn() {  })
  browser_on_compile_artifact(fn() { run_compile_probe() })
  browser_on_repair_artifact(fn() { run_repair_from_compile_summary() })
  browser_on_download_runtime_artifact("wasm", fn() {
    browser_download_runtime_artifact("wasm")
  })
  browser_on_download_runtime_artifact("source", fn() {
    browser_download_runtime_artifact("source")
  })
  browser_on_download_runtime_artifact("compile-report", fn() {
    browser_download_runtime_artifact("compile-report")
  })
  browser_on_download_runtime_artifact("result", fn() {
    browser_download_runtime_artifact("result")
  })
  browser_on_record_demo_runtime_result(fn() {
    browser_record_demo_runtime_result(
      fn(result) { on_runtime_result_ready(result) },
      fn(error) { show_error("demo-runtime failed", error) },
    )
  })
  browser_export_last_artifact_bundle(fn(folder) {
    browser_render_artifact_card(
      "Source bundle exported",
      "MoonAP exported a browser-downloadable source bundle for " +
      folder +
      ". This bundle is for the next implementation step; it is not yet a runnable Personal SKILL.",
      "[\"exported\",\"source bundle\"]",
      true,
      false,
      false,
    )
  })
  browser_on_save_personal_skill(fn() {
    browser_request_skill_save(
      fn(result) {
        ignore(browser_render_personal_skills())
        browser_set_skill_panel_open(true)
        on_skill_save_decision(result)
      },
      fn(error) { show_error("save-to-skill failed", error) },
    )
  })
  browser_watch_runtime_protocol(
    fn(raw) { on_runtime_request_ready(raw) },
    fn(raw) { on_runtime_result_ready(raw) },
    fn(raw) { on_skill_save_decision(raw) },
  )
  ignore(browser_render_personal_skills())
  browser_restore_formal_verification()
  refresh_policies()
}

///|
#cfg(not(target="js"))
fn main {
  println("MoonAP web app is a MoonBit JS-target frontend.")
  println("Build it with: moon build cmd/web_app --target js")
  println("Then copy the generated JS artifact to web/app.js.")
}
