; #################################################################################################################################################################################
; GUI2 Class
; #################################################################################################################################################################################
class Gui2 extends Gui {
	; Can only be scaled by integers
    AddImage(Image, Options, &W, &H, ScaleX := 1, ScaleY := 1, Text := "") {
        static WS_CHILD                  := 0x40000000   ; Creates a child window.
        static WS_VISIBLE                := 0x10000000   ; Show on creation.
        static WS_DISABLED               :=  0x8000000   ; Disables Left Click to drag.
        ImagePut.gdiplusStartup()
        pBitmap := ImagePutBitmap(Image)
        DllCall("gdiplus\GdipGetImageWidth", "ptr", pBitmap, "uint*", &W:=0)
        DllCall("gdiplus\GdipGetImageHeight", "ptr", pBitmap, "uint*", &H:=0)
        Display := this.Add("Text", Options " w" W * ScaleX " h" H * ScaleY, Text)
        Display.imagehwnd := ImagePut.show(pBitmap,, [0, 0, W * ScaleX, H * ScaleY], WS_CHILD | WS_VISIBLE | WS_DISABLED,, Display.hwnd)
        ImagePut.gdiplusShutdown()
        return Display
    }
}

; #################################################################################################################################################################################
; GUI Functions
; #################################################################################################################################################################################
; GUI Bars https://autohotkey.com/boards/viewtopic.php?t=4662

CreateGUI()
{
	global Logger, GGui, GDeckButtonImgHandle
	Logger.Log("CreateGUI--Start")

	X := 0
	Y := 0
	W := 1024
	H := 600
	if (!LoadGuiJsonSizeAndPos(&X, &Y, &W, &H))
	{
		MonitorGetWorkArea(MonitorGetPrimary(), &Left, &Top, &Right, &Bottom)
		X := (Right - Left) / 2 + Left - W / 2
		Y := (Bottom - Top) / 2 + Top - H / 2
	}

	GDeckButtonImgHandle := LoadPicture(GImgPath "SquareBtn.png")

	GGui := Gui("+Resize +MinSize800x400 +E0x08000000", "ScreenDeck")
	GGui.BackColor := "657287"
	
	; Show the UI first so we can retrieve the client position and size to configure it.
	GGui.Show("X" X " Y" Y " W" W " H" H " NoActivate")

	GuiCreateTopMenu()
	GuiCreateDeckGui()
	GuiCacheSizeAndCords()
	
	GGui.OnEvent("Size", GuiSize)
	GGui.OnEvent("Close", GuiClose)
	GGui.OnEvent("Escape", GuiClose)
}

ResetGuiToDefaultPosAndSize()
{
	global GGui
	W := 1024
	H := 600

	MonitorGetWorkArea(MonitorGetPrimary(), &Left, &Top, &Right, &Bottom)
	X := (Right - Left) / 2 + Left - W / 2
	Y := (Bottom - Top) / 2 + Top - H / 2

	GGui.Move(X, Y, W, H)
}

GuiCreateTopMenu()
{
	global Logger, GGui, GGuiElems, GGuiConfig, GImgPath

	GGuiElems["TopMenuGui"] := Gui("+AlwaysOnTop -Caption +ToolWindow +Parent" GGui.Hwnd, "ScreenDeckTopMenu")
	GGuiElems["TopMenuGui"].BackColor := GGuiConfig.Has("TopBackgroundColor") ? GGuiConfig["TopBackgroundColor"] : "657287"
	
	GGui.GetClientPos(&DummyX, &DummyY, &W, &H)
	TopGuiHeight := 34
	if (GGuiConfig.Has("ShowTopBar") && GGuiConfig["ShowTopBar"])
	{
		GGuiElems["TopMenuGui"].Show("X0 Y0 W" W " H" TopGuiHeight)
	}

	; Create profiles DDL and select the first one ifavailable, if not disable it.
	ProfileNames := GetProfileNameList()
	GGuiElems["TopProfileDropdown"] := GGuiElems["TopMenuGui"].AddDropDownList("vTopProfileChoice Choose1 x5 y6 w150", ProfileNames)
	GGuiElems["TopProfileDropdown"].Enabled := ProfileNames.Length >= 1
	GGuiElems["TopProfileDropdown"].OnEvent("Change", GuiProfileSelected)

	; Finally create a visual separator
	GGuiElems["TopSeparator"] := GGuiElems["TopMenuGui"].AddText("x1 y" TopGuiHeight - 2 " w1 h3 +0x10")

	; Call ResizeTopMenu so that the right buttons are placed accordingly
	ResizeTopMenu()
}

