# Claude Code Configuration

Working notes on configuring and customizing Claude Code.

## MCP Servers

### Playwright (`playwright`)
- **Source:** https://github.com/microsoft/playwright-mcp
- **Scope:** user (global, all projects)
- **Transport:** stdio
- **Command:** `npx @playwright/mcp@latest`
- **Mode:** headed (default) — opens a visible browser window
- **Notes:** For local web development. To scope to a specific project later, use `claude mcp add --scope project ...`

### Chrome DevTools (`chrome-devtools`)
- **Source:** https://github.com/ChromeDevTools/chrome-devtools-mcp
- **Scope:** user (global, all projects)
- **Transport:** stdio
- **Command:** `npx -y chrome-devtools-mcp@latest`
- **Prereqs:** Node.js v20.19+, Chrome stable
- **Notes:** Performance audits, network inspection, DOM access via DevTools Protocol. Use `--slim` for minimal 3-tool mode. Auto-launches Chrome on first tool use. Sends usage stats to Google by default — opt out with `--usage-statistics=false`.

### Figma (not installed)
- **Source:** https://help.figma.com/hc/en-us/articles/32132100833559-Guide-to-the-Figma-MCP-server
- **Setup:** `claude mcp add --transport http --scope user figma https://mcp.figma.com/mcp` (OAuth via `/mcp`)
- **Decision:** Skipped for now. Can export from Figma manually and pass as reference material. Revisit if design-to-code workflow becomes frequent.

## CLI Tools

### Spec-Kit (`specify`)
- **Source:** https://github.com/github/spec-kit
- **Version:** v0.1.6
- **Install:** `uv tool install specify-cli --from git+https://github.com/github/spec-kit.git`
- **Upgrade:** `uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git`
- **What it does:** Spec-driven development — define specs first, then generate implementations. Adds slash commands to Claude Code (`/speckit.constitution`, `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, `/speckit.implement`, `/speckit.clarify`, `/speckit.analyze`, `/speckit.checklist`).
- **Usage:** Run `specify init <project>` in a project directory, then use the slash commands in Claude Code.

## Session Transcripts

Extracted session transcripts live in `vlayer-vouch-sessions/`.

- **Shared gist:** https://gist.github.com/przadka/2763c927ffd6216dc5b81436b2363dae
- **Session files:** JSONL at `~/.claude/projects/<project-path>/<session-uuid>.jsonl`
- **Extraction:** Python script reads JSONL, consolidates assistant turns, summarizes tool actions. See `sessions/log-main.md` for session notes.

## Reference Docs

- [How Claude Code Works](https://code.claude.com/docs/en/how-claude-code-works) — agentic loop, tools, context
- [Skills](https://code.claude.com/docs/en/skills) — custom slash commands and skill authoring
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide) — lifecycle hooks configuration and examples
- [MCP](https://code.claude.com/docs/en/mcp) — Model Context Protocol server setup
- [Sub-agents](https://code.claude.com/docs/en/sub-agents) — agent definitions and sub-agent configuration
- [Status Line](https://code.claude.com/docs/en/statusline) — configuring the status line
- [Headless Mode](https://code.claude.com/docs/en/headless) — non-interactive/CI usage
- [Full docs index](https://code.claude.com/docs/llms.txt)
