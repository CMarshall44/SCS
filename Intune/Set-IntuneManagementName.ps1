$Creds = Get-Credential -UserName "" -Message logon
Connect-MSGraph -Credential $Creds 
$data = Import-csv -Path D:\ManagementNameFix.csv
$data| ForEach-Object {
    Write-Host ("Device ID {0}- Management Name {1}" -f $_.id, $_.name)
    Update-DeviceManagement_ManagedDevices -managedDeviceId $_.id -managedDeviceName $_.name  
}
