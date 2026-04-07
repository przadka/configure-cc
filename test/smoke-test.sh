#!/usr/bin/env bash
# Smoke test: verify onboarding skills work on a fresh CC installation.
#
# Usage:
#   ./test/smoke-test.sh              # smoke test only (no API key needed)
#   ANTHROPIC_API_KEY=sk-... ./test/smoke-test.sh   # + end-to-end with claude -p
#
# How it works:
#   Sets HOME to a temp dir to simulate a completely fresh environment
#   (no ~/.claude/, no ~/.claude.json). Tests that all skill pre-injection
#   commands handle this gracefully.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAKE_HOME=$(mktemp -d)
export ORIGINAL_HOME="$HOME"
export HOME="$FAKE_HOME"

cleanup() { rm -rf "$FAKE_HOME"; }
trap cleanup EXIT

PASS=0
FAIL=0
WARN=0

pass() { PASS=$((PASS + 1)); echo "  ✓ $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  ✗ $1"; }
warn() { WARN=$((WARN + 1)); echo "  ⚠ $1"; }

header() { echo -e "\n━━━ $1 ━━━"; }

run_cmd() {
  local label="$1"
  local cmd="$2"
  local output
  local exit_code

  output=$(eval "$cmd" 2>&1) && exit_code=0 || exit_code=$?

  if [ $exit_code -eq 0 ]; then
    if [ -n "$output" ]; then
      pass "$label → $(echo "$output" | head -1 | cut -c1-60)"
    else
      pass "$label → (empty output, exit 0)"
    fi
  else
    fail "$label → exit code $exit_code: $(echo "$output" | head -1 | cut -c1-60)"
  fi
}

# ─── 1. Verify clean environment ───────────────────────────────
header "1. Clean environment check"

echo "  HOME=$HOME (temp dir)"
echo "  Real home: $ORIGINAL_HOME"

if [ -d "$HOME/.claude" ]; then
  fail "~/.claude/ already exists in temp home"
else
  pass "No ~/.claude/ directory (fresh install simulated)"
fi

if command -v claude >/dev/null 2>&1; then
  pass "claude CLI in PATH: $(claude --version 2>/dev/null || echo 'unknown')"
else
  warn "claude CLI not in PATH (e2e test will be skipped)"
fi

# ─── 2. Skill file validation ─────────────────────────────────
header "2. Skill file validation"

