function Set-DllSearchMode{
    #TODO I believe SafeDLL searchmode is now the default TO CHECK
    Set-RegistryKey -keyPath "HKLM:\System\CurrentControlSet\Control\Session Manager" -property "SafeDllSearchMode" -value 1 #https://docs.microsoft.com/en-us/windows/win32/dlls/dynamic-link-library-search-order
}