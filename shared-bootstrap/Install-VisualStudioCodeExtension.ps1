param(
  [string]$toolsPath,
  [string]$logFilePath,
  [string]$extensionId
)


Write-Output "---"

Write-Output "- Installing Visual Studio Code $extensionId extension..."
code --install-extension $extensionId >> $logFilePath

Write-Output "- Finished Installing Visual Studio Code $extensionId extension..."
Write-Output "---"