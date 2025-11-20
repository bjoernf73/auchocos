function Publish-auPackageToChocolatey {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Package
    )

    try {
        $ChocoPushSuccess = $false
        $ChocoSuccessString = "was pushed successfully"
        if($null -eq $ENV:CHOCO_API_KEY)
        if ([string]::IsNullOrEmpty($env:CHOCO_API_KEY)) {
            throw "$($Package): Environment variable CHOCO_API_KEY is not set - cannot publish package to chocolatey.org"
        }

        $Nupkg = Get-Item -Path "$pwd\*" -Include "*.nupkg"
        $ChocoOut = & choco push $($NuPkg.Name) --source https://push.chocolatey.org/ --api-key $ENV:CHOCO_API_KEY
        
        for($c = 0; $c -lt $ChocoOut.Length; $c++){
            if($ChocoOut[$c] -match "$ChocoSuccessString"){
                $ChocoPushSuccess = $true
                break
            }
        }
        #Write-Host "$($Package): choco push out: '$chocoPushOut'"
        #Write-Host "$($Package): LASTEXITCODE: $LASTEXITCODE"
    
        if($LASTEXITCODE -eq 0 -and $ChocoPushSuccess -eq $true){
            Write-Host "$($Package): Published choco '$($NuPkg.Name)': Success"
            return $true
        }
        else {
            for($c = 0; $c -lt $ChocoOut.Length; $c++){
                Write-Host "$($Package): choco out: $($ChocoOut[$c])"
            }
            throw "$($Package): Choco push failed for '$($NuPkg.Name)'"
        }
    }
    catch {
        throw $_
    }
}