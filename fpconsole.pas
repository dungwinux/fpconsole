USES CRT, SysUtils;
VAR
    TEMPFOLDER, Build, dir, fname: AnsiString;
    m: text;

Procedure InitBuild();
Var s: String;
Begin
    s := {$I %DATE%}+'-'+{$I %TIME%};
    While pos('/',s) <> 0 do Delete(s, pos('/', s), 1);
    While pos(':',s) <> 0 do Delete(s, pos(':', s), 1);
    Delete(s, 1, 2);
    Delete(s, length(s) - 1, 2);
    Build := s;
End;

Procedure Help;
Begin
    Writeln('INFO: FPConsole is a tool that helps you directly write input and get output with the Free Pascal Compiler');
    Writeln('To make it easy, you can directly throw input as the argument or write it in a file');
    Writeln('Sometimes, when there is an error or an infinite loop and the program exited improperly, you can review the code in %TMP%\FPConsole folder');
    Writeln('All FPConsole Switch:');
    Writeln('-c  :   Clear TEMP');
    Writeln('-fs :   Read the whole file in formatted type (.pas)');
    Writeln('-f  :   Read text file with only Function and Procedure');
    Writeln('-h  :   Show this help');
    Writeln('FPConsole is an Open-Source Program. Github: fpconsole');
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
    If Create then Begin
        fname := tmp + {$IFDEF MSWINDOWS}'\'{$ENDIF} {$IFDEF LINUX}'/'{$ENDIF} + fname;
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
    If IOResult = 0 then Begin
        While not EOF(f) do Begin
            Readln(f, s);  
            Writeln(m, s);  
        End;
        Close(f);
    End;
End;

Function FineArgs:Boolean;
// Check if the passed arguments are okay
Var
    AvailableArgs: Array[1..4] of String = ('-c', '-f', '-fs', '-h');
    UsedArgs: Array of String;
    ArgItem, Arg: String;
    k, j: Byte;
Begin
    SetLength(UsedArgs, ParamCount);
    FineArgs := True;
    For k := 1 to ParamCount do
        Begin
            For ArgItem in AvailableArgs do If ParamStr(k) = ArgItem then  // ParamStr(k) is a valid argument
            Begin
                For Arg in UsedArgs do If ParamStr(k) = Arg then
                    Begin
                        FineArgs := False;
                        Writeln('Duplicate argument:', ParamStr(k));
                        Break;
                    End;
                Break;
            End
            else Begin  // ParamStr(k) is not a valid argument
                    FineArgs := False;
                    Writeln('Invalid argument:', ParamStr(k))
                 End;
        End;
End;

Procedure EditSource;
// Open a text editor and edit the source code
VAR
    EditorPath: String = {$IFDEF LINUX} '/bin/nano' {$ENDIF};
    i: Byte;
Begin
    // {$IFDEF LINUX}
    For i := 1 to ParamCount do
        Begin
        End;
    // {$ENDIF}
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
    s := s + {$IFDEF MSWINDOWS}'\'{$ENDIF} {$IFDEF LINUX}'/'{$ENDIF};
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

Procedure Execute;
// Compile & Execute the source code (source file is holded by the m variable)
Var exitcode: integer;
Begin
    Writeln('FPC Dir:', dir);
    ReadDat;
    If (ParamStr(1)<>'') then 
    Begin
        {$IFDEF MSWINDOWS}ExecuteProcess(dir, ['-v0', fname], []);{$ENDIF}
        {$IFDEF LINUX}ExecuteProcess('/bin/bash', ['-c', 'fpc ' + fname + ' &>/dev/null']);{$ENDIF}
        DeleteFile(fname + '.pas');

        Writeln('[OUTPUT]');
        Assign(m, fname {$IFDEF MSWINDOWS}+ '.exe'{$ENDIF});
        {$I-} Reset(m); {$I+}
        If IOResult = 0 then 
            Begin
                Close(m);
                DeleteFile(fname + '.o');
                exitcode := ExecuteProcess(fname {$IFDEF MSWINDOWS}+ '.exe'{$ENDIF}, '', []);
                DeleteFile(fname {$IFDEF MSWINDOWS}+ '.exe'{$ENDIF});
                Writeln;
                Writeln('---------------------');
                Writeln('Process terminated with exit code ', exitcode);
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
    If Not FineArgs then Halt;
    If ParamStr(1) = '-h' then Help
        else If ParamStr(1) = '-c' then Clear
        else If Create and (Get or SysFind) then Execute else Writeln('FPC NOT FOUND.');
END.
