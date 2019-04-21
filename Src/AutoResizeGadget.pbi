;/ ===== AutoResizeGadgets.pbi =====
;/ Automatically Resize Window Gadgets (based on RS_ResizeGadget by USCode)
;/ [ PureBasic V5.2x ]
;/ January 2014 by Thorsten1867 (optimized by TS-Soft)

DeclareModule GadgetResize
  Enumeration 1
    #GR_LEFT
    #GR_TOP     = 1 << 1
    #GR_RIGHT   = 1 << 2
    #GR_BOTTOM  = 1 << 3
    #GR_HCENTER = 1 << 4
    #GR_VCENTER = 1 << 5
  EndEnumeration

  Declare AddGadget(WindowID.i, GadgetID.i, Flags.l)
  Declare RemoveGadget(WindowID.i, GadgetID.i)
EndDeclareModule
 
Module GadgetResize
 
  EnableExplicit
 
  Structure GadgetResizeStructure
    WindowID.i
    GadgetID.i
    Left.i
    Top.i
    Right.i
    Bottom.i
    Lock_Left.i
    Lock_Top.i
    Lock_Right.i
    Lock_Bottom.i
    HCenter.i
    VCenter.i
  EndStructure
 
  Global NewList GadgetResize.GadgetResizeStructure()

  Procedure GadgetResize_WindowHandler()
    Protected.i WindowID = EventWindow(), WinWidth, WinHeight, X, Y, Width, Height
    If ListSize(GadgetResize())
      WinWidth  = WindowWidth(WindowID)
      WinHeight = WindowHeight(WindowID)
      ForEach GadgetResize()
        If IsGadget(GadgetResize()\GadgetID) And WindowID = GadgetResize()\WindowID
          X = GadgetX(GadgetResize()\GadgetID)
          Y = GadgetY(GadgetResize()\GadgetID)
          Width  = GadgetWidth(GadgetResize()\GadgetID)
          Height = GadgetHeight(GadgetResize()\GadgetID)
          If GadgetResize()\Lock_Left   = #False : X = WinWidth - GadgetResize()\Left : EndIf
          If GadgetResize()\Lock_Top    = #False : Y = WinHeight - GadgetResize()\Top  : EndIf       
          If GadgetResize()\Lock_Right  = #True  : Width = WinWidth - X - GadgetResize()\Right  : EndIf
          If GadgetResize()\Lock_Bottom = #True  : Height = WinHeight - Y - GadgetResize()\Bottom : EndIf 
          If GadgetResize()\HCenter : X = (WinWidth - Width) / 2 : EndIf
          If GadgetResize()\VCenter : Y = (WinHeight - Height) / 2 : EndIf
          ResizeGadget(GadgetResize()\GadgetID, X, Y, Width, Height)
        EndIf
      Next
    EndIf
  EndProcedure
 
  Procedure AddGadget(WindowID.i, GadgetID.i, Flags.l)
    Protected.i WinWidth, WinHeight, X, Y
    
    If IsWindow(WindowID)
      WinWidth  = WindowWidth(WindowID)
      WinHeight = WindowHeight(WindowID)
      If IsGadget(GadgetID)
        If AddElement(GadgetResize())
          GadgetResize()\WindowID    = WindowID
          GadgetResize()\GadgetID    = GadgetID
          If Flags & #GR_LEFT   : GadgetResize()\Lock_Left    = #True : EndIf
          If Flags & #GR_TOP    : GadgetResize()\Lock_Top     = #True : EndIf
          If Flags & #GR_RIGHT  : GadgetResize()\Lock_Right   = #True : EndIf
          If Flags & #GR_BOTTOM : GadgetResize()\Lock_Bottom  = #True : EndIf
          If Flags & #GR_HCENTER
            X = (WinWidth - GadgetWidth(GadgetID)) / 2
            GadgetResize()\HCenter = #True
          Else
            X = GadgetX(GadgetID)
          EndIf
          If Flags & #GR_VCENTER
            Y = (WinHeight - GadgetHeight(GadgetID)) / 2
            GadgetResize()\VCenter = #True
          Else
            Y = GadgetY(GadgetID)
          EndIf
          If GadgetResize()\Lock_Left   = #False : GadgetResize()\Left   = WinWidth  - X : EndIf
          If GadgetResize()\Lock_Top    = #False : GadgetResize()\Top    = WinHeight - Y : EndIf
          If GadgetResize()\Lock_Right  = #True  : GadgetResize()\Right  = WinWidth  - (X + GadgetWidth(GadgetID))  : EndIf
          If GadgetResize()\Lock_Bottom = #True  : GadgetResize()\Bottom = WinHeight - (Y + GadgetHeight(GadgetID)) : EndIf
          ResizeGadget(GadgetID, X, Y, #PB_Ignore, #PB_Ignore)
        EndIf
      EndIf
    EndIf
  EndProcedure

  Procedure RemoveGadget(WindowID, GadgetID.i) ; Stop resizing gadget
    ForEach GadgetResize()
      If GadgetResize()\GadgetID = GadgetID
        If WindowID = GadgetResize()\WindowID
          DeleteElement(GadgetResize())
          Break
        EndIf
      EndIf
    Next
  EndProcedure

  BindEvent(#PB_Event_SizeWindow, @GadgetResize_WindowHandler())

EndModule

CompilerIf #PB_Compiler_IsMainFile
 
  #Window = 0
  Enumeration
    #Button_0
    #Button_1
    #Button_2
    #Button_3
    #Button_4
    #Listview_0
  EndEnumeration
 
  If OpenWindow(#Window, 358, 178, 300, 300, "Resize Test",  #PB_Window_SizeGadget | #PB_Window_SystemMenu | #PB_Window_TitleBar | #PB_Window_ScreenCentered )
    ButtonGadget(#Button_0, 5, 5, 50, 25, "Resize -")
    ButtonGadget(#Button_1, 245, 5, 50, 25, "Resize +")
    ButtonGadget(#Button_2, 5, 240, 50, 25, "Button2")
    ButtonGadget(#Button_3, 245, 240, 50, 25, "Button3")
    ListViewGadget(#Listview_0, 55, 30, 190, 210)
    ButtonGadget(#Button_4, 5, 270, 80, 25, "Center")
    WindowBounds(#Window, 200, 200, 400, 500)
   
    GadgetResize::AddGadget(#Window, #Button_0, GadgetResize::#GR_LEFT | GadgetResize::#GR_TOP)
    GadgetResize::AddGadget(#Window, #Button_0, GadgetResize::#GR_LEFT | GadgetResize::#GR_TOP)
    GadgetResize::AddGadget(#Window, #Button_1, GadgetResize::#GR_TOP | GadgetResize::#GR_RIGHT)

    UseModule GadgetResize
    AddGadget(#Window, #Button_2, #GR_LEFT | #GR_BOTTOM)
    AddGadget(#Window, #Button_3, #GR_RIGHT | #GR_BOTTOM)
    AddGadget(#Window, #Listview_0, #GR_LEFT | #GR_TOP | #GR_RIGHT | #GR_BOTTOM)
    AddGadget(#Window, #Button_4, #GR_HCENTER)
    UnuseModule GadgetResize
   
    ExitWindow = #False
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow
          ExitWindow = #True
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Button_0
              ResizeWindow(#Window, #PB_Ignore, #PB_Ignore, 250, 250)
            Case #Button_1
              ResizeWindow(#Window, #PB_Ignore, #PB_Ignore, 350, 400)
          EndSelect
      EndSelect
    Until ExitWindow
    CloseWindow(#Window)
  EndIf
CompilerEndIf
; IDE Options = PureBasic 5.31 (Windows - x86)
; Folding = -
; EnableUnicode
; EnableXP