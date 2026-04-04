---
name: audit
description: Read-only analysis of global Claude Code configuration — flags issues and suggests improvements
disable-model-invocation: true
effort: high
allowed-tools: Read Glob Grep Bash(ls *) Bash(find *) Bash(which *) Bash(cat *) Bash(wc *) Bash(claude *) Bash(uname *) Bash(echo *) Bash(head *) Bash(command *)
---

Audit the user's global Claude Code configuration. ultrathink about what you find.

**This is read-only. Do NOT create, edit, or delete any files.**

---

## Snapshot

### Global CLAUDE.md
!`cat ~/.claude/CLAUDE.md 2>/dev/null || echo "(none)"`

### Global CLAUDE.md line count
!`wc -l < ~/.claude/CLAUDE.md 2>/dev/null || echo "0"`

### Global settings
!`cat ~/.claude/settings.json 2>/dev/null || echo "(none)"`

### Global rules
!`ls -la ~/.claude/rules/ 2>/dev/null || echo "(no rules directory)"`

### Global skills
!`find ~/.claude/skills/ -name "SKILL.md" 2>/dev/null || echo "(no skills)"`

### MCP servers
!`cat ~/.claude.json 2>/dev/null || echo "(no global MCP config)"`

### Installed CLI tools
!`for cmd in git gh node pnpm npm yarn bun python python3 uv pip cargo go ruby docker kubectl; do command -v $cmd >/dev/null 2>&1 && echo "  ✓ $cmd ($(which $cmd))"; done`

### Shell & platform
!`echo "Shell: $SHELL"; echo "OS: $(uname -s)"; echo "Home: $HOME"`

### Claude Code version
!`claude --version 2>/dev/null || echo "(claude CLI not in PATH)"`

### Memory directories
!`find ~/.claude/projects/ -name "MEMORY.md" 2>/dev/null | head -10 || echo "(no memory files)"`

---

## Analysis Checklist

Work through each check. Report findings as ✓ (good), ⚠ (suggestion), or ✗ (problem).

### 1. CLAUDE.md Health
- Does `~/.claude/CLAUDE.md` exist? If not → ✗
- Is it under 200 lines? Over 200 → ⚠ split into `.claude/rules/`
- Does it contain project-specific commands that belong in a project CLAUDE.md? → ⚠
- Any stale references (tools not installed, paths that don't exist)? → ✗
- Does it use `@import` for modularity? Not required, but ⚠ if over 100 lines without it

### 2. Settings & Hooks
- Does `~/.claude/settings.json` exist?
- Check for safety hooks. Flag if missing:
  - `rm -rf` blocking → ⚠
  - `git push --force` blocking → ⚠
  - `git add .` / `git add -A` blocking → ⚠

### 3. CLI Tool Safety
For each installed CLI tool that can modify external state, check for protective hooks:
- `gh` — can create PRs, close issues, delete repos
- `docker` — can remove containers/images
- `kubectl` — can modify cluster state
Report unprotected high-risk tools as ⚠

### 4. MCP Servers
- List configured servers from `~/.claude.json`
- If Node installed but no Playwright MCP → ⚠ (common miss)
- Flag any servers with overly broad permissions

### 5. Skills
- List global skills with their descriptions
- Check each for valid frontmatter (name, description)
- Flag overly permissive allowed-tools scopes

### 6. Rules
- List global rules
- Flag overlapping or contradictory rules

### 7. Memory Health
- Count project memory directories
- Flag any MEMORY.md over 200 lines (truncation risk)

---

## Report Format

```
# CC Config Audit

## Summary
[1-2 sentences: overall health]

## ✗ Problems
- [issue + how to fix]

## ⚠ Suggestions
- [improvement + why it matters]

## ✓ Good
- [things well-configured]

## Next steps
1. [most impactful fix]
2. [second]
3. [third]
```

Be specific. Only report what you actually found — no generic advice.
