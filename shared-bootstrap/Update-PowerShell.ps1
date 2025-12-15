param(
  [string]$toolsPath,
  [string]$logFilePath
)

Write-Output "- Updating PowerShell..."
$result = winget list --id Microsoft.Powershell
if($result -eq "No installed package found matching input criteria.") {
    Write-Output "- Found no existing winget PowerShell installation, installing latest version..."
    winget install --id Microsoft.Powershell
} else {
    Write-Output "- Found existing winget PowerShell installation, updating to latest version..."
    winget upgrade --id Microsoft.Powershell
}
Write-Output "- Finished Updating PowerShell..."
