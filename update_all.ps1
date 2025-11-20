try{
    Import-Module -Name "$($PSScriptRoot)\auchocos.psd1" -Force
    Push-Location
    $PackagesPath = Join-Path "$($PSScriptRoot)" -ChildPath "packages"
    $Packages = @("dsc")
    $FailedPackages = @()

    foreach($Package in $Packages){
        $ThisPackagePath = Join-Path -Path $PackagesPath -ChildPath $Package
        $ThisPackageNuspec = Join-Path -Path $ThisPackagePath -ChildPath "$Package.nuspec"
        $ThisPackageUpdate = Join-Path -Path $ThisPackagePath -ChildPath 'update.ps1'
        $ThisPackageInstall = Join-Path -Path $ThisPackagePath -ChildPath 'install.ps1'
        $ThisPackageTest = Join-Path -Path $ThisPackagePath -ChildPath 'test.ps1'
        Set-Location -Path $ThisPackagePath
        try{
            $uResult = $null  # update package result
            $iResult = $null  # install package result
            $tResult = $false # test package result
            $pResult = $false # publish package result
            $gResult = $false  # git push result

            $uResult = & $ThisPackageUpdate
            Write-Host "$($Package): Update result: `n$($uResult | Format-List | Out-String)"

            if($false -eq $uResult.NeedsUpdate){
                Write-Host "$($Package): No update."
                continue
            }
            if($false -eq $uResult.WasUpdated){
                throw "$($Package): NeedsUpdate is true but WasUpdated is false - something went wrong during update."
            }
            
            Write-Host "$($Package): Update succeeded."
            $iResult = & $ThisPackageInstall -Package $Package -Version $uResult.Version.ToString() -NuspecPath $ThisPackageNuspec
            
            if($false -eq $iResult.PackSuccess){
                throw "$($Package): choco pack failed."
            }
            if($false -eq $iResult.InstallSuccess){
                throw "$($Package): choco install failed."
            }
            
            Write-Host "$($Package): Install succeeded."
            
            $tResult = & $ThisPackageTest -Package $Package -Version $uResult.Version.ToString()
            if($tResult -ne $true){
                throw "$($Package): Test after update failed."
            }
            Write-Host "$($Package): Test succeeded - trying to publish package."

            $pResult = Publish-auPackageToChocolatey -Package $Package
            if($pResult -ne $true){
                throw "$($Package): Publish to chocolatey.org failed."
            }
            
            Write-Host "$($Package): Pushing to git"
            $PublishToGitParams = @{
                Path = $PSScriptRoot 
                Package = $Package
                Message = "AppVeyor build update: Package $($Package) updated to version $($uResult.Version.ToString())"
            }
            $gResult = Publish-auPackageToGit @PublishToGitParams
            # todo: check result?
                 
        }
        catch{
            $FailedPackages+=[PSCustomObject]@{
                Package = $Package
                Exception = $PSItem
                UpdateResult = $uResult
                InstallResult = $iResult
                TestResult = $tResult
                PublishResult = $pResult
                GitPushResult = $gResult
            }
        }
    }
    if($FailedPackages.Count -gt 0){
        foreach($failed in $FailedPackages){
            Write-Host "----------------------------------------"
            Write-Host "Package '$($failed.Package)' update/install/test/publish/git-push results:"
            Write-Host "Update result:`n$($failed.UpdateResult | Format-List | Out-String)"
            Write-Host "Install result:`n$($failed.InstallResult | Format-List | Out-String)"
            Write-Host "Test result: $($failed.TestResult)"
            Write-Host "Publish result: $($failed.PublishResult)"
            Write-Host "Git push result: $($failed.GitPushResult)"
        }
        Write-Host "----------------------------------------"
        throw "Packages failed: $($FailedPackages.Package -join ', ')"
    }
}
catch{
    throw $_
}
finally{
    Pop-Location
}