function Disable-UWF() {
	$NAMESPACE = "root\standardcimv2\embedded"
	# Retrieve the UWF_Filter settings.
	$objUWFInstance = Get-WMIObject -namespace $NAMESPACE -class UWF_Filter;

	if(!$objUWFInstance) {
		Write-Error -Exception ([System.EntryPointNotFoundException]::new("Could not load root\standardcimv2\embedded\UWF_Filter")) -ErrorAction Stop
	}
					
	# Call the method to disable UWF after the next restart.  This sets the NextEnabled property to false.

	$retval = $objUWFInstance.Disable();

	# Check the return value to verify that the disable is successful
	if ($retval.ReturnValue -eq 0) {
		"Unified Write Filter will be disabled after the next system restart."
	}
	else {
		Write-Error -Exception ([System.ApplicationException]::new("Unexpected return value {0}" -f $retval.ReturnValue)) -ErrorAction Stop
	}
}