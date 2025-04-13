function Disable-WeakCiphers{
	$ScriptDir = Get-Item  $PSScriptRoot 
    Invoke-Expression -Command ("{0}\General\Modules\Import-Modules.ps1 -Registry" -f $ScriptDir.Parent.FullName)
    #https://docs.microsoft.com/en-us/troubleshoot/windows-server/windows-security/restrict-cryptographic-algorithms-protocols-schannel
   $insecureCiphers = @(
      'DES 56/56',
      'NULL',
      'RC2 128/128',
      'RC2 40/128',
      'RC2 56/128',
      'RC4 40/128',
      'RC4 56/128',
      'RC4 64/128',
      'RC4 128/128',
      'Triple DES 168')
    $RegKeyRoot = "HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers"

    forEach($cipher in $insecureCiphers){
        Set-RegistryKey -keyPath ("{0}\{1}" -f $RegKeyRoot, $cipher) -property "Enabled" -value 0
    }
}