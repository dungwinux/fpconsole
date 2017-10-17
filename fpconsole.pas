{$LONGSTRINGS ON}

{$NOTE [FPConsole]. Created by Nguyen Tuan Dung (@dungwinux) and Nguyen Hoang Duong (@NOVAglow)}
{$NOTE Thanks for forking our project. Github: https://dungwinux.github.io/fpconsole}

uses Crt, SysUtils, DateUtils;

const
slash : char = {$IFDEF MSWINDOWS}'\'{$ENDIF} {$IFDEF LINUX}'/'{$ENDIF};

var
    TEMPFOLDER, Build, dir, fname: AnsiString;
    m: text;

    StartFlag, EndFlag: TDateTime;
    ExecTime: Double;

procedure InitBuild();
var s: string;
begin
    s:={$I %DATE%}+'-'+{$I %TIME%};
    while pos('/',s) <> 0 do delete(s,pos('/',s),1);
    while pos(':',s) <> 0 do delete(s,pos(':',s),1);
    delete(s,1,2);delete(s,length(s)-1,2);
    Build:=s;
end;

Procedure Help;
Begin
    Writeln('INFO: FPConsole is a tool that helps you directly input codes and get output with the Free Pascal Compiler');
    Writeln('To make it easy, you can directly throw codes as the argument or write it in a file');
    Writeln('Sometimes, when there is an error or an infinite loop and the program exited improperly, you can review the code in Temp folder folder');
    Writeln('All FPConsole Switch:');
    Writeln('-c    :   Clear temporary folder');
    Writeln('-fs   :   Read the whole file in formatted type (.pas)');
    Writeln('-f    :   Read text file with only Function and Procedure');
    Writeln('-e    :   Edit a source file in the temporary folder');
    Writeln('-edit :   Edit a source file given its path');
    Writeln('    --no-execute : No executing the program after editing the source file (used with -edit switch only & provide as the last argument)');
    Writeln('-ec   :   Specify the path of the text editor of your own choice, can only be used with -e and -edit switches only');
    Writeln('-h    :   Show this help');
    Writeln('FPConsole is an Open-Source Program. Github: dungwinux/fpconsole');
End;

Function Create: Boolean;
// Generate source file to compile
Var tmp: AnsiString;
Begin
    Randomize;
    Str(random(100000), fname);
    fname := '_' + fname;
    tmp := TEMPFOLDER;
    Create := (DirectoryExists(tmp)) or (CreateDir(tmp));
    If Create then 
    Begin
        fname := tmp + Slash + fname;
        Assign(m, fname + '.pas');
        Rewrite(m);
    End;
End;

Procedure Input(s: string);
// Pass the code to the temporary source file (is holded by the variable m)
Var f: text;
Begin
    Assign(f, s);
    {$I-} Reset(f); {$I+}
    If IOResult = 0 then 
    Begin
        While not EOF(f) do 
        Begin
            Readln(f, s);  
            Writeln(m, s);  
        End;
        Close(f);
    End;
End;

Function StrInList(s: AnsiString; A: Array of AnsiString; b: Byte): Boolean;
// Check if an ANSI string is presented in the first b elements of array A
VAR i: Byte;
Begin
    StrInList := False;
    For i := 0 to b do 
        If A[i] = s then
            Begin
                StrInList := True;
                Break;
            End;
End;

Function FineArgs: Boolean;
// Check if the passed arguments are okay
Var
    AvailableArgs: Array[1..8] of AnsiString = ('-c', '-f', '-fs', '-e', '-edit', '-ec', '-h', '--no-execute');
    UsedArgs: Array[1..5] of AnsiString;
    k, NScannedArgs: Byte;
Begin
    If Copy(ParamStr(1), 1, 1) <> '-' then Exit(True);  // Assuming ParamStr(1) till the end is code
    NScannedArgs := 0;
    FineArgs := True;
    k := 1;
    While k <= ParamCount do  // Scan arguments. We need to print all the errors, therefore this loop cannot be broken.
        Begin
        If StrInList(ParamStr(k), UsedArgs, NScannedArgs) then // If argument is duplicated
            Begin
                If StrInList(ParamStr(k), ['-f', '-fs', '-e', '-edit', '-ec'], 4) then 
                Begin
                    FineArgs := False;
                    Writeln('Error: Duplicate argument ', ParamStr(k));
                End
                else Writeln('Warning: Duplicate argument ', ParamStr(k));
            End
        else If StrInList(ParamStr(k), ['-f', '-fs', '-e', '-edit', '-ec'], 4) then  // If ParamStr(k) is a switch that needs additional argument
            Begin // Check if the next argument is another switch or the switch is already the last argument
                Inc(NScannedArgs);
                UsedArgs[NScannedArgs] := ParamStr(k);
                If (Copy(ParamStr(k + 1), 1, 1) = '-') or (k = ParamCount) then 
                Begin
                    FineArgs := False;
                    Writeln('Error: No value specified for the switch ', ParamStr(k));
                End
                else Inc(k);
            End
            else If StrInList(ParamStr(k), AvailableArgs, Length(AvailableArgs)) then // If argument is not a duplicate but is valid
            Begin
                Inc(NScannedArgs);
                UsedArgs[NScannedArgs] := ParamStr(k);
            End
            else 
            Begin
                // Not a valid argument
                FineArgs := False;
                Writeln('Error: Invalid argument ', ParamStr(k));
            End;
        Inc(k);
        End;
    // Check if -ec switch is called but neither -e not -edit is
    If (StrInList('-ec', UsedArgs, Length(UsedArgs)))
        and ((not StrInList('-e', UsedArgs, Length(UsedArgs))) or (not StrInList('-edit', UsedArgs, Length(UsedArgs)))) then 
    Begin
        FineArgs := False;
        Writeln('Error: The path to source file is not specified');
    End;
End;

Procedure EditSource;
// Open a text editor and edit the source code
VAR
    EditorPath: AnsiString;  // Assuming nano as a default editor
    SourceFilePath: AnsiString;
    i: Byte;
Begin
    EditorPath:= {$IFDEF MSWINDOWS} GetEnvironmentVariable('windir') + '\notepad.exe'{$ENDIF} {$IFDEF LINUX} '/bin/nano' {$ENDIF};
    SourceFilePath := TEMPFOLDER;
    // For i := 1 to ParamCount do
    //     Case ParamStr(i) of
    //         '-e': SourceFilePath := SourceFilePath + slash + ParamStr(i + 1);
    //         '-edit':    begin
    //                     // {$IFDEF LINUX}
    //                         If Copy(ParamStr(i + 1), 1, 1) = slash then 
    //                             SourceFilePath := ParamStr(i + 1)
    //                         else SourceFilePath := GetCurrentDir + ParamStr(i + 1);  // User provides path in local directory
    //                     // {$ENDIF}
    //                     // {$IFDEF MSWINDOWS}
    //                     // {$ENDIF}
    //                     end;
    //         '-ec':      begin
    //                     // {$IFDEF LINUX}
    //                         If Copy(ParamStr(i + 1), 1, 1) = slash  // Full path
    //                         then EditorPath := ParamStr(i + 1)
    //                         else EditorPath := GetCurrentDir + ParamStr(i + 1);  // Local path
    //                     // {$ENDIF}
    //                     // {$IFDEF MSWINDOWS}
    //                     // {$ENDIF}
    //                     end;
    //     End;
    // If not FileExists(SourceFilePath) then
    // begin
    //     Writeln('Error: No source file found.');
    //     Halt(1);
    // end 
    // else if not FileExists(EditorPath) then
    // Begin
    //     Writeln('Error: No editor found');
    //     Halt(1);
    // End
    else Begin
        fname := Copy(SourceFilePath, 1, Length(SourceFilePath) - 4);
        ExecuteProcess(EditorPath, [SourceFilePath], []);
    End;
End;

Procedure ReadDat;
// Write code to source file
Var
    i: Byte;
Begin
    If ParamStr(1) = '-fs' then Input(ParamStr(2))
    else Begin
        Write(m, 'uses ');
        Input('unit.dat');  // Get unit
        Writeln(m, 'crt;');
        Writeln(m, #13#10, 'type', #13#10, 'Int = Integer;');
        Input('type.dat');  // Get type
        Writeln(m, #13#10, 'const', #13#10, '_Default=', #39, 'FPConsole', #39, ';');
        Input('const.dat'); // Get const
        Writeln(m, #13#10, 'var', #13#10, '_nuStr:string;', #13#10, '_nInt:integer;', #13#10, '_nReal:real;', #13#10, '_nText:text;');
        Input('var.dat');   // Get var
        Writeln(m, #13#10, 'begin');
        Case ParamStr(1) of
            '-f' :  Input(ParamStr(2));
            ''   :  Help;
            else For i := 1 to ParamCount do Writeln(m, ParamStr(i));
        End;
        Write(m, 'end.');
    End;
    Close(m); 
End;

Function Get: Boolean;
// Find FPC by its default folder in installation
Var FileDat: TSearchRec;
Begin
    {$IFDEF MSWINDOWS}
    Get := DirectoryExists('C:\FPC\');
    If Get then Begin
                If FindFirst('C:\FPC\*', faDirectory, FileDat) = 0 
                    then Repeat
                            dir := FileDat.Name;
                            Until FindNext(FileDat) <> 0;
                FindClose(FileDat);
                If dir = '..' then Get := False
                    else dir := 'C:\FPC\' + dir + '\bin\i386-win32\fpc.exe';
                End;
    Get := Get and FileExists(dir);
    {$ENDIF}

    {$IFDEF LINUX}
    Get := FileExists('/usr/bin/fpc');
    If Get then dir := '/usr/bin/fpc';
    {$ENDIF}
    Writeln('Find FPC (Default):', Get);
End;

Function Find(s: string): boolean;
// Find FPC in the given directory s (passed as argument)
Var
FileDat: TSearchRec;
b: Boolean;
Begin
    s := s + slash;
    Find := DirectoryExists(s);
    If Find then Begin
        If FindFirst(s + '*', faAnyFile, FileDat) = 0 then
            Repeat 
                b := (Find and (FileDat.Name = {$IFDEF MSWINDOWS}'fpc.exe'{$ENDIF} {$IFDEF LINUX}'fpc'{$ENDIF})) 
            Until (FindNext(FileDat) <> 0) or b;
        Find := b;
        FindClose(FileDat);
    End;
End;

Function SysFind:boolean;
// Find FPC by looking in the directories specified by the PATH environment variable
Var s: AnsiString;
Begin
    s := GetEnvironmentVariable('PATH') + {$IFDEF MSWINDOWS}';'{$ENDIF} {$IFDEF LINUX}':'{$ENDIF};
    Repeat
        dir := copy(s, 1, pos({$IFDEF MSWINDOWS}';'{$ENDIF} {$IFDEF LINUX}':'{$ENDIF}, s) - 1);
        SysFind := Find(dir);
        delete(s, 1, pos({$IFDEF MSWINDOWS}';'{$ENDIF} {$IFDEF LINUX}':'{$ENDIF}, s)); 
    Until SysFind or (s = '');
    Writeln('Find FPC (Custom):', SysFind);
End;

Procedure Execute(SourceFileName: AnsiString; DelSrcFile: Boolean);
// Compile & Execute the source code (source file is holded by the m variable)
Var exitcode: integer;
Begin
    Writeln('FPC Dir:', dir);
    If (ParamStr(1) <> '') then 
    Begin
        {$IFDEF MSWINDOWS}ExecuteProcess(dir, ['-v0', SourceFileName], []);{$ENDIF}
        {$IFDEF LINUX}ExecuteProcess('/bin/bash', ['-c', 'fpc ' + SourceFileName + ' &>/dev/null']);{$ENDIF}
        If DelSrcFile then DeleteFile(SourceFileName + '.pas');
        Writeln('[OUTPUT]');
        Assign(m, SourceFileName {$IFDEF MSWINDOWS}+ '.exe'{$ENDIF});
        {$I-} Reset(m); {$I+}
        If IOResult = 0 then
        begin
            Close(m);
            DeleteFile(SourceFileName + '.o');
            StartFlag := Now;
            exitcode := ExecuteProcess(SourceFileName {$IFDEF MSWINDOWS}+ '.exe'{$ENDIF}, '', []);
            EndFlag := Now;
            DeleteFile(SourceFileName {$IFDEF MSWINDOWS}+ '.exe'{$ENDIF});
            // This may affects execute time
            // ExecTime := SecondsBetween(StartFlag, EndFlag);
            ExecTime := SecondSpan(StartFlag, EndFlag);
            writeln;
            writeln('--------------------');
            writeln('Execution Time: ', ExecTime:0:16, ' s');
            writeln('Process Exited with Exit code ', exitcode);
        End
        else Writeln('COMPILE ERROR');
    End;
End;

Procedure DeleteDir(const DirName: Ansistring);
// Delete program's temporary directory (might be non-empty) on Windows
Var
    Path: string;
    F: TSearchRec;
Begin
    Path:= DirName + '\*.*';
    If FindFirst(Path, faAnyFile, F) = 0 then 
        Repeat
            If (F.Attr and faDirectory <> 0) then 
                Begin
                    If (F.Name <> '.') and (F.Name <> '..') then
                        DeleteDir(DirName + '\' + F.Name);
                End
            else
                DeleteFile(DirName + '\' + F.Name);
        Until FindNext(F) <> 0;
    FindClose(F);
    RemoveDir(DirName);
End;

Procedure Clear;
// Remove program's temporary folder
Var tmp: AnsiString;
Begin
    tmp := TEMPFOLDER;
    If DirectoryExists(tmp) then Begin
        {$IFDEF MSWINDOWS}DeleteDir(tmp);{$ENDIF}
        {$IFDEF LINUX}ExecuteProcess('/bin/bash', ['-c', 'rm -rf ' + tmp], []);{$ENDIF}
        CreateDir(tmp);
    End;
    Writeln('TEMP folder removed.');
End;

BEGIN
    Clrscr; InitBuild;
    TEMPFOLDER := {$IFDEF MSWINDOWS}GetEnvironmentVariable('TEMP') + '\FPConsole'{$ENDIF} {$IFDEF LINUX}'/tmp/FPConsole'{$ENDIF};
    Writeln('FPConsole ', Build, ' - Created by Winux8YT3');
    Writeln('TEMP Folder: ', TEMPFOLDER);
    If ParamCount > 5 then 
    begin
        Writeln('Error: Too many arguments');
        Halt(1);
    End;
    If Not FineArgs then Halt;
    If ParamStr(1) = '-h' then Help
        else If ParamStr(1) = '-c' then Clear
        else Begin
            If StrInList('-edit', [ParamStr(1), ParamStr(2), ParamStr(3), ParamStr(4), ParamStr(5)], 4) then
                Begin
                    EditSource;
                    If ParamStr(ParamCount) <> '--no-execute' then Execute(fname, False);
                End
            else If StrInList('-e', [ParamStr(1), ParamStr(2), ParamStr(3), ParamStr(4), ParamStr(5)], 4)then
                Begin
                    EditSource;
                    Execute(fname, False);
                End 
            else If Create and (Get or SysFind) then 
                Begin
                    ReadDat;
                    Execute(fname, True);
                End
            else Writeln('FPC NOT FOUND.');
        End;
END.

