///|
async fn main {
  println("MoonAP native MoonBit server starting at http://127.0.0.1:3000")
  let server = @http.Server::new(@socket.Addr::parse("127.0.0.1:3000"))
  server.run_forever((request, body, conn) => moonap_server(request, body, conn))
}

///|
async fn moonap_server(
  request : @http.Request,
  body : &@io.Reader,
  conn : @http.ServerConnection,
) -> Unit {
  let path = request.path
  if request.meth == Get && (path == "/" || path == "/index.html") {
    send_html(conn, web_index_html())
  } else if request.meth == Get &&
    (path.contains("/app.js") || path.contains("/app-live.js")) &&
    !path.contains(".map") {
    serve_static_file(
      conn,
      if path.contains("/app-live.js") {
        "web/app-live.js"
      } else {
        "web/app.js"
      },
      "application/javascript; charset=utf-8",
    )
  } else if request.meth == Get &&
    (path.contains("/app.js.map") || path.contains("/app-live.js.map")) {
    serve_static_file(
      conn,
      if path.contains("/app-live.js.map") {
        "web/app-live.js.map"
      } else {
        "web/app.js.map"
      },
      "application/json; charset=utf-8",
    )
  } else if request.meth == Get && path == "/style.css" {
    send_css(conn, web_style_css())
  } else if request.meth == Get && path == "/api/health" {
    send_json(conn, 200, @core.health_json())
  } else if request.meth == Get && path == "/api/policies" {
    send_json(conn, 200, @core.policies_json())
  } else if request.meth == Get && path == "/api/formal-verification" {
    send_json(conn, 200, @core.formal_verification_policy_json())
  } else if request.meth == Get && path == "/api/large-file-policy" {
    send_json(conn, 200, @core.large_file_policy_json())
  } else if request.meth == Get && path == "/api/app-state" {
    send_json(conn, 200, @core.app_state_json())
  } else if request.meth == Get && path == "/api/skills" {
    send_json(conn, 200, @core.builtin_skill_hub_json())
  } else if request.meth == Get && path == "/api/personal-skill-set" {
    send_json(conn, 200, @core.personal_skill_set_json())
  } else if request.meth == Get &&
    path == "/api/experiments/free-llm-moonbit/results.json" {
    send_text(
      conn,
      200,
      read_text_or_default(
        "artifacts/moonbit-eval-results.json", "{\n  \"experiment_name\": \"Free LLM models ability of generating MoonBit code\",\n  \"status\": \"draft\"\n}\n",
      ),
      "application/json; charset=utf-8",
    )
  } else if request.meth == Get &&
    path == "/api/experiments/free-llm-moonbit/results.md" {
    send_text(
      conn,
      200,
      read_text_or_default(
        "docs/experiments/free-llm-moonbit/results.md", "# Free LLM models ability of generating MoonBit code\n\nNo experiment results recorded yet.\n",
      ),
      "text/markdown; charset=utf-8",
    )
  } else if request.meth == Get && path == "/api/logs/moonap-runtime.log" {
    send_text(
      conn,
      200,
      read_text_or_default(
        "logs/moonap-runtime.log", "MoonAP runtime log is empty.\n",
      ),
      "text/plain; charset=utf-8",
    )
  } else if request.meth == Get && path.contains("/api/skills/run-plan") {
    let skill_hint = if path.contains("finance") || path.contains("excel") {
      "finance excel"
    } else if path.contains("generator") || path.contains("synthetic") {
      "fastq generator"
    } else if path.contains("gomoku") || path.contains("game") {
      "gomoku game"
    } else {
      "fastq"
    }
    send_json(conn, 200, @core.skill_run_plan_json(skill_hint))
  } else if request.meth == Get && path.contains("/api/agent/context") {
    let user_input = if path.contains("game") {
      "make a browser game"
    } else if path.contains("csv") {
      "analyze csv"
    } else if path.contains("xlsx") || path.contains("excel") {
      "analyze excel"
    } else if path.contains("json") {
      "inspect json"
    } else if path.contains("fastq") || path.contains("fq") {
      "count N bases in FastQ"
    } else {
      "chat"
    }
    let detected_type = if path.contains("fastq") || path.contains("fq") {
      "fastq"
    } else if path.contains("csv") {
      "csv"
    } else if path.contains("xlsx") || path.contains("excel") {
      "xlsx"
    } else if path.contains("json") {
      "json"
    } else {
      ""
    }
    send_json(
      conn,
      200,
      @core.normalize_agent_context_json(
        "native-demo", user_input, "moonbit-task", detected_type, 0, detected_type,
        "2026-04-15T00:00:00Z",
      ),
    )
  } else if request.meth == Get &&
    (path.contains("/api/agent/route") || path.contains("/api/prompt/build")) {
    send_json(conn, 200, @core.route_agent_json(path, ""))
  } else if request.meth == Post && path.contains("/api/artifact/compile") {
    let source = body.read_all().text()
    send_json(
      conn,
      200,
      @core.artifact_compile_probe_json(
        source,
        formal_verification=path.contains("formal=1"),
      ),
    )
  } else if request.meth == Post && path == "/api/llm/proxy" {
    let spec = body.read_all().text()
    let (status, payload) = proxy_llm_post(spec)
    send_text(conn, status, payload, "application/json; charset=utf-8")
  } else if request.meth == Post &&
    path == "/api/experiments/free-llm-moonbit/results.json" {
    let payload = body.read_all().text()
    persist_experiment_text(
      conn, "artifacts", "artifacts/moonbit-eval-results.json", payload, "application/json; charset=utf-8",
    )
  } else if request.meth == Post &&
    path == "/api/experiments/free-llm-moonbit/results.md" {
    let payload = body.read_all().text()
    persist_experiment_text(
      conn, "docs/experiments/free-llm-moonbit", "docs/experiments/free-llm-moonbit/results.md",
      payload, "text/markdown; charset=utf-8",
    )
  } else if request.meth == Post && path == "/api/logs/moonap-runtime.log" {
    let payload = body.read_all().text()
    append_runtime_log(
      conn, "logs", "logs/moonap-runtime.log", payload, "text/plain; charset=utf-8",
    )
  } else {
    send_text(
      conn,
      if request.meth == Get || request.meth == Post {
        404
      } else {
        405
      },
      if request.meth == Get || request.meth == Post {
        "Not Found"
      } else {
        "Method Not Allowed"
      },
      "text/plain; charset=utf-8",
    )
  }
}

