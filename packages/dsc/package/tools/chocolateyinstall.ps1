# variable
$DSCv3Version = '3.1.1'
$DSCv3ZipCheckSum = '677873DA773755B34E89FA57FE086E88B1DFF87D560128E48CC5E5D2318525B7'

# static
$ErrorActionPreference = 'Stop';
$DSCv3InstallPath = Join-Path -Path $env:PROGRAMFILES -ChildPath 'dsc'
$Url = "https://github.com/PowerShell/DSC/releases/download/v$($DSCv3Version)/DSC-$($DSCv3Version)-x86_64-pc-windows-msvc.zip"

$UnzipArgs = @{
  PackageName   = $env:ChocolateyPackageName
  UnzipLocation = $DSCv3InstallPath
  Url           = $Url
  Checksum      = $DSCv3ZipCheckSum
  ChecksumType  = 'sha256'
  Force         = $true
}
Install-ChocolateyZipPackage @UnzipArgs

# add to path as well
Install-ChocolateyPath -PathToInstall $DSCv3InstallPath -PathType 'Machine'