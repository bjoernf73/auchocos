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
        Set-Location -Path $(Split-Path -Path $PSScriptRoot)
        Write-Host "$($Package): git: Current path '$pwd'"
        Write-Host "$($Package): git: Adding changes."
        $null = & git add .
        
        Write-Host "$($Package): git: Committing changes."
        $gitCommitOut = & git commit -m "$Message"
        
        Write-Host "$($Package): git: Pushing changes."
        $gitPushOut = & git push origin HEAD:main

        if($LASTEXITCODE -eq 0){
            Write-Host "$($Package): git: Successfully pushed."
            return $true
        }
        else {
            throw "$($Package): git: push failed - LASTEXITCODE $LASTEXITCODE"
        }
    }
    catch {
        if($gitCommitOut){
            for($c = 0; $c -lt $gitCommitOut.Length; $c++){
                Write-Host "$($Package): git: commit out> $($gitCommitOut[$c])"
            }
        }
        if($gitPushOut){
            for($c = 0; $c -lt $gitPushOut.Length; $c++){
                Write-Host "$($Package): git: push out> $($gitPushOut[$c])"
            }
        }
        throw $_
    }
}