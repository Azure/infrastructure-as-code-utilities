param(
  [string]$toolsPath,
  [string]$logFilePath
)

## Get latest version of Terraform
Write-Output "- Finding Latest Terraform Version..."
$versionResponse = Invoke-WebRequest -Uri "https://api.releases.hashicorp.com/v1/releases/terraform?limit=20"
if($versionResponse.StatusCode -ne "200") {
    throw "Unable to query Terraform version, please check your internet connection and try again..."
}
$releases = ($versionResponse).Content | ConvertFrom-Json | Where-Object -Property is_prerelease -EQ $false
$release = $releases[0]
$version = $release.version

## Download Terraform
Write-Output "- Downloading Terraform $version..."
$unzipdir = Join-Path -Path $toolsPath -ChildPath "terraform_$version"
$zipfilePath = "$unzipdir.zip"
$os = "windows"
$architecture = "amd64"
$url = $release.builds | Where-Object { $_.arch -eq $architecture -and $_.os -eq $os } | Select-Object -First 1 -ExpandProperty url
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
