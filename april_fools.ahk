#Requires AutoHotkey v2.0
#NoTrayIcon
#SingleInstance Force

; ==============================================================================
; TUNABLE VARIABLES
; ==============================================================================

; --- The Stuttering Spacebar ---
; Percentage chance (1-100) to output two spaces instead of one
Global SpacebarDoubleChance   := 3

; --- The Stuttering Backspace ---
; Percentage chance (1-100) to output two backspaces instead of one
Global BackspaceDoubleChance  := 3

; --- The Tab Typo ---
; Percentage chance (1-100) to open a new tab instead of typing 't'
Global TabOpenChance          := 2

; --- The Enter Prank ---
; Percentage chance (1-100) that Enter becomes Shift+Enter
Global EnterNewlinesChance    := 5

; --- The Random App Openers ---
; Times in minutes for app openers
Global EdgeTimerMinMinutes    := 180
Global EdgeTimerMaxMinutes    := 300
Global OutlookTimerMinMinutes := 600
Global OutlookTimerMaxMinutes := 600

; --- The Slippery Shift ---
; Percentage chance (1-100) to toggle CapsLock on Shift release
Global ShiftCapsLockChance    := 1

; --- The Gaslight Zoom ---
; Minimum and Maximum minutes between background zoom events
Global ZoomTimerMinMinutes    := 60
Global ZoomTimerMaxMinutes    := 90

; --- The Phantom Mouse Clicks ---
; Percentage chance (1-100) for a second click to fire immediately
Global DoubleClickChance      := 1

; --- The Hourly Windows ---
; Average time for these is roughly once an hour (40 to 80 minutes)
Global HourlyMinMinutes       := 40
Global HourlyMaxMinutes       := 80

; State variables for the windows
Global BackspaceBrightnessActive := false
Global EnterZoomActive           := false
Global SpaceVolumeActive         := false

; ==============================================================================
; INITIALIZATION
; ==============================================================================
SetZoomTimer()
SetBackspaceBrightnessTimer()
SetEnterZoomTimer()
SetSpaceVolumeTimer()
SetEdgeTimer()
SetOutlookTimer()

; ==============================================================================
; 0. THE KILL SWITCH
; ==============================================================================
; Instantly terminate script if Ctrl + Shift + Alt + F12 is pressed
^!+F12:: {
    ExitApp()
}

; ==============================================================================
; 1. THE STUTTERING SPACEBAR & VOLUME INCREASE
; ==============================================================================
$*Space:: {
    Global SpaceVolumeActive, SpacebarDoubleChance
    
    If (SpaceVolumeActive) {
        Send("{Blind}{Volume_Up}")
    }
    
    If (Random(1, 100) <= SpacebarDoubleChance) {
        Send("{Blind}{Space 2}")
    } Else {
        Send("{Blind}{Space}")
    }
}

; ==============================================================================
; 2. THE SLIPPERY SHIFT
; ==============================================================================
; Intercept Shift key releases. Use `~` to pass normal usage through.
~*LShift UP::
~*RShift UP:: {
    Global ShiftCapsLockChance
    If (Random(1, 100) <= ShiftCapsLockChance) {
        currentState := GetKeyState("CapsLock", "T")
        SetCapsLockState(currentState ? "Off" : "On")
    }
}

; ==============================================================================
; 3. THE GASLIGHT ZOOM
; ==============================================================================
SetZoomTimer() {
    Global ZoomTimerMinMinutes, ZoomTimerMaxMinutes
    msInterval := Random(ZoomTimerMinMinutes * 60000, ZoomTimerMaxMinutes * 60000)
    SetTimer(TriggerZoom, -msInterval) ; Negative means run only once
}

TriggerZoom() {
    If (Random(1, 2) == 1) {
        Send("^{=}") ; Simulate Ctrl + "=" (Zoom in)
    } Else {
        Send("^{-}") ; Simulate Ctrl + "-" (Zoom out)
    }
    SetZoomTimer() ; Reschedule for next time
}

; ==============================================================================
; 4. THE PHANTOM MOUSE CLICKS
; ==============================================================================
*LButton:: {
    Global DoubleClickChance
    ; Actually press the button down now
    Send("{Blind}{LButton Down}")
    
    ; The Phantom Double-Click Check
    If (Random(1, 100) <= DoubleClickChance) {
        ; Schedule a second full click shortly after
        SetTimer(PhantomDoubleClick, -50)
    }
}

