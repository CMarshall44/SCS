$clientId = "--" #Provide the Client ID
$clientSecret = "--" # Provide the ClientSecret
$ourTenantId = "--" #Specify the TenatID
# uses module Install-Module -Name WindowsAutoPilotIntune 
$Resource = "deviceManagement/windowsAutopilotDeviceIdentities"
$Resource = "deviceManagement/managedDevices"
$graphApiVersion = "Beta"
$uri = "https://graph.microsoft.com/$graphApiVersion/$($resource)"
$authority = "https://login.microsoftonline.com/$ourTenantId"
Connect-MgGraph

$SerialNumbers = Get-Content -Path "c:\temp\SerialNumbers.txt" #Provide the list of device you want to check the GroupTag
foreach ($Serial in $SerialNumbers)
{
    Write-host ("Processing {0}" -f $Serial)
    $dev = Get-AutopilotDevice -serial $Serial
    Set-AutopilotDevice -id $dev.id -groupTag Hybrid -ErrorAction SilentlyContinue
    Start-Sleep 1
    
}
