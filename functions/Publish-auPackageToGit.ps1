function Publish-auPackageToGit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Package,

        [Parameter(Mandatory)]
        [string]$Message
    )
    try {
        Set-Location $PSScriptRoot
        Write-Host "$($Package): Current path '$pwd'"
        Write-Host "$($Package): > Adding changes to git."
        $null = & git add .
        
        Write-Host "$($Package): > Committing changes to git."
        $gitCommitOut = & git commit -m "AppVeyor build update: Package $($Package) updated to version $($uResult.Version.ToString())"
        for($c = 0; $c -lt $gitCommitOut.Length; $c++){
            Write-Host "$($Package): git commit out: $($gitCommitOut[$c])"
        }

        Write-Host "$($Package): > Pushing changes to git."
        $gitPushOut = & git push origin HEAD:main
        for($c = 0; $c -lt $gitPushOut.Length; $c++){
            Write-Host "$($Package): git commit out: $($gitPushOut[$c])"
        }

        # todo: check output against known success messages
        if($LASTEXITCODE -eq 0){
            Write-Host "$($Package): Pushed changes to git."
            return $true
        }
        else {
            for($c = 0; $c -lt $gitCommitOut.Length; $c++){
                Write-Host "$($Package): git commit out: $($gitCommitOut[$c])"
            }
            write-host " "
            for($c = 0; $c -lt $gitPushOut.Length; $c++){
                Write-Host "$($Package): git push out: $($gitPushOut[$c])"
            }
            throw "$($Package): git push failed - LASTEXITCODE $LASTEXITCODE"
        }
    }
    catch {
        throw $_
    }
}