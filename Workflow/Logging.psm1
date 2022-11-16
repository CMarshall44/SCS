enum LogLevel
{
    Info = 1
    Warning = 2
    Error = 4
    Fatal = 8
    Debug = 16
    Verbose = 32
}
Class LogFile
{
    [string]$LogFileDir = [string]${env:Temp}+"\Logs\"
    [string]$LogFileName = "Log.log"
    [string]$FullLogPath = $this.LogFileDir + $this.LogFileName
    [int]$LogMaxSizeKB = 4096 # Max Size of log file in Kilobytes
    [int]$ArchiveLevel = 1 # Number of Archived logfile
    [Bool]$AllowDebug = $false;
    [bool]$AllowVerbose = $false;
}
Class LogMessage
{
    [LogFile]$LogFile = [LogFile]::New()
    [String]$Message
    [LogLevel]$LogLevel

    [void] PublishLogMessage()
    {
                $Local:FullLogPath = ("{0}{1}" -f $this.LogFile.LogFileDir, $this.LogFile.LogFileName)
        try
        {

                # Message is valid so can be published
                Out-File -FilePath $Local:FullLogPath -InputObject ("{0}  - {1} -  {2}" -f $this.LogLevel, (Get-Date -Format o) ,$this.Message) -NoClobber -Append
            
        }
        catch [System.IO.DirectoryNotFoundException]
        {
            #Directory not found create directory and then reprocess
            [system.io.directory]::CreateDirectory($this.LogFile.LogFileDir)
            Out-File -FilePath $Local:FullLogPath -InputObject $this.Message -NoClobber -Append
            
        }
        catch
        {
            Write-Host "There was an Error writing to the logfile." -ErrorAction SilentlyContinue -ForegroundColor Red
            Write-Host $_.Exception

        }
    }
}
Function Write-ToLog
{
  Param(
    [Parameter(Mandatory=$True)]
      [string]$Message,
    [Parameter(Mandatory=$True)]
      [string]$LogDirectory,
    [Parameter(Mandatory=$True)]
      [string]$FileName,
    [Parameter(Mandatory=$True)]
      [LogLevel]$MsgLevel
    )
    try
    {
        $LogFile = [LogFile]::New()
        $LogFile.LogFileDir = $LogDirectory
        $LogFile.LogFileName = $FileName
        #$LogFile.MsgLevel 
        $LogMessage = [LogMessage]::New()
        $LogMessage.LogFile = $LogFile
        $LogMessage.Message = $Message
        $LogMessage.LogLevel = [LogLevel]$MsgLevel
        $LogMessage.PublishLogMessage()
    }

    catch
    {
     Write-Host $_.Exception
    }
    finally
    {
    }

}

