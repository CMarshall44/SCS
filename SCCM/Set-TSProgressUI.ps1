Function Set-TSProgressUI
{
        param (
        [uInt32]$ActionNumber,
        [uInt32]$NumberOfActions,
        [string]$Message
        )
        Try
        {  
            $TSenv = New-Object -COMObject Microsoft.SMS.TSEnvironment 
            $tsProgress = New-Object -COMObject Microsoft.SMS.TSProgressUI -ErrorAction Stop
            $logPath = $tsenv.Value("LogPath")
            $OrgName = $tsenv.Value("_SMSTSOrgName")
            $PackageName = $tsenv.Value("_SMSTSPackageName")
            $ProgressDialogMessage = $tsenv.Value("_SMSTSCustomProgressDialogMessage")
            $CurrentActionName = $tsenv.Value("_SMSTSCurrentActionName")
            $InstructionTableSize = $tsenv.Value("_SMSTSInstructionTableSize")
            $tsProgress.ShowActionProgress($OrgName,$PackageName,$ProgressDialogMessage,$CurrentActionName,$NextInstructionPointer ,$InstructionTableSize,$Message,$ActionNumber,$NumberOfActions) 
            
        }
        catch [Exception]
        {
            Write-Host "Failed to update progress" -ForegroundColor Yellow

        } 
}