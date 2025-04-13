function Set-PCName{
    Param(
        [string]$NewPCName
    )
    Write-ToLog -Message ("Attempting to rename Computer to {0}" -f $NewPCName) -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
    $CurrentPCName = (Get-CimInstance -ClassName Win32_ComputerSystem).Name
    if ($CurrentPCName -ne $NewPCName){
        Write-ToLog -Message ("Changing PC Name from'{0}' to {1}" -f $CurrentPCName, $NewPCName) -LogDirectory $LogDir -FileName $LogFile -MsgLevel info
        Rename-Computer -NewName $NewPCName -Restart:$false -Force |Out-Null
    }
    else{
        Write-ToLog -Message ("PC name is correct no action taken '{0}'" -f $CurrentPCName) -LogDirectory $LogDir -FileName $LogFile -MsgLevel debug
    }
}