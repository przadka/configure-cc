---
name: bootstrap-project
description: Scan the current project and generate tailored project-level Claude Code configuration
disable-model-invocation: true
effort: high
allowed-tools: Read Glob Grep Bash(ls *) Bash(find *) Bash(which *) Bash(git *) Bash(cat *) Write Edit
argument-hint: "[target-dir (default: cwd)]"
---

Generate project-level Claude Code configuration for the project at `$ARGUMENTS` (default: current working directory).

This creates project-local config (CLAUDE.md, rules, hooks) — the complement to global `~/.claude/` settings.

---

## Project Snapshot

### File tree (top 2 levels)
!`find . -maxdepth 2 -not -path './.git/*' -not -path './node_modules/*' -not -path './__pycache__/*' -not -path './.venv/*' | head -60`

### Config files
!`find . -maxdepth 3 \( -name "package.json" -o -name "pyproject.toml" -o -name "Cargo.toml" -o -name "go.mod" -o -name "Gemfile" -o -name "composer.json" -o -name "tsconfig.json" -o -name "next.config.*" -o -name "vite.config.*" -o -name "vitest.config.*" -o -name "jest.config.*" -o -name ".eslintrc*" -o -name "biome.json" -o -name "rustfmt.toml" -o -name ".golangci.yml" -o -name ".mcp.json" \) -not -path './node_modules/*' -not -path './.git/*' 2>/dev/null | head -30`

### Lock files
!`ls -1 pnpm-lock.yaml yarn.lock package-lock.json uv.lock Cargo.lock go.sum Gemfile.lock composer.lock 2>/dev/null || echo "(none)"`

### Git history
!`git log --oneline -15 2>/dev/null || echo "(not a git repo)"`

### Existing CC config
!`ls -la CLAUDE.md .claude/ .mcp.json 2>/dev/null || echo "(none)"`

### CI
!`ls -d .github/workflows/ .gitlab-ci.yml Jenkinsfile .circleci/ 2>/dev/null || echo "(none)"`

---

## Phase 1 — Understand the Project

Deepen the snapshot:

1. **Read config files** — `package.json` scripts/deps, `pyproject.toml` tools, `Cargo.toml`, etc.
2. **Spot the framework** — FastAPI, Next.js, Actix, Gin, etc.
3. **Verify tooling** — `which` for key binaries. Only include commands that work.
4. **Read source files** — actual code style, imports, error handling, naming.

**Present a profile:**
```
Project: fastapi-webhooks
Stack:   Python 3.12 · FastAPI · uv · pytest · ruff + pyright
Layout:  src/webhooks/ → tests/ · alembic migrations
CI:      GitHub Actions (test + deploy)
Git:     conventional commits, 847 commits
CC:      no existing config
```

If CLAUDE.md exists → **additive mode** (present additions as diff, never overwrite).

## Phase 2 — Ask (only if needed)

At most 3 questions. Only ask what you couldn't detect:
- Commit style (if git log is ambiguous)
- Test setup subtleties (docker-compose, env vars)
- Team conventions code can't reveal

If the scan answered everything → skip and say so.

## Phase 3 — Generate Config

### 1. `CLAUDE.md` — 20-30 lines, all signal

```markdown
# Project Instructions

## Build & Test
[exact commands — package manager, build, test, lint, format, type check]

## Code Style
[4-6 rules from actual patterns in THIS codebase]

## Project Structure
[actual layout — source, tests, modules]

## Git
[detected commit convention, pre-commit expectations]
```

**Verify every command** before including it.

### 2. `.claude/rules/code-style.md` (conditional)

Only if the codebase has strong patterns worth codifying. 5-7 rules max. Skip for small projects.

### 3. `.claude/settings.json` (conditional)

Only if hooks add clear value:
- **TypeScript**: `tsc --noEmit` pre-commit
- **Python**: `ruff check .` pre-commit
- **Rust**: `cargo clippy -- -D warnings` pre-commit
- **Go**: `go vet ./...` pre-commit

If exists → merge, don't overwrite.

### 4. Recap

```
Done. Project config generated.

  ✓ CLAUDE.md          — [what it covers]
  ✓ .claude/rules/...  — [if created]
  ✓ .claude/settings   — [if created]

Next time you run `claude` here, it knows your project.
```

## Ground Rules

- **Never overwrite** existing CLAUDE.md — additive mode only
- **Never generate filler** — omit generic sections
- **Verify before including** — every command must work now
- **Less is more** — 20 lines of signal beats 60 of padding
- **Scale to complexity** — solo script gets just CLAUDE.md, monorepo gets full setup
