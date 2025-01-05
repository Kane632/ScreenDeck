﻿; #################################################################################################################################################################################
; Tooltip
; #################################################################################################################################################################################

SendTooltip(msg, timeout := 500)
{
	Tooltip(msg)
	SetTimer(RemoveTooltip, -timeout)
}

RemoveTooltip()
{
	Tooltip()
}

SendTrayTip(msg, title := "", options := "", timeout := 500)
{
	TrayTip(msg, title, options)
	SetTimer(RemoveTrayTip, -timeout)
}

RemoveTrayTip()
{
	TrayTip()
}

Clamp(N, Low, High)
{
	return Min(Max(N, Low), High)
}

SendClipboard(TextToSend, SleepBefore := 0, SleepAfter := 0)
{
    global Logger

	Sleep(SleepBefore)

    Logger.Log("SendClipboard--Start: Text to send: " . TextToSend)
    OldClipboard := ClipboardAll()
    Sleep(75)
    A_Clipboard := TextToSend
    Sleep(75)
    SendInput("{CtrlDown}v{CtrlUp}}")
    Sleep(75)
    A_Clipboard := OldClipboard

	Sleep(SleepAfter)
}

;Returns the last N lines of a string (1 for the last, 2 for the second last, 3 for the third last... etc)
StrGetTailf(&_Str, n := 1) {
    Return SubStr(_Str, InStr(_Str, "`n", False, -1, -n) + 1)
}

ExecutePowershellCommand(Command, ClipboardTimeout := 5)
{
	global Logger

	TempClipboard := A_Clipboard
	Command .= " | clip"
	A_Clipboard := ""
	Logger.Log("ExecutePowershellCommand: Executing the following command: " Command)
	RunWait("powershell.exe -Command &{" Command "}",, "Min")

	if !ClipWait(ClipboardTimeout)
	{
		A_Clipboard := TempClipboard
		Logger.LogMsgBox("ExecutePowershellCommand: Failure, An error occurred while waiting for the clipboard.")
		return ""
	}
	else
	{
		Output := A_Clipboard
		A_Clipboard := TempClipboard
		Logger.Log("ExecutePowershellCommand: Success, Command: " Command " Output: " Output)
		Logger.Log("ExecutePowershellCommand: End")
		return Output
	}
}

ExecuteCommandPromptCommand(Command, ClipboardTimeout := 5, Minimized := true)
{
	global Logger

	TempClipboard := A_Clipboard
	Command .= " | clip"
	A_Clipboard := ""
	Logger.Log("ExecuteCommandPromptCommand: Executing the following command: " Command)
	RunWait(A_ComSpec Command,, Minimized ? "Min" : "Max")

	if !ClipWait(ClipboardTimeout)
	{
		A_Clipboard := TempClipboard
		Logger.LogMsgBox("ExecuteCommandPromptCommand: Failure, An error occurred while waiting for the clipboard.")
		return ""
	}
	else
	{
		Output := A_Clipboard
		A_Clipboard := TempClipboard
		Logger.Log("ExecuteCommandPromptCommand: Success, Command: " Command " Output: " Output)
		Logger.Log("ExecuteCommandPromptCommand: End")
		return Output
	}
}