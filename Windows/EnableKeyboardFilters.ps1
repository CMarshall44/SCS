function Enable-KeyboardFilter {
    Invoke-Stage -Stage "Enable-WindowsFeature" -StageNumber 1 -Stages 1 -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters "-featureName 'Client-KeyboardFilter'"
    Get-Service -Name MsKeyboardFilter | Set-Service -StartupType Automatic
    $KeyCombos = @('Alt','Application','Ctrl','Escape','Windows','Alt+Esc','Alt+F4','Alt+Space','Alt+Tab','BrowserBack','BrowserFavorites','BrowserForward','BrowserHome','BrowserRefresh','BrowserSearch','BrowserStop','Ctrl+Alt+Del','Ctrl+Alt+Esc','Ctrl+Esc','Ctrl+F4','Ctrl+Tab','Ctrl+Win+F','LaunchApp1','LaunchApp2','LaunchMail','LaunchMediaSelect','LShift+LAlt+NumLock','LShift+LAlt+PrintScrn','MediaNext','MediaPlayPause','MediaPrev','MediaStop','Shift+Ctrl+Esc','VolumeDown','VolumeMute','VolumeUp','Win+-','Win+,','Win+.','Win+/','Win++','Win+B','Win+Break','Win+C','Win+D','Win+Down','Win+E','Win+Enter','Win+Esc','Win+F','Win+F1','Win+H','Win+Home','Win+I','Win+J','Win+K','Win+L','Win+Left','Win+M','Win+O','Win+P','Win+PageDown','Win+PageUp','Win+Q','Win+R','Win+Right','Win+Shift+Down','Win+Shift+Left','Win+Shift+Right','Win+Shift+Up','Win+Space','Win+T','Win+Tab','Win+U','Win+Up','Win+V','Win+W','Win+Z','Shift+Win','Alt+Win','Ctrl+Win','F21')
    $i =1;
    Invoke-Stage -Stage Set-KeyboardFilterSettings -StageNumber $i -Stages $KeyCombos.Count -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-setting 'DisableKeyboardFilterForAdministrators' -value 'false'")
    Invoke-Stage -Stage Set-KeyboardFilterSettings -StageNumber $i -Stages $KeyCombos.Count -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-setting 'ForceOffAccessibility' -value 'true'")
    Invoke-Stage -Stage Set-KeyboardFilterSettings -StageNumber $i -Stages $KeyCombos.Count -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-setting 'BreakoutKeyScanCode' -value '119'") #f8 as break out key
    foreach ($keycombo in $KeyCombos){
        Invoke-Stage -Stage Set-KeyboardShortcutFilters -StageNumber $i -Stages $KeyCombos.Count -SubStage:$true -LogDir $LogDir -LogFile $LogFile -Parameters ("-KeyCombo '{0}'" -f $keycombo)
        $i++
    }
}