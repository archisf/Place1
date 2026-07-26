$ErrorActionPreference = "Stop"

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$buildDirectory = Join-Path $projectRoot "build"

function Invoke-ProjectCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Command
    )

    Write-Host "`n==> ${Name}" -ForegroundColor Cyan
    & $Command

    if ($LASTEXITCODE -ne 0) {
        throw "${Name} failed with exit code $LASTEXITCODE."
    }
}

Push-Location $projectRoot

try {
    if (-not (Test-Path $buildDirectory)) {
        New-Item -ItemType Directory -Path $buildDirectory | Out-Null
    }

    Invoke-ProjectCommand "Install Wally dependencies from lock file" { wally install }
    Invoke-ProjectCommand "Check Luau formatting" { stylua --check src tests }
    Invoke-ProjectCommand "Lint Luau source" { selene src tests }
    Invoke-ProjectCommand "Build game place" {
        rojo build default.project.json --output build/Place1.rbxlx
    }
    Invoke-ProjectCommand "Build Studio test place" {
        rojo build tests.project.json --output build/Place1Tests.rbxlx
    }

    Write-Host "`nAll static checks passed." -ForegroundColor Green
    Write-Host "Open build/Place1Tests.rbxlx in Studio and press Play to run TestEZ." -ForegroundColor Yellow
} finally {
    Pop-Location
}