///|
async fn read_text_or_default(path : String, fallback : String) -> String {
  if @fs.exists(path) {
    @fs.read_file(path).text()
  } else {
    fallback
  }
}

///|
async fn persist_experiment_text(
  conn : @http.ServerConnection,
  directory : String,
  path : String,
  payload : String,
  content_type : String,
) -> Unit {
  if directory != "" && !@fs.exists(directory) {
    @fs.mkdir(directory, recursive=true, permission=0o755)
  }
  @fs.write_file(path, payload, create=0o644)
  send_text(conn, 200, payload, content_type)
}

///|
async fn append_runtime_log(
  conn : @http.ServerConnection,
  directory : String,
  path : String,
  payload : String,
  content_type : String,
) -> Unit {
  if directory != "" && !@fs.exists(directory) {
    @fs.mkdir(directory, recursive=true, permission=0o755)
  }
  let existing = if @fs.exists(path) { @fs.read_file(path).text() } else { "" }
  let next = existing + payload
  @fs.write_file(path, next, create=0o644)
  send_text(conn, 200, payload, content_type)
}

///|
async fn proxy_llm_post(spec : String) -> (Int, String) {
  let normalized = spec.replace_all(old="\r\n", new="\n")
  guard normalized.find("\nBODY\n") is Some(body_sep) else {
    return proxy_error_payload(
      400, "Invalid LLM proxy payload: missing BODY separator.", "", "proxy-parse",
    )
  }
  let meta = normalized[:body_sep].to_string()
  let body = normalized[body_sep + 6:].to_string()
  let mut url = ""
  let headers : Map[String, String] = {}
  for line in meta.split("\n") {
    if line.has_prefix("URL\t") {
      url = line[4:].to_string()
    } else if line.has_prefix("HEADER\t") {
      let header_spec = line[7:].to_string()
      guard header_spec.find("\t") is Some(sep) else { continue }
      let name = header_spec[:sep].to_string()
      let value = header_spec[sep + 1:].to_string()
      if name != "" {
        headers[name] = value
      }
    }
  }
  guard url != "" else {
    return proxy_error_payload(
      400, "Invalid LLM proxy payload: missing target URL.", "", "proxy-parse",
    )
  }
  try {
    let (response, response_body) = @http.post(url, body, headers~)
    (response.code, response_body.text())
  } catch {
    err =>
      proxy_error_payload(
        502,
        "MoonAP local LLM proxy failed before provider response.",
        url,
        err.to_string(),
      )
  }
}

///|
fn proxy_error_payload(
  status : Int,
  message : String,
  url : String,
  detail : String,
) -> (Int, String) {
  (
    status,
    "{\"error\":{\"message\":" +
    json_string(message) +
    ",\"url\":" +
    json_string(url) +
    ",\"detail\":" +
    json_string(detail) +
    "}}",
  )
}

///|
fn json_string(value : String) -> String {
  "\"" +
  value
  .replace_all(old="\\", new="\\\\")
  .replace_all(old="\"", new="\\\"")
  .replace_all(old="\r", new="\\r")
  .replace_all(old="\n", new="\\n")
  .replace_all(old="\t", new="\\t") +
  "\""
}

///|
async fn send_json(
  conn : @http.ServerConnection,
  status : Int,
  body : String,
) -> Unit {
  send_text(conn, status, body, "application/json; charset=utf-8")
}

///|
async fn send_html(conn : @http.ServerConnection, body : String) -> Unit {
  send_text(conn, 200, body, "text/html; charset=utf-8")
}

