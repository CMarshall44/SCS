#Requires -RunAsAdministrator
Function Run-Workflow
{
    Try
    {
        $global:ErrorActionPreference = "Stop" #Critical for workflow to function
        $global:ScriptDir = [string]$PSScriptRoot +"\"
        $global:LogDir = [string]${env:Temp} +"\"
        $global:LogFile = "BuildLab.log"
        $local:NumberOfStages = 12
        Write-Progress -Id 1 -Activity "Workflow" -Status "Initialising" -PercentComplete 0 -ErrorAction Continue #Continue on error action as not an issue if Workflow doesn't display
        Import-Module -Name ("{0}Logging.psm1" -f $ScriptDir) -Verbose -ErrorAction Stop  | Out-File -FilePath ("{0}{1}" -f $LogDir, $LogFile) -Append  #always stop if logging module fails to import as no actions should ever be taken without logging
        Import-Module -Name ("{0}Workflow.psm1" -f $ScriptDir) -Verbose -ErrorAction Stop | Out-File -FilePath ("{0}{1}" -f $LogDir, $LogFile) -Append
        Import-Module -Name ("{0}WorkflowFunctions.psm1" -f $ScriptDir) -Verbose -ErrorAction Stop | Out-File -FilePath ("{0}{1}" -f $LogDir, $LogFile) -Append
        Write-ToLog -Message "Workflow has begun" -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info

        Invoke-Stage -Stage Set-PCName -StageNumber 1 -Stages $NumberOfStages -LogDir $LogDir -LogFile $LogFile -Parameters ("-NewPCName 'HyperV-01'" )
        Invoke-Stage -Stage Set-PCTimeZone -StageNumber 2 -Stages $NumberOfStages -LogDir $LogDir -LogFile $LogFile -Parameters ("-TimeZone 'GMT Standard Time'" )
        Invoke-Stage -Stage Update-LicenceKey -StageNumber 3 -Stages $NumberOfStages -LogDir $LogDir -LogFile $LogFile -Parameters ("-ProductKey '	YDFWN-MJ9JR-3DYRK-FXXRW-78VHK'" ) #Server 2022 Standard AVMA
        Invoke-Stage -Stage Lock-TLS -StageNumber 3 -Stages $NumberOfStages -LogDir $LogDir -LogFile $LogFile
        Invoke-Stage -Stage Lock-SpeculativeCodeExec -StageNumber 4 -Stages $NumberOfStages -LogDir $LogDir -LogFile $LogFile
        Invoke-Stage -Stage Disable-LLMNR -StageNumber 5 -Stages $NumberOfStages -LogDir $LogDir -LogFile $LogFile
        Invoke-Stage -Stage Disable-NBT -StageNumber 6 -Stages $NumberOfStages -LogDir $LogDir -LogFile $LogFile
        Invoke-Stage -Stage Set-LSAProtection -StageNumber 7 -Stages $NumberOfStages -LogDir $LogDir -LogFile $LogFile
        Invoke-Stage -Stage Set-DllSearchMode -StageNumber 8 -Stages $NumberOfStages -LogDir $LogDir -LogFile $LogFile
        Invoke-Stage -Stage Enable-ApplicationGuard -StageNumber 9 -Stages $NumberOfStages -LogDir $LogDir -LogFile $LogFile
        Invoke-Stage -Stage Set-Bitlocker -StageNumber 10 -Stages $NumberOfStages -LogDir $LogDir -LogFile $LogFile
        Invoke-Stage -Stage Enable-ConstrainedLanguageMode -StageNumber 11 -Stages $NumberOfStages -LogDir $LogDir -LogFile $LogFile
        Invoke-Stage -Stage Set-LocalAccounts -StageNumber 2 -Stages $NumberOfStages -LogDir $LogDir -LogFile $LogFile -Parameters ("-LocalAdminAccountName 'LocalAdmin'") # NM
        #Invoke-Stage -Stage Enable-KeyboardFilter -StageNumber 11 -Stages $NumberOfStages -LogDir $LogDir -LogFile $LogFile
        #Enable Applocker   
        #Invoke-Stage -Stage Set-UnifiedWriteFilter -StageNumber 12 -Stages $NumberOfStages -LogDir $LogDir -LogFile $LogFile  
        #WinRM secute       https://jstuyts.github.io/Secure-WinRM-Manual/server-configuration.html
}
    Catch
    {
        Write-ToLog -Message $_.Exception -LogDirectory $LogDir -FileName $LogFile -MsgLevel Fatal
        return
    }
    Finally
    {
        Write-Progress -Id 1 -Activity "Workflow" -Status "Completed" -PercentComplete 100
        Write-ToLog -Message "Workflow has completed" -LogDirectory $LogDir -FileName $LogFile -MsgLevel Debug 
        Get-Module -Name WorkflowFunctions | Remove-Module      
        Get-Module -Name Workflow | Remove-Module
        Get-Module -Name Logging | Remove-Module      
    }
}

Run-Workflow

 