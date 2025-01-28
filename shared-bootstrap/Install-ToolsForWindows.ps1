param(
  [string]$toolsPath = "$env:USERPROFILE\tools",
  [string]$toolsJsonFilePath
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
    Write-Output "$message"
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
}

try {
  Write-Output "Starting Tools Install..."
  Write-Output "Logs and local installs can be found in $toolsPath."

  $ProgressPreference = 'SilentlyContinue';
  New-Item -Path $toolsPath -ItemType Directory -Force | Out-String | Write-Verbose

  $toolsJsonFilePath = Get-Content $toolsJsonFilePath | ConvertFrom-Json

  foreach($tool in $toolsJson) {
    if($null -eq $tool.additionalArguments) {
        Invoke-DownloadAndRunScript -scriptFileName $tool.script -toolsPath $toolsPath -message "Installing $($tool.name)..."
    } else {
      $isFirst = $true
      foreach($additionalArgument in $tool.additionalArguments) {
        if($isFirst) {
          Invoke-DownloadAndRunScript -scriptFileName $tool.script -toolsPath $toolsPath -message "Installing $($tool.name)..." -additionalArguments $additionalArgument
          $isFirst = $false
        } else {
          Invoke-DownloadAndRunScript -scriptFileName $tool.script -toolsPath $toolsPath -additionalArguments $additionalArgument
        }
      }
    }
  }

  Write-Output ""
  Write-Output "Tools installation completed successfully."
  Write-Output "Please close this terminal to apply the PATH changes."
  Read-Host -Prompt "Press any key to exit..."
  exit 0

} catch {
  Write-Output ""
  Write-Output "An error occurred during the installation process."
  Write-Output "Please check the logs in $toolsPath for more information."
  $failureLog = Join-Path $toolsPath "Install_Failed.log"
  $_ | Out-File $failureLog -Force
}
