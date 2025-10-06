Import-Module -Name "$($PSScriptRoot)\..\..\auchocos.psd1" -Force

$TemplateNuspecPath = "$($PSScriptRoot)\templates\dsc.nuspec"
$TemplateChocolateyInstallPath = "$($PSScriptRoot)\templates\chocolateyinstall.ps1"
$CurrentNuspecPath  = "$($PSScriptRoot)\package\dsc.nuspec"
$CurrentChocolateyInstallPath = "$($PSScriptRoot)\package\tools\chocolateyinstall.ps1"

# to be removed - just not to overwrite things
$CurrentNuspecPath1  = "$($PSScriptRoot)\package\dsc1.nuspec"
$CurrentChocolateyInstallPath1 = "$($PSScriptRoot)\package\tools\chocolateyinstall1.ps1"

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
$GithubLatestRelease = Get-auGithubLatestRelease @GetGithubReleaseParams
if(-not $GithubLatestRelease.NeedsUpdate){
    Write-Host "Package 'dcs': No update needed. $CurrentVersionString is the latest version."
    return
}
else{
    Write-Host "Package 'dsc': Needs update. New version '$NewVersionString' vs current version '$CurrentVersionString'."
    
    # needs to replace stuff in the nuspec and chocolateyinstall.ps1
    $NewVersionString = $GithubLatestRelease.Version.ToString()
    $NewChecksumValue = $GithubLatestRelease.ChecksumValue
    $NewChecksumAlgo = $GithubLatestRelease.ChecksumAlgo
    $NewDownloadUrl = $GithubLatestRelease.DownloadUrl

    # update the nuspec. We need to replace ###version### with the new version
    (Get-Content $TemplateNuspecPath) `
        -replace '###version###', $NewVersionString `
        | Out-File -FilePath $CurrentNuspecPath1 -Encoding utf8 -Force
    # update the chocolateyinstall.ps1. We need to replace ###version###, ###checksum###, ###checksumalg### and ###downloadurl###
    (Get-Content $TemplateChocolateyInstallPath) `
        -replace '###version###', $NewVersionString `
        -replace '###checksum###', $NewChecksumValue `
        -replace '###checksumalg###', $NewChecksumAlgo `
        -replace '###downloadurl###', $NewDownloadUrl `
        | Out-File -FilePath $CurrentChocolateyInstallPath1 -Encoding utf8 -Force
}

# just show the changes 
Write-Host ">>> showing changes: "
Get-Content -Path $CurrentNuspecPath1 | % { Write-Host $_}
Get-Content -Path $CurrentChocolateyInstallPath1 | % { Write-Host $_}
Write-Host "<<< end of changes"'