# Memory & /insights

## Two memory systems

| | CLAUDE.md | Auto memory |
|---|-----------|------------|
| **Who writes** | You | Claude |
| **What** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded** | Every session (full) | Every session (first 200 lines / 25KB) |

## Auto memory

Claude saves notes for itself as it works — build commands, preferences, debugging insights.

**Location:** `~/.claude/projects/<project>/memory/`

```
memory/
├── MEMORY.md          # Index, loaded every session (first 200 lines)
├── debugging.md       # Topic file, loaded on demand
└── api-conventions.md # Topic file, loaded on demand
```

**Commands:**
- `/memory` — browse loaded files, toggle auto memory, open memory folder
- "remember that..." — Claude saves to auto memory
- "forget..." — Claude removes the entry

## The meta-loop: /insights

`/insights` generates an HTML report from your usage data analyzing:
- What you work on (projects, session counts)
- How you use CC (tools, languages, session types)
- What's working (big wins, effective patterns)
- Where things go wrong (friction categories, specific examples)
- Features to try (personalized, with copy-paste CLAUDE.md additions)

**The feedback loop:**
1. Use CC for a few weeks
2. Run `/insights` — read friction patterns
3. Update CLAUDE.md with suggested additions
4. Better sessions → run `/insights` again

This is the feedback loop monster applied to the tool itself — Claude analyzing its own behavior to improve its own instructions. Turtles all the way down.

## Tips

- Keep CLAUDE.md under 200 lines — split into `.claude/rules/` when it grows
- Auto memory is machine-local, not shared across computers
- After `/compact`, CLAUDE.md reloads from disk but conversation-only instructions are lost
- If Claude isn't following a rule, check `/memory` to verify the file is loaded
