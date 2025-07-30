<#
From https://msdn.microsoft.com/en-us/library/windows/hardware/mt572010(v=vs.85).aspx
#>

Function Set-UFWExclusions {
	Try {
		$uwfmgrExecutable = ("{0}\System32\uwfmgr.exe"  -f $env:windir)
		if(!$objUWFInstance) {
			Write-Error -Exception ([System.IO.FileNotFoundException]::new("Could not find $uwfmgrExecutable ")) -ErrorAction Stop
		}
		#UWF File Exclusions

		 Start-Process -NoNewWindow -wait -FilePath $uwfmgrExecutable  -ArgumentList "file add-exclusion", "C:\WINDOWS\System32\Wbem"
		 Start-Process -NoNewWindow -wait -FilePath $uwfmgrExecutable  -ArgumentList "file add-exclusion", "C:\windows\system32\winevt\logs"
		 Start-Process -NoNewWindow -wait -FilePath $uwfmgrExecutable  -ArgumentList "file add-exclusion", "C:\Program Files\Microsoft Defender"
		 Start-Process -NoNewWindow -wait -FilePath $uwfmgrExecutable  -ArgumentList "file add-exclusion", "C:\Windows\WindowsUpdate.log"
		 Start-Process -NoNewWindow -wait -FilePath $uwfmgrExecutable  -ArgumentList "file add-exclusion", "C:\Windows\Temp\MpCmdRun.log"
		 Start-Process -NoNewWindow -wait -FilePath $uwfmgrExecutable  -ArgumentList "file add-exclusion", "C:\ProgramData\Microsoft\Microsoft Defender"
		#UWF Registry Exclusions

		 Start-Process -NoNewWindow -wait -FilePath $uwfmgrExecutable  -ArgumentList "registry add-exclusion", "HKLM\Software\Microsoft\Windows NT\CurrentVersion\WinLogon"
		 Start-Process -NoNewWindow -wait -FilePath $uwfmgrExecutable  -ArgumentList "registry add-exclusion", "HKLM\System\CurrentControlSet\Services\smstsmgr"
		 Start-Process -NoNewWindow -wait -FilePath $uwfmgrExecutable  -ArgumentList "registry add-exclusion", "HKLM\Software\Microsoft\Microsoft Defender"
		#SCCM 
		Start-Process -NoNewWindow -wait -FilePath $uwfmgrExecutable  -ArgumentList "file add-exclusion", "C:\_SMSTaskSequence"
		Start-Process -NoNewWindow -wait -FilePath $uwfmgrExecutable  -ArgumentList "file add-exclusion", "C:\WINDOWS\CCM"
		Start-Process -NoNewWindow -wait -FilePath $uwfmgrExecutable  -ArgumentList "file add-exclusion", "C:\windows\ccmcache"
		Start-Process -NoNewWindow -wait -FilePath $uwfmgrExecutable  -ArgumentList "registry add-exclusion", "HKLM\Software\Microsoft\CCM"
		Start-Process -NoNewWindow -wait -FilePath $uwfmgrExecutable  -ArgumentList "registry add-exclusion", "HKLM\Software\Microsoft\SMS"
	 }
	Catch {
	}
}