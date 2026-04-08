# Configure Claude Code

A Claude Code configuration agent. Clone this repo, run `claude`, and it helps you set up and optimize your global CC environment.

## Quick start

```bash
git clone <this-repo>
cd configure-cc
claude
```

Then run:
```
/bootstrap
```

Claude scans your environment (installed tools, existing config, shell setup), asks 0-3 questions, and generates your global `~/.claude/` config — personal CLAUDE.md, portable skills, hooks, and MCP recommendations.

Already have config? Try `/audit` for a read-only analysis with improvement suggestions.

You can also ask directly:
- "Help me set up my global Claude Code config"
- "Add a safety hook that blocks rm -rf"
- "What MCP servers should I install?"

## What's inside

```
configure-cc/
├── CLAUDE.md                             # Agent brain — CC config knowledge
├── .claude/skills/
│   ├── bootstrap/SKILL.md                # /bootstrap — generate global config
│   └── audit/SKILL.md                    # /audit — read-only config analysis
├── examples/
│   ├── claude-md/                        # CLAUDE.md templates by project type
│   │   ├── python-project.md
│   │   └── typescript-project.md
│   ├── skills/                           # Skill files to copy and adapt
│   │   ├── commit/SKILL.md
│   │   ├── review-pr/SKILL.md
│   │   └── bootstrap-project/SKILL.md    # Project-level config generator
│   ├── hooks/                            # Hook config JSON examples
│   │   └── settings-with-hooks.json
│   └── rules/                            # Rule files (always-on + path-scoped)
│       ├── code-style.md
│       └── api-endpoints.md
├── guides/                               # Cheatsheets for CC features
│   ├── hooks.md                          # Hook types, matchers, patterns
│   ├── session-management.md             # /fork, /rewind, /compact
│   ├── multi-agent.md                    # Parallel CC, worktrees, multi-model
│   ├── memory-and-insights.md            # Auto memory, /insights
│   └── statusline.md                     # Custom status bar setup
└── README.md
```

## How to use

**As a configuration agent:** Run `claude` in this repo and ask it to configure your global CC environment. It reads the examples and adapts them.

**As a reference:** Browse `examples/` and `guides/` for ready-made config you can copy into your own setup.

**As a learning tool:** Each example is practical and minimal — config you'd actually use.

## Configuration surfaces

| Surface | Location | What it does |
|---------|----------|-------------|
| CLAUDE.md | `./CLAUDE.md` or `~/.claude/CLAUDE.md` | Persistent instructions for Claude |
| Rules | `.claude/rules/*.md` | Modular, optionally path-scoped instructions |
| Skills | `.claude/skills/<name>/SKILL.md` | Reusable prompt workflows (`/skill-name`) |
| Settings | `.claude/settings.json` | Hooks, permissions, tool config |
| MCP servers | `~/.claude.json` or `.mcp.json` | External tool integrations |
| Auto memory | `~/.claude/projects/<project>/memory/` | Claude's self-written notes |

## MCP servers

### Playwright
```bash
claude mcp add --scope user playwright -- npx @playwright/mcp@latest
```
Fresh browser for testing. No login state.

### Chrome DevTools
```bash
claude mcp add --scope user chrome-devtools -- npx -y chrome-devtools-mcp@latest
```
Performance audits, network inspection, DOM access.

## Reference docs

- [Memory & CLAUDE.md](https://code.claude.com/docs/en/memory)
- [Skills](https://code.claude.com/docs/en/skills)
- [Hooks](https://code.claude.com/docs/en/hooks)
- [Settings](https://code.claude.com/docs/en/settings)
- [Status Line](https://code.claude.com/docs/en/statusline)
- [MCP](https://code.claude.com/docs/en/mcp)
- [Sub-agents](https://code.claude.com/docs/en/sub-agents)
- [Headless / claude -p](https://code.claude.com/docs/en/headless)
- [Full docs index](https://code.claude.com/docs/llms.txt)
