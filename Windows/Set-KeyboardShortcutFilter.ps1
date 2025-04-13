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