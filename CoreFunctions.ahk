; #######################################################################################################################################################################
; Functions
; #######################################################################################################################################################################

OnStartFunction()
{
	LoggerStart()
	
	; If the json file does not exist, it will automatically be created inside the CheckJsonFileExists
	If (CheckJsonFileExists())
	{
		ReadJsonConfigFile()
	}

    StartVariables()

	TraySetIcon(A_WorkingDir . "\Images\ScreenDeck.png")

	A_TrayMenu.Add()
	A_TrayMenu.Add("Reset Window size and cords", ResetWindowSizeAndCords)
	A_TrayMenu.Add("Reload Without Saving", ReloadWithoutSaveClicked)
	A_TrayMenu.Add("Exit Without Saving", ExitWithoutSaveClicked)
	
	CreateGUI()
}

ReloadWithoutSaveClicked(ItemName, ItemPos, MyMenu)
{
	global GExitWithoutSave
	GExitWithoutSave := true
	Reload()
}

ExitWithoutSaveClicked(ItemName, ItemPos, MyMenu)
{
	global GExitWithoutSave
	GExitWithoutSave := true
	ExitApp()
}

ResetWindowSizeAndCords(ItemName, ItemPos, MyMenu)
{
	ResetGuiToDefaultPosAndSize()
}

OnExitFunction(ExitReason, ExitCode)
{
	global Logger, GMousePos, GExitWithoutSave

	if (!GExitWithoutSave)
	{
		SaveGuiJsonSizeAndPos()
		SaveJsonConfigFile()
	}

	UnhookWindowsHookEx(GMousePos["Hook"])
	Logger.LogEndMessage()
}

StartVariables()
{
    global
    Logger.Log("StartVariables")
}

CheckJsonFileExists()
{
	global Logger, JsonConfigFilePath
	If FileExist(JsonConfigFilePath)
	{
		Logger.Log("CheckJsonFileExists: File exists. Nothing to do.")
		return true
	}
	Else
	{
		Logger.Log("CheckJsonFileExists: File does not exist, creating it.")
		InitializeJsonConfigFirstTime()
		return false
	}
}

InitializeJsonConfigFirstTime()
{
	global Logger, JsonConfigFilePath, JsonConfigText

	;Create default json config text
	JsonConfigText := "
(
{
	"Base": {},
    "Generated": {},
    "GuiConfig": {
        "DeckBackgroundColor": "1e7e1b",
        "DeckButtonMargin": 6,
        "DeckButtonSize": 95,
        "TopBackgroundColor": "657287"
    },
    "Profiles": {}
}
)"
	
	JsonFile := FileOpen(JsonConfigFilePath, "w")
	if !IsObject(JsonFile)
	{
		Logger.Log("InitializeJsonConfigFirstTime: Could not open the json config file.")
		MsgBox("Can't open " . JsonConfigFilePath . " for writing.")
		Return
	}
	JsonFile.write(JsonConfigText)
	JsonFile.Close()

	Logger.Log("InitializeJsonConfigFirstTime: Created for the first time the config json file.")
}

ReadJsonConfigFile()
{
	global Logger, JsonConfigFilePath, JsonConfig, GBaseConfig, GGuiConfig, GProfiles, GGeneratedConfig

	JsonFile := FileOpen(JsonConfigFilePath, "r")
	if (!IsObject(JsonFile))
	{
		Logger.Log("ReadJsonConfigFile: Could not open the json config file.")
		MsgBox("Can't open " . JsonConfigFilePath . " for reading.")
		Return
	}
	JsonInputStr := JsonFile.read()
	JsonFile.Close()
	JsonConfig := JSON.parse(JsonInputStr)
	
	GBaseConfig := JsonConfig["Base"]
	GGuiConfig := JsonConfig["GuiConfig"]
	GProfiles := JsonConfig["Profiles"]
	if (JsonConfig.Has("Generated"))
	{
		GGeneratedConfig := JsonConfig["Generated"]
	}
	
	Logger.Log("ReadJsonConfigFile: Read the json file.")

	Return
	;Useful info behind this return

	; MsgBox(JsonConfig["Profiles"].Length)

	; for index, element in JsonConfig["Profiles"]
	; {
	; 	MsgBox("Element number " . index . " is " . element["Name"])
	; }	
}

