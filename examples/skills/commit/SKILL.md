---
name: commit
description: Create a git commit with proper context and conventional commit message
disable-model-invocation: true
---

Create a git commit for the current changes.

1. Run `git status` and `git diff --staged` (and `git diff` if nothing staged) to understand the changes
2. Run `git log --oneline -5` to see recent commit message style
3. Draft a concise commit message:
   - Use conventional commit format: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
   - Focus on WHY, not WHAT (the diff shows what)
   - One sentence, under 72 characters for the subject line
4. Stage relevant files (prefer specific files over `git add -A`)
5. Never commit `.env`, credentials, or large binaries
6. Show the commit message and ask for confirmation before committing
