; #################################################################################################################################################################################
; Logger class
; #################################################################################################################################################################################

class LoggerObject {
	static _myInstance := 0

	static _instanceCount := 0

	LogDate := ""
	LogHour := ""
	LogFile := ""
	LastMessages := Array()
	MaxLastMessages := 10

	__New() {
		if IsObject(LoggerObject._myInstance) {
			return LoggerObject._myInstance
		}
	}
    
	static GetInstance() {
		if (IsObject(LoggerObject._myInstance) == 0 ) {
			LoggerObject._instanceCount++
			LoggerObject._myInstance := LoggerObject()
		}
		return LoggerObject._myInstance
	}

	Start() {
		this.LogDate := FormatTime(, "yy-MM-dd")

		Loop(this.MaxLastMessages)
		{
			this.LastMessages.Push("")
		}

		;Create the string for the log file
		this.LogFile := "" . A_WorkingDir . "\Logs\" . this.LogDate . ".txt"
		this.CheckForLogFile()

		this.LogStartMessage()
	}

	LogStartMessage() {
		this.UpdateLogHour()
		LogMessage 	:=  ""
		LogMessage 	.= 	"`n####################################################################`n"
		LogMessage	.=  "# Script started at:                                               #`n"
		LogMessage	.=  "# Date: " . this.LogDate . "                                                   #`n"
		LogMessage	.=  "# Hour: " . this.LogHour . "                                                   #`n"
		LogMessage	.=  "####################################################################`n"

		FileAppend(LogMessage, this.LogFile)
	}

	LogEndMessage() {
		this.UpdateLogHour()
		LogMessage  :=  ""
		LogMessage 	.= 	"`n####################################################################`n"
		LogMessage	.=  "# Script ended at:                                                 #`n"
		LogMessage	.=  "# Date: " . this.LogDate . "                                                   #`n"
		LogMessage	.=  "# Hour: " . this.LogHour . "                                                   #`n"
		LogMessage	.=  "####################################################################`n"

		FileAppend(LogMessage, this.LogFile)
	}

	Log(Message, Hour := 1) {
		if (Hour = 1) {
			this.UpdateLogHour()
			Mes := "[" . this.LogHour . "] " . Message . "`n"
		} else {
			Mes := "[ ] " . Message . "`n"
		}
		this.UpdateLoggerMessages(Mes)
		FileAppend(Mes, this.LogFile)
	}

	UpdateLoggerMessages(Message){
		Loop(this.MaxLastMessages - 1)
		{	
			this.LastMessages[A_index] := this.LastMessages[A_index + 1]
		}
		this.LastMessages[10] := Message
		;UpdateGuiLoggerMessages()
	}

	UpdateLogHour() {
		this.LogHour := FormatTime(, "HH:mm:ss")
	}

	CheckForLogFile() {
		global
		if not DirExist(A_WorkingDir . "\Logs")
	  		DirCreate(A_WorkingDir . "\Logs")
	  	this.CheckDeleteOldFiles()	  	
	}

	CheckDeleteOldFiles() {
		global MaxLogs
		FilesArray := Array()
		Loop Files, A_WorkingDir "\Logs\*.txt", "F"
		{
			FilesArray.Push(A_LoopFileFullPath)
		}

		LogsToDelete := FilesArray.Length - MaxLogs

		if (LogsToDelete > 0)
		{
			Loop(LogsToDelete)
			{
				FileDelete(filesArray[A_Index])
			}
		}
	}
}