# variables for v3.1.3
$DSCv3ZipCheckSum = '638F5E93197EBE64D6D15DE743773728E0F0ED22407BD4DECC69581E42D43194'
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
