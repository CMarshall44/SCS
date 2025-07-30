Function Add-TrustedRootCertifcate {
	param(
		$CertificatePath
	)
	if (-not (Test-Path -Path $CertificatePath)){
		Write-Error -Exception ([System.IO.FileNotFoundException]::new("Could not find path: $CertificatePath")) -ErrorAction Stop
	}
	$Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($CertificatePath)
	$MyRootStore = Get-Item Cert:\CurrentUser\Root
	$MyRootstore.Open("ReadWrite")
	$MyRootstore.Add($Cert)
	$MyRootstore.close()
}

Add-TrustedRootCertifcate -CertificatePath "C:\Users\Test\test.cer"