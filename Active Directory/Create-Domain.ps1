[string]$FQDN = "DemoSolutions.Net"
[string]$NetBIOS = "DemoSolutions"
[string]$CDomainName = "DC=DemoSolutions,DC=Net"
[string]$RootOU = "_DemoSolutions"
install-windowsfeature AD-Domain-Services  -IncludeAllSubFeature  -IncludeManagementTools
Install-ADDSForest -DomainName $FQDN -DomainNetbiosName $NetBIOS  -CreateDNSDelegation:$false -DomainMode 7 -ForestMode 7 -DatabasePath "D:\ADDS\NTDS" -SysvolPath "D:\ADDS\SYSVOL" -LogPath "L:\Logs\ADDS" -Force

Get-ADUser -Filter 'Name -Like "Administrator"' -Properties * | Set-ADUser -CannotChangePassword:$false -PasswordNeverExpires:$true
Get-ADUser -Filter 'Name -Like "LocalAdmin"' -Properties * | Set-ADUser -CannotChangePassword:$false -PasswordNeverExpires:$true

Add-KdsRootKey -EffectiveTime ((get-date).addhours(-10))
Enable-ADOptionalFeature 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target $FQDN -Confirm:$false

New-ADReplicationSite  -Name "Datacentre-01" -Description "Datacentre 01 Site" -ProtectedFromAccidentalDeletion:$true
New-ADReplicationSite  -Name "Datacentre-02" -Description "Datacentre 02 Site" -ProtectedFromAccidentalDeletion:$true
New-ADReplicationSubnet -Name "10.254.1.0/24" -Site "Datacentre-01"  -Location "London, United Kingdom"
New-ADReplicationSubnet -Name "10.254.2.0/24" -Site "Datacentre-02"  -Location "Edinburgh, United Kingdom"
New-ADReplicationSubnet -Name "10.254.4.0/24" -Site "Datacentre-01" -Location "Edinburgh, United Kingdom"
Move-ADDirectoryServer  -Identity $env:COMPUTERNAME -Site "Datacentre-01"