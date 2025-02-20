; #################################################################################################################################################################################
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

ActivateWindowOrRun(WindowName, RunCmd, RunWorkingDir := "", RunOptions := "")
{
	If (WinExist(WindowName))
		WinActivate
	Else
		Run(RunCmd, RunWorkingDir, RunOptions)
}

ClickWindowRatio(WindowName, RatioX, RatioY, DelayAfter := 0, SimulateMouseMove := false, MouseMoveSpeed := 1, DelayAfterMouseMove := 100)
{
	CoordMode("Mouse", "Window")
	
	WinGetPos(,, &WinWidth, &WinHeight, WindowName)
	FinalX := RatioX * WinWidth
	FinalY := RatioY * WinHeight
	if (SimulateMouseMove)
	{
		MouseMove(FinalX, FinalY, 1)
		Sleep(DelayAfterMouseMove)
	}

	ControlClick("x" FinalX " y" FinalY, WindowName,, "LEFT", 1, "NA",,)

	Sleep(DelayAfter)
	
	CoordMode("Mouse", "Screen")
}

ClickAndDragWindowRatio(WindowName, StartRatioX, StartRatioY, EndRatioX, EndRatioY)
{
	CoordMode("Mouse", "Window")
	CurrentMouseSpeed := A_DefaultMouseSpeed
	SetDefaultMouseSpeed(20)

	WinGetPos(,, &WinWidth, &WinHeight, WindowName)
	StartX := StartRatioX * WinWidth
	StartY := StartRatioY * WinHeight
	EndX := EndRatioX * WinWidth
	EndY := EndRatioY * WinHeight
	Send("{Click " . StartX . " " . StartY . " Down}{Click " . EndX . " " . EndY . " Up}")
	
	CoordMode("Mouse", "Screen")
	SetDefaultMouseSpeed(CurrentMouseSpeed)
}

ClicksRangeWindowRatios(WindowName, StartRatioX, StartRatioY, EndRatioX, EndRatioY, ClicksAmount, ClickDelay := 10, DelayAfter := 0)
{
	CoordMode("Mouse", "Window")

	WinGetPos(,, &WinWidth, &WinHeight, WindowName)
	RatioDiffX := EndRatioX - StartRatioX
	RatioDiffY := EndRatioY - StartRatioY
	DeltaPerClickX := RatioDiffX / ClicksAmount
	DeltaPerClickY := RatioDiffY / ClicksAmount
	
	Loop(ClicksAmount)
	{
		DeltaRatioX := DeltaPerClickX * (A_Index - 1)
		DeltaRatioY := DeltaPerClickY * (A_Index - 1)

		FinalX := (StartRatioX + DeltaRatioX) * WinWidth
		FinalY := (StartRatioY + DeltaRatioY) * WinHeight

		ControlClick("x" FinalX " y" FinalY, WindowName,, "LEFT", 1, "NA",,)
		Sleep(ClickDelay)
	}

	Sleep(DelayAfter)
	
	CoordMode("Mouse", "Screen")
}

CopyCurrentWindowCoordsAsRatios()
{
	CoordMode("Mouse", "Window")

	Title := WinGetTitle("A")
	WinGetPos(&OutX, &OutY, &WinWidth, &WinHeight, Title)
	MouseGetPos(&MouseX, &MouseY)
	RatioX := MouseX / WinWidth
	RatioY := MouseY / WinHeight
	Result := "" . Format("{:.6f}", RatioX) . ", " . Format("{:.6f}", RatioY)
	A_Clipboard := Result
	
	CoordMode("Mouse", "Screen")
}