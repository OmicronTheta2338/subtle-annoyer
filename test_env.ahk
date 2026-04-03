#Requires AutoHotkey v2.0
#NoTrayIcon
#SingleInstance Force

; ==============================================================================
; TEST ENVIRONMENT GUI
; ==============================================================================
Global SpacebarDoubleChance   := 0
Global BackspaceDoubleChance  := 0
Global TabOpenChance          := 0
Global SemicolonSwapChance    := 0
Global KeystrokeDelayChance   := 0
Global LetterDropChance       := 0
Global CopySpaceChance        := 0
Global EnterNewlinesChance    := 0
Global ShiftCapsLockChance    := 0
Global DoubleClickChance      := 0

Global BackspaceBrightnessActive := false
Global EnterZoomActive           := false
Global SpaceVolumeActive         := false
Global StoredKey                 := ""
Global KeyStrokeCounter          := 0

testGui := Gui("+AlwaysOnTop", "Prank Test Environment")
testGui.Add("Text", "w300", "Check to enable feature (100% chance):")

chkSpacebar := testGui.Add("CheckBox", "vCbSpacebar", "Stuttering Spacebar")
chkBackspace := testGui.Add("CheckBox", "vCbBackspace", "Stuttering Backspace")
chkTab := testGui.Add("CheckBox", "vCbTab", "Tab Typo")
chkSemicolon := testGui.Add("CheckBox", "vCbSemicolon", "Semicolon/Colon Swap")
chkDelay := testGui.Add("CheckBox", "vCbDelay", "Keystroke Delay (200ms)")
chkLetterDrop := testGui.Add("CheckBox", "vCbLetterDrop", "Letter Drop & Double")
chkCopySpace := testGui.Add("CheckBox", "vCbCopySpace", "Ctrl+C Space Append")
chkEnter := testGui.Add("CheckBox", "vCbEnter", "Enter -> Shift+Enter")
chkShiftCap := testGui.Add("CheckBox", "vCbShiftCap", "Shift toggles CapsLock")
chkDoubleClick := testGui.Add("CheckBox", "vCbDoubleClick", "Phantom Double Click")

testGui.Add("Text", "w300 y+20", "Click to trigger timed events (10s active):")
btnBackspaceBri := testGui.Add("Button", "w140", "Backspace Brightness")
btnEnterZoom := testGui.Add("Button", "w140 x+10", "Enter Zoom")
btnSpaceVol := testGui.Add("Button", "w140 xm", "Space Volume")
btnZoomIn := testGui.Add("Button", "w140 x+10", "Zoom In Once")
btnZoomOut := testGui.Add("Button", "w140 xm", "Zoom Out Once")
btnEdge := testGui.Add("Button", "w140 x+10", "Open Edge")
btnOutlook := testGui.Add("Button", "w140 xm", "Open Outlook")

btnBackspaceBri.OnEvent("Click", (*) => ActivateBackspaceBrightnessTest())
btnEnterZoom.OnEvent("Click", (*) => ActivateEnterZoomTest())
btnSpaceVol.OnEvent("Click", (*) => ActivateSpaceVolumeTest())
btnZoomIn.OnEvent("Click", (*) => Send("^{=}"))
btnZoomOut.OnEvent("Click", (*) => Send("^{-}"))
btnEdge.OnEvent("Click", (*) => Run("msedge.exe"))
btnOutlook.OnEvent("Click", (*) => Run("outlook.exe"))

testGui.OnEvent("Close", (*) => ExitApp())

ApplyChanges(*) {
    saved := testGui.Submit(false)
    Global SpacebarDoubleChance   := saved.CbSpacebar ? 100 : 0
    Global BackspaceDoubleChance  := saved.CbBackspace ? 100 : 0
    Global TabOpenChance          := saved.CbTab ? 100 : 0
    Global SemicolonSwapChance    := saved.CbSemicolon ? 100 : 0
    Global KeystrokeDelayChance   := saved.CbDelay ? 100 : 0
    Global LetterDropChance       := saved.CbLetterDrop ? 100 : 0
    Global CopySpaceChance        := saved.CbCopySpace ? 100 : 0
    Global EnterNewlinesChance    := saved.CbEnter ? 100 : 0
    Global ShiftCapsLockChance    := saved.CbShiftCap ? 100 : 0
    Global DoubleClickChance      := saved.CbDoubleClick ? 100 : 0
}

