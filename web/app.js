class $PanicError extends Error {}
function $panic() {
  throw new $PanicError();
}
function _M0TPB13StringBuilder(param0) {
  this.val = param0;
}
function $compare_int(a, b) {
  return (a >= b) - (a <= b);
}
function _M0TPC16string10StringView(param0, param1, param2) {
  this.str = param0;
  this.start = param1;
  this.end = param2;
}
const _M0FPB19int__to__string__js = (x, radix) => {
  return x.toString(radix);
};
function $bound_check(arr, index) {
  if (index < 0 || index >= arr.length) throw new Error("Index out of bounds");
}
function _M0TPB8MutLocalGiE(param0) {
  this.val = param0;
}
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
}
function _M0TPB9ArrayViewGsE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__append__message = (role, text) => {
   const messages = document.querySelector("#messages");
   const item = document.createElement("article");
   item.className = `message ${role}`;
   item.textContent = String(text);
   messages?.append(item);
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__set__state = (text) => {
   const state = document.querySelector("#state");
   if (state) state.textContent = String(text);
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app29browser__append__runtime__log = (kind, label, text) => {
   const payload = JSON.stringify({
     ts: new Date().toISOString(),
     kind: String(kind || "event"),
     label: String(label || ""),
     text: String(text || "")
   }) + "\n";
   fetch("/api/logs/moonap-runtime.log", {
     method: "POST",
     headers: { "Content-Type": "text/plain; charset=utf-8" },
     body: payload,
     keepalive: true
   }).catch(() => {});
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app33browser__extract__moonbit__source = (raw) => {
   if (!globalThis.__moonapExtractMoonBitSource) {
     globalThis.__moonapExtractMoonBitSource = (value) => {
       const text = String(value || "").trim();
       if (!text) return "";
       const extract = (source, startMarker, endMarker) => {
         const start = source.indexOf(startMarker);
         if (start < 0) return "";
         const after = source.slice(start + startMarker.length).trim();
         if (!after) return "";
         const end = after.indexOf(endMarker);
         if (end < 0) return "";
         return after.slice(0, end).trim();
       };
       const patterns = [
         ["FILE: cmd/main/main.mbt", "END_FILE"],
         ['<moonbit-file path="cmd/main/main.mbt">', "</moonbit-file>"],
         ["```moonbit", "```"],
         ["```mbt", "```"],
         ["```", "```"]
       ];
       for (const [startMarker, endMarker] of patterns) {
         const extracted = extract(text, startMarker, endMarker);
         if (extracted) return extracted;
       }
       return text;
     };
   }
   return globalThis.__moonapExtractMoonBitSource(raw);
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__render__artifact__card = (title, summary, metaJson, allowCompile, allowRepair, allowSave) => {
   const root = document.querySelector("#artifactActions");
   if (!root) return;
   let meta = [];
   try {
     const parsed = JSON.parse(String(metaJson || "[]"));
     meta = Array.isArray(parsed) ? parsed : [];
   } catch {
     meta = [];
   }
   root.innerHTML = "";
   const card = document.createElement("section");
   card.className = "action-card is-open";
   const metaHtml = meta.map((item) => `<span>${String(item)}</span>`).join("");
   card.innerHTML = `
     <strong>${String(title)}</strong>
     <small>${String(summary)}</small>
     <div class="action-card-meta">${metaHtml}</div>
     <div class="action-card-actions">
       ${allowCompile ? '<button id="compileArtifact" type="button">Run Compile Probe</button>' : ''}
       ${allowRepair ? '<button id="repairArtifact" type="button">Repair with Error Summary</button>' : ''}
       ${allowSave ? '<button id="savePersonalSkill" type="button">Save to Personal-SKILL-Set</button>' : ''}
       <button id="exportSkillBundle" class="secondary" type="button">Export Source Bundle</button>
     </div>`;
   root.append(card);
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app30browser__clear__artifact__card = () => {
   const root = document.querySelector("#artifactActions");
   if (root) root.innerHTML = "";
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__store__compile__report = (raw) => {
   try {
     globalThis.__moonapLastCompileReport = JSON.parse(String(raw));
   } catch {
     globalThis.__moonapLastCompileReport = String(raw);
   }
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__reset__compile__report = () => {
   globalThis.__moonapLastCompileReport = null;
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app32browser__assess__last__benchmark = () => {
   const artifact = globalThis.__moonapLastArtifact;
   const source = String(artifact?.moonbit_source || "");
   const name = String(artifact?.name || "");
   const prompt = String(artifact?.prompt || "");
   const combined = `${name}\n${prompt}`;
   const lowerCombined = combined.toLowerCase();
   const levelMatch = combined.match(/Benchmark Level\s+([1-5])/i);
   const level = levelMatch ? Number(levelMatch[1]) : 0;
   const fnNames = Array.from(source.matchAll(/\bfn\s+([A-Za-z_][A-Za-z0-9_]*)/g)).map((item) => String(item[1] || ""));
   const helperNames = fnNames.filter((item) => item !== "main");
   const lower = source.toLowerCase();
   const hasImport = /\bimport\b/.test(lower);
   const hasHelloMoonbit = /hello moonbit/.test(lower);
   const hasABC = /abc/.test(source);
   const hasControlFlow = /\bif\b|\bmatch\b|\bfor\b|\bwhile\b/.test(source);
   const hasRandomness = /\brandom\b|\bseed\b|\blcg\b|\brand_/.test(lower);
   const hasMain = /\bfn\s+main\b/.test(source);
   const isFastqMoonbitTask = lowerCombined.includes("fastq") && lowerCombined.includes("moonbit") && (lowerCombined.includes("generator") || lowerCombined.includes("synthetic read"));
   const hasFastqHeader = source.includes("@SEQ") || source.includes("@moonap") || source.includes("\"@\"");
   const hasFastqPlus = source.includes("\\n+\\n") || source.includes("\"+\"") || source.includes("+\\n");
   const hasQuality = source.includes("IIII") || source.includes("qual");
   const hasSequenceLogic = /A|C|G|T|N/.test(source) && (hasControlFlow || helperNames.length > 0);
   const missingSignals = [];
   const preserveConstraints = ["keep the original task goal", "keep the source import-free when possible", "return only cmd/main/main.mbt", "preserve wasm-gc compatibility"];
   const result = {
     applicable: level > 0 || isFastqMoonbitTask,
     assessment_kind: "system-assessment",
     task_kind: level > 0 ? `benchmark-l${level}` : (isFastqMoonbitTask ? "fastq-generator" : "general-moonbit"),
     level: level,
     pass: false,
     title: "Compile probe succeeded",
     summary: "MoonAP used the native MoonBit toolchain on this machine and produced a real wasm-gc artifact. Browser-local runtime execution is the next implementation step.",
     meta_json: JSON.stringify(["compile probe ok", "real wasm built", "runtime pending"]),
     missing_signals_json: "[]",
     preserve_constraints_json: JSON.stringify(preserveConstraints),
     repair_hint: "Keep the task intent intact while improving the machine-checkable task structure."
   };
   if (level === 1) {
     if (!hasMain) missingSignals.push("define exactly one fn main");
     if (hasImport) missingSignals.push("remove import usage");
     if (!hasHelloMoonbit) missingSignals.push("return text containing hello moonbit");
     if (helperNames.length !== 0) missingSignals.push("avoid helper functions for Benchmark L1");
     const pass = hasMain && !hasImport && hasHelloMoonbit && helperNames.length === 0;
     result.pass = pass;
     result.title = pass ? "Benchmark L1 passed" : "Compile succeeded, but Benchmark L1 failed";
     result.summary = pass
       ? "Compile succeeded and the generated MoonBit source matches the Level 1 checks: one main function, no imports, no helper functions, and hello moonbit is returned."
       : "Compile succeeded, but the generated source does not fully match Level 1. MoonAP expected one main function, no imports, no helpers, and a return value containing hello moonbit.";
     result.meta_json = JSON.stringify(pass
       ? ["benchmark l1", "compile ok", "quality pass"]
       : ["benchmark l1", "compile ok", "quality failed"]);
     result.repair_hint = "Benchmark L1 should be a single-file MoonBit program with one main function, no imports, no helpers, and a return value that visibly contains hello moonbit.";
   } else if (level === 2) {
     const helper = helperNames.length === 1 ? helperNames[0] : "";
     const mainCallsHelper = helper !== "" && source.includes(`${helper}(`);
     if (!hasMain) missingSignals.push("define fn main");
     if (hasImport) missingSignals.push("remove import usage");
     if (!hasHelloMoonbit) missingSignals.push("return text containing hello moonbit");
     if (helperNames.length !== 1) missingSignals.push("define exactly one helper function");
     if (!mainCallsHelper) missingSignals.push("have main call the helper function");
     const pass = hasMain && !hasImport && hasHelloMoonbit && helperNames.length === 1 && mainCallsHelper;
     result.pass = pass;
     result.title = pass ? "Benchmark L2 passed" : "Compile succeeded, but Benchmark L2 failed";
     result.summary = pass
       ? "Compile succeeded and the generated MoonBit source matches the Level 2 checks: exactly one helper function returns hello moonbit and main calls that helper."
       : "Compile succeeded, but the generated source does not fully match Level 2. MoonAP expected exactly one helper function, no imports, hello moonbit, and main calling the helper.";
     result.meta_json = JSON.stringify(pass
       ? ["benchmark l2", "compile ok", "quality pass"]
       : ["benchmark l2", "compile ok", "quality failed"]);
     result.repair_hint = "Benchmark L2 should keep one helper function that produces hello moonbit, with main delegating to that helper and no imports.";
   } else if (level === 3) {
     if (!hasMain) missingSignals.push("define fn main");
     if (hasImport) missingSignals.push("remove import usage");
     if (!hasABC) missingSignals.push("return text containing ABC");
     if (!hasControlFlow) missingSignals.push("include simple control flow");
     if (hasRandomness) missingSignals.push("remove randomness");
     const pass = hasMain && !hasImport && hasABC && hasControlFlow && !hasRandomness;
     result.pass = pass;
     result.title = pass ? "Benchmark L3 passed" : "Compile succeeded, but Benchmark L3 failed";
     result.summary = pass
       ? "Compile succeeded and the generated MoonBit source matches the Level 3 checks: main returns ABC, uses simple control flow, and avoids imports or randomness."
       : "Compile succeeded, but the generated source does not fully match Level 3. MoonAP expected main to return ABC using simple control flow, with no imports or randomness.";
     result.meta_json = JSON.stringify(pass
       ? ["benchmark l3", "compile ok", "quality pass"]
       : ["benchmark l3", "compile ok", "quality failed"]);
     result.repair_hint = "Benchmark L3 should visibly implement ABC with deterministic control flow and no imports or randomness.";
   } else if (isFastqMoonbitTask) {
     if (!hasMain) missingSignals.push("define fn main");
     if (hasImport) missingSignals.push("remove import usage");
     if (!hasFastqHeader) missingSignals.push("emit a visible FastQ header such as @SEQ or @moonap");
     if (!hasFastqPlus) missingSignals.push("emit a plus line between sequence and quality");
     if (!hasQuality) missingSignals.push("generate an explicit quality string such as IIII or qual");
     if (!hasSequenceLogic) missingSignals.push("include visible sequence-generation logic over A/C/G/T/N");
     const pass = hasMain && !hasImport && hasFastqHeader && hasFastqPlus && hasQuality && hasSequenceLogic;
     result.pass = pass;
     result.title = pass ? "FastQ Generator task passed" : "Compile succeeded, but FastQ Generator task failed";
     result.summary = pass
       ? "Compile succeeded and the generated MoonBit source shows the expected FastQ structure: a header, sequence logic, plus line, and quality generation without imports."
       : "Compile succeeded, but the generated MoonBit source does not yet look like a usable FastQ generator. MoonAP expected visible FastQ structure, sequence-generation logic, and a quality line without imports.";
     result.meta_json = JSON.stringify(pass
       ? ["fastq generator", "compile ok", "quality pass"]
       : ["fastq generator", "compile ok", "quality failed"]);
     result.repair_hint = "Keep the program compiling, but make the MoonBit source visibly look like a FastQ generator with header, sequence, plus line, and quality generation.";
   }
   result.missing_signals_json = JSON.stringify(missingSignals);
   return JSON.stringify(result);
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app35browser__set__benchmark__assessment = (raw) => {
   globalThis.__moonapBenchmarkAssessment = String(raw || "");
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app57browser__repair__last__artifact__with__system__assessment = async (knowledgePack, onDone, onError) => {
   try {
     const artifact = globalThis.__moonapLastArtifact;
     const source = String(artifact?.moonbit_source || "");
     if (!source.trim()) throw new Error("No captured MoonBit source is available for quality repair.");
     let assessment = {};
     try {
       assessment = JSON.parse(String(globalThis.__moonapBenchmarkAssessment || "{}"));
     } catch {
       assessment = {};
     }
     if (!assessment || typeof assessment !== "object") throw new Error("No system assessment is available yet.");
     const readRouter = () => {
       try {
         const parsed = JSON.parse(localStorage.getItem("moonap.llm.router.v1") || "{}");
         return parsed && typeof parsed === "object" ? parsed : {};
       } catch {
         return {};
       }
     };
     const saved = readRouter();
     const providers = Array.isArray(saved.providers) ? saved.providers.filter((item) => item.enabled && String(item.apiKey || "").trim() !== "" && String(item.test_status || "") !== "failed") : [];
     if (providers.length === 0) throw new Error("No enabled LLM provider is available in the router.");
     const cursor = Number.isFinite(saved.cursor) ? saved.cursor : 0;
     const start = ((cursor % providers.length) + providers.length) % providers.length;
     const ordered = providers.slice(start).concat(providers.slice(0, start));
     const proxyPost = async (url, headers, body) => {
       const envelope = [
         `URL\t${String(url)}`,
         ...Object.entries(headers || {}).map(([key, value]) => `HEADER\t${String(key)}\t${String(value).replace(/\r?\n/g, " ")}`),
         "BODY",
         String(body)
       ].join("\n");
       const response = await fetch("/api/llm/proxy", {
         method: "POST",
         headers: { "Content-Type": "text/plain; charset=utf-8" },
         body: envelope
       });
       const text = await response.text();
       let json = {};
       try {
         json = JSON.parse(text);
       } catch {
         const plain = String(text || "")
           .replace(/<script[\s\S]*?<\/script>/gi, " ")
           .replace(/<style[\s\S]*?<\/style>/gi, " ")
           .replace(/<[^>]+>/g, " ")
           .replace(/\s+/g, " ")
           .trim();
         const summarized = plain || `MoonAP proxy returned non-JSON (${response.status})`;
         throw new Error(`Provider returned non-JSON (${response.status}): ${summarized.slice(0, 240)}`);
       }
       if (!response.ok) {
         const detail = json?.error?.detail ? ` ${String(json.error.detail)}` : "";
         throw new Error((json?.error?.message || `LLM request failed (${response.status})`) + detail);
       }
       return json;
     };
     const updatePrompts = (modeText, systemPromptText, userPromptText) => {
       const setText = (selector, value) => {
         const node = document.querySelector(selector);
         if (node) node.textContent = String(value);
       };
       setText("#promptMode", modeText || "No LLM prompt captured yet.");
       setText("#promptSystem", systemPromptText || "No LLM prompt captured yet.");
       setText("#promptUser", userPromptText || "No LLM prompt captured yet.");
     };
     let missingSignals = [];
     let preserveConstraints = [];
     try { missingSignals = JSON.parse(String(assessment?.missing_signals_json || "[]")); } catch {}
     try { preserveConstraints = JSON.parse(String(assessment?.preserve_constraints_json || "[]")); } catch {}
     const originalTask = String(artifact?.prompt || "Generate MoonBit code for the requested task.");
     const systemPrompt = [
       "You are improving MoonBit code for MoonAP after the native compile probe already succeeded.",
       "Target language: MoonBit 0.9.",
       "Return ONLY the revised contents of cmd/main/main.mbt.",
       "Do NOT return markdown fences, explanations, bullet lists, moon.pkg, or moon.mod.json.",
       "Any non-code text is a failed repair.",
       "Preserve compilability under wasm-gc while improving the task-specific quality signals.",
       "Preserve the original task goal."
     ].join("\\n");
     const userPrompt = [
       "Read this MoonBit 0.9 primer first and follow it strictly:",
       String(knowledgePack || ""),
       "",
       `Original task: ${originalTask}`,
       "",
       "System assessment after a successful compile:",
       `- task_kind: ${String(assessment?.task_kind || "general-moonbit")}`,
       `- title: ${String(assessment?.title || "System assessment failed")}`,
       `- summary: ${String(assessment?.summary || "")}`,
       `- repair_hint: ${String(assessment?.repair_hint || "")}`,
       "",
       "Machine-detected missing signals:",
       ...(Array.isArray(missingSignals) && missingSignals.length > 0 ? missingSignals.map((item) => `- ${String(item)}`) : ["- none listed; improve task structure conservatively"]),
       "",
       "Constraints to preserve:",
       ...(Array.isArray(preserveConstraints) && preserveConstraints.length > 0 ? preserveConstraints.map((item) => `- ${String(item)}`) : ["- preserve the original task goal", "- keep wasm-gc compatibility"]),
       "",
       "Current source:",
       source,
       "",
       "Please revise the source so it still compiles and better satisfies the system assessment.",
       "Return the full corrected cmd/main/main.mbt file and nothing else."
     ].join("\\n");
     updatePrompts("quality-repair / full", systemPrompt, userPrompt);
     const requestJson = async (llm) => {
       if (llm.provider === "gemini") {
         const url = `${llm.baseUrl}/v1beta/models/${encodeURIComponent(llm.model)}:generateContent`;
         const json = await proxyPost(url, {
           "Content-Type": "application/json",
           "x-goog-api-key": String(llm.apiKey || "")
         }, JSON.stringify({
           system_instruction: { parts: [{ text: systemPrompt }] },
           contents: [{ role: "user", parts: [{ text: userPrompt }] }],
           generationConfig: { temperature: 0.1 }
         }));
         const text = (json?.candidates?.[0]?.content?.parts || []).map((part) => String(part?.text || "")).join("\\n").trim();
         if (!text) throw new Error("Gemini returned no revised MoonBit source.");
         return { source: text, raw: json };
       }
       const rawBaseUrl = String(llm.baseUrl || "").trim();
       const baseUrl = rawBaseUrl.endsWith("/") ? rawBaseUrl.slice(0, -1) : rawBaseUrl;
       let url = `${baseUrl}/chat/completions`;
       if (llm.provider === "zai") {
         if (baseUrl.endsWith("/chat/completions")) {
           url = baseUrl;
         } else if (baseUrl === "https://open.bigmodel.cn" || baseUrl === "https://open.bigmodel.cn/") {
           url = "https://open.bigmodel.cn/api/paas/v4/chat/completions";
         } else if (!baseUrl.includes("/api/paas/v4")) {
           url = `${baseUrl}/api/paas/v4/chat/completions`;
         }
       }
       const headers = {
         "Content-Type": "application/json",
         "Authorization": `Bearer ${String(llm.apiKey || "")}`
       };
       if (llm.provider === "openrouter") {
         headers["HTTP-Referer"] = "http://127.0.0.1:3000";
         headers["X-Title"] = "MoonAP";
       }
       const json = await proxyPost(url, headers, JSON.stringify({
         model: llm.model,
         messages: [
           { role: "system", content: systemPrompt },
           { role: "user", content: userPrompt }
         ],
         temperature: 0.1
       }));
       const text = String(json?.choices?.[0]?.message?.content || "").trim();
       if (!text) throw new Error(`${llm.provider} returned no revised MoonBit source.`);
       return { source: text, raw: json };
     };
     let repaired = null;
     let selected = null;
     const failures = [];
     for (let index = 0; index < ordered.length; index += 1) {
       const item = ordered[index];
       const llm = {
         provider: item.key,
         model: item.model,
         baseUrl: item.baseUrl,
         apiKey: item.apiKey,
         rotated: providers.length > 1
       };
       try {
         repaired = await requestJson(llm);
         selected = llm;
         const nextCursor = (start + index + 1) % providers.length;
         localStorage.setItem("moonap.llm.router.v1", JSON.stringify({
           providers: Array.isArray(saved.providers) ? saved.providers : providers,
           cursor: nextCursor,
           savedAt: saved.savedAt || new Date().toISOString()
         }));
         break;
       } catch (error) {
         failures.push(`${String(item.key || "provider")}/${String(item.model || "model")}: ${error instanceof Error ? error.message : String(error)}`);
       }
     }
     if (!repaired || !selected) {
       throw new Error(`All enabled providers failed during quality repair. ${failures.join(" | ")}`);
     }
     const cleaned = browser_extract_moonbit_source(String(repaired.source || ""));
     const nextArtifact = {
       ...(artifact || {}),
       moonbit_source: cleaned,
       llm_provider: selected.provider || "unknown",
       llm_model: selected.model || "unknown",
       llm_rotated: Boolean(selected.rotated),
       repair_round: Number(artifact?.repair_round || 0) + 1,
       quality_assessment_used: {
         task_kind: String(assessment?.task_kind || ""),
         title: String(assessment?.title || ""),
         repair_hint: String(assessment?.repair_hint || ""),
         missing_signals_json: String(assessment?.missing_signals_json || "[]")
       },
       llm_response_preview: JSON.stringify(repaired.raw).slice(0, 1200),
       created_at: new Date().toISOString()
     };
     globalThis.__moonapLastArtifact = nextArtifact;
     onDone(JSON.stringify(nextArtifact, null, 2));
   } catch (error) {
     onError(error instanceof Error ? error.message : String(error));
   }
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__next__benchmark__level = () => {
   try {
     const parsed = JSON.parse(globalThis.__moonapBenchmarkAssessment || "{}");
     const level = Number(parsed?.level || 0);
     const pass = Boolean(parsed?.pass);
     if (pass && level >= 1 && level < 3) return level + 1;
   } catch {}
   return 1;
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app38browser__last__artifact__repair__round = () => Number(globalThis.__moonapLastArtifact?.repair_round || 0);
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app32browser__compile__last__artifact = async (formalVerification, onDone, onError) => {
   try {
     const artifact = globalThis.__moonapLastArtifact;
     const source = String(artifact?.moonbit_source || "");
     if (!source.trim()) {
       throw new Error("No captured MoonBit source is available for compile probe.");
     }
     const url = formalVerification ? "/api/artifact/compile?formal=1" : "/api/artifact/compile";
     const response = await fetch(url, {
       method: "POST",
       headers: { "Content-Type": "text/plain; charset=utf-8" },
       body: source
     });
     const text = await response.text();
     if (!response.ok) throw new Error(text || `Compile probe failed (${response.status})`);
     onDone(String(text));
   } catch (error) {
     onError(error instanceof Error ? error.message : String(error));
   }
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app55browser__repair__last__artifact__with__compile__summary = async (formalVerification, knowledgePack, onDone, onError) => {
   try {
     const artifact = globalThis.__moonapLastArtifact;
     const report = globalThis.__moonapLastCompileReport;
     const source = String(artifact?.moonbit_source || "");
     if (!source.trim()) throw new Error("No captured MoonBit source is available for repair.");
     if (!report || typeof report !== "object") throw new Error("No compile summary is available yet.");
     const readRouter = () => {
       try {
         const parsed = JSON.parse(localStorage.getItem("moonap.llm.router.v1") || "{}");
         return parsed && typeof parsed === "object" ? parsed : {};
       } catch {
         return {};
       }
     };
     const saved = readRouter();
     const providers = Array.isArray(saved.providers) ? saved.providers.filter((item) => item.enabled && String(item.apiKey || "").trim() !== "" && String(item.test_status || "") !== "failed") : [];
     const repairMode = localStorage.getItem("moonap.repairFeedbackMode") === "summary" ? "summary" : "raw";
     if (providers.length === 0) throw new Error("No enabled LLM provider is available in the router.");
     const cursor = Number.isFinite(saved.cursor) ? saved.cursor : 0;
     const start = ((cursor % providers.length) + providers.length) % providers.length;
     const ordered = providers.slice(start).concat(providers.slice(0, start));
     const proxyPost = async (url, headers, body) => {
       const envelope = [
         `URL\t${String(url)}`,
         ...Object.entries(headers || {}).map(([key, value]) => `HEADER\t${String(key)}\t${String(value).replace(/\r?\n/g, " ")}`),
         "BODY",
         String(body)
       ].join("\n");
       const response = await fetch("/api/llm/proxy", {
         method: "POST",
         headers: { "Content-Type": "text/plain; charset=utf-8" },
         body: envelope
       });
       const text = await response.text();
       let json = {};
       try {
         json = JSON.parse(text);
       } catch {
         const plain = String(text || "")
           .replace(/<script[\s\S]*?<\/script>/gi, " ")
           .replace(/<style[\s\S]*?<\/style>/gi, " ")
           .replace(/<[^>]+>/g, " ")
           .replace(/\s+/g, " ")
           .trim();
         const summarized = plain || `MoonAP proxy returned non-JSON (${response.status})`;
         throw new Error(`Provider returned non-JSON (${response.status}): ${summarized.slice(0, 240)}`);
       }
       if (!response.ok) {
         const detail = json?.error?.detail ? ` ${String(json.error.detail)}` : "";
         throw new Error((json?.error?.message || `LLM request failed (${response.status})`) + detail);
       }
       return json;
     };
     const updatePrompts = (modeText, systemPromptText, userPromptText) => {
       const setText = (selector, value) => {
         const node = document.querySelector(selector);
         if (node) node.textContent = String(value);
       };
       setText("#promptMode", modeText || "No LLM prompt captured yet.");
       setText("#promptSystem", systemPromptText || "No LLM prompt captured yet.");
       setText("#promptUser", userPromptText || "No LLM prompt captured yet.");
     };
     const originalTask = String(artifact?.prompt || "Generate a Personal FastQ Generator in MoonBit.");
     const lowerTask = originalTask.toLowerCase();
     const isFastqTask = lowerTask.includes("fastq") && lowerTask.includes("moonbit");
     const systemPrompt = [
       "You are repairing MoonBit code for MoonAP.",
       "Target language: MoonBit 0.9.",
       "Return ONLY the repaired contents of cmd/main/main.mbt.",
       "Do NOT return markdown fences, explanations, bullet lists, quoted compiler messages, moon.pkg, or moon.mod.json.",
       "Do NOT describe the errors before writing code.",
       "Do NOT think aloud. Do NOT say 'Okay', 'I need to', 'Let me', or similar phrases.",
       "Any non-code text is a failed repair.",
       "Keep the task behavior and default parameters unchanged.",
       "Preserve the original task goal, not just compilability.",
       "",
       "Follow the MoonBit primer in the user prompt before using any stale prior memory."
     ].join("\\n");
     const fastqConstraints = isFastqTask ? [
       "",
       "FastQ-specific repair constraints:",
       "- main must return the generated FastQ String.",
       "- Do NOT replace the final generated String with ignore(...) or let _ = ....",
       "- Keep the header, sequence, plus line, and quality-line generation logic.",
       "- Prefer the smallest repair that preserves the FastQ task semantics."
     ] : [];
     const userPrompt = [
       "Read this MoonBit 0.9 primer first and follow it strictly:",
       String(knowledgePack || ""),
       "",
       `Original task: ${originalTask}`,
       "",
       "Current compile summary:",
       `- error_kind: ${String(report.summary_kind || report.stage || "compiler-error")}`,
       `- primary_file: ${String(report.primary_file || "cmd/main/main.mbt")}`,
       `- primary_line: ${String(report.primary_line || 0)}`,
       `- likely_cause: ${String(report.likely_cause || "")}`,
       `- repair_hint: ${String(report.repair_hint || "")}`,
       "",
       repairMode === "raw" ? "Raw compiler output:" : "Trimmed compiler output:",
       String(repairMode === "raw" ? (report.output || report.trimmed_output || "") : (report.trimmed_output || report.output || "")),
       "",
       "Current source:",
       source,
       ...fastqConstraints,
       "",
       "Please repair only what is needed to make this compile under wasm-gc.",
       "Return the full corrected cmd/main/main.mbt file and nothing else."
     ].join("\\n");
     updatePrompts("repair / full", systemPrompt, userPrompt);
     const requestJson = async (llm) => {
       if (llm.provider === "gemini") {
         const url = `${llm.baseUrl}/v1beta/models/${encodeURIComponent(llm.model)}:generateContent`;
         const json = await proxyPost(url, {
           "Content-Type": "application/json",
           "x-goog-api-key": String(llm.apiKey || "")
         }, JSON.stringify({
           system_instruction: { parts: [{ text: systemPrompt }] },
           contents: [{ role: "user", parts: [{ text: userPrompt }] }],
           generationConfig: { temperature: 0.1 }
         }));
         const text = (json?.candidates?.[0]?.content?.parts || []).map((part) => String(part?.text || "")).join("\\n").trim();
         if (!text) throw new Error("Gemini returned no repaired MoonBit source.");
         return { source: text, raw: json };
       }
       const rawBaseUrl = String(llm.baseUrl || "").trim();
       const baseUrl = rawBaseUrl.endsWith("/") ? rawBaseUrl.slice(0, -1) : rawBaseUrl;
       let url = `${baseUrl}/chat/completions`;
       if (llm.provider === "zai") {
         if (baseUrl.endsWith("/chat/completions")) {
           url = baseUrl;
         } else if (baseUrl === "https://open.bigmodel.cn" || baseUrl === "https://open.bigmodel.cn/") {
           url = "https://open.bigmodel.cn/api/paas/v4/chat/completions";
         } else if (!baseUrl.includes("/api/paas/v4")) {
           url = `${baseUrl}/api/paas/v4/chat/completions`;
         }
       }
       const headers = {
         "Content-Type": "application/json",
         "Authorization": `Bearer ${String(llm.apiKey || "")}`
       };
       if (llm.provider === "openrouter") {
         headers["HTTP-Referer"] = "http://127.0.0.1:3000";
         headers["X-Title"] = "MoonAP";
       }
       const json = await proxyPost(url, headers, JSON.stringify({
         model: llm.model,
         messages: [
           { role: "system", content: systemPrompt },
           { role: "user", content: userPrompt }
         ],
         temperature: 0.1
       }));
       const text = String(json?.choices?.[0]?.message?.content || "").trim();
       if (!text) throw new Error(`${llm.provider} returned no repaired MoonBit source.`);
       return { source: text, raw: json };
     };
     let repaired = null;
     let selected = null;
     const failures = [];
     for (let index = 0; index < ordered.length; index += 1) {
       const item = ordered[index];
       const llm = {
         provider: item.key,
         model: item.model,
         baseUrl: item.baseUrl,
         apiKey: item.apiKey,
         rotated: providers.length > 1
       };
       try {
         repaired = await requestJson(llm);
         selected = llm;
         const nextCursor = (start + index + 1) % providers.length;
         localStorage.setItem("moonap.llm.router.v1", JSON.stringify({
           providers: Array.isArray(saved.providers) ? saved.providers : providers,
           cursor: nextCursor,
           savedAt: saved.savedAt || new Date().toISOString()
         }));
         break;
       } catch (error) {
         failures.push(`${String(item.key || "provider")}/${String(item.model || "model")}: ${error instanceof Error ? error.message : String(error)}`);
       }
     }
     if (!repaired || !selected) {
       throw new Error(`All enabled providers failed during repair. ${failures.join(" | ")}`);
     }
     const ensureExtractMoonBitSource = () => {
       if (typeof globalThis.__moonapExtractMoonBitSource === "function") return globalThis.__moonapExtractMoonBitSource;
       globalThis.__moonapExtractMoonBitSource = (value) => {
         const text = String(value || "").trim();
         if (!text) return "";
         const extract = (source, startMarker, endMarker) => {
           const start = source.indexOf(startMarker);
           if (start < 0) return "";
           const after = source.slice(start + startMarker.length).trim();
           if (!after) return "";
           const end = after.indexOf(endMarker);
           if (end < 0) return "";
           return after.slice(0, end).trim();
         };
         const patterns = [
           ["FILE: cmd/main/main.mbt", "END_FILE"],
           ['<moonbit-file path="cmd/main/main.mbt">', "</moonbit-file>"],
           ["```moonbit", "```"],
           ["```mbt", "```"],
           ["```", "```"]
         ];
         for (const [startMarker, endMarker] of patterns) {
           const extracted = extract(text, startMarker, endMarker);
           if (extracted) return extracted;
         }
         return text;
       };
       return globalThis.__moonapExtractMoonBitSource;
     };
     const cleaned = ensureExtractMoonBitSource()(String(repaired.source || ""));
     const nextArtifact = {
       ...(artifact || {}),
       moonbit_source: cleaned,
       llm_provider: selected.provider || "unknown",
       llm_model: selected.model || "unknown",
       llm_rotated: Boolean(selected.rotated),
       repair_round: Number(artifact?.repair_round || 0) + 1,
       compile_summary_used: {
         summary_kind: String(report.summary_kind || ""),
         primary_file: String(report.primary_file || ""),
         primary_line: Number(report.primary_line || 0),
         repair_hint: String(report.repair_hint || "")
       },
       llm_response_preview: JSON.stringify(repaired.raw).slice(0, 1200),
       created_at: new Date().toISOString()
     };
     globalThis.__moonapLastArtifact = nextArtifact;
     globalThis.__moonapLastCompileReport = null;
     onDone(JSON.stringify(nextArtifact, null, 2));
   } catch (error) {
     onError(error instanceof Error ? error.message : String(error));
   }
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__update__process = (provider, stage, result, logText, sourceText) => {
   const setText = (selector, value) => {
     const node = document.querySelector(selector);
     if (node) node.textContent = String(value);
   };
   setText("#processProvider", provider || "-");
   setText("#processStage", stage || "-");
   setText("#processResult", result || "waiting");
   setText("#processStatus", result || "waiting");
   setText("#processLog", logText || "");
   if (sourceText !== "") setText("#processSource", sourceText || "No generated source yet.");
   const payload = JSON.stringify({
     ts: new Date().toISOString(),
     provider: String(provider || "-"),
     stage: String(stage || "-"),
     result: String(result || "waiting"),
     log_text: String(logText || ""),
     source_text: String(sourceText || "").slice(0, 2000)
   }) + "\n";
   fetch("/api/logs/moonap-runtime.log", {
     method: "POST",
     headers: { "Content-Type": "text/plain; charset=utf-8" },
     body: payload,
     keepalive: true
   }).catch(() => {});
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app30browser__update__result__panel = (raw) => {
   let data = {};
   try { data = JSON.parse(String(raw)); } catch { data = { status: "error" }; }
   const panel = document.querySelector("#resultPanel");
   panel?.classList.add("is-open");
   const setText = (selector, value) => {
     const node = document.querySelector(selector);
     if (node) node.textContent = String(value);
   };
   const bytes = (value) => {
     const n = Number(value || 0);
     if (n >= 1073741824) return `${(n / 1073741824).toFixed(2)} GB`;
     if (n >= 1048576) return `${(n / 1048576).toFixed(2)} MB`;
     if (n >= 1024) return `${(n / 1024).toFixed(1)} KB`;
     return `${n} B`;
   };
   const pct = Math.max(0, Math.min(100, Number(data.progress_percent ?? (data.status === "done" ? 100 : 0))));
   const fill = document.querySelector("#progressFill");
   if (fill) fill.style.width = `${pct}%`;
   setText("#resultStatus", data.status || "ready");
   setText("#resultTitle", data.status === "generated" ? "Synthetic FastQ generated locally" : "Browser-local FastQ analysis");
   setText("#metricFile", data.file_name || "-");
   setText("#metricProcessed", bytes(data.bytes_processed ?? data.file_size_bytes ?? 0));
   setText("#metricReads", data.reads_seen ?? data.read_count ?? "0");
   setText("#metricTarget", data.target_base_count ?? data.expected_n_count ?? "0");
   setText("#metricBases", data.total_bases ?? "0");
   setText("#metricUploaded", bytes(data.uploaded_bytes ?? 0));
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app23browser__message__value = () => String(document.querySelector("#message")?.value || "").trim();
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app32browser__prepare__message__input = (defaultText) => {
   const textarea = document.querySelector("#message");
   if (!textarea) return;
   const applyTone = () => {
     textarea.classList.toggle("suggested", String(textarea.value || "") === String(defaultText));
   };
   if (String(textarea.value || "").trim() === "") {
     textarea.value = String(defaultText);
   }
   applyTone();
   if (!textarea.dataset.moonapPrepared) {
     textarea.addEventListener("input", applyTone);
     textarea.dataset.moonapPrepared = "true";
   }
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app38browser__restore__formal__verification = () => {
   const enabled = localStorage.getItem("moonap.formalVerification") === "true";
   const mainToggle = document.querySelector("#formalVerification");
   const dialogToggle = document.querySelector("#routerFormalVerification");
   if (mainToggle) mainToggle.checked = enabled;
   if (dialogToggle) dialogToggle.checked = enabled;
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__toggle__details = () => {
   const root = document.querySelector(".app-shell");
   const button = document.querySelector("#detailsToggle");
   if (!root || !button) return;
   const open = !root.classList.contains("details-open");
   root.classList.toggle("details-open", open);
   button.setAttribute("aria-expanded", open ? "true" : "false");
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__file__name = () => {
   const file = document.querySelector("#fileInput")?.files?.[0];
   return String(file?.name || "");
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app18browser__has__file = () => Boolean(document.querySelector("#fileInput")?.files?.[0]);
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app38browser__formal__verification__enabled = () => Boolean(document.querySelector("#formalVerification")?.checked);
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app28browser__run__fastq__counter = async (targetBase, onProgress, onDone, onError) => {
   try {
     const file = document.querySelector("#fileInput")?.files?.[0];
     if (!file) {
       onError("Choose a FastQ file first.");
       return;
     }
     const chunkSize = 4 * 1024 * 1024;
     const target = String(targetBase || "N").toUpperCase();
     let offset = 0;
     let carry = "";
     let lineMod = 0;
     let readCount = 0;
     let sequenceLines = 0;
     let totalBases = 0;
     let targetCount = 0;
     const started = performance.now();
     const countLine = (line) => {
       sequenceLines += 1;
       totalBases += line.length;
       for (let i = 0; i < line.length; i += 1) {
         if (line[i].toUpperCase() === target) targetCount += 1;
       }
     };
     while (offset < file.size) {
       const end = Math.min(offset + chunkSize, file.size);
       const text = await file.slice(offset, end).text();
       const merged = carry + text;
       const hasFinalNewline = merged.endsWith("\n") || merged.endsWith("\r");
       const lines = merged.split(/\r?\n/);
       carry = hasFinalNewline ? "" : String(lines.pop() || "");
       for (const line of lines) {
         if (lineMod === 1) countLine(line);
         if (lineMod === 3) readCount += 1;
         lineMod = (lineMod + 1) % 4;
       }
       offset = end;
       const pct = file.size === 0 ? 100 : Math.floor((offset / file.size) * 100);
       onProgress(JSON.stringify({
         status: "counting",
         file_name: file.name,
         file_size_bytes: file.size,
         chunk_size_bytes: chunkSize,
         bytes_processed: offset,
         progress_percent: pct,
         uploaded_bytes: 0,
         llm_receives_file_contents: false,
         target_base: target
       }, null, 2));
       await new Promise((resolve) => setTimeout(resolve, 0));
     }
     if (carry.length > 0) {
       if (lineMod === 1) countLine(carry);
       if (lineMod === 3) readCount += 1;
     }
     const elapsedMs = Math.round(performance.now() - started);
     onDone(JSON.stringify({
       status: "done",
       file_name: file.name,
       file_size_bytes: file.size,
       reads_seen: readCount,
       sequence_lines: sequenceLines,
       total_bases: totalBases,
       target_base: target,
       target_base_count: targetCount,
       target_base_fraction: totalBases === 0 ? 0 : targetCount / totalBases,
       elapsed_ms: elapsedMs,
       uploaded_bytes: 0,
       llm_receives_file_contents: false,
       privacy: "File contents stayed in this browser."
     }, null, 2));
   } catch (error) {
     onError(error instanceof Error ? error.message : String(error));
   }
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app32browser__generate__fastq__sample = (readCountRaw, readLengthRaw, nRateText, seedRaw, onDone, onError) => {
   try {
     if (globalThis.__moonapAllowDownload !== "dialog-run") {
       throw new Error("Download blocked: open the SKILL settings dialog and click Run.");
     }
     globalThis.__moonapAllowDownload = "";
     const readCount = Math.max(1, Math.min(1000000, Number(readCountRaw) || 10000));
     const readLength = Math.max(1, Math.min(10000, Number(readLengthRaw) || 150));
     const nRate = Math.max(0, Math.min(1, Number(nRateText) || 0.01));
     const originalSeed = Number(seedRaw) || 42;
     let seed = originalSeed;
     const bases = ["A", "C", "G", "T"];
     const rand = () => {
       seed = (seed * 1664525 + 1013904223) >>> 0;
       return seed / 4294967296;
     };
     const chunks = [];
     let nCount = 0;
     let totalBases = 0;
     for (let read = 0; read < readCount; read += 1) {
       let seq = "";
       for (let i = 0; i < readLength; i += 1) {
         totalBases += 1;
         if (rand() < nRate) {
           seq += "N";
           nCount += 1;
         } else {
           seq += bases[Math.floor(rand() * bases.length)];
         }
       }
       chunks.push(`@moonap_${read}\n${seq}\n+\n${"I".repeat(readLength)}\n`);
     }
     const blob = new Blob(chunks, { type: "text/plain;charset=utf-8" });
     const url = URL.createObjectURL(blob);
     const link = document.createElement("a");
     link.href = url;
     link.download = "moonap-demo.fastq";
     document.body.append(link);
     link.click();
     link.remove();
     setTimeout(() => URL.revokeObjectURL(url), 1000);
     onDone(JSON.stringify({
       status: "generated",
       file_name: "moonap-demo.fastq",
       read_count: readCount,
       read_length: readLength,
       total_bases: totalBases,
       expected_n_count: nCount,
       n_rate: nRate,
       random_seed: originalSeed,
       llm_output_tokens_for_file_contents: 0,
       note: "LLM would output only this compact recipe; MoonAP generated the file locally."
     }, null, 2));
   } catch (error) {
     onError(error instanceof Error ? error.message : String(error));
   }
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__on__submit = (handler) => {
   const form = document.querySelector("#chatForm");
   form?.addEventListener("submit", (event) => {
     event.preventDefault();
     try {
       handler();
     } catch (error) {
       console.error("MoonAP submit handler failed:", error);
       alert(`MoonAP submit failed: ${error instanceof Error ? error.message : String(error)}`);
     }
   });
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app18browser__on__click = (selector, handler) => {
   document.querySelector(String(selector))?.addEventListener("click", (event) => {
     event.preventDefault();
     try {
       handler();
     } catch (error) {
       console.error(`MoonAP click handler failed for ${String(selector)}:`, error);
       alert(`MoonAP click failed: ${error instanceof Error ? error.message : String(error)}`);
     }
   });
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__on__skill__card__click = (handler) => {
   document.addEventListener("click", (event) => {
     const card = event.target?.closest?.(".skill-card[data-skill-id]");
     if (!card) return;
     event.preventDefault();
     event.stopPropagation();
     document.querySelectorAll(".skill-card").forEach((card) => card.classList.remove("is-selected"));
     card.classList.add("is-selected");
     try {
       handler(String(card.dataset?.skillId || ""));
     } catch (error) {
       console.error("MoonAP skill click failed:", error);
       alert(`MoonAP skill failed: ${error instanceof Error ? error.message : String(error)}`);
     }
   });
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__on__onboarding__action = (onRunBenchmark, onOpenSkill, onEditLlm, onOpenLog, onDownloadLog) => {
   document.addEventListener("click", (event) => {
     const target = event.target?.closest?.("#onboardingRunBenchmark, #onboardingOpenSkill, #onboardingEditLLM, #onboardingOpenLog, #onboardingDownloadLog");
     if (!target) return;
     event.preventDefault();
     event.stopPropagation();
     try {
       if (target.id === "onboardingRunBenchmark") {
         onRunBenchmark();
       } else if (target.id === "onboardingOpenSkill") {
         onOpenSkill();
       } else if (target.id === "onboardingEditLLM") {
         onEditLlm();
       } else if (target.id === "onboardingOpenLog") {
         onOpenLog();
       } else if (target.id === "onboardingDownloadLog") {
         onDownloadLog();
       }
     } catch (error) {
       console.error("MoonAP onboarding action failed:", error);
       alert(`MoonAP onboarding failed: ${error instanceof Error ? error.message : String(error)}`);
     }
   });
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app28browser__open__skill__dialog = (skillId) => {
   let dialog = document.querySelector("#skillDialog");
   if (!dialog) {
     dialog = document.createElement("dialog");
     dialog.id = "skillDialog";
     dialog.className = "skill-dialog";
     dialog.innerHTML = `
       <form method="dialog" class="skill-dialog-body">
         <div class="dialog-head"><span id="dialogScope">SKILL</span><strong id="dialogTitle">Configure SKILL</strong></div>
         <p id="dialogSummary" class="dialog-summary"></p>
         <div id="dialogFields" class="dialog-fields"></div>
         <div class="dialog-actions"><button id="dialogCancel" class="dialog-button" type="button">Cancel</button><button id="dialogRun" class="dialog-button primary" type="button">Run</button></div>
       </form>`;
     document.body.append(dialog);
   }
   const scope = document.querySelector("#dialogScope");
   const title = document.querySelector("#dialogTitle");
   const summary = document.querySelector("#dialogSummary");
   const fields = document.querySelector("#dialogFields");
   const set = (node, value) => { if (node) node.textContent = String(value); };
   if (!dialog || !fields) return;
   fields.innerHTML = "";
   dialog.dataset.skillId = String(skillId);
   const addField = (id, label, value, mode = "numeric") => {
     const item = document.createElement("label");
     item.textContent = label;
     const input = document.createElement("input");
     input.id = `param-${id}`;
     input.value = value;
     input.inputMode = mode;
     item.append(input);
     fields.append(item);
   };
   if (skillId.includes("moonbit.fastq-generator")) {
     set(scope, "SKILL-Hub / MoonBit");
     set(title, "MoonBit FastQ Generator");
     set(summary, "Ask the active LLM router to generate a MoonBit FastQ generator program, then run a real compile probe automatically.");
     addField("readCount", "Read count", "10000");
     addField("readLength", "Read length", "150");
     addField("nRatePerMille", "N rate per mille", "10");
     addField("seed", "Random seed", "42");
   } else if (skillId.includes("fastq-generator")) {
     const personal = skillId.includes("personal.fastq-generator");
     set(scope, personal ? "1.1 Personal-SKILL-Set" : "SKILL-Hub / Research / Synthetic");
     set(title, personal ? "Personal FastQ Generator" : "FastQ Generator");
     set(summary, "Generate deterministic FastQ locally. Confirm parameters before MoonAP downloads the file.");
     addField("readCount", "Read count", "10000");
     addField("readLength", "Read length", "150");
     addField("nRate", "N rate", "0.01", "decimal");
     addField("seed", "Random seed", "42");
   } else if (skillId.includes("moonbit-benchmark")) {
     set(scope, "SKILL-Hub / MoonBit");
     set(title, "MoonBit Benchmark Ladder");
     set(summary, "Start from a tiny MoonBit task and step upward. Use this to check whether the active LLM router can stay in real MoonBit syntax before we try harder jobs.");
     addField("benchmarkLevel", "Benchmark level (1-5)", "1");
   } else if (skillId.includes("free-llm-eval")) {
     set(scope, "SKILL-Hub / Experiments");
     set(title, "Free LLM MoonBit Eval");
     set(summary, "Run L1-L3 MoonBit experiments against every enabled provider/model, then persist raw JSON plus a readable markdown summary.");
     addField("evalMaxLevel", "Max benchmark level (1-3)", "3");
   } else if (skillId.includes("fastq-base-counter")) {
     set(scope, "SKILL-Hub / Research / FastQ");
     set(title, "FastQ Base Counter");
     set(summary, "Count a selected base in a browser-local FastQ file. Select a file with the + button before running.");
     addField("targetBase", "Target base", "N", "text");
   } else if (skillId === "personal") {
     set(scope, "1.1 Personal-SKILL-Set");
     set(title, "Personal-MoonAP-SKILL-Set");
     set(summary, "Local reusable SKILL folders on this computer. Folder selection and save-to-local workflow are planned next.");
   } else {
     set(scope, "1.2 SKILL-Hub");
     set(title, skillId.includes("gomoku") ? "Gomoku" : "Excel Max Amount Row");
     set(summary, "This SKILL is registered in MoonAP-SKILL-Hub. Full execution UI will follow the FastQ MVP.");
   }
   dialog.showModal();
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app29browser__close__skill__dialog = () => document.querySelector("#skillDialog")?.close();
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app26browser__dialog__skill__id = () => String(document.querySelector("#skillDialog")?.dataset?.skillId || "");
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app22browser__dialog__param = (name) => String(document.querySelector(`#param-${String(name)}`)?.value || "");
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__dialog__param__int = (name, fallback) => {
   const raw = document.querySelector(`#param-${String(name)}`)?.value;
   const value = Number.parseInt(String(raw || ""), 10);
   return Number.isFinite(value) && value > 0 ? value : fallback;
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__on__dialog__run = (handler) => document.addEventListener("click", (event) => {
   if (event.target?.id === "dialogRun") {
     event.preventDefault();
     event.stopPropagation();
     globalThis.__moonapAllowDownload = "dialog-run";
     handler();
     setTimeout(() => {
       if (globalThis.__moonapAllowDownload === "dialog-run") globalThis.__moonapAllowDownload = "";
     }, 0);
   }
 });
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__on__dialog__cancel = (handler) => document.addEventListener("click", (event) => {
   if (event.target?.id === "dialogCancel") {
     event.preventDefault();
     handler();
   }
 });
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app26browser__open__llm__dialog = () => {
   const parseModelList = (raw) => {
     const seen = new Set();
     const values = String(raw || "")
       .split(/\r?\n|,/)
       .map((item) => String(item || "").trim())
       .filter((item) => item.length > 0);
     return values.filter((item) => {
       const key = item.toLowerCase();
       if (seen.has(key)) return false;
       seen.add(key);
       return true;
     });
   };
   const normalizeProviderEntry = (item) => {
     const key = String(item?.key || "").toLowerCase();
     const model = String(item?.model || "").trim();
     const apiKey = String(item?.apiKey || "").trim();
     const enabled = Boolean(item?.enabled);
     const test_status = String(item?.test_status || "").trim();
     const test_message = String(item?.test_message || "").trim();
     const tested_at = String(item?.tested_at || "").trim();
     let baseUrl = String(item?.baseUrl || "").trim();
     if (key === "gemini") {
       baseUrl = "https://generativelanguage.googleapis.com";
     } else if (key === "openrouter") {
       baseUrl = "https://openrouter.ai/api/v1";
     } else if (key === "zai") {
       baseUrl = "https://open.bigmodel.cn/api/paas/v4";
     } else if (key === "siliconflow") {
       baseUrl = "https://api.siliconflow.cn/v1";
     } else if (key === "openai") {
       baseUrl = "moonap://codex-demo";
     } else if (key === "nvidia") {
       baseUrl = "https://integrate.api.nvidia.com/v1";
     }
     return { key, enabled, model, baseUrl, apiKey, test_status, test_message, tested_at };
   };
   const providerPriority = (provider, model) => {
     const key = String(provider || "").toLowerCase();
     const name = String(model || "").toLowerCase();
     let score = 0;
     if (name.includes("gpt-5.4")) score += 1200;
     else
     if (name.includes("llama-4-maverick-17b-128e-instruct")) score += 1000;
     else if (name.includes("glm-5.1")) score += 900;
     else if (name.includes("gemini-3-flash-preview")) score += 840;
     else if (name.includes("gemini-3.1-flash-lite")) score += 820;
     else if (name.includes("gemini-2.5-flash")) score += 800;
     else if (name.includes("gemini-2.5-flash-lite")) score += 780;
     else if (name.includes("gemini-2-flash-lite")) score += 765;
     else if (name.includes("gemini-2-flash")) score += 760;
     else if (name.includes("glm-5-turbo")) score += 780;
     else if (name === "glm-5" || name.includes("glm-5 ")) score += 770;
     else if (name.includes("glm-4.7")) score += 740;
     else if (name.includes("glm-4-flashx-250414")) score += 735;
     else if (name.includes("glm-4-long")) score += 730;
     else if (name.includes("glm-4.6")) score += 720;
     else if (name.includes("glm-4.5-airx")) score += 700;
     else if (name.includes("glm-4.5-air")) score += 690;
     else if (name.includes("glm-4.7-flashx")) score += 680;
     else if (name.includes("glm-4.7-flash")) score += 670;
     else if (name.includes("qwen2.5-coder-32b-instruct")) score += 620;
     else if (name.includes("llama-4-maverick-17b-128e-instruct")) score += 610;
     else if (name.includes("llama-4-scout-17b-16e-instruct")) score += 600;
     else if (name.includes("llama-3.3-70b-instruct")) score += 590;
     else if (name.includes("qwen2-7b-instruct")) score += 520;
     else if (name.includes("glm-4-9b-chat")) score += 510;
     else if (name.includes("internlm2_5-7b-chat")) score += 500;
     else if (name.includes("mistral-7b-instruct")) score += 490;
     else if (name.includes("chatglm3-6b")) score += 470;
     else if (name.includes("qwen3-coder:free")) score += 300;
     else if (name.includes("nemotron-3-super-120b-a12b:free")) score += 280;
     else if (name.includes("openrouter/free")) score += 200;
     else if (name.includes("openrouter/auto")) score += 180;
     if (key === "openai") score += 120;
     else if (key === "nvidia") score += 90;
     else if (key === "zai") score += 70;
     else if (key === "gemini") score += 40;
     else if (key === "siliconflow") score += 30;
     else if (key === "openrouter") score -= 1000;
     return score;
   };
   const sortMoonBitProviders = (providers) => [...providers].sort((a, b) => providerPriority(b?.key, b?.model) - providerPriority(a?.key, a?.model));
   const expandProviderSpec = (spec) => {
     const models = parseModelList(spec?.modelsText || spec?.model || "");
     if (models.length === 0) {
       return [{ key: spec?.key, enabled: Boolean(spec?.enabled), model: "", baseUrl: spec?.baseUrl, apiKey: spec?.apiKey }];
     }
     return models.map((model) => ({ key: spec?.key, enabled: Boolean(spec?.enabled), model, baseUrl: spec?.baseUrl, apiKey: spec?.apiKey }));
   };
   const readRouter = () => {
     try {
       const parsed = JSON.parse(localStorage.getItem("moonap.llm.router.v1") || "{}");
       return parsed && typeof parsed === "object" ? parsed : {};
     } catch (error) {
       console.warn("MoonAP reset invalid LLM router storage:", error);
       try { localStorage.removeItem("moonap.llm.router.v1"); } catch {}
       return {};
     }
   };
   const routerProfileVersion = 5;
   const providerConfigs = [
     {
       key: "openai",
       enabled: true,
       baseUrl: "moonap://codex-demo",
       models: [
         { id: "gpt-5.4", enabled: true }
       ]
     },
     {
       key: "nvidia",
       enabled: true,
       baseUrl: "https://integrate.api.nvidia.com/v1",
       models: [
         { id: "meta/llama-4-maverick-17b-128e-instruct", enabled: true },
         { id: "qwen/qwen2.5-coder-32b-instruct", enabled: false },
         { id: "meta/llama-4-scout-17b-16e-instruct", enabled: false },
         { id: "meta/llama-3.3-70b-instruct", enabled: false }
       ]
     },
     {
       key: "zai",
       enabled: true,
       baseUrl: "https://open.bigmodel.cn/api/paas/v4",
       models: [
         { id: "glm-5.1", enabled: true },
         { id: "glm-5-turbo", enabled: false },
         { id: "glm-5", enabled: false },
         { id: "glm-4.7", enabled: false },
         { id: "glm-4.7-flash", enabled: false },
         { id: "glm-4.7-flashx", enabled: false },
         { id: "glm-4.6", enabled: false },
         { id: "glm-4.5-air", enabled: false },
         { id: "glm-4.5-airx", enabled: false },
         { id: "glm-4-long", enabled: false },
         { id: "glm-4-flashx-250414", enabled: false }
       ]
     },
     {
       key: "gemini",
       enabled: false,
       baseUrl: "https://generativelanguage.googleapis.com",
       models: [
         { id: "gemini-3-flash-preview", enabled: false },
         { id: "gemini-3.1-flash-lite-preview", enabled: false },
         { id: "gemini-2.5-flash", enabled: false },
         { id: "gemini-2.5-flash-lite", enabled: false },
         { id: "gemini-2-flash", enabled: false },
         { id: "gemini-2-flash-lite", enabled: false }
       ]
     },
     {
       key: "siliconflow",
       enabled: false,
       baseUrl: "https://api.siliconflow.cn/v1",
       models: [
         { id: "THUDM/glm-4-9b-chat", enabled: false },
         { id: "Qwen/Qwen2-7B-Instruct", enabled: false },
         { id: "internlm/internlm2_5-7b-chat", enabled: false },
         { id: "mistralai/Mistral-7B-Instruct-v0.2", enabled: false },
         { id: "THUDM/chatglm3-6b", enabled: false }
       ]
     },
     {
       key: "openrouter",
       enabled: false,
       baseUrl: "https://openrouter.ai/api/v1",
       models: [
         { id: "qwen/qwen3-coder:free", enabled: false },
         { id: "nvidia/nemotron-3-super-120b-a12b:free", enabled: false },
         { id: "openrouter/free", enabled: false }
       ]
     }
   ];
   const defaults = providerConfigs.flatMap((spec) =>
     spec.models.map((model) => ({
       key: spec.key,
       enabled: Boolean(spec.enabled && model.enabled),
       model: model.id,
       baseUrl: spec.baseUrl,
       apiKey: spec.key === "openai" ? "codex-demo-mode" : ""
     }))
   );
   const saved = readRouter();
   const mergeWithDefaults = (savedProviders, defaultProviders) => {
     const savedNormalized = Array.isArray(savedProviders) ? savedProviders.map(normalizeProviderEntry) : [];
     const defaultNormalized = defaultProviders.map(normalizeProviderEntry);
     const keys = providerConfigs.map((item) => item.key);
     const merged = [];
     for (const key of keys) {
       const defaultsForKey = defaultNormalized.filter((item) => item.key === key && String(item.model || "").trim() !== "");
       const savedForKey = savedNormalized.filter((item) => item.key === key && String(item.model || "").trim() !== "");
       const shared = savedForKey[0] || defaultsForKey[0] || { key, enabled: false, baseUrl: "", apiKey: "" };
       const useSavedToggles = Number(saved?.profile_version || 0) >= routerProfileVersion;
       const seen = new Map();
       for (const item of defaultsForKey) {
         const savedMatch = savedForKey.find((entry) => String(entry.model || "").toLowerCase() === String(item.model || "").toLowerCase());
         seen.set(String(item.model || "").toLowerCase(), {
           ...item,
           enabled: useSavedToggles ? Boolean(savedMatch?.enabled) : Boolean(item.enabled),
           baseUrl: String(shared.baseUrl || item.baseUrl || ""),
           apiKey: String(shared.apiKey || ""),
           test_status: String(savedMatch?.test_status || ""),
           test_message: String(savedMatch?.test_message || ""),
           tested_at: String(savedMatch?.tested_at || "")
         });
       }
       merged.push(...Array.from(seen.values()));
     }
     return sortMoonBitProviders(merged);
   };
   const providers = mergeWithDefaults(saved.providers, defaults);
   try {
     localStorage.setItem("moonap.llm.router.v1", JSON.stringify({ providers, cursor: Number.isFinite(saved.cursor) ? saved.cursor : 0, savedAt: saved.savedAt || new Date().toISOString(), profile_version: routerProfileVersion }));
   } catch {}
   const grouped = {};
   for (const item of providers) {
     const key = String(item.key || "");
     if (!grouped[key]) grouped[key] = [];
     grouped[key].push(item);
   }
   const escapeHtml = (value) => String(value || "")
     .replaceAll("&", "&amp;")
     .replaceAll("<", "&lt;")
     .replaceAll(">", "&gt;")
     .replaceAll("\"", "&quot;");
   const bind = (name, ids) => {
     const items = grouped[name] || defaults.filter((entry) => entry.key === name) || [];
     const item = items[0] || {};
     const enable = document.querySelector(`#${ids.enable}`);
     const model = document.querySelector(`#${ids.model}`);
     const base = document.querySelector(`#${ids.base}`);
     const key = document.querySelector(`#${ids.key}`);
     if (enable) enable.checked = items.some((entry) => Boolean(entry.enabled));
     if (model) {
       model.innerHTML = items.map((entry, index) => {
         const modelId = String(entry.model || "");
         const checkboxId = `routerModelCheck-${name}-${index}`;
         return `<label class="router-model-option" for="${checkboxId}"><input id="${checkboxId}" type="checkbox" data-provider="${name}" value="${escapeHtml(modelId)}" ${entry.enabled ? "checked" : ""} /><span>${escapeHtml(modelId)}</span></label>`;
       }).join("");
     }
     if (base) base.value = String(item.baseUrl || "");
     if (key) key.value = String(item.apiKey || "");
     const syncDisabled = () => {
       const disabled = !Boolean(enable?.checked);
       model?.querySelectorAll("input[type=checkbox]")?.forEach((node) => { node.disabled = disabled; });
       if (model) model.style.opacity = disabled ? "0.55" : "1";
     };
     enable?.addEventListener("change", syncDisabled);
     syncDisabled();
   };
   bind("openai", { enable: "routerEnableOpenAI", model: "routerModelsOpenAI", base: "routerBaseOpenAI", key: "routerKeyOpenAI" });
   bind("gemini", { enable: "routerEnableGemini", model: "routerModelsGemini", base: "routerBaseGemini", key: "routerKeyGemini" });
   bind("siliconflow", { enable: "routerEnableSiliconFlow", model: "routerModelsSiliconFlow", base: "routerBaseSiliconFlow", key: "routerKeySiliconFlow" });
   bind("nvidia", { enable: "routerEnableNVIDIA", model: "routerModelsNVIDIA", base: "routerBaseNVIDIA", key: "routerKeyNVIDIA" });
   bind("zai", { enable: "routerEnableZAI", model: "routerModelsZAI", base: "routerBaseZAI", key: "routerKeyZAI" });
   bind("openrouter", { enable: "routerEnableOpenRouter", model: "routerModelsOpenRouter", base: "routerBaseOpenRouter", key: "routerKeyOpenRouter" });
   const verification = localStorage.getItem("moonap.formalVerification") === "true";
   const toggle = document.querySelector("#routerFormalVerification");
   if (toggle) toggle.checked = verification;
   const repairFeedbackRaw = localStorage.getItem("moonap.repairFeedbackMode") !== "summary";
   const repairFeedbackToggle = document.querySelector("#routerRepairUseRawCompilerOutput");
   if (repairFeedbackToggle) repairFeedbackToggle.checked = repairFeedbackRaw;
   document.querySelector("#llmDialog")?.showModal();
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app28browser__llm__is__configured = () => {
   let saved = {};
   try {
     const parsed = JSON.parse(localStorage.getItem("moonap.llm.router.v1") || "{}");
     saved = parsed && typeof parsed === "object" ? parsed : {};
   } catch (error) {
     console.warn("MoonAP reset invalid LLM router storage:", error);
     try { localStorage.removeItem("moonap.llm.router.v1"); } catch {}
   }
   const providers = Array.isArray(saved.providers) ? saved.providers : [];
   return providers.some((item) => item.enabled && String(item.apiKey || "").trim() !== "" && String(item.test_status || "") !== "failed");
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__llm__summary = () => {
   let saved = {};
   try {
     const parsed = JSON.parse(localStorage.getItem("moonap.llm.router.v1") || "{}");
     saved = parsed && typeof parsed === "object" ? parsed : {};
   } catch (error) {
     console.warn("MoonAP reset invalid LLM router storage:", error);
     try { localStorage.removeItem("moonap.llm.router.v1"); } catch {}
   }
   const providers = Array.isArray(saved.providers) ? saved.providers.filter((item) => item.enabled && String(item.apiKey || "").trim() !== "" && String(item.test_status || "") !== "failed") : [];
   if (providers.length === 0) return "not configured";
   const labels = providers.map((item) => `${item.key}/${item.model}`);
   return `${providers.length} provider(s): ${labels.join(", ")}`;
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__render__onboarding = () => {
   const root = document.querySelector("#onboardingCard");
   if (!root) return;
   const benchmarkPrompt = "Write the smallest valid cmd/main/main.mbt that compiles under wasm-gc and returns the string hello moonbit. Return only the file contents.";
   const textarea = document.querySelector("#message");
   const currentValue = String(textarea?.value || "").trim();
   if (textarea && (currentValue === "" || textarea.classList.contains("suggested"))) {
     textarea.value = benchmarkPrompt;
     textarea.classList.add("suggested");
   }
   const readRouter = () => {
     try {
       const parsed = JSON.parse(localStorage.getItem("moonap.llm.router.v1") || "{}");
       return parsed && typeof parsed === "object" ? parsed : {};
     } catch {
       return {};
     }
   };
   const saved = readRouter();
   const providers = Array.isArray(saved.providers) ? saved.providers : [];
   const usable = providers.filter((item) => Boolean(item?.enabled) && String(item?.apiKey || "").trim() !== "" && String(item?.test_status || "") !== "failed");
   const primary = usable[0];
   const primaryLabel = primary ? `${String(primary.key || "")}/${String(primary.model || "")}` : "OpenAI/GPT-5.4 (Codex-demo mode)";
   let benchmark = {};
   try { benchmark = JSON.parse(globalThis.__moonapBenchmarkAssessment || "{}"); } catch { benchmark = {}; }
   const passedLevel = Number(benchmark?.pass ? benchmark.level || 0 : 0);
   const nextBenchmarkLevel = passedLevel >= 1 && passedLevel < 3 ? passedLevel + 1 : 1;
   const nextBenchmarkLabel = passedLevel >= 1 && passedLevel < 3 ? `Run Benchmark L${nextBenchmarkLevel}` : "Run Benchmark L1";
   const benchmarkSummary = passedLevel >= 1
     ? `MoonAP already verified Benchmark L${passedLevel}. Recommended next step: run L${nextBenchmarkLevel} to keep climbing the quality ladder.`
     : "MoonAP can now route requests through checked providers. Recommended next step: run MoonBit Benchmark Ladder at Level 1 to verify the full generate -> compile flow.";
   const isReady = usable.length > 0;
   root.classList.add("is-open");
   root.innerHTML = isReady
     ? `
       <strong>LLM Router is ready</strong>
       <small>${benchmarkSummary} Current primary route: ${primaryLabel}</small>
       <div class="onboarding-actions">
         <button id="onboardingRunBenchmark" type="button">${nextBenchmarkLabel}</button>
         <button id="onboardingOpenSkill" class="secondary" type="button">Open SKILL</button>
         <button id="onboardingEditLLM" class="secondary" type="button">Edit LLM Router</button>
         <button id="onboardingOpenLog" class="secondary" type="button">Open Runtime Log</button>
         <button id="onboardingDownloadLog" class="secondary" type="button">Download Log</button>
       </div>`
     : `
       <strong>Connect an LLM to begin</strong>
       <small>Use OpenAI / GPT-5.4 Codex-demo mode for the local demo path, or switch to real providers later. After Save, MoonAP will test the checked models and show the usable order in Details.</small>
       <div class="onboarding-actions">
         <button id="onboardingEditLLM" type="button">Open LLM Router</button>
         <button id="onboardingOpenSkill" class="secondary" type="button">Browse SKILL</button>
         <button id="onboardingOpenLog" class="secondary" type="button">Open Runtime Log</button>
       </div>`;
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__open__runtime__log = () => {
   window.open("/api/logs/moonap-runtime.log", "_blank", "noopener,noreferrer");
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__download__runtime__log = async () => {
   try {
     const response = await fetch("/api/logs/moonap-runtime.log");
     const text = await response.text();
     const blob = new Blob([String(text || "")], { type: "text/plain;charset=utf-8" });
     const url = URL.createObjectURL(blob);
     const link = document.createElement("a");
     link.href = url;
     link.download = "moonap-runtime.log";
     document.body.append(link);
     link.click();
     link.remove();
     setTimeout(() => URL.revokeObjectURL(url), 1000);
   } catch (error) {
     throw new Error(`Runtime log download failed: ${error instanceof Error ? error.message : String(error)}`);
   }
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app39browser__export__last__artifact__bundle = (handler) => document.addEventListener("click", (event) => {
   if (event.target?.id !== "exportSkillBundle") return;
   event.preventDefault();
   event.stopPropagation();
   const artifact = globalThis.__moonapLastArtifact;
   if (!artifact) {
     alert("No generated artifact is ready to export.");
     return;
   }
   const folder = String(artifact?.skill?.folder_name || "personal-fastq-generator");
   const source = String(artifact?.moonbit_source || "");
   const compileReport = globalThis.__moonapLastCompileReport || null;
   const compileOk = compileReport && typeof compileReport === "object" && compileReport.ok === true;
   const compileStatus = compileReport && typeof compileReport === "object"
     ? (compileReport.ok ? "done" : "failed")
     : "pending";
   const skillMd = [
     "# Personal FastQ Generator",
     "",
     "MoonBit source captured by MoonAP from a real LLM response.",
     "",
     "## Current state",
     "- LLM code generation: done",
     `- MoonBit to Wasm compile: ${compileStatus}`,
     "- Browser-local runtime execution: pending",
     "",
     "## Default parameters",
     "- `read_count = 10000`",
     "- `read_length = 150`",
     "- `n_rate = 0.01`",
     "- `random_seed = 42`",
     "",
     "This source bundle was exported from MoonAP for the next implementation step."
   ].join("\\n");
   const manifest = {
     bundle_version: "moonap.source-bundle.v1",
     folder_name: folder,
     exported_at: new Date().toISOString(),
     runtime_ready: false,
     compile_ready: Boolean(compileOk),
     compile_report: compileReport,
     files: [
       { path: "SKILL.md", content: skillMd },
       { path: "moonap.skill.json", content: JSON.stringify(artifact, null, 2) },
       { path: "program/main.mbt", content: source }
     ]
   };
   const blob = new Blob([JSON.stringify(manifest, null, 2)], { type: "application/json;charset=utf-8" });
   const url = URL.createObjectURL(blob);
   const link = document.createElement("a");
   link.href = url;
   link.download = `${folder}.moonap-source-bundle.json`;
   document.body.append(link);
   link.click();
   link.remove();
   setTimeout(() => URL.revokeObjectURL(url), 0);
   try { handler(String(folder)); } catch (error) { console.error("MoonAP export handler failed:", error); }
 });
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app30browser__on__compile__artifact = (handler) => document.addEventListener("click", (event) => {
   if (event.target?.id !== "compileArtifact") return;
   event.preventDefault();
   event.stopPropagation();
   try {
     handler();
   } catch (error) {
     console.error("MoonAP compile probe handler failed:", error);
     alert(`MoonAP compile probe failed: ${error instanceof Error ? error.message : String(error)}`);
   }
 });
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app22browser__on__llm__save = (handler) => document.addEventListener("click", async (event) => {
   if (event.target?.id !== "llmSave") return;
   event.preventDefault();
   event.stopPropagation();
   const routerProfileVersion = 4;
   const parseModelList = (raw) => {
     const seen = new Set();
     const values = String(raw || "")
       .split(/\r?\n|,/)
       .map((item) => String(item || "").trim())
       .filter((item) => item.length > 0);
     return values.filter((item) => {
       const key = item.toLowerCase();
       if (seen.has(key)) return false;
       seen.add(key);
       return true;
     });
   };
   const normalizeProviderEntry = (item) => {
     const key = String(item?.key || "").toLowerCase();
     const model = String(item?.model || "").trim();
     const apiKey = String(item?.apiKey || "").trim();
     const enabled = Boolean(item?.enabled);
     const test_status = String(item?.test_status || "").trim();
     const test_message = String(item?.test_message || "").trim();
     const tested_at = String(item?.tested_at || "").trim();
     let baseUrl = String(item?.baseUrl || "").trim();
     if (key === "gemini") {
       baseUrl = "https://generativelanguage.googleapis.com";
     } else if (key === "openrouter") {
       baseUrl = "https://openrouter.ai/api/v1";
     } else if (key === "zai") {
       baseUrl = "https://open.bigmodel.cn/api/paas/v4";
     } else if (key === "siliconflow") {
       baseUrl = "https://api.siliconflow.cn/v1";
     } else if (key === "openai") {
       baseUrl = "moonap://codex-demo";
     } else if (key === "nvidia") {
       baseUrl = "https://integrate.api.nvidia.com/v1";
     }
     return { key, enabled, model, baseUrl, apiKey, test_status, test_message, tested_at };
   };
   const providerPriority = (provider, model) => {
     const key = String(provider || "").toLowerCase();
     const name = String(model || "").toLowerCase();
     let score = 0;
     if (name.includes("gpt-5.4")) score += 1200;
     else
     if (name.includes("llama-4-maverick-17b-128e-instruct")) score += 1000;
     else if (name.includes("glm-5.1")) score += 900;
     else if (name.includes("gemini-3-flash-preview")) score += 840;
     else if (name.includes("gemini-3.1-flash-lite")) score += 820;
     else if (name.includes("gemini-2.5-flash")) score += 800;
     else if (name.includes("gemini-2.5-flash-lite")) score += 780;
     else if (name.includes("gemini-2-flash-lite")) score += 765;
     else if (name.includes("gemini-2-flash")) score += 760;
     else if (name.includes("glm-5-turbo")) score += 780;
     else if (name === "glm-5" || name.includes("glm-5 ")) score += 770;
     else if (name.includes("glm-4.7")) score += 740;
     else if (name.includes("glm-4-flashx-250414")) score += 735;
     else if (name.includes("glm-4-long")) score += 730;
     else if (name.includes("glm-4.6")) score += 720;
     else if (name.includes("glm-4.5-airx")) score += 700;
     else if (name.includes("glm-4.5-air")) score += 690;
     else if (name.includes("glm-4.7-flashx")) score += 680;
     else if (name.includes("glm-4.7-flash")) score += 670;
     else if (name.includes("qwen2.5-coder-32b-instruct")) score += 620;
     else if (name.includes("llama-4-maverick-17b-128e-instruct")) score += 610;
     else if (name.includes("llama-4-scout-17b-16e-instruct")) score += 600;
     else if (name.includes("llama-3.3-70b-instruct")) score += 590;
     else if (name.includes("qwen2-7b-instruct")) score += 520;
     else if (name.includes("glm-4-9b-chat")) score += 510;
     else if (name.includes("internlm2_5-7b-chat")) score += 500;
     else if (name.includes("mistral-7b-instruct")) score += 490;
     else if (name.includes("chatglm3-6b")) score += 470;
     else if (name.includes("qwen3-coder:free")) score += 300;
     else if (name.includes("nemotron-3-super-120b-a12b:free")) score += 280;
     else if (name.includes("openrouter/free")) score += 200;
     else if (name.includes("openrouter/auto")) score += 180;
     if (key === "openai") score += 120;
     else if (key === "nvidia") score += 90;
     else if (key === "zai") score += 70;
     else if (key === "gemini") score += 40;
     else if (key === "siliconflow") score += 30;
     else if (key === "openrouter") score -= 1000;
     return score;
   };
   const sortMoonBitProviders = (providers) => [...providers].sort((a, b) => providerPriority(b?.key, b?.model) - providerPriority(a?.key, a?.model));
   const collectCheckedModels = (selector) => Array.from(document.querySelectorAll(`${selector} input[type=checkbox]:checked`)).map((node) => String(node.value || "").trim()).filter((value) => value.length > 0);
   const providerSpecs = [
     { key: "openai", enabled: Boolean(document.querySelector("#routerEnableOpenAI")?.checked), models: collectCheckedModels("#routerModelsOpenAI"), baseUrl: String(document.querySelector("#routerBaseOpenAI")?.value || "").trim(), apiKey: String(document.querySelector("#routerKeyOpenAI")?.value || "").trim() },
     { key: "nvidia", enabled: Boolean(document.querySelector("#routerEnableNVIDIA")?.checked), models: collectCheckedModels("#routerModelsNVIDIA"), baseUrl: String(document.querySelector("#routerBaseNVIDIA")?.value || "").trim(), apiKey: String(document.querySelector("#routerKeyNVIDIA")?.value || "").trim() },
     { key: "zai", enabled: Boolean(document.querySelector("#routerEnableZAI")?.checked), models: collectCheckedModels("#routerModelsZAI"), baseUrl: String(document.querySelector("#routerBaseZAI")?.value || "").trim(), apiKey: String(document.querySelector("#routerKeyZAI")?.value || "").trim() },
     { key: "gemini", enabled: Boolean(document.querySelector("#routerEnableGemini")?.checked), models: collectCheckedModels("#routerModelsGemini"), baseUrl: String(document.querySelector("#routerBaseGemini")?.value || "").trim(), apiKey: String(document.querySelector("#routerKeyGemini")?.value || "").trim() },
     { key: "siliconflow", enabled: Boolean(document.querySelector("#routerEnableSiliconFlow")?.checked), models: collectCheckedModels("#routerModelsSiliconFlow"), baseUrl: String(document.querySelector("#routerBaseSiliconFlow")?.value || "").trim(), apiKey: String(document.querySelector("#routerKeySiliconFlow")?.value || "").trim() },
     { key: "openrouter", enabled: Boolean(document.querySelector("#routerEnableOpenRouter")?.checked), models: collectCheckedModels("#routerModelsOpenRouter"), baseUrl: String(document.querySelector("#routerBaseOpenRouter")?.value || "").trim(), apiKey: String(document.querySelector("#routerKeyOpenRouter")?.value || "").trim() }
   ];
   const providers = providerSpecs.flatMap((item) => item.models.map((model) => ({
     key: item.key,
     enabled: Boolean(item.enabled),
     model,
     baseUrl: item.baseUrl,
     apiKey: item.apiKey
   })));
   const sortedProviders = sortMoonBitProviders(providers.map(normalizeProviderEntry));
   const active = sortedProviders.filter((item) => item.enabled && item.apiKey);
   if (active.length === 0) {
     alert("Please enable at least one provider, check at least one model under it, and fill its API key.");
     return;
   }
   const statusNode = document.querySelector("#routerTestStatus");
   const saveButton = document.querySelector("#llmSave");
   const dialog = document.querySelector("#llmDialog");
   const setStatus = (text) => {
     if (statusNode) statusNode.textContent = String(text || "");
   };
   const openDetails = () => {
     const root = document.querySelector(".app-shell");
     const button = document.querySelector("#detailsToggle");
     if (!root || !button) return;
     root.classList.add("details-open");
     button.setAttribute("aria-expanded", "true");
   };
   const updateProcess = (provider, stage, result, logText) => {
     const setText = (selector, value) => {
       const node = document.querySelector(selector);
       if (node) node.textContent = String(value);
     };
     setText("#processProvider", provider || "-");
     setText("#processStage", stage || "-");
     setText("#processResult", result || "waiting");
     setText("#processLog", logText || "");
   };
   const proxyPost = async (url, headers, body) => {
     const envelope = [
       `URL\t${String(url)}`,
       ...Object.entries(headers || {}).map(([key, value]) => `HEADER\t${String(key)}\t${String(value).replace(/\r?\n/g, " ")}`),
       "BODY",
       String(body)
     ].join("\n");
     const controller = new AbortController();
     const timeout = setTimeout(() => controller.abort(), 8000);
     try {
       const response = await fetch("/api/llm/proxy", {
         method: "POST",
         headers: { "Content-Type": "text/plain; charset=utf-8" },
         body: envelope,
         signal: controller.signal
       });
       const text = await response.text();
       let json = {};
       try {
         json = JSON.parse(text);
       } catch {
         const plain = String(text || "").replace(/<script[\s\S]*?<\/script>/gi, " ").replace(/<style[\s\S]*?<\/style>/gi, " ").replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
         throw new Error(`Provider returned non-JSON (${response.status}): ${(plain || text || "").slice(0, 180)}`);
       }
       if (!response.ok) {
         const detail = json?.error?.detail ? ` ${String(json.error.detail)}` : "";
         throw new Error((json?.error?.message || `LLM request failed (${response.status})`) + detail);
       }
       return json;
     } catch (error) {
       if (error && error.name === "AbortError") {
         throw new Error("Timed out after 8s");
       }
       throw error;
     } finally {
       clearTimeout(timeout);
     }
   };
   const testProvider = async (llm) => {
     if (llm.key === "gemini") {
       const url = `${llm.baseUrl}/v1beta/models/${encodeURIComponent(llm.model)}:generateContent`;
       const json = await proxyPost(url, {
         "Content-Type": "application/json",
         "x-goog-api-key": String(llm.apiKey || "")
       }, JSON.stringify({
         contents: [{ role: "user", parts: [{ text: "Reply with OK." }] }],
         generationConfig: { temperature: 0, maxOutputTokens: 8 }
       }));
       const text = (json?.candidates?.[0]?.content?.parts || []).map((part) => String(part?.text || "")).join(" ").trim();
       return text || "OK";
     }
     let urlBase = String(llm.baseUrl || "").trim();
     urlBase = urlBase.endsWith("/") ? urlBase.slice(0, -1) : urlBase;
     let url = `${urlBase}/chat/completions`;
     if (llm.key === "zai") {
       if (urlBase.endsWith("/chat/completions")) {
         url = urlBase;
       } else if (!urlBase.includes("/api/paas/v4")) {
         url = `${urlBase}/api/paas/v4/chat/completions`;
       }
     }
     const headers = {
       "Content-Type": "application/json",
       "Authorization": `Bearer ${String(llm.apiKey || "")}`
     };
     if (llm.key === "openrouter") {
       headers["HTTP-Referer"] = "http://127.0.0.1:3000";
       headers["X-Title"] = "MoonAP";
     }
     const json = await proxyPost(url, headers, JSON.stringify({
       model: llm.model,
       messages: [{ role: "user", content: "Reply with OK." }],
       temperature: 0,
       max_tokens: 8
     }));
     const text = String(json?.choices?.[0]?.message?.content || "").trim();
     return text || "OK";
   };
   localStorage.setItem("moonap.formalVerification", String(Boolean(document.querySelector("#routerFormalVerification")?.checked)));
   localStorage.setItem("moonap.repairFeedbackMode", Boolean(document.querySelector("#routerRepairUseRawCompilerOutput")?.checked) ? "raw" : "summary");
   const enabled = localStorage.getItem("moonap.formalVerification") === "true";
   const mainToggle = document.querySelector("#formalVerification");
   if (mainToggle) mainToggle.checked = enabled;
   if (saveButton) {
     saveButton.disabled = true;
     saveButton.textContent = "Saving...";
   }
   setStatus("Saving router config and testing enabled LLM APIs...");
   openDetails();
   dialog?.close();
   updateProcess(
     "LLM Router",
     "llm-api-test",
     "running",
     "Saving router config and testing enabled LLM APIs..."
   );
   try {
     const lines = [];
     const results = [];
     for (const item of active) {
       const label = `${item.key}/${item.model}`;
       lines.push(`[running] ${label}`);
       setStatus(lines.join("\n"));
       updateProcess("LLM Router", "llm-api-test", "running", lines.join("\n"));
       try {
         const result = await testProvider(item);
         lines[lines.length - 1] = `[ok] ${label} -> ${String(result).slice(0, 80)}`;
         results.push({ key: item.key, model: item.model, ok: true, message: String(result || "OK") });
       } catch (error) {
         const message = error instanceof Error ? error.message : String(error);
         lines[lines.length - 1] = `[failed] ${label} -> ${message}`;
         results.push({ key: item.key, model: item.model, ok: false, message });
       }
       setStatus(lines.join("\n"));
       updateProcess("LLM Router", "llm-api-test", "running", lines.join("\n"));
     }
     const testedAt = new Date().toISOString();
     const providersWithHealth = sortedProviders.map((item) => {
       const match = results.find((result) => result.key === item.key && result.model === item.model);
       if (!item.enabled || !item.apiKey || !item.model) {
         return { ...item, test_status: "skipped", test_message: "Disabled or incomplete.", tested_at: testedAt };
       }
       if (!match) {
         return { ...item, test_status: "failed", test_message: "No test result captured.", tested_at: testedAt };
       }
       return { ...item, test_status: match.ok ? "ok" : "failed", test_message: match.message, tested_at: testedAt };
     });
     const usable = providersWithHealth.filter((item) => item.enabled && item.apiKey && item.test_status === "ok");
     const orderLines = usable.length === 0
       ? ["No enabled provider passed the API test."]
       : usable.map((item, index) => `${index + 1}. ${item.key}/${item.model}`);
     const summary = lines.join("\n") + "\n\nFinal usable provider order:\n" + orderLines.join("\n");
     localStorage.setItem("moonap.llm.router.v1", JSON.stringify({
       providers: providersWithHealth,
       cursor: 0,
       savedAt: testedAt,
       last_test_summary: summary,
       profile_version: routerProfileVersion
     }));
     setStatus(summary);
     updateProcess(
       usable.length === 0 ? "LLM Router" : usable.map((item) => `${item.key}/${item.model}`).join(", "),
       "llm-api-test",
       usable.length === 0 ? "failed" : "succeeded",
       summary
     );
     handler();
   } catch (error) {
     console.error("MoonAP llm save handler failed:", error);
     const message = error instanceof Error ? error.message : String(error);
     setStatus(message);
     updateProcess("LLM Router", "llm-api-test", "failed", message);
     alert(`MoonAP LLM save failed: ${message}`);
   } finally {
     if (saveButton) {
       saveButton.disabled = false;
       saveButton.textContent = "Save";
     }
   }
 });
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__on__llm__cancel = (handler) => document.addEventListener("click", (event) => {
   if (event.target?.id !== "llmCancel") return;
   event.preventDefault();
   document.querySelector("#llmDialog")?.close();
   try {
     handler();
   } catch (error) {
     console.error("MoonAP llm cancel handler failed:", error);
   }
 });
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app36browser__generate__moonbit__artifact = async (taskTitle, prompt, simpleMode, formalVerification, knowledgePack, onDone, onError) => {
   try {
     const readRouter = () => {
       try {
         const parsed = JSON.parse(localStorage.getItem("moonap.llm.router.v1") || "{}");
         return parsed && typeof parsed === "object" ? parsed : {};
       } catch (error) {
         console.warn("MoonAP reset invalid LLM router storage:", error);
         try { localStorage.removeItem("moonap.llm.router.v1"); } catch {}
         return {};
       }
     };
     const saved = readRouter();
     const providers = Array.isArray(saved.providers) ? saved.providers.filter((item) => item.enabled && String(item.apiKey || "").trim() !== "" && String(item.test_status || "") !== "failed") : [];
     if (providers.length === 0) {
       throw new Error("No enabled LLM provider is available in the router.");
     }
     const cursor = Number.isFinite(saved.cursor) ? saved.cursor : 0;
     const start = ((cursor % providers.length) + providers.length) % providers.length;
     const ordered = providers.slice(start).concat(providers.slice(0, start));
     const lowerTaskTitle = String(taskTitle || "").toLowerCase();
     const lowerPrompt = String(prompt || "").toLowerCase();
     const isFastqTask = (lowerTaskTitle.includes("fastq") || lowerPrompt.includes("fastq")) && lowerPrompt.includes("moonbit");
     const systemPrompt = (simpleMode || isFastqTask)
       ? [
           "You write MoonBit code.",
           "Return ONLY cmd/main/main.mbt.",
           "No markdown fences.",
           "No explanations.",
           "Use valid MoonBit syntax only."
         ].join("\\n")
       : [
           "You are generating MoonBit code for MoonAP.",
           "Target language: MoonBit 0.9.",
           "Output contract:",
           "- Return ONLY the contents of cmd/main/main.mbt.",
           "- Do NOT return markdown fences.",
           "- Do NOT return explanations.",
           "- Do NOT return moon.pkg or moon.mod.json.",
           "- Use valid MoonBit syntax only.",
           "- The MoonBit primer in the user prompt overrides stale prior memory."
         ].join("\\n");
     const userPrompt = isFastqTask
       ? [
           `MoonAP task title: ${String(taskTitle || "MoonBit task")}`,
           "",
           String(prompt),
           "",
           "FastQ-specific constraints:",
           "- main must return the generated FastQ String.",
           "- Use MoonBit basics only; avoid imports and unknown library APIs.",
           "- Do not use var, mut, Rust imports, or type suffixes.",
           "- Prefer small pure helper functions over imperative loops if unsure.",
           "",
           "Again: return ONLY cmd/main/main.mbt source."
         ].join("\\n")
       : [
           "Read this MoonBit 0.9 primer first and follow it strictly:",
           String(knowledgePack || ""),
           "",
           `MoonAP task title: ${String(taskTitle || "MoonBit task")}`,
           "",
           String(prompt),
           "",
           "Again: return ONLY cmd/main/main.mbt source."
         ].join("\\n");
     const updatePrompts = (modeText, systemPromptText, userPromptText) => {
       const setText = (selector, value) => {
         const node = document.querySelector(selector);
         if (node) node.textContent = String(value);
       };
       setText("#promptMode", modeText || "No LLM prompt captured yet.");
       setText("#promptSystem", systemPromptText || "No LLM prompt captured yet.");
       setText("#promptUser", userPromptText || "No LLM prompt captured yet.");
     };
     updatePrompts(isFastqTask ? "codegen / minimal-fastq" : (simpleMode ? "codegen / simple" : "codegen / full"), systemPrompt, userPrompt);
     const proxyPost = async (url, headers, body) => {
       const envelope = [
         `URL\t${String(url)}`,
         ...Object.entries(headers || {}).map(([key, value]) => `HEADER\t${String(key)}\t${String(value).replace(/\r?\n/g, " ")}`),
         "BODY",
         String(body)
       ].join("\n");
       const response = await fetch("/api/llm/proxy", {
         method: "POST",
         headers: { "Content-Type": "text/plain; charset=utf-8" },
         body: envelope
       });
       const text = await response.text();
       let json = {};
       try {
         json = JSON.parse(text);
       } catch {
         const plain = String(text || "")
           .replace(/<script[\s\S]*?<\/script>/gi, " ")
           .replace(/<style[\s\S]*?<\/style>/gi, " ")
           .replace(/<[^>]+>/g, " ")
           .replace(/\s+/g, " ")
           .trim();
         const summarized = plain || `MoonAP proxy returned non-JSON (${response.status})`;
         throw new Error(`Provider returned non-JSON (${response.status}): ${summarized.slice(0, 240)}`);
       }
       if (!response.ok) {
         const detail = json?.error?.detail ? ` ${String(json.error.detail)}` : "";
         throw new Error((json?.error?.message || `LLM request failed (${response.status})`) + detail);
       }
       return json;
     };
     const requestJson = async (llm) => {
       if (llm.provider === "gemini") {
         const url = `${llm.baseUrl}/v1beta/models/${encodeURIComponent(llm.model)}:generateContent`;
         const json = await proxyPost(
           url,
           { "Content-Type": "application/json", "x-goog-api-key": String(llm.apiKey || "") },
           JSON.stringify({
             system_instruction: { parts: [{ text: systemPrompt }] },
             contents: [{ role: "user", parts: [{ text: userPrompt }] }],
             generationConfig: { temperature: 0.2 }
           })
         );
         const text = (json?.candidates?.[0]?.content?.parts || []).map((part) => String(part?.text || "")).join("\\n").trim();
         if (!text) throw new Error("Gemini returned no MoonBit source.");
         return { source: text, raw: json };
       }
       const rawBaseUrl = String(llm.baseUrl || "").trim();
       const baseUrl = rawBaseUrl.endsWith("/") ? rawBaseUrl.slice(0, -1) : rawBaseUrl;
       let url = `${baseUrl}/chat/completions`;
       if (llm.provider === "zai") {
         if (baseUrl.endsWith("/chat/completions")) {
           url = baseUrl;
         } else if (baseUrl === "https://open.bigmodel.cn" || baseUrl === "https://open.bigmodel.cn/") {
           url = "https://open.bigmodel.cn/api/paas/v4/chat/completions";
         } else if (!baseUrl.includes("/api/paas/v4")) {
           url = `${baseUrl}/api/paas/v4/chat/completions`;
         }
       }
       const headers = {
         "Content-Type": "application/json",
         "Authorization": `Bearer ${String(llm.apiKey || "")}`
       };
       if (llm.provider === "openrouter") {
         headers["HTTP-Referer"] = "http://127.0.0.1:3000";
         headers["X-Title"] = "MoonAP";
       }
       const json = await proxyPost(
         url,
         headers,
         JSON.stringify({
           model: llm.model,
           messages: [
             { role: "system", content: systemPrompt },
             { role: "user", content: userPrompt }
           ],
           temperature: 0.2
         })
       );
       const text = String(json?.choices?.[0]?.message?.content || "").trim();
       if (!text) throw new Error(`${llm.provider} returned no MoonBit source.`);
       return { source: text, raw: json };
     };
     let generated = null;
     let llm = null;
     const failures = [];
     for (let index = 0; index < ordered.length; index += 1) {
       const item = ordered[index];
       const candidate = {
         provider: item.key,
         model: item.model,
         baseUrl: item.baseUrl,
         apiKey: item.apiKey,
         rotated: providers.length > 1
       };
       try {
         generated = await requestJson(candidate);
         llm = candidate;
         const nextCursor = (start + index + 1) % providers.length;
         localStorage.setItem("moonap.llm.router.v1", JSON.stringify({
           providers: Array.isArray(saved.providers) ? saved.providers : providers,
           cursor: nextCursor,
           savedAt: saved.savedAt || new Date().toISOString()
         }));
         break;
       } catch (error) {
         failures.push(`${String(item.key || "provider")}/${String(item.model || "model")}: ${error instanceof Error ? error.message : String(error)}`);
       }
     }
     if (!generated || !llm) {
       throw new Error(`All enabled providers failed during code generation. ${failures.join(" | ")}`);
     }
     const ensureExtractMoonBitSource = () => {
       if (typeof globalThis.__moonapExtractMoonBitSource === "function") return globalThis.__moonapExtractMoonBitSource;
       globalThis.__moonapExtractMoonBitSource = (value) => {
         const text = String(value || "").trim();
         if (!text) return "";
         const extract = (source, startMarker, endMarker) => {
           const start = source.indexOf(startMarker);
           if (start < 0) return "";
           const after = source.slice(start + startMarker.length).trim();
           if (!after) return "";
           const end = after.indexOf(endMarker);
           if (end < 0) return "";
           return after.slice(0, end).trim();
         };
         const patterns = [
           ["FILE: cmd/main/main.mbt", "END_FILE"],
           ['<moonbit-file path="cmd/main/main.mbt">', "</moonbit-file>"],
           ["```moonbit", "```"],
           ["```mbt", "```"],
           ["```", "```"]
         ];
         for (const [startMarker, endMarker] of patterns) {
           const extracted = extract(text, startMarker, endMarker);
           if (extracted) return extracted;
         }
         return text;
       };
       return globalThis.__moonapExtractMoonBitSource;
     };
     const source = ensureExtractMoonBitSource()(String(generated.source || ""));
     const slug = String(taskTitle || "moonbit-task")
       .toLowerCase()
       .replace(/[^a-z0-9]+/g, "-")
       .replace(/^-+|-+$/g, "") || "moonbit-task";
     const artifact = {
       schema_version: "moonap.artifact.v1",
       id: slug,
       name: String(taskTitle || "MoonBit Task"),
       prompt: String(prompt),
       llm_provider: llm.provider || "unknown",
       llm_model: llm.model || "unknown",
       llm_rotated: Boolean(llm.rotated),
       stages: [
         { name: "llm-codegen", status: "ok", output: `MoonBit source generated by ${llm.provider}/${llm.model}` },
         { name: "formal-verification", status: formalVerification ? "reserved" : "skipped", output: formalVerification ? "moon prove hook reserved" : "disabled by user/default" },
         { name: "moonbit-wasm-compile", status: "pending", output: "Real MoonBit-to-Wasm compile is the next implementation step." },
         { name: "browser-local-run", status: "pending", output: "Browser-local execution will start after compile is wired." }
       ],
       skill: {
         folder_name: slug,
         description_file: "SKILL.md",
         program_dir: "program",
         parameters: {}
       },
       moonbit_source: source,
       knowledge_pack_version: "moonbit-primer-v1",
       llm_response_preview: JSON.stringify(generated.raw).slice(0, 1200),
       wasm_runtime: {
         target: "wasm-gc",
         browser_local: true,
         uploaded_bytes: 0,
         note: "Pending real compile and runtime execution."
       },
       created_at: new Date().toISOString()
     };
     globalThis.__moonapLastArtifact = artifact;
     onDone(JSON.stringify(artifact, null, 2));
   } catch (error) {
     onError(error instanceof Error ? error.message : String(error));
   }
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app38browser__run__free__llm__moonbit__eval = async (maxLevel, onDone, onError) => {
   try {
     if (globalThis.__moonapEvalRunning) {
       throw new Error("A MoonBit experiment run is already in progress.");
     }
     globalThis.__moonapEvalRunning = true;
     const clampLevel = (value) => Math.max(1, Math.min(3, Number(value || 3)));
     const nowIso = () => new Date().toISOString();
     const ensureExtractMoonBitSource = () => {
       if (typeof globalThis.__moonapExtractMoonBitSource === "function") return globalThis.__moonapExtractMoonBitSource;
       globalThis.__moonapExtractMoonBitSource = (value) => {
         const sourceText = String(value || "").trim();
         if (!sourceText) return "";
         const extract = (source, startMarker, endMarker) => {
           const start = source.indexOf(startMarker);
           if (start < 0) return "";
           const after = source.slice(start + startMarker.length).trim();
           if (!after) return "";
           const end = after.indexOf(endMarker);
           if (end < 0) return "";
           return after.slice(0, end).trim();
         };
         const patterns = [
           ["FILE: cmd/main/main.mbt", "END_FILE"],
           ['<moonbit-file path="cmd/main/main.mbt">', "</moonbit-file>"],
           ["```moonbit", "```"],
           ["```mbt", "```"],
           ["```", "```"]
         ];
         for (const [startMarker, endMarker] of patterns) {
           const extracted = extract(sourceText, startMarker, endMarker);
           if (extracted) return extracted;
         }
         return sourceText;
       };
       return globalThis.__moonapExtractMoonBitSource;
     };
     const cleanSource = (text) => ensureExtractMoonBitSource()(String(text || ""));
     const parseModelList = (raw) => {
       const seen = new Set();
       return String(raw || "")
         .split(/\r?\n|,/)
         .map((item) => String(item || "").trim())
         .filter((item) => item.length > 0)
         .filter((item) => {
           const key = item.toLowerCase();
           if (seen.has(key)) return false;
           seen.add(key);
           return true;
         });
     };
     const normalizeProviderEntry = (item) => {
       const key = String(item?.key || "").toLowerCase();
       let baseUrl = String(item?.baseUrl || "").trim();
       if (key === "gemini") baseUrl = "https://generativelanguage.googleapis.com";
       else if (key === "openrouter") baseUrl = "https://openrouter.ai/api/v1";
       else if (key === "zai") baseUrl = "https://open.bigmodel.cn/api/paas/v4";
       else if (key === "siliconflow") baseUrl = "https://api.siliconflow.cn/v1";
       else if (key === "openai") baseUrl = "moonap://codex-demo";
       else if (key === "nvidia") baseUrl = "https://integrate.api.nvidia.com/v1";
       return {
         key,
         provider: key,
         enabled: Boolean(item?.enabled),
         model: String(item?.model || "").trim(),
         baseUrl,
         apiKey: String(item?.apiKey || "").trim()
       };
     };
     const readRouter = () => {
       try {
         const parsed = JSON.parse(localStorage.getItem("moonap.llm.router.v1") || "{}");
         return parsed && typeof parsed === "object" ? parsed : {};
       } catch {
         return {};
       }
     };
     const updatePrompts = (modeText, systemPromptText, userPromptText) => {
       const setText = (selector, value) => {
         const node = document.querySelector(selector);
         if (node) node.textContent = String(value || "");
       };
       setText("#promptMode", modeText || "No LLM prompt captured yet.");
       setText("#promptSystem", systemPromptText || "No LLM prompt captured yet.");
       setText("#promptUser", userPromptText || "No LLM prompt captured yet.");
     };
     const updateProcess = (provider, stage, result, logText, sourceText = "") => {
       const setText = (selector, value) => {
         const node = document.querySelector(selector);
         if (node) node.textContent = String(value || "");
       };
       setText("#processProvider", provider || "-");
       setText("#processStage", stage || "-");
       setText("#processResult", result || "waiting");
       setText("#processLog", logText || "");
       if (sourceText !== "") setText("#processSource", sourceText || "No generated source yet.");
     };
     const proxyPost = async (url, headers, body, timeoutMs) => {
       const envelope = [
         `URL\t${String(url)}`,
         ...Object.entries(headers || {}).map(([key, value]) => `HEADER\t${String(key)}\t${String(value).replace(/\r?\n/g, " ")}`),
         "BODY",
         String(body)
       ].join("\n");
       const controller = new AbortController();
       const timeout = setTimeout(() => controller.abort(), timeoutMs);
       const started = performance.now();
       try {
         const response = await fetch("/api/llm/proxy", {
           method: "POST",
           headers: { "Content-Type": "text/plain; charset=utf-8" },
           body: envelope,
           signal: controller.signal
         });
         const text = await response.text();
         let json = {};
         try {
           json = JSON.parse(text);
         } catch {
           const plain = String(text || "").replace(/<script[\s\S]*?<\/script>/gi, " ").replace(/<style[\s\S]*?<\/style>/gi, " ").replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
           const err = new Error(`Provider returned non-JSON (${response.status}): ${(plain || text || "").slice(0, 240)}`);
           err.nonJson = true;
           err.httpStatus = response.status;
           throw err;
         }
         if (!response.ok) {
           const detail = json?.error?.detail ? ` ${String(json.error.detail)}` : "";
           const err = new Error((json?.error?.message || `LLM request failed (${response.status})`) + detail);
           err.httpStatus = response.status;
           throw err;
         }
         return { json, latencyMs: Math.round(performance.now() - started) };
       } catch (error) {
         if (error && error.name === "AbortError") {
           const timeoutError = new Error(`Timed out after ${Math.round(timeoutMs / 1000)}s`);
           timeoutError.timeout = true;
           throw timeoutError;
         }
         throw error;
       } finally {
         clearTimeout(timeout);
       }
     };
     const compileSource = async (sourceText) => {
       const response = await fetch("/api/artifact/compile", {
         method: "POST",
         headers: { "Content-Type": "text/plain; charset=utf-8" },
         body: String(sourceText || "")
       });
       const text = await response.text();
       return JSON.parse(text);
     };
     const buildMarkdown = (results) => {
       const models = Array.isArray(results?.models) ? results.models : [];
       const formatCell = (benchmark) => {
         if (!benchmark?.attempted) return "not-run";
         if (benchmark?.raw_codegen_pass) return "raw-pass";
         if (benchmark?.assisted_pass) return `assist-pass (${Number(benchmark?.repair_attempts_used || 0)} repairs)`;
         return "fail";
       };
       return [
         "# Free LLM models ability of generating MoonBit code",
         "",
         `Last updated: ${nowIso()}`,
         "",
         "## Current summary",
         "",
         "| Provider | Model | API | API ms | L1 | L2 | L3 | Notes |",
         "| --- | --- | --- | ---: | --- | --- | --- | --- |",
         ...models.map((item) => {
           const note = item?.notes?.final_recommendation_note || item?.api_test?.message || "";
           return `| ${String(item?.provider || "")} | ${String(item?.model || "")} | ${String(item?.api_test?.status || "")} | ${String(item?.api_test?.latency_ms ?? "")} | ${formatCell(item?.benchmarks?.L1)} | ${formatCell(item?.benchmarks?.L2)} | ${formatCell(item?.benchmarks?.L3)} | ${String(note).replace(/\|/g, "/")} |`;
         }),
         "",
         "## Raw JSON",
         "",
         "See `artifacts/moonbit-eval-results.json` for the full structured record."
       ].join("\n");
     };
     const persistResults = async (results) => {
       await fetch("/api/experiments/free-llm-moonbit/results.json", {
         method: "POST",
         headers: { "Content-Type": "application/json; charset=utf-8" },
         body: JSON.stringify(results, null, 2)
       });
       await fetch("/api/experiments/free-llm-moonbit/results.md", {
         method: "POST",
         headers: { "Content-Type": "text/markdown; charset=utf-8" },
         body: buildMarkdown(results)
       });
     };
     const requestMoonBit = async (llm, systemPrompt, userPrompt, timeoutMs, maxTokens = 512, mode = "eval / raw-codegen") => {
       updatePrompts(mode, systemPrompt, userPrompt);
       if (llm.provider === "gemini") {
         const url = `${llm.baseUrl}/v1beta/models/${encodeURIComponent(llm.model)}:generateContent`;
         const { json, latencyMs } = await proxyPost(url, {
           "Content-Type": "application/json",
           "x-goog-api-key": String(llm.apiKey || "")
         }, JSON.stringify({
           system_instruction: { parts: [{ text: systemPrompt }] },
           contents: [{ role: "user", parts: [{ text: userPrompt }] }],
           generationConfig: { temperature: 0, maxOutputTokens: maxTokens }
         }), timeoutMs);
         const text = (json?.candidates?.[0]?.content?.parts || []).map((part) => String(part?.text || "")).join("\n").trim();
         return { source: cleanSource(text), latencyMs };
       }
       const rawBaseUrl = String(llm.baseUrl || "").trim();
       const baseUrl = rawBaseUrl.endsWith("/") ? rawBaseUrl.slice(0, -1) : rawBaseUrl;
       let url = `${baseUrl}/chat/completions`;
       if (llm.provider === "zai" && !baseUrl.endsWith("/chat/completions") && !baseUrl.includes("/api/paas/v4")) {
         url = `${baseUrl}/api/paas/v4/chat/completions`;
       }
       const headers = {
         "Content-Type": "application/json",
         "Authorization": `Bearer ${String(llm.apiKey || "")}`
       };
       if (llm.provider === "openrouter") {
         headers["HTTP-Referer"] = "http://127.0.0.1:3000";
         headers["X-Title"] = "MoonAP";
       }
       const { json, latencyMs } = await proxyPost(url, headers, JSON.stringify({
         model: llm.model,
         messages: [
           { role: "system", content: systemPrompt },
           { role: "user", content: userPrompt }
         ],
         temperature: 0,
         max_tokens: maxTokens
       }), timeoutMs);
       return { source: cleanSource(String(json?.choices?.[0]?.message?.content || "")), latencyMs };
     };
     const benchmarks = [
       {
         id: "L1",
         title: "Smallest valid MoonBit program",
         userPrompt: "Write cmd/main/main.mbt only. main must return the string \"hello moonbit\". No imports. No helper functions."
       },
       {
         id: "L2",
         title: "One helper plus main",
         userPrompt: "Write cmd/main/main.mbt only. Define exactly one helper that returns \"hello moonbit\". main must call the helper and return its result. No imports."
       },
       {
         id: "L3",
         title: "Simple control flow",
         userPrompt: "Write cmd/main/main.mbt only. main must return exactly \"ABC\" using compact deterministic control flow. No imports. No randomness."
       }
     ].slice(0, clampLevel(maxLevel));
     const codegenSystemPrompt = [
       "You write MoonBit code.",
       "Return only cmd/main/main.mbt.",
       "No markdown fences.",
       "No explanations."
     ].join("\n");
     const repairSystemPrompt = [
       "You repair MoonBit code.",
       "Return only cmd/main/main.mbt.",
       "No markdown fences.",
       "No explanations."
     ].join("\n");
     const saved = readRouter();
     const providers = (Array.isArray(saved.providers) ? saved.providers : [])
       .map(normalizeProviderEntry)
       .filter((item) => item.enabled && item.apiKey && item.model);
     if (providers.length === 0) {
       throw new Error("No enabled provider/model with API key is available for the experiment run.");
     }
     const blankBenchmark = () => ({
       attempted: false,
       raw_codegen_pass: false,
       raw_codegen_compile_exit_code: null,
       raw_codegen_compile_summary_kind: "",
       repair_attempts_used: 0,
       assisted_pass: false,
       final_compile_exit_code: null,
       final_compile_summary_kind: "",
       final_source_bytes: null,
       first_codegen_response_latency_ms: null,
       total_time_to_first_compile_success_ms: null
     });
     const results = {
       experiment_name: "Free LLM models ability of generating MoonBit code",
       status: "running",
       generated_at: nowIso(),
       prompt_protocol: {
         system_prompt: codegenSystemPrompt,
         user_prompt_mode: "task-only"
       },
       benchmarks: benchmarks.map((item) => ({ id: item.id, title: item.title, goal: item.userPrompt })),
       models: []
     };
     const routerSummary = `${providers.length} provider(s): ${providers.map((item) => `${item.key}/${item.model}`).join(", ")}`;
     updateProcess(routerSummary, "moonbit-eval", "running", `Starting Free LLM MoonBit Eval across ${providers.length} enabled provider/model entries.`);
     for (const provider of providers) {
       const providerLabel = `${provider.key}/${provider.model}`;
       const modelRecord = {
         provider: provider.key,
         model: provider.model,
         base_url: provider.baseUrl,
         api_test: {
           status: "pending",
           message: "",
           latency_ms: null,
           http_status: null,
           timeout: false,
           non_json_response: false
         },
         benchmarks: { L1: blankBenchmark(), L2: blankBenchmark(), L3: blankBenchmark() },
         notes: {
           stalled_or_long_no_response: false,
           parser_drift_notes: "",
           language_drift_notes: "",
           final_recommendation_note: ""
         }
       };
       results.models.push(modelRecord);
       await persistResults(results);
       updateProcess(providerLabel, "llm-api-test", "running", `Testing API reachability for ${providerLabel}.`);
       try {
         const ping = await requestMoonBit(provider, "Reply with OK.", "Reply with OK.", 8000, 8, "eval / api-test");
         modelRecord.api_test.status = "ok";
         modelRecord.api_test.message = ping.source || "OK";
         modelRecord.api_test.latency_ms = ping.latencyMs;
       } catch (error) {
         modelRecord.api_test.status = "failed";
         modelRecord.api_test.message = error instanceof Error ? error.message : String(error);
         modelRecord.api_test.timeout = Boolean(error?.timeout);
         modelRecord.api_test.non_json_response = Boolean(error?.nonJson);
         modelRecord.api_test.http_status = Number.isFinite(error?.httpStatus) ? Number(error.httpStatus) : null;
         modelRecord.notes.stalled_or_long_no_response = modelRecord.api_test.timeout;
         await persistResults(results);
         updateProcess(providerLabel, "llm-api-test", "failed", modelRecord.api_test.message);
         continue;
       }
       await persistResults(results);
       for (const benchmark of benchmarks) {
         const bench = modelRecord.benchmarks[benchmark.id];
         const benchStart = performance.now();
         bench.attempted = true;
         updateProcess(providerLabel, `moonbit-eval-${benchmark.id.toLowerCase()}`, "running", `Running ${benchmark.id} for ${providerLabel}.`);
         try {
           const generated = await requestMoonBit(provider, codegenSystemPrompt, benchmark.userPrompt, 30000, 512, "eval / raw-codegen");
           bench.first_codegen_response_latency_ms = generated.latencyMs;
           updateProcess(providerLabel, `moonbit-eval-${benchmark.id.toLowerCase()}`, "running", `Compiling raw output for ${benchmark.id}.`, generated.source);
           let compile = await compileSource(generated.source);
           bench.raw_codegen_compile_exit_code = Number.isFinite(compile?.exit_code) ? Number(compile.exit_code) : null;
           bench.raw_codegen_compile_summary_kind = String(compile?.summary_kind || "");
           bench.final_compile_exit_code = Number.isFinite(compile?.exit_code) ? Number(compile.exit_code) : null;
           bench.final_compile_summary_kind = String(compile?.summary_kind || "");
           bench.final_source_bytes = Number.isFinite(compile?.source_bytes) ? Number(compile.source_bytes) : generated.source.length;
           if (compile?.ok === true) {
             bench.raw_codegen_pass = true;
             bench.assisted_pass = true;
             bench.total_time_to_first_compile_success_ms = Math.round(performance.now() - benchStart);
             await persistResults(results);
             continue;
           }
           let repairedSource = generated.source;
           for (let repairRound = 1; repairRound <= 2; repairRound += 1) {
             bench.repair_attempts_used = repairRound;
             const repairUserPrompt = [
               `Benchmark task: ${benchmark.userPrompt}`,
               "",
               "Current source:",
               repairedSource,
               "",
               "Compiler output:",
               String(compile?.output || compile?.trimmed_output || ""),
               "",
               "Repair the file so it compiles. Return only cmd/main/main.mbt."
             ].join("\n");
             const repaired = await requestMoonBit(provider, repairSystemPrompt, repairUserPrompt, 30000, 512, "eval / repair");
             repairedSource = repaired.source;
             updateProcess(providerLabel, `moonbit-eval-${benchmark.id.toLowerCase()}`, "running", `Compile-checking repair round ${repairRound} for ${benchmark.id}.`, repairedSource);
             compile = await compileSource(repairedSource);
             bench.final_compile_exit_code = Number.isFinite(compile?.exit_code) ? Number(compile.exit_code) : null;
             bench.final_compile_summary_kind = String(compile?.summary_kind || "");
             bench.final_source_bytes = Number.isFinite(compile?.source_bytes) ? Number(compile.source_bytes) : repairedSource.length;
             if (compile?.ok === true) {
               bench.assisted_pass = true;
               bench.total_time_to_first_compile_success_ms = Math.round(performance.now() - benchStart);
               break;
             }
           }
           if (!bench.assisted_pass && String(bench.final_compile_summary_kind || "").includes("parse")) {
             modelRecord.notes.parser_drift_notes = `Parser drift reached ${benchmark.id}.`;
           }
         } catch (error) {
           const message = error instanceof Error ? error.message : String(error);
           bench.final_compile_summary_kind = "request-error";
           modelRecord.notes.language_drift_notes = message;
           if (message.toLowerCase().includes("timed out")) {
             modelRecord.notes.stalled_or_long_no_response = true;
           }
         }
         await persistResults(results);
         updateProcess(providerLabel, `moonbit-eval-${benchmark.id.toLowerCase()}`, bench.assisted_pass ? "succeeded" : "failed", `${benchmark.id} result for ${providerLabel}: raw=${bench.raw_codegen_pass ? "pass" : "fail"}, assisted=${bench.assisted_pass ? "pass" : "fail"}, repairs=${Number(bench.repair_attempts_used || 0)}.`);
       }
       const l3 = modelRecord.benchmarks.L3;
       if (l3?.raw_codegen_pass) {
         modelRecord.notes.final_recommendation_note = "Strong first-pass MoonBit candidate.";
       } else if (l3?.assisted_pass) {
         modelRecord.notes.final_recommendation_note = "Usable with compiler-guided repair.";
       } else {
         modelRecord.notes.final_recommendation_note = "Not yet reliable for MoonBit benchmark L3.";
       }
       await persistResults(results);
     }
     results.status = "completed";
     await persistResults(results);
     updateProcess(routerSummary, "moonbit-eval", "succeeded", "Free LLM MoonBit Eval completed. Results were written to artifacts/moonbit-eval-results.json and docs/experiments/free-llm-moonbit/results.md.");
     onDone(JSON.stringify(results, null, 2));
   } catch (error) {
     onError(error instanceof Error ? error.message : String(error));
   } finally {
     globalThis.__moonapEvalRunning = false;
   }
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app34browser__on__save__personal__skill = (handler) => document.addEventListener("click", (event) => {
   if (event.target?.id !== "savePersonalSkill") return;
   event.preventDefault();
   event.stopPropagation();
   const artifact = globalThis.__moonapLastArtifact;
   if (!artifact) {
     alert("No generated artifact is ready to save.");
     return;
   }
   alert("Save to Personal-SKILL-Set is disabled until real MoonBit compile and runtime execution are implemented.");
   return;
   let skills = [];
   try {
     const parsed = JSON.parse(localStorage.getItem("moonap.personal.skills") || "[]");
     skills = Array.isArray(parsed) ? parsed : [];
   } catch (error) {
     console.warn("MoonAP reset invalid personal skill storage:", error);
     try { localStorage.removeItem("moonap.personal.skills"); } catch {}
   }
   const next = skills.filter((skill) => skill.id !== artifact.id);
   next.unshift(artifact);
   localStorage.setItem("moonap.personal.skills", JSON.stringify(next));
   try {
     handler();
   } catch (error) {
     console.error("MoonAP save personal skill handler failed:", error);
     alert(`MoonAP save failed: ${error instanceof Error ? error.message : String(error)}`);
   }
 });
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app29browser__on__repair__artifact = (handler) => document.addEventListener("click", (event) => {
   if (event.target?.id !== "repairArtifact") return;
   event.preventDefault();
   event.stopPropagation();
   try {
     handler();
   } catch (error) {
     alert(`MoonAP repair failed: ${error instanceof Error ? error.message : String(error)}`);
   }
 });
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app33browser__render__personal__skills = () => {
   const root = document.querySelector("#personalSkillCards");
   if (!root) return 0;
   let skills = [];
   try {
     const parsed = JSON.parse(localStorage.getItem("moonap.personal.skills") || "[]");
     skills = Array.isArray(parsed) ? parsed : [];
   } catch (error) {
     console.warn("MoonAP reset invalid personal skill storage:", error);
     try { localStorage.removeItem("moonap.personal.skills"); } catch {}
   }
   root.innerHTML = "";
   skills = skills.filter((skill) => Boolean(skill?.runtime_ready));
   if (skills.length === 0) {
     const empty = document.createElement("div");
     empty.className = "personal-skill-empty";
     empty.textContent = "No runnable Personal SKILL yet. MoonAP source capture is working; real compile and runtime wiring are the next step before Personal-SKILL-Set becomes reusable.";
     root.append(empty);
     return 0;
   }
   for (const skill of skills) {
     const card = document.createElement("button");
     card.className = "skill-card personal";
     card.type = "button";
     card.dataset.skillId = skill.id || "personal.fastq-generator";
     card.innerHTML = `<span>Local / Generated</span><strong>${skill.name || "Personal FastQ Generator"}</strong><small>Saved locally in this browser. Reusable without LLM.</small>`;
     root.append(card);
   }
   return skills.length;
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app25browser__set__mode__panel = (text) => {
   const panel = document.querySelector("#modePanel");
   if (panel) panel.setAttribute("aria-label", String(text));
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app32browser__set__skill__panel__open = (open) => {
   document.querySelector("#modePanel")?.classList.toggle("is-open", Boolean(open));
   document.querySelector("#privacyStrip")?.classList.toggle("is-open", Boolean(open));
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app20browser__fetch__text = (path, onOk, onError) => {
   fetch(String(path))
     .then((response) => response.text())
     .then((text) => onOk(String(text)))
     .catch((error) => onError(error instanceof Error ? error.message : String(error)));
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json = (raw) => {
   try { return JSON.stringify(JSON.parse(String(raw)), null, 2); }
   catch { return String(raw); }
 };
const _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field = (raw, field) => {
   try {
     const value = JSON.parse(String(raw))?.[String(field)];
     return value == null ? "" : String(value);
   } catch {
     return "";
   }
 };
const _M0FPB18brute__force__findN6constrS8126 = 0;
const _M0FPB28boyer__moore__horspool__findN6constrS8125 = 0;
function _M0FPC15abort5abortGRPC16string10StringViewE(msg) {
  return $panic();
}
function _M0MPB13StringBuilder11new_2einner(size_hint) {
  return new _M0TPB13StringBuilder("");
}
function _M0MPB13StringBuilder10to__string(self) {
  return self.val;
}
function _M0IPB13StringBuilderPB6Logger11write__char(self, ch) {
  self.val = `${self.val}${String.fromCodePoint(ch)}`;
}
function _M0MPC16uint166UInt1622is__leading__surrogate(self) {
  return _M0IP016_24default__implPB7Compare6op__geGkE(self, 55296) && _M0IP016_24default__implPB7Compare6op__leGkE(self, 56319);
}
function _M0MPC16uint166UInt1623is__trailing__surrogate(self) {
  return _M0IP016_24default__implPB7Compare6op__geGkE(self, 56320) && _M0IP016_24default__implPB7Compare6op__leGkE(self, 57343);
}
function _M0FPB32code__point__of__surrogate__pair(leading, trailing) {
  return (((Math.imul(leading - 55296 | 0, 1024) | 0) + trailing | 0) - 56320 | 0) + 65536 | 0;
}
function _M0MPC16uint166UInt1616unsafe__to__char(self) {
  return self;
}
function _M0MPC16string10StringView6length(self) {
  return self.end - self.start | 0;
}
function _M0MPC16string10StringView11unsafe__get(self, index) {
  return self.str.charCodeAt(self.start + index | 0);
}
function _M0IPB13StringBuilderPB6Logger13write__string(self, str) {
  self.val = `${self.val}${str}`;
}
function _M0IPC16uint166UInt16PB2Eq10not__equal(self, that) {
  return self !== that;
}
function _M0IPC16uint166UInt16PB7Compare7compare(self, that) {
  return $compare_int(self, that);
}
function _M0IP016_24default__implPB2Eq10not__equalGsE(x, y) {
  return !(x === y);
}
function _M0IP016_24default__implPB7Compare6op__leGkE(x, y) {
  return _M0IPC16uint166UInt16PB7Compare7compare(x, y) <= 0;
}
function _M0IP016_24default__implPB7Compare6op__geGkE(x, y) {
  return _M0IPC16uint166UInt16PB7Compare7compare(x, y) >= 0;
}
function _M0MPC16string6String11sub_2einner(self, start, end) {
  const len = self.length;
  let end$2;
  if (end === undefined) {
    end$2 = len;
  } else {
    const _Some = end;
    const _end = _Some;
    end$2 = _end < 0 ? len + _end | 0 : _end;
  }
  const start$2 = start < 0 ? len + start | 0 : start;
  if (start$2 >= 0 && (start$2 <= end$2 && end$2 <= len)) {
    if (start$2 < len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.charCodeAt(start$2))) {
      } else {
        $panic();
      }
    }
    if (end$2 < len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.charCodeAt(end$2))) {
      } else {
        $panic();
      }
    }
    return new _M0TPC16string10StringView(self, start$2, end$2);
  } else {
    return $panic();
  }
}
function _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE(self, value, start, len) {
  _M0IPB13StringBuilderPB6Logger11write__view(self, _M0MPC16string6String11sub_2einner(value, start, start + len | 0));
}
function _M0MPC16string10StringView4data(self) {
  return self.str;
}
function _M0MPC16string10StringView13start__offset(self) {
  return self.start;
}
function _M0MPB4Iter4nextGcE(self) {
  const _func = self;
  return _func();
}
function _M0MPB4Iter4nextGsE(self) {
  const _func = self;
  return _func();
}
function _M0MPC13int3Int18to__string_2einner(self, radix) {
  return _M0FPB19int__to__string__js(self, radix);
}
function _M0MPB4Iter3newGcE(f) {
  return f;
}
function _M0MPB4Iter3newGsE(f) {
  return f;
}
function _M0MPC16string10StringView12view_2einner(self, start_offset, end_offset) {
  let end_offset$2;
  if (end_offset === undefined) {
    end_offset$2 = _M0MPC16string10StringView6length(self);
  } else {
    const _Some = end_offset;
    end_offset$2 = _Some;
  }
  return start_offset >= 0 && (start_offset <= end_offset$2 && end_offset$2 <= _M0MPC16string10StringView6length(self)) ? new _M0TPC16string10StringView(self.str, self.start + start_offset | 0, self.start + end_offset$2 | 0) : _M0FPC15abort5abortGRPC16string10StringViewE("Invalid index for View");
}
function _M0IPC16string10StringViewPB4Show10to__string(self) {
  return self.str.substring(self.start, self.end);
}
function _M0MPC16string10StringView4iter(self) {
  const start = self.start;
  const end = self.end;
  const index = new _M0TPB8MutLocalGiE(start);
  return _M0MPB4Iter3newGcE(() => {
    if (index.val < end) {
      const c1 = self.str.charCodeAt(index.val);
      if (_M0MPC16uint166UInt1622is__leading__surrogate(c1) && (index.val + 1 | 0) < self.end) {
        const c2 = self.str.charCodeAt(index.val + 1 | 0);
        if (_M0MPC16uint166UInt1623is__trailing__surrogate(c2)) {
          index.val = index.val + 2 | 0;
          return _M0FPB32code__point__of__surrogate__pair(c1, c2);
        }
      }
      index.val = index.val + 1 | 0;
      return _M0MPC16uint166UInt1616unsafe__to__char(c1);
    } else {
      return -1;
    }
  });
}
function _M0MPB5Iter23newGicE(f) {
  return _M0MPB4Iter3newGsE(f);
}
function _M0MPC16string10StringView5iter2(self) {
  const start = self.start;
  const end = self.end;
  const index = new _M0TPB8MutLocalGiE(start);
  const char_index = new _M0TPB8MutLocalGiE(0);
  return _M0MPB5Iter23newGicE(() => {
    if (index.val < end) {
      const c1 = self.str.charCodeAt(index.val);
      if (_M0MPC16uint166UInt1622is__leading__surrogate(c1) && (index.val + 1 | 0) < self.end) {
        const c2 = self.str.charCodeAt(index.val + 1 | 0);
        if (_M0MPC16uint166UInt1623is__trailing__surrogate(c2)) {
          const result = { _0: char_index.val, _1: _M0FPB32code__point__of__surrogate__pair(c1, c2) };
          index.val = index.val + 2 | 0;
          char_index.val = char_index.val + 1 | 0;
          return result;
        }
      }
      const result = { _0: char_index.val, _1: _M0MPC16uint166UInt1616unsafe__to__char(c1) };
      index.val = index.val + 1 | 0;
      char_index.val = char_index.val + 1 | 0;
      return result;
    } else {
      return undefined;
    }
  });
}
function _M0MPC16string6String12view_2einner(self, start_offset, end_offset) {
  let end_offset$2;
  if (end_offset === undefined) {
    end_offset$2 = self.length;
  } else {
    const _Some = end_offset;
    end_offset$2 = _Some;
  }
  return start_offset >= 0 && (start_offset <= end_offset$2 && end_offset$2 <= self.length) ? new _M0TPC16string10StringView(self, start_offset, end_offset$2) : _M0FPC15abort5abortGRPC16string10StringViewE("Invalid index for View");
}
function _M0MPC15array9ArrayView6lengthGsE(self) {
  return self.end - self.start | 0;
}
function _M0IPB13StringBuilderPB6Logger11write__view(self, str) {
  self.val = `${self.val}${_M0IPC16string10StringViewPB4Show10to__string(str)}`;
}
function _M0FPB28boyer__moore__horspool__find(haystack, needle) {
  const haystack_len = _M0MPC16string10StringView6length(haystack);
  const needle_len = _M0MPC16string10StringView6length(needle);
  if (needle_len > 0) {
    if (haystack_len >= needle_len) {
      const skip_table = $make_array_len_and_init(256, needle_len);
      const _bind = needle_len - 1 | 0;
      let _tmp = 0;
      while (true) {
        const i = _tmp;
        if (i < _bind) {
          const _tmp$2 = _M0MPC16string10StringView11unsafe__get(needle, i) & 255;
          $bound_check(skip_table, _tmp$2);
          skip_table[_tmp$2] = (needle_len - 1 | 0) - i | 0;
          _tmp = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      let _tmp$2 = 0;
      while (true) {
        const i = _tmp$2;
        if (i <= (haystack_len - needle_len | 0)) {
          const _bind$2 = needle_len - 1 | 0;
          let _tmp$3 = 0;
          while (true) {
            const j = _tmp$3;
            if (j <= _bind$2) {
              if (_M0IPC16uint166UInt16PB2Eq10not__equal(_M0MPC16string10StringView11unsafe__get(haystack, i + j | 0), _M0MPC16string10StringView11unsafe__get(needle, j))) {
                break;
              }
              _tmp$3 = j + 1 | 0;
              continue;
            } else {
              return i;
            }
          }
          const _tmp$4 = _M0MPC16string10StringView11unsafe__get(haystack, (i + needle_len | 0) - 1 | 0) & 255;
          $bound_check(skip_table, _tmp$4);
          _tmp$2 = i + skip_table[_tmp$4] | 0;
          continue;
        } else {
          break;
        }
      }
      return undefined;
    } else {
      return undefined;
    }
  } else {
    return _M0FPB28boyer__moore__horspool__findN6constrS8125;
  }
}
function _M0FPB18brute__force__find(haystack, needle) {
  const haystack_len = _M0MPC16string10StringView6length(haystack);
  const needle_len = _M0MPC16string10StringView6length(needle);
  if (needle_len > 0) {
    if (haystack_len >= needle_len) {
      const needle_first = _M0MPC16string10StringView11unsafe__get(needle, 0);
      const forward_len = haystack_len - needle_len | 0;
      let _tmp = 0;
      while (true) {
        const i = _tmp;
        if (i <= forward_len) {
          if (_M0IPC16uint166UInt16PB2Eq10not__equal(_M0MPC16string10StringView11unsafe__get(haystack, i), needle_first)) {
            _tmp = i + 1 | 0;
            continue;
          }
          let _tmp$2 = 1;
          while (true) {
            const j = _tmp$2;
            if (j < needle_len) {
              if (_M0IPC16uint166UInt16PB2Eq10not__equal(_M0MPC16string10StringView11unsafe__get(haystack, i + j | 0), _M0MPC16string10StringView11unsafe__get(needle, j))) {
                break;
              }
              _tmp$2 = j + 1 | 0;
              continue;
            } else {
              return i;
            }
          }
          _tmp = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      return undefined;
    } else {
      return undefined;
    }
  } else {
    return _M0FPB18brute__force__findN6constrS8126;
  }
}
function _M0MPC16string10StringView4find(self, str) {
  return _M0MPC16string10StringView6length(str) <= 4 ? _M0FPB18brute__force__find(self, str) : _M0FPB28boyer__moore__horspool__find(self, str);
}
function _M0MPC16string6String4find(self, str) {
  return _M0MPC16string10StringView4find(new _M0TPC16string10StringView(self, 0, self.length), str);
}
function _M0MPC16string10StringView8find__by(self, pred) {
  const _it = _M0MPC16string10StringView5iter2(self);
  while (true) {
    const _bind = _M0MPB5Iter24nextGicE(_it);
    if (_bind === undefined) {
      break;
    } else {
      const _Some = _bind;
      const _x = _Some;
      const _i = _x._0;
      const _c = _x._1;
      if (pred(_c)) {
        return _i;
      }
      continue;
    }
  }
  return undefined;
}
function _M0MPC16string6String8find__by(self, pred) {
  return _M0MPC16string10StringView8find__by(new _M0TPC16string10StringView(self, 0, self.length), pred);
}
function _M0MPC16string10StringView8contains(self, str) {
  const _bind = _M0MPC16string10StringView4find(self, str);
  return !(_bind === undefined);
}
function _M0MPC16string6String8contains(self, str) {
  return _M0MPC16string10StringView8contains(new _M0TPC16string10StringView(self, 0, self.length), str);
}
function _M0MPC16string6String4iter(self) {
  const len = self.length;
  const index = new _M0TPB8MutLocalGiE(0);
  return _M0MPB4Iter3newGcE(() => {
    if (index.val < len) {
      const c1 = self.charCodeAt(index.val);
      if (_M0MPC16uint166UInt1622is__leading__surrogate(c1) && (index.val + 1 | 0) < len) {
        const c2 = self.charCodeAt(index.val + 1 | 0);
        if (_M0MPC16uint166UInt1623is__trailing__surrogate(c2)) {
          const c = _M0FPB32code__point__of__surrogate__pair(c1, c2);
          index.val = index.val + 2 | 0;
          return c;
        }
      }
      index.val = index.val + 1 | 0;
      return _M0MPC16uint166UInt1616unsafe__to__char(c1);
    } else {
      return -1;
    }
  });
}
function _M0MPC16string6String12replace__all(self, old, new_) {
  const len = self.length;
  const buf = _M0MPB13StringBuilder11new_2einner(len);
  const old_len = _M0MPC16string10StringView6length(old);
  const new$2 = _M0IPC16string10StringViewPB4Show10to__string(new_);
  if (old_len === 0) {
    _M0IPB13StringBuilderPB6Logger13write__string(buf, new$2);
    const _it = _M0MPC16string6String4iter(self);
    while (true) {
      const _bind = _M0MPB4Iter4nextGcE(_it);
      if (_bind === -1) {
        break;
      } else {
        const _Some = _bind;
        const _c = _Some;
        _M0IPB13StringBuilderPB6Logger11write__char(buf, _c);
        _M0IPB13StringBuilderPB6Logger13write__string(buf, new$2);
        continue;
      }
    }
    return _M0MPB13StringBuilder10to__string(buf);
  } else {
    const first_end = _M0MPC16string6String4find(self, old);
    if (first_end === undefined) {
      return self;
    } else {
      const _Some = first_end;
      const _end = _Some;
      let _tmp = new _M0TPC16string10StringView(self, 0, self.length);
      let _tmp$2 = _end;
      while (true) {
        const view = _tmp;
        const end = _tmp$2;
        const seg = _M0MPC16string10StringView12view_2einner(view, 0, end);
        _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE(buf, _M0MPC16string10StringView4data(seg), _M0MPC16string10StringView13start__offset(seg), _M0MPC16string10StringView6length(seg));
        _M0IPB13StringBuilderPB6Logger13write__string(buf, new$2);
        if ((end + old_len | 0) <= len) {
          const next_view = _M0MPC16string10StringView12view_2einner(view, end + old_len | 0, undefined);
          const _bind = _M0MPC16string10StringView4find(next_view, old);
          if (_bind === undefined) {
            _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE(buf, _M0MPC16string10StringView4data(next_view), _M0MPC16string10StringView13start__offset(next_view), _M0MPC16string10StringView6length(next_view));
            break;
          } else {
            const _Some$2 = _bind;
            const _next_end = _Some$2;
            _tmp = next_view;
            _tmp$2 = _next_end;
            continue;
          }
        } else {
          break;
        }
      }
      return _M0MPB13StringBuilder10to__string(buf);
    }
  }
}
function _M0MPC14char4Char20is__ascii__uppercase(self) {
  return self >= 65 && self <= 90;
}
function _M0MPC16string6String9to__lower(self) {
  const _bind = _M0MPC16string6String8find__by(self, (x) => _M0MPC14char4Char20is__ascii__uppercase(x));
  if (_bind === undefined) {
    return self;
  } else {
    const _Some = _bind;
    const _idx = _Some;
    const buf = _M0MPB13StringBuilder11new_2einner(self.length);
    const head = _M0MPC16string6String12view_2einner(self, 0, _idx);
    _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE(buf, _M0MPC16string10StringView4data(head), _M0MPC16string10StringView13start__offset(head), _M0MPC16string10StringView6length(head));
    const _it = _M0MPC16string10StringView4iter(_M0MPC16string6String12view_2einner(self, _idx, undefined));
    while (true) {
      const _bind$2 = _M0MPB4Iter4nextGcE(_it);
      if (_bind$2 === -1) {
        break;
      } else {
        const _Some$2 = _bind$2;
        const _c = _Some$2;
        if (_M0MPC14char4Char20is__ascii__uppercase(_c)) {
          _M0IPB13StringBuilderPB6Logger11write__char(buf, _c + 32 | 0);
        } else {
          _M0IPB13StringBuilderPB6Logger11write__char(buf, _c);
        }
        continue;
      }
    }
    return _M0MPB13StringBuilder10to__string(buf);
  }
}
function _M0MPC15array9ArrayView4iterGsE(self) {
  const i = new _M0TPB8MutLocalGiE(0);
  return _M0MPB4Iter3newGsE(() => {
    if (i.val < _M0MPC15array9ArrayView6lengthGsE(self)) {
      const elem = self.buf[self.start + i.val | 0];
      i.val = i.val + 1 | 0;
      return elem;
    } else {
      return undefined;
    }
  });
}
function _M0MPC15array5Array4iterGsE(self) {
  return _M0MPC15array9ArrayView4iterGsE(new _M0TPB9ArrayViewGsE(self, 0, self.length));
}
function _M0MPB4Iter4join(self, sep) {
  const result = _M0MPB13StringBuilder11new_2einner(0);
  const _bind = _M0MPB4Iter4nextGsE(self);
  if (_bind === undefined) {
  } else {
    const _Some = _bind;
    const _x = _Some;
    _M0IPB13StringBuilderPB6Logger13write__string(result, _x);
    while (true) {
      const _bind$2 = _M0MPB4Iter4nextGsE(self);
      if (_bind$2 === undefined) {
        break;
      } else {
        const _Some$2 = _bind$2;
        const _x$2 = _Some$2;
        _M0IPB13StringBuilderPB6Logger13write__string(result, sep);
        _M0IPB13StringBuilderPB6Logger13write__string(result, _x$2);
        continue;
      }
    }
  }
  return _M0MPB13StringBuilder10to__string(result);
}
function _M0MPB5Iter24nextGicE(self) {
  return _M0MPB4Iter4nextGsE(self);
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app13context__path(message, file_name) {
  const hint = _M0MPC16string6String9to__lower(`${message} ${file_name}`);
  let _tmp;
  const _bind = "fastq";
  if (_M0MPC16string6String8contains(hint, new _M0TPC16string10StringView(_bind, 0, _bind.length))) {
    _tmp = true;
  } else {
    const _bind$2 = ".fq";
    _tmp = _M0MPC16string6String8contains(hint, new _M0TPC16string10StringView(_bind$2, 0, _bind$2.length));
  }
  if (_tmp) {
    return "/api/agent/context?fastq";
  } else {
    const _bind$2 = "csv";
    if (_M0MPC16string6String8contains(hint, new _M0TPC16string10StringView(_bind$2, 0, _bind$2.length))) {
      return "/api/agent/context?csv";
    } else {
      let _tmp$2;
      const _bind$3 = "xlsx";
      if (_M0MPC16string6String8contains(hint, new _M0TPC16string10StringView(_bind$3, 0, _bind$3.length))) {
        _tmp$2 = true;
      } else {
        let _tmp$3;
        const _bind$4 = "xls";
        if (_M0MPC16string6String8contains(hint, new _M0TPC16string10StringView(_bind$4, 0, _bind$4.length))) {
          _tmp$3 = true;
        } else {
          const _bind$5 = "excel";
          _tmp$3 = _M0MPC16string6String8contains(hint, new _M0TPC16string10StringView(_bind$5, 0, _bind$5.length));
        }
        _tmp$2 = _tmp$3;
      }
      if (_tmp$2) {
        return "/api/agent/context?xlsx";
      } else {
        const _bind$4 = "json";
        if (_M0MPC16string6String8contains(hint, new _M0TPC16string10StringView(_bind$4, 0, _bind$4.length))) {
          return "/api/agent/context?json";
        } else {
          const _bind$5 = "game";
          if (_M0MPC16string6String8contains(hint, new _M0TPC16string10StringView(_bind$5, 0, _bind$5.length))) {
            return "/api/agent/context?game";
          } else {
            return "/api/agent/context";
          }
        }
      }
    }
  }
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app28active__skill__from__context(raw) {
  const _bind = "\"active_skill\": \"fastq\"";
  if (_M0MPC16string6String8contains(raw, new _M0TPC16string10StringView(_bind, 0, _bind.length))) {
    return "fastq";
  } else {
    const _bind$2 = "\"active_skill\": \"csv\"";
    if (_M0MPC16string6String8contains(raw, new _M0TPC16string10StringView(_bind$2, 0, _bind$2.length))) {
      return "csv";
    } else {
      const _bind$3 = "\"active_skill\": \"spreadsheet\"";
      if (_M0MPC16string6String8contains(raw, new _M0TPC16string10StringView(_bind$3, 0, _bind$3.length))) {
        return "spreadsheet";
      } else {
        const _bind$4 = "\"active_skill\": \"json\"";
        if (_M0MPC16string6String8contains(raw, new _M0TPC16string10StringView(_bind$4, 0, _bind$4.length))) {
          return "json";
        } else {
          const _bind$5 = "\"active_skill\": \"game\"";
          if (_M0MPC16string6String8contains(raw, new _M0TPC16string10StringView(_bind$5, 0, _bind$5.length))) {
            return "game";
          } else {
            return "chat";
          }
        }
      }
    }
  }
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app11show__error(label, error) {
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__set__state(`${label}: ${error}`);
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__update__process("-", label, "failed", error, "");
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__render__artifact__card("MoonAP error", error, "[\"failed\"]", false, false, false);
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app17refresh__policies() {
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app20browser__fetch__text("/api/app-state", (raw) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__set__state(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json(raw));
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__render__onboarding();
  }, (error) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app11show__error("app-state fetch failed", error);
  });
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app16show__llm__entry() {
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app25browser__set__mode__panel("LLM settings");
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app32browser__set__skill__panel__open(false);
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app26browser__open__llm__dialog();
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app20browser__fetch__text("/api/formal-verification", (raw) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__set__state(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json(raw));
  }, (error) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app11show__error("LLM state fetch failed", error);
  });
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app18show__skill__entry() {
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app25browser__set__mode__panel("MoonAP SKILL Hub");
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app32browser__set__skill__panel__open(true);
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app33browser__render__personal__skills();
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app20browser__fetch__text("/api/skills", (raw) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__set__state(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json(raw));
  }, (error) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app11show__error("SKILL hub fetch failed", error);
  });
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app22show__skill__run__plan(skill_id) {
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app28browser__open__skill__dialog(skill_id);
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19run__fastq__counter() {
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app30browser__clear__artifact__card();
  if (!_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app18browser__has__file()) {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__append__message("assistant", "Choose a FastQ file with the + button first, then run FastQ Base Counter. File contents will stay in this browser.");
    return undefined;
  }
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app28browser__run__fastq__counter(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app22browser__dialog__param("targetBase"), (progress) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__set__state(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json(progress));
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app30browser__update__result__panel(progress);
  }, (result) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__set__state(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json(result));
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app30browser__update__result__panel(result);
  }, (error) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app11show__error("FastQ analysis failed", error);
  });
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21run__fastq__generator() {
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app30browser__clear__artifact__card();
  const read_count = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__dialog__param__int("readCount", 10000);
  const read_length = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__dialog__param__int("readLength", 150);
  const seed_value = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__dialog__param__int("seed", 42);
  const n_rate_text = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app22browser__dialog__param("nRate");
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app32browser__generate__fastq__sample(read_count, read_length, n_rate_text, seed_value, (result) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__set__state(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json(result));
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app30browser__update__result__panel(result);
  }, (error) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app11show__error("FastQ generator failed", error);
  });
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app29run__free__llm__moonbit__eval(max_level) {
  const current = max_level < 1 ? 1 : max_level > 3 ? 3 : max_level;
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__append__message("assistant", `Starting Free LLM MoonBit Eval. We will run the enabled provider/model entries against benchmark levels L1-L${_M0MPC13int3Int18to__string_2einner(current, 10)} with minimal prompts, then persist raw JSON plus a markdown summary.`);
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__update__process(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__llm__summary(), "moonbit-eval", "running", "Preparing the experiment harness. Results will be persisted to artifacts/moonbit-eval-results.json and docs/experiments/free-llm-moonbit/results.md.", "");
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app38browser__run__free__llm__moonbit__eval(current, (result) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__set__state(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json(result));
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__render__artifact__card("Free LLM MoonBit Eval finished", "MoonAP completed the current experiment pass and wrote both raw JSON and a markdown summary file.", "[\"experiment complete\",\"json persisted\",\"markdown persisted\"]", false, false, false);
  }, (error) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app11show__error("Free LLM MoonBit Eval failed", error);
  });
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app32clamp__moonbit__benchmark__level(level) {
  return level < 1 ? 1 : level > 5 ? 5 : level;
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app26moonbit__benchmark__prompt(level) {
  const current = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app32clamp__moonbit__benchmark__level(level);
  return current === 1 ? _M0MPB4Iter4join(_M0MPC15array5Array4iterGsE(["MoonBit Benchmark Level 1.", "Write the smallest valid `cmd/main/main.mbt` that compiles under wasm-gc.", "Required behavior:", "- `main` returns the string `hello moonbit`", "- no helper functions", "- no imports", "- keep the file tiny", "Return only the file contents."]), "\n") : current === 2 ? _M0MPB4Iter4join(_M0MPC15array5Array4iterGsE(["MoonBit Benchmark Level 2.", "Write `cmd/main/main.mbt` with exactly one helper function plus `main`.", "Required behavior:", "- helper function returns the string `hello moonbit`", "- `main` calls the helper and returns the result", "- no imports", "- keep the file tiny and valid for wasm-gc compile", "Return only the file contents."]), "\n") : current === 3 ? _M0MPB4Iter4join(_M0MPC15array5Array4iterGsE(["MoonBit Benchmark Level 3.", "Write `cmd/main/main.mbt` that builds a fixed string using simple control flow.", "Required behavior:", "- return exactly `ABC` from `main`", "- no imports", "- no randomness", "- keep the implementation compact and valid for wasm-gc compile", "Return only the file contents."]), "\n") : current === 4 ? _M0MPB4Iter4join(_M0MPC15array5Array4iterGsE(["MoonBit Benchmark Level 4.", "Write `cmd/main/main.mbt` with two helper functions that thread a small deterministic integer state value.", "Required behavior:", "- one helper updates an integer state", "- one helper turns the state into a single base from `A`, `C`, `G`, `T`", "- `main` returns a fixed 12-character DNA string generated from seed 42", "- no imports", "- no floating point types", "- keep the code compact and valid for wasm-gc compile", "Return only the file contents."]), "\n") : _M0MPB4Iter4join(_M0MPC15array5Array4iterGsE(["MoonBit Benchmark Level 5.", "Write `cmd/main/main.mbt` for a tiny deterministic synthetic read generator.", "Required behavior:", "- return one 4-line FastQ record as a String", "- header must be `@moonap_benchmark_0`", "- sequence length must be 12", "- quality line must be twelve `I` characters", "- deterministic output from seed 42", "- no imports", "- keep the code compact and valid for wasm-gc compile", "Return only the file contents."]), "\n");
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app25moonbit__benchmark__title(level) {
  return `MoonBit Benchmark L${_M0MPC13int3Int18to__string_2einner(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app32clamp__moonbit__benchmark__level(level), 10)}`;
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24moonbit__llm__primer__v1() {
  return _M0MPB4Iter4join(_M0MPC15array5Array4iterGsE(["MoonBit 0.9 Primer for general LLMs:", "Treat MoonBit as its own language. Do not borrow syntax from Rust, C, C++, Go, Java, Python, TypeScript, or OCaml.", "", "MoonAP task constraints:", "1. Generate ONLY cmd/main/main.mbt. The build system already creates moon.mod.json and moon.pkg.", "2. Return source code only. No explanations, no markdown fences, no shell commands, no extra files.", "3. The target is `moon build cmd/main --target wasm-gc`, so keep the file self-contained.", "", "Core MoonBit 0.9 habits:", "4. Use MoonBit block style. The entry point should be `fn main { ... }`.", "5. Prefer the smallest valid solution that satisfies the task.", "6. Add helper functions only when they are clearly needed.", "7. If you are unsure about a library API, avoid that API and solve the task with basic language constructs.", "", "Tiny valid examples to imitate:", "fn main {", "  \"hello moonbit\"", "}", "", "fn greet(name : String) -> String {", "  \"hello \" + name", "}", "", "fn main {", "  greet(\"moonbit\")", "}", "", "Important syntax expectations:", "8. Use MoonBit type names like `Int`, `String`, `Bool`. Do not use `i32`, `u32`, `f32`, `usize`, or `char`.", "9. Do not write Rust-style imports like `import std::fmt;` or `use std::...`. In MoonAP tasks, do not write imports unless the task explicitly requires them.", "10. Do not write Rust mutation or collection syntax like `mut`, `let mut`, `String::new()`, `Vec`, `format!`, `println!`, `push_str`, or `as Type` casts.", "11. Do not write numeric suffixes like `42u32`, `1usize`, or `3.14f32`.", "12. Do not invent package declarations, trait syntax, impl blocks, or extra module files unless the task explicitly asks for them.", "", "Generation strategy:", "13. First write the smallest compilable MoonBit program that satisfies the task.", "14. Then add only the minimum helper functions or bindings needed by the requested behavior.", "15. When in doubt, choose simpler code over more abstract code."]), "\n");
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app25max__auto__repair__rounds() {
  return 2;
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19run__compile__probe() {
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app30browser__clear__artifact__card();
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__update__process(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__llm__summary(), "moonbit-wasm-compile", "running", "Submitting captured MoonBit source to the native MoonAP compile probe.", "");
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app32browser__compile__last__artifact(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app38browser__formal__verification__enabled(), (result) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__store__compile__report(result);
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__set__state(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json(result));
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app29browser__append__runtime__log("compile", "compile-report", _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json(result));
    const ok = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "ok");
    const stage = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "stage");
    const output = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "output");
    const wasm_path = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "wasm_path");
    const summary_kind = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "summary_kind");
    const repair_hint = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "repair_hint");
    const summary_excerpt = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "summary_excerpt");
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__update__process(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__llm__summary(), stage === "" ? "moonbit-wasm-compile" : stage, ok === "true" ? "succeeded" : "failed", ok === "true" || summary_excerpt === "" ? output : repair_hint === "" ? summary_excerpt : `${summary_excerpt}\nRepair hint: ${repair_hint}`, wasm_path === "" ? "No wasm artifact was produced." : `Wasm artifact: ${wasm_path}`);
    if (ok === "true") {
      const benchmark_assessment = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app32browser__assess__last__benchmark();
      _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app29browser__append__runtime__log("benchmark", "benchmark-assessment", benchmark_assessment);
      const benchmark_applicable = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(benchmark_assessment, "applicable");
      _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app35browser__set__benchmark__assessment(benchmark_assessment);
      if (benchmark_applicable === "true") {
        const benchmark_title = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(benchmark_assessment, "title");
        const benchmark_summary = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(benchmark_assessment, "summary");
        const benchmark_meta_json = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(benchmark_assessment, "meta_json");
        const benchmark_pass = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(benchmark_assessment, "pass");
        _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__update__process(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__llm__summary(), "moonbit-benchmark-check", benchmark_pass === "true" ? "succeeded" : "failed", benchmark_summary, "");
        const benchmark_hint = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(benchmark_assessment, "repair_hint");
        const benchmark_missing_signals_json = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(benchmark_assessment, "missing_signals_json");
        if (_M0IP016_24default__implPB2Eq10not__equalGsE(benchmark_pass, "true") && _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app44maybe__auto__repair__after__quality__failure(benchmark_title, benchmark_summary, benchmark_hint, benchmark_missing_signals_json)) {
          return;
        } else {
          _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__render__artifact__card(benchmark_title, benchmark_summary, benchmark_meta_json, true, false, false);
          _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__render__onboarding();
          return;
        }
      } else {
        _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__render__artifact__card("Compile probe succeeded", "MoonAP used the native MoonBit toolchain on this machine and produced a real wasm-gc artifact. Browser-local runtime execution is the next implementation step.", "[\"compile probe ok\",\"real wasm built\",\"runtime pending\"]", true, false, false);
        _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__render__onboarding();
        return;
      }
    } else {
      if (_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app44maybe__auto__repair__after__compile__failure(summary_kind, repair_hint, summary_excerpt)) {
        return;
      } else {
        const _tmp = repair_hint === "" ? "MoonAP attempted a real native compile and returned the true compiler output. Review Details and iterate on the generated source." : "MoonAP summarized the compiler failure, exhausted the current auto-repair budget, and kept the true compiler output for inspection.";
        const _bind = "\"";
        const _tmp$2 = new _M0TPC16string10StringView(_bind, 0, _bind.length);
        const _bind$2 = "'";
        _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__render__artifact__card("Compile probe failed", _tmp, `[\"compile failed\",\"true compiler output\",\"${summary_kind}\",\"${_M0MPC16string6String12replace__all(summary_excerpt, _tmp$2, new _M0TPC16string10StringView(_bind$2, 0, _bind$2.length))}\"]`, true, false, false);
        return;
      }
    }
  }, (error) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app11show__error("compile probe failed", error);
  });
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app44maybe__auto__repair__after__compile__failure(summary_kind, repair_hint, summary_excerpt) {
  const repair_round = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app38browser__last__artifact__repair__round();
  const max_rounds = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app25max__auto__repair__rounds();
  if (repair_hint === "" || repair_round >= max_rounds) {
    return false;
  } else {
    const next_round = repair_round + 1 | 0;
    const log_text = summary_excerpt === "" ? repair_hint : `${summary_excerpt}\nRepair hint: ${repair_hint}`;
    const detected_kind = summary_kind === "" ? "compiler-error" : summary_kind;
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__update__process(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__llm__summary(), "compile-repair", "running", `Compile probe failed. MoonAP is auto-repairing round ${_M0MPC13int3Int18to__string_2einner(next_round, 10)}/${_M0MPC13int3Int18to__string_2einner(max_rounds, 10)} using Compile-Error Summarizer v1.\n${log_text}`, "");
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__render__artifact__card("Compile probe failed, auto-repairing", `MoonAP detected ${detected_kind} and automatically started repair round ${_M0MPC13int3Int18to__string_2einner(next_round, 10)}/${_M0MPC13int3Int18to__string_2einner(max_rounds, 10)}.`, `[\"auto repair\",\"round ${_M0MPC13int3Int18to__string_2einner(next_round, 10)}\",\"${detected_kind}\"]`, false, false, false);
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app35run__repair__from__compile__summary();
    return true;
  }
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app35run__repair__from__compile__summary() {
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app30browser__clear__artifact__card();
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__update__process(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__llm__summary(), "compile-repair", "running", "Submitting the captured compiler failure back to the next enabled provider together with the MoonBit primer.", "");
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app55browser__repair__last__artifact__with__compile__summary(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app38browser__formal__verification__enabled(), _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24moonbit__llm__primer__v1(), (result) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__set__state(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json(result));
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app29browser__append__runtime__log("artifact", "repair-result", _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json(result));
    const provider = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "llm_provider");
    const model = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "llm_model");
    const source = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "moonbit_source");
    const repair_round = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "repair_round");
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__update__process(provider === "" ? _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__llm__summary() : model === "" ? provider : `${provider}/${model}`, "compile-repair", "succeeded", "Compile-Error Summarizer v1 injected the first compiler failure into a repair prompt. MoonAP captured a repaired MoonBit source and will run the compile probe again automatically.", source === "" ? "No repaired source returned." : source);
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__render__artifact__card("Repaired source is ready", `MoonAP generated repair round ${repair_round} from the summarized compiler failure and is now re-running the native compile probe.`, `[\"repair round ${repair_round}\",\"compile summary v1\",\"compile starting\"]`, true, false, false);
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19run__compile__probe();
  }, (error) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app11show__error("MoonBit compile repair failed", error);
  });
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app44maybe__auto__repair__after__quality__failure(assessment_title, assessment_summary, assessment_hint, missing_signals_json) {
  const repair_round = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app38browser__last__artifact__repair__round();
  const max_rounds = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app25max__auto__repair__rounds();
  if (repair_round >= max_rounds) {
    return false;
  } else {
    const next_round = repair_round + 1 | 0;
    const detected_title = assessment_title === "" ? "System assessment failed" : assessment_title;
    const missing_excerpt = missing_signals_json === "" || missing_signals_json === "[]" ? "" : `\nMissing signals: ${missing_signals_json}`;
    const hint_excerpt = assessment_hint === "" ? missing_excerpt : `\nRepair hint: ${assessment_hint}${missing_excerpt}`;
    const log_text = `Compile probe succeeded, but system assessment failed. MoonAP is auto-repairing round ${_M0MPC13int3Int18to__string_2einner(next_round, 10)}/${_M0MPC13int3Int18to__string_2einner(max_rounds, 10)} using the captured benchmark feedback.\n${assessment_summary}${hint_excerpt}`;
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__update__process(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__llm__summary(), "quality-repair", "running", log_text, "");
    const _tmp = `MoonAP kept the compiled artifact, but the system assessment still failed. Starting quality repair round ${_M0MPC13int3Int18to__string_2einner(next_round, 10)}/${_M0MPC13int3Int18to__string_2einner(max_rounds, 10)}.`;
    const _tmp$2 = _M0MPC13int3Int18to__string_2einner(next_round, 10);
    const _bind = "\"";
    const _tmp$3 = new _M0TPC16string10StringView(_bind, 0, _bind.length);
    const _bind$2 = "'";
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__render__artifact__card("Compile succeeded, auto-repairing quality", _tmp, `[\"quality repair\",\"round ${_tmp$2}\",\"${_M0MPC16string6String12replace__all(detected_title, _tmp$3, new _M0TPC16string10StringView(_bind$2, 0, _bind$2.length))}\"]`, false, false, false);
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app37run__repair__from__system__assessment();
    return true;
  }
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app37run__repair__from__system__assessment() {
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app30browser__clear__artifact__card();
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__update__process(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__llm__summary(), "quality-repair", "running", "Submitting the captured system assessment back to the next enabled provider together with the MoonBit primer.", "");
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app57browser__repair__last__artifact__with__system__assessment(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24moonbit__llm__primer__v1(), (result) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__set__state(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json(result));
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app29browser__append__runtime__log("artifact", "quality-repair-result", _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json(result));
    const provider = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "llm_provider");
    const model = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "llm_model");
    const source = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "moonbit_source");
    const repair_round = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "repair_round");
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__update__process(provider === "" ? _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__llm__summary() : model === "" ? provider : `${provider}/${model}`, "quality-repair", "succeeded", "MoonAP injected the current system assessment into a quality-repair prompt. The revised MoonBit source will now be compiled again automatically.", source === "" ? "No revised source returned." : source);
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__render__artifact__card("Quality-repaired source is ready", `MoonAP generated repair round ${repair_round} from the system assessment and is now re-running the native compile probe.`, `[\"quality repair round ${repair_round}\",\"system assessment\",\"compile starting\"]`, true, false, false);
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19run__compile__probe();
  }, (error) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app11show__error("MoonBit quality repair failed", error);
  });
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app26run__llm__moonbit__codegen(task_title, prompt, source_summary, simple_mode) {
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app30browser__clear__artifact__card();
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__reset__compile__report();
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app35browser__set__benchmark__assessment("");
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__update__process(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__llm__summary(), "llm-codegen", "running", "Submitting prompt to the next enabled provider in the router with the MoonBit primer injected into the user prompt.", "");
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app36browser__generate__moonbit__artifact(task_title, prompt, simple_mode, _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app38browser__formal__verification__enabled(), _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24moonbit__llm__primer__v1(), (result) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__set__state(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json(result));
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app29browser__append__runtime__log("artifact", "llm-codegen-result", _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json(result));
    const provider = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "llm_provider");
    const model = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "llm_model");
    const source = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__artifact__field(result, "moonbit_source");
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__update__process(provider === "" ? _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__llm__summary() : model === "" ? provider : `${provider}/${model}`, "llm-codegen", "succeeded", "Real LLM response received. MoonBit source captured after the MoonBit primer injection. Compile/run remains pending until the next implementation step.", source === "" ? "No generated source returned." : source);
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__render__artifact__card(`${task_title} source is ready`, source_summary, "[\"real LLM response\",\"source captured\",\"compile starting\"]", true, false, false);
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19run__compile__probe();
  }, (error) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app11show__error("LLM MoonBit artifact generation failed", error);
  });
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app23run__moonbit__benchmark(level) {
  const current = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app32clamp__moonbit__benchmark__level(level);
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__append__message("assistant", `Running ${_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app25moonbit__benchmark__title(current)}. We will use this to check whether the current LLM router can stay in valid MoonBit before we try harder tasks.`);
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app26run__llm__moonbit__codegen(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app25moonbit__benchmark__title(current), _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app26moonbit__benchmark__prompt(current), "MoonAP received benchmark source from the active router provider and is now starting a real native compile probe automatically.", true);
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app30run__moonbit__fastq__generator() {
  const read_count = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__dialog__param__int("readCount", 10000);
  const read_length = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__dialog__param__int("readLength", 150);
  const seed_value = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__dialog__param__int("seed", 42);
  const n_rate_per_mille = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__dialog__param__int("nRatePerMille", 10);
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__append__message("assistant", "Running MoonBit FastQ Generator. We will ask the active LLM router to generate a MoonBit program, then run a real compile probe and a basic FastQ structure check.");
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app26run__llm__moonbit__codegen("MoonBit FastQ Generator", _M0MPB4Iter4join(_M0MPC15array5Array4iterGsE(["Generate a Personal FastQ Generator in MoonBit.", "Write ONLY cmd/main/main.mbt so that `moon build cmd/main --target wasm-gc` succeeds.", "The program should return a String containing deterministic FastQ records.", "Keep these defaults in the source:", `- read_count = ${_M0MPC13int3Int18to__string_2einner(read_count, 10)}`, `- read_length = ${_M0MPC13int3Int18to__string_2einner(read_length, 10)}`, `- n_rate_per_mille = ${_M0MPC13int3Int18to__string_2einner(n_rate_per_mille, 10)}`, `- seed = ${_M0MPC13int3Int18to__string_2einner(seed_value, 10)}`, "Requirements:", "- generate valid 4-line FastQ records: header, sequence, plus line, quality", "- sequence uses only A, C, G, T, N", "- quality line uses I characters", "- deterministic from the seed", "- no imports", "- keep the code as simple and compact as possible", "Return only the file contents."]), "\n"), "MoonAP received a MoonBit FastQ generator candidate from the active router provider and is now starting a real native compile probe automatically.", true);
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app22execute__dialog__skill() {
  const skill_id = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app26browser__dialog__skill__id();
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app29browser__close__skill__dialog();
  const _bind = "moonbit-benchmark";
  if (_M0MPC16string6String8contains(skill_id, new _M0TPC16string10StringView(_bind, 0, _bind.length))) {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app23run__moonbit__benchmark(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__dialog__param__int("benchmarkLevel", 1));
    return undefined;
  }
  const _bind$2 = "free-llm-eval";
  if (_M0MPC16string6String8contains(skill_id, new _M0TPC16string10StringView(_bind$2, 0, _bind$2.length))) {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app29run__free__llm__moonbit__eval(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__dialog__param__int("evalMaxLevel", 3));
    return undefined;
  }
  const _bind$3 = "moonbit.fastq-generator";
  if (_M0MPC16string6String8contains(skill_id, new _M0TPC16string10StringView(_bind$3, 0, _bind$3.length))) {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app30run__moonbit__fastq__generator();
    return undefined;
  }
  const _bind$4 = "fastq-base-counter";
  if (_M0MPC16string6String8contains(skill_id, new _M0TPC16string10StringView(_bind$4, 0, _bind$4.length))) {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19run__fastq__counter();
    return undefined;
  }
  const _bind$5 = "fastq-generator";
  if (_M0MPC16string6String8contains(skill_id, new _M0TPC16string10StringView(_bind$5, 0, _bind$5.length))) {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21run__fastq__generator();
    return undefined;
  }
  let path;
  const _bind$6 = "finance";
  if (_M0MPC16string6String8contains(skill_id, new _M0TPC16string10StringView(_bind$6, 0, _bind$6.length))) {
    path = "/api/skills/run-plan?finance";
  } else {
    const _bind$7 = "generator";
    if (_M0MPC16string6String8contains(skill_id, new _M0TPC16string10StringView(_bind$7, 0, _bind$7.length))) {
      path = "/api/skills/run-plan?generator";
    } else {
      let _tmp;
      const _bind$8 = "gomoku";
      if (_M0MPC16string6String8contains(skill_id, new _M0TPC16string10StringView(_bind$8, 0, _bind$8.length))) {
        _tmp = true;
      } else {
        const _bind$9 = "game";
        _tmp = _M0MPC16string6String8contains(skill_id, new _M0TPC16string10StringView(_bind$9, 0, _bind$9.length));
      }
      if (_tmp) {
        path = "/api/skills/run-plan?gomoku";
      } else {
        path = skill_id === "personal" ? "/api/personal-skill-set" : "/api/skills/run-plan?fastq";
      }
    }
  }
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app20browser__fetch__text(path, (raw) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__set__state(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json(raw));
  }, (error) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app11show__error("SKILL plan fetch failed", error);
  });
}
function _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app15submit__message() {
  const message = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app23browser__message__value();
  const file_name = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__file__name();
  if (message === "") {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__append__message("assistant", "Please enter a task first.");
    return undefined;
  }
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__append__message("user", message);
  if (!_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app28browser__llm__is__configured()) {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__append__message("assistant", "LLM API is not configured yet. Please save provider, model, and API key first. You can still use SKILL without LLM.");
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app26browser__open__llm__dialog();
    return undefined;
  }
  if (_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app38browser__formal__verification__enabled()) {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__append__message("assistant", "Formal verification is reserved for a future MoonBit 0.9 moon prove step and is not executed yet.");
  }
  let _tmp;
  if (_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app18browser__has__file()) {
    let _tmp$2;
    const _tmp$3 = _M0MPC16string6String9to__lower(message);
    const _bind = "fastq";
    if (_M0MPC16string6String8contains(_tmp$3, new _M0TPC16string10StringView(_bind, 0, _bind.length))) {
      _tmp$2 = true;
    } else {
      const _tmp$4 = _M0MPC16string6String9to__lower(file_name);
      const _bind$2 = ".fq";
      _tmp$2 = _M0MPC16string6String8contains(_tmp$4, new _M0TPC16string10StringView(_bind$2, 0, _bind$2.length));
    }
    _tmp = _tmp$2;
  } else {
    _tmp = false;
  }
  if (_tmp) {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19run__fastq__counter();
    return undefined;
  }
  let _tmp$2;
  const _tmp$3 = _M0MPC16string6String9to__lower(message);
  const _bind = "fastq";
  if (_M0MPC16string6String8contains(_tmp$3, new _M0TPC16string10StringView(_bind, 0, _bind.length))) {
    _tmp$2 = true;
  } else {
    let _tmp$4;
    const _tmp$5 = _M0MPC16string6String9to__lower(message);
    const _bind$2 = "generator";
    if (_M0MPC16string6String8contains(_tmp$5, new _M0TPC16string10StringView(_bind$2, 0, _bind$2.length))) {
      _tmp$4 = true;
    } else {
      let _tmp$6;
      const _tmp$7 = _M0MPC16string6String9to__lower(message);
      const _bind$3 = "synthetic";
      if (_M0MPC16string6String8contains(_tmp$7, new _M0TPC16string10StringView(_bind$3, 0, _bind$3.length))) {
        _tmp$6 = true;
      } else {
        let _tmp$8;
        const _tmp$9 = _M0MPC16string6String9to__lower(message);
        const _bind$4 = "moonbit benchmark";
        if (_M0MPC16string6String8contains(_tmp$9, new _M0TPC16string10StringView(_bind$4, 0, _bind$4.length))) {
          _tmp$8 = true;
        } else {
          let _tmp$10;
          const _tmp$11 = _M0MPC16string6String9to__lower(message);
          const _bind$5 = "moonbit";
          if (_M0MPC16string6String8contains(_tmp$11, new _M0TPC16string10StringView(_bind$5, 0, _bind$5.length))) {
            let _tmp$12;
            const _tmp$13 = _M0MPC16string6String9to__lower(message);
            const _bind$6 = "write";
            if (_M0MPC16string6String8contains(_tmp$13, new _M0TPC16string10StringView(_bind$6, 0, _bind$6.length))) {
              _tmp$12 = true;
            } else {
              let _tmp$14;
              const _tmp$15 = _M0MPC16string6String9to__lower(message);
              const _bind$7 = "generate";
              if (_M0MPC16string6String8contains(_tmp$15, new _M0TPC16string10StringView(_bind$7, 0, _bind$7.length))) {
                _tmp$14 = true;
              } else {
                let _tmp$16;
                const _tmp$17 = _M0MPC16string6String9to__lower(message);
                const _bind$8 = "compile";
                if (_M0MPC16string6String8contains(_tmp$17, new _M0TPC16string10StringView(_bind$8, 0, _bind$8.length))) {
                  _tmp$16 = true;
                } else {
                  const _tmp$18 = _M0MPC16string6String9to__lower(message);
                  const _bind$9 = "benchmark";
                  _tmp$16 = _M0MPC16string6String8contains(_tmp$18, new _M0TPC16string10StringView(_bind$9, 0, _bind$9.length));
                }
                _tmp$14 = _tmp$16;
              }
              _tmp$12 = _tmp$14;
            }
            _tmp$10 = _tmp$12;
          } else {
            _tmp$10 = false;
          }
          _tmp$8 = _tmp$10;
        }
        _tmp$6 = _tmp$8;
      }
      _tmp$4 = _tmp$6;
    }
    _tmp$2 = _tmp$4;
  }
  if (_tmp$2) {
    const _tmp$4 = _M0MPC16string6String9to__lower(message);
    const _bind$2 = "moonbit benchmark";
    if (_M0MPC16string6String8contains(_tmp$4, new _M0TPC16string10StringView(_bind$2, 0, _bind$2.length))) {
      _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app23run__moonbit__benchmark(1);
    } else {
      _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app26run__llm__moonbit__codegen("MoonBit Task", message, "MoonAP received MoonBit source from the active router provider and is now starting a real native compile probe automatically.", false);
    }
    return undefined;
  }
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app20browser__fetch__text(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app13context__path(message, file_name), (raw) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__set__state(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app21browser__pretty__json(raw));
    const skill = _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app28active__skill__from__context(raw);
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__update__process(skill, "context", "ready", "Context normalized by MoonBit frontend and native server.", "");
  }, (error) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app11show__error("context fetch failed", error);
  });
}
(() => {
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app33browser__extract__moonbit__source("");
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app32browser__prepare__message__input("Write the smallest valid cmd/main/main.mbt that compiles under wasm-gc and returns the string hello moonbit. Return only the file contents.");
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19browser__on__submit(() => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app15submit__message();
  });
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app18browser__on__click("#detailsToggle", () => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__toggle__details();
  });
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app18browser__on__click("#llmButton", () => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app16show__llm__entry();
  });
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app18browser__on__click("#skillButton", () => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app18show__skill__entry();
  });
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__on__onboarding__action(() => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app23run__moonbit__benchmark(_M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__next__benchmark__level());
  }, () => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app18show__skill__entry();
  }, () => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app16show__llm__entry();
  }, () => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__open__runtime__log();
  }, () => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__download__runtime__log();
  });
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__on__skill__card__click((skill_id) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app22show__skill__run__plan(skill_id);
  });
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__on__dialog__run(() => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app22execute__dialog__skill();
  });
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__on__dialog__cancel(() => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app29browser__close__skill__dialog();
  });
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app22browser__on__llm__save(() => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app27browser__render__onboarding();
  });
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app24browser__on__llm__cancel(() => {
  });
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app30browser__on__compile__artifact(() => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app19run__compile__probe();
  });
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app29browser__on__repair__artifact(() => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app35run__repair__from__compile__summary();
  });
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app39browser__export__last__artifact__bundle((folder) => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__render__artifact__card("Source bundle exported", `MoonAP exported a browser-downloadable source bundle for ${folder}. This bundle is for the next implementation step; it is not yet a runnable Personal SKILL.`, "[\"exported\",\"source bundle\"]", true, false, false);
  });
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app34browser__on__save__personal__skill(() => {
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app33browser__render__personal__skills();
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app32browser__set__skill__panel__open(true);
    _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app31browser__render__artifact__card("Personal save is not active yet", "MoonAP will enable Personal-SKILL-Set saving after real compile and browser-local runtime execution are implemented.", "[\"pending implementation\"]", false, false, false);
  });
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app33browser__render__personal__skills();
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app38browser__restore__formal__verification();
  _M0FP412tangmaomao1618moonap__mb__server3cmd8web__app17refresh__policies();
})();
//# sourceMappingURL=web_app.js.map
