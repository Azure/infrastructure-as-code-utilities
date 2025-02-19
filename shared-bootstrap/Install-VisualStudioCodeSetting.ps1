param(
  [string]$toolsPath,
  [string]$logFilePath,
  [string]$settingKey,
  [string]$settingValue
)

$settingKey = "files.autoSave"
$settingValue = "afterDelay"

Write-Output "- Updating Visual Studio Code setting $settingKey to $settingValue..."

$codeSettingsFilePath = "$env:APPDATA\Code\User\settings.json"

if(!(Test-Path $codeSettingsFilePath)) {
  New-Item -ItemType file -Path $codeSettingsFilePath -Force | Out-String | Write-Verbose
  $settings = [PSObject]@{}
} else {
  $settings = Get-Content $codeSettingsFilePath | ConvertFrom-Json -Depth 100
}

if (!($settings.PSObject.Properties.Name -contains $settingKey)) {
  $settings | Add-Member -MemberType NoteProperty -Name $settingKey -Value $settingValue
}

$settings.$settingKey = $settingValue
$settings | ConvertTo-Json -Depth 100 | Set-Content $codeSettingsFilePath -Force

Write-Output "- Finished Updating Visual Studio Code setting $settingKey to $settingValue..."
