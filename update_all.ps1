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
            if(Test-Path -Path $ThisPackageTest){
                $tResult = & $ThisPackageTest -Package $Package -Version $uResult.Version.ToString()
                if($tResult -ne $true){
                    throw "$($Package): Test after update failed."
                }
                Write-Host "$($Package): Test after update succeeded."
            }
            else{
                Write-Host "$($Package): No test script found - skipping test after update."
                $tResult = $true
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