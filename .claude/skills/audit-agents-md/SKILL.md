---
name: audit-agents-md
description: Audit a project's CLAUDE.md / AGENTS.md for structure, bloat, stale references, and best practices
disable-model-invocation: true
effort: high
allowed-tools: Read Glob Grep Bash(ls *) Bash(find *) Bash(cat *) Bash(wc *) Bash(test *) Bash(stat *) Bash(head *)
---

Audit the CLAUDE.md or AGENTS.md in the **current project directory**. ultrathink about what you find.

**This is read-only. Do NOT create, edit, or delete any files.**

If no instruction file (CLAUDE.md, AGENTS.md, AGENT.md, .cursorrules) is found in the project root, report that and stop.

---

## Pre-loaded snapshot

!`wc -l CLAUDE.md AGENTS.md AGENT.md .cursorrules 2>/dev/null || echo "(no instruction files in root)"`
!`ls docs/ 2>/dev/null | head -20 || echo "(no docs/ directory)"`
!`ls .claude/rules/ 2>/dev/null || echo "(no .claude/rules/ directory)"`

---

## Phase 1 — Discover instruction files

1. Check for root instruction file: `CLAUDE.md`, `AGENTS.md`, `AGENT.md`, `.cursorrules`
   - If symlink, note the target
   - Note the line count from pre-loaded snapshot
2. Use Glob to find subtree instruction files: `**/{CLAUDE,AGENTS,AGENT}.md`
3. Check for `docs/` directory contents (from snapshot)
4. Check for `.claude/rules/` directory (from snapshot)

Read the root instruction file in full. If over 500 lines, read in chunks.

---

## Phase 2 — Structure Analysis

### 2.1 Size assessment

Based on [analysis of 2,500+ repositories](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/):

| Lines | Verdict |
|---|---|
| 0 (missing) | ✗ No instruction file found |
| 1–30 | ⚠ Likely too thin — check for missing sections |
| 31–150 | ✓ Good range — concise and effective |
| 151–250 | ⚠ Getting long — look for extraction candidates |
| 251+ | ✗ Too long — needs decomposition into docs/, subtree files, or `.claude/rules/` |

