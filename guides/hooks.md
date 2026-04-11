# Hooks

Hooks run shell commands at Claude Code lifecycle events. Add them to `.claude/settings.json` (shared) or `.claude/settings.local.json` (personal). For global hooks, use `~/.claude/settings.json`.

## Hook Types

| Hook | When it fires |
|------|--------------|
| `PreToolUse` | Before a tool runs — can block it |
| `PostToolUse` | After a tool completes |
| `InstructionsLoaded` | When CLAUDE.md / rules files load |

## Matcher Syntax

- `Bash` — matches all Bash tool calls
- `Write|Edit` — matches Write or Edit tool calls
- `*` — matches everything

## How blocking works

PreToolUse hooks receive the tool input as JSON on stdin. Use `jq` to extract the command, then check it with `grep`. To block, print a JSON object with `decision` and `reason`:

```json
{ "decision": "block", "reason": "Why this was blocked" }
```

If the hook prints nothing (or no decision), the tool call proceeds.

## Common Patterns

**Block `git add .` and `git add -A`** — force explicit file paths:
```json
{
  "matcher": "Bash",
  "hooks": [{
    "type": "command",
    "command": "jq -r '.tool_input.command' | { read -r cmd; if echo \"$cmd\" | grep -qE '(^|&& |; )git add (\\. |\\.$|\\./? &&|\\./? ;|(-A|--all))'; then echo \"{\\\"decision\\\":\\\"block\\\",\\\"reason\\\":\\\"Use explicit file paths with git add.\\\"}\"; fi; }"
  }]
}
```

**Block force push to main/master:**
```json
{
  "matcher": "Bash",
  "hooks": [{
    "type": "command",
    "command": "jq -r '.tool_input.command' | { read -r cmd; if echo \"$cmd\" | grep -qP '^git push\\b.*(-f\\b|--force\\b)' && echo \"$cmd\" | grep -qP '^git push\\b.*\\b(main|master)\\b'; then echo \"{\\\"decision\\\":\\\"block\\\",\\\"reason\\\":\\\"Force push to main/master is blocked.\\\"}\"; fi; }"
  }]
}
```

**Block `rm -rf` on critical paths:**
```json
{
  "matcher": "Bash",
  "hooks": [{
    "type": "command",
    "command": "jq -r '.tool_input.command' | { read -r cmd; if echo \"$cmd\" | grep -qP 'rm\\s+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)\\s+(/(?:\\s|$)|~/?(?:\\s|$)|\\$HOME/?(?:\\s|$)|/(?:bin|etc|usr|var)/?(?:\\s|$)|/home(?:/[^/\\s]+)?/?(?:\\s|$))'; then echo \"{\\\"decision\\\":\\\"block\\\",\\\"reason\\\":\\\"Blocked rm -rf targeting a critical path.\\\"}\"; fi; }"
  }]
}
```

> **Gotcha: path-prefix matching.** A naive pattern like `/home` will also block `rm -rf /home/user/.cache/old-stuff`. The pattern above anchors each protected path to end-of-argument (`(?:\s|$)`) so it only blocks the exact directory — `rm -rf /home` and `rm -rf /home/user` are blocked, but `rm -rf /home/user/tmp/build` is allowed.

## Where to put hooks

| File | Scope |
|------|-------|
| `~/.claude/settings.json` | All projects (global) |
| `.claude/settings.json` | This project (shared with team) |
| `.claude/settings.local.json` | This project (personal) |

See [official hooks docs](https://code.claude.com/docs/en/hooks) for the full reference. Example JSON configs in `examples/hooks/`.
