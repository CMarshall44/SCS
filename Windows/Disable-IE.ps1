function Disable-IE(){
    $ScriptDir = Get-Item  $PSScriptRoot 
    Invoke-Expression -Command ("{0}\General\Modules\Import-Modules.ps1 -Registry" -f $ScriptDir.Parent.FullName)
    Set-RegistryProperty -keyPath "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main" -propertyType DWord -propertyName NotifyDisableIEOptions  -propertyValue 0
}