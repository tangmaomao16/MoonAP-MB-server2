///|
async fn main {
  let session_dir = initialize_runtime_session()
  println("MoonAP native MoonBit server starting at http://127.0.0.1:3000")
  println("MoonAP runtime session: " + session_dir)
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
      built_web_js_path(),
      "application/javascript; charset=utf-8",
    )
  } else if request.meth == Get &&
    (path.contains("/app.js.map") || path.contains("/app-live.js.map")) {
    serve_static_file(
      conn,
      built_web_js_map_path(),
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
      read_text_or_default(runtime_log_path(), "MoonAP runtime log is empty.\n"),
      "text/plain; charset=utf-8",
    )
  } else if request.meth == Get && path == "/api/codex-threads-dev/manifest" {
    send_json(conn, 200, codex_threads_dev_manifest_json())
  } else if request.meth == Get && path == "/api/codex-threads-dev/coordination" {
    send_json(conn, 200, codex_threads_dev_coordination_json())
  } else if request.meth == Get && path == "/api/llm-sim/latest-request" {
    send_text(
      conn,
      200,
      latest_llm_sim_request_json_or_default(),
      "application/json; charset=utf-8",
    )
  } else if request.meth == Get && path == "/api/llm-sim/latest-response" {
    send_json(conn, 200, latest_llm_sim_response_status_json())
  } else if request.meth == Get && path == "/api/runtime-exec/latest-request" {
    send_text(
      conn,
      200,
      read_text_or_default(
        runtime_exec_root() + "/latest-request.json",
        "{\n  \"status\": \"empty\"\n}\n",
      ),
      "application/json; charset=utf-8",
    )
  } else if request.meth == Get && path == "/api/runtime-exec/latest-result" {
    send_text(
      conn,
      200,
      read_text_or_default(
        runtime_exec_root() + "/latest-result.json",
        "{\n  \"status\": \"empty\"\n}\n",
      ),
      "application/json; charset=utf-8",
    )
  } else if request.meth == Get &&
    path.has_prefix("/api/runtime-exec/request-artifact") {
    serve_runtime_exec_request_artifact(conn, path)
  } else if request.meth == Get && path == "/api/skill-export/save-decision" {
    send_text(
      conn,
      200,
      read_text_or_default(
        skill_export_root() + "/save-decision.json",
        "{\n  \"status\": \"unset\"\n}\n",
      ),
      "application/json; charset=utf-8",
    )
  } else if request.meth == Get && path == "/api/human-sim/latest-action" {
    send_text(
      conn,
      200,
      read_text_or_default(
        human_sim_state_dir() + "/latest-action.json",
        "{}\n",
      ),
      "application/json; charset=utf-8",
    )
  } else if request.meth == Get && path == "/api/human-sim/latest-feedback" {
    send_text(
      conn,
      200,
      read_text_or_default(
        human_sim_state_dir() + "/latest-feedback.md",
        "# latest-feedback\n\nNo human-sim feedback has been recorded yet.\n",
      ),
      "text/markdown; charset=utf-8",
    )
  } else if request.meth == Get && path == "/api/human-sim/latest-intent" {
    send_text(
      conn,
      200,
      read_text_or_default(
        human_sim_state_dir() + "/latest-intent.json",
        "{\n  \"status\": \"empty\"\n}\n",
      ),
      "application/json; charset=utf-8",
    )
  } else if request.meth == Post && path == "/api/human-sim/actions" {
    let payload = body.read_all().text()
    persist_human_sim_payload(
      conn, "actions", payload, "application/json; charset=utf-8",
    )
  } else if request.meth == Post && path == "/api/human-sim/feedback" {
    let payload = body.read_all().text()
    persist_human_sim_payload(
      conn, "feedback", payload, "text/markdown; charset=utf-8",
    )
  } else if request.meth == Post && path == "/api/human-sim/intent-status" {
    let payload = body.read_all().text()
    persist_human_sim_intent_status(
      conn, payload, "application/json; charset=utf-8",
    )
  } else if request.meth == Post &&
    path == "/api/human-sim/dispatch-latest-intent" {
    dispatch_latest_human_sim_intent(conn)
  } else if request.meth == Post &&
    path == "/api/llm-sim/process-latest-response" {
    process_latest_llm_sim_response(conn)
  } else if request.meth == Post && path == "/api/runtime-exec/register-ready" {
    let payload = body.read_all().text()
    persist_runtime_ready_registration(conn, payload)
  } else if request.meth == Post && path == "/api/task/execute" {
    let payload = body.read_all().text()
    persist_runtime_execution_result(conn, payload)
  } else if request.meth == Post && path == "/api/skill-export/save-decision" {
    let payload = body.read_all().text()
    persist_skill_save_decision(conn, payload)
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
      conn,
      runtime_log_directory(),
      runtime_log_path(),
      payload,
      "text/plain; charset=utf-8",
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
async fn initialize_runtime_session() -> String {
  let run_id = "run-" + @core.async_runtime_marker().to_string()
  let root = "logs/runs/" + run_id
  let llm_root = root + "/llm-sim"
  let human_root = root + "/human-sim"
  let runtime_exec_root = root + "/runtime-exec"
  let skill_export_root = root + "/skill-export"
  ensure_directory("logs")
  ensure_directory("logs/runs")
  ensure_directory(root)
  ensure_directory(llm_root + "/inbox")
  ensure_directory(llm_root + "/outbox")
  ensure_directory(llm_root + "/state")
  ensure_directory(human_root + "/actions")
  ensure_directory(human_root + "/observations")
  ensure_directory(human_root + "/feedback")
  ensure_directory(human_root + "/state")
  ensure_directory(runtime_exec_root)
  ensure_directory(skill_export_root)
  ensure_directory(skill_export_root + "/program")
  let runtime_log = root + "/moonap-runtime.log"
  let manifest = "{\n" +
    "  \"run_id\": " +
    json_string(run_id) +
    ",\n" +
    "  \"root\": " +
    json_string(root) +
    ",\n" +
    "  \"runtime_log\": " +
    json_string(runtime_log) +
    ",\n" +
    "  \"llm_sim_root\": " +
    json_string(llm_root) +
    ",\n" +
    "  \"human_sim_root\": " +
    json_string(human_root) +
    ",\n" +
    "  \"runtime_exec_root\": " +
    json_string(runtime_exec_root) +
    ",\n" +
    "  \"skill_export_root\": " +
    json_string(skill_export_root) +
    "\n" +
    "}\n"
  @fs.write_file("logs/current-run-dir.txt", root + "\n", create=0o644)
  @fs.write_file("logs/current-run.json", manifest, create=0o644)
  @fs.write_file(
    runtime_log,
    "{\"ts\":" +
    json_string(run_id) +
    ",\"kind\":\"server\",\"label\":\"session-start\",\"text\":\"MoonAP runtime session initialized.\"}\n",
    create=0o644,
  )
  root
}

///|
async fn ensure_directory(path : String) -> Unit {
  if path != "" && !@fs.exists(path) {
    @fs.mkdir(path, recursive=true, permission=0o755)
  }
}

///|
async fn current_runtime_dir() -> String {
  let path = "logs/current-run-dir.txt"
  if @fs.exists(path) {
    let text = @fs.read_file(path).text().trim().to_string()
    if text != "" {
      return text
    }
  }
  "logs"
}

///|
async fn runtime_log_directory() -> String {
  current_runtime_dir()
}

///|
async fn runtime_log_path() -> String {
  current_runtime_dir() + "/moonap-runtime.log"
}

///|
async fn llm_sim_root() -> String {
  current_runtime_dir() + "/llm-sim"
}

///|
async fn llm_sim_inbox_dir() -> String {
  llm_sim_root() + "/inbox"
}

///|
async fn llm_sim_outbox_dir() -> String {
  llm_sim_root() + "/outbox"
}

///|
async fn llm_sim_state_dir() -> String {
  llm_sim_root() + "/state"
}

///|
async fn human_sim_root() -> String {
  current_runtime_dir() + "/human-sim"
}

///|
async fn human_sim_actions_dir() -> String {
  human_sim_root() + "/actions"
}

///|
async fn human_sim_feedback_dir() -> String {
  human_sim_root() + "/feedback"
}

///|
async fn human_sim_observations_dir() -> String {
  human_sim_root() + "/observations"
}

///|
async fn human_sim_state_dir() -> String {
  human_sim_root() + "/state"
}

///|
async fn runtime_exec_root() -> String {
  current_runtime_dir() + "/runtime-exec"
}

///|
fn built_web_js_path() -> String {
  "_build/js/debug/build/cmd/web_app/web_app.js"
}

///|
fn built_web_js_map_path() -> String {
  "_build/js/debug/build/cmd/web_app/web_app.js.map"
}

///|
async fn runtime_exec_requests_dir() -> String {
  runtime_exec_root() + "/requests"
}

///|
async fn skill_export_root() -> String {
  current_runtime_dir() + "/skill-export"
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
async fn latest_llm_sim_request_text_path() -> String {
  read_text_or_default(llm_sim_state_dir() + "/latest-request.txt", "")
  .trim()
  .to_string()
}

///|
fn llm_sim_request_json_path_from_text_path(
  request_text_path : String,
) -> String {
  if request_text_path == "" {
    ""
  } else {
    request_text_path.replace_all(old=".txt", new=".json")
  }
}

///|
async fn latest_llm_sim_request_json_or_default() -> String {
  let request_text_path = latest_llm_sim_request_text_path()
  if request_text_path == "" {
    "{\n  \"status\": \"empty\"\n}\n"
  } else {
    let request_json_path = llm_sim_request_json_path_from_text_path(
      request_text_path,
    )
    read_text_or_default(
      request_json_path,
      "{\n  \"status\": \"missing-request-json\",\n  \"request_text_path\": " +
      json_string(request_text_path) +
      "\n}\n",
    )
  }
}

///|
async fn latest_llm_sim_response_status_json() -> String {
  let request_json = latest_llm_sim_request_json_or_default()
  let request_id = extract_json_string_field(request_json, "request_id")
  let response_path = extract_json_string_field(request_json, "reply_path")
  let error_path = extract_json_string_field(request_json, "error_path")
  if request_id == "" {
    return "{\n  \"ok\": false,\n  \"status\": \"empty\"\n}\n"
  }
  let response_exists = response_path != "" && @fs.exists(response_path)
  let error_exists = error_path != "" && @fs.exists(error_path)
  "{\n" +
  "  \"ok\": " +
  bool_json(response_exists) +
  ",\n" +
  "  \"request_id\": " +
  json_string(request_id) +
  ",\n" +
  "  \"status\": " +
  json_string(
    if response_exists {
      "response-ready"
    } else if error_exists {
      "error-ready"
    } else {
      "pending"
    },
  ) +
  ",\n" +
  "  \"response_path\": " +
  json_string(response_path) +
  ",\n" +
  "  \"error_path\": " +
  json_string(error_path) +
  "\n" +
  "}\n"
}

///|
fn bool_json(value : Bool) -> String {
  if value {
    "true"
  } else {
    "false"
  }
}

///|
fn json_message(role : String, content : String) -> String {
  "{\n" +
  "  \"role\": " +
  json_string(role) +
  ",\n" +
  "  \"content\": " +
  json_string(content) +
  "\n" +
  "}"
}

///|
fn append_json_message_array(
  history_json : String,
  role : String,
  content : String,
) -> String {
  let trimmed = history_json.trim().to_string()
  let message = json_message(role, content)
  if trimmed == "" || trimmed == "[]" {
    "[\n" + message + "\n]"
  } else if trimmed.has_prefix("[") && trimmed.has_suffix("]") {
    let inner = trimmed[1:trimmed.length() - 1].trim().to_string()
    if inner == "" {
      "[\n" + message + "\n]"
    } else {
      "[\n" + inner + ",\n" + message + "\n]"
    }
  } else {
    "[\n" + json_message("user", trimmed) + ",\n" + message + "\n]"
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
async fn persist_human_sim_payload(
  conn : @http.ServerConnection,
  channel : String,
  payload : String,
  content_type : String,
) -> Unit {
  let directory = if channel == "actions" {
    human_sim_actions_dir()
  } else {
    human_sim_feedback_dir()
  }
  let latest_suffix = if content_type.contains("json") {
    ".json"
  } else if channel == "actions" {
    ".txt"
  } else {
    ".md"
  }
  let state_path = if channel == "actions" {
    human_sim_state_dir() + "/latest-action" + latest_suffix
  } else {
    human_sim_state_dir() + "/latest-feedback" + latest_suffix
  }
  ensure_directory(directory)
  ensure_directory(human_sim_state_dir())
  let extension = if channel == "actions" { ".json" } else { latest_suffix }
  let normalized_payload = if channel == "actions" {
    normalize_human_sim_action_payload(payload)
  } else {
    payload
  }
  let path = directory +
    "/" +
    channel +
    "-" +
    @core.async_runtime_marker().to_string() +
    extension
  @fs.write_file(path, normalized_payload, create=0o644)
  @fs.write_file(state_path, normalized_payload, create=0o644)
  if channel == "actions" {
    let action_kind = extract_json_string_field(normalized_payload, "action")
    if action_kind == "submit-prompt" {
      @fs.write_file(
        human_sim_state_dir() + "/latest-intent.json",
        human_sim_intent_json(normalized_payload),
        create=0o644,
      )
    }
  }
  append_text_file(
    runtime_log_directory(),
    runtime_log_path(),
    "{\"ts\":" +
    json_string(@core.async_runtime_marker().to_string()) +
    ",\"kind\":\"human-sim\",\"label\":" +
    json_string(channel + "-received") +
    ",\"text\":" +
    json_string(path) +
    "}\n",
  )
  send_text(conn, 200, normalized_payload, content_type)
}

///|
async fn persist_human_sim_intent_status(
  conn : @http.ServerConnection,
  payload : String,
  content_type : String,
) -> Unit {
  let normalized = normalize_human_sim_intent_status_payload(payload)
  ensure_directory(human_sim_state_dir())
  @fs.write_file(
    human_sim_state_dir() + "/latest-intent-status.json",
    normalized,
    create=0o644,
  )
  append_text_file(
    runtime_log_directory(),
    runtime_log_path(),
    "{\"ts\":" +
    json_string(@core.async_runtime_marker().to_string()) +
    ",\"kind\":\"human-sim\",\"label\":\"intent-status-updated\",\"text\":" +
    json_string(human_sim_state_dir() + "/latest-intent-status.json") +
    "}\n",
  )
  send_text(conn, 200, normalized, content_type)
}

///|
async fn dispatch_latest_human_sim_intent(
  conn : @http.ServerConnection,
) -> Unit {
  let intent_path = human_sim_state_dir() + "/latest-intent.json"
  let intent_raw = read_text_or_default(
    intent_path, "{\n  \"status\": \"empty\"\n}\n",
  )
  let prompt = extract_json_string_field(intent_raw, "prompt")
  let task_kind = extract_json_string_field(intent_raw, "task_kind")
  if prompt == "" {
    send_json(
      conn, 400, "{\n  \"ok\": false,\n  \"error\": \"No captured human-sim intent is available yet.\"\n}\n",
    )
    return
  }
  let request_body = llm_sim_request_body_from_intent(prompt)
  let conversation_history_json = llm_sim_initial_conversation_history_json(
    prompt,
  )
  let (request_id, request_text_path, response_path, error_path) = create_llm_sim_request(
    "openai", "gpt-5.4", "codegen", "moonap://llm-sim", request_body, prompt, task_kind,
    conversation_history_json,
  )
  @fs.write_file(
    human_sim_state_dir() + "/latest-intent-status.json",
    "{\n" +
    "  \"status\": \"dispatched\",\n" +
    "  \"assignee\": \"llm-sim-thread\",\n" +
    "  \"notes\": " +
    json_string(request_id) +
    "\n" +
    "}\n",
    create=0o644,
  )
  send_json(
    conn,
    200,
    "{\n" +
    "  \"ok\": true,\n" +
    "  \"request_id\": " +
    json_string(request_id) +
    ",\n" +
    "  \"request_path\": " +
    json_string(request_text_path) +
    ",\n" +
    "  \"reply_path\": " +
    json_string(response_path) +
    ",\n" +
    "  \"error_path\": " +
    json_string(error_path) +
    "\n" +
    "}\n",
  )
}

///|
async fn process_latest_llm_sim_response(conn : @http.ServerConnection) -> Unit {
  let request_json = latest_llm_sim_request_json_or_default()
  let request_id = extract_json_string_field(request_json, "request_id")
  let response_path = extract_json_string_field(request_json, "reply_path")
  let error_path = extract_json_string_field(request_json, "error_path")
  let original_prompt = extract_json_string_field(
    request_json, "original_prompt",
  )
  let task_kind = extract_json_string_field(request_json, "task_kind")
  let conversation_history_json = extract_json_string_field(
    request_json, "conversation_history_json",
  )
  if request_id == "" {
    send_json(
      conn, 400, "{\n  \"ok\": false,\n  \"error\": \"No llm-sim request is available yet.\"\n}\n",
    )
    return
  }
  if error_path != "" && @fs.exists(error_path) {
    let detail = @fs.read_file(error_path).text()
    append_text_file(
      runtime_log_directory(),
      runtime_log_path(),
      "{\"ts\":" +
      json_string(request_id) +
      ",\"kind\":\"llm-sim\",\"label\":\"response-error-consumed\",\"text\":" +
      json_string(error_path) +
      "}\n",
    )
    send_json(
      conn,
      502,
      "{\n" +
      "  \"ok\": false,\n" +
      "  \"request_id\": " +
      json_string(request_id) +
      ",\n" +
      "  \"status\": \"error-ready\",\n" +
      "  \"error_path\": " +
      json_string(error_path) +
      ",\n" +
      "  \"detail\": " +
      json_string(detail) +
      "\n" +
      "}\n",
    )
    return
  }
  if response_path == "" || !@fs.exists(response_path) {
    send_json(
      conn,
      202,
      "{\n" +
      "  \"ok\": false,\n" +
      "  \"request_id\": " +
      json_string(request_id) +
      ",\n" +
      "  \"status\": \"pending-response\",\n" +
      "  \"response_path\": " +
      json_string(response_path) +
      "\n" +
      "}\n",
    )
    return
  }
  let raw_response = @fs.read_file(response_path).text()
  let source = @core.extract_moonbit_source(raw_response)
  let report = @core.artifact_compile_probe(source)
  let report_json = report.to_json().stringify(indent=2)
  let stage = extract_json_string_field(request_json, "stage")
  let requests_dir = runtime_exec_requests_dir()
  let request_dir = requests_dir + "/" + request_id
  let latest_response_path = runtime_exec_root() + "/latest-raw-response.txt"
  let latest_source_path = runtime_exec_root() + "/latest-source.mbt"
  let latest_report_path = runtime_exec_root() + "/latest-compile-report.json"
  let latest_runtime_request_path = runtime_exec_root() + "/latest-request.json"
  let request_response_path = request_dir + "/raw-response.txt"
  let request_source_path = request_dir + "/main.mbt"
  let request_report_path = request_dir + "/compile-report.json"
  let request_runtime_request_path = request_dir + "/runtime-request.json"
  let observation_path = human_sim_observations_dir() +
    "/" +
    request_id +
    "-compile-observation.md"
  let latest_observation_path = human_sim_observations_dir() +
    "/latest-compile-observation.md"
  ensure_directory(runtime_exec_root())
  ensure_directory(requests_dir)
  ensure_directory(request_dir)
  ensure_directory(human_sim_observations_dir())
  @fs.write_file(request_response_path, raw_response, create=0o644)
  @fs.write_file(request_source_path, source + "\n", create=0o644)
  @fs.write_file(request_report_path, report_json + "\n", create=0o644)
  @fs.write_file(latest_response_path, raw_response, create=0o644)
  @fs.write_file(latest_source_path, source + "\n", create=0o644)
  @fs.write_file(latest_report_path, report_json + "\n", create=0o644)
  let runtime_request_json = runtime_exec_request_json(
    request_id,
    stage,
    request_source_path,
    source,
    report,
    run_id_from_dir(current_runtime_dir()),
  )
  if report.ok {
    @fs.write_file(
      request_runtime_request_path,
      runtime_request_json,
      create=0o644,
    )
    @fs.write_file(
      latest_runtime_request_path,
      runtime_request_json,
      create=0o644,
    )
  }
  let observation = llm_sim_compile_observation_markdown(request_id, report)
  let next_repair_request = if report.ok {
    None
  } else {
    let compiler_excerpt = if report.trimmed_output != "" {
      report.trimmed_output
    } else if report.summary_excerpt != "" {
      report.summary_excerpt
    } else {
      report.output
    }
    let repair_body = llm_sim_repair_request_body_from_report(
      source, report, task_kind, conversation_history_json,
    )
    let next_conversation_history_json = append_json_message_array(
      append_json_message_array(conversation_history_json, "assistant", source),
      "user",
      "Compiler error:\n" + compiler_excerpt,
    )
    let (next_request_id, next_request_path, next_response_path, next_error_path
    ) = create_llm_sim_request(
      "openai", "gpt-5.4", "repair", "moonap://llm-sim", repair_body, original_prompt,
      task_kind, next_conversation_history_json,
    )
    Some(
      (next_request_id, next_request_path, next_response_path, next_error_path),
    )
  }
  @fs.write_file(observation_path, observation, create=0o644)
  @fs.write_file(latest_observation_path, observation, create=0o644)
  @fs.write_file(
    llm_sim_state_dir() + "/latest-response-status.json",
    "{\n" +
    "  \"request_id\": " +
    json_string(request_id) +
    ",\n" +
    "  \"status\": " +
    json_string(if report.ok { "compile-ok" } else { "compile-failed" }) +
    ",\n" +
    "  \"request_stage\": " +
    json_string(stage) +
    ",\n" +
    "  \"response_path\": " +
    json_string(response_path) +
    ",\n" +
    "  \"source_path\": " +
    json_string(request_source_path) +
    ",\n" +
    "  \"compile_report_path\": " +
    json_string(request_report_path) +
    ",\n" +
    "  \"next_request_id\": " +
    json_string(
      match next_repair_request {
        Some((next_request_id, _, _, _)) => next_request_id
        None => ""
      },
    ) +
    "\n" +
    "}\n",
    create=0o644,
  )
  append_text_file(
    runtime_log_directory(),
    runtime_log_path(),
    "{\"ts\":" +
    json_string(request_id) +
    ",\"kind\":\"llm-sim\",\"label\":\"response-processed\",\"text\":" +
    json_string(request_report_path) +
    "}\n",
  )
  append_text_file(
    runtime_log_directory(),
    runtime_log_path(),
    "{\"ts\":" +
    json_string(request_id) +
    ",\"kind\":\"runtime-exec\",\"label\":\"compile-probe-finished\",\"text\":" +
    json_string(if report.ok { "ok" } else { "failed" }) +
    "}\n",
  )
  if report.ok {
    append_text_file(
      runtime_log_directory(),
      runtime_log_path(),
      "{\"ts\":" +
      json_string(request_id) +
      ",\"kind\":\"runtime-exec\",\"label\":\"runtime-request-ready\",\"text\":" +
      json_string(request_runtime_request_path) +
      "}\n",
    )
  }
  if next_repair_request is Some((next_request_id, _, _, _)) {
    append_text_file(
      runtime_log_directory(),
      runtime_log_path(),
      "{\"ts\":" +
      json_string(next_request_id) +
      ",\"kind\":\"llm-sim\",\"label\":\"repair-request-created\",\"text\":" +
      json_string(request_id) +
      "}\n",
    )
  }
  send_json(
    conn,
    200,
    "{\n" +
    "  \"ok\": " +
    bool_json(report.ok) +
    ",\n" +
    "  \"request_id\": " +
    json_string(request_id) +
    ",\n" +
    "  \"source_path\": " +
    json_string(request_source_path) +
    ",\n" +
    "  \"compile_report_path\": " +
    json_string(request_report_path) +
    ",\n" +
    "  \"observation_path\": " +
    json_string(observation_path) +
    ",\n" +
    "  \"stage\": " +
    json_string(report.stage) +
    ",\n" +
    "  \"summary_kind\": " +
    json_string(report.summary_kind) +
    ",\n" +
    "  \"next_request_id\": " +
    json_string(
      match next_repair_request {
        Some((next_request_id, _, _, _)) => next_request_id
        None => ""
      },
    ) +
    ",\n" +
    "  \"next_request_path\": " +
    json_string(
      match next_repair_request {
        Some((_, next_request_path, _, _)) => next_request_path
        None => ""
      },
    ) +
    "\n" +
    "}\n",
  )
}

///|
fn runtime_exec_request_json(
  request_id : String,
  request_stage : String,
  source_path : String,
  source_text : String,
  report : @core.ArtifactCompileReport,
  run_id : String,
) -> String {
  runtime_exec_request_json_from_fields(
    request_id,
    request_stage,
    source_path,
    report.wasm_path,
    run_id,
    "",
    "",
    source_text,
  )
}

///|
fn runtime_exec_request_json_from_fields(
  request_id : String,
  request_stage : String,
  source_path : String,
  wasm_path : String,
  run_id : String,
  task_title : String,
  original_prompt : String,
  source_text : String,
) -> String {
  let base_url = "/api/runtime-exec/request-artifact?run_id=" +
    run_id +
    "&request_id=" +
    request_id
  let task_kind = runtime_task_kind_from_context(
    task_title, original_prompt, source_text,
  )
  let runtime_mode = runtime_mode_for_task_kind(task_kind)
  let result_mode = result_mode_for_task_kind(task_kind)
  let runtime_spec_json = runtime_spec_json_for_task_kind(task_kind)
  "{\n" +
  "  \"run_id\": " +
  json_string(run_id) +
  ",\n" +
  "  \"request_id\": " +
  json_string(request_id) +
  ",\n" +
  "  \"request_stage\": " +
  json_string(request_stage) +
  ",\n" +
  "  \"task_kind\": " +
  json_string(task_kind) +
  ",\n" +
  "  \"runtime_mode\": " +
  json_string(runtime_mode) +
  ",\n" +
  "  \"result_mode\": " +
  json_string(result_mode) +
  ",\n" +
  "  \"status\": \"ready-for-runtime\",\n" +
  "  \"wasm_path\": " +
  json_string(wasm_path) +
  ",\n" +
  "  \"wasm_url\": " +
  json_string(base_url + "&kind=wasm") +
  ",\n" +
  "  \"source_path\": " +
  json_string(source_path) +
  ",\n" +
  "  \"source_url\": " +
  json_string(base_url + "&kind=source") +
  ",\n" +
  "  \"compile_report_url\": " +
  json_string(base_url + "&kind=compile-report") +
  ",\n" +
  "  \"raw_response_url\": " +
  json_string(base_url + "&kind=raw-response") +
  ",\n" +
  "  \"runtime_spec\": " +
  runtime_spec_json +
  ",\n" +
  "  \"runtime_ui\": " +
  runtime_spec_json +
  ",\n" +
  "  \"result_delivery\": {\n" +
  "    \"show_in_browser\": true,\n" +
  "    \"allow_download\": true,\n" +
  "    \"save_skill_after_user_accepts\": true\n" +
  "  }\n" +
  "}\n"
}

///|
fn runtime_mode_for_task_kind(task_kind : String) -> String {
  if task_kind == "fastq-generator" || task_kind == "excel-generator" {
    "form"
  } else if task_kind == "fastq-analysis" || task_kind == "finance-report-analysis" {
    "file"
  } else if task_kind == "browser-game" {
    "interactive"
  } else {
    "form"
  }
}

///|
fn result_mode_for_task_kind(task_kind : String) -> String {
  if task_kind == "fastq-generator" || task_kind == "excel-generator" {
    "download"
  } else if task_kind == "fastq-analysis" || task_kind == "finance-report-analysis" {
    "report"
  } else if task_kind == "browser-game" {
    "interactive"
  } else {
    "text"
  }
}

///|
fn runtime_task_kind_from_context(
  task_title : String,
  original_prompt : String,
  source_text : String,
) -> String {
  let haystack = task_title + "\n" + original_prompt + "\n" + source_text
  if haystack.contains("fastq") ||
    haystack.contains("FastQ") ||
    haystack.contains("FASTQ") {
    "fastq-generator"
  } else if haystack.contains("financial") ||
    haystack.contains("Financial") ||
    haystack.contains("finance") ||
    haystack.contains("Finance") ||
    haystack.contains("report") ||
    haystack.contains("Report") {
    "finance-report-analysis"
  } else if haystack.contains("excel") ||
    haystack.contains("Excel") ||
    haystack.contains("EXCEL") {
    "excel-generator"
  } else if haystack.contains("game") ||
    haystack.contains("Game") ||
    haystack.contains("GAME") {
    "browser-game"
  } else {
    "generic-task"
  }
}

///|
fn runtime_spec_json_for_task_kind(task_kind : String) -> String {
  if task_kind == "fastq-generator" {
    "{\n" +
    "    \"mode\": \"form\",\n" +
    "    \"title\": \"Generate FastQ file\",\n" +
    "    \"primary_action_label\": \"Run generator\",\n" +
    "    \"fields\": [\n" +
    "      {\n" +
    "        \"name\": \"read_count\",\n" +
    "        \"label\": \"Read count\",\n" +
    "        \"type\": \"int\",\n" +
    "        \"default\": 10000,\n" +
    "        \"min\": 1,\n" +
    "        \"max\": 1000000,\n" +
    "        \"step\": 1\n" +
    "      },\n" +
    "      {\n" +
    "        \"name\": \"read_length\",\n" +
    "        \"label\": \"Read length\",\n" +
    "        \"type\": \"int\",\n" +
    "        \"default\": 150,\n" +
    "        \"min\": 1,\n" +
    "        \"max\": 10000,\n" +
    "        \"step\": 1\n" +
    "      },\n" +
    "      {\n" +
    "        \"name\": \"n_rate\",\n" +
    "        \"label\": \"N rate\",\n" +
    "        \"type\": \"float\",\n" +
    "        \"default\": 0.01,\n" +
    "        \"min\": 0,\n" +
    "        \"max\": 1,\n" +
    "        \"step\": 0.001\n" +
    "      },\n" +
    "      {\n" +
    "        \"name\": \"random_seed\",\n" +
    "        \"label\": \"Random seed\",\n" +
    "        \"type\": \"int\",\n" +
    "        \"default\": 42,\n" +
    "        \"step\": 1\n" +
    "      }\n" +
    "    ]\n" +
    "  }"
  } else if task_kind == "excel-generator" {
    "{\n" +
    "    \"mode\": \"form\",\n" +
    "    \"title\": \"Generate financial spreadsheet\",\n" +
    "    \"action_label\": \"Run generator\",\n" +
    "    \"fields\": [\n" +
    "      {\n" +
    "        \"name\": \"row_count\",\n" +
    "        \"label\": \"Row count\",\n" +
    "        \"type\": \"int\",\n" +
    "        \"default\": 120,\n" +
    "        \"min\": 1,\n" +
    "        \"max\": 100000,\n" +
    "        \"step\": 1\n" +
    "      },\n" +
    "      {\n" +
    "        \"name\": \"company_name\",\n" +
    "        \"label\": \"Company name\",\n" +
    "        \"type\": \"text\",\n" +
    "        \"default\": \"MoonAP Finance\"\n" +
    "      },\n" +
    "      {\n" +
    "        \"name\": \"currency\",\n" +
    "        \"label\": \"Currency\",\n" +
    "        \"type\": \"text\",\n" +
    "        \"default\": \"USD\"\n" +
    "      },\n" +
    "      {\n" +
    "        \"name\": \"random_seed\",\n" +
    "        \"label\": \"Random seed\",\n" +
    "        \"type\": \"int\",\n" +
    "        \"default\": 42,\n" +
    "        \"step\": 1\n" +
    "      }\n" +
    "    ]\n" +
    "  }"
  } else if task_kind == "fastq-analysis" {
    "{\n" +
    "    \"mode\": \"file\",\n" +
    "    \"title\": \"Analyze FastQ file\",\n" +
    "    \"action_label\": \"Run analysis\",\n" +
    "    \"fields\": []\n" +
    "  }"
  } else if task_kind == "finance-report-analysis" {
    "{\n" +
    "    \"mode\": \"file\",\n" +
    "    \"title\": \"Analyze financial report\",\n" +
    "    \"action_label\": \"Run analysis\",\n" +
    "    \"fields\": []\n" +
    "  }"
  } else if task_kind == "browser-game" {
    "{\n" +
    "    \"mode\": \"interactive\",\n" +
    "    \"title\": \"Launch browser game\",\n" +
    "    \"action_label\": \"Run game\",\n" +
    "    \"fields\": []\n" +
    "  }"
  } else {
    "{\n" +
    "    \"mode\": \"action\",\n" +
    "    \"title\": \"Run browser-local step\",\n" +
    "    \"action_label\": \"Run runtime step\",\n" +
    "    \"fields\": []\n" +
    "  }"
  }
}

///|
async fn persist_runtime_ready_registration(
  conn : @http.ServerConnection,
  payload : String,
) -> Unit {
  let source_text = extract_payload_block(
    payload, "SOURCE_BEGIN\n", "\nSOURCE_END",
  )
  let compile_report_json = extract_payload_block(
    payload, "COMPILE_REPORT_BEGIN\n", "\nCOMPILE_REPORT_END",
  )
  let task_title = extract_payload_header(payload, "TASK_TITLE")
  let original_prompt = extract_payload_header(payload, "ORIGINAL_PROMPT")
  let llm_provider = extract_payload_header(payload, "LLM_PROVIDER")
  let llm_model = extract_payload_header(payload, "LLM_MODEL")
  let request_stage = extract_payload_header(payload, "REQUEST_STAGE")
  let raw_response_text = extract_payload_block(
    payload, "RAW_RESPONSE_BEGIN\n", "\nRAW_RESPONSE_END",
  )
  let compile_ok = extract_payload_header(payload, "COMPILE_OK") == "true"
  let wasm_path = extract_payload_header(payload, "WASM_PATH")
  if source_text.trim() == "" {
    send_json(
      conn, 400, "{\n  \"ok\": false,\n  \"error\": \"No source_text was provided for runtime registration.\"\n}\n",
    )
    return
  }
  if !compile_ok || wasm_path == "" {
    send_json(
      conn, 400, "{\n  \"ok\": false,\n  \"error\": \"MoonAP runtime registration requires a successful compile report with wasm_path.\"\n}\n",
    )
    return
  }
  let request_id = "browser-runtime-" + @core.async_runtime_marker().to_string()
  let run_id = run_id_from_dir(current_runtime_dir())
  let request_dir = runtime_exec_requests_dir() + "/" + request_id
  let latest_response_path = runtime_exec_root() + "/latest-raw-response.txt"
  let latest_source_path = runtime_exec_root() + "/latest-source.mbt"
  let latest_report_path = runtime_exec_root() + "/latest-compile-report.json"
  let latest_runtime_request_path = runtime_exec_root() + "/latest-request.json"
  let request_response_path = request_dir + "/raw-response.txt"
  let request_source_path = request_dir + "/main.mbt"
  let request_report_path = request_dir + "/compile-report.json"
  let request_runtime_request_path = request_dir + "/runtime-request.json"
  ensure_directory(runtime_exec_root())
  ensure_directory(runtime_exec_requests_dir())
  ensure_directory(request_dir)
  @fs.write_file(
    request_response_path,
    if raw_response_text == "" {
      source_text + "\n"
    } else {
      raw_response_text + "\n"
    },
    create=0o644,
  )
  @fs.write_file(request_source_path, source_text + "\n", create=0o644)
  @fs.write_file(request_report_path, compile_report_json + "\n", create=0o644)
  @fs.write_file(
    latest_response_path,
    if raw_response_text == "" {
      source_text + "\n"
    } else {
      raw_response_text + "\n"
    },
    create=0o644,
  )
  @fs.write_file(latest_source_path, source_text + "\n", create=0o644)
  @fs.write_file(latest_report_path, compile_report_json + "\n", create=0o644)
  let runtime_request_json = runtime_exec_request_json_from_fields(
    request_id,
    if request_stage == "" {
      "browser-direct"
    } else {
      request_stage
    },
    request_source_path,
    wasm_path,
    run_id,
    task_title,
    original_prompt,
    source_text,
  )
  @fs.write_file(
    request_runtime_request_path,
    runtime_request_json,
    create=0o644,
  )
  @fs.write_file(
    latest_runtime_request_path,
    runtime_request_json,
    create=0o644,
  )
  append_text_file(
    runtime_log_directory(),
    runtime_log_path(),
    "{\"ts\":" +
    json_string(request_id) +
    ",\"kind\":\"runtime-exec\",\"label\":\"runtime-request-registered\",\"text\":" +
    json_string(
      (if task_title == "" { "browser-direct" } else { task_title }) +
      " via " +
      (if llm_provider == "" { "unknown-provider" } else { llm_provider }) +
      "/" +
      (if llm_model == "" { "unknown-model" } else { llm_model }),
    ) +
    "}\n",
  )
  send_text(
    conn,
    200,
    "{\n" +
    "  \"ok\": true,\n" +
    "  \"run_id\": " +
    json_string(run_id) +
    ",\n" +
    "  \"request_id\": " +
    json_string(request_id) +
    ",\n" +
    "  \"request_stage\": " +
    json_string(
      if request_stage == "" {
        "browser-direct"
      } else {
        request_stage
      },
    ) +
    ",\n" +
    "  \"task_title\": " +
    json_string(task_title) +
    ",\n" +
    "  \"original_prompt\": " +
    json_string(original_prompt) +
    ",\n" +
    runtime_request_json[1:runtime_request_json.length()].to_string(),
    "application/json; charset=utf-8",
  )
}

///|
fn extract_payload_header(payload : String, key : String) -> String {
  let marker = key + "\t"
  for line in payload.split("\n") {
    let trimmed = line.trim_end().to_string()
    if trimmed.has_prefix(marker) {
      return trimmed[marker.length():].to_string()
    }
  }
  ""
}

///|
fn extract_payload_block(
  payload : String,
  begin_marker : String,
  end_marker : String,
) -> String {
  guard payload.find(begin_marker) is Some(start) else { return "" }
  let after_start = payload[start + begin_marker.length():]
  guard after_start.find(end_marker) is Some(end) else { return "" }
  after_start[:end].to_string()
}

///|
async fn persist_runtime_execution_result(
  conn : @http.ServerConnection,
  payload : String,
) -> Unit {
  let normalized = normalize_runtime_execution_payload(payload)
  let request_id = extract_json_string_field(normalized, "request_id")
  let status = extract_json_string_field(normalized, "status")
  let request_dir = if request_id == "" {
    runtime_exec_root()
  } else {
    runtime_exec_requests_dir() + "/" + request_id
  }
  ensure_directory(runtime_exec_root())
  ensure_directory(runtime_exec_requests_dir())
  ensure_directory(request_dir)
  @fs.write_file(
    runtime_exec_root() + "/latest-result.json",
    normalized,
    create=0o644,
  )
  @fs.write_file(request_dir + "/result.json", normalized, create=0o644)
  let stdout = extract_json_string_field(normalized, "stdout_text")
  let error_text = extract_json_string_field(normalized, "error_text")
  let download_name = extract_json_string_field(normalized, "download_name")
  let download_content = extract_json_string_field(
    normalized, "download_content",
  )
  @fs.write_file(
    request_dir + "/stdout.txt",
    if stdout == "" {
      ""
    } else {
      stdout + "\n"
    },
    create=0o644,
  )
  @fs.write_file(
    request_dir + "/error.txt",
    if error_text == "" {
      ""
    } else {
      error_text + "\n"
    },
    create=0o644,
  )
  @fs.write_file(
    request_dir + "/preview.json",
    "{\n" +
    "  \"request_id\": " +
    json_string(request_id) +
    ",\n" +
    "  \"status\": " +
    json_string(status) +
    ",\n" +
    "  \"download_name\": " +
    json_string(download_name) +
    "\n" +
    "}\n",
    create=0o644,
  )
  if download_name != "" || download_content != "" {
    let download_file_name = if download_name == "" {
      "download.txt"
    } else {
      download_name
    }
    let download_path = request_dir + "/" + download_file_name
    @fs.write_file(download_path, download_content, create=0o644)
  }
  append_text_file(
    runtime_log_directory(),
    runtime_log_path(),
    "{\"ts\":" +
    json_string(
      if request_id == "" {
        @core.async_runtime_marker().to_string()
      } else {
        request_id
      },
    ) +
    ",\"kind\":\"runtime-exec\",\"label\":\"runtime-result-received\",\"text\":" +
    json_string(request_dir + "/result.json") +
    "}\n",
  )
  send_text(conn, 200, normalized, "application/json; charset=utf-8")
}

///|
fn normalize_runtime_execution_payload(payload : String) -> String {
  let run_id = extract_json_string_field(payload, "run_id")
  let request_id = extract_json_string_field(payload, "request_id")
  let status = extract_json_string_field(payload, "status")
  let result_kind = extract_json_string_field(payload, "result_kind")
  let summary = extract_json_string_field(payload, "summary")
  let display_text = extract_json_string_field(payload, "display_text")
  let stdout_text = extract_json_string_field(payload, "stdout_text")
  let error_text = extract_json_string_field(payload, "error_text")
  let download_name = extract_json_string_field(payload, "download_name")
  let download_content = extract_json_string_field(payload, "download_content")
  let accepted_for_skill = extract_json_bool_field(
    payload, "accepted_for_skill",
  )
  let download_url = if request_id == "" || download_name == "" {
    ""
  } else {
    "/api/runtime-exec/request-artifact?" +
    (if run_id == "" { "" } else { "run_id=" + run_id + "&" }) +
    "request_id=" +
    request_id +
    "&kind=download&name=" +
    download_name
  }
  "{\n" +
  "  \"run_id\": " +
  json_string(run_id) +
  ",\n" +
  "  \"request_id\": " +
  json_string(request_id) +
  ",\n" +
  "  \"status\": " +
  json_string(if status == "" { "runtime-succeeded" } else { status }) +
  ",\n" +
  "  \"result_kind\": " +
  json_string(if result_kind == "" { "text" } else { result_kind }) +
  ",\n" +
  "  \"summary\": " +
  json_string(summary) +
  ",\n" +
  "  \"display_text\": " +
  json_string(display_text) +
  ",\n" +
  "  \"stdout_text\": " +
  json_string(stdout_text) +
  ",\n" +
  "  \"error_text\": " +
  json_string(error_text) +
  ",\n" +
  "  \"download_name\": " +
  json_string(download_name) +
  ",\n" +
  "  \"download_url\": " +
  json_string(download_url) +
  ",\n" +
  "  \"download_content\": " +
  json_string(download_content) +
  ",\n" +
  "  \"accepted_for_skill\": " +
  bool_json(accepted_for_skill) +
  "\n" +
  "}\n"
}

///|
async fn persist_skill_save_decision(
  conn : @http.ServerConnection,
  payload : String,
) -> Unit {
  let normalized = normalize_skill_save_decision_payload(payload)
  let request_id = extract_json_string_field(normalized, "request_id")
  let decision = extract_json_string_field(normalized, "decision")
  ensure_directory(skill_export_root())
  @fs.write_file(
    skill_export_root() + "/save-decision.json",
    normalized,
    create=0o644,
  )
  if request_id != "" && decision == "accepted-save-skill" {
    materialize_skill_export(request_id)
  }
  append_text_file(
    runtime_log_directory(),
    runtime_log_path(),
    "{\"ts\":" +
    json_string(@core.async_runtime_marker().to_string()) +
    ",\"kind\":\"skill-export\",\"label\":\"save-decision-recorded\",\"text\":" +
    json_string(skill_export_root() + "/save-decision.json") +
    "}\n",
  )
  send_text(conn, 200, normalized, "application/json; charset=utf-8")
}

///|
async fn materialize_skill_export(request_id : String) -> Unit {
  let run_id = run_id_from_dir(current_runtime_dir())
  let request_dir = runtime_exec_requests_dir() + "/" + request_id
  guard @fs.exists(request_dir) else { return }
  let program_dir = skill_export_root() + "/program"
  ensure_directory(skill_export_root())
  ensure_directory(program_dir)
  let source_path = request_dir + "/main.mbt"
  let report_path = request_dir + "/compile-report.json"
  let result_path = request_dir + "/result.json"
  let runtime_request_path = request_dir + "/runtime-request.json"
  let source_text = read_text_or_default(source_path, "")
  let report_json = read_text_or_default(report_path, "{\n  \"ok\": false\n}\n")
  let result_json = read_text_or_default(
    result_path, "{\n  \"status\": \"missing\"\n}\n",
  )
  let runtime_request_json = read_text_or_default(
    runtime_request_path, "{\n  \"status\": \"missing\"\n}\n",
  )
  if source_text != "" {
    @fs.write_file(program_dir + "/main.mbt", source_text, create=0o644)
  }
  @fs.write_file(
    program_dir + "/compile-report.json",
    report_json,
    create=0o644,
  )
  @fs.write_file(
    program_dir + "/runtime-request.json",
    runtime_request_json,
    create=0o644,
  )
  @fs.write_file(program_dir + "/result.json", result_json, create=0o644)
  let wasm_url = "/api/runtime-exec/request-artifact?run_id=" +
    run_id +
    "&request_id=" +
    request_id +
    "&kind=wasm"
  let source_url = "/api/runtime-exec/request-artifact?run_id=" +
    run_id +
    "&request_id=" +
    request_id +
    "&kind=source"
  let result_url = "/api/runtime-exec/request-artifact?run_id=" +
    run_id +
    "&request_id=" +
    request_id +
    "&kind=result"
  @fs.write_file(
    skill_export_root() + "/skill-manifest.json",
    "{\n" +
    "  \"run_id\": " +
    json_string(run_id) +
    ",\n" +
    "  \"request_id\": " +
    json_string(request_id) +
    ",\n" +
    "  \"status\": \"exported\",\n" +
    "  \"entry_source\": " +
    json_string(program_dir + "/main.mbt") +
    ",\n" +
    "  \"wasm_url\": " +
    json_string(wasm_url) +
    ",\n" +
    "  \"source_url\": " +
    json_string(source_url) +
    ",\n" +
    "  \"result_url\": " +
    json_string(result_url) +
    "\n" +
    "}\n",
    create=0o644,
  )
  @fs.write_file(
    skill_export_root() + "/SKILL.md",
    "# Exported MoonAP SKILL\n\n" +
    "- request_id: `" +
    request_id +
    "`\n" +
    "- source: `program/main.mbt`\n" +
    "- compile report: `program/compile-report.json`\n" +
    "- runtime request: `program/runtime-request.json`\n" +
    "- runtime result: `program/result.json`\n\n" +
    "## Runtime Artifacts\n\n" +
    "- wasm URL: `" +
    wasm_url +
    "`\n" +
    "- source URL: `" +
    source_url +
    "`\n" +
    "- result URL: `" +
    result_url +
    "`\n",
    create=0o644,
  )
  append_text_file(
    runtime_log_directory(),
    runtime_log_path(),
    "{\"ts\":" +
    json_string(request_id) +
    ",\"kind\":\"skill-export\",\"label\":\"skill-export-materialized\",\"text\":" +
    json_string(skill_export_root() + "/skill-manifest.json") +
    "}\n",
  )
}

///|
fn normalize_skill_save_decision_payload(payload : String) -> String {
  let request_id = extract_json_string_field(payload, "request_id")
  let decision = extract_json_string_field(payload, "decision")
  let reason = extract_json_string_field(payload, "reason")
  "{\n" +
  "  \"request_id\": " +
  json_string(request_id) +
  ",\n" +
  "  \"decision\": " +
  json_string(if decision == "" { "pending" } else { decision }) +
  ",\n" +
  "  \"reason\": " +
  json_string(reason) +
  "\n" +
  "}\n"
}

///|
fn llm_sim_compile_observation_markdown(
  request_id : String,
  report : @core.ArtifactCompileReport,
) -> String {
  "# llm-sim compile observation\n\n" +
  "- request_id: `" +
  request_id +
  "`\n" +
  "- compile_ok: `" +
  (if report.ok { "true" } else { "false" }) +
  "`\n" +
  "- stage: `" +
  report.stage +
  "`\n" +
  "- summary_kind: `" +
  report.summary_kind +
  "`\n" +
  "- primary_file: `" +
  report.primary_file +
  "`\n" +
  "- primary_line: `" +
  report.primary_line.to_string() +
  "`\n\n" +
  "## Note\n\n" +
  report.note +
  "\n\n" +
  "## Likely Cause\n\n" +
  (if report.likely_cause == "" { "None." } else { report.likely_cause }) +
  "\n\n" +
  "## Repair Hint\n\n" +
  (if report.repair_hint == "" {
    "No repair hint needed."
  } else {
    report.repair_hint
  }) +
  "\n"
}

///|
fn llm_sim_repair_request_body_from_report(
  source : String,
  report : @core.ArtifactCompileReport,
  task_kind : String,
  conversation_history_json : String,
) -> String {
  let system_prompt = "You are an AI coder.\n" +
    "You only write MoonBit code.\n" +
    "Your job is to repair MoonBit code for the user's task.\n" +
    "Return only the full contents of cmd/main/main.mbt."
  let task_prefix = if task_kind == "" || task_kind == "moonbit-task" {
    ""
  } else {
    "Task kind: " + task_kind + "\n\n"
  }
  let compiler_excerpt = if report.trimmed_output != "" {
    report.trimmed_output
  } else if report.summary_excerpt != "" {
    report.summary_excerpt
  } else {
    report.output
  }
  let repair_user_message = "The previous MoonBit file failed to compile under wasm-gc.\n\n" +
    task_prefix +
    "Compiler error:\n" +
    compiler_excerpt +
    "\n\nFix the file and return the full corrected cmd/main/main.mbt only."
  let conversation_with_source = append_json_message_array(
    conversation_history_json, "assistant", source,
  )
  let conversation_with_feedback = append_json_message_array(
    conversation_with_source, "user", repair_user_message,
  )
  "{\n" +
  "  \"model\": \"gpt-5.4\",\n" +
  "  \"messages\": [\n" +
  "    {\n" +
  "      \"role\": \"system\",\n" +
  "      \"content\": " +
  json_string(system_prompt) +
  "\n" +
  "    },\n" +
  conversation_with_feedback[1:conversation_with_feedback.length() - 1].to_string() +
  "  ],\n" +
  "  \"temperature\": 0.1\n" +
  "}\n"
}

///|
fn normalize_human_sim_action_payload(payload : String) -> String {
  let action = extract_json_string_field(payload, "action")
  let source = extract_json_string_field(payload, "source")
  let prompt = extract_json_string_field(payload, "prompt")
  let task_kind = extract_json_string_field(payload, "task_kind")
  let reason = extract_json_string_field(payload, "reason")
  let artifact_id = extract_json_string_field(payload, "artifact_id")
  let notes = extract_json_string_field(payload, "notes")
  "{\n" +
  "  \"action\": " +
  json_string(if action == "" { "unknown" } else { action }) +
  ",\n" +
  "  \"source\": " +
  json_string(if source == "" { "simulated-user-thread" } else { source }) +
  ",\n" +
  "  \"prompt\": " +
  json_string(prompt) +
  ",\n" +
  "  \"task_kind\": " +
  json_string(task_kind) +
  ",\n" +
  "  \"reason\": " +
  json_string(reason) +
  ",\n" +
  "  \"artifact_id\": " +
  json_string(artifact_id) +
  ",\n" +
  "  \"notes\": " +
  json_string(notes) +
  "\n" +
  "}\n"
}

///|
fn normalize_human_sim_intent_status_payload(payload : String) -> String {
  let status = extract_json_string_field(payload, "status")
  let assignee = extract_json_string_field(payload, "assignee")
  let notes = extract_json_string_field(payload, "notes")
  "{\n" +
  "  \"status\": " +
  json_string(if status == "" { "unknown" } else { status }) +
  ",\n" +
  "  \"assignee\": " +
  json_string(assignee) +
  ",\n" +
  "  \"notes\": " +
  json_string(notes) +
  "\n" +
  "}\n"
}

///|
fn llm_sim_request_body_from_intent(prompt : String) -> String {
  let system_prompt = "You are an AI coder.\n" +
    "You only write MoonBit code.\n" +
    "Your job is to write MoonBit code for the user's task.\n" +
    "Return only the full contents of cmd/main/main.mbt."
  let user_prompt = prompt
  "{\n" +
  "  \"model\": \"gpt-5.4\",\n" +
  "  \"messages\": [\n" +
  "    {\n" +
  "      \"role\": \"system\",\n" +
  "      \"content\": " +
  json_string(system_prompt) +
  "\n" +
  "    },\n" +
  "    {\n" +
  "      \"role\": \"user\",\n" +
  "      \"content\": " +
  json_string(user_prompt) +
  "\n" +
  "    }\n" +
  "  ],\n" +
  "  \"temperature\": 0.2\n" +
  "}\n"
}

///|
fn llm_sim_initial_conversation_history_json(prompt : String) -> String {
  "[\n" + json_message("user", prompt) + "\n]"
}

///|
fn human_sim_intent_json(normalized_payload : String) -> String {
  let prompt = extract_json_string_field(normalized_payload, "prompt")
  let task_kind = extract_json_string_field(normalized_payload, "task_kind")
  let source = extract_json_string_field(normalized_payload, "source")
  "{\n" +
  "  \"intent_kind\": \"submit-prompt\",\n" +
  "  \"prompt\": " +
  json_string(prompt) +
  ",\n" +
  "  \"task_kind\": " +
  json_string(if task_kind == "" { "moonbit-task" } else { task_kind }) +
  ",\n" +
  "  \"source\": " +
  json_string(source) +
  ",\n" +
  "  \"status\": \"captured\",\n" +
  "  \"next_owner\": \"developer-thread\"\n" +
  "}\n"
}

///|
async fn codex_threads_dev_manifest_json() -> String {
  let run_id = current_runtime_dir()
  let llm_root = llm_sim_root()
  let human_root = human_sim_root()
  let human_actions = human_sim_actions_dir()
  let human_feedback = human_sim_feedback_dir()
  let human_observations = human_sim_observations_dir()
  let human_state = human_sim_state_dir()
  let runtime_root = runtime_exec_root()
  let skill_root = skill_export_root()
  "{\n" +
  "  \"mode\": \"codex-threads-dev\",\n" +
  "  \"developer_thread_required\": true,\n" +
  "  \"enable_simulated_user_thread\": true,\n" +
  "  \"enable_simulated_llm_thread\": true,\n" +
  "  \"run_root\": " +
  json_string(run_id) +
  ",\n" +
  "  \"llm_sim_root\": " +
  json_string(llm_root) +
  ",\n" +
  "  \"human_sim_root\": " +
  json_string(human_root) +
  ",\n" +
  "  \"human_sim_actions_dir\": " +
  json_string(human_actions) +
  ",\n" +
  "  \"human_sim_feedback_dir\": " +
  json_string(human_feedback) +
  ",\n" +
  "  \"human_sim_observations_dir\": " +
  json_string(human_observations) +
  ",\n" +
  "  \"human_sim_state_dir\": " +
  json_string(human_state) +
  ",\n" +
  "  \"runtime_exec_root\": " +
  json_string(runtime_root) +
  ",\n" +
  "  \"skill_export_root\": " +
  json_string(skill_root) +
  ",\n" +
  "  \"docs\": [\n" +
  "    " +
  json_string("docs/modes/codex-threads-dev-mode.md") +
  ",\n" +
  "    " +
  json_string("docs/modes/codex-threads-dev/protocol-spec.md") +
  ",\n" +
  "    " +
  json_string("docs/modes/codex-threads-dev/developer-thread.md") +
  ",\n" +
  "    " +
  json_string("docs/modes/codex-threads-dev/simulated-user-thread.md") +
  ",\n" +
  "    " +
  json_string("docs/modes/codex-threads-dev/simulated-llm-thread.md") +
  "\n" +
  "  ]\n" +
  "}\n"
}

///|
async fn serve_runtime_exec_request_artifact(
  conn : @http.ServerConnection,
  path : String,
) -> Unit {
  let run_id = query_param(path, "run_id")
  let request_id = query_param(path, "request_id")
  let kind = query_param(path, "kind")
  let name = query_param(path, "name")
  let file_path = runtime_exec_request_artifact_path(
    run_id, request_id, kind, name,
  )
  if file_path == "" {
    send_json(
      conn, 404, "{\n  \"ok\": false,\n  \"error\": \"Runtime artifact was not found.\"\n}\n",
    )
    return
  }
  serve_static_file(
    conn,
    file_path,
    runtime_exec_artifact_content_type(kind, name),
  )
}

///|
async fn runtime_exec_request_artifact_path(
  run_id : String,
  request_id : String,
  kind : String,
  name : String,
) -> String {
  guard request_id != "" else { return "" }
  let request_dir = (if run_id == "" {
      runtime_exec_root()
    } else {
      "logs/runs/" + run_id + "/runtime-exec"
    }) +
    "/requests/" +
    request_id
  if !@fs.exists(request_dir) {
    return ""
  }
  if kind == "source" {
    let path = request_dir + "/main.mbt"
    if @fs.exists(path) {
      path
    } else {
      ""
    }
  } else if kind == "compile-report" {
    let path = request_dir + "/compile-report.json"
    if @fs.exists(path) {
      path
    } else {
      ""
    }
  } else if kind == "raw-response" {
    let path = request_dir + "/raw-response.txt"
    if @fs.exists(path) {
      path
    } else {
      ""
    }
  } else if kind == "result" {
    let path = request_dir + "/result.json"
    if @fs.exists(path) {
      path
    } else {
      ""
    }
  } else if kind == "stdout" {
    let path = request_dir + "/stdout.txt"
    if @fs.exists(path) {
      path
    } else {
      ""
    }
  } else if kind == "error" {
    let path = request_dir + "/error.txt"
    if @fs.exists(path) {
      path
    } else {
      ""
    }
  } else if kind == "download" {
    let file_name = if name == "" { "download.txt" } else { name }
    let path = request_dir + "/" + file_name
    if @fs.exists(path) {
      path
    } else {
      ""
    }
  } else if kind == "wasm" {
    let report_json = read_text_or_default(
      request_dir + "/compile-report.json",
      "",
    )
    let wasm_path = extract_json_string_field(report_json, "wasm_path")
    if wasm_path != "" && @fs.exists(wasm_path) {
      wasm_path
    } else {
      let fallback = request_dir + "/main.wasm"
      if @fs.exists(fallback) {
        fallback
      } else {
        ""
      }
    }
  } else {
    ""
  }
}

///|
fn runtime_exec_artifact_content_type(kind : String, name : String) -> String {
  if kind == "wasm" {
    "application/wasm"
  } else if kind == "source" {
    "text/plain; charset=utf-8"
  } else if kind == "compile-report" || kind == "result" {
    "application/json; charset=utf-8"
  } else if kind == "raw-response" || kind == "stdout" || kind == "error" {
    "text/plain; charset=utf-8"
  } else if kind == "download" && name.has_suffix(".json") {
    "application/json; charset=utf-8"
  } else {
    "text/plain; charset=utf-8"
  }
}

///|
fn query_param(path : String, key : String) -> String {
  guard path.find("?") is Some(query_start) else { return "" }
  let query = path[query_start + 1:]
  for item in query.split("&") {
    let prefix = key + "="
    if item.has_prefix(prefix) {
      return item[prefix.length():].to_string()
    }
  }
  ""
}

///|
fn run_id_from_dir(dir : String) -> String {
  let mut last = dir
  for part in dir.split("/") {
    last = part.to_string()
  }
  last
}

///|
async fn codex_threads_dev_coordination_json() -> String {
  let intent_json = read_text_or_default(
    human_sim_state_dir() + "/latest-intent.json",
    "{\n  \"status\": \"empty\"\n}\n",
  )
  let intent_status_json = read_text_or_default(
    human_sim_state_dir() + "/latest-intent-status.json",
    "{\n  \"status\": \"unknown\"\n}\n",
  )
  let llm_request_json = latest_llm_sim_request_json_or_default()
  let llm_response_json = latest_llm_sim_response_status_json()
  let runtime_request_json = read_text_or_default(
    runtime_exec_root() + "/latest-request.json",
    "{\n  \"status\": \"empty\"\n}\n",
  )
  let runtime_result_json = read_text_or_default(
    runtime_exec_root() + "/latest-result.json",
    "{\n  \"status\": \"empty\"\n}\n",
  )
  let save_decision_json = read_text_or_default(
    skill_export_root() + "/save-decision.json",
    "{\n  \"decision\": \"unset\"\n}\n",
  )
  let prompt = extract_json_string_field(intent_json, "prompt")
  let intent_status = extract_json_string_field(intent_status_json, "status")
  let llm_request_id = extract_json_string_field(llm_request_json, "request_id")
  let llm_request_stage = extract_json_string_field(llm_request_json, "stage")
  let llm_reply_path = extract_json_string_field(llm_request_json, "reply_path")
  let llm_error_path = extract_json_string_field(llm_request_json, "error_path")
  let llm_response_request_id = extract_json_string_field(
    llm_response_json, "request_id",
  )
  let runtime_request_id = extract_json_string_field(
    runtime_request_json, "request_id",
  )
  let runtime_request_status = extract_json_string_field(
    runtime_request_json, "status",
  )
  let runtime_result_request_id = extract_json_string_field(
    runtime_result_json, "request_id",
  )
  let runtime_result_status = extract_json_string_field(
    runtime_result_json, "status",
  )
  let save_decision_request_id = extract_json_string_field(
    save_decision_json, "request_id",
  )
  let save_decision = extract_json_string_field(save_decision_json, "decision")
  let llm_response_ready = llm_reply_path != "" && @fs.exists(llm_reply_path)
  let llm_error_ready = llm_error_path != "" && @fs.exists(llm_error_path)
  let developer_status = if prompt != "" &&
    intent_status != "dispatched" &&
    intent_status != "completed" {
    "needs-dispatch"
  } else if llm_request_id != "" &&
    (llm_response_ready || llm_error_ready) &&
    llm_response_request_id != llm_request_id {
    "needs-process-llm-response"
  } else {
    "idle"
  }
  let developer_prompt = if developer_status == "needs-dispatch" {
    "Call POST /api/human-sim/dispatch-latest-intent once to convert the captured human intent into a new llm-sim request."
  } else if developer_status == "needs-process-llm-response" {
    "Call POST /api/llm-sim/process-latest-response once to compile the newest llm-sim response and continue the flow."
  } else {
    "No developer action is required right now."
  }
  let llm_status = if llm_request_id != "" &&
    !llm_response_ready &&
    !llm_error_ready {
    "needs-reply"
  } else {
    "idle"
  }
  let llm_prompt = if llm_status == "needs-reply" {
    "Read /api/llm-sim/latest-request once. Read the raw_body messages before answering. Treat those messages as the source of truth. Do not use keyword templates or canned task handlers. If the request_id is new, write only the next MoonBit code response to the reply_path and then stop."
  } else {
    "No llm-sim reply is needed right now."
  }
  let user_status = if runtime_request_id != "" &&
    runtime_request_status == "ready-for-runtime" &&
    runtime_result_request_id != runtime_request_id {
    "needs-runtime-result"
  } else if runtime_result_request_id != "" &&
    runtime_result_status.contains("succeeded") &&
    save_decision_request_id != runtime_result_request_id &&
    save_decision != "accepted-save-skill" &&
    save_decision != "rejected-save-skill" {
    "needs-save-decision"
  } else {
    "idle"
  }
  let user_prompt = if user_status == "needs-runtime-result" {
    "Inspect /api/runtime-exec/latest-request once. Then submit one runtime result through POST /api/task/execute and stop."
  } else if user_status == "needs-save-decision" {
    "Inspect /api/runtime-exec/latest-result once. Then decide whether to save as a SKILL through POST /api/skill-export/save-decision and stop."
  } else {
    "No simulated-user action is required right now."
  }
  let wake_order = if developer_status != "idle" {
    "[\"developer-thread\"]"
  } else if llm_status != "idle" {
    "[\"simulated-llm-thread\"]"
  } else if user_status != "idle" {
    "[\"simulated-user-thread\"]"
  } else {
    "[]"
  }
  "{\n" +
  "  \"mode\": \"codex-threads-dev\",\n" +
  "  \"developer\": {\n" +
  "    \"status\": " +
  json_string(developer_status) +
  ",\n" +
  "    \"prompt\": " +
  json_string(developer_prompt) +
  "\n" +
  "  },\n" +
  "  \"simulated_llm\": {\n" +
  "    \"status\": " +
  json_string(llm_status) +
  ",\n" +
  "    \"request_id\": " +
  json_string(llm_request_id) +
  ",\n" +
  "    \"stage\": " +
  json_string(llm_request_stage) +
  ",\n" +
  "    \"prompt\": " +
  json_string(llm_prompt) +
  "\n" +
  "  },\n" +
  "  \"simulated_user\": {\n" +
  "    \"status\": " +
  json_string(user_status) +
  ",\n" +
  "    \"request_id\": " +
  json_string(runtime_request_id) +
  ",\n" +
  "    \"prompt\": " +
  json_string(user_prompt) +
  "\n" +
  "  },\n" +
  "  \"wake_order\": " +
  wake_order +
  ",\n" +
  "  \"observed\": {\n" +
  "    \"intent_status\": " +
  json_string(intent_status) +
  ",\n" +
  "    \"llm_response_request_id\": " +
  json_string(llm_response_request_id) +
  ",\n" +
  "    \"runtime_result_request_id\": " +
  json_string(runtime_result_request_id) +
  ",\n" +
  "    \"save_decision\": " +
  json_string(save_decision) +
  "\n" +
  "  }\n" +
  "}\n"
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
  if is_llm_sim_url(url) {
    return handle_llm_sim_proxy(url, body)
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
fn is_llm_sim_url(url : String) -> Bool {
  url.has_prefix("moonap://llm-sim") ||
  url.has_prefix("http://moonap.llm-sim") ||
  url.has_prefix("https://moonap.llm-sim") ||
  url.has_prefix("moonap://codex-demo")
}

///|
async fn handle_llm_sim_proxy(url : String, body : String) -> (Int, String) {
  let model = extract_json_string_field(body, "model")
  let model_name = if model == "" { "gpt-5.4" } else { model }
  let stage = infer_llm_sim_stage(body)
  let (request_id, _, response_path, error_path) = create_llm_sim_request(
    "openai", model_name, stage, url, body, "", "", "[]",
  )
  if stage == "api-test" {
    return (200, openai_chat_completion_payload(model_name, "OK", request_id))
  }
  wait_for_llm_sim_response(request_id, model_name, response_path, error_path)
}

///|
async fn create_llm_sim_request(
  provider : String,
  model_name : String,
  stage : String,
  url : String,
  body : String,
  original_prompt : String,
  task_kind : String,
  conversation_history_json : String,
) -> (String, String, String, String) {
  let request_id = "llm-sim-" + @core.async_runtime_marker().to_string()
  let inbox_dir = llm_sim_inbox_dir()
  let outbox_dir = llm_sim_outbox_dir()
  let state_dir = llm_sim_state_dir()
  ensure_directory(inbox_dir)
  ensure_directory(outbox_dir)
  ensure_directory(state_dir)
  let response_path = outbox_dir + "/" + request_id + ".response.txt"
  let error_path = outbox_dir + "/" + request_id + ".error.txt"
  let request_json_path = inbox_dir + "/" + request_id + ".json"
  let request_text_path = inbox_dir + "/" + request_id + ".txt"
  let request_json = "{\n" +
    "  \"request_id\": " +
    json_string(request_id) +
    ",\n" +
    "  \"provider\": " +
    json_string(provider) +
    ",\n" +
    "  \"model\": " +
    json_string(model_name) +
    ",\n" +
    "  \"stage\": " +
    json_string(stage) +
    ",\n" +
    "  \"original_prompt\": " +
    json_string(original_prompt) +
    ",\n" +
    "  \"task_kind\": " +
    json_string(task_kind) +
    ",\n" +
    "  \"conversation_history_json\": " +
    json_string(conversation_history_json) +
    ",\n" +
    "  \"url\": " +
    json_string(url) +
    ",\n" +
    "  \"reply_path\": " +
    json_string(response_path) +
    ",\n" +
    "  \"error_path\": " +
    json_string(error_path) +
    ",\n" +
    "  \"raw_body\": " +
    json_string(body) +
    "\n" +
    "}\n"
  let request_text = "MoonAP LLM-sim request\n" +
    "request_id: " +
    request_id +
    "\n" +
    "provider: " +
    provider +
    "\n" +
    "model: " +
    model_name +
    "\n" +
    "stage: " +
    stage +
    "\n" +
    "original_prompt: " +
    original_prompt +
    "\n" +
    "task_kind: " +
    task_kind +
    "\n" +
    "conversation_history_json: " +
    conversation_history_json +
    "\n" +
    "reply_path: " +
    response_path +
    "\n" +
    "error_path: " +
    error_path +
    "\n\n" +
    "worker_contract:\n" +
    "- read the raw_body messages below before generating any response\n" +
    "- use the request messages as the source of truth\n" +
    "- do not answer from task-keyword templates or cached canned code\n" +
    "- write only the next code response to reply_path\n\n" +
    "raw_body:\n" +
    body +
    "\n"
  @fs.write_file(request_json_path, request_json, create=0o644)
  @fs.write_file(request_text_path, request_text, create=0o644)
  @fs.write_file(
    state_dir + "/latest-request.txt",
    request_text_path + "\n",
    create=0o644,
  )
  append_text_file(
    runtime_log_directory(),
    runtime_log_path(),
    "{\"ts\":" +
    json_string(request_id) +
    ",\"kind\":\"llm-sim\",\"label\":\"request-created\",\"text\":" +
    json_string(stage + " -> " + request_text_path) +
    "}\n",
  )
  (request_id, request_text_path, response_path, error_path)
}

///|
async fn append_text_file(
  directory : String,
  path : String,
  payload : String,
) -> Unit {
  if directory != "" && !@fs.exists(directory) {
    @fs.mkdir(directory, recursive=true, permission=0o755)
  }
  let existing = if @fs.exists(path) { @fs.read_file(path).text() } else { "" }
  @fs.write_file(path, existing + payload, create=0o644)
}

///|
async fn wait_for_llm_sim_response(
  request_id : String,
  model : String,
  response_path : String,
  error_path : String,
) -> (Int, String) {
  wait_for_llm_sim_response_from(
    request_id,
    model,
    response_path,
    error_path,
    @async.now(),
    1000 * 60 * 20,
  )
}

///|
async fn wait_for_llm_sim_response_from(
  request_id : String,
  model : String,
  response_path : String,
  error_path : String,
  started : Int64,
  timeout_ms : Int,
) -> (Int, String) {
  if @fs.exists(response_path) {
    let content = @fs.read_file(response_path).text()
    append_text_file(
      runtime_log_directory(),
      runtime_log_path(),
      "{\"ts\":" +
      json_string(request_id) +
      ",\"kind\":\"llm-sim\",\"label\":\"response-received\",\"text\":" +
      json_string(response_path) +
      "}\n",
    )
    (200, openai_chat_completion_payload(model, content, request_id))
  } else if @fs.exists(error_path) {
    let detail = @fs.read_file(error_path).text()
    append_text_file(
      runtime_log_directory(),
      runtime_log_path(),
      "{\"ts\":" +
      json_string(request_id) +
      ",\"kind\":\"llm-sim\",\"label\":\"response-error\",\"text\":" +
      json_string(detail) +
      "}\n",
    )
    proxy_error_payload(502, "LLM-sim response failed.", response_path, detail)
  } else if (@async.now() - started).to_int() >= timeout_ms {
    let detail = "Timed out waiting for LLM-sim response file.\n" +
      "Write the MoonBit response to: " +
      response_path +
      "\n" +
      "Or write an error to: " +
      error_path
    append_text_file(
      runtime_log_directory(),
      runtime_log_path(),
      "{\"ts\":" +
      json_string(request_id) +
      ",\"kind\":\"llm-sim\",\"label\":\"response-timeout\",\"text\":" +
      json_string(detail) +
      "}\n",
    )
    proxy_error_payload(
      504, "LLM-sim response timed out.", response_path, detail,
    )
  } else {
    @async.sleep(250)
    wait_for_llm_sim_response_from(
      request_id, model, response_path, error_path, started, timeout_ms,
    )
  }
}

///|
fn infer_llm_sim_stage(body : String) -> String {
  let lowered = body.to_lower()
  if lowered.contains("reply with ok") {
    "api-test"
  } else if lowered.contains("repair") ||
    lowered.contains("compiler failure") ||
    lowered.contains("compile-error summarizer") {
    "repair"
  } else {
    "codegen"
  }
}

///|
fn extract_json_string_field(body : String, key : String) -> String {
  let marker = "\"" + key + "\""
  guard body.find(marker) is Some(start) else { return "" }
  let after_key = body[start + marker.length():]
  guard after_key.find(":") is Some(colon) else { return "" }
  let after_colon = after_key[colon + 1:].trim().to_string()
  if !after_colon.has_prefix("\"") {
    return ""
  }
  let source = after_colon[1:]
  guard source.find("\"") is Some(end) else { return "" }
  source[:end].to_string()
}

///|
fn extract_json_bool_field(body : String, key : String) -> Bool {
  let marker = "\"" + key + "\""
  guard body.find(marker) is Some(start) else { return false }
  let after_key = body[start + marker.length():]
  guard after_key.find(":") is Some(colon) else { return false }
  let after_colon = after_key[colon + 1:].trim().to_string()
  after_colon.has_prefix("true")
}

///|
fn openai_chat_completion_payload(
  model : String,
  content : String,
  request_id : String,
) -> String {
  "{\n" +
  "  \"id\": " +
  json_string(request_id) +
  ",\n" +
  "  \"object\": \"chat.completion\",\n" +
  "  \"created\": " +
  @core.async_runtime_marker().to_string() +
  ",\n" +
  "  \"model\": " +
  json_string(model) +
  ",\n" +
  "  \"choices\": [\n" +
  "    {\n" +
  "      \"index\": 0,\n" +
  "      \"message\": {\n" +
  "        \"role\": \"assistant\",\n" +
  "        \"content\": " +
  json_string(content) +
  "\n" +
  "      },\n" +
  "      \"finish_reason\": \"stop\"\n" +
  "    }\n" +
  "  ]\n" +
  "}\n"
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
    "<div class=\"router-grid\">", "<div class=\"router-row\"><div class=\"router-row-head\"><span class=\"router-level\">Level 1</span><input id=\"routerEnableOpenAI\" type=\"checkbox\" checked /><strong>OpenAI</strong></div><div class=\"router-level-label\">Level 2 - Models</div><div id=\"routerModelsOpenAI\" class=\"router-model-list\"></div><label>Base URL<input id=\"routerBaseOpenAI\" value=\"moonap://llm-sim\" /></label><label>API key<input id=\"routerKeyOpenAI\" type=\"password\" value=\"llm-sim-mode\" placeholder=\"llm-sim-mode\" /></label></div>",
    "<div class=\"router-row\"><div class=\"router-row-head\"><span class=\"router-level\">Level 1</span><input id=\"routerEnableNVIDIA\" type=\"checkbox\" checked /><strong>NVIDIA</strong></div><div class=\"router-level-label\">Level 2 - Models</div><div id=\"routerModelsNVIDIA\" class=\"router-model-list\"></div><label>Base URL<input id=\"routerBaseNVIDIA\" value=\"https://integrate.api.nvidia.com/v1\" /></label><label>API key<input id=\"routerKeyNVIDIA\" type=\"password\" placeholder=\"Paste NVIDIA API key\" /></label></div>",
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
    ".action-card { display: none; gap: 12px; max-width: 720px; padding: 18px 20px; border: 1px solid #dfe7e3; border-radius: 18px; background: #f7fbf9; box-shadow: 0 14px 34px rgba(22, 38, 31, 0.05); }",
    ".action-card.is-open { display: grid; }", ".action-card strong { font-size: 16px; line-height: 1.3; }",
    ".action-card small { color: #56615b; line-height: 1.55; }", ".action-card-meta { display: flex; flex-wrap: wrap; gap: 8px; }",
    ".action-card-meta span { border-radius: 999px; padding: 5px 10px; background: #eef5f1; color: #24523f; font-size: 12px; }",
    ".action-card-actions { display: flex; flex-wrap: wrap; gap: 10px; }", ".action-card button { justify-self: start; min-height: 40px; border: 1px solid #111111; border-radius: 999px; padding: 0 16px; background: #111111; color: #ffffff; cursor: pointer; }",
    ".action-card button.secondary { border-color: #d8d8d8; background: #ffffff; color: #111111; }",
    ".action-card-runtime { gap: 14px; border-color: #d7e6df; background: linear-gradient(180deg, #f6fbf8 0%, #eef6f1 100%); box-shadow: 0 18px 42px rgba(41, 76, 60, 0.08); }",
    ".action-card-runtime.is-complete { border-color: #d1e4da; background: linear-gradient(180deg, #f7fbf7 0%, #edf6ef 100%); }",
    ".action-card-eyebrow { font-size: 12px; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase; color: #2f5d4b; }",
    ".action-card-status { display: flex; flex-wrap: wrap; gap: 8px; }", ".action-card-status span { border-radius: 999px; padding: 6px 10px; background: #e5f1ea; color: #24523f; font-size: 12px; }",
    ".action-card-params { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px 12px; padding: 12px; border: 1px solid #dbe7e0; border-radius: 14px; background: rgba(255,255,255,0.68); }",
    ".action-card-params label { display: grid; gap: 6px; font-size: 12px; color: #335748; }",
    ".action-card-params label span { font-weight: 600; }", ".action-card-params input { width: 100%; min-height: 38px; border: 1px solid #d0ddd6; border-radius: 10px; padding: 0 12px; background: #ffffff; color: #14261d; font: inherit; }",
    ".action-card-primary, .action-card-secondary { display: flex; flex-wrap: wrap; gap: 10px; }",
    ".action-card-primary button.primary { background: #111111; color: #ffffff; border-color: #111111; }",
    ".action-card-secondary { padding-top: 2px; }", ".action-card-secondary button.secondary { background: rgba(255,255,255,0.84); border-color: #d4dfd8; color: #193529; }",
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
