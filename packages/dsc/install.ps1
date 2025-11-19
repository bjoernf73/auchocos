param(
    [string]$Package = 'dsc',
    [string]$Version,
    [string]$NuspecPath
)
try{
    Write-Host "$($Package): Testing nuspec '$NuspecPath'"
    Write-Host "$($Package): Current directory '$pwd'"
    if(Test-Path -Path $NuspecPath){
        Write-Host "$($Package): Found nuspec file."
    }
    else{
        throw "$($Package): Nuspec file '$ThisPackageNuspec' not found."
    }
}
catch{
    $PSCmdlet.ThrowTerminatingError($_)
}
