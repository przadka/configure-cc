---
name: bootstrap
description: Set up global Claude Code configuration — personal CLAUDE.md, skills, hooks, and settings
disable-model-invocation: true
effort: high
allowed-tools: Read Glob Grep Bash(ls *) Bash(find *) Bash(which *) Bash(cat *) Bash(uname *) Bash(echo *) Write Edit
---

Set up the user's global Claude Code environment. ultrathink about what matters.

All generated config goes to **global paths** (`~/.claude/`), not the current project.

---

## Pre-loaded environment snapshot

### Current global config
!`ls -la ~/.claude/CLAUDE.md ~/.claude/settings.json 2>/dev/null || echo "(no global config)"`

### Existing global CLAUDE.md
!`cat ~/.claude/CLAUDE.md 2>/dev/null || echo "(none)"`

### Existing global settings
!`cat ~/.claude/settings.json 2>/dev/null || echo "(none)"`

### Existing global skills
!`ls ~/.claude/skills/ 2>/dev/null || echo "(no skills)"`

### Existing global rules
!`ls ~/.claude/rules/ 2>/dev/null || echo "(no rules)"`

### Shell & platform
!`echo "Shell: $SHELL"; echo "OS: $(uname -s)"; echo "Home: $HOME"`

### Key binaries available
!`for cmd in git node pnpm npm yarn bun python python3 uv pip cargo go ruby gem docker gh; do which $cmd 2>/dev/null && echo "  ✓ $cmd"; done || echo "(none found)"`

### Global MCP servers
!`cat ~/.claude.json 2>/dev/null || echo "(no global MCP config)"`

---

## Phase 1 — Read the Room

You have the snapshot above. Now assess:

1. **What languages/tools does this user work with?** — The installed binaries tell you. Node + pnpm = JS/TS developer. Python + uv = Python developer. Both = polyglot. Tailor recommendations accordingly.
2. **What global config exists already?** — Read the existing `~/.claude/CLAUDE.md` and `~/.claude/settings.json` carefully. Work additively — improve what's there, don't start over.
3. **What skills are already installed?** — Don't recommend skills that duplicate what exists.
4. **What MCP servers are configured?** — Note what's connected.

**Present a profile:**

```
Environment: Linux · bash · Node 22 + pnpm · Python 3.12 + uv · git + gh
Global CC:   CLAUDE.md (exists, imports AGENTS.md) · 3 skills · settings.json with hooks
MCP:         Playwright, Chrome DevTools
```

## Phase 2 — Fill in the Gaps

Ask at most 3 questions. Only ask what you can't infer:

- What kinds of projects do they mostly work on? (helps tailor style rules)
- Commit style preference (if not obvious from existing config)
- Any pet peeves or must-have rules?

If existing config is comprehensive → skip questions and move to recommendations.

## Phase 3 — Configure

Generate or update files at global paths. After each, print one line saying what it does.

### 1. `~/.claude/CLAUDE.md` — Personal instructions

This is the user's global brain. It should contain:

```markdown
# Personal Instructions

## Preferences
[coding style preferences, communication style, workflow habits]

## Tools & Environment
[default package managers, preferred test runners, shell setup]

## Conventions
[commit style, PR workflow, naming conventions they follow across projects]
```

Target: 15-25 lines, all signal. This applies to EVERY project, so keep it general — no project-specific commands.

**If `~/.claude/CLAUDE.md` already exists** → read it, then present suggested additions/changes as a diff. Never overwrite.

### 2. `~/.claude/skills/` — Portable skills (conditional)

Recommend and generate skills that work across any project. Good candidates:

- **commit** — conventional commits with context-aware messages
- **review-pr** — parallel review agents for correctness, security, style
- **bootstrap-project** — a lighter skill that generates project-level CLAUDE.md (the project-scoped complement to this global bootstrap)

Only generate skills that don't already exist at `~/.claude/skills/`.

### 3. `~/.claude/settings.json` — Global hooks & permissions (conditional)

Recommend hooks that make sense globally:

- Block `git add .` / `git add -A` (prefer explicit staging)
- Block `rm -rf` without confirmation
- Pre-commit lint check (if a universal linter is installed)

**If `~/.claude/settings.json` already exists** → read it, merge new hooks, don't overwrite existing ones.

### 4. MCP servers (recommend only)

Don't install MCP servers — just recommend ones relevant to the detected environment:

- **Playwright** (`claude mcp add --scope user playwright -- npx @playwright/mcp@latest`) — if Node installed
- **Chrome DevTools** (`claude mcp add --scope user chrome-devtools -- npx -y chrome-devtools-mcp@latest`) — for perf debugging

Print the `claude mcp add` commands for the user to run. Skip any already configured.

### 5. Recap

```
Done. Your global Claude Code environment is set up.

  ✓ ~/.claude/CLAUDE.md     — [what it covers]
  ✓ ~/.claude/skills/...    — [skills created or already present]
  ✓ ~/.claude/settings.json — [hooks added or already present]
  ℹ MCP recommendations     — [if any, with commands to run]

This config applies to every project. For project-specific setup,
create a CLAUDE.md in the project root.
```

## Ground Rules

- **All output goes to `~/.claude/`** — never write to project-local paths.
- **Never overwrite** existing files. Read first, present diffs for changes.
- **Never generate filler**. If a section would be generic ("follow best practices"), omit it.
- **Verify before including**. Only recommend tools/commands that are actually installed.
- **Global means portable**. Nothing project-specific in global config — it must work everywhere.
