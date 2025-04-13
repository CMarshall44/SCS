$BuiltinAdmin = get-localuser  | Where-Object {$_.Sid -like "S-1-5*-500"}
if ($BuiltinAdmin.count -ne 1)
{
    Write-Error "Could not identify built in account"
    exit 2
}

$builtinAdmin | Enable-LocalUser 