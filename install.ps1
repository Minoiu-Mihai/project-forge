param(
    [string]$Version = "0.1.0"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$moduleBase = ($env:PSModulePath -split [System.IO.Path]::PathSeparator |
    Where-Object { $_ -like "$HOME*" -and $_ -match "Modules" } |
    Select-Object -First 1)

if (-not $moduleBase) {
    $moduleBase = Join-Path $HOME "Documents\PowerShell\Modules"
}

$moduleRoot = Join-Path $moduleBase "ProjectForge"
$versionRoot = Join-Path $moduleRoot $Version

Write-Host "[INFO] Installing Project Forge $Version"
Write-Host "[INFO] Target: $versionRoot"

New-Item -ItemType Directory -Path $versionRoot -Force | Out-Null

Copy-Item -Path (Join-Path $RepoRoot "ProjectForge.ps1") -Destination $versionRoot -Force
Copy-Item -Path (Join-Path $RepoRoot "ProjectForge.psm1") -Destination $versionRoot -Force
Copy-Item -Path (Join-Path $RepoRoot "templates") -Destination $versionRoot -Recurse -Force

$manifestPath = Join-Path $versionRoot "ProjectForge.psd1"

New-ModuleManifest `
    -Path $manifestPath `
    -RootModule "ProjectForge.psm1" `
    -ModuleVersion $Version `
    -Author "Mihai Minoiu" `
    -Description "PowerShell CLI tool for generating multidisciplinary engineering project structures." `
    -FunctionsToExport @("Invoke-ProjectForge") `
    -AliasesToExport @("project-forge") `
    -PowerShellVersion "5.1"

Write-Host "[DONE] Project Forge installed successfully."
Write-Host ""
Write-Host "Test it with:"
Write-Host "  Import-Module ProjectForge -Force"
Write-Host "  project-forge list-templates"