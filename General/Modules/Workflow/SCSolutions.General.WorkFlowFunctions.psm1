function Set-RegistryKey{
    param(
        $keyPath,
        $property,
        $value,
        [Microsoft.Win32.RegistryValueKind]$type  = [Microsoft.Win32.RegistryValueKind]::Dword 
    )
    try
    {
        if ( Test-Path $keyPath)
        {
            Write-ToLog -Message ("Path '{0}' Exists" -f $keyPath)  -LogDirectory $LogDir -FileName $LogFile -MsgLevel Debug    
        }
        else
        { 
            Write-ToLog -Message ("Path '{0}' does not exist - Creating Path" -f $keyPath)  -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info  
            New-Item -Path $keyPath -Force | Out-Null

        }
        try
        {
            Write-ToLog -Message  ('Creating Property {0} to value {1} in path {2} ' -f $property, $value, $keyPath ) -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
            New-ItemProperty $keyPath -Name $property -Value $value -PropertyType $type  -ErrorAction Stop  | Out-Null
        }
        catch [System.IO.IOException]
        {
            Write-ToLog -Message ('Setting Property {0} to value {1} in path {2} ' -F $property, $value, $keyPath ) -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
            Write-ToLog -Message  ("Previous value = '{0}'" -F ((Get-ItemPropertyValue -Path $keyPath -Name $property) -join ',')) -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
            Set-ItemProperty -Path $keyPath -Name $property -Value $value  | Out-Null
        }
    }
    catch
    {
        throw $_.Exception
    }
}
function New-RandomPassword{
param(
        [Parameter()]
        [ValidateScript({$_ -gt 0})]
        [Alias('Min')] 
        [int]$MinPasswordLength = 12,
        [Parameter()]
        [ValidateScript({$_ -ge $MinPasswordLength})]
        [Alias('Max')] 
        [int]$MaxPasswordLength = 18,
        [Parameter()]
        [ValidateScript({
        $CharTypeCount =4         
        ($_ * $CharTypeCount) -le $MinPasswordLength})] # 4 Distinct char types (UCase,LCase,Number and Special)
        [int]$MinCharofEachType = 2

        
)
[Char[]]$LCChars = @()
[Char[]]$UCChars = @()
[Char[]]$NumChars = @()
[Char[]]$SpecialChars = @()
[Char[]]$allChars = @()
for ([byte]$c = [char]'a'; $c -le [char]'z'; $c++)  
{  
    $LCChars += [char]$c  
}
for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
    $UCChars += [char]$c  
}
for ([byte]$c = [char]'0'; $c -le [char]'9'; $c++)  
{  
    $NumChars += [char]$c  
}
for ([byte]$c = [char]33; $c -le [char]47; $c++)  
{  
    $SpecialChars += [char]$c  
}
for ([byte]$c = [char]58; $c -le [char]64; $c++) 
{  
    $SpecialChars += [char]$c  
}
for ([byte]$c = [char]91; $c -le [char]96; $c++) 
{  
    $SpecialChars += [char]$c  
}
$allChars = $LCChars + $UCChars + $NumChars + $SpecialChars
$PasswordLength = Get-Random -Minimum $MinPasswordLength -Maximum $MaxPasswordLength
$pwd = @() 
$count = 0;
do{
    $pwd += Get-Random -InputObject $UCChars
    $count++
} while ($count -lt $MinCharofEachType)
$count = 0;
do{
    $pwd += Get-Random -InputObject $LCChars
    $count++
} while ($count -lt $MinCharofEachType)
$count = 0;
do{
    $pwd += Get-Random -InputObject $NumChars
    $count++
} while ($count -lt $MinCharofEachType)
$count = 0;
do{
    $pwd += Get-Random -InputObject $SpecialChars
    $count++
} while ($count -lt $MinCharofEachType)
do {
    $pwd += Get-Random -InputObject $allChars
    
} while ($pwd.Count -lt $PasswordLength)
$shuffled = $pwd | Sort-Object{Get-Random}
[string]$stringPwd = $null
 ForEach ($a in $shuffled){
    $stringPwd += $a.ToString()
    }
    return $stringPwd
}
function Set-PCName{
    Param(
        [string]$NewPCName
    )
    Write-ToLog -Message ("Attempting to rename Computer to {0}" -f $NewPCName) -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
    $CurrentPCName = (Get-CimInstance -ClassName Win32_ComputerSystem).Name
    if ($CurrentPCName -ne $NewPCName){
        Write-ToLog -Message ("Changing PC Name from'{0}' to {1}" -f $CurrentPCName, $NewPCName) -LogDirectory $LogDir -FileName $LogFile -MsgLevel info
        Rename-Computer -NewName $NewPCName -Restart:$false -Force |Out-Null
    }
    else{
        Write-ToLog -Message ("PC name is correct no action taken '{0}'" -f $CurrentPCName) -LogDirectory $LogDir -FileName $LogFile -MsgLevel debug
    }

}
function Set-PCTimeZone{
    Param(
        [string]$TimeZone
    )
    if ((Get-TimeZone -ListAvailable).ID -notcontains $TimeZone){
        Write-ToLog -Message ("TimeZone '{0}' provided is not valid " -f $TimeZone) -LogDirectory $LogDir -FileName $LogFile -MsgLevel Error
        Write-ToLog -Message ("Set timezone will not proceed but workflow will continue") -LogDirectory $LogDir -FileName $LogFile -MsgLevel Error
        return
    } 
    $curTimeZone = Get-TimeZone 
    if ($curTimeZone.Id -ne $TimeZone){
        Write-ToLog -Message ("Setting TimeZone to '{0}' from {1}" -f $TimeZone, $curTimeZone) -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
        Set-TimeZone -Id $TimeZone -Verbose 
        return
    }
   Write-ToLog -Message ("Timezone already set correctly No further action required") -LogDirectory $LogDir -FileName $LogFile -MsgLevel Debug
}
function Set-LocalAccounts{
    Param(
        [string]$LocalAdminAccountName
    )

    Invoke-Stage -Stage "New-LocalAccount" -StageNumber 1 -Stages 4 -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-LocalAdminAccountName '{0}'" -f $LocalAdminAccountName)
    Invoke-Stage -Stage "Add-ToLocalAdmin" -StageNumber 2 -Stages 4 -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-LocalAdminAccountName '{0}'" -f $LocalAdminAccountName)
    Invoke-Stage -Stage "Disable-DefaultAdmin" -StageNumber 3 -Stages 4 -SubStage:$true -LogDir $LogDir -LogFile $LogFile 
    Invoke-Stage -Stage "Disable-DefaultGuest" -StageNumber 4 -Stages 4 -SubStage:$true -LogDir $LogDir -LogFile $LogFile 

}
function New-LocalAccount{
    Param(
        [string]$LocalAdminAccountName
    )
    try{
    Write-ToLog -Message  "Checking if local Admin account already exists" -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
    $GLU = Get-LocalUser -Name $LocalAdminAccountName -ErrorAction Stop
    Write-ToLog -Message  ("Local Admin account '{0}' already exists" -f $LocalAdminAccountName) -LogDirectory $LogDir -FileName $LogFile -MsgLevel Debug
    }
    catch [Microsoft.PowerShell.Commands.UserNotFoundException]{
    Write-ToLog -Message  "Account does not exists requesting a password from user" -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
    $PasswordMsg = "Enter Password"
    do{
        try{
        $LocalAdminPwd = Read-Host $PasswordMsg -AsSecureString
        }
        catch{
            Write-Host $_
        } 
        $LocalAdminPwd2 = Read-Host "Confirm Password" -AsSecureString
        $usLAP1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($LocalAdminPwd))
        $usLAP2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($LocalAdminPwd2))
        if ($usLAP1 -ne $usLAP2){
            Write-ToLog -Message  "Passwords do not match" -LogDirectory $LogDir -FileName $LogFile -MsgLevel Warning
            $PasswordMsg = "Retry Passwords (Did not Match)"
        }
    }
    While (($usLAP1 -ne $usLAP2)-or ($usLAP1 -eq $null))
    $usLAP1 = $null
    $usLAP2 = $null
    Write-ToLog -Message  "Creating Account" -LogDirectory $LogDir -FileName $LogFile -MsgLevel Debug
    $NLU = New-LocalUser -Name $LocalAdminAccountName  -FullName 'Local Administrative Account' -AccountNeverExpires -Description 'Local Administrative account' -Disabled:$false -PasswordNeverExpires -Password $LocalAdminPwd
    
    } 
}
function Add-ToLocalAdmin{
    Param(
        [string]$LocalAdminAccountName
    )
    try{
        Write-ToLog -Message ("Checking if {0} is a memeber of the Local Administrative Group" -f $LocalAdminAccountName) -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
        $GroupMembership = Get-LocalGroupMember -Group 'Administrators' -Member $LocalAdminAccountName -ErrorAction Stop | Out-Null
        Write-ToLog -Message "User is already a member no further action to take" -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
    }
    catch [Microsoft.PowerShell.Commands.PrincipalNotFoundException]{
        Write-ToLog -Message "User is not a member - adding" -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
        $AddLGM = Add-LocalGroupMember -Group 'Administrators' -Member $LocalAdminAccountName -Confirm:$false 
        Write-ToLog -Message "Added user to Administators group" -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
    }
}
function Disable-DefaultAdmin{
    try
    {
        Write-ToLog -Message "Disabling Default Admin" -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
        Get-LocalUser -Name 'Administrator' | Disable-LocalUser 
        Write-ToLog -Message "Changing Default Admin Password" -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
        Set-LocalUser -Name 'Administrator' -Password (ConvertTo-SecureString -AsPlainText -Force -String (new-RandomPassword -Min 16 -Max 32 -MinCharofEachType 4)) 
        Write-ToLog -Message "Renaming Default Admin" -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
        Rename-LocalUser -Name 'Administrator' -NewName 'DisabledAdmin'
    }
    catch [Microsoft.PowerShell.Commands.UserNotFoundException]
    {
        Write-ToLog -Message "Could not find account named administrator taking no further action" -LogDirectory $LogDir -FileName $LogFile -MsgLevel Warning
    }
}
function Disable-DefaultGuest{
    try
    {
        Write-ToLog -Message "Disabling Default Guest" -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
        Get-LocalUser -Name 'Guest' | Disable-LocalUser 
        Write-ToLog -Message "Changing Default Guest Password" -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
        Set-LocalUser -Name 'Guest' -Password (ConvertTo-SecureString -AsPlainText -Force -String (new-RandomPassword -Min 16 -Max 32 -MinCharofEachType 4)) -UserMayChangePassword:$false
        Write-ToLog -Message "Renaming Default Guest" -LogDirectory $LogDir -FileName $LogFile -MsgLevel Info
        Rename-LocalUser -Name 'Guest' -NewName 'DisabledGuest'
    }
    catch [Microsoft.PowerShell.Commands.UserNotFoundException]
    {
        Write-ToLog -Message "Could not find account named guest taking no further action" -LogDirectory $LogDir -FileName $LogFile -MsgLevel Warning
    }
}
function Lock-TLS{
    $NumberOfStages= 16
    Invoke-Stage -Stage "Set-SChannelProtocol" -StageNumber 1 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-Protocol 'Multi-Protocol Unified Hello'")
    Invoke-Stage -Stage "Set-SChannelProtocol" -StageNumber 2 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-Protocol 'PCT 1.0'")
    Invoke-Stage -Stage "Set-SChannelProtocol" -StageNumber 3 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-Protocol 'SSL 2.0'")
    Invoke-Stage -Stage "Set-SChannelProtocol" -StageNumber 4 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-Protocol 'SSL 3.0'")
    Invoke-Stage -Stage "Set-SChannelProtocol" -StageNumber 5 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-Protocol 'TLS 1.0'")
    Invoke-Stage -Stage "Set-SChannelProtocol" -StageNumber 6 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-Protocol 'TLS 1.1'")
    Invoke-Stage -Stage "Set-SChannelProtocol" -StageNumber 7 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-Protocol 'TLS 1.2' -Enable")
    Invoke-Stage -Stage "Set-SChannelProtocol" -StageNumber 8 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-Protocol 'TLS 1.3' -Enable")
    Invoke-Stage -Stage "Lock-NetFrameworks" -StageNumber 9 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile
    Invoke-Stage -Stage "Lock-InternetBrowser" -StageNumber 11 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile
    #Invoke-Stage -Stage "Disable-WeakCiphers" -StageNumber 12 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile
    Invoke-Stage -Stage "Disable-WeakHashes" -StageNumber 13 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile
    Invoke-Stage -Stage "Set-DHMinKeyLength" -StageNumber 14 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile
    Invoke-Stage -Stage "Set-PKCSMinKeyLength" -StageNumber 15 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile
    Invoke-Stage -Stage "Set-CypherSuiteOrder" -StageNumber 16 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile

    }
