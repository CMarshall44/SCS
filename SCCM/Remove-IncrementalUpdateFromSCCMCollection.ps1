Enum RefreshType {Manual = 1; Periodic = 2;Incremental = 4;} 

Function Remove-IncrementalUpdates
{
    [CmdletBinding()]
    Param()
    {
        [string]$ServerName = "." #Default to local should be an FQDN of an SMS Provider      
        [ValidatePattern("/[[:alnum:]]{8}/g")]
        [string]$CollectionID# Requires validation that collection is not smsxxxxxx as we do not want to alter default collections 

    }
    Begin
    {
        try
        {
        #Getting site code
        [string]$SiteCode = Get-SiteCode -ServerName $ServerName;
        }
        catch
        {
            Write-Host -ForegroundColor Red -Object "Failed to retrieve Site code"
            Write-Host -ForegroundColor Red -Object $_.Exception
            throw $_.Exception;
        }
    }
    Process
    {
    try
    {
        
        $collection = Get-WmiObject -Query "Select * From sms_collection Where CollectionID='$CollectionID'" -Namespace "root\sms\site_$SiteCode" -ComputerName $ServerName | Select-Object -First #As we are using a unique ID we assume there will be only one object
        Write-Host ("Collection '{0}' ({1}) is currently set to '{3}' ({4})" -F $Collection.Name, $collection.CollectionID, [Enum]::ToObject([RefreshType], $Collection.RefreshType), $collection.RefreshType )
        switch ($collection.RefreshType)
        {
            1 
            { 
                Write-Host ("Collection does not have Incremental updates enabled. No further action" ) -ForegroundColor Yellow
                Return 
                }

            2 
            {
                Write-Host ("Collection does not have Incremental updates enabled. No further action" ) -ForegroundColor Yellow
                Return 
            }
            4 
            {
                Write-Host ("Collection has incremental updates enabled. Disabling")
                $Collection.RefreshType = 1 #Collection had incremental but no shedule so setting to manual
                break
               
            }
            6 
            {
                Write-Host ("Collection has incremental updates enabled. Disabling")
                $Collection.RefreshType = 2 #Collection had incremental and scheduled so setting to scheduled
                break
            }
            default
            {
                Write-Host "Unexpected refresh type value currentlt set. Taking no further action" -ForegroundColor Red
                throw Exception "Unexpected RefreshType"
            }

                  
        }
         Write-Host "Commiting change"
         $Collection.Put() # Commiting change
         Write-Host ("Collection '{0}' ({1}), has been updated" -F $Collection.Name, $collection.CollectionID )
         Return

    }
    catch
    {
       Write-Host "Failed to update incremental updates due to an unexpected error"
        Throw  $_.Exception
    }

    }
    end
    {
    }
}

Function Get-SiteCode
{
    [CmdletBinding()]
    Param()
    {
        [string]$ServerName = "." #Default to local    
    }
    Try
    {
        #Getting the sitecode of the 
        [string]$SiteCode = @(Get-WmiObject -Namespace root\sms -Class SMS_ProviderLocation -ComputerName $ServerName)[0].SiteCode #There should only ever be one site code so safe to take the first record from the WMI
        return $SiteCode;
    }
    catch
    {
        throw $_.Exception
    }
       
}

