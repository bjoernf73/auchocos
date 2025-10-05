# variable
$DSCv3Version = '###version###'
$DSCv3ZipCheckSum = '###checksum###'
$DSCv3ZipCheckSumAlg = '###checksumalg###'
$DSCv3ZipDownloadUrl = '###downloadurl###'

# static
$ErrorActionPreference = 'Stop';
$DSCv3InstallPath = Join-Path -Path $env:PROGRAMFILES -ChildPath 'dsc'

$UnzipArgs = @{
  PackageName   = $env:ChocolateyPackageName
  UnzipLocation = $DSCv3InstallPath
  Url           = $DSCv3ZipDownloadUrl
  Checksum      = $DSCv3ZipCheckSum
  ChecksumType  = $DSCv3ZipCheckSumType
  Force         = $true
}
Install-ChocolateyZipPackage @UnzipArgs

# add to path as well
Install-ChocolateyPath -PathToInstall $DSCv3InstallPath -PathType 'Machine'