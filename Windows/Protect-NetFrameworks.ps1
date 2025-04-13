function Protect-NetFrameworks{
    $NetFrameworkVersions = 'v2.0.50727','v4.0.30319'
    $RegKeyPart1 = "HKLM:\SOFTWARE\"
    $RegKeyPart2 = "Microsoft\.NETFramework\"
    foreach($NetFrameworkVersion in $NetFrameworkVersions){
        
        Set-RegistryKey -keyPath ("{0}{1}{2}" -f $RegKeyPart1, $RegKeyPart2,$NetFrameworkVersion) -property "SystemDefaultTlsVersions" -value 1
        Set-RegistryKey -keyPath ("{0}{1}{2}" -f $RegKeyPart1, $RegKeyPart2,$NetFrameworkVersion) -property "SchUseStrongCrypto" -value 1
        if (Test-Path 'HKLM:\SOFTWARE\Wow6432Node'){
            Set-RegistryKey -keyPath ("{0}Wow6432Node\{1}{2}" -f $RegKeyPart1, $RegKeyPart2,$NetFrameworkVersion) -property "SystemDefaultTlsVersions" -value 1
            Set-RegistryKey -keyPath ("{0}Wow6432Node\{1}{2}" -f $RegKeyPart1, $RegKeyPart2,$NetFrameworkVersion) -property "SchUseStrongCrypto" -value 1
        }
    }    
}