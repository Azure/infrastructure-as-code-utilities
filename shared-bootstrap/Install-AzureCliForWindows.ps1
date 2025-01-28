param(
  [string]$toolsPath,
  [string]$logFilePath
)

Write-Output "---"

$ProgressPreference = 'SilentlyContinue'; 
$msiPath = Join-Path $toolsPath "AzureCLI.msi"

Write-Output "- Downloading Azure CLI Installer..."
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindowsx64 -OutFile $msiPath

Write-Output "- Running Azure CLI Installer..."
Start-Process msiexec.exe -Wait -ArgumentList "/i `"$msiPath`" /quiet /L*V $logFilePath"
Remove-Item $msiPath

Write-Output "- Finished Installing Azure CLI..."

Write-Output "---"
