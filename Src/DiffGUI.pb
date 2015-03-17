;{- Enumerations / DataSections
;{ Windows
Enumeration
  #MainWindow
EndEnumeration
;}
;{ Gadgets
Enumeration
  #Text_0
  #EtaloneFile
  #Button_Etalone
  #Text_3
  #PatchedFile
  #Button_Patched
  #Text_7
  #OutputFile
  #Button_Output
  #Text_10
  #InfoField
  #Button_Generate
  #Button_Quit
  #Button_About
  #Text_15
  #TitleField
  #IconFile
  #Text_18
  #Button_Icon
  #Text_20
  #TargetField
  #RegistryField
  #Text_23
EndEnumeration
;}
;{ Fonts
Enumeration
  #Font_Text_0
  #Font_Text_3
  #Font_Text_7
  #Font_Text_10
  #Font_Button_Generate
  #Font_Button_Quit
  #Font_Button_About
  #Font_Text_15
  #Font_Text_18
  #Font_Text_20
  #Font_Text_23
EndEnumeration
;}
;}
Procedure OpenWindow_MainWindow()
  If OpenWindow(#MainWindow, 474, 251, 325, 495, "Difference engine:", #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MinimizeGadget|#PB_Window_TitleBar|#PB_Window_Invisible|#PB_Window_MaximizeGadget|#PB_Window_ScreenCentered)
    TextGadget(#Text_0, 5, 5, 315, 20, "Etalone file:", #PB_Text_Center)
    StringGadget(#EtaloneFile, 5, 25, 266, 20, "", #PB_String_BorderLess|#WS_BORDER)
    ButtonGadget(#Button_Etalone, 270, 25, 50, 20, "Search...", #BS_FLAT)
    TextGadget(#Text_3, 5, 50, 315, 20, "Patched file:", #PB_Text_Center)
    StringGadget(#PatchedFile, 5, 70, 266, 20, "", #PB_String_BorderLess|#WS_BORDER)
    ButtonGadget(#Button_Patched, 270, 70, 50, 20, "Search...", #BS_FLAT)
    TextGadget(#Text_7, 5, 95, 315, 20, "Output file:", #PB_Text_Center)
    StringGadget(#OutputFile, 5, 115, 266, 20, "", #PB_String_BorderLess|#WS_BORDER)
    ButtonGadget(#Button_Output, 270, 115, 50, 20, "View...", #BS_FLAT)
    TextGadget(#Text_10, 5, 320, 315, 20, "Additional info:", #PB_Text_Center)
    EditorGadget(#InfoField, 5, 340, 315, 120)
    ButtonGadget(#Button_Generate, 5, 470, 80, 20, "Generate", #BS_FLAT)
    ButtonGadget(#Button_Quit, 240, 470, 80, 20, "Quit", #BS_FLAT)
    ButtonGadget(#Button_About, 122, 470, 80, 20, "About", #BS_FLAT)
    TextGadget(#Text_15, 5, 140, 315, 20, "Project's title:", #PB_Text_Center)
    StringGadget(#TitleField, 5, 160, 315, 20, "=[Generic patcher]=", #PB_String_BorderLess|#ES_CENTER|#WS_BORDER)
    StringGadget(#IconFile, 5, 205, 266, 20, "Resources\Generic.ico", #PB_String_BorderLess|#WS_BORDER)
    TextGadget(#Text_18, 5, 185, 315, 19, "Project's icon:", #PB_Text_Center)
    ButtonGadget(#Button_Icon, 270, 205, 50, 20, "Search...", #BS_FLAT)
    TextGadget(#Text_20, 5, 230, 315, 20, "Patching target:", #PB_Text_Center)
    StringGadget(#TargetField, 5, 250, 315, 20, "...[No file selected]...", #PB_String_BorderLess|#WS_BORDER)
    StringGadget(#RegistryField, 5, 295, 315, 20, "", #PB_String_BorderLess|#WS_BORDER)
    TextGadget(#Text_23, 5, 275, 315, 20, "Registry pathholder:", #PB_Text_Center)
    ; Gadget Resizing
    PureRESIZE_SetGadgetResize(#Text_0, 1, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#EtaloneFile, 1, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#Button_Etalone, 0, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#Text_3, 1, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#PatchedFile, 1, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#Button_Patched, 0, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#Text_7, 1, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#OutputFile, 1, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#Button_Output, 0, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#Text_10, 1, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#InfoField, 1, 1, 1, 1)
    PureRESIZE_SetGadgetResize(#Button_Generate, 1, 0, 0, 1)
    PureRESIZE_SetGadgetResize(#Button_Quit, 0, 0, 1, 1)
    PureRESIZE_SetGadgetResize(#Button_About, 0, 0, 0, 0)
    PureRESIZE_CenterGadget(#Button_About, 1, 0)
    PureRESIZE_SetGadgetResize(#Text_15, 1, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#TitleField, 1, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#IconFile, 1, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#Text_18, 1, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#Button_Icon, 0, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#Text_20, 1, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#TargetField, 1, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#RegistryField, 1, 1, 1, 0)
    PureRESIZE_SetGadgetResize(#Text_23, 1, 1, 1, 0)
    ; Gadget Fonts
    SetGadgetFont(#Text_0, LoadFont(#Font_Text_0, "Palatino Linotype", 10, #PB_Font_Bold|#PB_Font_HighQuality))
    SetGadgetFont(#Text_3, LoadFont(#Font_Text_3, "Palatino Linotype", 10, #PB_Font_Bold|#PB_Font_HighQuality))
    SetGadgetFont(#Text_7, LoadFont(#Font_Text_7, "Palatino Linotype", 10, #PB_Font_Bold|#PB_Font_HighQuality))
    SetGadgetFont(#Text_10, LoadFont(#Font_Text_10, "Palatino Linotype", 10, #PB_Font_Bold|#PB_Font_HighQuality))
    SetGadgetFont(#Button_Generate, LoadFont(#Font_Button_Generate, "Palatino Linotype", 9, #PB_Font_Bold|#PB_Font_HighQuality))
    SetGadgetFont(#Button_Quit, LoadFont(#Font_Button_Quit, "Palatino Linotype", 9, #PB_Font_Bold|#PB_Font_HighQuality))
    SetGadgetFont(#Button_About, LoadFont(#Font_Button_About, "Palatino Linotype", 9, #PB_Font_Bold|#PB_Font_HighQuality))
    SetGadgetFont(#Text_15, LoadFont(#Font_Text_15, "Palatino Linotype", 10, #PB_Font_Bold|#PB_Font_HighQuality))
    SetGadgetFont(#Text_18, LoadFont(#Font_Text_18, "Palatino Linotype", 10, #PB_Font_Bold|#PB_Font_HighQuality))
    SetGadgetFont(#Text_20, LoadFont(#Font_Text_20, "Palatino Linotype", 10, #PB_Font_Bold|#PB_Font_HighQuality))
    SetGadgetFont(#Text_23, LoadFont(#Font_Text_23, "Palatino Linotype", 10, #PB_Font_Bold|#PB_Font_HighQuality))
    ; Window Minimum Size
    PureRESIZE_SetWindowMinimumSize(#MainWindow, 325, 495)
    ;
    SetGadgetText(#InfoField,  "")
    SendMessage_(GadgetID(#InfoField), #EM_SETTEXTMODE, #TM_PLAINTEXT, 0)
    SetGadgetFont(#InfoField, FontID(LoadFont(#PB_Any, "Lucida Console", 8)))
    SetGadgetText(#InfoField,  "...Zere should be some info 'bout project...")
    SmartWindowRefresh(#MainWindow, #True)
    SetWindowLong_(WindowID(#MainWindow),#GWL_EXSTYLE,GetWindowLong_(WindowID(#MainWindow), #GWL_EXSTYLE)|#WS_EX_COMPOSITED)
  EndIf
EndProcedure

; IDE Options = PureBasic 5.00 Beta 3 (Windows - x86)
; Folding = -
; EnableXP