function Get-auGithubLatestRelease {
    <#
    .SYNOPSIS
        Gets data on the latest GitHub release for a repo.
    .DESCRIPTION
        Used to get information that uses releases in GitHub repos. Returns an object: 
        [PSCustomObject]@{
            Version = [system.version]"1.2.3"
            ChecksumAlgo = "sha256"
            ChecksumValue = ""
            DownloadUrl = $NewDownloadUrl
            NeedsUpdate = $true
        }
    .EXAMPLE
        $GetGithubReleaseParams = @{
            Repo = "PowerShell/DSC"
            DownloadFileStringMatch = "x86_64-pc-windows-msvc\.zip$"
            CurrentVersion = [system.version]"3.1.0"
            VersionStringProperty = "name"
            VersionStringRegex = '^v(\d+\.\d+\.\d+)$'
        }
        Get-auGithubLatestRelease @GetGithubReleaseParams
    .PARAMETER Repo
        GitHub repo in the format "owner/repo", like "PowerShell/DSC". Get the front page of
        the repo, like "https://github.com/PowerShell/DSC", remove "https://github.com/", 
        and th erest is the repo string.
    .PARAMETER DownloadFileStringMatch
        Regex string to match the file to download from the release assets.
    .PARAMETER VersionStringProperty
        Property to use for creating the version. This produces the string $VersionString, which may be like "v1.2.3"
    .PARAMETER VersionStringRegex
        The VersionStringRegex is matched against the value of $VersionString, and the second element i.e. the first capturing group 
        ($matches[1]) is put in $VersionString. This enable us to create a string that can be used to create a system.version, 
        like [system.version]"1.2.3". If not provided, the full string from $VersionStringProperty is used.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Repo,

        [Parameter(Mandatory)]
        [string]$DownloadFileStringMatch,

        [Parameter(Mandatory)]
        [system.version]$CurrentVersion,

        [Parameter(Mandatory)]
        [string]$VersionStringProperty,

        [Parameter(Mandatory = $false)]
        [regex]$VersionStringRegex
    )
    try {
       
        $ReleasesURL = "https://api.github.com/repos/$Repo/releases"
        $task = "Getting repo from Github: $ReleasesURL"
        $InvokeWebRequestParams = @{
            Uri = $ReleasesURL
            Method = 'Get'
            ContentType = 'application/json'
            Headers = @{ Accept = "application/vnd.github.v3+json" }
            ErrorAction = 'Stop'
        }
        $ReleasesJson = Invoke-WebRequest @InvokeWebRequestParams
        
        $task = "converting response from json"
        $ReleasesObj = $ReleasesJson.Content | ConvertFrom-Json
        
        $task = "getting latest non-pre-release"
        $LatestNoPrerelaseObj = ($ReleasesObj | Where-Object { $_.prerelease -eq $false })[0]

        # url              : https://api.github.com/repos/PowerShell/DSC/releases/232324819
        # assets_url       : https://api.github.com/repos/PowerShell/DSC/releases/232324819/assets
        # upload_url       : https://uploads.github.com/repos/PowerShell/DSC/releases/232324819/assets{?name,label}
        # html_url         : https://github.com/PowerShell/DSC/releases/tag/v3.1.1
        # id               : 232324819
        # author           : @{login=SteveL-MSFT; id=11859881; node_id=MDQ6VXNlcjExODU5ODgx; avatar_url=https://avatars.githubusercontent.com...}
        # node_id          : RE_kwDOIhuAWM4N2P7T
        # tag_name         : v3.1.1
        # target_commitish : release/v3.1
        # name             : v3.1.1
        # draft            : False
        # immutable        : False
        # prerelease       : False
        # created_at       : 14.07.2025 17:57:30
        # updated_at       : 14.07.2025 19:46:42
        # published_at     : 14.07.2025 19:46:42
        # assets           : {@{url=https://api.github.com/repos/PowerShell/DSC/releases/assets/272825298; id=272825298; node_id=RA_kwDOIhuAWM4QQvvS; name=DSC-3.1.1-aarch64-apple-darwin.tar.gz; label=; uploader=; content_type=application/x-gzip; state=uploaded; size=3958705; dig
        #                 est=sha256:3794c708141563d115745db5042a179f57912bc951293b670a18eeee99e20af0; download_count=48; created_at=14.07.2025 19:46:31; updated_at=14.07.2025 19:46:32; browser_download_url=https://github.com/PowerShell/DSC/releases/download/v3.1.1/DSC-3.1.1-
        #                 aarch64-apple-darwin.tar.gz}, @{url=https://api.github.com/repos/PowerShell/DSC/releases/assets/272825305; id=272825305; node_id=RA_kwDOIhuAWM4QQvvZ; name=DSC-3.1.1-aarch64-linux.tar.gz; label=; uploader=; content_type=application/x-gzip; state=uploa
        #                 ded; size=4440841; digest=sha256:349a8eb21c5e8dc9f65cc6e34ce0ec6b52bb4b9c55abc6517179d0fa64fada36; download_count=41; created_at=14.07.2025 19:46:34; updated_at=14.07.2025 19:46:36; browser_download_url=https://github.com/PowerShell/DSC/releases/down
        #                 load/v3.1.1/DSC-3.1.1-aarch64-linux.tar.gz}, @{url=https://api.github.com/repos/PowerShell/DSC/releases/assets/272825302; id=272825302; node_id=RA_kwDOIhuAWM4QQvvW; name=DSC-3.1.1-aarch64-pc-windows-msvc.zip; label=; uploader=; content_type=applicati
        #                 on/zip; state=uploaded; size=4365654; digest=sha256:a4a0b61411b155a19d89be33b1a4491a85562424e9d7f09476ba8b91f6606afd; download_count=316; created_at=14.07.2025 19:46:33; updated_at=14.07.2025 19:46:33; browser_download_url=https://github.com/PowerShe
        #                 ll/DSC/releases/download/v3.1.1/DSC-3.1.1-aarch64-pc-windows-msvc.zip}, @{url=https://api.github.com/repos/PowerShell/DSC/releases/assets/272825293; id=272825293; node_id=RA_kwDOIhuAWM4QQvvN; name=DSC-3.1.1-x86_64-apple-darwin.tar.gz; label=; uploade
        #                 r=; content_type=application/x-gzip; state=uploaded; size=4230762; digest=sha256:7d5399a47cf8b6c1412b08fecbfc51d7e6e4793f5536edc528de1296df3534f3; download_count=21; created_at=14.07.2025 19:46:29; updated_at=14.07.2025 19:46:31; browser_download_url
        #                 =https://github.com/PowerShell/DSC/releases/download/v3.1.1/DSC-3.1.1-x86_64-apple-darwin.tar.gz}…}
        # tarball_url      : https://api.github.com/repos/PowerShell/DSC/tarball/v3.1.1
        # zipball_url      : https://api.github.com/repos/PowerShell/DSC/zipball/v3.1.1
        # body             : ## What's Changed
        #                 * Backport: Fix default output to YAML when used interactively by @SteveL-MSFT in https://github.com/PowerShell/DSC/pull/960


        #                 **Full Changelog**: https://github.com/PowerShell/DSC/compare/v3.1.0...v3.1.1

        #                 ## SHA256 Hashes of the release artifacts

        #                 - DSC-3.1.1-aarch64-apple-darwin.tar.gz
        #                     - 3794C708141563D115745DB5042A179F57912BC951293B670A18EEEE99E20AF0
        #                 - DSC-3.1.1-aarch64-linux.tar.gz
        #                     - 349A8EB21C5E8DC9F65CC6E34CE0EC6B52BB4B9C55ABC6517179D0FA64FADA36
        #                 - DSC-3.1.1-aarch64-pc-windows-msvc.zip
        #                     - A4A0B61411B155A19D89BE33B1A4491A85562424E9D7F09476BA8B91F6606AFD
        #                 - DSC-3.1.1-x86_64-apple-darwin.tar.gz
        #                     - 7D5399A47CF8B6C1412B08FECBFC51D7E6E4793F5536EDC528DE1296DF3534F3
        #                 - DSC-3.1.1-x86_64-linux.tar.gz
        #                     - AD3D35DD1AC204F067EA64396AD796425C0D6B53034C87E452ACE32CA0DDEDDE
        #                 - DSC-3.1.1-x86_64-pc-windows-msvc.zip
        #                     - 677873DA773755B34E89FA57FE086E88B1DFF87D560128E48CC5E5D2318525B7
        # discussion_url   : https://github.com/PowerShell/DSC/discussions/970
        # reactions        : @{url=https://api.github.com/repos/PowerShell/DSC/releases/232324819/reactions; total_count=3; +1=0; -1=0; laugh=0; hooray=2; confused=0; heart=0; rocket=1; eyes=0}
        # mentions_count   : 1

        $task = "getting asset matching '$DownloadFileStringMatch'"
        $AssetObj = $LatestNoPrerelaseObj.assets | Where-Object { 
            $_.Name -match "$DownloadFileStringMatch"
        }

        # url                  : https://api.github.com/repos/PowerShell/DSC/releases/assets/272825300
        # id                   : 272825300
        # node_id              : RA_kwDOIhuAWM4QQvvU
        # name                 : DSC-3.1.1-x86_64-pc-windows-msvc.zip
        # label                :
        # uploader             : @{login=SteveL-MSFT; id=11859881; node_id=MDQ6VXNlcjExODU5ODgx; avatar_url...}
        # content_type         : application/zip
        # state                : uploaded
        # size                 : 4879646
        # digest               : sha256:677873da773755b34e89fa57fe086e88b1dff87d560128e48cc5e5d2318525b7
        # download_count       : 2887
        # created_at           : 14.07.2025 19:46:32
        # updated_at           : 14.07.2025 19:46:33
        # browser_download_url : https://github.com/PowerShell/DSC/releases/download/v3.1.1/DSC-3.1.1-x86_64-pc-windows-msvc.zip

        # get the data we need from the new version
        $task = "extracting version from property '$VersionStringProperty'"
        $VersionString = $LatestNoPrerelaseObj."$VersionStringProperty"
        
        $task = "matching VersionString '$VersionString' with regex '$VersionStringRegex'"
        if($null -ne $VersionStringRegex){
            if($VersionString -match $VersionStringRegex){
                [string]$VersionString = $matches[1]
            }
            else{
                throw "The VersionString '$VersionString' did not match the regex '$VersionStringRegex'"
            }
        }
        $task = "creating [system.version] object from string '$VersionString'"
        $Version = [system.version]"$VersionString"
        
        $task = "extracting checksum, checksumalgorithm and download url"
        $ChecksumAlgo,$ChecksumValue = $AssetObj.digest -split "\:"
        $DownloadUrl = $AssetObj.browser_download_url

        $task = "creating return object"
        [PSCustomObject]@{
            Version = $Version
            ChecksumAlgo = $ChecksumAlgo
            ChecksumValue = $ChecksumValue.ToUpper()
            DownloadUrl = $DownloadUrl
            NeedsUpdate = $(if ($Version -gt $CurrentVersion) { $true } else { $false } )
            WasUpdated = $false
            TestSuccess = $false
            PushSuccess = $false
        }
    }
    catch{
        throw "Failed on task '$task': $($_.Exception.Message)"
    }
}