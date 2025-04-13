param(
    [Parameter()]
    [switch]$Registry,
    [Parameter()]
    [switch]$Logging
)
if ($Registry){
    if ((Get-Module -Name SCSolutions.General.Registry) -eq $null){
        Write-Host "Registry function needs imported"
        $ScriptDir = Get-Item  $PSScriptRoot
        Import-Module -Name ( "{0}\Registry\SCSolutions.General.Registry.psm1" -f $PSScriptRoot)
    }
    else{
        Write-Host "Registry Module Already imported"
    }
}
if ($Logging){
    if ((Get-Module -Name SCSolutions.General.Logging) -eq $null){
        Write-Host "Logging function needs imported"
        $ScriptDir = Get-Item  $PSScriptRoot
        Import-Module -Name ( "{0}\Logging\SCSolutions.General.Logging.psm1" -f $PSScriptRoot)
    }
    else{
        Write-Host "Logging Module Already imported"
    }
}
