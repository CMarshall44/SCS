#Convert-WMITime to sytem Date Time

$wmiDate = New-Object -ComObject Wbemscripting.swbemdatetime
$wmiDate.Value = (Get-WmiObject -Class Win32_OperatingSystem).InstallDate
[DateTime]$result = Get-Date -Date ("{0}-{1}-{2} {3}:{4}:{5}" -F $wmiDate.Year, $wmiDate.Month, $wmiDate.Day, $wmiDate.Hours, $wmiDate.Minutes, $wmiDate.Seconds ) #sure a try convert may help
