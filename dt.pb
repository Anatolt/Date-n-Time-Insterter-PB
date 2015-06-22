#Myname = "Date-n-time-inserter-v0.4"
Enumeration
  #Window
  #SysTrayIcon
  #Menu
  #Exit
  #change_hk
  #strShowHideHK
EndEnumeration

IncludeFile "hotkey-requester.pb"

Structure _GlobalHotkeys
  window.l
  event.l
EndStructure
Global NewList GlobalHotkeys._GlobalHotkeys()
appname.s = GetFilePart(ProgramFilename())

Procedure AddGlobalHotkey(window,event,modifiers,vk)
  Define.l result
  result=RegisterHotKey_(WindowID(window),event,modifiers,vk)
  If result
    LastElement(GlobalHotkeys())
    AddElement(GlobalHotkeys())
    GlobalHotkeys()\window=window
    GlobalHotkeys()\event=event
  EndIf
  ProcedureReturn result
EndProcedure

Procedure RemoveGlobalHotkey(window,event)
Define.l result
 ForEach GlobalHotkeys()
  If (GlobalHotkeys()\window=window) And (GlobalHotkeys()\event=event) : Break :  EndIf
  ProcedureReturn #False
 Next
 result=UnregisterHotKey_(WindowID(window),event)
 If result
  DeleteElement(GlobalHotkeys(),1)
 EndIf
 ProcedureReturn result
EndProcedure

Procedure RemoveAllGlobalHotkeys()
  ForEach GlobalHotkeys()
    UnregisterHotKey_(WindowID(GlobalHotkeys()\window),GlobalHotkeys()\event)
    DeleteElement(GlobalHotkeys(),0)
  Next
EndProcedure

Procedure pasteStuff()
  ;   Repeat 
  ;     Delay(10)
  ;   Until #WM_KEYDOWN
  Define n.INPUT
  n\type = #INPUT_KEYBOARD
  txt$ = FormatDate("%yyyy.%mm.%dd %hh:%ii",Date())
  SetClipboardText(txt$)
  AddGadgetItem(textField,-1,txt$)
  Delay(1000)
  n\ki\wVk = #VK_CONTROL : n\ki\dwFlags = 0
  SendInput_(1,@n,SizeOf(n))
  n\ki\wVk = #VK_V
  SendInput_(1,@n,SizeOf(n))
  n\ki\dwFlags = #KEYEVENTF_KEYUP
  SendInput_(1,@n,SizeOf(n))
  n\ki\wVk = #VK_CONTROL
  SendInput_(1,@n,SizeOf(n))
EndProcedure

Procedure WindowCallback(hwnd,msg,wparam,lparam)
  result=#PB_ProcessPureBasicEvents
  Select msg 
    Case #WM_HOTKEY
      pasteStuff()
      ;       If wparam=#VK_MEDIA_PLAY_PAUSE
      ;         Debug "#VK_MEDIA_PLAY_PAUSE pressed"
      ;         result=#False
      ;       EndIf
  EndSelect
  ProcedureReturn result
EndProcedure 

OpenWindow(#Window,0,0,400,200,#Myname,#PB_Window_Invisible) ;#PB_Window_Invisible #PB_Window_SystemMenu
MessageRequester(#Myname,"Press Ctlr+Alt+D to paste timestamp")
icon = ExtractIcon_(WindowID(#Window),appname,0)
AddSysTrayIcon(1,WindowID(#Window),icon)
SysTrayIconToolTip(#SysTrayIcon,#Myname)
CreatePopupMenu(#Menu)
MenuItem(1,#Myname)
DisableMenuItem(#Menu,1,1)
MenuBar()
MenuItem(#change_hk,"Change Hotkey")
MenuItem(#Exit,"Exit")
textField = EditorGadget(0,0,0,400,200)
If AddGlobalHotkey(#Window,#VK_D,#MOD_CONTROL|#MOD_ALT,#VK_D)=#False
  MessageRequester(#Myname,"Failed to register hotkey")
EndIf
SetWindowCallback(@WindowCallback(),#Window)

Repeat
  ev=WaitWindowEvent()
  If ev = #PB_Event_SysTray And EventType() = #PB_EventType_RightClick
    DisplayPopupMenu(#Menu,WindowID(#Window))
  ElseIf ev = #PB_Event_Menu 
    Select EventMenu() 
      Case #change_hk
        If isHotkey(hkShowHide)
          ;If the hotkey was already set, delete it before showing requester again
          RemoveHotkey(hkShowHide)
          RemoveGlobalHotkey(#Window,#VK_D)
        EndIf
        txt2$ = "Press the key combination you want to associate with this action"
        hkShowHide = HotkeyRequester(#Window, #Myname, txt2$, @pasteStuff())
        
        If hkShowHide
          SetMenuItemText(#Menu,#change_hk, "Hotkey: "+HotkeyFriendlyName(hkShowHide))
        Else
          SetMenuItemText(#Menu,#change_hk, "Hotkey: None")
        EndIf
        
      Case #Exit
        Break
    EndSelect
  EndIf
Until ev=#PB_Event_CloseWindow

RemoveAllGlobalHotkeys()