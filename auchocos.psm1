# dot source functions
$Functions = Resolve-Path -Path "$PSScriptRoot\functions\*.ps1" -ErrorAction Stop
foreach($function in $Functions){
    . $function.Path
}

# ensure global variables are available