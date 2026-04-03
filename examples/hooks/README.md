# Hook Examples

Hooks run shell commands at lifecycle events. Add them to `.claude/settings.json` (shared) or `.claude/settings.local.json` (personal).

## Hook Types

| Hook | When it fires |
|------|--------------|
| `PreToolUse` | Before a tool runs — can block it |
| `PostToolUse` | After a tool completes |
| `InstructionsLoaded` | When CLAUDE.md / rules files load (useful for debugging) |

## Matcher Syntax

- `Bash(git push *)` — matches Bash tool calls starting with `git push`
- `Write\|Edit` — matches Write or Edit tool calls
- `*` — matches everything

## Practical Hook Ideas

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

**Block dangerous commands:**
```json
{
  "matcher": "Bash(rm -rf *)",
  "hooks": [{ "type": "command", "command": "echo 'BLOCKED: rm -rf is not allowed' && exit 1" }]
}
```

## Setup

Copy the hook config into your project's `.claude/settings.json`:

```bash
# If you don't have one yet:
mkdir -p .claude
cp examples/hooks/settings-with-hooks.json .claude/settings.json

# Or merge into existing settings.json
```

See [official hooks docs](https://code.claude.com/docs/en/hooks) for the full reference.
