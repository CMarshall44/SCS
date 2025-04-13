Function Create-LocalUser{
    param(
    [string]$Description,
    [string]$FullName,
    [string]$Name,
    [securestring]$Password,
    [bool]$PaswordNeverExpires,
    [bool]$UserCannotChangePassword
    )
    try{
        $account = Get-LocalUser | Where-Object {$_.Name -eq $Name}
        if ($account -eq $null){
            New-LocalUser -AccountNeverExpires -Description $Description -Disabled:$false -FullName $FullName -Name $Name -Password $Password -PasswordNeverExpires:$PaswordNeverExpires -UserMayNotChangePassword:$UserCannotChangePassword
        }
    }
    catch{
        throw $_.Exception
    }
}


    #Create-LocalUser -Description "Local Administrator" -FullName "Local Administator" -Name "LocalAdmin" -Password (ConvertTo-SecureString "*********" -AsPlainText -Force) -PaswordNeverExpires $true -UserCannotChangePassword $false
    #Add-UserToLocalGroup -User "LocalAdmin" -Group "Administrators"
