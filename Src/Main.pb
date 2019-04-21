; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; 'Difference Engine' patch generator v0.35
; Developed in 2010 by Guevara-chan
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

; TO.DO[
; Добавить возможность отключения валидации файлов.
; Добавить возможность отключения резервного копирования.
; Добавить поддержку множественных файлов для патчинга.
; Улучшить возможность ручного задания шаблона поиска.
; Добавить запрос на перезапись существующего файла.
; Улучшить интерфейс.
; ]TO.DO

IncludeFile "DiffGUI.pb"
EnableExplicit
Import "" ; Kernel32.lib
AttachConsole(dwProcessId)
EndImport

CompilerIf #PB_Compiler_Version => 540
UseCRC32Fingerprint() ; Legacy codec.
CompilerEndIf

;{ Definitions
; --Enumerations--
Enumeration ; Files
#fVoid
#fEtalone
#fPatched
#fOutput
#fIcon
EndEnumeration

; --Constants--
#FieldsCount = 8-1 ; Количество полей.
#EXEFiles    = "EXEcutable files (*.exe)|*.exe"
#ICOFiles    = "Icon files (*.ico)|*.ico"
#ExtraTypes  = "|Dynamic-link libraries (*.dll)|*.dll|Screen savers (*.scr)|*.scr"
#AllFiles    = "|All files (*.*)|*.*"
#FullPattern = #EXEFiles + #ExtraTypes + #AllFiles
#EXEPattern  = #EXEFiles + #AllFiles
#ICOPattern  = #ICOFiles + #AllFiles
#RedLetters   = #FOREGROUND_RED|#FOREGROUND_INTENSITY
#GreenLetters = #FOREGROUND_GREEN|#FOREGROUND_INTENSITY
#GrayLetters  = #FOREGROUND_RED|#FOREGROUND_GREEN|#FOREGROUND_BLUE

; --Structures--
Structure EventData
Type.i
SubType.i
Gadget.i
EndStructure

Structure LayerBase ; System support.
bWidth.a
bHeight.a
bColorCount.a
bReserved.a
wPlanes.u
wBitCount.u
dwBytesInRes.l
EndStructure

Structure IconLayer  Extends LayerBase
dwBytesOffset.l
EndStructure

Structure GroupLayer Extends LayerBase
nID.u
EndStructure

Structure HeaderBase ; System support.
idReserved.u         ; Reserved (must be 0)  
idType.u             ; Resource Type (1 for icons)  
idCount.u            ; How many images?  
EndStructure

Structure IcoHeader Extends HeaderBase
idEntries.IconLayer[0] ; An entry for each image.
EndStructure

Structure GroupHeader Extends HeaderBase
idEntries.GroupLayer[0] ; An entry for each image.
EndStructure

; --Varibales--
Global PatternPos.i
Global GUIEvent.EventData
Global *Out ; Указатель выходного потока.
Global.i FIndex, GenTrigger, BreakFlag, ExitCode
Global Dim Fields.Point(#FieldsCount) ; Массив полей.
;} EndDefinitions

;{ Procedures
;{ --GUI management--
Procedure ReceiveEvent(*Container.EventData)
With *Container
\Type = WaitWindowEvent()
\SubType = EventType()
If \Type = #PB_Event_Gadget
\Gadget = EventGadget()
Else : \Gadget = #Null
EndIf
EndWith
EndProcedure

Procedure FieldFiller(*FieldID, Target.s, Pattern.s, PPos, Saving = #False)
If Saving : Define FName.s
FName = SaveFileRequester("Select location for " + Target + " file:",GetGadgetText(*FieldID), Pattern, PPos)
If FName And LCase(GetExtensionPart(FName)) <> "exe" And SelectedFilePattern() = 0 : FName + ".exe" : EndIf
Else : FName = OpenFileRequester("Locate "+Target+" file:",GetGadgetText(*FieldID), Pattern, PPos)
If PPos <> - 1 : PatternPos = SelectedFilePattern() : EndIf ; Сохраняем выбранный шаблон.
EndIf : If FName : SetGadgetText(*FieldID, FName) : EndIf
EndProcedure

Macro ShowAbout() ; Pseudo-procedure.
#ProgramSig = "'Difference Engine' patch generator v0.35"
#AuthorSig  = "Developed in 2010 by Chrono Syndrome"
MessageRequester("About me:", #ProgramSig + #CR$ + #AuthorSig, #MB_ICONINFORMATION)
EndMacro

Procedure.s LocateTarget()
Define Etalone.s = GetGadgetText(#EtaloneFile)
If Etalone ; Если таки введено имя файлу-эталону...
ProcedureReturn GetFilePart(Etalone)
Else : ProcedureReturn "...[No file selected]..."
EndIf
EndProcedure

Macro PutChar(InPtr, OutPtr) ; Partializer.
OutPtr\C = InPtr\C : OutPtr + SizeOf(Character)
EndMacro

Procedure.s RefineReg(Text.s)
Define *Char.Character = @Text, *COut.Character = @Text, Slash.i 
With *Char
While \C ; Пока не конец строки.
Select \C ; Анализируем символ.
Case '\' ; Если это разделитель...
If Slash = #False : PutChar(*Char, *COut) : Slash = #True : EndIf
Default : PutChar(*Char, *COut) : Slash = #False ; Копируем символ.
EndSelect : *Char + SizeOf(Character)
Wend : *COut\C = 0 : ProcedureReturn Text
EndWith
EndProcedure

Procedure.s ValidateField(FieldID, Text.s)
If Text = "" ; Если поле представляет пустым...
Select FieldID ; Анализируем индекс.
Case #TitleField  : ProcedureReturn "=[Generic patcher]="
Case #TargetField : ProcedureReturn LocateTarget()
; ...
EndSelect
EndIf
ProcedureReturn Text ; Стандартный результат.
EndProcedure

Macro ValidateTarget() ; Partializer.
SetGadgetText(#TargetField, LocateTarget())
EndMacro

Macro NormalizeField(FieldID) ; Pseudo-procedure.
If GUIEvent\SubType = #PB_EventType_Change ; Проверяем поле на изменение.
Define SStart, SEnd, Gadget = GUIEvent\Gadget
Define Text.s = RTrim(GetGadgetText(Gadget))
If Text ; Если в поле есть какой-то текст...
SendMessage_(GadgetID(Gadget), #EM_GETSEL, @SStart, @SEnd)
Define TabLen = Len(Text) : Text = LTrim(Text)
If FieldID = #RegistryField : Text = RefineReg(Text) : EndIf
TabLen - Len(Text) ; Досчитываем размер удаленных пробелов.
If SStart <= TabLen : SEnd - SStart ; Корректируем конец выделения.
SStart = 0 ; Корректируем начало выделения.
EndIf
SetGadgetText(Gadget, Text) ; Выставляем новое значение.
SendMessage_(GadgetID(Gadget), #EM_SETSEL, SStart, SEnd)
Else : SetGadgetText(Gadget, ValidateField(Gadget, Text)) ; Выставляем заменитель.
EndIf
EndIf
EndMacro

Procedure MessageOut(Title.s, Text.s, Flags = #False, Color = #GrayLetters)
Define Dummy ; Кол-во вписанных байт.
If GenTrigger <> 'Mute' ; Если не включен "тихий" режим...
MessageRequester(Title, Text, Flags)
Else : Text = Title + " " + Text + #CRLF$ ; Конкатенция.
SetConsoleTextAttribute_(*Out, Color) ; Выставляем цвет.
WriteFile_(*Out, @Text, StringByteLength(Text), @Dummy, 0)
EndIf
EndProcedure
;}
;{ --Patching process--
CompilerIf #PB_Compiler_Version => 540 ; Не было печали - апдейтов накачали.
Macro CRC32FileFingerprint(File) ; Pseudo-procedure.
Val("$"+FileFingerprint(File, #PB_Cipher_CRC32))
EndMacro
CompilerEndIf

Macro ShowError(ErrorMsg) ; Pseudo-procedure.
ExitCode = -1 : MessageOut("Critical error:", ErrorMsg, #MB_ICONERROR, #RedLetters)
EndMacro

Procedure IsValidIcon(*FileID, FileName.s)
If ReadLong(*FileID) = $10000 ; Если заголовок валиден...
If Lof(*FileID) >= SizeOf(IcoHeader) + ReadUnicodeCharacter(*FileID) * SizeOf(IconLayer)
CloseFile(*FileID) ; Закрываем файл для теста.
If LoadImage(0, FileName) ; Если удалось загрузить иконку...
FreeImage(0) : ReadFile(*FileID, FileName) ; Возвращаем все обратно
ProcedureReturn #True ; Рапортуем успех.
EndIf
EndIf
EndIf
EndProcedure

Procedure UseFile(FName.s, *FileID, Target.s, Mode = 'None')
Define Result
If FName ; Если указан путь к файлу.
If *FileID = #Null ; Копирование шаблона
If CopyFile("Resources\Template.app", FName) : ProcedureReturn #True
Else : ShowError("Unable to create '" + GetFilePart(FName) + "' !")
EndIf
Else ; Открытие файла на чтение.
If FileSize(FName) ; Если файл не пустой...
If ReadFile(*FileID, FName)
If Mode = 'Icon' : If IsValidIcon(*FileId, FName) ; Проверка иконки...
ProcedureReturn #True ; Рапортуем об успешной проверке.
Else : ShowError("Invalid icon file '" + GetFilePart(FName) + "' !")
EndIf
Else : ProcedureReturn #True ; Рапортуем успех.
EndIf 
Else : ShowError("Unable to open '" + GetFilePart(FName) + "' !")
EndIf
Else : ShowError("Unable to accept empty " + Target + " file !")
EndIf
EndIf
; Вывод сообщения о пустом поле.
ElseIf Mode = 'None' : ShowError("Path to " + Target + " file not specified !")
EndIf
EndProcedure

Procedure AppendString(Text.s)
Define Temp.s = Text     ; Accumulator.
WriteInteger(#fOutput, StringByteLength(Text))
CharToOem_(@Temp, @Text) ; Conversion.
WriteString(#fOutput, Text)
EndProcedure

Procedure.s TempFileName(TmpDir.S, Prefix.s, Postfix.s = ".tmp")
Repeat : Define I, FileName.s = TmpDir + "\" + Prefix
For I = 1 To 5 : FileName + Chr(Random('z' - 'a') + 'a')
Next I : FileName + Postfix
Until FileSize(FileName) = -1
ProcedureReturn FileName
EndProcedure

Macro NewStream(Offset = 1) ; Partializer
WriteInteger(#fOutput, Loc(#fEtalone) - Offset) ; Записываем смещение.
Position\X = Loc(#fOutput) ; Записываем адрес потока.
WriteInteger(#fOutput, 0) ; Резервируем место под длину.
EndMacro

Macro FinishStream() ; Partializer
Position\Y = Stream : Stream = 0 ; Записываем размер потока.
AddElement(Streams()) ; Добавляем новый элемент в список.
Streams() = Position ; Записываем данные в список.
EndMacro

Procedure FindDifferences()
Define Stream, Position.Point
NewList Streams.Point()
While Not Eof(#fEtalone)
Define Byte.b = ReadByte(#fPatched)
If ReadByte(#fEtalone) = Byte ; Если байты идентичны...
If Stream : FinishStream() : EndIf ; Если сейчас пишется поток различий - кончить.
ElseIf Stream = 0 : Stream = 1 : NewStream() ; Если байты различны...
WriteByte(#fOutput, Byte) ; Записываем первый байт различий.
Else : WriteByte(#fOutput, Byte) ; Записываем байт различий.
Stream + 1 ; Инкрементируем счетчик.
EndIf
Wend
; Проверяем на лишние байты:
If Not Eof(#fPatched) ; Eсли не все описали...
If Stream = 0 : NewStream(0) : EndIf ; Начинаем описание потока.
While Not Eof(#fPatched) : WriteByte(#fOutput, ReadByte(#fPatched)) : Stream + 1 : Wend
EndIf : If Stream : FinishStream() : EndIf
; Дописываем адреса.
ForEach Streams() : Position = Streams()
FileSeek(#fOutput, Position\X)
WriteInteger(#fOutput, Position\Y)
Next ; Возвращаем количество потоков.
ProcedureReturn ListSize(Streams())
EndProcedure

Macro InfuseIcon(IconFile, Updater) ; Pseudo-procedure.
Define IconSize = Lof(IconFile) ; Читаем размер иконки.
Define *IconHeader.IcoHeader = AllocateMemory(IconSize) ; Выделяем память.
ReadData(IconFile, *IconHeader, IconSize) ; Читаем данные заголовка.
Define *GroupData.GroupHeader = *IconHeader ; Получаем данные для группы.
Define I, ToFix = *IconHeader\idCount - 1 ; Готовим цикл.
For I = 0 To ToFix ; Перечисляем слои.
Define *Layer.IconLayer = *IconHeader\idEntries[I] ; Получаем данные слоя.
UpdateResource_(Updater, #RT_ICON, I, 1033, *IconHeader + *Layer\dwBytesOffset, *Layer\dwBytesInRes)
Define *GroupEntry.GroupLayer = *GroupData\idEntries[I] ; Получаем данные группы.
MoveMemory(*Layer, *GroupEntry, SizeOf(LayerBase)) ; Копируем основные данные слоя.
*GroupEntry\nID = I ; Задаем идентефикатор.
Next I
UpdateResource_(Updater,#RT_GROUP_ICON,1,1033,*GroupData,SizeOf(GroupHeader)+*IconHeader\idCount*SizeOf(GroupLayer))
FreeMemory(*IconHeader) ; Высвобождаем память
EndMacro

Procedure IsValidTarget(Target.s)
If FindString(Target, "|", 1) ; Если шаблон некорректен...
ShowError("Compound patterns couldn't be used for targetting (yes) !")
Else : ProcedureReturn #True
EndIf
EndProcedure

Procedure GeneratePatcher()
; Подготовка временного файла.
Define TempFile.s = Space(#MAX_PATH)
GetTempPath_(#MAX_PATH, @TempFile)
TempFile = TempFileName(TempFile, "Temporary data (", ").dat")
Define Result = #False
; Fields reading.
Define Etalone.s = GetGadgetText(#EtaloneFile)
Define Patched.s = GetGadgetText(#PatchedFile)
If CompareMemoryString(@Etalone, @Patched, #PB_String_NoCase) ; Если заданы разные файлы...
Define Output.s  = GetGadgetText(#OutputFile)
Define Icon.s    = GetGadgetText(#IconFile)
; Открытие файлов.
If UseFile(Etalone, #fEtalone, "etalone")
If UseFile(Patched, #fPatched, "patched")
If UseFile(Icon   , #fIcon,    "icon", 'Icon')
If UseFile(Output,  #fVoid,    "output")
Define Target.s = GetGadgetText(#TargetField)
If IsValidTarget(Target.s) ; Проверка шаблона поиска на валидность.
; Послединие проверки.
Define CRC32 = CRC32FileFingerprint(Etalone)
If CRC32FileFingerprint(Patched) <> CRC32 ; Если файлы разные...
Define FSize = Lof(#fEtalone)
If FSize <= Lof(#fPatched) ; Если файл не стал меньше после патча...
If CreateFile(#fOutput, TempFile) ; Начинаем работу...
; Записываем заголовок.
AppendString(GetGadgetText(#InfoField))  ; Записываем информацию патчера.
AppendString(Target)                     ; Записываем шаблон к поиску.
AppendString(GetGadgetText(#TitleField)) ; Записываем название патчера.
AppendString(GetGadgetText(#RegistryField)) ; Записываем путь до хранилища пути.
WriteInteger(#fOutput, CRC32)      ; Записываем CRC изначального файла.
WriteInteger(#fOutput, FSize)      ; Записываем размер изначального файла.
Result = FindDifferences() ; Записываем данные о различия файла.
If Result ; Если различия найдены...
CloseFile(#fOutput) ; Закрываем файл временных данных.
ReadFile(#fOutput, TempFile) ; Открываем временный файл на чтение.
FSize = Lof(#fOutput) ; получаем размер временного файла.
Define *TempData = AllocateMemory(FSize) ; Выделяем данные для файла.
ReadData(#fOutput, *TempData, FSize) ; Читаем данные из временного файла.
Define *Update = BeginUpdateResource_(Output, #True) ; Обновляем ресурсы.
UpdateResource_(*Update, #RT_RCDATA, @"PATCH_DATA", 0, *TempData, FSize)
If IsFile(#fIcon) : InfuseIcon(#fIcon, *Update) : EndIf ; Если файл иконки таки открыт...
EndUpdateResource_(*Update, #False) ; Заканчиваем обновление.
MessageOut("Work complete:","Patcher ('"+GetFilePart(Output)+"') successfully created !",#MB_ICONWARNING,#GreenLetters)
Else : ShowError("No differnce found between choosen files !") ; Различий не найдено.
EndIf
CloseFile(#fOutput)  ; Закрыть временный файл.
DeleteFile(TempFile) ; Удаляем временный файл.
Else : ShowError("No temporary storage present !")
EndIf
Else : ShowError("Patched file can't be smaller zen original one !")
EndIf
Else : ShowError("Patched file should have different CRC zen original one !")
EndIf ; Зaкрываем и удаляем файл, если что-то пошло не так...
If Result = #False : DeleteFile(Output) : EndIf ; Удаляем патчер в случае ошибки.
EndIf
EndIf : DisableDebugger : CloseFile(#fIcon) : EnableDebugger ; Закрываем файл иконки.
EndIf : CloseFile(#fPatched) ; Закрываем отпатченный файл.
EndIf : CloseFile(#fEtalone) ; Закрываем файл эталона.
EndIf
Else : ShowError("Stupid user encountered !")
EndIf
EndProcedure
;}
;{ --Parsing management--
Macro ShiftPtr() ; Partializer.
*Text\I + SizeOf(Character) ; Перевод изначального указателя.
EndMacro

Procedure ParsingError(Text.s)
MessageRequester("CLI error:", Text + #CR$ + "Parsing aborted !", #MB_ICONERROR)
BreakFlag = #True ; Выставляем флаг ошибки.
GenTrigger = 0 ; Убиваем триггер.
EndProcedure

Macro NormalizeWord(Word) ; Pseudo-procedure.
ReplaceString(Word, #CRLF$, "`n")
EndMacro

Procedure.s ExtractWord(*Text.Integer)
Define Special.i, Word.S, Block.c, *Char.Character = *Text\I
With *Char
While \C ; Пока не найдено окончание строки...
If Special ; Если включен спец. режим...
Select \C ; Aнализируем символ как специальный.
Case 'n', 'N' : Word + #CRLF$ ; Добавляем перенос строки.
Default : Word + Chr(\C) ; Просто дбавляем этот символ.
EndSelect : Special = #False ; Убираем флаг.
Else ; Обычная анализация.
Select \C ; Анализируем символ
Case ' ', #TAB ; Разделитель найден.
If Block.c = 0 ; Если не парсится блок...
If Word : ShiftPtr() : ProcedureReturn Word : EndIf ; Возвращаем результат.
Else : Word + Chr(\C) ; Дописываем разделитель.
EndIf
Case '"', 39 ; Надена граница блока.
Word + Chr(\C) ; Дописываем разделитель блоков.
If Block.c = 0 : Block.c = \C ; Открыть блок.
Else : ShiftPtr() : ProcedureReturn Word ; Возвращаем слово.
EndIf
Case '`' : Special = #True ; Найден специальный символ.
Case Block ; Найдено окончание блока.
ProcedureReturn Word ; Возвращаем результат.
Default : Word + Chr(\C) ; Просто дописываем символ.
EndSelect
EndIf
*Char + SizeOf(Character) : ShiftPtr() ; Сдвигаем позиции.
Wend
EndWith
If Block : ParsingError("Unfinished (d)quote block encountered.")
ElseIf Special : ParsingError("Command-line couldn't end with '`'")
Else : ProcedureReturn Word ; Возвращаем что напарсилось.
EndIf
EndProcedure

Procedure.s ExtractPrefix(Text.s)
Define CutPos = FindString(Text, ":=", 1)
If CutPos : ProcedureReturn Left(Text, CutPos) : EndIf
EndProcedure

Procedure.s CutPrefix(Text.s)
Define CutPos = FindString(Text, ":=", 1)
If CutPos : ProcedureReturn Right(Text, Len(Text) - CutPos - 1) : EndIf
EndProcedure

Procedure.s RemoveQuotes(Text.s)
Define Start = 1, Finish = Len(Text), *Char.Character = @Text
If *Char\C = '"' Or *Char\C = 39 : Start + 1 : EndIf
*Char + StringByteLength(Text) - SizeOf(Character)
If *Char\C = '"' Or *Char\C = 39 : Finish - Start : EndIf
ProcedureReturn Mid(Text, Start, Finish)
EndProcedure

Macro RegField(FieldID) ; Pseudo-procedure.
Fields(FIndex)\Y = FieldID : FIndex + 1
EndMacro

Macro RegisterFields(Arr) ; Pseudo-procedure.
RegField(#EtaloneFile) : RegField(#PatchedFile) : RegField(#OutputFile)
RegField(#TitleField)  : RegField(#IconFile)    : RegField(#TargetField)
RegField(#RegistryField) : RegField(#InfoField)
FIndex = 0 ; Обнуляем индексатор.
EndMacro

Procedure SetField(Index, Text.s, Trim = #True, Loop = #False)
If Trim : Text = ReplaceString(Trim(Text), #CRLF$, "") : EndIf ; Обрезаем.
Retry: ; ...И да, это метка.
If Fields(Index)\X = #False ; Если поле еще не заполенено...
Define FieldID = Fields(Index)\Y ; Получаем индекс поля.
SetGadgetText(FieldID, ValidateField(FieldID, Text)) ; Выставляем полю значение.
Fields(Index)\X = #True ; Выставляем флаг.
ProcedureReturn Index + 1 ; Рапортуем успех.
ElseIf Loop = #False : ParsingError("Field is already set for: " + NormalizeWord(Text))
EndIf
If Loop And Index < #FieldsCount : Index + 1 : Goto Retry : EndIf ; Идем циклом по индексам.
EndProcedure

Procedure SetTrigger(Word.s, NewVal)
If GenTrigger = '' : GenTrigger = NewVal
Else : ParsingError("Dissonant directive found: " + NormalizeWord(Word))
EndIf
EndProcedure

Macro TooMuchArgs() ; Partializer.
ParsingError("Too much arguments: " + NormalizeWord(Word))
EndMacro

Macro AnalyzeWord(Word) ; Partializer.
Select LCase(Word) ; Анализируем...
Case "/cli"        : SetTrigger(Word, 'DoIt')
Case "/cli:silent" : SetTrigger(Word, 'Mute')
*Out = GetStdHandle_(#STD_OUTPUT_HANDLE) : AttachConsole(-1)
Case "/now"        : SetTrigger(Word, '/now')
Default : ; Выставляем следующее поле...
Define Trim.i ; Флаг обрезки.
If FIndex <= #FieldsCount ; Если еще не все поля заполнены...
If Fields(FIndex)\Y = #InfoField : Trim = #False : Else : Trim = #True : EndIf
FIndex = SetField(FIndex, Word, Trim, #True) ; Выставляем поле и сдвигаем индекс.
If FIndex = 0 : TooMuchArgs() : EndIf ; Рапортуем переизбыток.
Else : TooMuchArgs() ; Сразу рапортуем переизбыток аргументов.
EndIf
EndSelect
EndMacro

Macro ParseCL() ; Pseudo-procedure.
Define Text.s = Trim(PeekS(GetCommandLine_()))
If Text ; Если есть, что анализировать...
RegisterFields(Fields) ; Регистратор полей.
Define *Char.Character = @Text ; Запоминаем адрес первого символа.
ExtractWord(@*Char) ; Сразу вытаксиваем имя .EXE
Repeat : Define Word.s = ExtractWord(@*Char) ; Вытаскиваем следующее слово.
If Word = "" : Break : EndIf ; Выходим, если достигнут конец строки.
Define Prefix.s = ExtractPrefix(Word) ; Вытаскиваем из слова префикс.
If Prefix : Word = CutPrefix(Word) : EndIf ; Вырезаем его оттуда, если есть.
Word = RemoveQuotes(Word) ; Убираем символы блока (кавычки\апострофы).
Select LCase(Prefix) ; Анализируем префикс.
Case ""    : AnalyzeWord(Word) ; Префикса нет - анализируем слово.
Case "/e:" : SetField(0, Word) ; Файл эталона (принудительно).
Case "/p:" : SetField(1, Word) ; Патченный файл (принудительно).
Case "/o:" : SetField(2, Word) ; Выходной файл (принудительно).
Case "/t:" : SetField(3, Word) ; Название проекта (принудительно).
Case "/i:" : SetField(4, Word) ; Файл иконки (принудительно).
Case "/*:" : SetField(5, Word) ; Шаблон поиска (принудительно).
Case "/r:" : SetField(6, Word) ; Хранилище пути в регистре (принудительно).
Case "/a:" : SetField(7, Word, 0) ; Доп. описание (принудительно).
Default : ParsingError("Invalid prefix: " + NormalizeWord(Prefix) + "=")
EndSelect
Until BreakFlag ; Выходим на ошибке.
EndIf
If GenTrigger ; Если активирован триггер...
GeneratePatcher() ; Сразу запускаем генерацию.
If GenTrigger <> '/now' ; Если надо выходить...
If GenTrigger = 'Mute' : SetConsoleTextAttribute_(*Out, #GrayLetters) : EndIf
End ExitCode ; Выходим из программы.
EndIf 
EndIf : HideWindow(#MainWindow, #False) ; Показываем окно.
EndMacro
;}
;} EndProcedures

; ==Main loop==
Define FixDir.s = GetPathPart(ProgramFilename()) ; На случай cmd и тому подобного.
If FixDir <> GetTemporaryDirectory() : SetCurrentDirectory(FixDir) : EndIf
OpenWindow_MainWindow()
ParseCL() ; CLI management.
Repeat : ReceiveEvent(GUIEvent)
Select GUIEvent\Type
Case #PB_Event_Gadget 
Select GUIEvent\Gadget
; Buttons.
Case #Button_Etalone  : FieldFiller(#EtaloneFile, "unpatched",        #FullPattern, PatternPos)
ValidateTarget() ; Выставляем новое значение графе "Patching target".
Case #Button_Patched  : FieldFiller(#PatchedFile, "already patched",  #FullPattern, PatternPos)
Case #Button_Output   : FieldFiller(#OutputFile , "output patcher's", #EXEPattern , -1, #True)
Case #Button_Icon     : FieldFiller(#IconFile   , "icon",             #ICOPattern , -1)
Case #Button_Generate : GeneratePatcher()
Case #Button_About    : ShowAbout()
Case #Button_Quit     : End
; Fields.
Case #TargetField, #TitleField, #EtaloneFile, #PatchedFile, #OutputFile, #IconFile, #RegistryField
NormalizeField(GUIEvent\Gadget) ; Очищение поля.
If GUIEvent\Gadget = #EtaloneFile : ValidateTarget() : EndIf ; Корректируем графу "Patching target".
EndSelect
Case #PB_Event_CloseWindow : End
EndSelect
ForEver
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; Folding = 74f--
; UseIcon = ..\Resources\gear-icon.ico
; Executable = ..\Difference Engine.exe
; CurrentDirectory = ..\