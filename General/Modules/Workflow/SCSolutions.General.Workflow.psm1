Function Invoke-Stage 
{
    param(
    [string]$Stage,
    [string]$Parameters = "",
    [int]$StageNumber,
    [int]$Stages,
    [string]$LogDir,
    [string]$LogFile,
    [bool]$SubStage = $false
    )
    try{
		Write-ToLog -Message "Stage $stage has been started" -LogDirectory $logDir -FileName $Logfile -MsgLevel Info   
        try{
			$percentComplete =  (($StageNumber - 1) / $Stages) *100 #Calculating the percentage of stages complete as it is at the begins we minus 1 of the stagenumber to get the % complete
        }
        catch{
            $percentComplete = 0 # Set the progress bar to 0% on any error as do not want to fail a stage because of a invalid number when calculating the %
        }
        #Bounding percentage to valid numbers
        if ($percentComplete -Lt 0) {$percentComplete = 0}
        if ($percentComplete -gt 100) {$percentComplete = 100}
        if ($SubStage){
            [int]$WorkFlowID = 100
            Write-Progress -Id $WorkFlowID -Activity "Workflow" -Status $Stage -PercentComplete $percentComplete -ParentID 1 -ErrorAction SilentlyContinue  
        }
        else{
            [int]$WorkFlowID = 1
        }
        Write-Progress -Id $WorkFlowID -Activity "Workflow" -Status $Stage -PercentComplete $percentComplete -ErrorAction SilentlyContinue

        $ExpCmd = ("{0} {1}" -F $Stage, $Parameters) 
        Write-ToLog -Message ("Executing command '{0}' with Parameters '{1}'" -f $Stage, $Parameters) -LogDirectory $logDir -FileName $Logfile -MsgLevel Info   
        Invoke-Expression -Command $ExpCmd
    }
    catch{
        Write-ToLog -Message $_.Exception -LogDirectory $logDir -FileName $Logfile -MsgLevel Error   
        Show-StageFailure -LogDir $LogDir -LogFile $LogFile
    }
    finally{
        Write-ToLog -Message "Stage $stage has completed" -LogDirectory $logDir -FileName $Logfile -MsgLevel Info   
		If ($StageNumber -ge  $Stages){
            Write-Progress -Id $WorkFlowID -Activity "Workflow" -Completed
        }
    }
}

Function Show-StageFailure
{
param(
    
    [string]$LogDir,
    [string]$LogFile
    )
     Write-ToLog -Message "Error has been detected in stage $stage of the work flow" -LogDirectory $logDir -FileName $Logfile -MsgLevel Error   
    try{
        $dialogAnswer= [System.Windows.Forms.MessageBox]::Show("An error has occurred during $stage of the workflow" , "Workflow" , 2)
    }
    catch [System.Management.Automation.RuntimeException]{
    # Rework for server core as server core doesn't contain Windows Forms
       $dialogAnswer = Read-Host "An error has occurred during $stage of the workflow do you wish to 'Abort' (A) 'Retry' (R) or 'Ignore' (I"
        Switch ($dialogAnswer){
            "A"{
                $DialogAnswer = "Abort"
            }
            "R"{
                $DialogAnswer = "Retry"
            }
            "I" {
                $dialogAnswer = "Ignore"
            }
        }
        while ("Abort","Retry","Ignore" -notcontains $dialogAnswer){
            #Loop invalid answers
             $dialogAnswer = Read-Host "An error has occurred during $stage of the workflow do you wish to 'Abort' (A) 'Retry' (R) or 'Ignore' (I)"
        }
    }   
    Switch ($dialogAnswer)
    {
        "Abort" 
        {
            #User has chosen to abort Throwing Exception
            Write-ToLog -Message "User has chosen to abort the workflow after error at stage $stage" -LogDirectory $logDir -FileName $Logfile -MsgLevel Error
            Throw $_.Exception
        }
        "Retry" 
        {
            Try
            {
                #User has chosen to retry
                Write-ToLog -Message "User has chosen to retry the stage $stage the workflow after error" -LogDirectory $logDir -FileName $Logfile -MsgLevel Error  
                Invoke-Expression -Command $ExpCmd
            }
            catch
            {              
                #Loop around if failure again at retry
                Show-StageFailure -LogDir $LogDir -LogFile $LogFile
            }
        }
        "Ignore" 
        {
        #User has chosen to Ignore
        Write-ToLog -Message "User has chosen to ignore the error on stage $stage and proceed to the next stage" -LogDirectory $logDir -FileName $Logfile -MsgLevel Warning   
        }
       
        default
        {
            #unexpected result from message box
            Write-ToLog -Message "An unexpected result has come back from message box. Aborting" -LogDirectory $logDir -FileName $Logfile -MsgLevel fatal   
            Throw $_.Exception
        }
    }
}

Function Reboot-Device{
param(
    [switch]$SkipRebootWarning,
    [int]$StageNumber
)
# Get the current Stage number
#Create a schedule task to restart after reboot 
#restart device
}
Function Restore-Workflow{
#function to be called by the schedule task defined in reboot

}