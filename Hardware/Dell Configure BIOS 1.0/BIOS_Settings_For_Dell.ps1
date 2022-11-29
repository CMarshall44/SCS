Param
(
	[string]$MyPassword	= "PLACEHOLDERPASSWORD"
)				
set-Location -Path $PSScriptRoot
$SystemRoot = $env:SystemRoot
$Log_File = "$SystemRoot\Debug\Dell_BIOS_Settings.log" 
If(test-path $Log_File)
	{
		remove-item $Log_File -force
	}
new-item $Log_File -type file -force

Function Write-Log
	{
	param(
	$Message_Type, 
	$Message
	)
		$MyDate = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)  
		Add-Content $Log_File  "$MyDate - $Message_Type : $Message"  
        Write-Host "$MyDate - $Message_Type : $Message"  
	} 

Function Get-NugetPackageProvider{
    [CmdletBinding()]
    param(
    [string]$minimumVersion = "2.8.5.201"
    )
    try
    {
        If (!(Get-PackageProvider -ListAvailable | Where Name -eq Nuget)) 
        {     
        Install-PackageProvider -Name NuGet -MinimumVersion $minimumVersion -Force 
        Write-Log -Message_Type "INFO" -Message "Nuget Package Provider has been installed"		
        }
        else
        {
            Write-Log -Message_Type "INFO" -Message "Nuget Package Provider is already available"  
        }
        `
    }
    catch
    {
        Write-Log -Message_Type "Error" -Message "Failed to install prerequisite package provider"

    }
}
Function Get-DellBIOSProvider{
    [CmdletBinding()]
    param()		
    try{
        $availbleModules = Get-Module -listavailable
        Write-Log -Message_Type "INFO" -Message ("Avaliliable modules are")
        $availbleModules
        If (!(Get-Module DellBIOSProvider -listavailable)){
            Get-NugetPackageProvider -minimumVersion "2.8.5.201"
            Install-Module DellBIOSProvider -Force  -ErrorAction stop
            Write-Log -Message_Type "INFO" -Message "DellBIOSProvider has been installed"  			
        }
            Import-Module DellBIOSProvider -ErrorAction stop
            Write-Log -Message_Type "INFO" -Message "DellBIOSProvider has been imported"  

        $availbleModules = Get-Module -listavailable
        $availbleModules
        Write-Log -Message_Type "INFO" -Message ("Avaliliable modules are now" )	
    }
    catch{
        Write-Log -Message_Type "Error" -Message "Failed to import Dell BIOS Provider " 
        Write-Log -Message_Type "Error" -Message $_.Exception.Message  	
        throw $_.Exception  
    }
}
  
Write-Log -Message_Type "INFO" -Message "The 'Set BIOS settings for Dell' process starts"  
Try{
    Get-DellBIOSProvider 
}
catch{
    Write-Log -Message_Type "ERROR" -Message "Failed to get Dell BIOS Provider"
    Exit 1002  
}
  
$Exported_CSV = ".\BIOS_Settings.csv"																																			
$Get_CSV_Content = Import-CSV $Exported_CSV  -Delimiter ";"				

$IsPasswordSet = (Get-Item -Path DellSmbios:\Security\IsAdminPasswordSet).currentvalue 

If($IsPasswordSet -eq $true){
	Write-Log -Message_Type "INFO" -Message "A password is configured"  
	If($MyPassword -eq ""){
		Write-Log -Message_Type "WARNING" -Message "No password has been sent to the script"  	
		Exit 1001
	}
}
	
$Dell_BIOS = get-childitem -path DellSmbios:\ | foreach {
get-childitem -path @("DellSmbios:\" + $_.Category)  | select-object attribute, currentvalue, possiblevalues, PSChildName}   

ForEach($New_Setting in $Get_CSV_Content){ 
	$Setting_To_Set = $New_Setting.Setting 
	$Setting_NewValue_To_Set = $New_Setting.Value 
	Add-Content $Log_File  "" 
	Write-Log -Message_Type "INFO" -Message "Change to do: $Setting_To_Set > $Setting_NewValue_To_Set"  
	ForEach($Current_Setting in $Dell_BIOS | Where {$_.attribute -eq $Setting_To_Set}){ 
        $Attribute = $Current_Setting.attribute
		$Setting_Cat = $Current_Setting.PSChildName
        $Setting_Current_Value = $Current_Setting.CurrentValue
		If (($IsPasswordSet -eq $true)){   
			$Password_To_Use = $MyPassword
			Try{
                & Set-Item -Path Dellsmbios:\$Setting_Cat\$Attribute -Value $Setting_NewValue_To_Set -Password $Password_To_Use
				Write-Log -Message_Type "SUCCESS" -Message "New value for $Attribute is $Setting_Current_Value"  						
			}
            Catch{
				Write-Log -Message_Type "ERROR" -Message "Cannot change setting $Attribute (Return code $Change_Return_Code)"  																		
			}
		}
		Else{
            Try{
				& Set-Item -Path Dellsmbios:\$Setting_Cat\$Attribute -Value $Setting_NewValue_To_Set  
			    Write-Log -Message_Type "SUCCESS" -Message "New value for $Attribute is $Setting_Current_Value"  						
			}
            Catch{
				Write-Log -Message_Type "ERROR" -Message "Cannot change setting $Attribute (Return code $Change_Return_Code)"  																		
            }						
		}        
	}  
}  

Try{
    If (($IsPasswordSet -eq $true)){
        Write-Log -Message_Type "WARNING" -Message "BIOS Password already set"  	
    }
    else{
        Set-Item -Path DellSmbios:\Security\AdminPassword $MyPassword 
        Write-Log -Message_Type "SUCCESS" -Message "Setting BIOS ADmin Password" 
    }
}
catch{
    Write-Log -Message_Type "ERROR" -Message "Failed to set BIOS Password"
    Write-Log -Message_Type "ERROR" -Message $_.Exception.Message 
}
