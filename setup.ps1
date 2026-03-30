<#
.SYNOPSIS
    One-command setup for Chief of Staff agent.
    Validates prerequisites, caches MCP packages, creates config files.

.EXAMPLE
    .\setup.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Chief of Staff -- Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# -- 1. Check Node.js -----------------------------------------------------
Write-Host "[1/5] Checking Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version 2>$null
    Write-Host "  Node.js $nodeVersion found" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: Node.js is not installed." -ForegroundColor Red
    Write-Host "  Install from https://nodejs.org (LTS recommended)" -ForegroundColor Red
    exit 1
}

$npmVersion = npm --version 2>$null
if (-not $npmVersion) {
    Write-Host "  ERROR: npm is not available." -ForegroundColor Red
    exit 1
}
Write-Host "  npm $npmVersion found" -ForegroundColor Green

# -- 2. Check VS Code extensions ------------------------------------------
Write-Host "[2/5] Checking VS Code extensions..." -ForegroundColor Yellow

$requiredExtensions = @(
    @{ Id = "GitHub.copilot";       Name = "GitHub Copilot" },
    @{ Id = "GitHub.copilot-chat";  Name = "GitHub Copilot Chat" }
)

$codeCmd = $null
if (Get-Command "code-insiders" -ErrorAction SilentlyContinue) { $codeCmd = "code-insiders" }
elseif (Get-Command "code" -ErrorAction SilentlyContinue) { $codeCmd = "code" }

if ($codeCmd) {
    $installed = & $codeCmd --list-extensions 2>$null
    foreach ($ext in $requiredExtensions) {
        if ($installed -contains $ext.Id) {
            Write-Host "  $($ext.Name) ($($ext.Id)) installed" -ForegroundColor Green
        } else {
            Write-Host "  MISSING: $($ext.Name) ($($ext.Id))" -ForegroundColor DarkYellow
            Write-Host "    Install: $codeCmd --install-extension $($ext.Id)" -ForegroundColor DarkYellow
        }
    }
} else {
    Write-Host "  WARNING: VS Code CLI not found. Cannot verify extensions." -ForegroundColor DarkYellow
}

# -- 3. Pre-cache WorkIQ MCP package --------------------------------------
Write-Host "[3/5] Pre-caching WorkIQ MCP package..." -ForegroundColor Yellow
Write-Host "  Caching @microsoft/workiq ..." -NoNewline
try {
    $null = npx -y @microsoft/workiq --help 2>$null
    Write-Host " OK" -ForegroundColor Green
} catch {
    Write-Host " cached (first-run download will occur)" -ForegroundColor DarkYellow
}

# -- 4. Create .vscode/mcp.json from template -----------------------------
Write-Host "[4/5] Setting up MCP configuration..." -ForegroundColor Yellow

$mcpJsonPath = Join-Path $PSScriptRoot ".vscode" "mcp.json"
if (Test-Path $mcpJsonPath) {
    try {
        $null = Get-Content $mcpJsonPath -Raw | ConvertFrom-Json
        Write-Host "  .vscode/mcp.json exists and is valid" -ForegroundColor Green
    } catch {
        Write-Host "  WARNING: .vscode/mcp.json has invalid JSON" -ForegroundColor Red
    }
} else {
    $mcpTemplatePath = Join-Path $PSScriptRoot ".vscode" "mcp.template.json"
    if (Test-Path $mcpTemplatePath) {
        Copy-Item $mcpTemplatePath $mcpJsonPath
        Write-Host "  Created .vscode/mcp.json from template" -ForegroundColor Green
    } else {
        Write-Host "  ERROR: .vscode/mcp.template.json not found" -ForegroundColor Red
        exit 1
    }
}

# -- 5. Create user-context.yaml from template ----------------------------
Write-Host "[5/5] Setting up user context..." -ForegroundColor Yellow

$configDir = Join-Path $PSScriptRoot "config"
$templatePath = Join-Path $configDir "user-context.template.yaml"
$userContextPath = Join-Path $configDir "user-context.yaml"

if (Test-Path $userContextPath) {
    Write-Host "  config/user-context.yaml exists" -ForegroundColor Green
} elseif (Test-Path $templatePath) {
    Copy-Item $templatePath $userContextPath
    Write-Host "  Created config/user-context.yaml from template" -ForegroundColor Green
    Write-Host "  ACTION REQUIRED: Edit config/user-context.yaml with your values" -ForegroundColor DarkYellow
} else {
    Write-Host "  WARNING: config/user-context.template.yaml not found" -ForegroundColor DarkYellow
}

# -- Summary ---------------------------------------------------------------
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Open this folder in VS Code:  code ." -ForegroundColor White
Write-Host "  2. Edit config/user-context.yaml with your name, email, and manager" -ForegroundColor White
Write-Host "  3. When prompted, enter your Power Platform Environment ID" -ForegroundColor White
Write-Host "     (find it at https://admin.powerplatform.microsoft.com)" -ForegroundColor White
Write-Host "  4. Chat: @chief-of-staff Daily triage" -ForegroundColor White
Write-Host ""
Write-Host "Tip: Use the feedcontext prompt to auto-discover your config values:" -ForegroundColor Gray
Write-Host "  In Copilot Chat, type /feedcontext and follow the prompts" -ForegroundColor Gray
Write-Host ""
