try{
    Import-Module -Name "$($PSScriptRoot)\..\..\auchocos.psd1" -Force
    $TemplatesRoot = "$($PSScriptRoot)\..\..\templates\dsc"

    # templates paths are paths to templates with replacement patterns that replaces the dynamic files on the package
    $TemplateNuspecPath = Join-Path -Path $TemplatesRoot -Child Path "dsc.nuspec"
    $TemplateChocolateyInstallPath = Join-Path -Path $TemplatesRoot -Child Path "chocolateyinstall.ps1"
    
    
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
        VersionStringRegex = "^v(\d+\.\d+\.\d+)$"
    }
    $GithubLatestRelease = Get-auGithubLatestRelease @GetGithubReleaseParams
    
    if(-not $GithubLatestRelease.NeedsUpdate){
        Write-Host "Package 'dcs': No update needed. $CurrentVersionString is the latest version."
        return $GithubLatestRelease
    }
    else{
        Write-Host "Package 'dsc': Needs update. New version '$($GithubLatestRelease.Version.ToString())' vs current version '$CurrentVersionString'."
    
        
        # needs to replace stuff in the nuspec and chocolateyinstall.ps1
        $NewVersionString = $GithubLatestRelease.Version.ToString()
        $NewChecksumValue = $GithubLatestRelease.ChecksumValue
        $NewChecksumAlgo = $GithubLatestRelease.ChecksumAlgo
        $NewDownloadUrl = $GithubLatestRelease.DownloadUrl

        if($null -eq $NewVersionString -or $NewVersionString -eq ""){
            throw "NewVersionString is null or empty"
        }
        if($null -eq $NewChecksumValue -or $NewChecksumValue -eq ""){
            throw "NewChecksumValue is null or empty"
        }
        if($null -eq $NewChecksumAlgo -or $NewChecksumAlgo -eq ""){
            throw "NewChecksumAlgo is null or empty"
        }
        if($null -eq $NewDownloadUrl -or $NewDownloadUrl -eq ""){
            throw "NewDownloadUrl is null or empty"
        }

        # update the nuspec. We need to replace ###version### with the new version
        (Get-Content $TemplateNuspecPath) -replace '###version###', $NewVersionString | 
            Out-File -FilePath $CurrentNuspecPath -Encoding utf8 -Force
        
        # update the chocolateyinstall.ps1. We need to replace ###version###, ###checksum###, ###checksumalg### and ###downloadurl###
        (Get-Content $TemplateChocolateyInstallPath) `
            -replace '###version###', $NewVersionString `
            -replace '###checksum###', $NewChecksumValue `
            -replace '###checksumalg###', $NewChecksumAlgo `
            -replace '###downloadurl###', $NewDownloadUrl | 
            Out-File -FilePath $CurrentChocolateyInstallPath -Encoding utf8 -Force

        # if we get here, success updating the package local files. Still needs to be tested and published
        $GithubLatestRelease.WasUpdated = $true
        return $GithubLatestRelease
    }
}
catch{
    throw "Error updating package 'dsc': $_"
}
