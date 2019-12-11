# take user creds, encrypt with DPAPI
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/convertfrom-securestring?view=powershell-6
# the file created by this will be placed in the user's profile dir
# note that this file needs to be protected. ideally, this would point to an account that was not used for anything else
(Get-Credential).Password | ConvertFrom-SecureString | Out-File "$($env:USERPROFILE)\temp.cred"
