# just dot source like a module
. "$PSScriptRoot\..\..\functions\Get-GithubLatestRelease.ps1"

$TemplateNuspecPath = "$($PSScriptRoot)\templates\dsc.nuspec"
$TemplateChocolateyInstallPath = "$($PSScriptRoot)\templates\chocolateyinstall.ps1"
$CurrentNuspecPath  = "$($PSScriptRoot)\package\dsc.nuspec"
$CurrentChocolateyInstallPath = "$($PSScriptRoot)\package\tools\chocolateyinstall.ps1"

# get the current version

[xml]$doc = Get-Content $CurrentNuspecPath
$CurrentVersionString = $doc.package.metadata.version
$CurrentVersion = [system.version]$CurrentVersionString

# get the latest release on github
$GetGithubReleaseParams = @{
    Repo = "PowerShell/DSC"
    DownloadFileStringMatch = "x86_64-pc-windows-msvc\.zip$"
    CurrentVersion = $CurrentVersion
    VersionStringProperty = "name"
    VersionStringScriptblock = { $VersionString.substring(1) }
}
$GithubLatestRelease = Get-GithubLatestRelease @GetGithubReleaseParams
if( -not $GithubLatestRelease.NeedsUpdate ) {
    Write-Host "No update needed. Current version $CurrentVersionString is the latest."
    return
}
else{
    # neew to replace stuff in the nuspec and chocolateyinstall.ps1
    $NewVersionString = $GithubLatestRelease.Version.ToString()
    $NewChecksumValue = $GithubLatestRelease.ChecksumValue
    $NewChecksumAlgo = $GithubLatestRelease.ChecksumAlgo
    $NewDownloadUrl = $GithubLatestRelease.DownloadUrl
    Write-Host "Updating to version $NewVersionString"

    # update the nuspec. We need to replace ###version### with the new version
    (Get-Content $TemplateNuspecPath) `
        -replace '###version###', $NewVersionString `
        | Out-File -FilePath $CurrentNuspecPath -Encoding utf8 -Force
    # update the chocolateyinstall.ps1. We need to replace ###version###, ###checksum###, ###checksumalg### and ###downloadurl###
    (Get-Content $TemplateChocolateyInstallPath) `
        -replace '###version###', $NewVersionString `
        -replace '###checksum###', $NewChecksumValue `
        -replace '###checksumalg###', $NewChecksumAlgo `
        -replace '###downloadurl###', $NewDownloadUrl `
        | Out-File -FilePath $CurrentChocolateyInstallPath -Encoding utf8 -Force

}