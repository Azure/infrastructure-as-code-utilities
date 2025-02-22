param(
  [string]$toolsPath = "$env:USERPROFILE\tools"
)

Write-Output "Starting Terraform Tools for Windows Install..."

$ProgressPreference = 'SilentlyContinue';

$scriptFileName = "Install-ToolsForWindows.ps1"
$scriptPath = Join-Path $toolsPath $scriptFileName
New-Item -ItemType "file" $scriptPath -Force | Out-String | Write-Verbose
(Invoke-WebRequest "https://raw.githubusercontent.com/Azure/infrastructure-as-code-utilities/refs/heads/main/shared-bootstrap/$scriptFileName").Content | Out-File $scriptPath -Force

$tools = @(
  @{ 
    name = "Git"
    script = "Install-GitForWindows.ps1"
  },
  @{ 
    name = "Visual Studio Code Settings" 
    script = "Install-VisualStudioCodeSetting.ps1"
    additionalArguments = @(
      "-settingKey files.autoSave -settingValue afterDelay"
    )
  },
  @{ 
    name = "Visual Studio Code Extensions" 
    script = "Install-VisualStudioCodeExtension.ps1"
    additionalArguments = @(
      "-extensionId hashicorp.terraform",
      "-extensionId azapi-vscode.azapi",
      "-extensionId ms-azuretools.vscode-azureterraform"
    )
  },
  @{ 
    name = "Terraform CLI" 
    script = "Install-TerraformCliForWindows.ps1" 
  },
  @{ 
    name = "Azure CLI"
    script = "Install-AzureCliForWindows.ps1" 
  }
)

$toolsJsonFilePath = Join-Path $toolsPath "tools.json"

ConvertTo-Json $tools | Out-File $toolsJsonFilePath -Force

Invoke-Expression "$scriptPath -toolsPath `"$toolsPath`" -toolsJsonFilePath `"$toolsJsonFilePath`""