*LButton Up:: {
    Send("{Blind}{LButton Up}")
}

PhantomDoubleClick() {
    Send("{Blind}{LButton}")
}

; ==============================================================================
; 5. THE HOURLY WINDOWS
; ==============================================================================

; --- Backspace Brightness Lowering (45s window) ---
SetBackspaceBrightnessTimer() {
    Global HourlyMinMinutes, HourlyMaxMinutes
    msInterval := Random(HourlyMinMinutes * 60000, HourlyMaxMinutes * 60000)
    SetTimer(ActivateBackspaceBrightness, -msInterval)
}

ActivateBackspaceBrightness() {
    Global BackspaceBrightnessActive
    BackspaceBrightnessActive := true
    SetTimer(DeactivateBackspaceBrightness, -45000)
    SetBackspaceBrightnessTimer()
}

DeactivateBackspaceBrightness() {
    Global BackspaceBrightnessActive
    BackspaceBrightnessActive := false
}

$*Backspace:: {
    Global BackspaceBrightnessActive, BackspaceDoubleChance
    If (BackspaceBrightnessActive) {
        Try {
            For monitor in ComObjGet("winmgmts:\\.\root\WMI").ExecQuery("SELECT * FROM WmiMonitorBrightness") {
                current := monitor.CurrentBrightness
                newLevel := current - 5
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

; --- Enter Zoom In (30s window) ---
SetEnterZoomTimer() {
    Global HourlyMinMinutes, HourlyMaxMinutes
    msInterval := Random(HourlyMinMinutes * 60000, HourlyMaxMinutes * 60000)
    SetTimer(ActivateEnterZoom, -msInterval)
}

ActivateEnterZoom() {
    Global EnterZoomActive
    EnterZoomActive := true
    SetTimer(DeactivateEnterZoom, -30000)
    SetEnterZoomTimer()
}

DeactivateEnterZoom() {
    Global EnterZoomActive
    EnterZoomActive := false
}

$*Enter::
$*NumpadEnter:: {
    Global EnterZoomActive, EnterNewlinesChance
    If (EnterZoomActive) {
        Send("^{=}")
    }
    
    If (Random(1, 100) <= EnterNewlinesChance) {
        Send("{Blind}+{Enter}")
    } Else {
        Send("{Blind}{Enter}")
    }
}

; --- Spacebar Volume Increase (20s window) ---
SetSpaceVolumeTimer() {
    Global HourlyMinMinutes, HourlyMaxMinutes
    msInterval := Random(HourlyMinMinutes * 60000, HourlyMaxMinutes * 60000)
    SetTimer(ActivateSpaceVolume, -msInterval)
}

ActivateSpaceVolume() {
    Global SpaceVolumeActive
    SpaceVolumeActive := true
    SetTimer(DeactivateSpaceVolume, -20000)
    SetSpaceVolumeTimer()
}

DeactivateSpaceVolume() {
    Global SpaceVolumeActive
    SpaceVolumeActive := false
}

; ==============================================================================
; 7. THE RANDOM APP OPENERS
; ==============================================================================

SetEdgeTimer() {
    Global EdgeTimerMinMinutes, EdgeTimerMaxMinutes
    msInterval := Random(EdgeTimerMinMinutes * 60000, EdgeTimerMaxMinutes * 60000)
    SetTimer(TriggerEdge, -msInterval)
}

TriggerEdge() {
    Run("msedge.exe")
    SetEdgeTimer()
}

SetOutlookTimer() {
    Global OutlookTimerMinMinutes, OutlookTimerMaxMinutes
    msInterval := Random(OutlookTimerMinMinutes * 60000, OutlookTimerMaxMinutes * 60000)
    SetTimer(TriggerOutlook, -msInterval)
}

TriggerOutlook() {
    Run("outlook.exe")
    SetOutlookTimer()
}

; ==============================================================================
; 8. THE TAB TYPO
; ==============================================================================
#HotIf WinActive("ahk_class Chrome_WidgetWin_1") or WinActive("ahk_class MozillaWindowClass")
$*t:: {
    Global TabOpenChance
    If (Random(1, 100) <= TabOpenChance) {
        Send("^t")
    } Else {
        Send("{Blind}t")
    }
}
#HotIf
