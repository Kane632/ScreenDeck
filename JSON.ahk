#Requires AutoHotkey v2.0

; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=100197
#Include ".\lib\Native.ahk"

class JSON {
    static __New() {
        Native.LoadModule('.\lib\ahk-json\' (A_PtrSize * 8) 'bit\ahk-json.dll', ['JSON'])
        this.DefineProp('true', {value: 1})
        this.DefineProp('false', {value: 0})
        this.DefineProp('null', {value: ''})
    }
    static parse(str) => Map() | Array()
    static stringify(obj, space := 0) => ''
}