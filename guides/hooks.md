# Hooks

Hooks run shell commands at Claude Code lifecycle events. Add them to `.claude/settings.json` (shared) or `.claude/settings.local.json` (personal). For global hooks, use `~/.claude/settings.json`.

## Hook Types

| Hook | When it fires |
|------|--------------|
| `PreToolUse` | Before a tool runs — can block it |
| `PostToolUse` | After a tool completes |
| `InstructionsLoaded` | When CLAUDE.md / rules files load |

## Matcher Syntax

- `Bash(git push *)` — matches Bash calls starting with `git push`
- `Write\|Edit` — matches Write or Edit tool calls
- `*` — matches everything

## Common Patterns

**Block dangerous commands:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(rm -rf *)",
        "hooks": [{ "type": "command", "command": "echo 'BLOCKED: rm -rf requires manual confirmation' && exit 1" }]
      },
      {
        "matcher": "Bash(git push --force*)",
        "hooks": [{ "type": "command", "command": "echo 'BLOCKED: force push not allowed' && exit 1" }]
      }
    ]
  }
}
```

**Pre-commit type check (TypeScript):**
```json
{
  "matcher": "Bash(git commit *)",
  "hooks": [{ "type": "command", "command": "npx tsc --noEmit" }]
}
```

**Pre-commit lint (Python):**
```json
{
  "matcher": "Bash(git commit *)",
  "hooks": [{ "type": "command", "command": "uv run ruff check ." }]
}
```

## Where to put hooks

| File | Scope |
|------|-------|
| `~/.claude/settings.json` | All projects (global) |
| `.claude/settings.json` | This project (shared with team) |
| `.claude/settings.local.json` | This project (personal) |

See [official hooks docs](https://code.claude.com/docs/en/hooks) for the full reference. Example JSON configs in `examples/hooks/`.
