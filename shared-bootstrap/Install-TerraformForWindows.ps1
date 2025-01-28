param(
  [string]$toolsPath,
  [string]$logFilePath
)

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
