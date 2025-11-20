# variables for v3.1.2
$DSCv3ZipCheckSum = '8DC83CCD773D5A43F5907F01034C75C64771DC0E90D53B837C11747AF3D87D43'
$DSCv3ZipCheckSumAlg = 'sha256'
$DSCv3ZipDownloadUrl = 'https://github.com/PowerShell/DSC/releases/download/v3.1.2/DSC-3.1.2-x86_64-pc-windows-msvc.zip'

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
