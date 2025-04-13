Try{
$a = Get-AppxPackage -Name "Microsoft.CompanyPortal"
if ($a -ne $null){
    Write-Output "Microsoft Company Portal Detected"
    Exit 0
}
    Exit 1
}
catch {
    Exit 2
}
