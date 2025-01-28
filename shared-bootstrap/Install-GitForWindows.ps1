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
