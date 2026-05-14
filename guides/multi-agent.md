# Multi-Agent Patterns

## Agent view (recommended)

`claude agents` opens one screen for many background sessions.
Dispatch a task, peek with `Space`, attach with `Enter`/`→`, detach with `←` on an empty prompt.
A supervisor process keeps sessions running with no terminal attached.

```bash
claude agents                              # open the view
claude --bg "investigate the flaky test"   # dispatch from shell
claude attach <id>                         # attach by short id
claude logs <id>                           # tail recent output
```

From inside an existing session, `/bg` (or `←` on an empty prompt) moves it into the background.

Each session edits in its own git worktree under `.claude/worktrees/`,
so parallel sessions don't stomp on each other.
Caveats:
- Each session burns subscription quota independently
- Sessions die when your machine sleeps — `claude respawn --all` brings them back from where they left off
- Deleting a session wipes its worktree, including uncommitted changes — push or merge first
- Kill switch: `disableAgentView: true` in settings, or `CLAUDE_CODE_DISABLE_AGENT_VIEW=1`

Requires Claude Code v2.1.139+.
Full docs: [Manage multiple agents with agent view](https://code.claude.com/docs/en/agent-view).

## Level 1: Multiple terminals

Open multiple terminals, each running `claude` in the same repo.
They share the filesystem but have separate context windows.
Largely superseded by agent view, but useful when you want each session pinned to its own terminal pane.

**Use case:** One instance writes code, another reviews it.

## Level 2: Sub-agents

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

Using multiple models together catches more than any single model alone.

## Worktrees for isolation

Git worktrees give each agent its own copy of the repo. Two ways to do it:

**Quick way** — Claude Code handles it:
```bash
claude --worktree
```
CC creates a worktree, works in isolation, and asks whether to keep changes when done.

**Manual way** — you manage the worktree:
```bash
git worktree add ../feature-branch feature-branch
cd ../feature-branch
claude  # runs in isolated copy
```

Use case: Agent works on a feature branch while you keep coding on main.
