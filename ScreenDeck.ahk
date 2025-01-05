#Requires AutoHotkey v2.0
SendMode "Input"  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_InitialWorkingDir  ; Ensures a consistent starting directory.

full_command_line := DllCall("GetCommandLine", "str")
If not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    Try
    {
        If (A_IsCompiled)
        {
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        }
        Else
        {
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
        }
    }
    ExitApp
}

#Include "JSON.ahk"
#Include "ImagePut.ahk"
#Include "Classes.ahk"
#Include "Globals.ahk"
#Include CommonFunctions.ahk
#Include GUI.ahk
#Include CoreFunctions.ahk
#Include CustomFunctions.ahk

; Global Timers & Hooks
CallBack := CallbackCreate(MouseHook)
GMousePos["Hook"] := SetWindowsHookEx(14, CallBack)  ; WH_MOUSE_LL := 14 

; OnStart Code
OnStartFunction()
; OnExit Code
OnExit(OnExitFunction)
Return ; End of startup code

; Macros / Hotkeys
#Include Macros-utf8.ahk