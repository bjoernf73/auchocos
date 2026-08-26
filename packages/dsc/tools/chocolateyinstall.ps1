# variables for v3.2.3
$DSCv3ZipCheckSum = 'E1E48218014C166BBBE0EE6364D1E9C2AB20AB5515CEDA4EABD529A4BFD49881'
$DSCv3ZipCheckSumAlg = 'sha256'
$DSCv3ZipDownloadUrl = 'https://github.com/PowerShell/DSC/releases/download/v3.2.3/DSC-3.2.3-x86_64-pc-windows-msvc.zip'

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
