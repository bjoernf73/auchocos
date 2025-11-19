try{
    Import-Module -Name "$($PSScriptRoot)\auchocos.psd1" -Force
    Push-Location
    $PackagesPath = Join-Path "$($PSScriptRoot)" -ChildPath "packages"
    $Packages = @(
        "dsc"
    )

    foreach($Package in $Packages){
        $ThisPackagePath = Join-Path -Path $PackagesPath -ChildPath $Package
        $ThisPackageNuspec = Join-Path -Path $ThisPackagePath -ChildPath "$Package.nuspec"
        $ThisPackageUpdate = Join-Path -Path $ThisPackagePath -ChildPath 'update.ps1'
        $ThisPackageTest = Join-Path -Path $ThisPackagePath -ChildPath 'test.ps1'
        Set-Location -Path $ThisPackagePath
        try{
            $uResult = $null
            $tResult = $null

            $uResult = & $ThisPackageUpdate
            if($true -eq $uResult.NeedsUpdate -and $uResult.WasUpdated){
                Write-Host "$($Package): Package was updated to $($uResult.Version.ToString()) - needs testing."
                # test the package
                try{
                    Write-Host "$($Package): Testing nuspec '$ThisPackageNuspec'"
                    if(Test-Path -Path $ThisPackageNuspec){
                        Write-Host "$($Package): Found nuspec file."
                        Test-Package -Nu "$ThisPackageNuspec" -Install -Verbose -ErrorAction Stop
                        Write-Host "$($Package): Package test passed."
                        $uResult.Tested = $true
                    }
                    else{
                        throw "$($Package): Nuspec file '$ThisPackageNuspec' not found."
                    }
                }
                catch{
                    $PSCmdlet.ThrowTerminatingError($_)
                }
                # run package specific tests
                $tResultParams = @{
                    Package = $Package
                    Version = $uResult.Version
                    NuspecPath = $ThisPackageNuspec
                }
                $tResult = & $ThisPackageTest @tResultParams
            }
            elseif($false -eq $uResult.WasUpdated){
                Write-Host "$($Package): No update."
            }
            else{
                Write-Host "$($Package): Failed to run."
                throw "$($Package): Failed to run scripts."
            }
        }
        catch{
            Write-Error "$($Package): Error updating package: $_"
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