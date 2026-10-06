---
name: audit
description: Read-only analysis of global Claude Code configuration — flags issues and suggests improvements
disable-model-invocation: true
effort: high
allowed-tools: Read Glob Grep Bash(ls *) Bash(find *) Bash(which *) Bash(cat *) Bash(wc *) Bash(claude *) Bash(uname *) Bash(echo *) Bash(head *) Bash(command *) Bash(readlink *)
---

Audit the user's global Claude Code configuration. ultrathink about what you find.

**This is read-only. Do NOT create, edit, or delete any files.**

---

## Pre-loaded snapshot

These run inside the project sandbox — safe on any install.

### Installed CLI tools
!`which git gh node pnpm npm yarn bun python python3 uv pip cargo go ruby docker kubectl 2>/dev/null || true`

### OS & home
!`uname -s`
!`echo ~`

### Claude Code version
!`claude --version 2>/dev/null || echo "(claude CLI not in PATH)"`

---

## Phase 1 — Read global config

Use your tools to read these paths (they may not all exist — that's expected):

1. `~/.claude/CLAUDE.md` — personal instructions (also count lines with `wc -l`)
2. `~/.claude/settings.json` — hooks and permissions
3. `~/.claude/rules/` — list rule files
4. `~/.claude/skills/` — find all SKILL.md files
5. `~/.claude.json` — MCP server config
6. `~/.claude/projects/` — find MEMORY.md files (up to 10)

---

## Analysis Checklist

Work through each check. Report each finding as Good, Suggestion, or Problem.

### 1. CLAUDE.md Health
- Does `~/.claude/CLAUDE.md` exist? If not, that is a Problem
- Is it under 200 lines? Over 200 is a Suggestion: split into `.claude/rules/`
- Does it contain project-specific commands that belong in a project CLAUDE.md? That is a Suggestion
- Any stale references (tools not installed, paths that don't exist)? Those are Problems
- Does it use `@import` for modularity? Not required, but a Suggestion if over 100 lines without it

### 2. Settings & Hooks
- Does `~/.claude/settings.json` exist?
- Check for safety hooks. Flag if missing:
  - `rm -rf` blocking, a Suggestion if absent
  - `git push --force` blocking, a Suggestion if absent
  - `git add .` / `git add -A` blocking, a Suggestion if absent
- Cross-session messaging, on CC v2.1.224+ and macOS or Linux only. Check `crossSessionInbound`:
  - Unset is a sound default for interactive use, the behavior is derived from permission mode. Report as Good, do not suggest adding the key for its own sake
  - Any unattended `claude -p` worker needs `accept` in its own `--settings`. Without it a held message never arrives, because `-p` cannot show the approval dialog and nothing reports the drop. A Suggestion where such workers exist
  - A deny rule on `SendMessage` also removes messaging to subagents and agent-team teammates, since it is the same tool. Report as a Problem if the user relies on either

### 3. CLI Tool Safety
For each installed CLI tool that can modify external state, check for protective hooks:
- `gh` — can create PRs, close issues, delete repos
- `docker` — can remove containers/images
- `kubectl` — can modify cluster state
Report unprotected high-risk tools as Suggestions

### 4. MCP Servers
- List configured servers from `~/.claude.json`
- If Node installed but no Playwright MCP is a Suggestion (common miss)
- Flag any servers with overly broad permissions

### 5. Skills
Measure against Anthropic's [skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices).
- List global skills with their descriptions
- Validate frontmatter with `claude plugin validate <dir>` (v2.1.233+). It accepts only a directory named `skills` and does not read symlinked entries, yet still reports a pass with exit 0, so a pass on `~/.claude/skills` says nothing about symlinked skills:
  - Run it on `~/.claude/skills` for the skills stored there as real directories
  - Resolve each symlinked skill with `readlink -f` and run it once on each distinct parent directory of the targets. If a parent is not named `skills`, the command fails with "No manifest found"; report those skills as not checked
  - Exit 1 with "YAML frontmatter failed to parse" is a Problem: the skill loads with empty metadata, so Claude can't match its description
  - Never report a skill as validated unless a run actually read it
- A model-invocable skill whose description says what it does but not when to use it is a Suggestion. Skip skills with `disable-model-invocation: true`: their description never reaches Claude
- A SKILL.md over 500 lines is a Suggestion: move reference material into separate files linked from SKILL.md
- A reference file reachable only through another reference file is a Suggestion: Claude may read it partially
- A reference file over 100 lines with no contents list near the top is a Suggestion
- An instruction to write out reasoning or thinking in the reply is a Suggestion: on current Claude models such requests may be declined as reasoning extraction. Asking for a short explanation of the result is fine
- Flag overly permissive allowed-tools scopes. The field pre-approves tools; it restricts nothing
- With more than about 20 skills, suggest `/skill-doctor` (v2.1.252+) for each skill's context cost and usage

### 6. Rules
- List global rules
- Flag overlapping or contradictory rules

### 7. Memory Health
- Count project memory directories
- Flag any MEMORY.md over 200 lines or 25KB (truncation risk — whichever comes first)

---

## Report Format

```
# CC Config Audit

## Summary
[1-2 sentences: overall health]

## Problems
- [issue + how to fix]

## Suggestions
- [improvement + why it matters]

## Good
- [things well-configured]

## Next steps
1. [most impactful fix]
2. [second]
3. [third]
```

Be specific. Only report what you actually found — no generic advice.
