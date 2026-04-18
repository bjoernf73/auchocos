# variables for v3.1.3
$DSCv3ZipCheckSum = '8176A6571A4B67D50565448D11F95B1D59B76896B6C6733CA5971464E4CF7EA0'
$DSCv3ZipCheckSumAlg = 'sha256'
$DSCv3ZipDownloadUrl = 'https://github.com/PowerShell/DSC/releases/download/v3.1.3/DSC-3.1.3-x86_64-pc-windows-msvc.zip'

# static
$ErrorActionPreference = 'Stop';
$DSCv3InstallPath = Join-Path -Path $env:PROGRAMFILES -ChildPath 'dsc'

$UnzipArgs = @{
  PackageName   = $env:ChocolateyPackageName
  UnzipLocation = $DSCv3InstallPath
  Url           = $DSCv3ZipDownloadUrl
  Checksum      = $DSCv3ZipCheckSum
  ChecksumType  = $DSCv3ZipCheckSumAlg
  Force         = $true
}
Install-ChocolateyZipPackage @UnzipArgs
Install-ChocolateyPath -PathToInstall $DSCv3InstallPath -PathType 'Machine'
