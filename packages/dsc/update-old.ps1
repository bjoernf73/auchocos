Import-Module -Name AU
Install-Script -Name Get-GitHubRelease


function global:au_GetLatest {
    $download_page = Invoke-WebRequest 'https://example.com/downloads'
    $version = $download_page.Links | Where-Object href -match '\.exe$' |
               Select-Object -First 1 -ExpandProperty href |
               ForEach-Object { $_ -replace '.*v([\d\.]+).*', '$1' }
    @{
        Version = $version
        URL32   = "https://example.com/downloads/app-$version.exe"
    }
}

update