///|
async fn send_css(conn : @http.ServerConnection, body : String) -> Unit {
  send_text(conn, 200, body, "text/css; charset=utf-8")
}

///|
async fn serve_static_file(
  conn : @http.ServerConnection,
  file_path : String,
  content_type : String,
) -> Unit {
  guard @fs.exists(file_path) else {
    send_text(conn, 404, "Not Found", "text/plain; charset=utf-8")
    return
  }
  let file = @fs.open(file_path, mode=ReadOnly)
  defer file.close()
  conn
  ..send_response(200, "OK", extra_headers={
    "Content-Type": content_type,
    "Access-Control-Allow-Origin": "*",
    "Cache-Control": "no-store, max-age=0",
  })
  ..write_reader(file)
  .end_response()
}

///|
async fn send_text(
  conn : @http.ServerConnection,
  status : Int,
  body : String,
  content_type : String,
) -> Unit {
  conn
  ..send_response(status, "OK", extra_headers={
    "Content-Type": content_type,
    "Access-Control-Allow-Origin": "*",
    "Cache-Control": "no-store, max-age=0",
  })
  ..write(body)
  .end_response()
}

///|
fn web_index_html() -> String {
  [
    "<!doctype html>", "<html lang=\"en\">", "<head>", "<meta charset=\"utf-8\" />",
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />",
    "<title>MoonAP</title>", "<link rel=\"stylesheet\" href=\"/style.css\" />", "</head>",
    "<body>", "<div class=\"app-shell\">", "<main class=\"chat-shell\">", "<header class=\"topbar\">",
    "<div class=\"topbar-main\">", "<p class=\"tagline topbar-tagline\">MoonAP: MoonBit Agent Playground. Set LLM API and chat, or use SKILL.</p>",
    "<div class=\"entry-actions topbar-actions\">", "<button id=\"llmButton\" class=\"entry-button primary\" type=\"button\">LLM</button>",
    "<button id=\"skillButton\" class=\"entry-button\" type=\"button\">SKILL</button>",
    "</div>", "</div>", "<div class=\"top-actions\">", "<button id=\"detailsToggle\" class=\"details-button\" type=\"button\" aria-expanded=\"false\">Details</button>",
    "</div>", "</header>", "<section class=\"conversation\" aria-label=\"Chat conversation\">",
    "<div class=\"welcome\">", "<label class=\"verify-option\"><input id=\"formalVerification\" type=\"checkbox\" /> Formal verification before Wasm compile</label>",
    "<div class=\"privacy-strip\" id=\"privacyStrip\">File contents stay in this browser. Uploaded bytes: 0. LLM receives metadata only.</div>",
    "<section id=\"onboardingCard\" class=\"onboarding-card\"></section>", "<div id=\"modePanel\" class=\"mode-panel\">",
    "<div class=\"skill-section\">", "<div class=\"section-title\"><span>1.1</span><strong>Personal-SKILL-Set</strong></div>",
    "<div id=\"personalSkillCards\" class=\"personal-skill-cards\"></div>", "</div>",
    "<div class=\"skill-section hub-section\">", "<div class=\"section-title\"><span>1.2</span><strong>SKILL-Hub</strong></div>",
    "<div class=\"hub-grid\">", "<button class=\"skill-card\" data-skill-id=\"research.bioinformatics.fastq-base-counter\" type=\"button\"><span>Research / FastQ</span><strong>FastQ Base Counter</strong><small>Default: count N bases. Browser-local 4MB chunks.</small></button>",
    "<button class=\"skill-card\" data-skill-id=\"research.bioinformatics.fastq-generator\" type=\"button\"><span>Research / Synthetic</span><strong>FastQ Generator</strong><small>LLM writes a compact recipe; MoonAP writes the bytes locally.</small></button>",
    "<button class=\"skill-card\" data-skill-id=\"research.moonbit.benchmark-ladder\" type=\"button\"><span>MoonBit / LLM</span><strong>Benchmark Ladder</strong><small>Start at L1 and climb to L5 to see when the router stops producing valid MoonBit.</small></button>",
    "<button class=\"skill-card\" data-skill-id=\"research.moonbit.fastq-generator\" type=\"button\"><span>MoonBit / LLM</span><strong>MoonBit FastQ Generator</strong><small>Ask the active LLM route to generate a MoonBit FastQ generator program and run a real compile probe.</small></button>",
    "<button class=\"skill-card\" data-skill-id=\"research.moonbit.free-llm-eval\" type=\"button\"><span>Experiments / MoonBit</span><strong>Free LLM MoonBit Eval</strong><small>Batch-test enabled free models on L1-L3 and persist JSON plus markdown notes.</small></button>",
    "<button class=\"skill-card\" data-skill-id=\"finance.accounting.excel-max-amount-row\" type=\"button\"><span>Finance / Spreadsheet</span><strong>Excel Max Amount Row</strong><small>Default: extract row with maximum amount column.</small></button>",
    "<button class=\"skill-card\" data-skill-id=\"games.board-games.gomoku\" type=\"button\"><span>Games / Board</span><strong>Gomoku</strong><small>Default: single player, 15x15 board.</small></button>",
    "</div>", "</div>", "</div>", "<section id=\"resultPanel\" class=\"result-panel\" aria-live=\"polite\">",
    "<div class=\"result-head\"><span id=\"resultStatus\">Ready</span><strong id=\"resultTitle\">Browser-local FastQ workflow</strong></div>",
    "<div class=\"progress-track\"><div id=\"progressFill\" class=\"progress-fill\"></div></div>",
    "<div class=\"metrics-grid\">", "<div><span>File</span><strong id=\"metricFile\">-</strong></div>",
    "<div><span>Processed</span><strong id=\"metricProcessed\">0 B</strong></div>",
    "<div><span>Reads</span><strong id=\"metricReads\">0</strong></div>", "<div><span>N bases</span><strong id=\"metricTarget\">0</strong></div>",
    "<div><span>Total bases</span><strong id=\"metricBases\">0</strong></div>", "<div><span>Uploaded</span><strong id=\"metricUploaded\">0 B</strong></div>",
    "</div>", "</section>", "</div>", "<div id=\"messages\" class=\"messages\" aria-live=\"polite\"></div>",
    "<div id=\"artifactActions\" class=\"artifact-actions\" aria-live=\"polite\"></div>",
    "<dialog id=\"skillDialog\" class=\"skill-dialog\">", "<form method=\"dialog\" class=\"skill-dialog-body\">",
    "<div class=\"dialog-head\"><span id=\"dialogScope\">SKILL</span><strong id=\"dialogTitle\">Configure SKILL</strong></div>",
    "<p id=\"dialogSummary\" class=\"dialog-summary\"></p>", "<div id=\"dialogFields\" class=\"dialog-fields\"></div>",
    "<div class=\"dialog-actions\"><button id=\"dialogCancel\" class=\"dialog-button\" type=\"button\">Cancel</button><button id=\"dialogRun\" class=\"dialog-button primary\" type=\"button\">Run</button></div>",
    "</form>", "</dialog>", "<dialog id=\"llmDialog\" class=\"skill-dialog\">", "<form method=\"dialog\" class=\"skill-dialog-body\">",
    "<div class=\"dialog-head\"><span>LLM Router</span><strong>Connect one or more providers</strong></div>",
    "<p class=\"dialog-summary\">MoonAP stores these keys in this browser only. Level 1 selects providers. Level 2 selects models inside each provider. MoonAP rotates through the checked models from top to bottom.</p>",
    "<div class=\"router-grid\">", "<div class=\"router-row\"><div class=\"router-row-head\"><span class=\"router-level\">Level 1</span><input id=\"routerEnableNVIDIA\" type=\"checkbox\" checked /><strong>NVIDIA</strong></div><div class=\"router-level-label\">Level 2 - Models</div><div id=\"routerModelsNVIDIA\" class=\"router-model-list\"></div><label>Base URL<input id=\"routerBaseNVIDIA\" value=\"https://integrate.api.nvidia.com/v1\" /></label><label>API key<input id=\"routerKeyNVIDIA\" type=\"password\" placeholder=\"Paste NVIDIA API key\" /></label></div>",
    "<div class=\"router-row\"><div class=\"router-row-head\"><span class=\"router-level\">Level 1</span><input id=\"routerEnableZAI\" type=\"checkbox\" checked /><strong>ZAI</strong></div><div class=\"router-level-label\">Level 2 - Models</div><div id=\"routerModelsZAI\" class=\"router-model-list\"></div><label>Base URL<input id=\"routerBaseZAI\" value=\"https://open.bigmodel.cn/api/paas/v4\" /></label><label>API key<input id=\"routerKeyZAI\" type=\"password\" placeholder=\"Paste ZAI API key\" /></label></div>",
    "<div class=\"router-row\"><div class=\"router-row-head\"><span class=\"router-level\">Level 1</span><input id=\"routerEnableGemini\" type=\"checkbox\" /><strong>Gemini</strong></div><div class=\"router-level-label\">Level 2 - Models</div><div id=\"routerModelsGemini\" class=\"router-model-list\"></div><label>Base URL<input id=\"routerBaseGemini\" value=\"https://generativelanguage.googleapis.com\" /></label><label>API key<input id=\"routerKeyGemini\" type=\"password\" placeholder=\"Paste Gemini API key\" /></label></div>",
    "<div class=\"router-row\"><div class=\"router-row-head\"><span class=\"router-level\">Level 1</span><input id=\"routerEnableSiliconFlow\" type=\"checkbox\" /><strong>SiliconFlow</strong></div><div class=\"router-level-label\">Level 2 - Models</div><div id=\"routerModelsSiliconFlow\" class=\"router-model-list\"></div><label>Base URL<input id=\"routerBaseSiliconFlow\" value=\"https://api.siliconflow.cn/v1\" /></label><label>API key<input id=\"routerKeySiliconFlow\" type=\"password\" placeholder=\"Paste SiliconFlow API key\" /></label></div>",
    "<div class=\"router-row\"><div class=\"router-row-head\"><span class=\"router-level\">Level 1</span><input id=\"routerEnableOpenRouter\" type=\"checkbox\" /><strong>OpenRouter</strong></div><div class=\"router-level-label\">Level 2 - Models</div><div id=\"routerModelsOpenRouter\" class=\"router-model-list\"></div><label>Base URL<input id=\"routerBaseOpenRouter\" value=\"https://openrouter.ai/api/v1\" /></label><label>API key<input id=\"routerKeyOpenRouter\" type=\"password\" placeholder=\"Paste OpenRouter API key\" /></label></div>",
    "</div>", "<label class=\"dialog-toggle\"><input id=\"routerFormalVerification\" type=\"checkbox\" /> Reserve MoonBit formal verification before Wasm compile</label>",
    "<label class=\"dialog-toggle\"><input id=\"routerRepairUseRawCompilerOutput\" type=\"checkbox\" checked /> Feed native compiler output into repair rounds</label>",
    "<div id=\"routerTestStatus\" class=\"router-test-status\">No API test run yet.</div>",
    "<div class=\"dialog-actions\"><button id=\"llmCancel\" class=\"dialog-button\" type=\"button\">Cancel</button><button id=\"llmSave\" class=\"dialog-button primary\" type=\"button\">Save</button></div>",
    "</form>", "</dialog>", "</section>", "<form id=\"chatForm\" class=\"composer\">",
    "<label class=\"sr-only\" for=\"message\">Message</label>", "<div class=\"composer-box\">",
    "<label class=\"attach-button\" for=\"fileInput\" title=\"Attach file\">+</label>",
    "<input id=\"fileInput\" type=\"file\" />", "<textarea id=\"message\" rows=\"1\" placeholder=\"\"></textarea>",
    "<button class=\"send-button\" type=\"submit\" title=\"Send\">&gt;</button>",
    "</div>", "</form>", "</main>", "<aside id=\"detailsDrawer\" class=\"details-drawer\" aria-label=\"MoonAP details\">",
    "<div class=\"details-drawer-body\">", "<section class=\"details-section details-state-section\"><strong>State</strong><pre id=\"state\">{}</pre></section>",
    "<section class=\"details-section details-process-section\"><strong>Process</strong>",
    "<div class=\"details-process-grid\">", "<div><span>Provider</span><strong id=\"processProvider\">-</strong></div>",
    "<div><span>Stage</span><strong id=\"processStage\">-</strong></div>", "<div><span>Result</span><strong id=\"processResult\">waiting</strong></div>",
    "</div>", "<div class=\"details-log\"><span>Last event</span><pre id=\"processLog\">MoonAP is waiting for input.</pre></div>",
    "<div class=\"details-log\"><span>LLM prompt mode</span><pre id=\"promptMode\">No LLM prompt captured yet.</pre></div>",
    "<div class=\"details-log\"><span>LLM system prompt</span><pre id=\"promptSystem\">No LLM prompt captured yet.</pre></div>",
    "<div class=\"details-log\"><span>LLM user prompt</span><pre id=\"promptUser\">No LLM prompt captured yet.</pre></div>",
    "<div class=\"details-log\"><span>MoonBit code preview</span><pre id=\"processSource\">No generated source yet.</pre></div>",
    "</section>", "</div>", "</aside>", "</div>", "<script type=\"module\" src=\"/app-live.js?v=moonap-llm-router-34\"></script>",
    "</body>", "</html>",
  ]
  .iter()
  .join("\n")
}

