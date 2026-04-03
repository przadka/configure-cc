# Configure Claude Code

A self-aware Claude Code configuration agent. Clone this repo, run `claude` inside it, and it helps you set up and optimize your Claude Code environment.

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

That's it. Claude scans your project (language, framework, tooling, git conventions), asks 0-3 questions, and generates a tailored `CLAUDE.md` — plus rules and hooks if your project warrants them.

You can also ask directly:
- "Help me set up Claude Code for my Python project"
- "Add a pre-commit hook that runs type checking"
- "Set up a PR review skill"

## What's inside

```
configure-cc/
├── CLAUDE.md                           # The agent brain — knows all CC config
├── .claude/skills/bootstrap/SKILL.md   # /bootstrap — the recommended entry point
├── examples/
│   ├── claude-md/                      # CLAUDE.md templates by project type
│   │   ├── python-project.md
│   │   └── typescript-project.md
│   ├── skills/                         # Skill files to copy and adapt
│   │   ├── commit/SKILL.md
│   │   └── review-pr/SKILL.md
│   ├── hooks/                          # Hook configs with explanations
│   │   ├── README.md
│   │   └── settings-with-hooks.json
│   └── rules/                          # Rule files (always-on + path-scoped)
│       ├── code-style.md
│       └── api-endpoints.md            # Path-scoped example
├── guides/                             # Cheatsheets for advanced features
│   ├── session-management.md           # /fork, /rewind, /compact
│   ├── multi-agent.md                  # Parallel CC, CC+Gemini, worktrees
│   └── memory-and-insights.md          # Auto memory, /insights feedback loop
└── README.md                           # You are here
```

## How to use

**As a configuration agent:** Run `claude` in this repo and ask it to generate config for your project. It reads the examples and adapts them.

**As a reference:** Browse the `examples/` and `guides/` directories on GitHub. Copy what you need into your project.

**As a learning tool:** Each example is practical and minimal. No bloat, no hypothetical scenarios — just config you'd actually use.

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

### Chrome integration (beta)
```bash
claude --chrome
```
Your real browser with login state. Requires [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn).

## Reference docs

- [Memory & CLAUDE.md](https://code.claude.com/docs/en/memory)
- [Skills](https://code.claude.com/docs/en/skills)
- [Hooks](https://code.claude.com/docs/en/hooks)
- [Settings](https://code.claude.com/docs/en/settings)
- [MCP](https://code.claude.com/docs/en/mcp)
- [Sub-agents](https://code.claude.com/docs/en/sub-agents)
- [Headless / claude -p](https://code.claude.com/docs/en/headless)
- [Full docs index](https://code.claude.com/docs/llms.txt)