ResizeTopMenu()
{
	global Logger, GGui, GGuiElems, GGuiConfig

	if (!GGuiConfig.Has("ShowTopBar") || !GGuiConfig["ShowTopBar"])
	{
		return
	}

	; Grab client window size
	GGui.GetClientPos(&DummyX, &DummyY, &W, &H)

	GGuiElems["TopSeparator"].Move(, , W)
}

GuiDestroyDeckGui()
{
	global Logger, GGuiElems, GMaxRows, GMaxCols

	; Clear old deck buttons refs
	if (GGuiElems.Has("DeckGuiButtons"))
	{
		i := 0
		j := 0
		while (i < GMaxRows)
		{
			while (j < GMaxCols)
			{
				if (GGuiElems["DeckGuiButtons"].Has("X" i "J" j) && GGuiElems["DeckGuiButtons"]["X" i "J" j].Has("Gui"))
				{
					GGuiElems["DeckGuiButtons"]["X" i "J" j]["Gui"].Destroy()
					GGuiElems["DeckGuiButtons"].Delete("X" i "J" j)
				}
				j++
			}
			i++
		}
		GGuiElems.Delete("DeckGuiButtons")
	}

	if (GGuiElems.Has("DeckGuiCentered"))
	{
		GGuiElems["DeckGuiCentered"].Destroy()
		GGuiElems.Delete("DeckGuiCentered")
	}

	if (GGuiElems.Has("DeckGui"))
	{
		GGuiElems["DeckGui"].Destroy()
		GGuiElems.Delete("DeckGui")
	}
}

GuiCreateDeckGui()
{
	global Logger, GGui, GGuiElems, GGuiConfig, GGeneratedConfig, GMaxRows, GMaxCols

	GuiDestroyDeckGui()
	
	GGuiElems["DeckGui"] := Gui("+AlwaysOnTop -Caption +ToolWindow +Parent" GGui.Hwnd, "ScreenDeckButtons")
	GGuiElems["DeckGui"].BackColor := GetCurrentDeckColor()
	
	GGui.GetClientPos(&DummyX, &DummyY, &W, &H)
	DeckHeight := H
	Y := 0
	
	if (GGuiConfig.Has("ShowTopBar") && GGuiConfig["ShowTopBar"])
	{
		GGuiElems["TopSeparator"].GetPos(&DummyX, &TopCtrlY, &CtrlW, &DummyH)
		DeckHeight := H - TopCtrlY
		Y := TopCtrlY
	}

	GGuiElems["DeckGui"].Show("X0 Y" Y " W" W " H" DeckHeight)

	DeckBtnSize := GetCurrentDeckButtonSize()
	DeckBtnMargin := GetCurrentDeckButtonMargin()
	DeckBtnAndMargin := DeckBtnSize + DeckBtnMargin
	RowsNoClamp := Integer(DeckHeight / (DeckBtnAndMargin))
	ColsNoClamp := Integer(W / (DeckBtnAndMargin))
	GGeneratedConfig["Rows"] := Clamp(RowsNoClamp, 0, GMaxRows)
	GGeneratedConfig["Cols"] := Clamp(ColsNoClamp, 0, GMaxCols)

	GGuiElems["DeckGuiCentered"] := Gui("+AlwaysOnTop -Caption +ToolWindow +Parent" GGuiElems["DeckGui"].Hwnd, "ScreenDeckButtonsCentered")
	GGuiElems["DeckGuiCentered"].BackColor := GetCurrentDeckColor()
	GGuiElems["DeckGuiCentered"].Show("W" GGeneratedConfig["Cols"] * DeckBtnAndMargin " H" GGeneratedConfig["Rows"] * DeckBtnAndMargin)

	GuiCreateDeckButtons()
}

