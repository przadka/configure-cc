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

Requires Claude Code v2.1.139+. (See the [version requirements table](../README.md#version-requirements) for all feature minimums.)
Full docs: [Manage multiple agents with agent view](https://code.claude.com/docs/en/agent-view).

## Cross-session messaging

Claude in one session can hand a plain-text message to another of your sessions.
Text only, never conversation history or files.
To move a whole conversation, resume it instead.

Claude drives this itself with two tools, `ListAgents` to find reachable sessions and `SendMessage` to deliver.
You only say what the other session needs to know:

```
Ask the session in my other terminal whether the migration finished
```

Supporting commands:

```bash
/list-agents     # or /peers, lists what this session can reach
/rename <name>   # the name other sessions address it by
/status          # "Peer address" row shows this session's own inbox socket
claude --name api-worker    # set the name at launch instead
```

An unnamed session is named after its working directory, like `myapp-3f`, so two can collide.
Every row also carries a short ref in brackets, `myapp-3f [303a76]`, and the listing prints each
session's directory. Address a session by its bare name; add the ref only when the name is ambiguous.

Reach depends on where the other session runs:

| Other session | How it travels | What you can send |
|---|---|---|
| Same machine | Per-session Unix socket, never through Anthropic servers | New messages and replies |
| Another of your machines | Anthropic servers, over that machine's Remote Control connection | Replies only |
| Claude Code in the cloud | Anthropic servers | Send only, it cannot message back yet |

Same-machine delivery needs both sessions to see the same files,
so a session inside a container and one on the host cannot reach each other.

A cloud session is the asymmetric case worth knowing: it receives what you send,
but has no way to answer, so read its reply in its own transcript rather than waiting for one.

The listing is wider than the table. Alongside other sessions it shows in-process subagents
you spawned and, if you have one, the teammates on your team, each row labeled by kind.

An incoming message carries less authority than you do.
It cannot approve a pending permission prompt, cannot change permissions or CLAUDE.md,
and a slash command in its text arrives as inert text.
Anything it asks for still hits the receiving session's own permission prompts.

Inbound control with `crossSessionInbound` in settings:

| Value | Behavior |
|---|---|
| `accept` | Deliver every message |
| `hold` | Notice only, delivered if you approve |
| `refuse` | Dropped without delivery |

Left unset, the default keys off permission modes.
A session that prompts for permissions takes messages, holding only those from a sender that bypasses prompts.
A `bypassPermissions` session holds everything unless the sender also bypasses.
An unanswered hold dialog expires after `dialogExpiry` and the message is dropped with a denial.
It takes `"60s"`, `"5m"`, `"10m"`, or `"never"`, and defaults to `5m`.
The same deadline governs a permission dialog forwarded to a remote client.

> **Gotcha:** `claude -p` binds a socket and can receive, but it cannot show an approval dialog,
> so anything held there stays held with no error and no timeout you will see.
> Give unattended workers `"crossSessionInbound": "accept"` in their `--settings`.
> `"dialogExpiry": "never"` keeps a held message parked instead of dropping it, but parked is not
> delivered: it is a way to stop losing messages, not a way to make an unattended session read them.

Turning it off is two separate controls, inbound and outbound:

```json
{
  "permissions": { "deny": ["SendMessage", "ListAgents"] },
  "crossSessionInbound": "refuse"
}
```

The deny rules take bare tool names with no specifier.
Denying `SendMessage` also cuts messaging to subagents and agent-team teammates, since it is the same tool.
Separately, `isolatePeerMachines: true` requires your approval before any message leaves the machine,
even under `bypassPermissions`. Any settings scope can turn that on, none can turn it off.

Requires v2.1.224+ on macOS or Linux (including WSL 2), not native Windows,
and not on Bedrock, Claude Platform on AWS, Google Cloud's Agent Platform, or Microsoft Foundry.
It also stays off when `DISABLE_TELEMETRY`, `DO_NOT_TRACK`, `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`,
or `DISABLE_GROWTHBOOK` disables the feature-flag evaluation it depends on.
If `/list-agents` is unrecognized the session lacks the feature;
if it works but a message never landed, the cause is on the receiving side.

Full docs: [Message your other Claude Code sessions](https://code.claude.com/docs/en/cross-session-messaging).

## Level 1: Multiple terminals

Open multiple terminals, each running `claude` in the same repo.
They share the filesystem but have separate context windows.
Largely superseded by agent view, but useful when you want each session pinned to its own terminal pane.

**Use case:** One instance writes code, another reviews it.
They can now talk to each other, see [cross-session messaging](#cross-session-messaging).

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

## Level 5: Dynamic workflows

When the orchestration outgrows a single context window — dozens-to-hundreds of agents,
a repeatable adversarial-verify pass, a large migration — reach for a workflow.
The plan moves into a script the runtime executes in the background, so only the final
answer returns to your context. See [workflows.md](workflows.md).

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
