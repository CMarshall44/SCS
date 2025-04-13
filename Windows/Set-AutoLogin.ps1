Import-Module -Name ("{0}\SCSolutions.General.Registry.psm1" -f $PSScriptRoot)
Set-RegistryProperty -keypath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -propertyType String -propertyName "DefaultUserName" -propertyValue "*******" 
Set-RegistryProperty -keypath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -propertyType String -propertyName "DefaultPassword" -propertyValue "*********" 
Set-RegistryProperty -keypath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -propertyType String -propertyName "AutoAdminLogon" -propertyValue "1" 