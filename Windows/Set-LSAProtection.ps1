function Set-LSAProtection{
# https://docs.microsoft.com/en-us/windows-server/security/credentials-protection-and-management/configuring-additional-lsa-protection#BKMK_
    Set-RegistryKey -keyPath "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -property "RunAsPPL" -value 1 
}