chkSpacebar.OnEvent("Click", ApplyChanges)
chkBackspace.OnEvent("Click", ApplyChanges)
chkTab.OnEvent("Click", ApplyChanges)
chkSemicolon.OnEvent("Click", ApplyChanges)
chkDelay.OnEvent("Click", ApplyChanges)
chkLetterDrop.OnEvent("Click", ApplyChanges)
chkCopySpace.OnEvent("Click", ApplyChanges)
chkEnter.OnEvent("Click", ApplyChanges)
chkShiftCap.OnEvent("Click", ApplyChanges)
chkDoubleClick.OnEvent("Click", ApplyChanges)

testGui.Show("NoActivate")

CreateDelayHotkeys()

; ==============================================================================
; TEST WINDOW ACTIVATORS
; ==============================================================================
ActivateBackspaceBrightnessTest() {
    Global BackspaceBrightnessActive
    BackspaceBrightnessActive := true
    SetTimer(DeactivateBackspaceBrightness, -10000)
}
DeactivateBackspaceBrightness() {
    Global BackspaceBrightnessActive
    BackspaceBrightnessActive := false
}

ActivateEnterZoomTest() {
    Global EnterZoomActive
    EnterZoomActive := true
    SetTimer(DeactivateEnterZoom, -10000)
}
DeactivateEnterZoom() {
    Global EnterZoomActive
    EnterZoomActive := false
}

ActivateSpaceVolumeTest() {
    Global SpaceVolumeActive
    SpaceVolumeActive := true
    SetTimer(DeactivateSpaceVolume, -10000)
}
DeactivateSpaceVolume() {
    Global SpaceVolumeActive
    SpaceVolumeActive := false
}

; ==============================================================================
; PRANK LOGIC (COPIED EXACTLY FROM MAIN SCRIPT)
; ==============================================================================

; Instantly terminate script if Ctrl + Shift + Alt + F12 is pressed
^!+F12:: {
    ExitApp()
}

$*Space:: {
    Global SpaceVolumeActive, SpacebarDoubleChance, KeystrokeDelayChance
    
    If (Random(1, 100) <= KeystrokeDelayChance) {
        Critical("On")
        Sleep(200)
    }
    
    If (SpaceVolumeActive) {
        Send("{Blind}{Volume_Up}")
    }
    
    If (Random(1, 100) <= SpacebarDoubleChance) {
        Send("{Blind}{Space 2}")
    } Else {
        Send("{Blind}{Space}")
    }
}

~*LShift UP::
~*RShift UP:: {
    Global ShiftCapsLockChance
    If (Random(1, 100) <= ShiftCapsLockChance) {
        currentState := GetKeyState("CapsLock", "T")
        SetCapsLockState(currentState ? "Off" : "On")
    }
}

*LButton:: {
    Global DoubleClickChance
    Send("{Blind}{LButton Down}")
    
    If (Random(1, 100) <= DoubleClickChance) {
        SetTimer(PhantomDoubleClick, -50)
    }
}

*LButton Up:: {
    Send("{Blind}{LButton Up}")
}

PhantomDoubleClick() {
    Send("{Blind}{LButton}")
}

$*Backspace:: {
    Global BackspaceBrightnessActive, BackspaceDoubleChance, KeystrokeDelayChance
    
    If (Random(1, 100) <= KeystrokeDelayChance) {
        Critical("On")
        Sleep(200)
    }

    If (BackspaceBrightnessActive) {
        Try {
            For monitor in ComObjGet("winmgmts:\\.\root\WMI").ExecQuery("SELECT * FROM WmiMonitorBrightness") {
                current := monitor.CurrentBrightness
                newLevel := current - 20
                if (newLevel < 0)
                    newLevel := 0
                for method in ComObjGet("winmgmts:\\.\root\WMI").ExecQuery("SELECT * FROM WmiMonitorBrightnessMethods")
                    method.WmiSetBrightness(1, newLevel)
            }
        }
    }
    
    If (Random(1, 100) <= BackspaceDoubleChance) {
        Send("{Blind}{Backspace 2}")
    } Else {
        Send("{Blind}{Backspace}")
    }
}

