try{
    Import-Module -Name "$($PSScriptRoot)\auchocos.psd1" -Force
    Push-Location
    $PackagesPath = Join-Path "$($PSScriptRoot)" -ChildPath "packages"
    $Packages = @("dsc")

    foreach($Package in $Packages){
        $ThisPackagePath = Join-Path -Path $PackagesPath -ChildPath $Package
        $ThisPackageNuspec = Join-Path -Path $ThisPackagePath -ChildPath "$Package.nuspec"
        $ThisPackageUpdate = Join-Path -Path $ThisPackagePath -ChildPath 'update.ps1'
        $ThisPackageInstall = Join-Path -Path $ThisPackagePath -ChildPath 'install.ps1'
        $ThisPackageTest = Join-Path -Path $ThisPackagePath -ChildPath 'test.ps1'
        Set-Location -Path $ThisPackagePath
        try{
            $uResult = $null
            $iResult = $null
            $tResult = $false

            $uResult = & $ThisPackageUpdate
            Write-Host "$($Package): Update result: `n$($uResult | Format-List | Out-String)"
            
            if($true -eq $uResult.NeedsUpdate -and $uResult.WasUpdated){
                Write-Host "$($Package): Package was updated to $($uResult.Version.ToString()) - install."
                $iResult = & $ThisPackageInstall -Package $Package -Version $uResult.Version.ToString() -NuspecPath $ThisPackageNuspec
                if($true -eq $iResult.PackSuccess -and $iResilt.InstallSuccess){
                    Write-Host "$($Package): Install after update succeeded."
                    if(Test-Path -Path $ThisPackageTest){
                        $tResult = & $ThisPackageTest -Package $Package -Version $uResult.Version.ToString()
                        if($tResult -ne $true){
                            throw "$($Package): Test after update failed."
                        }
                        Write-Host "$($Package): Test after update succeeded."
                    }
                    else{
                        Write-Host "$($Package): No test script found - skipping test after update."
                    }
                }
                elseif($false -eq $iResult.PackSuccess){
                    throw "$($Package): Install after update failed - choco pack failed."
                }
                elseif($false -eq $iResult.InstallSuccess){
                    throw "$($Package): Install after update failed - choco install failed."
                }
            }
            elseif($false -eq $uResult.NeedsUpdate){
                Write-Host "$($Package): No update."
            }
            else{
                Write-Host "$($Package): Failed to run."
                throw "$($Package): Failed to run scripts."
            }

            if($true -eq $tResult){
                Write-Host "$($Package): Publish Package"
            }
        }
        catch{
            Write-Host "*** Fatal error during update_all.ps1 ***"
            $Error[0] | Format-List -Property * -Force
            Write-Host "*****************************************"
            throw $_
        }
    }
}
catch{
    Write-Host "*** Fatal error during update_all.ps1 ***"
    $Error[0] | Format-List -Property * -Force
    Write-Host "*****************************************"
    throw $_
}
finally{
    Pop-Location
}