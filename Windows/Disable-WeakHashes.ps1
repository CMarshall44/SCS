function Disable-Weakhashes{
	$ScriptDir = Get-Item  $PSScriptRoot 
    Invoke-Expression -Command ("{0}\General\Modules\Import-Modules.ps1 -Registry" -f $ScriptDir.Parent.FullName)
	$insecureHashes = @(
      'MD5')
    $RegKeyRoot = "HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes"

    forEach($hashes in $insecureHashes){
        Set-RegistryKey -keyPath ("{0}\{1}" -f $RegKeyRoot, $cipher) -property "Enabled" -value 0
    }
}