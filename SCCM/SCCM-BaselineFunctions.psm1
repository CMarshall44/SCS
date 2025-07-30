$scriptLocation = "C:\Users\Administrator\Desktop\"
Import-Module("{0}Write-Log.ps1" -F $scriptLocation) -Verbose

Enum SCCMClientAction
{
    #The number assigned to the client action is linked to the number assigned to the end of the GUID of the actions trigger
    HardwareInventory = 1;
    SoftwareInventory = 2;
    DiscoveryInventory= 3;
    FileCollection = 10;
    IDMIFCollection = 11;
    ClientMachineAuthentication = 12;
    RequestMachineAssignments = 21;
    EvaluateMachinePolicies = 22;
    RefreshDefaultMPTask = 23;
    LocationServiceRefreshLocationsTask = 24;
    LocationServiceTimeoutRefreshTask = 25;
    UserPolicyAgentRequestAssignment = 26;
    UserPolicyAgentEvaluateAssignment = 27;
    SoftwareMeteringGeneratingUsageReport = 31;
    SourceUpdateMessage = 32;
    ClearProxySettingscache = 37;
    MachinePolicyAgentCleanup = 40;
    UserPolicyAgentCleanup = 41;
    PolicyAgentValidateMachinePolicy = 42;
    PolicyAgentValidateUserPolicy = 43;
    RefreshCertificatesInADonMP = 51;
    PeerDPStatusReporting = 61;
    PeerDPPendingPackageCheckSchedule = 62;
    SUMUpdatesInstallSchedule = 63;
    NAPaction = 71;
    HardwareInventoryCollectionCycle = 101;
    SoftwareInventoryCollectionCycle = 102;
    DiscoveryDataCollectionCycle = 103;
    FileCollectionCycle = 104;
    IDMIFCollectionCycle = 105;
    SoftwareMeteringUsageReportCycle = 106;
    WindowsInstallerSourceListUpdateCycle = 107;
    SoftwareUpdatesAssignmentsEvaluationCycle = 108;
    BranchDistributionPointMaintenanceTask = 109;
    DCMPolicy = 110;
    SendUnsentStateMessage = 111;
    StateSystempolicycachecleanout = 112;
    ScanbyUpdateSource = 113;
    UpdateStorePolicy = 114;
    StateSystemPolicyBulkSendHigh = 115;
    StatesystemPolicyBulkSendLow = 116;
    AMTStatusCheckPolicy = 120
    ApplicationManagerPolicyAction = 121;
    ApplicationManagerUserPolicyAction = 122;
    ApplicationManagerGlobalEvaluationAction = 123;
    PowerManagementStartSummarizer = 131;
    EndpointDeploymentReevaluate = 221;
    EndpointAMPolicyReevaluate = 222;
    ExternalEventDetection = 223;
}
Enum SCCMComplianceStatus
{
    NonCompliant = 0;
    Compliant = 1;
    Submitted = 2;
    Detecting = 3;   
    NotEvaluated = 5;
}
Enum SCCMComplianceEvaluationStatus
{
    Evaluting = 0;
    Evaluated = 1;
    NotEvaluated = 5;
}
Function Convert-SCCMClientAction
{
    # Converts the ENUM into the GUID to run the trigger

Param(
    
    [Parameter(Mandatory=$True)]
      [SCCMClientAction]$Trigger
    )
    begin 
    {
        [string]$GuidTemplate = "00000000-0000-0000-0000-000000000000"
    }
    process
    {
        Try
        {
            Write-Debug "Generating GUID for SCCM Client Action $Trigger"       
            [int]$IDNumber = [SCCMClientAction]::$Trigger.value__
             Write-Debug ("Generating GUID for SCCM Client Actions {0}" -f $IDNumber)
            #Determining the length of the int of $Trigger so as to determine how many zeros to remove from GUID template
            [int]$IDNumberLength = ($IDNumber).tostring().length;
            Write-Debug ("ID number length = {0} " -f $IDNumberLength ) 
            #Replacing the last n character (as defined by the length of the int assign to the trigger 2=1, 10=2 100=3 ...etc) of GUID template to generate a 'GUID Number'
            [string]$result = $GuidTemplate -replace "\d{$IDNumberLength}$", ($IDNumber).tostring() 
            Write-Debug ("GUID = {0}" -f $result)
            # Encapsulating the 'GUID Number' with '{' and '}' respectively to generate the GUID.
            $result = "{" +$result+ "}"
            Write-Debug ("Result = {0}" -f $result)
            return $result
        }
        catch
        {
            throw $_.Exception.Message
        }
        finally
        {
        }
        }
    end
    {
    }
}
Function Invoke-SCCMClientAction
{
    # Converts the ENUM into the GUID to run the trigger

Param(
    
    [Parameter(Mandatory=$True)]
      [SCCMClientAction]$Trigger,
      [Parameter(Mandatory=$False)]
      [string]$ComputerName="LocalHost",
      [Parameter(Mandatory=$False)]
      [int]$Sleep = 0
    )
    begin 
    {
    }
    process
    {
        Try
        {
            Write-Log -Message "Invoking SCCM Action $Trigger"
            [string]$TriggerScheduleName = Convert-SCCMClientAction -Trigger $Trigger
            Write-Debug "Trigger Schedule ID =  $TriggerScheduleName"
            $result = Invoke-WMIMethod -ComputerName $ComputerName -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule $TriggerScheduleName -ErrorAction Stop
            Write-Log -Message $result -Level Info
            Write-Log -Message "Waiting $Sleep seconds" #Should be a Counter/Progress
            Start-Sleep -Seconds $Sleep -Description "Waiting after invoking action $Trigger"

        }
        catch [System.Management.ManagementException]
        {
            Write-Host "Cannot Connect to SCCM Client Management" -ForegroundColor Red
            Write-Log -Message  "Cannot Connect to SCCM Client Management" -Level Warn
            Write-Log -Message $_.Exception -Level Error
            throw $_.Exception
        }
         catch
        {
            Write-Host "Unexpected Error Invoking SCCM Client Action" -ForegroundColor Red
            Write-Log -Message "Unnexpected Error Invoking SCCM Client Action" -Level Warn
            Write-Log -Message $_.Exception -Level Error
            throw $_.Exception
        }
        finally
        {
        }
        }
    end
    {
    }
}
Function Get-SCCMDCMBaseline
{
    Param(
      [Parameter(Mandatory=$False)]
      [string]$ComputerName="LocalHost",
      [Parameter(Mandatory=$False)]
      [string]$Name = ''
    )
    begin 
    {
    }
    process
    {
        Try
        {
            Write-Log -Message "Getting Baselines applied to client" -Level Info
            If ($Name -eq '')
            {
                $Baselines = Get-WmiObject -ComputerName $ComputerName -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration -ErrorAction Stop
            }
            else
            {
                $Baselines = Get-WmiObject -ComputerName $ComputerName -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration -Filter ("Name='{0}'" -F $Name) -ErrorAction Stop 
            }
            If ($Baselines -eq $null)
            {
                Write-Log -Message "Failed to detect any baslines assigned" -Level Warn
            }
            else
            {
                Write-Log -Message $Baselines -Level Info
            }

            return $Baselines
        }
        catch [System.Management.ManagementException]
        {
            Write-Host "Cannot Connect to SCCM Client Management" -ForegroundColor Red
            Write-Log -Message "Cannot Connect to SCCM Client Management" -Level Warn
            Write-Log -Message  $_.Exception -Level Error
            throw $_.Exception
        }
         catch
        {
            Write-Host "Unexpected Error Getting SCCM Baseline" -ForegroundColor Red
            Write-Log -Message "Unexpected Error Getting SCCM Baseline" -Level Warn
            Write-Log -Message $_.Exception -Level Error
            throw $_.Exception
        }
        finally
        {
        }
        }
    end
    {
    }
}
Function Invoke-SCCMDCMBaselineEvaluation
{
    Param(   
      [Parameter(Mandatory=$False)]
      [string]$ComputerName="LocalHost",
      [Parameter(Mandatory=$False)]
      [string]$Name
    )
    begin 
    {
    }
    process
    {
        Try
        {
                Write-Log -Message "Triggering Evaluation of Baselines" -Level Info
            	$Baselines = Get-SCCMDCMBaseline 

	            # For each (%) baseline object, call SMS_DesiredConfiguration.TriggerEvaluation, passing in the Name and Version as params
	            $Baselines | %{ 
                    Write-Log -Message  ("Triggering Evaluation of {0} Previously Evaluated at {1} With Compliace State {2} and Evaluation Status {3}" -F $_.DisplayName,$_.LastEvalTime, $_.LastComplianceStatus, $_.Status  ) -Level Info
                    ([wmiclass]"\root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation($_.Name, $_.Version) 
                }
        }
        catch [System.Management.ManagementException]
        {
            Write-Host "Cannot Connect to SCCM Client Management" -ForegroundColor Red
            Write-Log -Message "Cannot Connect to SCCM Client Management" -Level Warn
            Write-Log -Message  $_.Exception -Level Error
            throw $_.Exception
        }
         catch
        {
            Write-Host "Unexpected Error Evaluating Baseline" -ForegroundColor Red
            Write-Log -Message "Unexpected Error Evaluating Baseline" -Level Warn
            Write-Log -Message $_.Exception -Level Error
            throw $_.Exception
        }
        finally
        {
        }
        }
    end
    {
    }
}
Function Check-Compliance
{
    Try
    {
    Do {Write-Log -Message "Checking if ccmexec Service is running" -Level Info
	        $proc=Check-Service -service ccmexec -status "Running" -maxWait 5
            if ($proc)
            {
                Write-Log -Message "CCMExec service is running"  -Level Info
                Write-Host "CCMEXec is Running"
                }
            else
            {
                Write-Log "CCMExec service is not running retrying" -Level Warn
                Write-Host "CCMEXec is not running Running retrying"
        }
    } while ($proc -eq $False)
    [int]$SCCMActionWait = 30
    Write-Host "Requesting Machine Policies and then sleeping for $SCCMActionWait seconds"
    Invoke-SCCMClientAction -Trigger RequestMachineAssignments -Sleep $SCCMActionWait
    Write-Host "Requesting Source Update Messages and then sleeping for $SCCMActionWait seconds"
    Invoke-SCCMClientAction -Trigger SourceUpdateMessage -Sleep $SCCMActionWait
    Write-Host "Requesting Hardware Inventory and then sleeping for $SCCMActionWait seconds"
    Invoke-SCCMClientAction -Trigger HardwareInventory -Sleep $SCCMActionWait
    Write-Host "Getting Current Compliance status"
    $CurrentBaseline = Get-SCCMDCMBaseline
    If ($CurrentBaseline -eq $null)
    {
        [int]$NoBaselinePause = 300
        Write-Log -Message "No baseline detected waiting $NoBaselinePause seconds and then restarting" -Level Info
        Start-Sleep -Seconds $NoBaselinePause -Description "No Baseline detecting Waiting for Baseline"
        return $false
    }
    Write-Log -Message ("Current Compliance status is {0}" -F $CurrentBaseline.LastComplianceStatus) 
    if ($CurrentBaseline.LastComplianceStatus -eq 1) #1 = compliant
    {
        Write-Host "Device is Compliant"
        Write-Log  -Message "Device is Compliant" -Level Info
        return $true;
    }
    Do
    {
        Write-Host "Device is not Compliant Invoking Baseline policy" -ForegroundColor Yellow
        Write-Log -Message "Device is not Compliant Invoking Baseline policy" -Level Warn
        [int]$MaxLoops = 10
        [int]$CurrentLoop = 0 
        $PreviousBaseline = $CurrentBaseline
        Invoke-SCCMDCMBaselineEvaluation
        Do
        {
            Start-Sleep -Seconds 5 -Description "Waiting before evaluating Compliance status"# Waiting n seconds before checking / rechecking the resuled 
            Write-Host "Checking the results of re-evaluation"
            Write-Log -Message "Getting Latest Baseline status"
            $CurrentBaseline = Get-SCCMDCMBaseline # Checking the results of the baseline evaluation
            $CurrentLoop++ # increase loop count by one Counter used to prevent infinte loop
            Write-Log -Message "Current Baseline check Loop = $CurrentLoop"
            If ($CurrentLoop -ge $MaxLoops)
            {
                #break do to stop infinite loop
                Write-Host "Baseline has failed to update in a timely manner re-evaluating" -ForegroundColor Yellow
                Write-Log -Message "Device has spent to too long updating will invoke a new Baseline evaluation" -Level Warn
                Break;
            }
        } While($CurrentBaseline.LastEvalTime -eq $PreviousBaseline.LastEvalTime)
        If ($CurrentBaseline.LastComplianceStatus -ne 1)
        {
            [int]$InvokeBaselinePause = 200
            Write-Host "Waiting for $InvokeBaselinePause before re-invoking Baseline evaluation"
                    Start-Sleep -Seconds $InvokeBaselinePause -Description "Baseline non-Compliant Re-Evaluating in"
        }
    }  While($CurrentBaseline.LastComplianceStatus -ne 1)
        return $true;
    }
    catch
    {
        return $False # maybe throw but no handling in Start-Final 
    }
}

Function Start-Sleep
{
    Param(   
      [Parameter(Mandatory=$True)]
      [int]$Seconds,
      [Parameter(Mandatory=$False)]
      [string]$Description = "Sleeping ...."
    )
    Try
    {
    $doneDT = (Get-Date).AddSeconds($seconds)
    while($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity "Sleeping" -Status $Description -SecondsRemaining $secondsLeft -PercentComplete $percent

        [System.Threading.Thread]::Sleep(500)
        }
     Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining 0 -Completed
    }
    catch
    {
        If ($Sleep -gt 1)
        {
        sleep $Sleep 
        }
    }
}