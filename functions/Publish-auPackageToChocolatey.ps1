function Publish-auPackageToChocolatey {
    [CmdletBinding()]
    param (
    )

    try {
        $ApiKey = (Get-auSecret -Alias ChocoApiKey -Properties Key).Key
        $Nupkg = Get-Item -Path "$pwd\*" -Include "*.nupkg"
        if ($NuPkg -is [system.io.fileinfo]) {
            & choco push $($NuPkg.Name) --source https://push.chocolatey.org/ --api-key $ApiKey
            if (-not ($LASTEXITCODE)) {
                wrl 8 "Published choco '$($NuPkg.Name)' to the Chocolatey Community Repository"
            }
            else {
                wrl 1 "Command '& choco push $($NuPkg.Name) --source https://push.chocolatey.org/ --api-key ********' failed"
                wrl 1 "The command failed with exit code $($LASTEXITCODE)"
            }
        }
        elseif ($NuPkg -is [system.array]) {
            throw "Multiple files matching $($pwd)\*.nupkg - I don't  know which to use"
        }
        else {
            throw "A file matching the pattern $($pwd)\*.nupkg was not found"
        }
    }
    catch {
        throw $_
    }
    finally {
        $ApiKey = $NULL
        Remove-Variable -Name ApiKey -ErrorAction Ignore
        Remove-Variable -Name NuPkg -ErrorAction Ignore
    }
}