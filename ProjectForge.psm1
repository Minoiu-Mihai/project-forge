function Invoke-ProjectForge {
    & (Join-Path $PSScriptRoot "ProjectForge.ps1") @args
}

Set-Alias -Name project-forge -Value Invoke-ProjectForge

Export-ModuleMember -Function Invoke-ProjectForge -Alias project-forge