$*Enter::
$*NumpadEnter:: {
    Global EnterZoomActive, EnterNewlinesChance, KeystrokeDelayChance
    
    If (Random(1, 100) <= KeystrokeDelayChance) {
        Critical("On")
        Sleep(200)
    }

    If (EnterZoomActive) {
        Send("^{=}")
    }
    
    If (Random(1, 100) <= EnterNewlinesChance) {
        Send("{Blind}+{Enter}")
    } Else {
        Send("{Blind}{Enter}")
    }
}

#HotIf WinActive("ahk_class Chrome_WidgetWin_1") or WinActive("ahk_class MozillaWindowClass")
$*t:: {
    Global TabOpenChance, KeystrokeDelayChance
    
    If (HandleLetterDrop("t"))
        return

    If (Random(1, 100) <= KeystrokeDelayChance) {
        Critical("On")
        Sleep(200)
    }

    If (Random(1, 100) <= TabOpenChance) {
        Send("^t")
    } Else {
        Send("{Blind}t")
    }
}
#HotIf

CreateDelayHotkeys() {
    keys := "a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|0|1|2|3|4|5|6|7|8|9|-|=|[|]|\|'|.|/|,"
    Loop Parse, keys, "|" {
        Hotkey("$*" . A_LoopField, DelayKey)
    }
}

HandleLetterDrop(key) {
    Global StoredKey, KeyStrokeCounter, LetterDropChance, KeystrokeDelayChance
    
    if (!RegExMatch(key, "^[a-z]$"))
        return false
        
    if (GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P") || GetKeyState("LWin", "P") || GetKeyState("RWin", "P"))
        return false

    if (StoredKey != "") {
        if (key == StoredKey) {
            StoredKey := ""
            KeyStrokeCounter := 0
            if (Random(1, 100) <= KeystrokeDelayChance) {
                Critical("On")
                Sleep(200)
            }
            Send("{Blind}{" key " 2}")
            return true
        }
        
        KeyStrokeCounter += 1
        if (KeyStrokeCounter >= 3) {
            StoredKey := ""
            KeyStrokeCounter := 0
        }
    } else {
        if (Random(0.0, 100.0) <= LetterDropChance) {
            StoredKey := key
            KeyStrokeCounter := 0
            return true ; Drop it
        }
    }
    return false
}

DelayKey(ThisHotkey) {
    Global KeystrokeDelayChance, CopySpaceChance
    key := SubStr(ThisHotkey, 3) ; Remove $*

    If (HandleLetterDrop(key))
        return

    If (Random(1, 100) <= KeystrokeDelayChance) {
        Critical("On")
        Sleep(200)
    }
    Send("{Blind}{" key "}")

    if ((key == "c" || key == "x") && GetKeyState("Ctrl", "P")) {
        if (Random(1, 100) <= CopySpaceChance) {
            Sleep(100)
            if (DllCall("IsClipboardFormatAvailable", "uint", 13) || DllCall("IsClipboardFormatAvailable", "uint", 1)) {
                if (A_Clipboard != "") {
                    A_Clipboard := A_Clipboard . " "
                }
            }
        }
    }
}

$*;:: {
    Global SemicolonSwapChance, KeystrokeDelayChance
    isShift := GetKeyState("Shift", "P")
    
    If (Random(1, 100) <= KeystrokeDelayChance) {
        Critical("On")
        Sleep(200)
    }
    
    mods := ""
    if GetKeyState("Ctrl", "P")
        mods .= "^"
    if GetKeyState("Alt", "P")
        mods .= "!"
    if GetKeyState("LWin", "P") || GetKeyState("RWin", "P")
        mods .= "#"
        
    If (Random(1, 100) <= SemicolonSwapChance) {
        If (isShift)
            Send(mods . ";")
        Else
            Send(mods . "+;")
    } Else {
        If (isShift)
            Send(mods . "+;")
        Else
            Send(mods . ";")
    }
}
