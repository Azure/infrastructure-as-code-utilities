param(
  [string]$toolsPath,
  [string]$logFilePath
)

Write-Output "- Installing Az PowerShell Module..."
Install-Module Az -SkipPublisherCheck
Write-Output "- Finished Installing Az PowerShell Module..."