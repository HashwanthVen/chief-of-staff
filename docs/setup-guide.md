# Setup Guide

> **End-to-end setup time: ~5 minutes**

| Phase | What you do | Time |
|---|---|---|
| **1. Prerequisites** | Install Node.js (if missing) | 2 min |
| **2. Clone & setup** | One-time script | 1 min |
| **3. Configure** | Fill in your name, email, manager | 1 min |
| **4. Verify** | Send a test prompt | < 1 min |

---

## 1. Prerequisites

| Requirement | Purpose | Install |
|---|---|---|
| **Node.js 18+** | Runs the WorkIQ MCP server | [nodejs.org](https://nodejs.org) (LTS) |
| **VS Code** | IDE with Copilot Chat | [code.visualstudio.com](https://code.visualstudio.com) |
| **GitHub Copilot** | The agent runtime | VS Code extension: `GitHub.copilot` + `GitHub.copilot-chat` |

---

## 2. Clone & Setup

```powershell
git clone https://github.com/HashwanthVen/chief-of-staff.git
cd chief-of-staff
.\setup.ps1
code .
```

The script validates prereqs, caches the WorkIQ npm package, and creates your config files.

---

## 3. Configure

### 3a. Personal Context

Edit `config/user-context.yaml` (created by setup.ps1):

```yaml
user:
  displayName: "Jane Doe"
  email: "janedoe@contoso.com"

statusEmail:
  recipient: "manager@contoso.com"
  subjectPrefix: "Jane Doe"
  autoSend: true
  sections:
    - name: "Engineering POD"
      bulletCount: 6
      topics: ["pipeline optimization", "dashboard development"]
    - name: "Security POD"
      bulletCount: 6
      topics: ["access reviews", "compliance tracking"]

team:
  members: ["Alice", "Bob", "Carol"]

infrastructure:
  powerPlatformEnvironmentId: "<GUID>"
```

### 3b. Power Platform Environment ID

The M365 MCP servers need this GUID. Find it:

1. Go to https://admin.powerplatform.microsoft.com
2. Click **Environments** in the left nav
3. Click your environment (usually the default one)
4. Copy the GUID from the URL or the details panel

VS Code will prompt for this once when first connecting to M365 servers.

### 3c. Authentication

M365 MCP servers authenticate through your Microsoft identity. When VS Code first activates
a server, you'll see an OAuth consent popup -- click **Allow**.

If you hit 401/403 errors later, your token expired. Fix:
```powershell
az login    # or re-sign into VS Code
```

---

## 4. Verify

In Copilot Chat, try:

```
@chief-of-staff What meetings do I have today?
```

If it returns your calendar events, everything is connected.

### Test each capability:

| Test | Command |
|------|---------|
| Calendar | "What meetings do I have today?" |
| Email | "Summarize my recent emails" |
| Teams | "What did [someone] say in Teams?" |
| Status email | "Draft my status email" |
| Full triage | "Daily triage" |

---

## Troubleshooting

### MCP servers won't connect

1. Check the MCP panel in VS Code (View → Command Palette → "MCP: List Servers")
2. Each server should show as "connected" or "ready"
3. If not, re-run `.\setup.ps1` and restart VS Code

### M365 returns empty data

- Look for an OAuth consent popup -- it might be behind other windows
- Try restarting VS Code and re-opening the workspace
- Verify your Power Platform Environment ID is correct

### WorkIQ hangs on first use

- First download takes ~30 seconds. This is normal.
- After the first run, it starts instantly.

### "environment_id" keeps prompting

- Enter your Power Platform GUID
- VS Code saves it per-workspace -- you only enter it once
- If it keeps asking, check `.vscode/mcp.json` exists (run `.\setup.ps1`)

### Wrong tenant

If you're signed into multiple Microsoft accounts:
```powershell
az login --tenant <your-tenant-id>
```

---

## How VS Code MCP Discovery Works

When you open this repo in VS Code:

1. VS Code reads `.vscode/mcp.json` automatically
2. It registers all the MCP servers defined there
3. Servers start on-demand when a tool is first called
4. `${input:environment_id}` prompts you once, then remembers

The agent definition (`.github/agents/chief-of-staff.agent.md`) tells Copilot which
tools this agent can use. The MCP servers provide those tools.

```
.github/agents/chief-of-staff.agent.md   -- "I can use workiq, mail, calendar, teams"
         ↕
.vscode/mcp.json                         -- "Here's how to connect to those servers"
         ↕
M365 APIs (via agent365.svc)             -- "Here's the actual data"
```
