#myname = "Date-n-time-inserter-v0.2"

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

; Procedure RemoveGlobalHotkey(window,event)
; Define.l result
;  ForEach GlobalHotkeys()
;   If (GlobalHotkeys()\window=window) And (GlobalHotkeys()\event=event) : Break :  EndIf
;   ProcedureReturn #False
;  Next
;  result=UnregisterHotKey_(WindowID(window),event)
;  If result
;   DeleteElement(GlobalHotkeys(),1)
;  EndIf
;  ProcedureReturn result
; EndProcedure

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
  Delay(1000)
  Define n.INPUT
  n\type = #INPUT_KEYBOARD
  SetClipboardText(FormatDate("%yyyy.%mm.%dd %hh:%ii",Date()))
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
      Debug pasteStuff()
;       If wparam=#VK_MEDIA_PLAY_PAUSE
;         Debug "#VK_MEDIA_PLAY_PAUSE pressed"
;         result=#False
;       EndIf
  EndSelect
  ProcedureReturn result
EndProcedure 

If OpenWindow(0,1,1,1,1,#myname,#PB_Window_Invisible)
  icon = ExtractIcon_(WindowID(0),appname,0)
  AddSysTrayIcon(1,WindowID(0),icon)
  SysTrayIconToolTip(1,#myname)
  CreatePopupMenu(0)
  MenuItem(1,#myname)
  DisableMenuItem(0,1,1)
  MenuBar()
  MenuItem(2,"Exit")
;   textField = EditorGadget(0,0,0,400,200) ; for emidiately test
 If AddGlobalHotkey(0,#VK_D,#MOD_CONTROL|#MOD_ALT,#VK_D)=#False
  Debug "failed to register hotkey"
 EndIf
 SetWindowCallback(@WindowCallback(),1)
 
 Repeat
   ev=WaitWindowEvent()
     If ev = #PB_Event_SysTray And EventType() = #PB_EventType_RightClick
    DisplayPopupMenu(0,WindowID(0))
  ElseIf ev = #PB_Event_Menu And EventMenu() = 2
    Break
  EndIf
 Until ev=#PB_Event_CloseWindow
EndIf 

RemoveAllGlobalHotkeys()