function Set-PCTimeZone{
    Param(
        [string]$TimeZone
    )
    if ((Get-TimeZone -ListAvailable).ID -notcontains $TimeZone){
        Write-ToLog -Message ("TimeZone '{0}' provided is not valid " -f $TimeZone) -LogDirectory $LogDir -FileName $LogFile -MsgLevel Error
        Write-ToLog -Message ("Set timezone will not proceed but workflow will continue") -LogDirectory $LogDir -FileName $LogFile -MsgLevel Error
        return
    } 
    $curTimeZone = Get-TimeZone 
    if ($curTimeZone.Id -ne $TimeZone){
        Write-ToLog -Message ("Setting TimeZone to '{0}' from {1}" -f $TimeZone, $curTimeZone) -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
        Set-TimeZone -Id $TimeZone -Verbose 
        return
    }
   Write-ToLog -Message ("Timezone already set correctly No further action required") -LogDirectory $LogDir -FileName $LogFile -MsgLevel Debug
}