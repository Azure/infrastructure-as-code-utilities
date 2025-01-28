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

function Add-LogItem {
  param(
    [string]$toolsPath,
    [string]$message
  )

  $logFilePath = Join-Path $toolsPath "FullLog.log"
  if(-not (Test-Path $logFilePath)) {
    New-Item -ItemType "file" $logFilePath -Force | Out-String | Write-Verbose
  }
  Add-Content -Path $logFilePath -Value "$(Get-Date -Format "yyyy-dd-MM HH:mm:ss"): $message"
}

function Invoke-DownloadAndRunScript {
  param(
    [string]$scriptFileName,
    [string]$scriptFileFolder = "shared-bootstrap",
    [string]$toolsPath,
    [string]$additionalArguments = "",
    [string]$message = ""
  )

  if($message -ne "") {
    Write-Output ""
    Write-Output "$message..."
    Add-LogItem -toolsPath $toolsPath -message $message
  }
  
  $logFilePath = Join-Path $toolsPath $scriptFileName.Replace(".ps1", ".log")
  if(-not (Test-Path $logFilePath)) {
    New-Item -ItemType "file" $logFilePath -Force | Out-String | Write-Verbose
  }

  $scriptPath = Join-Path $toolsPath $scriptFileName
  if(-not (Test-Path $scriptPath)) {
    $url = "https://raw.githubusercontent.com/Azure/infrastructure-as-code-utilities/refs/heads/main/$scriptFileFolder/$scriptFileName"
    Write-Verbose "Downloading $scriptFileName from $url..."
    (Invoke-WebRequest $url).Content | Out-File $scriptPath -Force
  }

  Invoke-Expression "$scriptPath -toolsPath `"$toolsPath`" -logFilePath `"$logFilePath`" $additionalArguments"

  if($message -ne "") {
    Write-Output ""
  }
}



try {
  Write-Output "Starting Tools Install..."
  Write-Output "Logs and local installs can be found in $toolsPath."

  $ProgressPreference = 'SilentlyContinue';
  New-Item -Path $toolsPath -ItemType Directory -Force | Out-String | Write-Verbose

  # Install Git
  Invoke-DownloadAndRunScript -scriptFileName "Install-GitForWindows.ps1" -toolsPath $toolsPath -message "Installing Git"

  # Install Code Extensions
  Invoke-DownloadAndRunScript -scriptFileName "Install-VisualStudioCodeExtension.ps1" -toolsPath $toolsPath -additionalArguments "-extensionId hashicorp.terraform" -message "Installing Visual Studio Code Extensions"
  Invoke-DownloadAndRunScript -scriptFileName "Install-VisualStudioCodeExtension.ps1" -toolsPath $toolsPath -additionalArguments "-extensionId azapi-vscode.azapi"
  Invoke-DownloadAndRunScript -scriptFileName "Install-VisualStudioCodeExtension.ps1" -toolsPath $toolsPath -additionalArguments "-extensionId ms-azuretools.vscode-azureterraform"

  # Install Terraform
  Invoke-DownloadAndRunScript -scriptFileName "Install-TerraformForWindows.ps1" -toolsPath $toolsPath -message "Installing Terraform CLI"

  # Install Azure CLI
  Invoke-DownloadAndRunScript -scriptFileName "Install-AzureCliForWindows.ps1" -toolsPath $toolsPath -message "Installing Azure CLI"

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
