# run package specific tests
param(
    [string]$Package,
    [string]$Version
)

try{
    $DscVersionReturn = & dsc.exe --version
    if($LASTEXITCODE -ne 0){
        throw "dsc.exe --version failed with exit code $LASTEXITCODE"
    }
    if($DscVersionReturn -eq "dsc $version"){
        Write-Host "dsc: test passed. Version '$Version' is installed."
        return $true
    }
    else{
        Write-Host "dsc: test failed. dsc.exe --version returned '$DscVersionReturn' instead of 'dsc $version'."
        return $false
    }
}
catch{
    throw "$_"
}
