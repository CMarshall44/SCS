function Set-SChannelProtocol{
    Param(
        [string]$Protocol,
        [switch]$Enable
    )
    if ($Enable)
    {
        Write-ToLog -Message  ('Enabling Schannel Protocol {0}' -f $Protocol) -LogDirectory $LogDir -FileName $LogFile -MsgLevel Debug
        $EnableValue = 1
        $DisableByDefaultValue = 0
    }
    else
    {
        Write-ToLog -Message  ('Disabling Schannel Protocol {0}' -f $Protocol) -LogDirectory $LogDir -FileName $LogFile -MsgLevel Debug
        $EnableValue = 0
        $DisableByDefaultValue = 1
    }
    $keys = "Client","Server"
    $RegBase = ("HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\{0}\" -f $Protocol)
    foreach ($key in $keys){
        $keyPath = ("{0}{1}" -f $RegBase, $key)
        Set-RegistryKey -keyPath $keyPath -property "Enabled" -value $EnableValue
        Set-RegistryKey -keyPath $keyPath -property "DisabledByDefault" -value $DisableByDefaultValue
    }
}
Set-SChannelProtocol -Protocol 'TLS 1.1'
Set-SChannelProtocol -Protocol 'TLS 1.2' -Enable
Set-SChannelProtocol -Protocol 'TLS 1.3' -Enable