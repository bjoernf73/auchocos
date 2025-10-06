try{
    Import-Module -Name "$($PSScriptRoot)\auchocos.psd1" -Force
    Push-Location
    $PackagesPath = Join-Path "$($PSScriptRoot)" -ChildPath "packages"
    $Packages = @(
        "dsc"
    )

    foreach($Package in $Packages){
        $ThisPackagePath = Join-Path $PackagesPath -ChildPath $Package
        Set-Location -Path $ThisPackagePath
        try{
            $uResult = & .\update.ps1
            if($true -eq $uResult.WasUpdated){
                $tResult = & .\test.ps1
            }
        }
        catch{
            Write-Error "Error updating package '$Package': $_"
        }
    }
}
catch{
    Pop-Location
}