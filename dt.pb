#Myname = "Date-n-time-inserter-v0.7"

Enumeration
  #Window
  #SysTrayIcon
  #Menu
  #Exit
  #change_hk
EndEnumeration

IncludeFile "hotkey-requester.pb"

Procedure myWinCallback(hWnd.i, uMsg.i, wParam.i, lParam.i)
  
  If uMsg = #WM_HOTKEY
    WM_HOTKEY_Event(wParam, lParam)
  EndIf
  
  ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

Procedure pasteStuff()
  Protected i.i, txt$
  ; continue if all keys are free
  Repeat
    For i = 0 To 1000
      If GetKeyState_(i) <= -1
        Break
      ElseIf i = 1000
        Debug "all keys are free"
        Break 2
      EndIf
    Next
    Delay(10)
  ForEver
  Define n.INPUT
  n\type = #INPUT_KEYBOARD
  txt$ = FormatDate("%yyyy.%mm.%dd %hh:%ii",Date())
  SetClipboardText(txt$)
  n\ki\wVk = #VK_CONTROL : n\ki\dwFlags = 0
  SendInput_(1,@n,SizeOf(n))
  n\ki\wVk = #VK_V
  SendInput_(1,@n,SizeOf(n))
  n\ki\dwFlags = #KEYEVENTF_KEYUP
  SendInput_(1,@n,SizeOf(n))
  n\ki\wVk = #VK_CONTROL
  SendInput_(1,@n,SizeOf(n))
EndProcedure

Define ev.i, hkInsTimestamp.i, txt2.s = "Press the key combination you want To associate With this action", 
icon, appname.s = GetFilePart(ProgramFilename())
OpenWindow(#Window, 0, 0, 500, 500, #Myname, #PB_Window_Invisible)
SetWindowCallback(@myWinCallback(), #Window)
icon = ExtractIcon_(WindowID(#Window),appname,0)
AddSysTrayIcon(#SysTrayIcon,WindowID(#Window),icon)
SendMessage_(WindowID(#Window),#WM_SETICON,#ICON_SMALL,icon)
SysTrayIconToolTip(#SysTrayIcon,#Myname)
CreatePopupMenu(#Menu)
MenuItem(1,#Myname)
DisableMenuItem(#Menu,1,1)
MenuBar()
MenuItem(#change_hk,"Change Hotkey")
MenuItem(#Exit,"Exit")
HotkeyRequester(#Window, #Myname, txt2, @pasteStuff())

Repeat
  ev = WaitWindowEvent()
  If ev = #PB_Event_SysTray And EventType() = #PB_EventType_RightClick
    DisplayPopupMenu(#Menu,WindowID(#Window))
  ElseIf ev = #PB_Event_Menu 
    Select EventMenu() 
      Case #change_hk
        If isHotkey(hkInsTimestamp)
          ;If the hotkey was already set, delete it before showing requester again
          RemoveHotkey(hkInsTimestamp)
        EndIf
        
        hkInsTimestamp = HotkeyRequester(#Window, #Myname, txt2, @pasteStuff())
        
        If hkInsTimestamp
          SetMenuItemText(#Menu,#change_hk, "Hotkey: "+HotkeyFriendlyName(hkInsTimestamp))
        Else
          SetMenuItemText(#Menu,#change_hk, "Hotkey: None")
        EndIf
        
      Case #Exit
        Break
    EndSelect
  EndIf
Until ev = #PB_Event_CloseWindow
RemoveHotkey(#PB_All)