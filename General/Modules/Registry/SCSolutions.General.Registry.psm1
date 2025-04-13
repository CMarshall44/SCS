
Function Set-RegistryProperty{
    <#
    .SYNOPSIS
        This function Creates or updates the registry Propery value as well as creating the Key path if required 

    .DESCRIPTION
        Set-RegistryProperty is a function that sets a registry property to a particular value. This function will create a new property including all required keys in the key path or update the existing property if the property already exists.

    .PARAMETER keyPath
        REQUIRED: The keyPath parameter is a string of a path to the location the property resides in and should be in the format [hive]:\[Key]\[Subkey]

    .PARAMETER propertyType
        REQUIRED: The propertyType parameter defines the type of property to be create, valid values are 'String','ExpandedString','Binary','DWord','MultiString','QWord' which are equivalent to 'REG_SZ','REG_EXPAND_SZ','REG_BINARY','REG_DWORD','REG_MULTI_SZ', 'REG_QWORD'

    .PARAMETER propertyName
        REQUIRED: The propertyName parameter defines the name of the registry property to be created or updated.

    .PARAMETER propertyValue
        REQUIRED: The propertyValue parameter defines the value of the registry property to be created or updated. The value must be a valid value for the propertyType defined

    .EXAMPLE
        Set-RegistryProperty -keyPath "HKCU:\ExampleKey\ExampleSubKey" -propertyType DWord -propertyName "Example Property" -propertyValue 27

    .OUTPUTS
        Null

    .NOTES
        Author:  Chris Marshall
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("(HKCU|HKLM|hkcu|hklm):\\\S*")]
        [string]$keyPath,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('String','ExpandedString','Binary','DWord','MultiString','QWord')]
        [Microsoft.Win32.RegistryValueKind]$propertyType = [Microsoft.Win32.RegistryValueKind]::Dword ,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$propertyName,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [object]$propertyValue
    )
    try
    {
    if ( Test-Path $keyPath)
    {
        Write-Debug -Message ("Registry Path '{0}' Exists" -f $keyPath)
    
    }
    else
    { 
        Write-Debug ("RegistryPath '{0}' does not exist - Creating Path" -f $keyPath)
        New-Item -Path $keyPath -Force

    }
    $key =  Get-Item -LiteralPath $keyPath
    if ($Key.GetValue($propertyName, $null) -ne $null) 
    {
        Write-Debug ('Updating Property {0} to value {1} in path {2} ' -F $propertyName, $propertyValue, $keyPath )
        Set-ItemProperty -Path $keyPath -Name $propertyName -Value $propertyValue |Out-Null
    } 
    else 
    {
        Write-Information ('Creating Property {0} to value {1} in path {2} ' -F $propertyName, $propertyValue, $keyPath )
        New-ItemProperty $keyPath -Name $propertyName -Value $propertyValue -PropertyType $propertyType |Out-Null
     }
    }
    catch
    {
        Write-Error "Failed to set registry"
        Write-Error $_Exception.Message
    }
    Finally
    {
        if ($key -ne $null){
            Write-Verbose ('Closing key Handle')
            $key.Handle.Close()
        }
    }
}
Function Open-RegistryHive{
    <#
    .SYNOPSIS
        This function Loads a registry hive from a file 

    .DESCRIPTION
        Open-RegistryHive is a funtion that loads a registry hive from a file.

    .PARAMETER hivePath
        REQUIRED: path of the hive, HKLM\SYSTEM: %windir%\system32\config\SYSTEM; HKLM\SAM: %windir%\system32\config\SAM; HKLM\SECURITY: %windir%\system32\config\SECURITY;HKLM\SOFTWARE: %windir%\system32\config\SOFTWARE;HKU\.DEFAULT: %windir%\system32\config\DEFAULT; HKCU  c:\\users\default\ntuser.dat

    .PARAMETER registryPath
        REQUIRED: The propertyType parameteris the registry path/key that the loaded hive will be place in must be in the format HKLM:\Key{\SubKey}

    .EXAMPLE
        Open-RegistryHive -hivePath c:\users\default\ntuser.dat -registryPath HKLM:\LoadedRegistry
    .OUTPUTS
        Null

    .NOTES
        Author:  Chris Marshall
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$hivePath,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("(HKLM|hklm):\\\S*")]
        [string]$registryPath
        )

    Try{
        REG LOAD ($registryPath -replace ':', '' ) ("{0}" -f $hivePath)
    }
    catch
    {
        throw $_.Exception
    }
}
Function Close-RegistryHive{
    <#
    .SYNOPSIS
        This function unLoads a registry hive from a file 

    .DESCRIPTION
        Close-RegistryHive is a funtion that unloads a registry hive that has been loaded  from a file.

    .PARAMETER registryPath
        REQUIRED: The propertyType parameteris the registry path/key that the loaded hive will be place in must be in the format HKLM:\Key{\SubKey}

    .EXAMPLE
        Close-RegistryHive -registryPath HKLM:\LoadedRegistry
    .OUTPUTS
        Null

    .NOTES
        Author:  Chris Marshall
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$hivePath,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("(HKLM|hklm):\\\S*")]
        [string]$registryPath
        )
    try{
    Set-Location $env:windir
    $unloaded = $false
    $attempts = 0
    while (!$unloaded -and ($attempts -le 5)) {
      [gc]::Collect() # necessary call to be able to unload registry hive
      & REG UNLOAD ($registryPath -replace ':', '' )
      $unloaded = $?
      $attempts += 1
    }
        if (!$unloaded) {
          Write-Warning "Unable to dismount default user registry hive at HKLM\DEFAULT - manual dismount required"
          exit 1001
        }
    }
    catch
    {
        throw $_.Exception
    }
}

#Set-RegistryProperty -keyPath HKCU:\\TEST -propertyType String -propertyName TEST -propertyValue TEST