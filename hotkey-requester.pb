; HotkeyRequester.pbi
; Dec 1, 2014
; Windows Only
; Written in PB 5.31 x86
; Author: missile69
; http://www.purebasic.fr/english/memberlist.php?mode=viewprofile&u=7421
; 
; License: Free to use, modify, or publish any way you wish. Credit appreciated,
;          not required.
;
; Main function: HotkeyRequester(WindowNumber.i, Title$, Instruction$, *funcToCall)
                ;WindowNumber = Window that will respond to #WM_Hotkey. Usually your main window as closed windows 
                ;               can't respond to hotkey messages.
                ;Title$       = Title bar text
                ;Instruction$ = 
                ;*funcToCall  = Pointer to the function you want called when this hotkey is triggered. Function 
                ;               should not require parameters
                ;
                ;Return Value = ID number of hotkey if successfully set. Zero otherwise. 
;
; Opens a simple window where your program's user can easily select pick a 
; global hotkey. HotkeyRequester features "live" updating of their keypresses and 
; color-based visual feedback to show the validity of their chosen Hotkey
;
; Global hotkeys, as opposed to PB's keyboard shortcuts, are
; available even when your program's window is not focused or is not visible.

EnableExplicit

Enumeration whk 100
  #wndHKRequester
  #tmrUpdate
  #fntHKDisplay
  ;Gadgets
  #lblHKDisplay
  #btnOk
  #btnCancel
EndEnumeration

Structure _UserHK
  vkey.i
  mods.i
  hWnd.i
  ID.i
  *function
  friendlyString.s
EndStructure

NewList hkList._UserHK()

;This flag ensures only one #WM_Hotkey message is received even if user keeps
;hotkey buttons pushed down. 
#MOD_NOREPEAT = 16384
;Colors
#myGreen      = $37A537
#myRed        = $BE3F3F

Procedure.i _whk_idExists(hkID.i)
  Shared hkList()
  
  If hkID
    ForEach hkList()
      If hkList()\ID = hkID
        ProcedureReturn @hkList()
        Break
      EndIf
    Next 
  EndIf
  
  ProcedureReturn 0
EndProcedure

Procedure.i _whk_isDuplicate(*UserHK._UserHK)
  Shared hkList()
  Protected r.i
  
    ForEach hkList()
      If hkList()\mods = *UserHK\mods And hkList()\vkey = *UserHK\vkey
        r = #True
        Break
      EndIf
    Next
  
  ProcedureReturn r
EndProcedure

Procedure WM_HOTKEY_Event(wParam.i, lParam.i)
  ;This function should be called from your window callback when a
  ;#WM_HOTKEY message is received.
  
  Shared hkList()
  
  ;Debug "WM_HOTKEY id = " + Str(wParam)
  If _whk_idExists(wParam)
    CallFunctionFast(hkList()\function)
  EndIf
  
EndProcedure

Procedure RemoveHotkey(hkID.i)
  ;Returns non-zero on success, else returns zero.
  ;hkID = ID number associated with this hotkey. #PB_All can be used to unregister all
  ;       hotkeys when your program ends.
  Shared hkList()
  Protected i.i
  If hkID = #PB_All
    ForEach hkList()
      UnregisterHotKey_(hkList()\hWnd, hkList()\ID)
      i + 1
    Next
    ClearList(hkList())
    ;Debug "Unregistered " + Str(i) + " Hotkeys"
  ElseIf hkID
    ;If the given hotkey ID is valid, unregister it and delete from list.
    If _whk_idExists(hkID)
      UnregisterHotKey_(hkList()\hWnd, hkList()\ID)
      DeleteElement(hkList())
    EndIf
  EndIf
  
EndProcedure

