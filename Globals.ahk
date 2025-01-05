﻿; #######################################################################################################################################################################
; Global vars
; #######################################################################################################################################################################

ScriptDir 			            := A_ScriptDir

JsonConfigFilePath              := "ScreenDeck.json"
JsonConfigText                  := ""
JsonConfig                      :=
GBaseConfig                     := Map()
GGeneratedConfig                := Map()
GProfiles                       := Map()
GImgPath                        := A_ScriptDir "\Images\"
GCustomImgPath                  := A_ScriptDir "\CustomImages\"
GMousePos                       := Map()

GExitWithoutSave                := false

; #######################################################################################################################################################################
; Logger Vars
; #######################################################################################################################################################################
Logger 				:= 0
MaxLogs 			:= 15

; #######################################################################################################################################################################
; GUI Vars
; #######################################################################################################################################################################

;GUI vars
GGui := {}
GGuiElems := Map()
GGuiConfig := Map()
GDeckButtonImgHandle := ""

GMaxCols := 25
GMaxRows := 15