function Disable-LLMNR{
    $ScriptDir = Get-Item  $PSScriptRoot 
    Invoke-Expression -Command ("{0}\General\Modules\Import-Modules.ps1 -Registry" -f $ScriptDir.Parent.FullName)
    Set-RegistryKey -keyPath 'hklm:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -property "EnableMulticast" -value 0
}