Procedure.i _whk_addHotkey(*UserHK._UserHK, Test.b = #False)
  ;Hotkey       = Pointer to filled out _userHK-structured variable. \ID value is always auto-generated 
  ;               and the is the return value.
  ;Test         = If true, unregisters the hotkey before exiting and doesn't add it to our hkList().
  ;
  ;Return Value = Hotkey ID on success. 0 on error (usually means that hotkey is already used by another program).
  
  Shared hkList()
  Protected r.i
  Static hkAutoID.i 
  hkAutoID + 1
  
  With *UserHK
    If \friendlyString And \function And \mods And \vkey
      \ID = hkAutoID
      
      If _whk_isDuplicate(*UserHK) = #False
        r = RegisterHotKey_(\hWnd, \ID, \mods, \vKey)
        If r
          If Test
            UnregisterHotKey_(\hWnd, \ID)
            hkAutoID - 1
          Else
            AddElement(hkList())
            hkList()\friendlyString = \friendlyString
            hkList()\function       = \function
            hkList()\hWnd           = \hWnd
            hkList()\ID             = \ID
            hkList()\mods           = \mods
            hkList()\vkey           = \vkey
          EndIf
          r = \ID
        Else
          hkAutoID - 1
        EndIf
      Else
        hkAutoID - 1
      EndIf
      
    EndIf
  EndWith
  
  ProcedureReturn r
EndProcedure

Procedure.i HotkeyKeycode(hkID.i)
  ;Returns the key code associated with given ID. 
  
  Shared hkList()
  If _whk_idExists(hkID)
    ProcedureReturn hkList()\vkey
  EndIf
  
  ProcedureReturn #Null
EndProcedure

Procedure.i HotkeyModifiers(hkID.i)
  ;Returns the modifiers associated with given ID. They can be any combination
  ;of #MOD_ALT, #MOD_CONTROL, #MOD_SHIFT, and #MOD_NOREPEAT
  
  Shared hkList()
  If _whk_idExists(hkID)
    ProcedureReturn hkList()\mods
  EndIf
  
  ProcedureReturn #Null
EndProcedure

Procedure.s HotkeyFriendlyName(hkID.i)
  ;Returns the user-friendly hotkey description associated with the given hkID
  Shared hkList()
  If hkID
    If _whk_idExists(hkID)
      ProcedureReturn hkList()\friendlyString
    EndIf
  EndIf
  ProcedureReturn #NULL$
EndProcedure

Procedure.i isHotkey(hkID.i)
  ;Returns non-zero if this hotkey ID is valid and registered. Zero when not.
  
  If hkID 
    ProcedureReturn _whk_idExists(hkID)
  EndIf
  
  ProcedureReturn 0
EndProcedure



Procedure.i _whk_checkKB(*UserHK._UserHK)
  ;Checks Ctrl, Alt, Shift and Keycodes 48-122 which correspond to all numbers and basic visible characters.
  ;Since hotkeys can only have one vKey code associated with them, this function only returns the key code
  ;for the first (lowest numbered on Ascii chart) pressed key it finds even if, for example, two letters 
  ;were pressed.
  ;
  ;Return value = Non-zero if keyboard state was successfully retrieved. The _UserHK structure passed by 
  ;               reference will have its mods, vKey, and friendlyString fields filled in if their 
  ;               corresponding keys were pressed.
  
  ClearStructure(*UserHK, _UserHK)
  Protected r.i, i.i
  
  Dim kb.b(255)
  r = GetKeyboardState_(@kb())
  If r
    With *UserHK
      
      If kb(#VK_CONTROL) & $ff > 1
        \mods + #MOD_CONTROL
        \friendlyString + "Ctrl + "
      EndIf
      If kb(#VK_MENU) & $ff > 1
        \mods + #MOD_ALT
        \friendlyString + "Alt + "
      EndIf
      If kb(#VK_SHIFT) & $ff > 1
        \mods + #MOD_SHIFT
        \friendlyString + "Shift + "
      EndIf
      If \mods
        \mods + #MOD_NOREPEAT
      EndIf
      
      For i = '0' To 'z'
        If kb(i) & $ff > 1
          
          ;Debug Chr(i) + " pressed!"
          \friendlyString + Chr(i)
          \vKey = i
          Break
        EndIf
      Next
      
    EndWith
  EndIf

  ProcedureReturn r
EndProcedure

Procedure.i HotkeyRequester(WindowNumber.i, Title$, Instruction$, *funcToCall)
  ;WindowNumber = Window that will respond to #WM_Hotkey. Usually your main window as closed windows 
  ;               can't respond to hotkey messages.
  ;Title$       = Title bar text
  ;Instruction$ = 
  ;*funcToCall  = Pointer to the function you want called when this hotkey is triggered. Function 
  ;               should not require parameters
  ;
  ;Return Value = ID number of hotkey if successfully set. Zero otherwise.
  
  Protected._UserHK currKeys, prevKeys 
  Protected r.i, e.i, h.i, w.i, hkIsValid.i
  Protected MaxHK$ = "Ctrl + Alt + Shift + W"
  
  If IsWindow(WindowNumber)
    WindowNumber = WindowID(WindowNumber)
    
    If OpenWindow(#wndHKRequester, 0, 0, 400, 150, Title$, #PB_Window_ScreenCentered|#PB_Window_SystemMenu)
      TextGadget(#PB_Any, 10, 10, WindowWidth(#wndHKRequester) - 20, 36, Instruction$, #PB_Text_Center)
      ButtonGadget(#btnOk, 320, 105, 70, 35, "OK")
      DisableGadget(#btnOk, #True)
      ButtonGadget(#btnCancel, 240, 105, 70, 35, "Cancel")
      
      ;Set up hotkey display area
      LoadFont(#fntHKDisplay, "Arial", 14, #PB_Font_Bold)
      StartDrawing(WindowOutput(#wndHKRequester))
      DrawingFont(FontID(#fntHKDisplay))
      h = TextHeight(MaxHK$) + 20
      w = TextWidth(MaxHK$) + 20
      StopDrawing()
      
      TextGadget(#lblHKDisplay, (400-w)/2, 50, w, h, "None", #PB_Text_Center|#SS_CENTERIMAGE)
      SetGadgetColor(#lblHKDisplay, #PB_Gadget_BackColor, #White)
      SetGadgetFont(#lblHKDisplay, FontID(#fntHKDisplay))
      
      AddWindowTimer(#wndHKRequester, #tmrUpdate, 150)
      Repeat
        e = WaitWindowEvent()
        Select e
          Case #PB_Event_Timer
            If _whk_checkKB(@currKeys)
              With currKeys
                ;If keys were pressed
                If \friendlyString
                  ;Show pressed keys to user
                  SetGadgetText(#lblHKDisplay, \friendlyString)
                  If \friendlyString <> prevKeys\friendlyString
                    SetGadgetColor(#lblHKDisplay, #PB_Gadget_FrontColor, #Black)
                  EndIf
                  If \mods And \vkey
                    If \mods <> prevKeys\mods Or \vkey <> prevKeys\vkey
                      
                      \function = *funcToCall
                      \hWnd     = WindowNumber
                      ;Test this hotkey combination. 
                      r = _whk_addHotkey(@currKeys, #True)
                      If r
                        ;Hotkey is good and able to be registered
                        prevKeys = currKeys
                        hkIsValid = #True
                        SetGadgetColor(#lblHKDisplay, #PB_Gadget_FrontColor, #myGreen)
                      Else
                        hkIsValid = #False
                        SetGadgetColor(#lblHKDisplay, #PB_Gadget_FrontColor, #myRed)
                      EndIf
                    EndIf
                  EndIf  
                  
                Else
                  ;Keep showing previous valid hotkey if there is one
                  If prevKeys\ID
                    If GetGadgetData(#btnOk) = 0
                      DisableGadget(#btnOk, #False)
                      SetGadgetData(#btnOk, 1)
                    EndIf
                    SetGadgetText(#lblHKDisplay, prevKeys\friendlyString)
                    SetGadgetColor(#lblHKDisplay, #PB_Gadget_FrontColor, #myGreen)
                  Else 
                    If GetGadgetData(#btnOk)
                      DisableGadget(#btnOk, #True)
                      SetGadgetData(#btnOk, 0)
                    EndIf
                    SetGadgetText(#lblHKDisplay, "None")
                    SetGadgetColor(#lblHKDisplay, #PB_Gadget_FrontColor, #Black)
                  EndIf
                EndIf
              EndWith
            EndIf
            
          Case #PB_Event_Gadget
            Select EventGadget()
              Case #btnOk
                If prevKeys\ID
                  ;Add hotkey for real this time. 
                  r = _whk_addHotkey(@prevKeys)
                EndIf
                Break 
                
              Case #btnCancel
                r = 0
                Break
                
            EndSelect
            
          Case #PB_Event_CloseWindow
            r = 0
            Break
            
        EndSelect
        
      ForEver
      
      RemoveWindowTimer(#wndHKRequester, #tmrUpdate)
      FreeFont(#fntHKDisplay)
      CloseWindow(#wndHKRequester)
      
      
    EndIf
  EndIf
  
  ProcedureReturn r
EndProcedure
DisableExplicit

;////////////////////////////////////// Sample Code \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  Enumeration
    #wndMain
    #strShowHideHK
    #btnEditShowHideHK
    #btnDelShowHideHK
  EndEnumeration
  
  Procedure ShowHideHKActivated()
    
    SetWindowData(#wndMain, ~GetWindowData(#wndMain))
    HideWindow(#wndMain, GetWindowData(#wndMain))
    
    Debug "Press " + GetGadgetText(#strShowHideHK) + " to show/hide window" 
    
  EndProcedure
  
  Procedure myWinCallback(hWnd.i, uMsg.i, wParam.i, lParam.i)
    
    If uMsg = #WM_HOTKEY
      WM_HOTKEY_Event(wParam, lParam)
    EndIf
    
    ProcedureReturn #PB_ProcessPureBasicEvents
  EndProcedure
  
  If OpenWindow(#wndMain, 0, 0, 500, 500, "Hotkey Settings", #PB_Window_ScreenCentered|#PB_Window_SystemMenu)
    SetWindowCallback(@myWinCallback(), #wndMain)
    TextGadget(#PB_Any, 10, 10, 300, 20, "Hotkey for Showing/Hiding this window:")
    StringGadget(#strShowHideHK, 10, 40, 200, 25, "None", #PB_String_ReadOnly)
    ButtonGadget(#btnEditShowHideHK, 220, 40, 100, 25, "Change Hotkey") 
    ButtonGadget(#btnDelShowHideHK,  330, 40, 100, 25, "Delete Hotkey")
    
    Define e.i, hkShowHide.i, desc.s = "Press the key combination you want to associate with this action"
    Repeat
      e = WaitWindowEvent()
      If e = #PB_Event_Gadget
        Select EventGadget()
          Case #btnEditShowHideHK
            If isHotkey(hkShowHide)
              ;If the hotkey was already set, delete it before showing requester again
              RemoveHotkey(hkShowHide)
            EndIf
            hkShowHide = HotkeyRequester(#wndMain, "Select hotkey to show/hide main window", desc, @ShowHideHKActivated())
            If hkShowHide
              SetGadgetText(#strShowHideHK, HotkeyFriendlyName(hkShowHide))
            Else
              SetGadgetText(#strShowHideHK, "None")
            EndIf
            
          Case #btnDelShowHideHK
            RemoveHotkey(hkShowHide)
            SetGadgetText(#strShowHideHK, "None")
            
        EndSelect
        
      EndIf
      
    Until e = #PB_Event_CloseWindow
  EndIf
  RemoveHotkey(#PB_All)
  End
CompilerEndIf