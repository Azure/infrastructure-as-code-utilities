param(
  [string]$toolsPath,
  [string]$logFilePath
)

## Get latest version of Bicep
Write-Output "- Finding Latest Bicep Version..."
$repoReleaseUrl = "https://api.github.com/repos/Azure/bicep/releases/latest"
$releaseData = Invoke-RestMethod $repoReleaseUrl -SkipHttpErrorCheck -StatusCodeVariable "statusCode"
if($statusCode -ne 200) {
  throw "Unable to query git repository version..."
}

Write-Output "- Downloading Bicep..."
$version = $releaseData.tag_name
$exeName = "bicep-win-x64.exe"
$targetExeName = "bicep.exe"
$installPath = Join-Path -Path $toolsPath -ChildPath "bicep_$version"
New-Item -Path $installPath -ItemType Directory -Force | Out-String | Write-Verbose


$targetFile = Join-Path -Path $installPath -ChildPath $targetExeName
$url = "https://github.com/Azure/bicep/releases/download/$version/$exeName"
Invoke-WebRequest -Uri $url -OutFile "$targetFile"

## Set Env vars
Write-Output "- Setting Bicep Path Environment Variable..."
$env:PATH = "$($installPath);$env:PATH"
[System.Environment]::SetEnvironmentVariable('PATH', $env:PATH, 'User')

Write-Output "- Finished Installing Bicep..."
