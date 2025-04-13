function Set-PKCSMinKeyLength{
 $RegKeyRoot = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\PKCS"
 Set-RegistryKey -keyPath $RegKeyRoot -property "ClientMinKeyBitLength" -value 2048
}