///|
fn web_style_css() -> String {
  [
    ":root { color-scheme: light; font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, \"Segoe UI\", sans-serif; background: #ffffff; color: #111111; }",
    "* { box-sizing: border-box; }", "body { margin: 0; min-height: 100vh; background: #ffffff; }",
    "button, textarea { font: inherit; }", "button, label[for], .skill-card { cursor: pointer; }",
    ".app-shell { --details-space: 0px; min-height: 100vh; }", ".app-shell.details-open { --details-space: 420px; }",
    ".chat-shell { min-width: 0; min-height: 100vh; display: grid; grid-template-rows: 74px minmax(0, 1fr) auto; }",
    ".topbar { position: sticky; top: 0; z-index: 20; display: flex; align-items: center; justify-content: space-between; gap: 24px; padding: 0 calc(48px + var(--details-space)) 0 48px; background: rgba(255,255,255,0.92); backdrop-filter: blur(10px); border-bottom: 1px solid rgba(238,238,238,0.9); transition: padding-right 160ms ease; }",
    ".topbar-main { min-width: 0; display: flex; align-items: center; gap: 20px; flex-wrap: wrap; }",
    ".topbar-tagline { margin: 0; color: #5f5f5f; font-size: 15px; line-height: 1.45; }",
    ".topbar-actions { justify-content: flex-start; }", ".top-actions { position: relative; z-index: 30; flex: 0 0 auto; }",
    ".details-button { border: 1px solid #dedede; border-radius: 999px; padding: 8px 14px; color: #555555; background: #ffffff; cursor: pointer; user-select: none; }",
    ".details-button:hover { background: #f5f5f5; }", ".details-drawer { position: fixed; right: 0; top: 0; bottom: 0; z-index: 15; width: min(420px, calc(100vw - 48px)); overflow: auto; padding: 88px 16px 16px; border-left: 1px solid #e6e6e6; background: #ffffff; box-shadow: -10px 0 30px rgba(0,0,0,0.08); transform: translateX(100%); transition: transform 160ms ease; }",
    ".app-shell.details-open .details-drawer { transform: translateX(0); }", ".details-drawer-body { min-height: calc(100vh - 104px); display: grid; grid-auto-rows: min-content; gap: 16px; }",
    ".details-section { display: grid; gap: 10px; align-content: start; }", ".details-section strong { font-size: 14px; }",
    ".details-state-section { min-height: 0; }", ".details-process-section { min-height: 0; }",
    ".details-process-grid { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 10px; }",
    ".details-process-grid div { display: grid; gap: 4px; padding: 10px; border-radius: 10px; background: #f7f7f7; }",
    ".details-process-grid span { color: #666666; font-size: 12px; }", ".details-process-grid strong { font-size: 14px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }",
    ".details-log { display: grid; gap: 6px; }", ".details-log span { color: #666666; font-size: 12px; }",
    "#state { margin: 0; min-height: 260px; height: min(42vh, 420px); overflow: auto; padding: 12px; border-radius: 12px; background: #0d1113; color: #d7f7e8; font-size: 12px; line-height: 1.5; white-space: pre-wrap; }",
    ".details-log pre { margin: 0; min-height: 150px; height: min(24vh, 240px); overflow: auto; padding: 12px; border-radius: 12px; background: #0d1113; color: #d7f7e8; font-size: 12px; line-height: 1.5; white-space: pre-wrap; }",
    ".conversation { min-height: 0; overflow: auto; padding: 28px calc(24px + var(--details-space)) 140px 24px; transition: padding-right 160ms ease; }",
    ".welcome { width: min(920px, calc(100vw - 48px - var(--details-space))); margin: 0 auto; display: grid; justify-items: stretch; align-content: start; gap: 18px; min-height: 160px; transition: width 160ms ease; }",
    ".tagline { margin: 0; color: #5f5f5f; font-size: 15px; text-align: center; line-height: 1.45; }",
    ".entry-actions { display: flex; gap: 12px; flex-wrap: wrap; justify-content: center; }",
    ".entry-button { min-width: 110px; height: 42px; border: 1px solid #d8d8d8; border-radius: 999px; background: #ffffff; color: #111111; font-weight: 650; }",
    ".entry-button.primary { background: #111111; color: #ffffff; border-color: #111111; }",
    ".entry-button:hover { background: #f4f4f4; }", ".entry-button.primary:hover { background: #2a2a2a; }",
    ".verify-option { display: none; align-items: center; justify-content: center; gap: 8px; color: #6a6a6a; font-size: 13px; }",
    ".onboarding-card { max-width: 720px; margin: 0 auto; display: none; gap: 12px; padding: 16px; border: 1px solid #dfe7e3; border-radius: 14px; background: #f7fbf9; }",
    ".onboarding-card.is-open { display: grid; }", ".onboarding-card strong { font-size: 15px; }",
    ".onboarding-card small { color: #555555; line-height: 1.5; }", ".onboarding-actions { display: flex; flex-wrap: wrap; gap: 10px; }",
    ".onboarding-actions button { height: 38px; border: 1px solid #111111; border-radius: 999px; padding: 0 16px; background: #111111; color: #ffffff; cursor: pointer; }",
    ".onboarding-actions button.secondary { border-color: #d8d8d8; background: #ffffff; color: #111111; }",
    ".verify-option input { width: 14px; height: 14px; accent-color: #111111; }",
    ".privacy-strip { display: none; width: 100%; padding: 10px 12px; border: 1px solid #cde4da; border-radius: 12px; background: #f7fbf9; color: #225c46; font-size: 13px; text-align: center; }",
    ".privacy-strip.is-open { display: block; }", ".mode-panel { width: 100%; display: none; gap: 12px; margin-top: 8px; }",
    ".mode-panel.is-open { display: grid; }", ".skill-section { display: grid; gap: 10px; padding: 12px; border: 1px solid #e8e8e8; border-radius: 14px; background: #ffffff; }",
    ".skill-section:first-child { border-color: #cfe2d9; background: #fbfdfc; }",
    ".hub-section { border-color: #e8e8e8; background: #ffffff; }", ".section-title { display: flex; align-items: center; gap: 8px; color: #111111; flex-wrap: wrap; }",
    ".section-title span { color: #666666; font-size: 12px; }", ".section-title strong { font-size: 15px; }",
    ".hub-grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 10px; }",
    ".skill-card { min-height: 118px; display: grid; align-content: start; gap: 8px; padding: 14px; border: 1px solid #e2e2e2; border-radius: 12px; background: #ffffff; text-align: left; transition: border-color 120ms ease, box-shadow 120ms ease, transform 120ms ease; }",
    ".skill-card:hover { border-color: #111111; box-shadow: 0 10px 28px rgba(0,0,0,0.08); transform: translateY(-1px); }",
    ".skill-card:focus-visible, .entry-button:focus-visible, .send-button:focus-visible, .attach-button:focus-visible { outline: 2px solid #111111; outline-offset: 3px; }",
    ".skill-card.is-selected { border-color: #1f7a5b; background: #f7fbf9; box-shadow: 0 12px 30px rgba(31,122,91,0.12); }",
    ".skill-card span { color: #6b6b6b; font-size: 12px; }", ".skill-card strong { font-size: 15px; line-height: 1.25; }",
    ".skill-card small { color: #555555; font-size: 12px; line-height: 1.4; }", ".skill-card.personal { border-color: #cde4da; background: #f7fbf9; }",
    ".personal-skill-cards { display: grid; gap: 10px; }", ".personal-skill-empty { padding: 14px; border: 1px dashed #d7dfdb; border-radius: 12px; color: #5d5d5d; background: #fcfcfc; }",
    ".artifact-actions { width: min(920px, calc(100vw - 48px - var(--details-space))); margin: 0 auto; display: grid; gap: 14px; transition: width 160ms ease; }",
    ".action-card { display: none; gap: 12px; max-width: 720px; padding: 16px; border: 1px solid #dfe7e3; border-radius: 14px; background: #f7fbf9; }",
    ".action-card.is-open { display: grid; }", ".action-card strong { font-size: 15px; }",
    ".action-card small { color: #555555; line-height: 1.45; }", ".action-card-meta { display: flex; flex-wrap: wrap; gap: 8px; }",
    ".action-card-meta span { border-radius: 999px; padding: 5px 10px; background: #eef5f1; color: #24523f; font-size: 12px; }",
    ".action-card-actions { display: flex; flex-wrap: wrap; gap: 10px; }", ".action-card button { justify-self: start; height: 38px; border: 1px solid #111111; border-radius: 999px; padding: 0 16px; background: #111111; color: #ffffff; cursor: pointer; }",
    ".action-card button.secondary { border-color: #d8d8d8; background: #ffffff; color: #111111; }",
    ".result-panel { width: 100%; display: none; gap: 12px; padding: 16px; border: 1px solid #e0e0e0; border-radius: 14px; background: #ffffff; box-shadow: 0 12px 36px rgba(0,0,0,0.06); }",
    ".result-panel.is-open { display: grid; }", ".result-head { display: flex; align-items: center; justify-content: space-between; gap: 12px; }",
    ".result-head span { border-radius: 999px; background: #111111; color: #ffffff; padding: 5px 10px; font-size: 12px; }",
    ".result-head strong { font-size: 15px; }", ".progress-track { height: 8px; border-radius: 999px; overflow: hidden; background: #eeeeee; }",
    ".progress-fill { width: 0%; height: 100%; border-radius: inherit; background: #1f7a5b; transition: width 160ms ease; }",
    ".metrics-grid { display: grid; grid-template-columns: repeat(6, minmax(0, 1fr)); gap: 10px; }",
    ".metrics-grid div { min-width: 0; display: grid; gap: 4px; padding: 10px; border-radius: 10px; background: #f7f7f7; }",
    ".metrics-grid span { color: #666666; font-size: 12px; }", ".metrics-grid strong { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-size: 14px; }",
    ".skill-dialog { width: min(560px, calc(100vw - 40px)); border: 1px solid #dedede; border-radius: 16px; padding: 0; box-shadow: 0 24px 80px rgba(0,0,0,0.22); }",
    ".skill-dialog::backdrop { background: rgba(0,0,0,0.18); }", ".skill-dialog-body { display: grid; gap: 16px; padding: 20px; }",
    ".dialog-head { display: grid; gap: 4px; }", ".dialog-head span { color: #666666; font-size: 12px; }",
    ".dialog-head strong { font-size: 20px; }", ".dialog-summary { margin: 0; color: #444444; line-height: 1.5; }",
    ".router-grid { display: grid; gap: 12px; }", ".router-row { display: grid; gap: 10px; padding: 12px; border: 1px solid #e5e5e5; border-radius: 12px; background: #fafafa; }",
    ".router-row-head { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }",
    ".router-row-head strong { font-size: 15px; }", ".router-level { display: inline-flex; align-items: center; justify-content: center; min-width: 54px; height: 22px; padding: 0 8px; border-radius: 999px; background: #111111; color: #ffffff; font-size: 11px; font-weight: 650; }",
    ".router-level-label { color: #555555; font-size: 13px; font-weight: 600; }",
    ".dialog-fields { display: grid; gap: 10px; }", ".dialog-fields label, .router-row label { display: grid; gap: 6px; color: #555555; font-size: 13px; }",
    ".dialog-fields input, .router-row input { width: 100%; border: 1px solid #d8d8d8; border-radius: 10px; padding: 8px 10px; font: inherit; }",
    ".dialog-fields input, .router-row input { height: 38px; }", ".router-model-list { display: grid; gap: 8px; max-height: 180px; overflow: auto; padding: 12px; border: 1px solid #d8d8d8; border-radius: 10px; background: #ffffff; }",
    ".router-model-option { display: flex; align-items: flex-start; gap: 10px; padding: 8px 10px; border-radius: 10px; background: #fafafa; }",
    ".router-model-option input { width: 16px; height: 16px; margin-top: 2px; border: 0; border-radius: 0; padding: 0; background: transparent; accent-color: #111111; }",
    ".router-model-option span { color: #222222; font-size: 13px; line-height: 1.4; overflow-wrap: anywhere; }",
    ".dialog-toggle { display: flex; align-items: center; gap: 8px; color: #555555; font-size: 13px; }",
    ".dialog-toggle input { width: 14px; height: 14px; accent-color: #111111; }",
    ".router-test-status { min-height: 88px; max-height: 180px; overflow: auto; white-space: pre-wrap; padding: 12px; border: 1px solid #e5e5e5; border-radius: 12px; background: #fafafa; color: #222222; font-size: 12px; line-height: 1.5; }",
    ".dialog-actions { display: flex; justify-content: flex-end; gap: 10px; }", ".dialog-button { height: 38px; border: 1px solid #d8d8d8; border-radius: 999px; padding: 0 16px; background: #ffffff; }",
    ".dialog-button.primary { border-color: #111111; background: #111111; color: #ffffff; }",
    ".dialog-button:hover { background: #f3f3f3; }", ".dialog-button.primary:hover { background: #2a2a2a; }",
    ".messages { width: min(920px, calc(100vw - 48px - var(--details-space))); margin: 0 auto; display: grid; gap: 18px; transition: width 160ms ease; }",
    ".message { max-width: 720px; padding: 16px 18px; border-radius: 18px; line-height: 1.55; white-space: pre-wrap; overflow-wrap: anywhere; }",
    ".message.user { justify-self: end; background: #f4f4f4; color: #111111; }",
    ".message.assistant { justify-self: start; background: transparent; color: #111111; }",
    ".composer { position: sticky; bottom: 0; padding: 18px calc(24px + var(--details-space)) 28px 24px; background: linear-gradient(to top, #ffffff 70%, rgba(255,255,255,0)); transition: padding-right 160ms ease; }",
    ".composer-box { width: min(920px, calc(100vw - 48px - var(--details-space))); min-height: 64px; margin: 0 auto; display: grid; grid-template-columns: 44px minmax(0, 1fr) 44px; align-items: end; gap: 10px; padding: 10px 12px; border: 1px solid #d8d8d8; border-radius: 30px; background: #ffffff; box-shadow: 0 18px 50px rgba(0,0,0,0.08); transition: width 160ms ease; }",
    ".attach-button, .send-button { width: 40px; height: 40px; display: grid; place-items: center; border-radius: 50%; border: 0; font-size: 28px; line-height: 1; }",
    ".attach-button { color: #111111; background: transparent; }", ".attach-button:hover { background: #f2f2f2; }",
    ".send-button { background: #111111; color: white; font-size: 22px; }", "#fileInput { display: none; }",
    "textarea { width: 100%; max-height: 180px; resize: none; border: 0; outline: 0; padding: 11px 0; color: #111111; background: transparent; line-height: 1.45; }",
    "textarea.suggested { color: #8a8a8a; }", "textarea::placeholder { color: #8a8a8a; }",
    ".sr-only { position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0,0,0,0); white-space: nowrap; border: 0; }",
    "@media (max-width: 980px) { .hub-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); } .metrics-grid, .details-process-grid { grid-template-columns: repeat(3, minmax(0, 1fr)); } .app-shell.details-open { --details-space: 360px; } .topbar-main { gap: 14px; } }",
    "@media (max-width: 760px) { .app-shell.details-open { --details-space: 0px; } .topbar { padding: 10px 18px; align-items: flex-start; } .topbar-main { display: grid; gap: 12px; } .topbar-actions { justify-content: flex-start; } .conversation { padding: 20px 16px 112px; } .welcome { width: 100%; min-height: 120px; } .hub-grid { grid-template-columns: 1fr; } .messages, .composer-box { width: 100%; } .details-drawer { right: 0; left: auto; top: 0; bottom: 0; width: min(100vw, 420px); padding-top: 88px; } .details-drawer-body { min-height: calc(100vh - 104px); } .details-process-grid { grid-template-columns: 1fr; } #state { min-height: 220px; height: 34vh; } .details-log pre { min-height: 120px; height: 20vh; } .composer { padding: 18px 16px 28px; } }",
  ]
  .iter()
  .join("\n")
}
