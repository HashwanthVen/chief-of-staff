# Copilot Instructions -- Chief of Staff Agent

This repository is a **Chief of Staff** personal productivity agent for GitHub Copilot Chat.
It connects to your Microsoft 365 work context (Outlook, Teams, Calendar, Word) via MCP servers
and lets you triage, draft status emails, prep for meetings, and search your work history --
all from the Copilot Chat panel in VS Code.

## Setup Instructions (for GitHub Copilot)

When a user asks you to help them set up this repo, follow these steps **exactly**:

### Step 1: Check Prerequisites

```powershell
node --version   # Must be 18+
npm --version    # Comes with Node.js
```

If Node.js is missing, tell the user to install from https://nodejs.org (LTS).

### Step 2: Run Setup Script

```powershell
.\setup.ps1
```

This script:
1. Validates Node.js and npm are installed
2. Pre-caches the WorkIQ npm package (`@microsoft/workiq`)
3. Creates `.vscode/mcp.json` from the template (if not present)
4. Creates `config/user-context.yaml` from the template (if not present)
5. Checks for required VS Code extensions

### Step 3: Configure User Context

Help the user fill in `config/user-context.yaml`:

```yaml
user:
  displayName: "<Their name>"
  email: "<Their email>"

statusEmail:
  recipient: "<Manager email>"
  subjectPrefix: "<Their name>"
  sections:
    - name: "<Team 1>"
      bulletCount: 6
      topics: ["<topic1>", "<topic2>"]
```

### Step 4: Find Power Platform Environment ID

The M365 MCP servers (Mail, Calendar, Teams, Word, M365 Copilot) require a Power Platform
Environment ID. Help the user find it:

1. Go to https://admin.powerplatform.microsoft.com
2. Click "Environments" in the left nav
3. Click on their environment (usually the default one)
4. Copy the Environment ID (GUID) from the URL or details panel

When VS Code prompts for `environment_id`, they paste this GUID.

### Step 5: Verify MCP Connections

After setup, have the user test each MCP server:

```
@chief-of-staff What meetings do I have today?
```

If it works, Calendar + WorkIQ are connected. Then test:
- "Summarize my recent emails" (Mail)
- "What did [person] say in Teams?" (Teams)
- "Draft my status email" (Mail send)

### MCP Troubleshooting Guide

| Problem | Cause | Fix |
|---------|-------|-----|
| WorkIQ returns empty | Not signed into M365 | Run `az login` or sign in via VS Code Microsoft account |
| M365 servers fail with 401 | Token expired or wrong tenant | `az login --tenant <tenant-id>` |
| M365 servers fail with 403 | OAuth consent not granted | Look for a VS Code popup asking for consent -- click Allow |
| "environment_id" prompt keeps appearing | VS Code didn't save the input | Enter the GUID again; it persists per workspace |
| Mail/Calendar returns no data | Consent popup was dismissed | Restart VS Code, re-open workspace, approve the consent popup |
| npx command hangs | Firewall or proxy blocking npm | Try `npm config set registry https://registry.npmjs.org/` |
| Server shows "disconnected" in MCP panel | Package not cached | Run `npx -y @microsoft/workiq --help` in terminal to force download |

### How VS Code MCP Servers Work

- `.vscode/mcp.json` defines which MCP servers to start
- VS Code auto-discovers this file when you open the workspace
- Servers are started on-demand when a tool is first called
- `${input:environment_id}` prompts the user once, then remembers the value
- HTTP-type servers (M365) connect to Microsoft's hosted endpoints
- stdio-type servers (WorkIQ) run locally via npx

## Agent Capabilities

The `@chief-of-staff` agent can:

| Command | What It Does |
|---------|-------------|
| "Daily triage" | Morning briefing: meetings, priority emails, risks, action items |
| "Draft my status email" | Auto-generates status email from M365 signals and sends it |
| "Prep me for my next meeting" | Agenda, attendees, context, talking points |
| "Summarize my emails" | Priority email digest |
| "What did [person] say?" | Search Teams/email for communications from a person |
| "What changed since yesterday?" | Delta summary of new emails, chats, decisions |

## File Structure

```
.github/
  agents/chief-of-staff.agent.md    -- Agent definition (the brain)
  skills/daily-status-email/SKILL.md -- Status email generation skill
  prompts/feedcontext.prompt.md      -- Context enrichment prompt
  copilot-instructions.md            -- This file (auto-read by GHC)
.vscode/
  mcp.template.json                  -- MCP server definitions (template)
  mcp.json                           -- Your local MCP config (gitignored, created by setup.ps1)
config/
  user-context.template.yaml         -- User config template (committed)
  user-context.yaml                  -- Your personal config (gitignored)
docs/
  setup-guide.md                     -- Detailed setup walkthrough
setup.ps1                            -- One-command setup script
```
