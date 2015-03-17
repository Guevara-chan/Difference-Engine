; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Difference Engine: patcher's template
; Developed in 2010 by Guevara-chan.
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

EnableExplicit ; Essential.

;{ --Definitions--
; ==Structures==
Structure DataPtr
StructureUnion 
I.I : B.B ; Fields.
EndStructureUnion
EndStructure

Structure PatchInfo
CRC32.i
FileSize.i
FileName.s
ExtraInfo.s
ConsoleTitle.s
InstallHolder.s
EndStructure

; ==Variables==
Global *PatchData.DataPtr, *EndPtr
Global PatchInfo.PatchInfo

; ==Procedures==
Procedure ThrowError(Message.s)
ConsoleColor(12, 0) : PrintN("ERROR: " + Message + " !")
EndProcedure

Procedure.i ExtractInt()
Define I.i = *PatchData\I
*PatchData + SizeOf(Integer)
ProcedureReturn I
EndProcedure

Procedure.b ExtractByte()
Define B.b = *PatchData\B
*PatchData + SizeOf(Byte)
ProcedureReturn B
EndProcedure

Procedure.s ExtractString()
Define Size = ExtractInt()
Define Text.s = PeekS(*PatchData, Size / SizeOf(Character))
*PatchData + Size : ProcedureReturn Text
EndProcedure

Macro ParseInfo() ; Pesudo-procedure
OpenConsole()
Define *Res = FindResource_(0, "PATCH_DATA", #RT_RCDATA)
*PatchData = LockResource_(LoadResource_(0, *Res))
*EndPtr = *PatchData + SizeofResource_(0, *Res)
PatchInfo\ExtraInfo     = ExtractString()
PatchInfo\FileName      = ExtractString()
PatchInfo\ConsoleTitle  = ExtractString()
PatchInfo\InstallHolder = ExtractString()
PatchInfo\CRC32         = ExtractInt()
PatchInfo\FileSize      = ExtractInt()
EndMacro

Macro ShowDelimiter() ; Partializer.
ConsoleColor(15, 0) : PrintN("------")
EndMacro

Procedure PatchUP(FileName.s)
If FileName ; Если имя файлу вообще задано...
Define FName.s = GetFilePart(FileName) ; Выделяем имя файла.
Select FileSize(FileName) ; Анализируем размер файла.
Case PatchInfo\FileSize ; Если он идентичен необходимому...
If PatchInfo\CRC32 = CRC32FileFingerprint(FileName) ; Если CRC совпадает...
If OpenFile(0, FileName) ; Открываем файл на чтение.
ConsoleColor(14, 0) : PrintN(#CRLF$ + "Patching '" + FName + "'...")
ConsoleColor(7, 0) : Define NewName.s = FileName.s + ".bak"
CopyFile(FileName, NewName) ; Создаем back-up и рапортуем:
PrintN("Backup file '" + GetFilePart(NewName) + "' created.")
ShowDelimiter() : ConsoleColor(7, 0) ; Рисуем разделитель.
While *PatchData < *EndPtr ; While there are some data for patching...
FileSeek(0, ExtractInt()) ; Переходим на смещение для патчинга.
Print(RSet(Hex(Loc(0)), 8, "0") + ": ...")
Define I, StreamSize = ExtractInt() ; Вытаскиваем размер последовательности.
For I = 1 To StreamSize : WriteByte(0, ExtractByte()) : Next I
PrintN(Str(StreamSize) + " bytes succesfully patched.") ; Рапорт.
Wend : ProcedureReturn #True ; Сигнализируем успех.
CloseFile(0) ; Закрываем файл на всякий пожарный.
Else : ThrowError("Unable to open '" + FName + "'")
EndIf
Else : ThrowError("CRC32 mismatches required one")
EndIf
Case -1, -2 : ThrowError("Unable to find '" + FName + "'")
Default : ThrowError("File size mismatches required one")
EndSelect
EndIf
EndProcedure

Macro Quote
"
EndMacro

Macro DefRegTrunk(Trunk) ; Partializer.
Case Quote#Trunk#Quote : ProcedureReturn #Trunk
EndMacro

Procedure TrunkName2ID(Name.s)
Select UCase(Name)
DefRegTrunk(HKEY_CLASSES_ROOT)
DefRegTrunk(HKEY_CURRENT_USER)
DefRegTrunk(HKEY_LOCAL_MACHINE)
DefRegTrunk(HKEY_USERS)
DefRegTrunk(HKEY_CURRENT_CONFIG)
EndSelect
EndProcedure

Procedure.s RegPath2String(Path.s)
Define Value.s{#MAX_PATH}, Trunk.s = StringField(Path, 1, "\"), ValType.i
Define *Hnd, Dummy = #MAX_PATH, VName.s = StringField(Path, CountString(Path, "\") + 1, "\")
Path = Mid(Path, Len(Trunk) + 2)
Path = Left(Path, Len(Path) - Len(VName))
RegOpenKeyEx_(TrunkName2ID(Trunk), @Path, 0, #KEY_READ, @*Hnd)
RegQueryValueEx_(*Hnd, @VName, 0, @ValType, @Value, @Dummy)
RegCloseKey_(*Hnd)
Select ValType ; В зависимости от типа значения...
Case #REG_EXPAND_SZ : Path = Space(#MAX_PATH)
ExpandEnvironmentStrings_(@Value, @Path, #MAX_PATH)
ProcedureReturn Path ; Возвращаем результат.
Case #REG_SZ : ProcedureReturn Value
EndSelect
EndProcedure

Procedure.s PathCombine(Part1.s, Part2.s)
Define Result.s{#MAX_PATH} : If PathCombine_(@Result, @Part1, @Part2)
ProcedureReturn Result : EndIf
EndProcedure
;}

;{ --Main code--
With PatchInfo
ParseInfo() : OpenConsole()
; Header output...
ConsoleTitle(\ConsoleTitle) ; Выставляем заголовок.
ConsoleColor(10, 0) : PrintN(\ExtraInfo)
ConsoleColor(7, 0)  : PrintN("[it's made with 'Difference Engine' patch generator, btw]" + #CRLF$)
; Target requesting:
Define TDir.s = Trim(RegPath2String(\InstallHolder)) ; Пытаемся получить путь.
If TDir = "" : TDir = GetPathPart(ProgramFilename()) : EndIf ; Берем нынешнюю директорию.
TDir = PathCombine(TDir, \FileName)               ; Дописываем для полного порядка.
Define Pattern.s = "Target file (" + \FileName + ")|" + \FileName + "|All files (*.*)|*.*"
Define FName.s = Trim(ProgramParameter())
While PatchUP(FName.s) = 0
Define FName.s = Trim(OpenFileRequester("Locate '" + \FileName + "' to apply patch:", TDir, PAttern, 0))
If FName = "" : End : EndIf : TDir = PathCombine(GetPathPart(FName), \FileName)
Wend
; Finalizing...
ShowDelimiter() ; Рисуем разделитель.
ConsoleColor(10, 0) : PrintN("Work complete !" + #CRLF$)
ConsoleColor(11, 0) : PrintN("<Exiting in 3 seconds>")
Delay(3000)
EndWith
;}
; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; ExecutableFormat = Console
; Folding = --
; EnableXP
; Executable = ..\Resources\Template.app
; DisableDebugger