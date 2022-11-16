try
{
$regDefaultPath = "HKLM\DEFAULT"
REG LOAD $regDefaultPath ("{0}\users\default\ntuser.dat" -f $env:SystemDrive)
Set-Location HKLM:
$keyPath = ".\DEFAULT\Software\Microsoft\Windows\CurrentVersion\Search" 
$property = "SearchboxTaskbarMode2"
$value = 0
  if ( Test-Path $keyPath)
    {
        Write-Host "Path Exists"
    
    }
    else
    { 
        Write-Host "Path doesn't exist"
        New-Item -Path $keyPath -Force

    }
    $key =  Get-Item -LiteralPath $keyPath
    if ($Key.GetValue($property, $null) -ne $null) 
    {
        Set-ItemProperty -Path $keyPath -Name $property -Value $value 
    } 
    else 
    {
        Write-Output 'Value DOES NOT exist'
        New-ItemProperty $keyPath -Name $property -Value $value -PropertyType "DWord"
     }
     $key.Handle.Close()

    
}
catch
{
throw $_.Exception
}
finally
{
Set-Location $env:windir
$unloaded = $false
$attempts = 0
while (!$unloaded -and ($attempts -le 5)) {
  [gc]::Collect() # necessary call to be able to unload registry hive
  & REG UNLOAD $regDefaultPath
  $unloaded = $?
  $attempts += 1
}
if (!$unloaded) {
  Write-Warning "Unable to dismount default user registry hive at HKLM\DEFAULT - manual dismount required"
  exit 1001
}
}