Function Get-TSVariableValue
{
    param(
    [string]$VariableName
    )
       $TSEnv
       [string]$result
    try
    {
        $TSenv = New-Object -COMObject Microsoft.SMS.TSEnvironment

        $result = $tsenv.Value($VariableName)
        Write-Host "Variable '$VariableName' = '$result[0]'"
        return $result[0]
    }
    catch [Exception]
    {
        Write-Host "Failed to get Task sequence variable"
        Write-Host $_.Exception
        throw [Exception]::new("Failed to get TS Variable",$_.Exception)
    }
    Finally
    {
        #remove the comobject
        $TSEnv = $null
    }
}