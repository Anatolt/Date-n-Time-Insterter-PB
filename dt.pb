; #VK_MEDIA_PLAY_PAUSE=$B3

Structure _GlobalHotkeys
 window.l
 event.l
EndStructure
Global NewList GlobalHotkeys._GlobalHotkeys()

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
      pasteStuff()
      Debug FormatDate("%yyyy.%mm.%dd %hh:%ii:%ss",Date())
;       If wparam=#VK_MEDIA_PLAY_PAUSE
;         Debug "#VK_MEDIA_PLAY_PAUSE pressed"
;         result=#False
;       EndIf
  EndSelect
  ProcedureReturn result
EndProcedure 

#Window=1

If OpenWindow(#Window,300,250,400,200,"test",#PB_Window_SystemMenu)
 If AddGlobalHotkey(#Window,#VK_D,#MOD_CONTROL|#MOD_ALT,#VK_D)=#False
  Debug "failed to register hotkey"
 EndIf
 SetWindowCallback(@WindowCallback(),1)
 
 Repeat
  event=WaitWindowEvent()
 Until event=#PB_Event_CloseWindow
EndIf 

RemoveAllGlobalHotkeys()
; IDE Options = PureBasic 5.31 (Windows - x86)
; Folding = -
; EnableUnicode
; EnableXP