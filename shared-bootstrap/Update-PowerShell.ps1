param(
  [string]$toolsPath,
  [string]$logFilePath
)

Write-Output "- Updating PowerShell..."
$result = winget list --id Microsoft.Powershell
Write-Host "- IMPORTANT! It is possible that updating PowerShell may cause this script to terminate early. If this happens you may see the message 'Installation Abandoned' or just that it exits to the prompt before the PowerShell update completes." -ForegroundColor Yellow
Write-Host "- If this happens please wait for the PowerShell update dialog to complete, then close this terminal window, open a new admin terminal and run the script again..." -ForegroundColor Yellow
if($result -eq "No installed package found matching input criteria.") {
    Write-Output "- Found no existing winget PowerShell installation, installing latest version..."
    winget install --id Microsoft.Powershell
} else {
    Write-Output "- Found existing winget PowerShell installation, updating to latest version..."
    winget upgrade --id Microsoft.Powershell
}
Write-Output "- Finished Updating PowerShell..."
