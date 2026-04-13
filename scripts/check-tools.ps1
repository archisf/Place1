$tools = @("rojo", "wally", "stylua", "selene", "git")

foreach ($tool in $tools) {
    $command = Get-Command $tool -ErrorAction SilentlyContinue

    if ($null -eq $command) {
        Write-Host "${tool}: missing" -ForegroundColor Yellow
    } else {
        Write-Host "${tool}: found -> $($command.Source)" -ForegroundColor Green
    }
}
