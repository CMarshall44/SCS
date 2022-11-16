#Requires -RunAsAdministrator


function New-VirtualMachine
{
    [CmdletBinding(SupportsShouldProcess)]
    param(
    [string[]]$VM,
    $VMStartupMemory = 4GB,
    [string]$VMSwitch,
    [string]$VMConfigDir,
    [string]$VHDDir,
    [string]$SnapshotDir,
    [string]$PagingDir,
    [string]$ISOPath,
    [switch]$InOwnDirectory = $false,
    [int]$ProcessorCount = 2,
    [Switch]$NoDVDDrive = $false
    )
    process
    {
        forEach ($VMName in $VM)
        {
            Try
            {
                
                $VMPath = ("{0}" -f $VMConfigDir)
                if ($InOwnDirectory)
                {
                    $VHDPath =("{0}\{1}" -f $VHDDir ,$VMName)
                    $SnapshotPath = ("{0}\{1}" -f $SnapshotDir ,$VMName)
                    $PagingPath = ("{0}\{1}" -f $PagingDir ,$VMName)
                }         
                else
                {
                    $VHDPath =("{0}" -f $VHDDir)
                    $SnapshotPath = ("{0}" -f $SnapshotDir)
                    $PagingPath = ("{0}" -f $PagingDir)
                }
                if (Test-Path ("{0}\OS.vhdx" -f $VHDPath)){
                    Write-Error ("Cannot create VM as {0}\OS.vhdx already exists" -f $VHDPath)
                    break
                }
                New-VM -Name $VMName -MemoryStartupBytes $VMStartupMemory -Generation 2 -SwitchName $VMSwitch -NewVHDPath ("{0}\OS.vhdx" -f $VHDPath) -NewVHDSizeBytes 128GB -Path $VMPath  -ErrorAction Stop | Out-Null
   
                Set-VMMemory $VMName -DynamicMemoryEnabled $true -StartupBytes $VMStartupMemory -MaximumBytes ($VMStartupMemory + $VMStartupMemory) -MinimumBytes $VMStartupMemory -Priority 50 | Out-Null
                if (Test-Path ("{0}\Binaries.vhdx" -f $VHDPath)){
                    Write-Warning ("Cannot create VM HardDrive as {0}\Binaries.vhdx already exists" -f $VHDPath)
                }
                else
                {
                    New-VHD -Path ("{0}\Binaries.vhdx" -f $VHDPath) -SizeBytes 60GB -Dynamic | Out-Null
                    Add-VMHardDiskDrive -VMName $VMName -Path ("{0}\Binaries.vhdx" -f $VHDPath) | Out-Null
                }
                if (Test-Path ("{0}\Logs.vhdx" -f $VHDPath)){
                    Write-Warning ("Cannot create VM Hard Driveas {0}\Logs.vhdx already exists" -f $VHDPath)
                }
                else
                {
                    New-VHD -Path ("{0}\Logs.vhdx" -f $VHDPath) -SizeBytes 40GB -Dynamic  | Out-Null
                    Add-VMHardDiskDrive -VMName $VMName -Path ("{0}\Logs.vhdx" -f $VHDPath) | Out-Null
                }

                Set-VMProcessor  $VMName -Count $ProcessorCount -Reserve 10 -Maximum 75 -RelativeWeight 200 | Out-Null
                if ($NoDVDDrive)
                {
                    Write-Debug -Message "Skipping DVD drive as NoDVDDrive switch is present" 
                }
                else
                {
                    Add-VMDvdDrive -VMName $VMName  | Out-Null
                    if(Test-Path $ISOPath)
                    {
                        Set-VMDvdDrive -VMName $VMName -Path $ISOPath | Out-Null
                    }
                    else 
                    {
                        Write-Warning -Message "Couldn't find the ISO file so no DVD Connected"
                    }
                }
                Set-VM -Name $VMName -AutomaticStartAction Start -AutomaticStopAction ShutDown -AutomaticCheckpointsEnabled $false -SnapshotFileLocation $SnapshotPath -SmartPagingFilePath $PagingPath -CheckpointType Disabled | Out-Null
                Enable-VMIntegrationService -VMName $VMName  -Name "Guest Service Interface" | Out-Null
                
                $owner = Get-HgsGuardian UntrustedGuardian # is null until created so currently fails on brand new install as Get-HGSGuardian is empty 
                if ($null -eq $owner )
                {
                # is null until created so currently fails on brand new install as Get-HGSGuardian is empty until the first tpm is ticked
                    New-HgsGuardian -Name UntrustedGuardian -GenerateCertificates | Out-Null
                    $owner = Get-HgsGuardian UntrustedGuardian | Out-Null
                }
                $kp = New-HgsKeyProtector -Owner $owner -AllowUntrustedRoot
                Set-VMKeyProtector -VMName $VMName -KeyProtector $kp.RawData | Out-Null
                Enable-VMTPM -VMName $VMName | Out-Null
                $VMfirmware = Get-VMFirmware -VMName $VMName
                $BootOrder = $VMfirmware.BootOrder
                ForEach ($BootDevice in $BootOrder)
                {
                    Write-host  $BootDevice
                    Switch ($BootDevice.BootType)
                    {
                        Network 
                        {
                            $NetworkBoot = $BootDevice
                            break
                        }
                        Drive 
                        {
                            if ($BootDevice.Device.Path -eq ("{0}\OS.vhdx" -f $VHDPath))
                            {
                               $OSBoot = $BootDevice
                               break
                            }
                            else
                            {
                                if ($BootDevice.Device.Name -like "DVD Drive on SCSI*")
                                {
                                    $DVDBoot = $BootDevice
                                    break
                                }
                            }
                        }
                    }
                }
                if (($NoDVDDrive) -or ($null -eq $DVDBoot))
                {
                    Set-VMFirmware -VMName  $VMName -BootOrder $NetworkBoot,$OSBoot  | Out-Null
                }
                else
                {
                    Set-VMFirmware -VMName  $VMName -BootOrder $DVDBoot,$OSBoot,$NetworkBoot | Out-Null
                }
            }
            catch
            {
                Write-Error -Message "Failed to create VM"
                throw $_
            }
        }
    }
}


$VMsToCreate = @("DC-01", "DC-02","SQL-01","SQL-02","ConfigMgr-01","ConfigMgr-03","AADConnect-01", "OfflineRootCA-01", "IssuingCA-01", "FS-01")

New-VirtualMachine -VM $VMsToCreate -VMStartupMemory 4GB -VMSwitch "DataCentre-01" -VMConfigDir "D:\Hyper-V\Configs" -VHDDir "V:\Hyper-V\VHDs" -SnapshotDir "V:\Hyper-V\Snapshots" -PagingDir "D:\Hyper-V\Paging" -ISOPath ("D:\Isostore\en-us_windows_server_2022_updated_june_2022_x64_dvd_ac918027.iso") -InOwnDirectory