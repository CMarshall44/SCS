Function Load-TSEnvironment
{
    try
    {
        $Result = New-Object -COMObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
        }
        catch [System.Runtime.InteropServices.COMException]
        {
            Write-Host "Failed to Connect to Microsoft.SMS.TSEnvironment" -ForegroundColor Yellow
            Write-Host $_.Exception
            $Result = $null # not failing as this is not a valid failure when running outside TS
        }
        catch [Exception]
        {
            Write-Host "Unexpected Exception loading TSEnvironment" -ForegroundColor Red
            Write-Host $_.Exception
            throw [Exception]::new("Unexpected Error Getting Loading TSEnvironment",$_.Exception)
        } 
    
}