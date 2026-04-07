#!/usr/bin/env bash
# End-to-end test: run /bootstrap on a simulated fresh CC install.
#
# Uses your real auth credentials but an empty ~/.claude/ config.
# Tests what a brand-new user would see after running /bootstrap.
#
# NOTE: In headless mode, claude -p can't write to ~/.claude/ (sandboxed).
# The bootstrap skill gracefully falls back to printing instructions.
# This test verifies the output content quality instead.
#
# Usage:
#   ./test/e2e-bootstrap.sh                    # with simulated user answers
#   E2E_INTERACTIVE=1 ./test/e2e-bootstrap.sh  # pauses for manual answers

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAKE_HOME=$(mktemp -d)
ORIGINAL_HOME="$HOME"

PASS=0
FAIL=0
WARN=0

pass() { PASS=$((PASS + 1)); echo "  ✓ $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  ✗ $1"; }
warn() { WARN=$((WARN + 1)); echo "  ⚠ $1"; }

cleanup() {
  echo ""
  echo "━━━ Cleanup ━━━"
  if [ -d "$FAKE_HOME/.claude" ]; then
    echo "  Generated files:"
    find "$FAKE_HOME/.claude" -type f -not -path "*/statsig/*" -not -path "*/cache/*" -not -name "*.jsonl" -not -name "*.sh" 2>/dev/null | sort | sed 's/^/    /'
  fi
  rm -rf "$FAKE_HOME"
  echo "  Cleaned up $FAKE_HOME"
}
trap cleanup EXIT

echo "━━━ E2E Bootstrap Test ━━━"
echo "  Fake HOME: $FAKE_HOME"
echo ""

# ─── Setup ────────────────────────────────────────────────────
# Copy ONLY auth credentials — nothing else
if [ -f "$ORIGINAL_HOME/.claude/.credentials.json" ]; then
  mkdir -p "$FAKE_HOME/.claude"
  cp "$ORIGINAL_HOME/.claude/.credentials.json" "$FAKE_HOME/.claude/.credentials.json"
  pass "Copied auth credentials"
else
  fail "No credentials at ~/.claude/.credentials.json — run 'claude login' first"
  exit 1
fi

# Copy statsig (telemetry state) to avoid prompts
if [ -d "$ORIGINAL_HOME/.claude/statsig" ]; then
  cp -r "$ORIGINAL_HOME/.claude/statsig" "$FAKE_HOME/.claude/statsig"
fi

export HOME="$FAKE_HOME"

# Create a temp project
PROJ=$(mktemp -d)
cd "$PROJ"
git init -q
git config user.email "test@test.com"
git config user.name "Test User"
pass "Test project at $PROJ"

# ─── Build prompt ────────────────────────────────────────────
# Strip frontmatter from skill, add pre-answered questions for headless mode
SKILL_BODY=$(awk '/^---$/{n++; next} n>=2' "$REPO_ROOT/.claude/skills/bootstrap/SKILL.md")

PROMPT="$SKILL_BODY

---

## Pre-answered questions (simulated new user)

Since this is running headless, here are the user's answers:
1. Projects: mostly TypeScript/Node.js web apps with some Python scripts
2. Commit style: conventional commits (feat:, fix:, chore:)
3. Pet peeves: don't use semicolons in JS/TS, prefer const over let, hate verbose comments

Now proceed directly to Phase 3 — generate all config files."

# ─── Run ──────────────────────────────────────────────────────
echo ""
echo "━━━ Running bootstrap (headless) ━━━"
echo ""

OUTPUT=$(echo "$PROMPT" | claude -p - \
  --max-turns 20 \
  --allowedTools 'Read,Glob,Grep,Write,Edit,Bash(ls *),Bash(find *),Bash(which *),Bash(cat *),Bash(uname *),Bash(echo *),Bash(mkdir *)' \
  2>&1) && e2e_exit=0 || e2e_exit=$?

# Save output for inspection
echo "$OUTPUT" > "$FAKE_HOME/bootstrap-output.txt"

echo "$OUTPUT"
echo ""

# ─── Validate output ─────────────────────────────────────────
echo ""
echo "━━━ Output Validation ━━━"

if [ $e2e_exit -eq 0 ]; then
  pass "claude -p exited cleanly"
else
  fail "claude -p failed (exit $e2e_exit)"
fi

# Check that output is non-trivial
output_lines=$(echo "$OUTPUT" | wc -l)
if [ "$output_lines" -gt 10 ]; then
  pass "Output is substantial ($output_lines lines)"
else
  fail "Output too short ($output_lines lines) — likely didn't run properly"
fi

# Check that it mentions key config files
for pattern in "CLAUDE.md" "settings.json" "MCP"; do
  if echo "$OUTPUT" | grep -qi "$pattern"; then
    pass "Output mentions $pattern"
  else
    warn "Output doesn't mention $pattern"
  fi
done

# Check that it detected the environment (mentions installed tools)
if echo "$OUTPUT" | grep -qiE "(node|git|python|npm)"; then
  pass "Output references detected tools"
else
  warn "Output doesn't reference any detected tools"
fi

# Check for code blocks (should contain actual config content)
code_blocks=$(echo "$OUTPUT" | grep -c '```' || true)
if [ "$code_blocks" -gt 0 ]; then
  pass "Output contains $((code_blocks / 2)) code blocks with config"
else
  warn "No code blocks in output — config might not be actionable"
fi

# Check that it produced a recap section
if echo "$OUTPUT" | grep -qiE "(done|recap|summary|set up)"; then
  pass "Output includes a recap/summary"
else
  warn "No recap section found"
fi

# Check for the known headless limitation
if echo "$OUTPUT" | grep -qi "blocked\|sandbox\|manual\|copy.paste\|apply"; then
  warn "Writes were blocked (expected in headless mode) — fell back to instructions"
else
  # Check if files were actually created
  if [ -f "$HOME/.claude/CLAUDE.md" ]; then
    pass "Files written directly to ~/.claude/"
    lines=$(wc -l < "$HOME/.claude/CLAUDE.md")
    pass "CLAUDE.md has $lines lines"
    if [ "$lines" -gt 200 ]; then
      warn "CLAUDE.md is $lines lines (>200 = truncation risk in context)"
    fi
  fi
fi

# ─── Summary ──────────────────────────────────────────────────
echo ""
echo "━━━ Results ━━━"
echo "  ✓ $PASS passed"
echo "  ⚠ $WARN warnings"
echo "  ✗ $FAIL failed"
echo ""
echo "  Full output saved to: $FAKE_HOME/bootstrap-output.txt"

# Clean up test project
rm -rf "$PROJ"

if [ $FAIL -gt 0 ]; then
  exit 1
fi
