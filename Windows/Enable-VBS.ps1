function Enable-VirtualisationBasedSecurity{
    Invoke-Stage -Stage "Enable-WindowsFeature" -StageNumber 1 -Stages 1 -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters "-featureName 'Microsoft-Hyper-V'"
    Set-RegistryKey -keyPath "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -property "EnableVirtualizationBasedSecurity" -value 1
}