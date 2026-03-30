# Chief of Staff -- Your AI Executive Assistant in VS Code

A **GitHub Copilot Chat agent** that connects to your Microsoft 365 work context and acts as your
personal Chief of Staff -- triaging emails, prepping meetings, drafting status updates, and
searching your work history. All from the Copilot Chat panel.

## 30-Second Setup

```powershell
git clone https://github.com/v-arloonker/chief-of-staff.git
cd chief-of-staff
.\setup.ps1
code .
```

Then in Copilot Chat: `@chief-of-staff Daily triage`

**That's it.** The setup script handles everything. VS Code auto-discovers the MCP servers.

> **Even easier:** Just paste the repo URL into GitHub Copilot Chat and say
> "Help me set up this repo" -- Copilot reads the instructions and walks you through it.

## What It Does

| Say This | Get This |
|----------|----------|
| "Daily triage" | Morning briefing: today's meetings, priority emails, risks, action items |
| "Draft my status email" | Auto-generated status email from your M365 activity, sent to your manager |
| "Prep me for my next meeting" | Agenda, attendees, recent context, talking points |
| "Summarize my emails" | Priority email digest |
| "What did Sarah say?" | Search Teams + email for any person's messages |
| "What changed since yesterday?" | Delta summary of new emails, chats, decisions |

## Prerequisites

| Requirement | Why |
|-------------|-----|
| **VS Code** with GitHub Copilot | The agent runs inside Copilot Chat |
| **Node.js 18+** | Runs the WorkIQ MCP server locally |
| **Microsoft 365 account** | Provides email, calendar, Teams data |
| **Power Platform Environment ID** | Routes M365 MCP servers (one-time setup) |

## How It Works

```
You (in Copilot Chat)
  │
  ├── @chief-of-staff "Daily triage"
  │     │
  │     ├── WorkIQ MCP ──── searches your M365 (emails, Teams, calendar)
  │     ├── Calendar MCP ── reads today's meetings
  │     ├── Mail MCP ────── drafts and sends emails
  │     └── Teams MCP ───── reads channel/chat messages
  │
  └── Agent synthesizes everything into a concise briefing
```

**MCP servers** are the bridge between Copilot and your M365 data. They're defined in
`.vscode/mcp.json` and VS Code starts them automatically.

## Configuration

After running `setup.ps1`, edit `config/user-context.yaml` with your details:

```yaml
user:
  displayName: "Your Name"
  email: "you@company.com"

statusEmail:
  recipient: "manager@company.com"
  subjectPrefix: "Your Name"
  sections:
    - name: "My Team"
      bulletCount: 6
      topics: ["project alpha", "dashboard work", "pipeline fixes"]
```

**Don't know your Power Platform Environment ID?**
1. Go to https://admin.powerplatform.microsoft.com
2. Click Environments → your environment
3. Copy the GUID from the URL

Or just ask Copilot: "Help me find my Power Platform Environment ID"

## Troubleshooting

| Problem | Fix |
|---------|-----|
| MCP servers won't connect | Run `.\setup.ps1` again to re-cache packages |
| M365 returns empty data | Look for an OAuth consent popup in VS Code -- click Allow |
| 401/403 errors | Your auth token expired. Run `az login` or re-sign into VS Code |
| "environment_id" keeps prompting | Enter your Power Platform GUID; it saves per-workspace |
| WorkIQ hangs on first use | Normal -- first download takes ~30s. Wait for it. |

## File Structure

```
chief-of-staff/
├── .github/
│   ├── copilot-instructions.md          # GHC auto-reads this -- setup + troubleshooting guide
│   ├── agents/
│   │   └── chief-of-staff.agent.md      # Agent definition
│   ├── skills/
│   │   └── daily-status-email/SKILL.md  # Status email generation
│   └── prompts/
│       └── feedcontext.prompt.md        # Auto-discover your config values
├── .vscode/
│   └── mcp.template.json               # MCP server definitions (template)
├── config/
│   └── user-context.template.yaml       # Your personal config (template)
├── docs/
│   └── setup-guide.md                   # Detailed setup walkthrough
├── setup.ps1                            # One-command setup
├── .gitignore
├── LICENSE
└── README.md                            # You are here
```

## Credits

Extracted from [WorkFAST](https://github.com/v-arloonker/WorkFAST) -- a multi-agent orchestration
system for Fabric DevOps, Databricks, ADO, and M365 productivity. This repo is the standalone
Chief of Staff component, optimized for easy setup.

## License

MIT
