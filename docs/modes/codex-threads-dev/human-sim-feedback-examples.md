# Human-sim Feedback Examples

This document gives the simulated user thread concrete feedback payload examples.

## accept-output

```json
{
  "feedback": "accept-output",
  "source": "simulated-user-thread",
  "summary": "The result looks correct enough for this task.",
  "artifact_id": "moonbit-task"
}
```

## reject-output

```json
{
  "feedback": "reject-output",
  "source": "simulated-user-thread",
  "summary": "The program compiles, but the visible result is still wrong.",
  "artifact_id": "moonbit-task"
}
```

## semantic-feedback

```markdown
# semantic-feedback

source: simulated-user-thread
artifact_id: moonbit-task

The generated FastQ is close, but I want the header and quality line to look more explicit.
Keep the task goal and preserve compilability.
```
