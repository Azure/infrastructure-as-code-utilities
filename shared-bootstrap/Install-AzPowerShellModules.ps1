param(
  [string]$toolsPath,
  [string]$logFilePath,
  [string]$moduleName = "Az"
)

Write-Output "- Installing Az PowerShell Module..."
Install-Module $moduleName -SkipPublisherCheck -Force
Write-Output "- Finished Installing Az PowerShell Module..."
