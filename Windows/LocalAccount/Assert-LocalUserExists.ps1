
Function Assert-LocalUserExists
{
    [CmdletBinding(
        #ConfirmImpact="",
        #DefaultParameterSetName=<String>,
        #HelpUri=<URI>,
        #SupportsPaging=<Boolean>,
        #SupportsShouldProcess=<Boolean>,
        #PositionalBinding=<Boolean>
        )]
    param(
       [string]$UserName 
    )
    Begin{}
    Process{
        try
        {
            $account = Get-LocalUser | Where-Object {$_.Name -eq $UserName }
            if ($account -ne $null)
            {
                Write-Verbose ("Found user - '{0}'" -f $UserName)
                return $true
            }            
            Write-Verbose ("Could not find user - '{0}'" -f $UserName)
		    return $false
        }
        catch
        {
            throw $_.Exception
        }
    }
    End{}
    
}

Assert-LocalUserExists -UserName "LocalAdmin"