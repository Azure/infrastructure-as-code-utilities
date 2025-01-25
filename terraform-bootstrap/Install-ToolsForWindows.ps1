$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if(-not $isAdmin) {
  throw "Please run this script as an Administrator"
}

$psVersion = $PSVersionTable.PSVersion

if($psVersion.Major -lt 7) {
  throw "Please run this script using PowerShell version 7 or higher"
}

function Install-Terraform {
  param(
    [string]$toolsPath
  )

  Write-Output "---"

  ## Get latest version of Terraform
  Write-Output "- Finding Latest Terraform Version..."
  $versionResponse = Invoke-WebRequest -Uri "https://checkpoint-api.hashicorp.com/v1/check/terraform"
  if($versionResponse.StatusCode -ne "200") {
      throw "Unable to query Terraform version, please check your internet connection and try again..."
  }
  $version = ($versionResponse).Content | ConvertFrom-Json | Select-Object -ExpandProperty current_version

  ## Download Terraform
  Write-Output "- Downloading Terraform $version..."
  $unzipdir = Join-Path -Path $toolsPath -ChildPath "terraform_$version"
  $zipfilePath = "$unzipdir.zip"
  $url = "https://releases.hashicorp.com/terraform/$($version)/terraform_$($version)_windows_amd64.zip" 
  Invoke-WebRequest -Uri $url -OutFile "$zipfilePath"

  ## Unzip Terraform
  Write-Output "- Unzipping Terraform..."
  Expand-Archive -Path $zipfilePath -DestinationPath $unzipdir
  Remove-Item $zipfilePath

  ## Set Env vars
  Write-Output "- Setting Terraform Path Environment Variable..."
  $env:PATH = "$($unzipdir);$env:PATH"
  [System.Environment]::SetEnvironmentVariable('PATH', $env:PATH, 'User')

  Write-Output "- Finished Installing Terraform..."
  Write-Output "---"
}

function Install-Azure-Cli {
  param(
    [string]$toolsPath,
    [string]$logFilePath
  )

  Write-Output "---"

  $ProgressPreference = 'SilentlyContinue'; 
  $msiPath = "$toolsPath\AzureCLI.msi"

  Write-Output "- Downloading Azure CLI Installer..."
  Invoke-WebRequest -Uri https://aka.ms/installazurecliwindowsx64 -OutFile $msiPath

  Write-Output "- Running Azure CLI Installer..."
  Start-Process msiexec.exe -Wait -ArgumentList "/i `"$msiPath`" /quiet /L*V $logFilePath"
  Remove-Item $msiPath

  Write-Output "- Finished Installing Azure CLI..."

  Write-Output "---"
}

function Install-Git {
  param(
    [string]$toolsPath,
    [string]$logFilePath
  )

  Write-Output "---"
  Write-Output "- Finding Latest Git Version..."
  $repoReleaseUrl = "https://api.github.com/repos/git-for-windows/git/releases/latest"
  $releaseData = Invoke-RestMethod $repoReleaseUrl -SkipHttpErrorCheck -StatusCodeVariable "statusCode"
  if($statusCode -ne 200) {
    throw "Unable to query git repository version..."
  }

  Write-Output "- Downloading Git Installer..."
  $version = $releaseData.tag_name
  $versionExe = $version.Replace("v", "").Replace("windows.", "")
  $exeName = "Git-$versionExe-64-bit.exe"
  $installPath = Join-Path -Path $toolsPath -ChildPath "git_$version"
  New-Item -Path $installPath -ItemType Directory -Force | Out-String | Write-Verbose

  $targetFile = Join-Path -Path $toolsPath -ChildPath $exeName
  $url = "https://github.com/git-for-windows/git/releases/download/$version/$exeName"
  Invoke-WebRequest -Uri $url -OutFile "$targetFile"

  Write-Output "- Running Git Installer..."
  Start-Process "$targetFile" -Wait -ArgumentList "/VERYSILENT", "/DIR=`"$installPath`"", "/LOG=`"$logFilePath`"",  "/SP-"
  Remove-Item $targetFile

  Write-Output "- Finished Installing Git..."
  Write-Output "---"
}

function Install-VsCode-Extensions {
  param(
    [string]$toolsPath,
    [string]$logFilePath
  )

  Write-Output "---"

  Write-Output "- Installing Hashicorp Terraform extension..."
  code --install-extension hashicorp.terraform >> $logFilePath

  Write-Output "- Installing azapi provider extension..."
  code --install-extension azapi-vscode.azapi >> $logFilePath
  
  Write-Output "- Installing azurerm provider extension..."
  code --install-extension ms-azuretools.vscode-azureterraform >> $logFilePath

  Write-Output "- Finished Installing Visual Studio Code Extensions..."
  Write-Output "---"
}

$toolsPath = "$env:USERPROFILE\tools"

try {
  Write-Output "Starting Tools Install..."
  Write-Output "Logs and local installs can be found in $toolsPath."

  $ProgressPreference = 'SilentlyContinue';
  New-Item -Path $toolsPath -ItemType Directory -Force | Out-String | Write-Verbose

  $fullLog = "$toolsPath\FullLog.log";
  New-Item -Path $fullLog -ItemType File -Force | Out-String | Write-Verbose

  # Install Git
  Write-Output "Installing Git..."
  Add-Content -Path $fullLog -Value "$(Get-Date -Format "yyyy-dd-MM HH:mm:ss"): Installing Git"
  $logFile = "$toolsPath\Install_Git.log"
  New-Item -Path $logFile -ItemType File -Force | Out-String | Write-Verbose
  Install-Git -toolsPath $toolsPath -logFilePath $logFile

  # Install Code Extensions
  Write-Output "Installing Visual Studio Code Extensions..."
  Add-Content -Path $fullLog -Value "$(Get-Date -Format "yyyy-dd-MM HH:mm:ss"): Installing Code Extensions"
  $logFile = "$toolsPath\Install_Code_Extensions.log"
  New-Item -Path $logFile -ItemType File -Force | Out-String | Write-Verbose
  Install-VsCode-Extensions -toolsPath $toolsPath -logFilePath $logFile

  # Install Terraform
  Write-Output "Installing Terraform CLI..."
  Add-Content -Path $fullLog -Value "$(Get-Date -Format "yyyy-dd-MM HH:mm:ss"): Installing Terraform"
  $logFile = "$toolsPath\Install_Terraform.log"
  New-Item -Path $logFile -ItemType File -Force | Out-String | Write-Verbose
  Install-Terraform -toolsPath $toolsPath

  # Install Azure CLI
  Write-Output "Installing Azure CLI..."
  Add-Content -Path $fullLog -Value "$(Get-Date -Format "yyyy-dd-MM HH:mm:ss"): Installing Azure CLI"
  $logFile = "$toolsPath\Install_Azure_CLI.log"
  New-Item -Path $logFile -ItemType File -Force | Out-String | Write-Verbose
  Install-Azure-Cli -toolsPath $toolsPath -logFilePath $logFile

  Write-Output "Tools installation completed successfully."
  Write-Output "Please close this terminal to apply the PATH changes."
  Read-Host -Prompt "Press any key to exit..."
  exit 0

} catch {
  Write-Output "An error occurred during the installation process."
  Write-Output "Please check the logs in $toolsPath for more information."
  $_ | Out-File "$toolsPath\Install_Failed.txt" -Force
}