GuiCreateDeckButtons()
{
	global Logger, GGuiElems, GGeneratedConfig

	if (!GGuiElems.Has("DeckGuiButtons"))
	{
		GGuiElems["DeckGuiButtons"] := Map()
	}

	i := 0
	while (i < GGeneratedConfig["Rows"])
	{
		j := 0
		while (j < GGeneratedConfig["Cols"])
		{
			GGuiElems["DeckGuiButtons"]["X" i "J" j] := GuiCreateDeckButton(i, j)
			j++
		}
		i++
	}
}

GuiCreateDeckButton(Row, Col)
{
	global Logger, GGuiElems, GGuiConfig, GGeneratedConfig
	
	DeckBtnSize := GetCurrentDeckButtonSize()
	DeckBtnMargin := GetCurrentDeckButtonMargin()
	BtnAndMargin := DeckBtnSize + DeckBtnMargin
	GuiX := BtnAndMargin * Col
	GuiY := BtnAndMargin * Row

	DeckButton := Map()
	DeckButton["Gui"] := Gui2("+AlwaysOnTop -Caption +ToolWindow +Parent" GGuiElems["DeckGuiCentered"].Hwnd, "ScreenDeckButtonX" Row "J" Col)
	;DeckButton["Gui"].BackColor := Format("{:06X}", Random(0, 16777215)) ; RandomColor for debug
	DeckButton["Gui"].BackColor := "FFFFFE"
	WinSetTransColor("FFFFFE 255", "ahk_id " DeckButton["Gui"].Hwnd)
	
	BtnStart := DeckBtnMargin / 2
	DeckButton["Btn"] := DeckButton["Gui"].AddPicture("x" BtnStart " y" BtnStart " w" DeckBtnSize " h" DeckBtnSize " +BackgroundTrans", "HBITMAP:*" GDeckButtonImgHandle)
	DeckButton["Btn"].OnEvent("Click", GuiDeckButtonClicked)
	DeckButton["Btn"].OnEvent("DoubleClick", GuiDeckButtonDoubleClick)
	
	DeckButton["Btn"].Row := Row
	DeckButton["Btn"].Col := Col
	Idx := Row * GGeneratedConfig["Cols"] + Col
	DeckButton["Btn"].Idx := Idx
	DeckButton["Btn"].CustomFunction := ""
	DeckButton["Btn"].CustomDoubleClickFunction := ""
	
	; Creating a second button on top of the first would not work if wanted to be clicked. The first button created, or the one that is drawn first (the one at the back) is the one that receives the click event
	if (GetCurrentProfileName() != "")
	{
		Json := Map()
		if (GetCurrentProfileButtonJson(Idx, &Json))
		{
			if (Json.Has("Action") && Json["Action"] != "")
			{
				DeckButton["Btn"].CustomFunction := Json["Action"]
			}

			if (Json.Has("DoubleClickAction") && Json["DoubleClickAction"] != "")
			{
				DeckButton["Btn"].CustomDoubleClickFunction := Json["DoubleClickAction"]
			}
			
			if (Json.Has("Profile") && Json["Profile"] != "")
			{
				DeckButton["Btn"].Profile := Json["Profile"]
			}

			if (Json.Has("Icon"))
			{
				IconScale := Json.Has("IconScale") && IsNumber(Json["IconScale"]) ? Clamp(Json["IconScale"], 0.1, 1.0) : 0.65
				IconVerticalAlignment := Json.Has("IconVerticalAlignment") && IsNumber(Json["IconVerticalAlignment"]) ? Json["IconVerticalAlignment"] : 0.5

				if (IsGif(Json["Icon"]))
				{
					DeckButton["Icon"] := DeckButton["Gui"].AddImage(GCustomImgPath Json["Icon"], "x0 y0 +BackgroundTrans", &W, &H)
					IconStartX := (BtnAndMargin / 2) - W / 2
					IconStartY := BtnAndMargin * IconVerticalAlignment - H / 2
					DeckButton["Icon"].Move(IconStartX, IconStartY)
				}
				else
				{
					IconSize := DeckBtnSize * IconScale
					IconStartX := (BtnAndMargin / 2) - IconSize / 2
					IconStartY := BtnAndMargin * IconVerticalAlignment - IconSize / 2

					DeckButton["Icon"] := DeckButton["Gui"].AddPicture("x" IconStartX " y" IconStartY " w" IconSize " h" IconSize " +BackgroundTrans", GCustomImgPath Json["Icon"])
					DeckButton["Icon"].Value := GCustomImgPath Json["Icon"]
				}
			}

			if (Json.Has("Text"))
			{
				TextSize := Json.Has("TextSize") ? Json["TextSize"] : "15"
				TextColor := Json.Has("TextColor") ? Json["TextColor"] : "Green"
				TextWeight := Json.Has("TextWeight") && IsInteger(Json["TextWeight"]) ? Clamp(Json["TextWeight"], 1, 1000) : 400
				TextVerticalAlignment := Json.Has("TextVerticalAlignment") && IsNumber(Json["TextVerticalAlignment"]) ? Json["TextVerticalAlignment"] : 0.5

				DeckButton["Gui"].SetFont("S" TextSize " W" TextWeight " Q4", "")
				DeckButton["Text"] := DeckButton["Gui"].AddText("c" TextColor " Center +BackgroundTrans", Json["Text"])
				DeckButton["Text"].GetPos(&X, &Y, &W, &H)
				TextCenterX := BtnAndMargin / 2 - W / 2
				TextCenterY := BtnAndMargin * TextVerticalAlignment - H / 2
				DeckButton["Text"].Move(TextCenterX, TextCenterY)
			}
		}	
	}	
	
	DeckButton["Gui"].Show("X" GuiX "Y" GuiY " W" BtnAndMargin " H" BtnAndMargin)

	return DeckButton
}

