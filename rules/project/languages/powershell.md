<!-- managed by rules — changes will be overwritten by /rules:init-project -->
---
paths:
  - "**/*.ps1"
  - "**/*.psm1"
  - "**/*.psd1"
---

# PowerShell Standards

- **Version**: PowerShell 7.5 stable or 7.4 LTS (supported until Nov 2026)
- **Runtime**: .NET 9 (7.5) with DATAS memory management
- **Linting**: PSScriptAnalyzer (70+ rules, VS Code integration)
- **Package Management**: PSResourceGet v1.1.1
- **Encoding**: UTF-8 without BOM (BOM causes parsing errors)

## Core Requirements

- **MUST** use `Set-StrictMode -Version Latest`
- **MUST** use `$ErrorActionPreference = 'Stop'`
- **MUST** use approved verbs (Get-, Set-, New-, Remove-, etc.)
- **MUST** use PascalCase for functions, parameters
- **MUST** use full cmdlet names in scripts (not aliases)
- **MUST** use full parameter names (not positional)
- **MUST** use PSScriptAnalyzer for linting
- **MUST** create module manifests with Version, Author, Description
- **MUST NOT** use Read-Host in automation scripts - use parameters
- **MUST NOT** leave commented-out dead code - use source control
- **SHOULD** use PowerShell 7.5+ (cross-platform, 90% faster +=)

## Script Template

```powershell
#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
    Brief description of script
.DESCRIPTION
    Detailed description
.PARAMETER Name
    Parameter description
.EXAMPLE
    ./Script.ps1 -Name "value"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter()]
    [ValidateSet('Dev', 'Staging', 'Prod')]
    [string]$Environment = 'Dev'
)

function Main {
    Write-Host "Running with Name=$Name, Environment=$Environment"
}

Main
```

## Modern Patterns

```powershell
# Null-coalescing (7.0+)
$value = $null ?? 'default'
$result ??= 'fallback'

# Ternary operator (7.0+)
$status = $success ? 'Passed' : 'Failed'

# Pipeline chain operators (7.0+)
Get-Process notepad && Stop-Process -Name notepad
Get-Process nonexistent || Write-Host "Not found"

# Parallel foreach (7.0+)
$servers | ForEach-Object -Parallel {
    Invoke-Command -ComputerName $_ -ScriptBlock { Get-Service }
} -ThrottleLimit 10

# Splatting for readability
$params = @{
    Path        = $filePath
    Destination = $destPath
    Force       = $true
}
Copy-Item @params

# Classes
class Config {
    [string]$Name
    [int]$Port = 8080

    Config([string]$name) {
        $this.Name = $name
    }
}
```

## PowerShell 7.4/7.5 Features

```powershell
# Native byte-stream preservation (7.4+)
# Stdout redirects preserve binary data
docker save myimage:latest > image.tar

# CliXml conversion without files (7.5+)
$xml = $object | ConvertTo-CliXml
$restored = $xml | ConvertFrom-CliXml

# Test-Path with PathType (improved in 7.5)
Test-Path -Path $file -PathType Leaf -IsValid

# Test-Json with Path parameter (7.4+)
Test-Json -Path ./config.json -Schema $schema

# CSV without header (7.4+)
$data | ConvertTo-Csv -NoHeader
$data | Export-Csv -Path out.csv -NoHeader
```

## PSScriptAnalyzer

```powershell
# Install
Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser

# Run analysis
Invoke-ScriptAnalyzer -Path ./script.ps1 -Severity Warning,Error

# Key rules to enforce
# PSAvoidUsingCmdletAliases - use full cmdlet names
# PSAvoidExclaimOperator - use -not instead of !
# PSUseCmdletCorrectly - specify mandatory parameters
# PSAvoidUsingPositionalParameters - use named parameters

# CI/CD integration
$results = Invoke-ScriptAnalyzer -Path ./src -Recurse
if ($results) {
    $results | Format-Table -AutoSize
    exit 1
}
```

## Error Handling

```powershell
# Try-catch with specific errors
try {
    $result = Invoke-RestMethod -Uri $uri
}
catch [System.Net.WebException] {
    Write-Error "Network error: $_"
    throw
}
catch {
    Write-Error "Unexpected error: $_"
    throw
}
finally {
    # Cleanup
}

# Validate input
function Get-User {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9_]+$')]
        [string]$Username
    )

    # Function logic
}
```

## Anti-patterns

```powershell
# ❌ Bad
$files = ls *.txt           # Alias
if ($var -eq $null) { }     # Null check
$result = cmd /c "echo hi"  # cmd.exe

# ✅ Good
$files = Get-ChildItem -Filter *.txt
if ($null -eq $var) { }     # $null on left
$result = "hi"              # Native PowerShell
```

## Module Structure

```
MyModule/
├── MyModule.psd1           # Module manifest
├── MyModule.psm1           # Root module
├── Public/                 # Exported functions
│   └── Get-Something.ps1
├── Private/                # Internal functions
│   └── Helper.ps1
└── Tests/
    └── MyModule.Tests.ps1  # Pester tests
```
