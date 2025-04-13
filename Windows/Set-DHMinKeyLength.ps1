function Set-DHMinKeyLength{
     #https://docs.microsoft.com/en-us/security-updates/SecurityAdvisories/2016/3174644
     $RegKeyRoot = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\Diffie-Hellman"
     Set-RegistryKey -keyPath $RegKeyRoot -property "ServerMinKeyBitLength" -value 2048
     Set-RegistryKey -keyPath $RegKeyRoot -property "ClientMinKeyBitLength" -value 2048
}