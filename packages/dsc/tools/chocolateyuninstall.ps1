$ErrorActionPreference = 'Stop';
$DSCv3InstallPath = Join-Path -Path $env:PROGRAMFILES -ChildPath 'dsc'
$RemoveArgs = @{
  Path = $DSCv3InstallPath
  Force = $true
  Recurse = $true
  ErrorAction = 'Stop'
}
Remove-Item @RemoveArgs
Uninstall-ChocolateyPath -PathToUninstall $DSCv3InstallPath -PathType 'Machine'