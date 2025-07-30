WriteToApplicationEventLog 0,"Success test"
WriteToApplicationEventLog 1,"Error test"
WriteToApplicationEventLog 2,"Warning test"
WriteToApplicationEventLog 4,"Info test"



sub WriteToApplicationEventLog(intType, strMessage)
Dim shl
'0 success , 1 Error , 2 Warning , 4 Information , 8 Audit Success , 16 Audit Failure
      Set shl = CreateObject("WScript.Shell")

      Call shl.LogEvent(intType,strMessage)

      Set shl = Nothing
if Err.Number <> 0 THEN 
			' not important if logging failes
		Err.Clear
	End if
end sub