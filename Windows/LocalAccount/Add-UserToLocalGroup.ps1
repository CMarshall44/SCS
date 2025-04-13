Function Add-UserToLocalGroup{
    param(
    [string]$Group,
    [string]$User
    )
    try{
        $localAdminGroupWMI = Get-WmiObject -Class Win32_Group -Filter ("Name='{0}'" -f $Group)
        $admins = $localAdminGroupWMI.GetRelated("Win32_UserAccount") | Where-Object {$_.Name -eq $User}
        if ($admins -eq $null){
            Add-LocalGroupMember -Group $Group -Member $User -Confirm:$false 
        }
    }
    catch{
        throw $_.Exception
    }
}