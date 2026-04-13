param(
    [switch]$Build
)

$requiredTool = "rojo"

if (-not (Get-Command $requiredTool -ErrorAction SilentlyContinue)) {
    Write-Host "Rojo is not installed or not on PATH." -ForegroundColor Red
    Write-Host "Install Rojo first, then rerun this script." -ForegroundColor Yellow
    exit 1
}

if ($Build) {
    $buildDir = Join-Path $PSScriptRoot "..\\build"

    if (-not (Test-Path $buildDir)) {
        New-Item -ItemType Directory -Path $buildDir | Out-Null
    }

    rojo build (Join-Path $PSScriptRoot "..\\default.project.json") --output (Join-Path $buildDir "Place1.rbxlx")
    exit $LASTEXITCODE
}

rojo serve (Join-Path $PSScriptRoot "..\\default.project.json")
