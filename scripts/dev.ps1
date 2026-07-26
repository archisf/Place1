param(
    [switch]$Build
)

$requiredTools = @("rojo", "wally")

foreach ($requiredTool in $requiredTools) {
    if (-not (Get-Command $requiredTool -ErrorAction SilentlyContinue)) {
        Write-Host "${requiredTool} is not installed or not on PATH." -ForegroundColor Red
        Write-Host "Install Rokit, run 'rokit install', then rerun this script." -ForegroundColor Yellow
        exit 1
    }
}

wally install

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
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
