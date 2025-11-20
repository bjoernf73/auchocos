function Publish-auPackageToChocolatey {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Package
    )

    try {
        $Nupkg = Get-Item -Path "$pwd\*" -Include "*.nupkg"

        choco apikey --key $env:CHOCO_API_KEY --source https://push.chocolatey.org/
        choco push $($NuPkg.Name) --source https://push.chocolatey.org/
    
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$($Package): Published choco '$($NuPkg.Name)'"
            return $true
        }
        else {
            Write-Host "$($Package): Failed to publish choco package '$($NuPkg.Name)' - choco push exited with code $LASTEXITCODE"
            throw "$($Package): Failed to publish choco package '$($NuPkg.Name)' - choco push exited with code $LASTEXITCODE"
        }
    }
    catch {
        throw $_
    }
}