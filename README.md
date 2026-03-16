# Claude Code Configuration

Working notes on configuring and customizing Claude Code.

## Scope

- CLAUDE.md patterns and best practices
- Hooks configuration
- MCP server setup
- Keybindings and slash commands
- Settings and permissions
- IDE integration (VS Code, JetBrains)

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

## Status

Workspace initialized 2026-03-09.
