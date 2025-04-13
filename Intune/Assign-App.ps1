#Install-Module Microsoft.Graph 
Import-Module Microsoft.Graph 
try{
    Connect-MgGraph -Scopes "Directory.ReadWrite.All","DeviceManagementApps.ReadWrite.All","Group.ReadWrite.All"
    $appID = "aaaa-aaa-aaa-1234145"
    $group = get-MgGroup -Name "Test"
    $TargetAssignment = @{
        "@odata.type" = "#microsoft.group.groupAssignmentTarget"
        groupId = $group.id
    }
    $App = Get-MgDeviceAppManagementMobileAppp -MobileAppID $appID
    if ($app.AdditionalProperties.'@odata.type' = "#microsoft.graph.win32LobApp"){
        if ($app.AdditionalProperties.installExperience.deviceBehaviour -eq "basedOnReturnCode"){
            $RestartSettings  =@{
                "@odata.type" = "#microsoft.graph.win32LobAppRestartSettings"
                gracePeriodInMinutes = 240
                countdownDisplayBeforeRestartInMiinutes = 15
                restartNotificationSnoozeDurationInMinutes = 60

            }

        }
        else{
            $RestartSettings = $null
        }
    $settings = @{
        "@odata.type" = "#microsoft.graph.win32LobAppAssignmentSettings"
        notifications = "showReboot"
        restartSettings = $RestartSettings
        installTimeSettings = $null
        deliveryOptimizationPriority = "notConfigured"
        }
    new-MgDeviceAppManagementMobileAppAssignment -MobileAppID = $appID -intent 'required' -Target $group -Settings $settings
    }

}
catch{
}
finally{
    Disconnect-MgGrraph
}

function Create-AADGroup{
param(
    [string]$DisplayName,
    [string]$Description

)
    New-MgGroup -DisplayName $DisplayName -Description $Description -MailEnabled:$false -SecurityEnabled:$true -MailNickName "MailNickNameisRequiredButNoSpaces"
}