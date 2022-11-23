#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
#include resource\gdip_all.ahk
#include resource\gdip_ext.ahk
Gdip_Startup()

global ScreenConfiguratorPID:= DllCall("GetCurrentProcessId")

gui, Canvas:new, +LastFound -SysMenu -border -0xC00000 +HWNDCanvasHWND
Gui, Color , 000000

SysGet, Monitor, monitor
WinSet, Trans, 50
global CanvasPositions:= {CanvasRight:MonitorRight, CanvasTop:MonitorTop}
Gui, show,x0 y0 w%MonitorRight% h%MonitorBottom%

global  CanvasControl:= {Height:100, Width:200}
gui, CanvasControl:new, +AlwaysOnTop
gui, add, text,% "x0 y0 w" CanvasControl.Width " center", Control
gui, add, button,gSaveProfile, Save
gui, add, button,, Undo
gui, add, button,, Redo
gui, add, button,gCanvasHotkeys, Hotkeys
gui, show, % "w" CanvasControl.Width
CanvasHotkeys()
Return

~LButton::
CoordMode, Mouse , Screen
MouseGetPos, OutputVarX, OutputVarY, OutputVarWin
WinGet, WinCanvas, ID, ahk_ID %OutputVarWin%
if (WinCanvas = CanvasHWND)
{
    Gui, Canvas:add, button,% "h25 w25 x" (OutputVarX-12.5) " y" (OutputVarY-12.5)
}
return

CanvasGuiClose:
Exitapp
CanvasControlGuiClose:
Exitapp

CanvasHotkeys()
{
    static HotkeysOverlay:=false
    HotkeyPositions:= {Width:200, Height:300}
    if !(HotkeysOverlay)
    {
        Gui, CanvasHotkeys:new, +E0x80000 +LastFound +ToolWindow +OwnDialogs -0xC00000 +E0x08000000 +hwndCanvasHotkeysHWND +OwnerCanvas
        WinSet, Exstyle, +0x20

    Gui, show,
    hwnd1 := WinExist()
    hbm := CreateDIBSection(HotkeyPositions.Width, HotkeyPositions.Height)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    G := Gdip_GraphicsFromHDC(hdc)
    Gdip_SetSmoothingMode(G, 4)

    Font = Arial

            Text=
                (
Hotkeys
F1: Save
F2: Undo
F3: Redo
                )

    Options = x10p y120 w80p Centre cffffffff ow4 ocFF000000 r4 s20
    Gdip_TextToGraphics2(G, Text, Options, Font, HotkeyPositions.Width, HotkeyPositions.Height)

    UpdateLayeredWindow(hwnd1, hdc, (CanvasPositions.CanvasRight - HotkeyPositions.Width - 25), (CanvasPositions.CanvasTop + 200), HotkeyPositions.Width, HotkeyPositions.Height)

    ; Cleanup #######
    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(G)
    HotkeysOverlay:=True
    }
    else
    {
        HotkeysOverlay:=false
        gui, CanvasHotkeys:destroy
    }
}

SaveProfile:
gui, Canvas:destroy
gui, CanvasControl:destroy
#include NewProfile.ahk
return