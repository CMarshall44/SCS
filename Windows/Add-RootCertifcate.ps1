Function Add-TrustedRootCertifcate {
	param(
		$CertificatePath
	)
	if (!Test-Path -Path $CertificatePath){
		throw (New-Object -TypeName System.IO.filenotfoundexception	-ArgumentList "Feature named in parameter cannot be found ")
	}
	$TCert1 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($CertificatePath)
	$MyRootStore = Get-Item Cert:\CurrentUser\Root
	$MyRootstore.Open("ReadWrite")
	$MyRootstore.Add($Tcert1)
	$MyRootstore.close()
}