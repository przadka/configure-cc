# Dynamic Workflows

A workflow is a JavaScript script that orchestrates subagents at scale.
Claude writes the script for the task you describe; a background runtime executes it
while your session stays responsive. Research preview, Claude Code v2.1.154+, paid plans.
(See the [version requirements table](../README.md#version-requirements) for all feature minimums.)

## The one idea

**A workflow moves the plan out of context and into code.**
Normally Claude plans *and* executes in one context window — decide a step, run it, read
the result, decide again. A workflow holds the loop, the branching, and every intermediate
result in *script variables*. Only the final answer lands back in Claude's context.

That separation is what kills the failure modes of long single-context runs:
- **Agentic laziness** — stopping at 35 of 50 items. A script that loops over all 50 can't skip 15.
- **Self-preferential bias** — Claude rating its own output favorably. Workflows spawn *independent* agents to refute each finding.
- **Goal drift** — losing the objective over many turns / after compaction. The objective lives in code.

## When to use it

| Primitive | Who holds the plan | Scale | Reach for it when |
|-----------|--------------------|-------|-------------------|
| **Skills** | Instructions Claude follows | — | Reusable prompt you invoke as `/name` |
| **Subagents** (Task) | Claude, turn by turn | a few/turn | Delegate a handful of parallel tasks |
| **Agent teams** | A lead supervises peers | handful | Long-running peer sessions, shared task list |
| **Workflows** | A script the runtime runs | dozens–hundreds | Codified orchestration, kept out of context |

**Use a workflow when:** codebase-wide sweep/audit, 500-file migration, cross-checked research,
or any process you want *repeatable* and *adversarially verified*. **Don't** when breadth doesn't
justify the token cost of dozens of agents — most coding tasks don't need a panel of 5 reviewers.

## Triggering one

```text
ultracode: audit every endpoint under src/routes/ for missing auth checks
```

- Type **`ultracode`** anywhere in a prompt (was `workflow` before v2.1.160) — forces a workflow.
- Or just say **"use a workflow"** in natural language.
- **`/effort ultracode`** — xhigh effort + auto-orchestration for *every* substantive task that session. Expensive; drop to `/effort high` for routine work.
- **`/deep-research <question>`** — bundled workflow: fan out searches, cross-check sources, vote per claim, cited report. Needs the WebSearch tool.

Saved workflows live in `.claude/workflows/` (project, shared via repo) or `~/.claude/workflows/`
(personal). They run as `/<name>` and take input via `args`.

## The patterns (the actual leverage)

The value isn't the API, it's a handful of composable shapes:

1. **Fan-out + synthesize** — N agents each cover a slice; a barrier merges them.
2. **Adversarial verify** — every finding gets an independent agent *trying to refute it*; majority-refute kills it.
3. **Pipeline** — stream each item through stages independently; item A hits stage 3 while B is still in stage 1. *The default* — no wasted wall-clock.
4. **Tournament** — to rank a big list, run pairwise-comparison agents; the script holds the bracket. Beats sorting 1000 rows in one prompt.
5. **Generate-and-filter** — produce many candidates, filter down.
6. **Loop-until-dry** — keep spawning finders until K rounds find nothing new. For unknown-size discovery (bugs, edge cases). Dedupe against *everything* seen or it never converges.
7. **Cross-model lens** — add a non-Claude reviewer (e.g. the Codex CLI) as one lens, then verify its findings with Claude. A lens agent shells out to the other tool and normalizes its output into your schema; those findings flow through the same verify pass. Agreement raises confidence; disagreement surfaces a blind spot one model alone would miss.

## Primitives Claude writes against

You rarely hand-write these — Claude does — but it helps to read a script:

```js
agent(prompt, { schema, label, phase, model, isolation: 'worktree' })  // spawn one subagent
parallel(thunks)        // fan-out BARRIER — waits for all; use only when a stage needs every prior result
pipeline(items, s1, s2) // DEFAULT — each item flows through stages independently, no barrier
phase(title)            // group progress; log(msg) emits a narrator line
args                    // JSON passed at launch (a global; undefined if omitted)
budget                  // token target, to scale depth dynamically
```

- `schema` (JSON Schema) forces validated structured output and retries on mismatch — far more reliable than asking for JSON in prose.
- `isolation: 'worktree'` gives an agent its own git worktree. Use only when agents mutate files in parallel and would conflict — it's expensive.

## Managing a run

```text
/workflows     # list runs, open the progress view (phases, agent counts, token totals)
```

Keys in the view: `p` pause/resume, `x` stop, `r` restart an agent, `s` save the script as a command.
Each run's script is written under `~/.claude/projects/<session>/` — read it, diff it, edit it, relaunch.

## Caveats

- **Token-hungry.** A run can cost dramatically more than the same task in conversation, and counts toward rate limits. Pilot on a small slice first; watch per-agent usage in `/workflows`; stop anytime without losing completed work.
- **No mid-run human input** — only permission prompts pause it. For staged sign-off, split into separate workflows.
- **Spawned agents run in `acceptEdits`** regardless of session mode — edits auto-approve. Add needed shell/web/MCP commands to your allowlist *before* a long run.
- **Quarantine untrusted content** — agents reading public/untrusted input should be barred from privileged actions; separate acting-agents do the writes. A security primitive worth designing in.
- **No filesystem/shell from the script itself** — only spawned agents read, write, and run commands. The script just coordinates.
- **`Date.now()`, `Math.random()`, argless `new Date()` throw** inside a workflow — the runtime journals execution for resumption, so non-determinism would break caching.
- **A saved workflow's `args` arrives as a JSON *string*, not an object** — parse it defensively (`JSON.parse`) at the top. A bare `typeof args === 'object'` check silently falls through to defaults, so the script runs against the wrong target instead of erroring.
- **Resume is session-bound** — exiting Claude Code restarts the workflow fresh next session.

Limits: up to 16 concurrent agents (fewer on low-core machines), 1,000 agents total per run.
Disable: toggle in `/config`, `"disableWorkflows": true` in settings.json, or `CLAUDE_CODE_DISABLE_WORKFLOWS=1`.

Full docs: [Dynamic workflows](https://code.claude.com/docs/en/workflows) ·
[Blog: A harness for every task](https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code)
