﻿$dest = "$($env:ProgramData)\Microsoft\RenameComputer"
$ScheduledTaskName = "RenameComputer"
$DevicePrefix = "PC-"
Function Assert-IsDomainMember{
$details = Get-ComputerInfo
if ($details.CsPartOfDomain) 
{
    Write-Host "Computer is a domain memeber."
    return $true
}
    Write-Host "Not part of a domain."
    return $false
}
Function Assert-HasDomainAccess{
#Think this would be better checked using NLA
$dcInfo = [ADSI]"LDAP://RootDSE"
if ($dcInfo.dnsHostName -ne $null)
{
    Write-Host "Computer is currently connected to the domain."
    return $true
}
    Write-Host "Computer is not currently connected to the domain."
    return $false
}
Function Create-ScheduledTask{
    Param(
        [string]$ScheduledTaskName
    )
    # Check to see if already scheduled
    $existingTask = Get-ScheduledTask -TaskName "RenameComputer" -ErrorAction SilentlyContinue
    if ($existingTask -ne $null)    {
        Write-Host "Scheduled task already exists."
        return
    }

    # Copy myself to a safe place if not already there
    if (-not (Test-Path "$dest\RenameComputer.ps1"))
    {
        Copy-Item $PSCommandPath "$dest\RenameComputer.PS1"
    }

    # Create the scheduled task action
    $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-NoProfile -ExecutionPolicy bypass -WindowStyle Hidden -File $dest\RenameComputer.ps1"

    # Create the scheduled task trigger
    $timespan = New-Timespan -minutes 5
    $triggers = @()
    $triggers += New-ScheduledTaskTrigger -Daily -At 9am
    $triggers += New-ScheduledTaskTrigger -AtLogOn -RandomDelay $timespan
    $triggers += New-ScheduledTaskTrigger -AtStartup -RandomDelay $timespan
    
    # Register the scheduled task
    Register-ScheduledTask -User SYSTEM -Action $action -Trigger $triggers -TaskName $ScheduledTaskName -Description "Rename Computer" -Force
    Write-Host "Scheduled task created."
}
Function Get-ComputerName{
    param(
        [string]$prefix = ""
    )
        #Generate the Computer Name
    $availableLength = (12 - $prefix.Length)     # max length of net bios computer name is 

    [string]$at = Get-AssetNumber
    if ($at -ne ""){
        [string]$computerName =  -join ($prefix , $at.substring(0,$availableLength).ToString()) 
    }
    else{
        [string]$sn  = Get-SerialNumber
        [string]$computerName =  -join ($prefix , $sn.substring(0,$availableLength).ToString()) 
    }
    $computerName = Add-Suffix -newName $computerName #Add a suffix if the machine name already exists
    Write-Host "Computer name will be $computerName"
    return $computerName

}
Function Get-SerialNumber{
    [string]$serialNumber = Get-WmiObject Win32_ComputerSystemProduct | Select -Expand IdentifyingNumber
    $serialNumber.Replace('-','')
    Write-Host "Serial Number - " + $serialNumber.ToString() 
    return $serialNumber.ToString()
    # 
}
Function Get-AssetNumber{
    [string]$assetNumber = Get-WmiObject Win32_SystemEnclosure| Select -Expand SMBIOSAssetTag
    Write-Host "Asset Tag - " + $assetNumber.ToString() 
    return $assetNumber.ToString()
    # 
}
Function Rename-PC{
     param(
        [string]$NewName
     )
        $result = Rename-Computer -NewName $newName -PassThru #result is in the fomr Microsoft.PowerShell.Commands.RenameComputerChangeInfo
        Write-Host "Result: "$result
        return $result
}
Function Remove-ScheduledTasks{
    Param(
        [string]$ScheduledTaskName
    )
    Write-Host "Disabling the Scheduled Task"
    Disable-ScheduledTask -TaskName $ScheduledTaskName -ErrorAction Ignore
    Write-Host "Unregistering the scheduled task"
    Unregister-ScheduledTask -TaskName $ScheduledTaskName -Confirm:$false -ErrorAction Ignore
    Write-Host "Scheduled task unregistered."
}
Function Add-Suffix{
    param(
        [string]$newName
    )
    $newName = $newName.Trim()
    $adsiResult = ([ADSISearcher]"Name=$newName").FindAll()
    If($adsiResult -ne $null){
        Write-Host "newname exists:"$adsiResult.path
        $suffix = 2
        Do{
            $newerName = "$newName-$suffix"
            $suffix++
            Remove-Variable -Name "adsiResult"
            Write-Host "Checking LDAP for "$newerName
            $adsiResult = ([ADSISearcher]"Name=$newerName").FindAll()
            if($adsiResult -ne $null){
                Write-Host "Found "$adsiResult.path
            }else{
                Write-Host "Cound not find $newerName"
                $end = 1
            }
        }Until($end)
        Write-Host "Setting new name to "$newerName
        $newName = $newerName
    }else{
        Write-Host "Newname $newName does not already exist"
    }
    return $newName
}

if (-not (Test-Path $dest))
{
    mkdir $dest
}
Start-Transcript "$dest\RenameComputer.log" -Append
Write-Host "Checking Prerequisites"

if (-not(Assert-IsDomainMember) -or -not (Assert-HasDomainAccess) ){
    Write-Host "Failed Prereq checks. Setting up a schedule task to complete once the prereqs exist"
    Create-ScheduledTask -ScheduledTaskName $ScheduledTaskName
}
Else{
    Write-Host "Passed Pre Requisites"
    $newPCName = Get-ComputerName -prefix $DevicePrefix #Generate Computer Name
    Write-Host "New PC name will be $newPCName"
    $result = Rename-PC -NewName $newPCName
    if ($result.HasSucceeded){
        Remove-ScheduledTasks -ScheduledTaskName $ScheduledTaskName
        $details = Get-ComputerInfo
        if ($details.CsUserName -match "defaultUser")
        {
            Write-Host "Exiting during ESP/OOBE with return code 1641"
            Stop-Transcript
            Exit 1641
        }
        else {
            Write-Host "Initiating a restart in 10 minutes"
#            & shutdown.exe /g /t 600 /f /c "Computer will restart after 10 minutes to complete name change. Save your work."
            Stop-Transcript
            Exit 3010
        }
    }
    else{
        Stop-Transcript
        Exit 1
    } 
}