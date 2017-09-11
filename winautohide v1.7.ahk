/*
 * BoD winautohide v1.7
 *
 * This program and its source are in the public domain.
 * Contact BoD@JRAF.org for more information.
 *
 * Version history:
 * 2008-06-13: v1.00
 * 2017-08-25: v1.20 AutoHide in right edge got support for multiple monitors Modified By TW
 * 2017-08-25: v1.30  Four sides got support for multiple monitors Modified By TW
 * 2017-09-05: v1.6.6  Support dynamic move Modified By TW
 * 2017-09-10: v1.7  Dynamic move bugs fixed Modified By TW
 *
 */

#SingleInstance ignore

/*
 * Hotkey bindings
 * Win Key: #		Alt: !		Ctrl: ^		Shift: +
 */ (Control + Win + DirectionKey)
Hotkey, ^#right, toggleWindowRight
Hotkey, ^#left, toggleWindowLeft
Hotkey, ^#up, toggleWindowUp
Hotkey, ^#down, toggleWindowDown

; uncomment the following lines to use ctrl+alt+shift instead if you don't have a "windows" key
;Hotkey, !^+right, toggleWindowRight
;Hotkey, !^+left, toggleWindowLeft
;Hotkey, !^+up, toggleWindowUp
;Hotkey, !^+down, toggleWindowDown



/*
 * Timer initialization.
 */
SetTimer, watchCursor, 300


/*
 * Tray menu initialization.
 */
Menu, tray, NoStandard
Menu, tray, Add, About..., menuAbout
Menu, tray, Add, Un-autohide all windows, menuUnautohideAll
Menu, tray, Add, Exit, menuExit
Menu, tray, Default, About...


return ; end of code that is to be executed on script start-up


/*
 * Tray menu implementation.
 */
menuAbout:
	MsgBox, 8256, About, BoD winautohide v1.7.0 Mod By WT.`n`nThis program and its source are in the public domain.`nContact BoD@JRAF.org for more information.
return

menuUnautohideAll:
	Loop, Parse, autohideWindows, `,
	{
		curWinId := A_LoopField
		if (autohide_%curWinId%) {
			Gosub, unautohide
		}
	}
return

menuExit:
	Gosub, menuUnautohideAll
	ExitApp
return


/*
 * Timer implementation.
 */
watchCursor:
	MouseGetPos, xpos, ypos , winId ; get window under mouse pointer
	if (autohide_%winId%) { ; window is on the list of 'autohide' windows
		if (hidden_%winId%) { ; window is in 'hidden' position
			previousActiveWindow := WinExist("A")
			WinActivate, ahk_id %winId% ; activate the window
			WinMove, ahk_id %winId%, , showing_%winId%_x, showing_%winId%_y ; move it to 'showing' position
			hidden_%winId% := false
			needHide := winId ; store it for next iteration
			Sleep, 1000  ; Window Hide in 1 second
		}
	} else {
		if (needHide) {
			WinGetPos, new_%needHide%_x, new_%needHide%_y, new_width, new_height, ahk_id %needHide% ;			
			SysGet, MonitorCount, MonitorCount
			SysGet, MonitorPrimary, MonitorPrimary
			Loop, %MonitorCount%
			{
				SysGet, MonitorName, MonitorName, %A_Index%
				SysGet, Monitor, Monitor, %A_Index%
				SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
				if (new_%needHide%_x >= MonitorWorkAreaLeft && new_%needHide%_x < MonitorWorkAreaRight)
					MonitorIndex = %A_Index%
				S%A_Index%MonitorTop := MonitorTop
				S%A_Index%MonitorWorkAreaTop := MonitorWorkAreaTop
				S%A_Index%MonitorBottom := MonitorBottom
				S%A_Index%MonitorWorkAreaBottom := MonitorWorkAreaBottom
			}
			
			if (mode_%needHide% = "right") {
				showing_%needHide%_x := MonitorRight - new_width
				showing_%needHide%_y := MonitorTop + 100

				hidden_%needHide%_x := MonitorRight - 2
				hidden_%needHide%_y := MonitorTop + 100
			} else if (mode_%needHide% = "left") {
				showing_%needHide%_x := 0
				showing_%needHide%_y := new_%needHide%_y

				hidden_%needHide%_x := -new_width + 2
				hidden_%needHide%_y := new_%needHide%_y
			} else if (mode_%needHide% = "up") {
				showing_%needHide%_x := new_%needHide%_x
				showing_%needHide%_y := S%MonitorIndex%MonitorTop

				hidden_%needHide%_x := new_%needHide%_x
				hidden_%needHide%_y := S%MonitorIndex%MonitorTop - new_height + 2
			} else { ; down
				showing_%needHide%_x := new_%needHide%_x
				showing_%needHide%_y := S%MonitorIndex%MonitorBottom - new_height

				hidden_%needHide%_x := new_%needHide%_x
				hidden_%needHide%_y := S%MonitorIndex%MonitorBottom - 3
			}
			
			for j, ele in Array {
				if(Array[j,1] == %needHide%){
					Array[j,3] :=showing_%needHide%_x
					Array[j,4] :=showing_%needHide%_y
					Array[j,5] :=hidden_%needHide%_x
					Array[j,6] :=hidden_%needHide%_y
					Array[j,7] :=new_width
					Array[j,8] :=new_height
					break
				}
			}
						
			if((xpos < -30) OR (xpos > (new_width + 30)) OR (ypos < -30) OR (ypos > (new_height + 30))){				
				WinMove, ahk_id %needHide%, , hidden_%needHide%_x, hidden_%needHide%_y ; move it to 'hidden' position
				WinActivate, ahk_id %previousActiveWindow% ; activate previously active window
				hidden_%needHide% := true
				needHide := false ; do that only once
			}			
		}
	}
