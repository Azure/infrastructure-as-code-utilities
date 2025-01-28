param(
  [string]$toolsPath = "$env:USERPROFILE\tools"
)

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if(-not $isAdmin) {
  throw "Please run this script as an Administrator"
}

$psVersion = $PSVersionTable.PSVersion

if($psVersion.Major -lt 7) {
  throw "Please run this script using PowerShell version 7 or higher"
}

function Invoke-DownloadAndRunScript {
  param(
    [string]$scriptFileName,
    [string]$scriptFileFolder = "shared-bootstrap",
    [string]$toolsPath,
    [string]$additionalArguments = ""
  )
  
  $logFilePath = Join-Path $toolsPath $scriptFileName.Replace(".ps1", ".log")
  if(-not (Test-Path $logFilePath)) {
    New-Item -ItemType "file" $logFilePath -Force
  }

  $scriptPath = Join-Path $toolsPath $scriptFileName
  if(-not (Test-Path $scriptPath)) {
    (Invoke-WebRequest "https://raw.githubusercontent.com/Azure/infrastructure-as-code-utilities/refs/heads/main/$scriptFileFolder/$scriptFileName").Content | Out-File $scriptPath -Force
  }

  Invoke-Expression "$scriptPath -toolsPath `"$toolsPath`" -logFilePath `"$logFilePath`" $additionalArguments"
}

function Add-LogItem {
  param(
    [string]$toolsPath,
    [string]$message
  )

  Write-Output "$message..."
  $logFilePath = Join-Path $toolsPath "FullLog.log"
  if(-not (Test-Path $logFilePath)) {
    New-Item -ItemType "file" $logFilePath -Force
  }
  Add-Content -Path $logFilePath -Value "$(Get-Date -Format "yyyy-dd-MM HH:mm:ss"): $message"
}

try {
  Write-Output "Starting Tools Install..."
  Write-Output "Logs and local installs can be found in $toolsPath."

  $ProgressPreference = 'SilentlyContinue';
  New-Item -Path $toolsPath -ItemType Directory -Force | Out-String | Write-Verbose

  # Install Git
  Add-LogItem -toolsPath $toolsPath -message "Installing Git"
  Invoke-DownloadAndRunScript -scriptFileName "Install-GitForWindows.ps1" -toolsPath $toolsPath

  # Install Code Extensions
  Add-LogItem -toolsPath $toolsPath -message "Installing Visual Studio Code Extensions"
  Invoke-DownloadAndRunScript -scriptFileName "Install-VisualStudioCodeExtension.ps1" -toolsPath $toolsPath -additionalArguments "-extensionId hashicorp.terraform"
  Invoke-DownloadAndRunScript -scriptFileName "Install-VisualStudioCodeExtension.ps1" -toolsPath $toolsPath -additionalArguments "-extensionId azapi-vscode.azapi"
  Invoke-DownloadAndRunScript -scriptFileName "Install-VisualStudioCodeExtension.ps1" -toolsPath $toolsPath -additionalArguments "-extensionId ms-azuretools.vscode-azureterraform"

  # Install Terraform
  Add-LogItem -toolsPath $toolsPath -message "Installing Terraform CLI"
  Invoke-DownloadAndRunScript -scriptFileName "Install-TerraformForWindows.ps1" -toolsPath $toolsPath

  # Install Azure CLI
  Add-LogItem -toolsPath $toolsPath -message "Installing Azure CLI"
  Invoke-DownloadAndRunScript -scriptFileName "Install-AzureCliForWindows.ps1" -toolsPath $toolsPath

  Write-Output "Tools installation completed successfully."
  Write-Output "Please close this terminal to apply the PATH changes."
  Read-Host -Prompt "Press any key to exit..."
  exit 0

} catch {
  Write-Output "An error occurred during the installation process."
  Write-Output "Please check the logs in $toolsPath for more information."
  $failureLog = Join-Path $toolsPath "Install_Failed.log"
  $_ | Out-File $failureLog -Force
}
