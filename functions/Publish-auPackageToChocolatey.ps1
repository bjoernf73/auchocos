function Publish-auPackageToChocolatey {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Package
    )

    try {
        $ChocoPushSuccess = $false
        $ChocoSuccessString = "was pushed successfully"
        
        if ([string]::IsNullOrEmpty($env:CHOCO_API_KEY)) {
            throw "$($Package): choco: Environment variable CHOCO_API_KEY is not set - cannot publish package to chocolatey.org"
        }

        $Nupkg = Get-Item -Path "$pwd\*" -Include "*.nupkg"
        $ChocoOut = & choco push $($NuPkg.Name) --source https://push.chocolatey.org/ --api-key $ENV:CHOCO_API_KEY
        
        for($c = 0; $c -lt $ChocoOut.Length; $c++){
            if($ChocoOut[$c] -match "$ChocoSuccessString"){
                $ChocoPushSuccess = $true
                break
            }
        }
        
        if($LASTEXITCODE -eq 0 -and $ChocoPushSuccess -eq $true){
            Write-Host "$($Package): choco: Published choco '$($NuPkg.Name)': Success"
            return $true
        }
        else {
            throw "$($Package): choco: push failed for '$($NuPkg.Name)'"
        }
    }
    catch {
        if($ChocoOut){
            for($c = 0; $c -lt $ChocoOut.Length; $c++){
                Write-Host "$($Package): choco: out> $($ChocoOut[$c])"
            }
        }
        throw $_
    }
}