return


/*
 * Hotkey implementation.
 */
toggleWindowRight:
	mode := "right"
	Gosub, toggleWindow
return

toggleWindowLeft:
	mode := "left"
	Gosub, toggleWindow
return

toggleWindowUp:
	mode := "up"
	Gosub, toggleWindow
return

toggleWindowDown:
	mode := "down"
	Gosub, toggleWindow
return


toggleWindow:
	WinGet, curWinId, id, A
	autohideWindows = %autohideWindows%,%curWinId%
	
	Array := Object()
	Array.Insert(["a1","down",0,0,0,0,100,100])
	
	WinGetPos, WindowX, WindowY, , , A
	SysGet, MonitorCount, MonitorCount
	SysGet, MonitorPrimary, MonitorPrimary
	MonitorIndex = 1
	Loop, %MonitorCount%
	{
		SysGet, MonitorName, MonitorName, %A_Index%
		SysGet, Monitor, Monitor, %A_Index%
		SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
		if (WindowX >= MonitorWorkAreaLeft && WindowX < MonitorWorkAreaRight)
			MonitorIndex = %A_Index%
		S%A_Index%MonitorTop := MonitorTop
		S%A_Index%MonitorWorkAreaTop := MonitorWorkAreaTop
		S%A_Index%MonitorBottom := MonitorBottom
		S%A_Index%MonitorWorkAreaBottom := MonitorWorkAreaBottom
	}
	
	if (autohide_%curWinId%) {
		Gosub, unautohide		
	} else {
		autohide_%curWinId% := true
		Gosub, workWindow
		WinGetPos, orig_%curWinId%_x, orig_%curWinId%_y, width, height, ahk_id %curWinId% ; get the window size and store original position
				
		if (mode = "right") {
			showing_%curWinId%_x := MonitorRight - width
			showing_%curWinId%_y := MonitorTop + 100

			hidden_%curWinId%_x := MonitorRight - 1
			hidden_%curWinId%_y := MonitorTop + 100
			
			mode_%curWinId% := "right"
		} else if (mode = "left") {
			showing_%curWinId%_x := 0
			showing_%curWinId%_y := orig_%curWinId%_y

			hidden_%curWinId%_x := -width + 1
			hidden_%curWinId%_y := orig_%curWinId%_y
			
			mode_%curWinId% := "left"
		} else if (mode = "up") {
			showing_%curWinId%_x := orig_%curWinId%_x
			showing_%curWinId%_y := S%MonitorIndex%MonitorTop

			hidden_%curWinId%_x := orig_%curWinId%_x
			hidden_%curWinId%_y := S%MonitorIndex%MonitorTop - height + 1
			
			mode_%curWinId% := "up"
		} else { ; down
			showing_%curWinId%_x := orig_%curWinId%_x
			showing_%curWinId%_y := S%MonitorIndex%MonitorBottom - height

			hidden_%curWinId%_x := orig_%curWinId%_x
			hidden_%curWinId%_y := S%MonitorIndex%MonitorBottom - 2
			
			mode_%curWinId% := "down"
		}
		
		checklist := 1
		inlist := 0
		
		if(checklist == 1){
			for j, ele in Array {
				if(Array[j,1] == %curWinId%){
					Array[j,2] :=mode_%curWinId%
					Array[j,3] :=showing_%curWinId%_x
					Array[j,4] :=showing_%curWinId%_y
					Array[j,5] :=hidden_%curWinId%_x
					Array[j,6] :=hidden_%curWinId%_y
					Array[j,7] :=orig_width
					Array[j,8] :=orig_height
					inlist = 1
				}
			}
		}
		if(inlist == 0){
			Array.Insert([%curWinId%,mode_%curWinId%,showing_%curWinId%_x,showing_%curWinId%_y,hidden_%curWinId%_x,hidden_%curWinId%_y,orig_width,orig_height])
		}
		
		WinMove, ahk_id %curWinId%, , hidden_%curWinId%_x, hidden_%curWinId%_y ; hide the window
		hidden_%curWinId% := true
		
	}
return


unautohide:
	autohide_%curWinId% := false
	needHide := false
	Gosub, unworkWindow
	WinMove, ahk_id %curWinId%, , orig_%curWinId%_x, orig_%curWinId%_y ; go back to original position
	hidden_%curWinId% := false
return

workWindow:
	DetectHiddenWindows, On
	WinSet, AlwaysOnTop, on, ahk_id %curWinId% ; always-on-top
	WinHide, ahk_id %curWinId%
	WinSet, Style, -0xC00000, ahk_id %curWinId% ; no title bar
	WinSet, ExStyle, +0x80, ahk_id %curWinId% ; remove from task bar
	WinShow, ahk_id %curWinId%
return

unworkWindow:
	DetectHiddenWindows, On
	WinSet, AlwaysOnTop, off, ahk_id %curWinId% ; always-on-top
	WinHide, ahk_id %curWinId%
	WinSet, Style, +0xC00000, ahk_id %curWinId% ; title bar
	WinSet, ExStyle, -0x80, ahk_id %curWinId% ; remove from task bar
	WinShow, ahk_id %curWinId%
return
