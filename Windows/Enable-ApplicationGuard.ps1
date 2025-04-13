function Enable-ApplicationGuard{
    Param(
        $mode = "Audit"
    )
	$ScriptDir = Get-Item  $PSScriptRoot 
    Invoke-Expression -Command ("{0}\General\Modules\Import-Modules.ps1 -Registry" -f $ScriptDir.Parent.FullName)
    Invoke-Stage -Stage "Enable-VirtualisationBasedSecurity" -StageNumber 1 -Stages 2 -SubStage:$true -LogDir $LogDir -LogFile $LogFile
    Invoke-Stage -Stage "Enable-WindowsFeature" -StageNumber 2 -Stages 2 -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters "-featureName 'Windows-Defender-ApplicationGuard'"
    #Currently Might require internet
    if ($mode -eq "Audit"){
    Set-RegistryKey -keyPath "HKLM:\SOFTWARE\Policies\Microsoft\AppHVSIr" -property "AuditApplicationGuard" -value 1
    }

}