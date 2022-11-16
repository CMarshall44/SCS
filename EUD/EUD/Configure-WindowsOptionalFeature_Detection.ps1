
Function get-WindowsOptionalFeatureInstallState{
    [CmdLetBinding(SupportsShouldProcess=$True)]
    param(
        [string]$FeatureName
    )
    try{
        Write-Host "Finding the current state of Windows Optional Feature $FeatureName"
        [Microsoft.DISM.Commands.FeatureState]$featureState = (Get-WindowsOptionalFeature -Online -FeatureName $FeatureName).state
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

 $installState = get-WindowsOptionalFeatureInstallState -FeatureName "Client-EmbeddedShellLauncher"
 if($installState -ne [Microsoft.DISM.Commands.FeatureState]::Enabled){
    Write-Output "Feature Not Enabled"
    Exit 1
 }