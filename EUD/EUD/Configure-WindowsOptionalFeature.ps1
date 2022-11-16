Param(
    [Parameter(Mandatory=$false)]
    [Switch]$Install,
    [Parameter(Mandatory=$false)]
    [Switch]$Uninstall,
    [Parameter(Mandatory)]
    [String]$FeatureName,
    [Parameter(Mandatory=$false)]
    [Switch]$InstallPreReqFeatures
)

Function get-WindowsOptionalFeatureInstallState{
    [CmdLetBinding(SupportsShouldProcess=$True)]
    param(
        [string]$FeatureName
    )
    try{
        Write-Host "Finding the current state of Windows Optional Feature $FeatureName"
        $featureState = (Get-WindowsOptionalFeature -Online -FeatureName $FeatureName).state
        if ($featureState.Count -lt 1){
            throw (New-Object -TypeName System.IO.InvalidDataException -ArgumentList "Feature named in parameter cannot be found ")
        }
        #currently not handing state
        if ($featureState.Count -gt 1){
            throw (New-Object -TypeName System.IO.InvalidDataException -ArgumentList "Feature name parameter is returning more than one Feature unable to process.")
        }
        return $featureState

    }
    
    catch [System.IO.InvalidDataException]{
        Write-Error "Invalid parameters in function"
        Write-Error $_
    }
    catch{
        Write-Host "Unexpected Error"
        Write-Host $_
    }
    Finally{
        Write-Host "Cleaning up function"
    }
}

Function Add-WindowsOptionalFeature{
    [CmdLetBinding(SupportsShouldProcess=$True)]
    param(
        [string]$FeatureName,
        [string] $CabFilePath,
        [switch] $all 
    )
    Write-Host "Begining INstall"
        [Microsoft.DISM.Commands.FeatureState]$currentState = get-WindowsOptionalFeatureInstallState -FeatureName $FeatureName

        switch($currentState)
        {
            Disabled{
                if ($all.IsPresent){
                    Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -LimitAccess -NoRestart  -All
                }
                else{
                    Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -LimitAccess -NoRestart
                }
                
            }
            DisabledWithPayloadRemoved{
            if ($CabFilePath -eq ""){
                if ($all.IsPresent){
                    Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart  -All
                }
                else{
                    Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart
                }
                 }
            else{
               if ($all.IsPresent){
                    Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -LimitAccess -NoRestart -Source $CabFilePath -All
                }
                else{
                    Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -LimitAccess -NoRestart -Source $CabFilePath #use local content
                }
                 }
            }
           
        }
        [Microsoft.DISM.Commands.FeatureState]$newState = get-WindowsOptionalFeatureInstallState -FeatureName $FeatureName
        switch($newState)
        {
            Disabled
            {
                throw (New-Object -TypeName System.Exception -ArgumentList "Failed to Enable Feature.")
            }
            DisabledWithPayloadRemoved{
                throw (New-Object -TypeName System.Exception -ArgumentList "Failed to Enable Feature (Payload Removed).")
            }
            DisablePending{
                throw (New-Object -TypeName System.Exception -ArgumentList "Cannot Enable Feature as feature is currently pending being disabled.")
            }
            Enabled{
                return 0 # already enabled so thats a succcess
            }
            EnablePending
            {
                return 3010 #awaiting reboot
            }
            PartiallyInstalled
            {
                #maybe a reboot will complete
                return 3010
            }
            Superseded
            {
                throw (New-Object -TypeName System.Exception -ArgumentList "Cannot Enable Feature as feature is superceeded.")                
            }
        }
}
Function Remove-WindowsOptionalFeature{
     [CmdLetBinding(SupportsShouldProcess=$True)]
    param(
        [string]$FeatureName
    )
        [Microsoft.DISM.Commands.FeatureState]$currentState = get-WindowsOptionalFeatureInstallState -FeatureName $FeatureName
        $CurrentState
        switch($currentState)
        {
            Enabled
            {
                Disable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart 
            }
            Superseded
            {
                Disable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart 
            }
           
        }
        [Microsoft.DISM.Commands.FeatureState]$newState = get-WindowsOptionalFeatureInstallState -FeatureName $FeatureName
        switch($newState)
        {
            Disabled
            {
                return 0
            }
            DisabledWithPayloadRemoved{
                return 0
            }
            DisablePending{
                return 3010
            }
            Enabled{
               throw (New-Object -TypeName System.Exception -ArgumentList "Failed to disable.")      
            }
            EnablePending
            {
               throw (New-Object -TypeName System.Exception -ArgumentList "Failed to disable  as Enable pending.")   
            }
            PartiallyInstalled
            {
                #maybe a reboot will complete
                return 3010
            }
            Superseded
            {
                return 0 # maybe superseded is a removal            
            }
        }
}

$returnCode = -1
try
{
    if ($Install.IsPresent){
        if ($InstallPreReqFeatures.IsPresent){
        Write-Host "Install with all switch"
        $returnCode = Add-WindowsOptionalFeature -FeatureName $FeatureName -all
        }
        else{
        Write-Host "Install without all switch"
        $returnCode = Add-WindowsOptionalFeature -FeatureName $FeatureName
        }
    }
    if ($Uninstall.IsPresent){
        $returnCode = Remove-WindowsOptionalFeature -FeatureName $FeatureName
    }
    $returnCode 
}
catch{
        Write-Error $_
        $returnCode -1
}

Exit $returnCode