#$CIM = Get-CimClass -Namespace root/WMI -ClassName WmiMonitorBrightnessMethods
$CurBright = Get-WmiObject  -Namespace root/WMI -ClassName WmiMonitorBrightness
$CurBright
$wmi = Get-WmiObject  -Namespace root/WMI -ClassName WmiMonitorBrightnessMethods
$wmi.WMISetBrightness(10,0)
