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