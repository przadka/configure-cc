# Status Line

Custom status bar at the bottom of Claude Code. Runs a shell script, displays whatever it prints.

**Official docs:** https://code.claude.com/docs/en/statusline

## Quick setup

```
/statusline show model name and context percentage with a progress bar
```

CC generates the script and updates settings automatically.

## Manual setup

### 1. Create a script

```bash
#!/bin/bash
input=$(cat)
MODEL=$(echo "$input" | jq -r '.model.display_name')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
echo "[$MODEL] ${PCT}% context"
```

### 2. Make executable

```bash
chmod +x ~/.claude/statusline.sh
```

### 3. Add to settings.json

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

`padding` is optional (default `0`), adds horizontal spacing.

## How it works

- CC pipes JSON session data to your script via **stdin**
- Script reads JSON, extracts fields, prints to **stdout**
- Updates after each assistant message (debounced 300ms)
- Multiple `echo` statements = multiple rows
- Supports ANSI colors and OSC 8 clickable links

## Available JSON fields

| Field | Description |
|-------|-------------|
| `model.id`, `model.display_name` | Current model |
| `workspace.current_dir` | Current working directory |
| `workspace.project_dir` | Directory where CC was launched |
| `cost.total_cost_usd` | Session cost in USD |
| `cost.total_duration_ms` | Wall-clock time since session start |
| `cost.total_api_duration_ms` | Time waiting for API responses |
| `cost.total_lines_added/removed` | Lines changed |
| `context_window.used_percentage` | Context usage (pre-calculated) |
| `context_window.remaining_percentage` | Context remaining |
| `context_window.context_window_size` | Max tokens (200k or 1M) |
| `context_window.current_usage` | Token counts from last API call |
| `exceeds_200k_tokens` | Whether last response exceeded 200k |
| `rate_limits.five_hour.used_percentage` | 5-hour rate limit % (Pro/Max only) |
| `rate_limits.seven_day.used_percentage` | 7-day rate limit % (Pro/Max only) |
| `session_id`, `session_name` | Session identifiers |
| `transcript_path` | Path to conversation transcript |
| `version` | CC version |
| `vim.mode` | `NORMAL` or `INSERT` (when vim mode on) |
| `agent.name` | Agent name (when using `--agent`) |
| `worktree.*` | Worktree info (name, path, branch) |

**May be absent:** `session_name`, `vim`, `agent`, `worktree`, `rate_limits`
**May be null:** `context_window.current_usage` (before first API call), `used_percentage` (early in session)

## Inline command (no script file)

```json
{
  "statusLine": {
    "type": "command",
    "command": "jq -r '\"[\\(.model.display_name)] \\(.context_window.used_percentage // 0)% context\"'"
  }
}
```

## Patterns

### Color-coded context bar

```bash
if [ "$PCT" -ge 90 ]; then COLOR='\033[31m'    # red
elif [ "$PCT" -ge 70 ]; then COLOR='\033[33m'   # yellow
else COLOR='\033[32m'; fi                        # green
```

### Git branch with status

```bash
BRANCH=$(git branch --show-current 2>/dev/null)
STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
```

### Clickable links (OSC 8)

```bash
printf '%b' "\e]8;;${URL}\a${TEXT}\e]8;;\a\n"
```

Requires iTerm2, Kitty, or WezTerm.

### Cache slow operations

```bash
CACHE_FILE="/tmp/statusline-git-cache"
CACHE_MAX_AGE=5
if [ ! -f "$CACHE_FILE" ] || [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -gt $CACHE_MAX_AGE ]; then
    # refresh cache
fi
```

Use a fixed filename — not `$$` (PID changes every invocation).

## Testing

```bash
echo '{"model":{"display_name":"Opus"},"context_window":{"used_percentage":42}}' | ~/.claude/statusline.sh
```

## Disable

```
/statusline remove
```

Or delete `statusLine` from settings.json.

## Troubleshooting

- **Not appearing:** Check `chmod +x`, verify stdout output, check `disableAllHooks` isn't `true`
- **Shows `--`:** Fields are null before first API response — use fallbacks like `// 0` in jq
- **Links not clickable:** Terminal must support OSC 8 (not Terminal.app)
- **Workspace trust:** Must accept trust dialog — restart CC if you see "statusline skipped"
- **Debug:** Run `claude --debug` to see exit code and stderr from first invocation

## Community

- [ccstatusline](https://github.com/sirmalloc/ccstatusline) — pre-built configs with themes
- [starship-claude](https://github.com/martinemde/starship-claude) — Starship-style status line
