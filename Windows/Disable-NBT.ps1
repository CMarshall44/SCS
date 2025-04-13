function Disable-NBT{
	$ScriptDir = Get-Item  $PSScriptRoot 
    Invoke-Expression -Command ("{0}\General\Modules\Import-Modules.ps1 -Registry" -f $ScriptDir.Parent.FullName)
    $RegKey = "HKLM:\SYSTEM\CurrentControlSet\Services\NETBT\Parameters\Interfaces"
    Get-ChildItem -Path $RegKey | Set-RegistryKey -KeyPath ("{0}\{1}" -f $RegKey, $_.Name) -property "NetbiosOptions" -Value 2
}