SaveJsonConfigFile()
{
	global Logger, JsonConfigFilePath, JsonConfig, GGeneratedConfig

	JsonConfig["Generated"] := GGeneratedConfig
	JsonOutputStr := JSON.stringify(JsonConfig)

	JsonFile := FileOpen(JsonConfigFilePath, "w")
	if !IsObject(JsonFile)
	{
		Logger.Log("SaveJsonConfigFile: Could not open the json config file.")
		MsgBox("Can't open " . JsonConfigFilePath . " for writing.")
		Return
	}
	JsonFile.write(JsonOutputStr)
	JsonFile.Close()

	Logger.Log("SaveJsonConfigFile: Saved the json file.")
}

; #################################################################################################################################################################################
; Logger Functions
; #################################################################################################################################################################################

LoggerStart()
{
	global Logger

	;Get the singleton instance
	Logger := LoggerObject.GetInstance()

	Logger.Start()
}

; #################################################################################################################################################################################
; Json Functions
; #################################################################################################################################################################################

GetProfileNameList()
{
	global GProfiles

	ProfileNames := []

	For (name, profile in GProfiles)
	{
		ProfileNames.Push(name)
	}

	return ProfileNames
}

GetCurrentProfileJson(&OutJson)
{
	global GProfiles
	if (GetCurrentProfileName() == "")
	{
		return False
	}

	if (GProfiles.Has(GetCurrentProfileName()))
	{
		OutJson := GProfiles[GetCurrentProfileName()]
		return True
	}

	return False
}

GetCurrentProfileButtonJson(Idx, &OutJson)
{
	Json := Map()
	if(!GetCurrentProfileJson(&Json))
	{
		return False
	}

	if (!Json["Actions"].Has("" Idx))
	{
		return False
	}

	OutJson := Json["Actions"]["" Idx]
	return True
}

; #################################################################################################################################################################################
; Mouse
; #################################################################################################################################################################################

;https://www.autohotkey.com/boards/viewtopic.php?t=14733
MouseHook(nCode, wParam, lParam)
{
    global GMousePos

    Critical 1000

    if nCode >= 0
    {
		CordX := NumGet(lParam+0, 0, "Int")
		CordY := NumGet(lParam+0, 4, "Int")
        ;SendTooltip("X " CordX " Y " CordY, 1000)

		if (!GMousePos.Has("X"))
		{
			GMousePos["X"] := CordX
		}

		if (!GMousePos.Has("Y"))
		{
			GMousePos["Y"] := CordY
		}

		; If big mouse offset in one mouse move
		if (Abs(CordX - GMousePos["X"]) + Abs(CordY - GMousePos["Y"]) > 150)
		{
			;MsgBox("X " CordX " Y " CordY " BIG MOUSE OFFSET " AreCordsInsideGui(CordX, CordY))
			if (AreCordsInsideGui(CordX, CordY))
			{
				Temp := CallNextHookEx(nCode, wParam, lParam) ; make sure other hooks in the chain receive this event if we didn't process it
				GMousePos["WaitingToRestore"] := true
				SetTimer(RestoreMouseToPreviousPosition, -15)
				return Temp
			}
		}

		if (!GMousePos.Has("WaitingToRestore") || GMousePos["WaitingToRestore"] != true)
		{
			GMousePos["X"] := CordX
			GMousePos["Y"] := CordY
		}
    }

    return CallNextHookEx(nCode, wParam, lParam) ; make sure other hooks in the chain receive this event if we didn't process it
}

SetWindowsHookEx(idHook, pfn)
{
	return DllCall("SetWindowsHookEx", "int", idHook, "Ptr", pfn, "Ptr", DllCall("GetModuleHandle", "Ptr", 0, "Ptr"), "UInt", 0)
}

CallNextHookEx(nCode, wParam, lParam, hHook := 0)
{
	return DllCall("CallNextHookEx", "Ptr", hHook, "int", nCode, "Ptr", wParam, "Ptr", lParam)
}

UnhookWindowsHookEx(hHook)
{
	return DllCall("UnhookWindowsHookEx", "Ptr", hHook)
}

RestoreMouseToPreviousPosition()
{
	global GMousePos

	if (!GMousePos.Has("X") || !GMousePos.Has("Y"))
	{
		return
	}

	CoordMode("Mouse", "Screen")
	MouseMove(GMousePos["X"], GMousePos["Y"], 0)
	GMousePos["WaitingToRestore"] := false
}