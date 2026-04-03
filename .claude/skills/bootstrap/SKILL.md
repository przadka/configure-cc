---
name: bootstrap
description: Scan the current project and generate tailored Claude Code configuration in seconds
disable-model-invocation: true
effort: high
allowed-tools: Read Glob Grep Bash(ls *) Bash(find *) Bash(which *) Bash(git *) Bash(cat *) Write Edit
argument-hint: "[target-dir (default: cwd)]"
---

Bootstrap Claude Code configuration for the project at `$ARGUMENTS` (default: current working directory).

You are about to give this project a brain. ultrathink about what matters.

---

## Pre-loaded project snapshot

The following was captured automatically — use it, don't re-scan what's already here.

### File tree (top 2 levels)
!`find . -maxdepth 2 -not -path './.git/*' -not -path './node_modules/*' -not -path './__pycache__/*' -not -path './.venv/*' | head -60`

### Config files detected
!`find . -maxdepth 3 \( -name "package.json" -o -name "pyproject.toml" -o -name "Cargo.toml" -o -name "go.mod" -o -name "Gemfile" -o -name "composer.json" -o -name "tsconfig.json" -o -name "next.config.*" -o -name "vite.config.*" -o -name "vitest.config.*" -o -name "jest.config.*" -o -name ".eslintrc*" -o -name "biome.json" -o -name "rustfmt.toml" -o -name ".golangci.yml" -o -name ".mcp.json" \) -not -path './node_modules/*' -not -path './.git/*' 2>/dev/null | head -30`

### Lock files (→ package manager)
!`ls -1 pnpm-lock.yaml yarn.lock package-lock.json uv.lock Cargo.lock go.sum Gemfile.lock composer.lock 2>/dev/null || echo "(none found)"`

### Git history (commit style)
!`git log --oneline -15 2>/dev/null || echo "(not a git repo)"`

### Existing CC config
!`ls -la CLAUDE.md .claude/ .mcp.json 2>/dev/null || echo "(no existing CC config)"`

### CI
!`ls -d .github/workflows/ .gitlab-ci.yml Jenkinsfile .circleci/ 2>/dev/null || echo "(no CI detected)"`

---

## Phase 1 — Read the Room

You already have the snapshot above. Now deepen it:

1. **Read key config files** — `package.json` (scripts, deps), `pyproject.toml` (tools, deps), `Cargo.toml`, etc. These reveal the exact commands, frameworks, and tooling.
2. **Spot the framework** — FastAPI/Flask/Django imports, Next.js/Vite/Remix config, Actix/Axum in Cargo.toml, Gin/Echo in go.mod.
3. **Check what's installed** — run `which` for key binaries (the package manager, linter, type checker). Only include commands that actually work.
4. **Read a few source files** — understand the actual code style, not what you'd guess. Look at imports, error handling, naming.

**Present a project profile** — specific, not generic:

```
Project: fastapi-webhooks
Stack:   Python 3.12 · FastAPI · uv · pytest · ruff + pyright
Layout:  src/webhooks/ → tests/ · alembic migrations
CI:      GitHub Actions (test + deploy)
Git:     conventional commits (feat/fix/chore), 847 commits
CC:      no existing config ← we're fixing that
```

If existing CLAUDE.md found → say so and switch to **additive mode** (suggest additions as a diff, never overwrite).

## Phase 2 — Fill in the Gaps

Ask ONLY what you couldn't detect. Pick at most 3 from this list, skip the rest:

- Commit style (only if git log was ambiguous or repo is brand new)
- Test command subtleties (e.g., "do you need docker-compose up first?")
- Any team conventions that code analysis can't reveal
- Whether they want hooks (auto-lint, type check before commit)

If the scan answered everything → skip this phase entirely and say so. Don't manufacture questions.

## Phase 3 — Build the Config

Generate files in this order. After each, print one line saying what it does. Don't pause between files.

### 1. `CLAUDE.md`

Four sections, every line actionable. Target: 20-30 lines.

```markdown
# Project Instructions

## Build & Test
[exact commands — package manager, build, test single/all, lint, format, type check]

## Code Style
[4-6 rules pulled from actual patterns in THIS codebase, not generic advice]

## Project Structure
[describe the actual layout — where source lives, where tests go, how modules are organized]

## Git
[commit convention detected or chosen, pre-commit expectations]
```

**Verify every command** — run `which <binary>` or check the config exists before including it. If `pnpm` isn't installed, don't put `pnpm test` in CLAUDE.md.

### 2. `.claude/rules/code-style.md` (conditional)

Only create if the codebase has strong patterns worth codifying (e.g., consistent error handling, import ordering, naming conventions). 5-7 rules max. Skip for small or new projects.

### 3. `.claude/settings.json` (conditional)

Only create if hooks add clear value. Tailor to the detected toolchain:

- **TypeScript**: `tsc --noEmit` pre-commit hook
- **Python**: `ruff check .` pre-commit hook
- **Rust**: `cargo clippy -- -D warnings` pre-commit hook
- **Go**: `go vet ./...` pre-commit hook

If `.claude/settings.json` already exists → merge, don't overwrite.

### 4. Recap

```
Done. Your project now has a brain.

  ✓ CLAUDE.md          — build commands, style rules, project layout
  ✓ .claude/rules/...  — [if created: what it enforces]
  ✓ .claude/settings   — [if created: what hooks do]

Next time you run `claude` here, it already knows your project.
Customize: edit CLAUDE.md or add rules in .claude/rules/
```

## Ground Rules

- **Never overwrite** existing CLAUDE.md. If one exists, present additions as a diff.
- **Never generate filler**. If a section would be generic ("follow best practices"), omit it.
- **Verify before including**. Every command in CLAUDE.md must work if run right now.
- **Less is more**. A 20-line CLAUDE.md that's all signal beats a 60-line one with padding.
- **No rules/hooks for simple projects**. Solo script? Just CLAUDE.md. Monorepo with CI? Full setup.
