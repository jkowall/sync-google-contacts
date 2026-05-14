param(
    [string]$TaskName = "Google Contacts Sync WSL",
    [string]$RepoDir = "/home/jkowall/contacts-sync-work",
    [string]$Distro = "",
    [string]$WslUser = "jkowall",
    [string]$StartTime = "08:17"
)

$ErrorActionPreference = "Stop"

if (-not $Distro) {
    $Distro = (wsl.exe -l -q | Where-Object { $_ -and $_.Trim() } | Select-Object -First 1).Trim()
}

if (-not $Distro) {
    throw "Could not determine a WSL distro. Pass -Distro explicitly."
}

$bashCommand = "cd '$RepoDir' && CONTACTS_SYNC_REPO_DIR='$RepoDir' ./scripts/run-sync.sh"
$arguments = "-d `"$Distro`" --user `"$WslUser`" --exec /bin/bash -lc `"$bashCommand`""

$action = New-ScheduledTaskAction -Execute "wsl.exe" -Argument $arguments
$trigger = New-ScheduledTaskTrigger -Daily -At ([datetime]::ParseExact($StartTime, "HH:mm", $null))
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew `
    -ExecutionTimeLimit (New-TimeSpan -Hours 2)

$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description "Runs sync-google-contacts in WSL once per day." `
    -Force | Out-Null

Write-Host "Installed scheduled task '$TaskName'"
Write-Host "Distro: $Distro"
Write-Host "User: $WslUser"
Write-Host "Daily start time: $StartTime"
Write-Host "Command: wsl.exe $arguments"