Research note: [Gloaguen et al. (2026)](https://asdlc.io/practices/agents-md-spec/) found that verbose context files inflate reasoning costs without proportional task improvement. Minimal, precise content outperforms comprehensive documentation.

### 2.2 Essential sections — the six critical areas

The [GitHub analysis](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/) found that top-performing instruction files cover these six areas. Check whether they exist (by heading or equivalent content). Not every project needs all — use judgment.

| Area | What to look for | When it matters |
|---|---|---|
| **Commands** | Build, test, lint, deploy — executable with flags, not just tool names | Always for code projects |
| **Testing** | Framework, how to run, patterns, coverage expectations | Code projects |
| **Project structure** | Key directories and files, architecture bird's-eye view | Projects with >10 files |
| **Code style** | Real code examples showing preferred patterns (not prose descriptions) | Always |
| **Git workflow** | Commit style, branching, PR conventions | Team projects |
| **Boundaries** | What the agent must never do, what requires asking first | Always |

Flag missing critical areas as ⚠ with a one-line rationale.

### 2.3 Hierarchy check

- If >150 lines and no `docs/` directory or subtree files → ⚠ suggest decomposition
- If docs/ exists, check that root file links to it — orphaned docs are invisible to agents
- If `@import` is used, verify imported files exist (paths are relative to the file containing the `@import` directive)
- If subtree instruction files exist, check they don't duplicate root content

---

## Phase 3 — Content Quality

### 3.1 Bloat detection

Scan for these patterns and flag as ⚠:

- **Long code blocks** (>15 lines) — reference material, not instructions. Should live in docs/ or scripts/
- **Full OAuth/auth flows** — procedural recipes that an agent can look up when needed
- **Complete API reference tables** — better as a linked doc
- **Step-by-step tutorials** — agents need "what" not "how to learn"
- **Completed checklists** (`[x]` items) still inline — historical noise
- **Duplicate information** — same fact stated in multiple sections
- **Rules already enforced by toolchain** — if a linter/formatter/type checker enforces it, restating it in the instruction file is noise that wastes tokens

For each bloat finding, note the line range and suggest where to extract it.

### 3.2 Freshness check

Verify a sample of references (up to 10):

- **File paths** mentioned in the doc — do they exist? Use `test -e <path>`
- **Commands** mentioned — are the binaries installed?
- **Version numbers** — flag if they look stale (>6 months old, or old major versions)
- **URLs** — don't fetch, but flag obviously broken patterns (localhost links in production docs, dead GitHub paths)

Flag stale references as ✗ with the specific line.

### 3.3 Anti-patterns

Flag these as ✗:

- **Secrets or tokens** — API keys, passwords, bearer tokens in plain text
- **TODO/TBD/FIXME placeholders** — unfinished sections that mislead agents
- **Generic filler** — "follow best practices", "write clean code", "use appropriate error handling" add zero signal
- **Vague tech descriptions** — "React project" instead of specific stack/version details
- **Vague personas** — "helpful coding assistant" instead of specific role definitions
- **Project-specific content in global CLAUDE.md** — if auditing `~/.claude/CLAUDE.md`, flag project-bound paths/commands
- **LLM-generated boilerplate** — overly broad constraints, formulaic section structure, and generic guidance are signs of AI-generated content. [Research shows](https://asdlc.io/practices/agents-md-spec/) this reduces agent success rates while increasing inference cost by >20%

### 3.4 Agent-orientation check

Flag as ⚠ if the file reads more like human documentation than agent instructions:

- **Prose style guides instead of code examples** — one real code snippet showing your style beats three paragraphs describing it
- **Missing imperative voice** — agents need "Run X" not "X can be run by..."
- **Excessive background/history** — agents need current state, not how we got here
- **No actionable commands** — descriptions without copy-paste recipes
- **Ambiguous instructions** — "consider using" instead of "use" or "do not use"
- **Missing boundary tiers** — best practice is three tiers: always do, ask first, never do
- **Describing patterns instead of pointing to files** — "We use the adapter pattern" is less useful than "See `src/adapters/base.rb` for the pattern to follow." The agent won't read the file right away, but will know where to look when needed.
- **Documenting rules that hooks enforce** — if a hook already blocks `git push --force`, documenting "never force push" wastes tokens. Note: this only applies when the audited project actually has hooks configured.

---

## Phase 4 — Cross-tool Compatibility

Quick check on naming and portability:

- **AGENTS.md** has the broadest compatibility (Claude Code, Codex, Jules, Cursor, GitHub Copilot, 25+ tools)
- **CLAUDE.md** is Claude Code-specific but also read by some other tools
- If the project uses CLAUDE.md only, note that AGENTS.md would give broader compatibility (⚠, not ✗ — it's a preference)
- If both CLAUDE.md and AGENTS.md exist, check for contradictions or duplication between them

---

## Phase 5 — Report

```
# AGENTS.md Audit — [project name or directory]

## Summary
[1-2 sentences: overall quality, biggest issue]

## File stats
- **File:** [path] ([N] lines)
- **Subtree files:** [count or "none"]
- **Docs directory:** [yes/no, file count if yes]
- **Rules:** [count or "none"]
- **Cross-tool:** [AGENTS.md / CLAUDE.md / both — compatibility note if relevant]

## ✗ Problems
- [issue + specific line/section + fix]

## ⚠ Suggestions
- [improvement + rationale + how]

## ✓ Good
- [things done well — be specific]

## Extraction candidates
[Only if file is >150 lines]
- **Lines [N-M]: [section name]** → extract to `docs/[name].md` ([reason])

## Next steps
1. [most impactful improvement]
2. [second]
3. [third]
```

**Rules for the report:**
- Be specific — cite line numbers, section names, exact content
- Only report what you actually found — no generic advice
- Extraction candidates should name the target file and explain why
- "Good" section must exist — always acknowledge what's working
- Keep the report under 80 lines — this is a summary, not a rewrite
