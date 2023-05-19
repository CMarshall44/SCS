$User = "LocalAdmin"
Function Assert-LocalUserExists
{
    param(
       [string]$UserName 
    )
    try
    {
        $account = Get-LocalUser | Where-Object {$_.Name -eq $UserName }
        if ($account -eq $null)
        {
        Write-Host "Could not find user"
            return $false
        }
        Write-Host "Found User"
    }
    catch
    {
        throw $_.Exception
    }
}