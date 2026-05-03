Install-Module -Name VMware.PowerCLI -Scope AllUsers -Confirm:$false
Install-Module -Name PSWindowsUpdate -Scope AllUsers -Confirm:$false
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Install-Module -Name AppVeyorBYOC -Scope AllUsers -Confirm:$false

# until it install no more, do:
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot 

# AppVeyor UI → Environments → BYOC → Add Environment → Windows download the agent
