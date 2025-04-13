function Lock-InternetBrowserProtocol{
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