# Human-sim Action Examples

This document gives the simulated user thread concrete payload examples.

## submit-prompt

```json
{
  "action": "submit-prompt",
  "source": "simulated-user-thread",
  "prompt": "Generate a FastQ file generator",
  "task_kind": "moonbit-task",
  "notes": "Use Codex-threads-dev mode default path."
}
```

## refresh-page

```json
{
  "action": "refresh-page",
  "source": "simulated-user-thread",
  "reason": "Need the latest frontend bundle and process state."
}
```

## save-router

```json
{
  "action": "save-router",
  "source": "simulated-user-thread",
  "provider": "openai",
  "model": "gpt-5.4",
  "base_url": "moonap://codex-demo",
  "api_key_hint": "codex-demo-mode"
}
```

## request-save-skill

```json
{
  "action": "request-save-skill",
  "source": "simulated-user-thread",
  "artifact_id": "moonbit-task",
  "reason": "The current result is acceptable and should be reusable."
}
```