LoadGuiJsonSizeAndPos(&X, &Y, &W, &H)
{
	global Logger, GGeneratedConfig
	
	if (!GGeneratedConfig.Has("X"))
	{
		Logger.Log("LoadGuiJsonSizeAndPos: Missing X in json file.")
		return false
	}
	X := GGeneratedConfig["X"]

	if (!GGeneratedConfig.Has("Y"))
	{
		Logger.Log("LoadGuiJsonSizeAndPos: Missing Y in json file.")
		return false
	}
	Y := GGeneratedConfig["Y"]

	if (!GGeneratedConfig.Has("W"))
	{
		Logger.Log("LoadGuiJsonSizeAndPos: Missing W in json file.")
		return false
	}
	W := GGeneratedConfig["W"]

	if (!GGeneratedConfig.Has("H"))
	{
		Logger.Log("LoadGuiJsonSizeAndPos: Missing H in json file.")
		return false
	}
	H := GGeneratedConfig["H"]

	return true
}

LoadGuiJsonRowAndCol(&Row, &Col)
{
	global Logger, GGeneratedConfig
	
	if (!GGeneratedConfig.Has("Row"))
	{
		Logger.Log("LoadGuiJsonRowAndCol: Missing Row in json file.")
		return false
	}
	Row := GGeneratedConfig["Row"]

	if (!GGeneratedConfig.Has("Col"))
	{
		Logger.Log("LoadGuiJsonRowAndCol: Missing Col in json file.")
		return false
	}
	Col := GGeneratedConfig["Col"]

	return true
}

SaveGuiJsonSizeAndPos()
{
	global Logger, GGeneratedConfig, GGui

	GGui.GetPos(&X, &Y, &W, &H)
	GGui.GetClientPos(&DummyX, &DummyY, &W, &H)
	Logger.Log("SaveGuiJsonSizeAndPos: Saving to json file. X: " X " Y: " Y " W: " W " H: " H)

	GGeneratedConfig["X"] := X
	GGeneratedConfig["Y"] := Y
	GGeneratedConfig["W"] := W
	GGeneratedConfig["H"] := H
}

GuiSize(GuiObj, MinMax, Width, Height)
{
	global Logger, GGui

	SetTimer(GuiResize, -50)
}

GuiResize()
{
	ResizeTopMenu()
	GuiCreateDeckGui() ; We need to recreate it in case we need to delete extra deck buttons
	GuiCacheSizeAndCords()
}

OnGuiSizeTimer()
{
	GuiResize()
}