for skill_dir in "$REPO_ROOT"/.claude/skills/*/; do
  skill_file="$skill_dir/SKILL.md"
  skill_name=$(basename "$skill_dir")

  if [ ! -f "$skill_file" ]; then
    fail "$skill_name: SKILL.md not found"
    continue
  fi

  # Check frontmatter exists
  if head -1 "$skill_file" | grep -q '^---'; then
    pass "$skill_name: has frontmatter"
  else
    fail "$skill_name: missing frontmatter (first line should be ---)"
    continue
  fi

  # Extract frontmatter (between first and second ---)
  frontmatter=$(awk '/^---$/{n++; next} n==1' "$skill_file")

  for field in name description; do
    if echo "$frontmatter" | grep -q "^${field}:"; then
      pass "$skill_name: has '$field' field"
    else
      fail "$skill_name: missing '$field' in frontmatter"
    fi
  done

  # Check for ! pre-injection commands and count them
  bang_count=$(grep -c '^!' "$skill_file" 2>/dev/null || echo 0)
  if [ "$bang_count" -gt 0 ]; then
    pass "$skill_name: has $bang_count pre-injection commands"
  else
    warn "$skill_name: no pre-injection commands found"
  fi
done

# ─── 3. Pre-injection commands (bootstrap) ────────────────────
header "3. Bootstrap skill — pre-injection commands (fresh env)"

run_cmd "global config listing" \
  'ls -la ~/.claude/CLAUDE.md ~/.claude/settings.json 2>/dev/null || echo "(no global config)"'

run_cmd "existing CLAUDE.md" \
  'cat ~/.claude/CLAUDE.md 2>/dev/null || echo "(none)"'

run_cmd "existing settings" \
  'cat ~/.claude/settings.json 2>/dev/null || echo "(none)"'

run_cmd "existing skills" \
  'ls ~/.claude/skills/ 2>/dev/null || echo "(no skills)"'

run_cmd "existing rules" \
  'ls ~/.claude/rules/ 2>/dev/null || echo "(no rules)"'

run_cmd "OS" \
  'uname -s'

run_cmd "home dir" \
  'echo ~'

run_cmd "key binaries" \
  'which git node pnpm npm yarn bun python python3 uv pip cargo go ruby gem docker gh 2>/dev/null'

run_cmd "global MCP config" \
  'cat ~/.claude.json 2>/dev/null || echo "(no global MCP config)"'

# ─── 4. Pre-injection commands (audit) ────────────────────────
header "4. Audit skill — pre-injection commands (fresh env)"

run_cmd "CLAUDE.md line count" \
  'wc -l < ~/.claude/CLAUDE.md 2>/dev/null || echo "0"'

run_cmd "global rules listing" \
  'ls -la ~/.claude/rules/ 2>/dev/null || echo "(no rules directory)"'

run_cmd "global skills find" \
  'find ~/.claude/skills/ -name "SKILL.md" 2>/dev/null || echo "(no skills)"'

run_cmd "installed CLI tools" \
  'which git gh node pnpm npm yarn bun python python3 uv pip cargo go ruby docker kubectl 2>/dev/null'

run_cmd "claude version" \
  'claude --version 2>/dev/null || echo "(claude CLI not in PATH)"'

run_cmd "memory directories" \
  'find ~/.claude/projects/ -name "MEMORY.md" 2>/dev/null | head -10 || echo "(no memory files)"'

# ─── 5. Verify fallback values make sense ─────────────────────
header "5. Fallback output validation"

# The fallback strings should match what the skill instructions expect
for expected in "(no global config)" "(none)" "(no skills)" "(no rules)" "(no global MCP config)" "(no rules directory)" "(no memory files)"; do
  # At least one command above should have produced this fallback
  if grep -qF "$expected" <(
    ls -la ~/.claude/CLAUDE.md ~/.claude/settings.json 2>/dev/null || echo "(no global config)"
    cat ~/.claude/CLAUDE.md 2>/dev/null || echo "(none)"
    ls ~/.claude/skills/ 2>/dev/null || echo "(no skills)"
    ls ~/.claude/rules/ 2>/dev/null || echo "(no rules)"
    cat ~/.claude.json 2>/dev/null || echo "(no global MCP config)"
    ls -la ~/.claude/rules/ 2>/dev/null || echo "(no rules directory)"
    find ~/.claude/projects/ -name "MEMORY.md" 2>/dev/null | head -10 || echo "(no memory files)"
  ); then
    pass "Fallback: '$expected' produced correctly"
  else
    fail "Fallback: '$expected' not found in output"
  fi
done

# ─── 6. End-to-end test (optional) ────────────────────────────
header "6. End-to-end test"

if [ -n "${ANTHROPIC_API_KEY:-}" ] && command -v claude >/dev/null 2>&1; then
  echo "  API key + claude CLI detected — running headless bootstrap..."

  # Create a temp project dir
  mkdir -p /tmp/cc-e2e-test
  cd /tmp/cc-e2e-test
  git init -q
  git config user.email "test@test.com"
  git config user.name "Test User"

  # Copy skills so CC can find them
  mkdir -p .claude/skills/
  cp -r "$REPO_ROOT"/.claude/skills/* .claude/skills/

  # Run bootstrap headless
  output=$(claude -p "/bootstrap" --max-turns 10 2>&1) && e2e_exit=0 || e2e_exit=$?

  if [ $e2e_exit -eq 0 ]; then
    pass "claude -p /bootstrap exited cleanly"

    if [ -f "$HOME/.claude/CLAUDE.md" ]; then
      lines=$(wc -l < "$HOME/.claude/CLAUDE.md")
      pass "Generated ~/.claude/CLAUDE.md ($lines lines)"
      if [ "$lines" -gt 200 ]; then
        warn "CLAUDE.md is $lines lines (>200 = truncation risk)"
      fi
    else
      warn "No ~/.claude/CLAUDE.md generated"
    fi

    if [ -f "$HOME/.claude/settings.json" ]; then
      pass "Generated ~/.claude/settings.json"
      # Validate JSON
      if python3 -c "import json; json.load(open('$HOME/.claude/settings.json'))" 2>/dev/null; then
        pass "settings.json is valid JSON"
      else
        fail "settings.json is invalid JSON"
      fi
    else
      warn "No ~/.claude/settings.json generated"
    fi
  else
    fail "claude -p /bootstrap failed (exit $e2e_exit)"
    echo "  Last 20 lines of output:"
    echo "$output" | tail -20 | sed 's/^/    /'
  fi

  rm -rf /tmp/cc-e2e-test
else
  if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
    echo "  No ANTHROPIC_API_KEY — skipping e2e test"
  else
    echo "  claude CLI not in PATH — skipping e2e test"
  fi
  echo "  To run: ANTHROPIC_API_KEY=sk-... ./test/smoke-test.sh"
fi

# ─── Summary ──────────────────────────────────────────────────
header "Results"
echo "  ✓ $PASS passed"
echo "  ⚠ $WARN warnings"
echo "  ✗ $FAIL failed"
echo ""

if [ $FAIL -gt 0 ]; then
  echo "FAILED"
  exit 1
else
  echo "ALL PASSED"
fi
