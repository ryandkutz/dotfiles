# ~/.config/powershell/Microsoft.PowerShell_profile.ps1

# ============================================================
# OH MY POSH
# ============================================================
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$(oh-my-posh env shell)" | Invoke-Expression
}

# ============================================================
# PSREADLINE
# ============================================================
if ($host.Name -eq 'ConsoleHost') {
    # Predictive IntelliSense from command history
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView

    # History search on arrow keys
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    # Ctrl+D to exit (Unix convention)
    Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit

    # Tab completion behavior
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

    # Syntax highlighting
    Set-PSReadLineOption -Colors @{
        Command            = 'Cyan'
        Parameter          = 'DarkCyan'
        Operator           = 'DarkYellow'
        Variable           = 'Green'
        String             = 'DarkGreen'
        Number             = 'DarkMagenta'
        Member             = 'DarkCyan'
        InlinePrediction   = 'DarkGray'
    }
}

# ============================================================
# ENVIRONMENT
# ============================================================

# Prefer less/more for paging if available
$env:PAGER = 'less'

# Make Az CLI output default to table for readability
# (override per-command with --output json when needed)
$env:AZURE_DEFAULTS_OUTPUT = 'table'

# ============================================================
# ALIASES
# ============================================================

# Unix-style conveniences
Set-Alias -Name which   -Value Get-Command
Set-Alias -Name grep    -Value Select-String

# Terraform/OpenTofu
Set-Alias -Name tf      -Value tofu     # adjust to 'terraform' if needed
Set-Alias -Name tg      -Value terragrunt

# ============================================================
# FUNCTIONS — GENERAL
# ============================================================

# Shorthand: go up N directories
function .. { Set-Location .. }
function ... { Set-Location ../.. }

# Quick directory listing with color (uses ls if eza/lsd not present)
function ll {
    if (Get-Command eza -ErrorAction SilentlyContinue) {
        eza -la --icons --git
    } else {
        Get-ChildItem -Force
    }
}

# Open the current directory in VS Code
function c. { code . }

# Print PATH entries one per line
function path { $env:PATH -split ':' }

# ============================================================
# FUNCTIONS — AZURE
# ============================================================

# Show current Az CLI subscription
function azwho {
    az account show --query '{Name:name, SubscriptionId:id, TenantId:tenantId}' --output table
}

# Quick subscription switcher
function azuse {
    param([string]$SubscriptionNameOrId)
    az account set --subscription $SubscriptionNameOrId
    azwho
}

# List all ACR repositories in a registry
function acr-repos {
    param([string]$RegistryName)
    az acr repository list --name $RegistryName --output table
}

# ============================================================
# FUNCTIONS — TERRAFORM / OPENTOFU
# ============================================================

# Terramate: run tofu plan across all stacks
function tm-plan {
    terramate run -- tofu plan
}

# Terramate: run tofu apply across all stacks
function tm-apply {
    terramate run -- tofu apply
}

# ============================================================
# FUNCTIONS — GIT
# ============================================================

function gs  { git status }
function glo { git log --oneline --graph --decorate -20 }
function gco { git checkout $args }
function gp  { git push $args }
function gpl { git pull $args }

# ============================================================
# FUNCTIONS — POWERSHELL MODULE DEV
# ============================================================

# Re-import the module in the current directory (useful during dev)
function reimport {
    $modulePath = Get-ChildItem -Path . -Filter *.psd1 | Select-Object -First 1
    if ($modulePath) {
        Remove-Module -Name $modulePath.BaseName -ErrorAction SilentlyContinue -Force
        Import-Module -Name $modulePath.FullName -Force
        Write-Host "Reimported: $($modulePath.BaseName)" -ForegroundColor Green
    } else {
        Write-Warning "No .psd1 found in current directory."
    }
}

# Run Pester tests in the current directory
function ptest {
    if (Get-Command Invoke-Pester -ErrorAction SilentlyContinue) {
        Invoke-Pester -Path . -Output Detailed
    } else {
        Write-Warning "Pester not installed. Run: Install-PSResource -Name Pester"
    }
}

# ============================================================
# COMPLETION HOOKS
# ============================================================

# Az CLI tab completion
if (Get-Command az -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName az -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
        $env:ARGCOMPLETE_USE_TEMPFILES = 1
        $env:_ARGCOMPLETE_STDOUT_FILENAME = $null
        $env:COMP_LINE = $wordToComplete
        $env:COMP_POINT = $cursorPosition
        $env:_ARGCOMPLETE = 1
        $env:_ARGCOMPLETE_SUPPRESS_SPACE = 0
        $env:_ARGCOMPLETE_IFS = "`n"
        $env:_ARGCOMPLETE_SHELL = 'fish'
        az 2>&1 | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
    }
}

# Terramate completion (if supported)
if (Get-Command terramate -ErrorAction SilentlyContinue) {
    terramate completion powershell | Out-String | Invoke-Expression
}

# kubectl completion (if present in container)
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    kubectl completion powershell | Out-String | Invoke-Expression
}

# ============================================================
# STARTUP MESSAGE (optional, remove if you prefer clean starts)
# ============================================================
Write-Host "pwsh $($PSVersionTable.PSVersion)  |  $(Get-Date -Format 'ddd dd MMM yyyy')" -ForegroundColor DarkGray