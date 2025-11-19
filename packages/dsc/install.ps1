param(
    [string]$Package = 'dsc',
    [string]$Version,
    [string]$NuspecPath
)

$iResult = [PSCustomObject]@{
    Package = $Package
    Version = $Version
    InstallSuccess = $false
    PackSuccess = $false
    Exception = $null
}
try{
    Write-Host "$($Package): Testing nuspec '$NuspecPath'"
    # first, create the package
    & choco pack $NuspecPath --no-progress --confirm
    if($LASTEXITCODE -ne 0){
        $iResult.Exception = "$($Package): choco pack failed with exit code $LASTEXITCODE"
        return $iResult
    }
    $iResult.PackSuccess = $true
    Write-Host "$($Package): choco pack success."
    
    & choco install $Package --version "$Version" --source "$pwd" --force --no-progress --confirm
    if($LASTEXITCODE -ne 0){
        $iResult.Exception = "$($Package): choco install failed with exit code $LASTEXITCODE"
        return $iResult
    }
    $iResult.InstallSuccess = $true
    Write-Host "$($Package): choco install success."
    return $iResult
}
catch{
    throw $_
}