GuiCacheSizeAndCords()
{
	global GGui, GGeneratedConfig

	WinGetPos(&OutX, &OutY, &OutWidth, &OutHeight, "ahk_id " GGui.Hwnd)
	GGeneratedConfig["Left"] := OutX
	GGeneratedConfig["Right"] := OutX + OutWidth
	GGeneratedConfig["Top"] := OutY
	GGeneratedConfig["Bottom"] := OutY + OutHeight
}

GuiClose(GuiObj)
{
	ExitApp()
}

; #################################################################################################################################################################################
; TOP Control events
; #################################################################################################################################################################################

GuiProfileSelected(GuiCtrlObj, Info)
{
	global Logger
	Logger.Log("GuiProfileSelected: Selected profile: " GuiCtrlObj.Text)
	GuiCreateDeckGui()
}

GuiDeckButtonClicked(GuiCtrlObj, Info)
{
	global Logger
	Logger.Log("GuiDeckButtonClicked")

	if (GuiCtrlObj.HasProp("CustomFunction") && GuiCtrlObj.CustomFunction != "")
	{
		%GuiCtrlObj.CustomFunction%()
	}
	
	if (GuiCtrlObj.HasProp("Profile") && GuiCtrlObj.Profile != "")
	{
		GGuiElems["TopProfileDropdown"].Text := GuiCtrlObj.Profile
		GuiProfileSelected(GGuiElems["TopProfileDropdown"], "")
	}
}

GuiDeckButtonDoubleClick(GuiCtrlObj, Info)
{
	global Logger
	Logger.Log("GuiDeckButtonDoubleClick")

	if (GuiCtrlObj.HasProp("CustomDoubleClickFunction") && GuiCtrlObj.CustomDoubleClickFunction != "")
	{
		%GuiCtrlObj.CustomDoubleClickFunction%()
	}

	GuiDeckButtonClicked(GuiCtrlObj, Info)
}

; #################################################################################################################################################################################
; Helpers
; #################################################################################################################################################################################

GetCurrentProfileName()
{
	global GGuiElems
	return GGuiElems["TopProfileDropdown"].Text
}

AreCordsInsideGui(CordX, CordY)
{
	global GGeneratedConfig
	return GGeneratedConfig["Left"] < CordX && GGeneratedConfig["Right"] > CordX && GGeneratedConfig["Top"] < CordY && GGeneratedConfig["Bottom"] > CordY
}

GetCurrentDeckColor()
{
	global GGuiConfig, GProfiles

	CurrentProfile := GetCurrentProfileName()
	Color := GGuiConfig.Has("DeckBackgroundColor") ? GGuiConfig["DeckBackgroundColor"] : "1e7e1b"
	if (CurrentProfile == "")
	{
		return Color
	}
	
	if (GProfiles.Has(CurrentProfile) && GProfiles[CurrentProfile].Has("DeckBackgroundColor"))
	{
		Color := GProfiles[CurrentProfile]["DeckBackgroundColor"]
	}

	return Color
}

GetCurrentDeckButtonSize()
{
	global GGuiConfig, GProfiles

	CurrentProfile := GetCurrentProfileName()
	DeckButtonSize := GGuiConfig.Has("DeckButtonSize") ? GGuiConfig["DeckButtonSize"] : 95
	if (CurrentProfile == "")
	{
		return DeckButtonSize
	}
	
	if (GProfiles.Has(CurrentProfile) && GProfiles[CurrentProfile].Has("DeckButtonSize"))
	{
		DeckButtonSize := GProfiles[CurrentProfile]["DeckButtonSize"]
	}

	return DeckButtonSize
}

GetCurrentDeckButtonMargin()
{
	global GGuiConfig, GProfiles

	CurrentProfile := GetCurrentProfileName()
	DeckButtonMargin := GGuiConfig.Has("DeckButtonMargin") ? GGuiConfig["DeckButtonMargin"] : 6
	if (CurrentProfile == "")
	{
		return DeckButtonMargin
	}
	
	if (GProfiles.Has(CurrentProfile) && GProfiles[CurrentProfile].Has("DeckButtonMargin"))
	{
		DeckButtonMargin := GProfiles[CurrentProfile]["DeckButtonMargin"]
	}

	return DeckButtonMargin
}

IsGif(FileName)
{
	StrParts := StrSplit(FileName, '.')

	return StrParts.Length != 0 && StrParts[StrParts.Length] == "gif"
}