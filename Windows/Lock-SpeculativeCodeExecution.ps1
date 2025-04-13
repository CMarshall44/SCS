function Lock-SpeculativeCodeExecution{
    #https://community.tenable.com/s/article/Speculative-Execution-Side-Channel-Vulnerability-Plugin-and-Mitigation-Information
    $SpecKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    Set-RegistryKey -keyPath $SpecKey  -property "FeatureSettingsOverrideMask" -Value 3
    Set-RegistryKey -keyPath $SpecKey  -property "FeatureSettingsOverride" -Value 72
    #If the Hyper-V feature is installed, add the following registry setting:
    #Set-RegistryKey -keyPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization" -property "MinVmVersionForCpuBasedMitigations" -Value "1.0" -type "String"
}