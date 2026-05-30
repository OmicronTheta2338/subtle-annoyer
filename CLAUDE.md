# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

An AutoHotkey v2 prank script that installs itself to Windows startup and introduces subtle, hard-to-diagnose input annoyances. Disguised as `windows_update_service.exe`.

## Build & Run

This is an AHK v2 project compiled to a Windows `.exe`. Development happens on Windows with AutoHotkey v2 installed.

- **Run the main script**: `autohotkey april_fools.ahk` (or double-click)
- **Run the test harness**: `autohotkey test_env.ahk` — opens a GUI to enable each prank at 100% probability and manually trigger timed events
- **Compile to exe**: Use Ahk2Exe (bundled with AHK): `Ahk2Exe.exe /in april_fools.ahk /out windows_update_service.exe /icon windowprogram.ico`
- **Kill switch**: `Ctrl+Alt+Shift+F12` terminates the running script immediately

## Architecture

All prank logic lives in `april_fools.ahk`. `test_env.ahk` is a parallel file that duplicates the prank logic verbatim but wires it to a GUI instead of probability-based timers.

**Two categories of pranks:**

1. **Per-keystroke hooks** — registered via `$*Key::` hotkeys or `CreateDelayHotkeys()` (which registers a-z, 0-9, and symbols dynamically). Each hook runs a chance check on every keypress. These: spacebar double, backspace double, shift→capslock, enter→shift+enter, semicolon/colon swap, tab→new-tab (browser only), keystroke delay, letter drop, copy-space append, phantom double-click.

2. **Timed windows** — one-shot timers that activate a global boolean flag for a fixed duration, then reschedule themselves. The per-keystroke hooks check these flags. Three timed windows: `BackspaceBrightnessActive` (45s, lowers monitor brightness via WMI), `EnterZoomActive` (30s, sends Ctrl+= on Enter), `SpaceVolumeActive` (20s, sends Volume_Up on Space). Two app openers fire on their own timers: Edge (3–5 hrs) and Outlook (10 hrs).

**Global probability knobs** are declared at the top of `april_fools.ahk` as named constants — adjust these to tune aggression without touching logic.

**Startup persistence**: On launch, the script writes its own path to `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` under the key `"update"` (skips if already present).

**Context-sensitive hotkey**: The Tab Typo only activates when Chrome or Firefox is the active window (`#HotIf WinActive(...)`).

## Key Constraint

`test_env.ahk` duplicates the prank functions from `april_fools.ahk` exactly. When modifying prank logic, update both files. The test file replaces timer-based activation with GUI buttons (10s windows) and sets all chance variables to 0, toggling them to 100 via checkboxes.