function Set-SChannelProtocol{
    Param(
        [string]$Protocol,
        [switch]$Enable
    )
    if ($Enable)
    {
        Write-ToLog -Message  ('Enabling Schannel Protocol {0}' -f $Protocol) -LogDirectory $LogDir -FileName $LogFile -MsgLevel Debug
        $EnableValue = 1
        $DisableByDefaultValue = 0
    }
    else
    {
        Write-ToLog -Message  ('Disabling Schannel Protocol {0}' -f $Protocol) -LogDirectory $LogDir -FileName $LogFile -MsgLevel Debug
        $EnableValue = 0
        $DisableByDefaultValue = 1
    }
    $keys = "Client","Server"
    $RegBase = ("HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\{0}\" -f $Protocol)
    foreach ($key in $keys){
        $keyPath = ("{0}{1}" -f $RegBase, $key)
        Set-RegistryKey -keyPath $keyPath -property "Enabled" -value $EnableValue
        Set-RegistryKey -keyPath $keyPath -property "DisabledByDefault" -value $DisableByDefaultValue
    }
}
function Lock-NetFrameworks{
    $NetFrameworkVersions = 'v2.0.50727','v4.0.30319'
    $RegKeyPart1 = "HKLM:\SOFTWARE\"
    $RegKeyPart2 = "Microsoft\.NETFramework\"
    foreach($NetFrameworkVersion in $NetFrameworkVersions){
        
        Set-RegistryKey -keyPath ("{0}{1}{2}" -f $RegKeyPart1, $RegKeyPart2,$NetFrameworkVersion) -property "SystemDefaultTlsVersions" -value 1
        Set-RegistryKey -keyPath ("{0}{1}{2}" -f $RegKeyPart1, $RegKeyPart2,$NetFrameworkVersion) -property "SchUseStrongCrypto" -value 1
        if (Test-Path 'HKLM:\SOFTWARE\Wow6432Node'){
            Set-RegistryKey -keyPath ("{0}Wow6432Node\{1}{2}" -f $RegKeyPart1, $RegKeyPart2,$NetFrameworkVersion) -property "SystemDefaultTlsVersions" -value 1
            Set-RegistryKey -keyPath ("{0}Wow6432Node\{1}{2}" -f $RegKeyPart1, $RegKeyPart2,$NetFrameworkVersion) -property "SchUseStrongCrypto" -value 1
        }
    }

    
}
function Lock-SpeculativeCodeExec{
    #https://community.tenable.com/s/article/Speculative-Execution-Side-Channel-Vulnerability-Plugin-and-Mitigation-Information
    $SpecKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    Set-RegistryKey -keyPath $SpecKey  -property "FeatureSettingsOverrideMask" -Value 3
    Set-RegistryKey -keyPath $SpecKey  -property "FeatureSettingsOverride" -Value 72
    #If the Hyper-V feature is installed, add the following registry setting:
    #Set-RegistryKey -keyPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization" -property "MinVmVersionForCpuBasedMitigations" -Value "1.0" -type "String"
}
function Disable-LLMNR{
    Set-RegistryKey -keyPath 'hklm:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -property "EnableMulticast" -value 0
}
function Disable-NBT{
    $RegKey = "HKLM:\SYSTEM\CurrentControlSet\Services\NETBT\Parameters\Interfaces"
    Get-ChildItem -Path $RegKey | Set-RegistryKey -KeyPath ("{0}\{1}" -f $RegKey, $_.Name) -property "NetbiosOptions" -Value 2
}
function Lock-InternetBrowser{
  $SecureProtocols = @(
  #8, #SSL 2.0
  #32, #SSL 3.0
  #128, #TLS 1.0
  #512, #TLS 1.1
  2048,  # TLS 1.2
  8192 #TLS 1.3
)
    $SecureProtocolValue = ($SecureProtocols | Measure-Object -Sum).Sum
    $RegKeyPart1 = "HKLM:\SOFTWARE\"
    $RegKeyPart2 = "Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp"       
    Set-RegistryKey -keyPath ("{0}{1}" -f $RegKeyPart1, $RegKeyPart2) -property "DefaultSecureProtocols" -value $SecureProtocolValue
    if (Test-Path 'HKLM:\SOFTWARE\Wow6432Node'){
        Set-RegistryKey -keyPath ("{0}Wow6432Node\{1}" -f $RegKeyPart1, $RegKeyPart2) -property "DefaultSecureProtocols" -value $SecureProtocolValue
    }
}
function Disable-WeakCiphers{
    #https://docs.microsoft.com/en-us/troubleshoot/windows-server/windows-security/restrict-cryptographic-algorithms-protocols-schannel
   $insecureCiphers = @(
      'DES 56/56',
      'NULL',
      'RC2 128/128',
      'RC2 40/128',
      'RC2 56/128',
      'RC4 40/128',
      'RC4 56/128',
      'RC4 64/128',
      'RC4 128/128',
      'Triple DES 168')
    $RegKeyRoot = "HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers"

    forEach($cipher in $insecureCiphers){
        Set-RegistryKey -keyPath ("{0}\{1}" -f $RegKeyRoot, $cipher) -property "Enabled" -value 0
    }
}
function Disable-Weakhashes{
   $insecureHashes = @(
      'MD5')
    $RegKeyRoot = "HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes"

    forEach($hashes in $insecureHashes){
        Set-RegistryKey -keyPath ("{0}\{1}" -f $RegKeyRoot, $cipher) -property "Enabled" -value 0
    }
}
function Set-DHMinKeyLength{
 #https://docs.microsoft.com/en-us/security-updates/SecurityAdvisories/2016/3174644
 $RegKeyRoot = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\Diffie-Hellman"
 Set-RegistryKey -keyPath $RegKeyRoot -property "ServerMinKeyBitLength" -value 2048
 Set-RegistryKey -keyPath $RegKeyRoot -property "ClientMinKeyBitLength" -value 2048
}
function Set-PKCSMinKeyLength{
 $RegKeyRoot = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\PKCS"
 Set-RegistryKey -keyPath $RegKeyRoot -property "ClientMinKeyBitLength" -value 2048
}
function Set-CypherSuiteOrder{
#https://docs.microsoft.com/en-us/windows/win32/secauthn/prioritizing-schannel-cipher-suites
      $cipherSuitesOrder = @(
       'TLS_CHACHA20_POLY1305_SHA256', #TLS 1.3
       'TLS_AES_256_GCM_SHA384', #TLS 1.3
       'TLS_AES_128_GCM_SHA256', #TLS 1.3
       'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
       'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
       'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
       'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
       'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384',
       'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256',
       'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA',
       'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA'
       'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384',
       'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256',
       'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA',
       'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA'
       )
    Set-RegistryKey -keyPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Cryptography\Configuration\Local\SSL\00010002' -property "Functions" -value $cipherSuitesOrder -type MultiString
  
}
function Set-LSAProtection{
# https://docs.microsoft.com/en-us/windows-server/security/credentials-protection-and-management/configuring-additional-lsa-protection#BKMK_
    Set-RegistryKey -keyPath "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -property "RunAsPPL" -value 1 
}
function Set-DllSearchMode{
    #TODO I believe SafeDLL searchmode is now the default TO CHECK
    Set-RegistryKey -keyPath "HKLM:\System\CurrentControlSet\Control\Session Manager" -property "SafeDllSearchMode" -value 1 #https://docs.microsoft.com/en-us/windows/win32/dlls/dynamic-link-library-search-order
}
function Enable-ApplicationGuard{
    Param(
        $mode = "Audit"
    )
    Invoke-Stage -Stage "Enable-VirtualisationBasedSecurity" -StageNumber 1 -Stages 2 -SubStage:$true -LogDir $LogDir -LogFile $LogFile
    Invoke-Stage -Stage "Enable-WindowsFeature" -StageNumber 2 -Stages 2 -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters "-featureName 'Windows-Defender-ApplicationGuard'"
    #Currently Might require internet
    if ($mode -eq "Audit"){
    Set-RegistryKey -keyPath "HKLM:\SOFTWARE\Policies\Microsoft\AppHVSIr" -property "AuditApplicationGuard" -value 1
    }

}
function Enable-VirtualisationBasedSecurity{
    Invoke-Stage -Stage "Enable-WindowsFeature" -StageNumber 1 -Stages 1 -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters "-featureName 'Microsoft-Hyper-V'"
    Set-RegistryKey -keyPath "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -property "EnableVirtualizationBasedSecurity" -value 1
}
function Enable-WindowsFeature{
param(
    [string]$featureName
)
    if ((Get-WindowsOptionalFeature -Online -FeatureName $featureName).State -ne "Enabled"){
        Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName $featureName -All | Out-Null
    }
}
function Set-Bitlocker {}
function Enable-KeyboardFilter {
    Invoke-Stage -Stage "Enable-WindowsFeature" -StageNumber 1 -Stages 1 -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters "-featureName 'Client-KeyboardFilter'"
    Get-Service -Name MsKeyboardFilter | Set-Service -StartupType Automatic
    $KeyCombos = @('Alt','Application','Ctrl','Escape','Windows','Alt+Esc','Alt+F4','Alt+Space','Alt+Tab','BrowserBack','BrowserFavorites','BrowserForward','BrowserHome','BrowserRefresh','BrowserSearch','BrowserStop','Ctrl+Alt+Del','Ctrl+Alt+Esc','Ctrl+Esc','Ctrl+F4','Ctrl+Tab','Ctrl+Win+F','LaunchApp1','LaunchApp2','LaunchMail','LaunchMediaSelect','LShift+LAlt+NumLock','LShift+LAlt+PrintScrn','MediaNext','MediaPlayPause','MediaPrev','MediaStop','Shift+Ctrl+Esc','VolumeDown','VolumeMute','VolumeUp','Win+-','Win+,','Win+.','Win+/','Win++','Win+B','Win+Break','Win+C','Win+D','Win+Down','Win+E','Win+Enter','Win+Esc','Win+F','Win+F1','Win+H','Win+Home','Win+I','Win+J','Win+K','Win+L','Win+Left','Win+M','Win+O','Win+P','Win+PageDown','Win+PageUp','Win+Q','Win+R','Win+Right','Win+Shift+Down','Win+Shift+Left','Win+Shift+Right','Win+Shift+Up','Win+Space','Win+T','Win+Tab','Win+U','Win+Up','Win+V','Win+W','Win+Z','Shift+Win','Alt+Win','Ctrl+Win','F21')
    $i =1;
    Invoke-Stage -Stage Set-KeyboardFilterSettings -StageNumber $i -Stages $KeyCombos.Count -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-setting 'DisableKeyboardFilterForAdministrators' -value 'false'")
    Invoke-Stage -Stage Set-KeyboardFilterSettings -StageNumber $i -Stages $KeyCombos.Count -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-setting 'ForceOffAccessibility' -value 'true'")
    Invoke-Stage -Stage Set-KeyboardFilterSettings -StageNumber $i -Stages $KeyCombos.Count -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-setting 'BreakoutKeyScanCode' -value '119'") #f8 as break out key
    foreach ($keycombo in $KeyCombos){
        Invoke-Stage -Stage Set-KeyboardShortcutFilters -StageNumber $i -Stages $KeyCombos.Count -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-KeyCombo '{0}'" -f $keycombo)
        $i++
    }
}
function Set-KeyboardShortcutFilters{
    param(
        [switch] $AllowShortcut = $false,
        [string] $KeyCombo
    )
    $AllowValue = 0 
    if ($AllowShortcut){
        $AllowValue = 1
    }    
    $key = Get-CimInstance -ClassName WEKF_PredefinedKey -Namespace 'root\standardcimv2\embedded' -Filter ("id='{0}'" -f $KeyCombo)
    $key | Set-CimInstance -Property @{Enabled=$AllowValue}

}
function Set-KeyboardFilterSettings{
    param(
        [string] $setting,
        [string] $value
    )
    $AllowValue = 0 
    if ($AllowShortcut){
        $AllowValue = 1
    }
    
    $key = Get-CimInstance -ClassName WEKF_Settings -Namespace 'root\standardcimv2\embedded' -Filter ("name='{0}'" -f $setting)
    $key | Set-CimInstance -Property @{value=$value}

}
function Set-UnifiedWriteFilter{
    #https://docs.microsoft.com/en-us/windows-hardware/customize/enterprise/uwf-turnonuwf
    $NumberOfStages= 16
    Invoke-Stage -Stage "Disable-PagingFiles" -StageNumber 1 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile
    Invoke-Stage -Stage "Disable-SystemRestore" -StageNumber 2 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile
    Invoke-Stage -Stage "Disable-SuperFetch" -StageNumber 3 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile
    Invoke-Stage -Stage "Disable-FileIndexing" -StageNumber 4 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile
    Invoke-Stage -Stage "Disable-FastBoot" -StageNumber 5 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile
    Invoke-Stage -Stage "Disable-Defrag" -StageNumber 6 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile
    Invoke-Stage -Stage "Set-BCD" -StageNumber 7 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile
    Invoke-Stage -Stage "Enable-WindowsFeature" -StageNumber 8 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters "-featureName 'Client-UnifiedWriteFilter'"
    
    Invoke-Stage -Stage "Enable-UWF" -StageNumber 9 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile
    Invoke-Stage -Stage "Protect-VolumeWithUWF" -StageNumber 10 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters "-DriveLetter C"
    Invoke-Stage -Stage "Set-UWFExceptions" -StageNumber 11 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile 
    Invoke-Stage -Stage Set-UWFConfig -StageNumber 12 -Stages $NumberOfStages -SubStage:$true -LogDir $LogDir -LogFile $LogFile 
}
function Disable-PagingFiles{
    $key = Get-CimInstance -ClassName Win32_ComputerSystem 
    $key | Set-CimInstance -Property @{AutomaticManagedPagefile=$false}
    Get-CimInstance win32_pagefilesetting | Remove-CimInstance
}
function Disable-SystemRestore{    
     Disable-ComputerRestore -Drive $env:SystemDrive
}
function Disable-SuperFetch{
    Set-Service -Name "SysMain" -StartupType Disabled
    Stop-Service -Force -Name "SysMain"
}
function Disable-FileIndexing{
    $key = Get-CimInstance -ClassName Win32_Volume -Filter ("DriveLetter='{0}'" -f $env:SystemDrive)    
    $key |Set-CimInstance -Property @{IndexingEnabled='False'}
}
function Disable-FastBoot{
    Set-RegistryKey -keyPath "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -property HiberbootEnabled -value 0 -type DWord
}
function Disable-Defrag{
    Get-ScheduledTask -TaskName ScheduledDefrag  | Disable-ScheduledTask | Out-Null
}
function Set-BCD{
    Invoke-Expression -Command "bcdedit /set bootstatuspolicy ignoreallfailures"
    Invoke-Expression -Command "bcdedit /set recoveryenabled No"
}
function Set-UWFExceptions{
    $DirExceptions = @() 
    $RegExceptions = @()
    # Windows Defender Exceptions https://docs.microsoft.com/en-gb/windows-hardware/customize/enterprise/uwf-antimalware-support
    $DirExceptions += "C:\Program Files\Microsoft Defender", "C:\ProgramData\Microsoft\Microsoft Defender", "C:\Windows\WindowsUpdate.log", "C:\Windows\Temp\MpCmdRun.log" 
    $RegExceptions  += "HKLM\SOFTWARE\Microsoft\Microsoft Defender","HKLM\SYSTEM\CurrentControlSet\Services\WdBoot", "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter", "HKLM\SYSTEM\CurrentControlSet\Services\WdNisSvc", "HKLM\SYSTEM\CurrentControlSet\Services\WdNisDrv","HKLM\SYSTEM\CurrentControlSet\Services\WinDefend"
    #SCEP Exceptions https://docs.microsoft.com/en-gb/windows-hardware/customize/enterprise/uwf-antimalware-support
    $DirExceptions += "C:\Program Files\Microsoft Security Client","C:\Windows\Windowsupdate.log","C:\Windows\Temp\Mpcmdrun.log","C:\ProgramData\Microsoft\Microsoft Antimalware"
    $RegExceptions  += "HKLM\SOFTWARE\Microsoft\Microsoft Antimalware"
    #Allow Daylight saving time changes to persist https://docs.microsoft.com/en-us/windows-hardware/customize/enterprise/uwfexclusions
    $RegExceptions  += "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones", "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation"
    # Allow BITs
    $DirExceptions += ("{0}\Microsoft\Network\Downloader" -f $env:ALLUSERSPROFILE)
    $RegExceptions  += ("HKLM\Software\Microsoft\Windows\CurrentVersion\BITS\StateIndex")
    #Allow CEIP
    $RegExceptions  += ("HKLM\Software\Policies\Microsoft\SQMClient\Windows\CEIPEnable","HKLM\Software\Microsoft\SQMClient\Windows\CEIPEnable", "HKLM\Software\Microsoft\SQMClient\UploadDisableFlag")
    $UWFRegFilter = Get-CimInstance -ClassName "UWF_RegistryFilter" -Namespace "root\standardcimv2\embedded" -Filter ("CurrentSession='false'") 
    foreach  ($regException in $RegExceptions){
        Invoke-CimMethod -InputObject $UWFRegFilter -MethodName AddExclusion -Arguments @{RegistryKey=$regException}
    }
    $VolumeC = (Get-Volume -DriveLetter C).UniqueId.Split("\")
    $UWFDirFiltersVolumeC = Get-CimInstance -ClassName "UWF_Volume" -Namespace "root\standardcimv2\embedded" -Filter ("CurrentSession='false' and VolumeName='{0}'" -f $VolumeC[3])
    foreach ($DirException in $DirExceptions)    {
        $reformat  = $DirException.Split(":")
        if ($reformat[0] -eq 'C'){
            Invoke-CimMethod -InputObject $UWFDirFiltersVolumeC  -MethodName AddExclusion -Arguments @{FileName='$reformat[1]'} #Some optimisation by assuming the vast majority of exceptions will be on the C drive
        }
        else{
            $Volume = (Get-Volume -DriveLetter $reformat[0]).UniqueId.Split("\")
            Get-CimInstance -ClassName "UWF_Volume" -Namespace "root\standardcimv2\embedded" -Filter ("CurrentSession='false' and VolumeName='{0}'" -f $Volume[3]) | Invoke-CimMethod -MethodName AddExclusion -Arguments @{FileName='$reformat[1]'}
        }

    }
}
function Set-UWFConfig{
    $MaximumSize = 10240
    $uwfOverlayConfig = Get-CimInstance -Namespace 'root\standardcimv2\embedded' -ClassName 'UWF_OverlayConfig' -Filter ("CurrentSession='false'")
    Invoke-CimMethod -InputObject $uwfOverlayConfig -MethodName SetMaximumSize -Arguments @{size = $MaximumSize} | Out-Null #maximum size in MB
    Invoke-Expression  ("uwfmgr.exe overlay set-warningthreshold {0}" -f [math]::Floor(($MaximumSize/100)*75)) | Out-Null
    Invoke-Expression  ("uwfmgr.exe overlay set-CriticalSize {0}" -f [math]::Floor(($MaximumSize/100)*90)) | Out-Null
    Invoke-Expression  ("uwfmgr.exe overlay Set-Type Disk") | Out-Null
    Invoke-Expression  ("uwfmgr.exe overlay set-passthrough off") | Out-Null
}
function Enable-UWF{
    $uwfFilter = Get-CimInstance -Namespace 'root\standardcimv2\embedded' -ClassName 'UWF_Filter'
    if (($objUWFFilter.CurrentEnabled)-or($objUWFFilter.NextEnabled)) {
        return # already enabled or will be enabled on next reboot so no action to take 
    }
    Invoke-CimMethod -InputObject $uwfFilter -MethodName Enable | Out-Null  
    
}
function Protect-VolumeWithUWF{
param(
    [char]$Driveletter
)
    Invoke-Expression  ("uwfmgr.exe volume protect {0}:" -f $Driveletter) | Out-Null
}
function Enable-ConstrainedLanguageMode{
    Set-RegistryKey -keyPath "HKLM:\System\CurrentControlSet\Control\SESSION MANAGER\Environment\" -property "__PSLockdownPolicy" -value 4 -type DWord
}
function Update-LicenceKey{
param(
    [string]$productKey
)
   $Licences = Get-CimInstance -ClassName "SoftwareLicesingService" -Namespace "root\cimv2"
    foreach  ($Licence in $Licences){
        Invoke-CimMethod -InputObject $Licence -MethodName InstallProductKey -Arguments @{ProductKey=$productKey}
        Invoke-CimMethod -InputObject $Licence -MethodName RefreshLicenseStatus
    }
}
function Set-UserLanguage{
param(
    [string]$UserLanguage # "en-GB"
)
    #Get-WinUserLanguageList
    Set-WinUserLanguageList -Force -LanguageList $UserLanguage
}