param(
  [string]$toolsPath,
  [string]$logFilePath
)

Write-Output "- Finding Latest Git Version..."
$repoReleaseUrl = "https://api.github.com/repos/git-for-windows/git/releases/latest"
$releaseData = Invoke-RestMethod $repoReleaseUrl -SkipHttpErrorCheck -StatusCodeVariable "statusCode"
if($statusCode -ne 200) {
  throw "Unable to query git repository version..."
}

$version = $releaseData.tag_name
$asset = $releaseData.assets | Where-Object { $_.name.EndsWith("64-bit.exe")  }
$exeName = $asset.name
$url = $asset.browser_download_url
Write-Output "- Found Git Version $version"

Write-Output "- Downloading Git Installer..."
$installPath = Join-Path -Path $toolsPath -ChildPath "git_$version"
New-Item -Path $installPath -ItemType Directory -Force | Out-String | Write-Verbose

$targetFile = Join-Path -Path $toolsPath -ChildPath $exeName
Write-Output "- Downloading from $url"
Invoke-WebRequest -Uri $url -OutFile "$targetFile"

Write-Output "- Running Git Installer..."
Start-Process "$targetFile" -Wait -ArgumentList "/VERYSILENT", "/DIR=`"$installPath`"", "/LOG=`"$logFilePath`"",  "/SP-"
Remove-Item $targetFile

Write-Output "- Finished Installing Git..."
