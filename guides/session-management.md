# Session Management Cheatsheet

## Core Commands

| Command | What it does | When to use |
|---------|-------------|-------------|
| `/fork` | New session with full conversation history | Parallel tasks from shared context |
| `/rewind` or `Esc+Esc` | Restore code and/or conversation to earlier point | Claude went off track, undo mistakes |
| `/compact` | Compress context, CLAUDE.md reloaded fresh | Session getting sluggish |
| `/resume` or `claude --continue` | Resume previous session | Coming back to unfinished work |

## /fork patterns

**Pre-warming:** Load a master session with architecture context, then fork for each feature:
```bash
# Terminal 1: master session with full context loaded
claude

# Terminal 2: fork for a specific feature
claude --continue --fork-session
```

**Parallel exploration:** Try two approaches to the same problem without losing either.

## /rewind options

When you activate rewind, you choose what to restore:
- **Code only** — undo file changes, keep conversation
- **Conversation only** — roll back discussion, keep file changes
- **Both** — full reset to that point

Limitation: can't undo bash side effects (git push, rm, database changes).

## /compact tips

- CLAUDE.md survives compaction — it's reloaded from disk
- Instructions given only in conversation do NOT survive — add them to CLAUDE.md if they matter
- Use when you notice Claude forgetting instructions or repeating mistakes

## Session resume

```bash
# List recent sessions
claude --list

# Continue the most recent session
claude --continue

# Continue a specific session
claude --continue --session <session-id>
```
