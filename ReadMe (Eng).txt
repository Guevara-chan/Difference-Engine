*-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-*
Title: Difference Engine
Version: v0.35 (Alpha)
Distribution: FreeWare OpenSource
Dev. environment: PureBASIC v5.20
*-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-*

~Available command line arguments:
/e:=%FileName% -> set value for "Etalone file" field.
/p:=%FileName% -> set value for "Patched file" field.
/o:=%FileName% -> set value for "Output file" field.
/t:=%Text%     -> set value for "Project's title" field.
/i:=%FileName% -> set value for "Project's icon" field.
/*:=%Pattern%  -> set value for "Patching target" field.
/r:=%RegPath%  -> set value for "Registry patholder" field.
/a:=%Text%     -> set value for "Additional info" field.
/now -> Send received data for processing. Trigger.
/cli -> Send received data for processing, then the exit. Trigger.
/cli:silent -> send received data for "silent" processing, then exit. Trigger.

Note #1: if argument doesn't fall under listed classification, it will be used to fill one of free fields.
Note #2: for correct delivery of the space-containing arguments, they should be enclosed in quotation marks or apostrophes.
Note #3: for correct delivery of quote/apostrophe-containing text, they should be preceded by ' symbol.
Note #4: for correct delivery of newline-characters, they should be replaced with `n combination.
Note #5: results of "silent" patcher generation would be written to standard output.
Note #6: there should not be more than one trigger-argument in command line.
