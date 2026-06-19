param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateSet("create", "list-templates")]
    [string]$Command,

    [Parameter(Position = 1)]
    [string]$ProjectName,

    [string]$Template = "engineering-system",

    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

$ProjectForgeRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplatesRoot = Join-Path $ProjectForgeRoot "templates"


function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message"
}


function Write-Success {
    param([string]$Message)
    Write-Host "[DONE] $Message"
}


function Write-Skip {
    param([string]$Message)
    Write-Host "[SKIP] $Message"
}


function Get-TemplatePath {
    param([string]$TemplateName)

    $templatePath = Join-Path $TemplatesRoot $TemplateName
    $templateFile = Join-Path $templatePath "template.json"

    if (-not (Test-Path $templateFile)) {
        throw "Template not found: $TemplateName"
    }

    return $templateFile
}


function Get-ProjectTemplate {
    param([string]$TemplateName)

    $templateFile = Get-TemplatePath -TemplateName $TemplateName
    $rawJson = Get-Content $templateFile -Raw
    return $rawJson | ConvertFrom-Json
}


function Show-Templates {
    if (-not (Test-Path $TemplatesRoot)) {
        throw "Templates folder not found: $TemplatesRoot"
    }

    Write-Host "Available templates:"

    Get-ChildItem $TemplatesRoot -Directory | ForEach-Object {
        $templateFile = Join-Path $_.FullName "template.json"

        if (Test-Path $templateFile) {
            $template = Get-Content $templateFile -Raw | ConvertFrom-Json
            Write-Host "  - $($template.name): $($template.description)"
        }
    }
}


function New-ProjectDirectory {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "[CREATE] Directory: $Path"
    }
    else {
        Write-Skip "Directory already exists: $Path"
    }
}


function New-ProjectFile {
    param(
        [string]$Path,
        [switch]$Overwrite
    )

    if ((Test-Path $Path) -and (-not $Overwrite)) {
        Write-Skip "File already exists: $Path"
        return
    }

    $parent = Split-Path -Parent $Path

    if ($parent -and (-not (Test-Path $parent))) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    New-Item -ItemType File -Path $Path -Force | Out-Null
    Write-Host "[CREATE] File: $Path"
}


function New-EngineeringProject {
    param(
        [string]$Name,
        [string]$TemplateName,
        [switch]$Overwrite
    )

    if ([string]::IsNullOrWhiteSpace($Name)) {
        throw "Project name is required. Usage: .\ProjectForge.ps1 create <project-name>"
    }

    $template = Get-ProjectTemplate -TemplateName $TemplateName
    $projectRoot = Join-Path (Get-Location) $Name

    Write-Info "Creating project: $projectRoot"
    Write-Info "Using template: $TemplateName"

    New-ProjectDirectory -Path $projectRoot

    foreach ($directory in $template.directories) {
        $directoryPath = Join-Path $projectRoot $directory
        New-ProjectDirectory -Path $directoryPath
    }

    foreach ($file in $template.files) {
        $filePath = Join-Path $projectRoot $file
        New-ProjectFile -Path $filePath -Overwrite:$Overwrite
    }

    Write-Success "Project created successfully."
}


switch ($Command) {
    "list-templates" {
        Show-Templates
    }

    "create" {
        New-EngineeringProject `
            -Name $ProjectName `
            -TemplateName $Template `
            -Overwrite:$Overwrite
    }
}