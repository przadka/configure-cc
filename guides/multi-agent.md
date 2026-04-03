# Multi-Agent Patterns

## Level 1: Multiple CC instances (zero setup)

Open multiple terminals, each running `claude` in the same repo. They share the filesystem but have separate context windows.

**Use case:** One instance writes code, another reviews it.

## Level 2: Sub-agents (built-in)

Claude Code spawns sub-agents automatically (Task tool) or you can ask for it:

```
please summarize the quality of code. you can use subagents for that
```

Sub-agents get their own context window — they don't pollute your main session.

**Use case:** Parallel research, code analysis, review with multiple focuses.

## Level 3: CC + other models

Run Claude Code alongside other coding agents for diversity of opinion:

| Setup | How | Best for |
|-------|-----|----------|
| CC + CC | Two terminals | Parallel features |
| CC + Gemini CLI | `gemini` in separate terminal | Second opinion, different strengths |
| CC + Codex CLI | `codex` in separate terminal | Independent verification |
| CC with Codex sub-agent | Codex plugin in CC | Review from within CC session |

## Level 4: /fork for parallel branches

Fork your session to try multiple approaches:

```bash
# Terminal 1: approach A
claude --continue --fork-session

# Terminal 2: approach B  
claude --continue --fork-session
```

Both start from the same context, diverge independently.

## Multi-agent review pattern

The most proven pattern — use multiple reviewers:

```
Review this PR using 3 parallel agents:
1. Correctness and edge cases
2. Security and data handling  
3. Style and consistency

Consolidate findings into P1/P2/P3 triage list.
```

Results: Claude finds ~58% of bugs, Codex ~38%, Gemini ~28%. Together they catch more than any single model.

## Worktrees for isolation

Git worktrees give each agent its own copy of the repo:

```bash
git worktree add ../feature-branch feature-branch
cd ../feature-branch
claude  # runs in isolated copy
```

Use case: Agent works on a feature branch while you keep coding on main.
