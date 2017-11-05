{$CODEPAGE UTF8}
// For font compatibility
// Remove this if string showing incorrectly or you want to use your system codepage

uses crt, SysUtils, DateUtils, getopts;
var
    TEMPFOLDER, Build, dir, fname: AnsiString;
    Editor: AnsiString;
    m: text;
    argPos: integer = 0;
    argStr:Array [0..255] of AnsiString;

    StartFlag, EndFlag: TDateTime;
    ExecTime: Double;

procedure Return(msg: string);
begin
    writeln(msg);
    halt(1);
end;

procedure Return(code: integer);
var msg: string = '[ERROR]';
begin
    if code <> 0 then TextColor(Red);
    case code of 
        0   :   msg := '';
        1   :   msg := msg + ' File Does Not Exist!';
        2   :   msg := msg + ' COMPILE ERROR';
        3   :   msg := msg + ' FPC NOT FOUND';
        4   :   msg := msg + ' Can'+#39+'t create temp file for compiling.';
    end;
    writeln(msg);
    TextColor(White);
    halt(code);
end;

procedure InitParam;
var i: integer;
begin
    argStr[0] := ParamStr(argPos);
    for i:=1 to ParamCount do
        argStr[i] := ParamStr(argPos+i);
end;

procedure InitBuild();
var s: string;
begin
    s:={$I %DATE%}+'-'+{$I %TIME%};
	while pos('/',s) <> 0 do delete(s,pos('/',s),1);
	while pos(':',s) <> 0 do delete(s,pos(':',s),1);
    delete(s,1,2);
    delete(s,length(s)-1,2);
    Build:=s;
end;

Procedure Help;
Begin
    TextColor(White);
    Writeln('[INFO]: FPConsole is a tool that helps you directly write code and get output with the Free Pascal Compiler');
    Writeln('Attention: Sometimes, when there is an infinite loop and the program exited improperly, you can review the code in TEMP\FPConsole folder');
    Writeln('===== All FPConsole Switches =====');
    Writeln('-c     :   Clear TEMP');
    Writeln('-f     :   Read text file with only Function and Procedure');
    Writeln('-fe    :   Read the file on-the-fly');
    Writeln('-fs    :   Read the whole file in formatted type (.pas)');
    Writeln('[blank]:   Show this help');
    Writeln('FPConsole is an Open-Source Program. Github: dungwinux/fpconsole');
End;

Function Create: boolean;
var tmp: AnsiString;
// Generate source file to compile
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

    // Pass the code to the temp source file
Procedure Input(s: string);
VAR f: text;
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

procedure OpenEditor;
begin
    writeln(m,'// Your code goes here');
    writeln(m);
    Write(m, 'end.');
    close(m);
    ExecuteProcess(Editor, fname+'.pas', []);
    append(m);
    if (FileExists(FName+'.pas')) then
        Input(FName+'.pas')
    else Return(1);
end;

Procedure ReadDat;
Begin
    If ParamStr(1) = '-fs' then begin
        if FileExists(ParamStr(2)) then
            Input(ParamStr(2))
        else begin
            Return(1);
        end;
    end
    else Begin
        Write(m, 'uses ');
        Input('_unit.dat');  // Get unit
        Writeln(m, 'sysutils, crt;');
        Writeln(m, #13#10, 'type', #13#10, '_Int = Integer;');
        Input('_type.dat');  // Get type
        Writeln(m, #13#10, 'const', #13#10, '_Def = ', #39, 'FPConsole', #39, ';');
        Input('_const.dat'); // Get const
        Writeln(m, #13#10, 'var', #13#10, '_boo: Boolean;');
        Input('_var.dat');   // Get var
        Writeln(m, #13#10, 'begin');
        Case ParamStr(1) of
            '-f'    :   begin
                            if FileExists(ParamStr(2)) then
                                Input(ParamStr(2))
                            else begin
                                Return(1);
                            end;    
                        end;
            '-fe'   :   OpenEditor;
            ''      :   Help;
            else Writeln(m, ParamStr(1));
        End;
        if not (ParamStr(1) = '-fe') then Write(m, 'end.');
    End;
    Close(m); 
End;

Function Get: boolean;
{$IFDEF MSWINDOWS}
VAR FileDat: TSearchRec;
{$ENDIF}
Begin
    {$IFDEF MSWINDOWS}
    Get := DirectoryExists('C:\FPC\');
    If Get then Begin
                If FindFirst('C:\FPC\*', faDirectory, FileDat) = 0 then
                    Repeat
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
VAR 
    FileDat: TSearchRec;
    b: boolean;
Begin
    s := s + {$IFDEF MSWINDOWS}'\'{$ENDIF} {$IFDEF LINUX}'/'{$ENDIF};
    Find := DirectoryExists(s);
    If Find then begin
        If FindFirst(s + '*', faAnyFile, FileDat) = 0 then
            Repeat 
                b := (Find and (FileDat.Name = {$IFDEF MSWINDOWS}'fpc.exe'{$ENDIF} {$IFDEF LINUX}'fpc'{$ENDIF})) 
            Until (FindNext(FileDat) <> 0) or b;
        Find := b;
        FindClose(FileDat);
    End;
End;

Function SysFind:boolean;
VAR s: AnsiString;
    ch: char = {$IFDEF MSWINDOWS}';'{$ENDIF} {$IFDEF LINUX}':'{$ENDIF};
    // Seperate path symbol
Begin
    s := GetEnvironmentVariable('PATH') + ch;
    Repeat
        dir := copy(s, 1, pos(ch, s) - 1);
        SysFind := Find(dir);
        delete(s, 1, pos(ch, s)); 
    Until SysFind or (s = '');
    Writeln('Find FPC (Custom):', SysFind);
End;

Procedure Execute;
var exitcode: integer;
Begin
    Writeln('FPC Dir:', dir);
    ReadDat;
    if (ParamStr(1)<>'') then begin

        {$IFDEF MSWINDOWS}
        ExecuteProcess(dir, ['-v0', fname], []);
        {$ENDIF}
        {$IFDEF LINUX}
        ExecuteProcess('/bin/bash', ['-c', 'fpc ' + fname + ' &>/dev/null']);
        {$ENDIF}
        DeleteFile(fname + '.pas');

        Writeln('[OUTPUT]');
        Assign(m, fname {$IFDEF MSWINDOWS}+ '.exe'{$ENDIF});
        {$I-} Reset(m); {$I+}
        If IOResult = 0 then begin
            Close(m);
            DeleteFile(fname + '.o');
            StartFlag := Now;
            if (not FileExists(fname{$IFDEF MSWINDOWS}+ '.exe'{$ENDIF})) then Return(1);
            exitcode := ExecuteProcess(fname {$IFDEF MSWINDOWS}+ '.exe'{$ENDIF}, argStr, []);
            EndFlag := Now;
            DeleteFile(fname {$IFDEF MSWINDOWS}+ '.exe'{$ENDIF});
            // This may affects execute time
            ExecTime := SecondSpan(StartFlag, EndFlag);
            writeln;
            TextColor(White);
            writeln('--------------------');
            writeln('Execution Time: ', ExecTime:0:16, ' s');
            TextColor(LightGreen);
            if exitcode <> 0 then TextColor(Red);
            writeln('Process Exited with Exit code ', exitcode);
        End
        else Return(2);
    end;
End;

// Credit goes to David Heffernan on Stack Overflow
// https://stackoverflow.com/questions/16336761/delete-directory-with-non-empty-subdirectory-and-files?answertab=votes#tab-top
procedure DeleteDir(const DirName: Ansistring);
var
  Path: string;
  F: TSearchRec;
begin
    Path:= DirName + '\*.*';
    if FindFirst(Path, faAnyFile, F) = 0 then begin
        repeat
            if (F.Attr and faDirectory <> 0) then begin
                if (F.Name <> '.') and (F.Name <> '..') then begin
                    DeleteDir(DirName + '\' + F.Name);
                end;
            end
            else
                DeleteFile(DirName + '\' + F.Name);
        until FindNext(F) <> 0;
    end;
    FindClose(F);
    RemoveDir(DirName);
end;

Procedure Clear;
var tmp: AnsiString;
Begin
    tmp := TEMPFOLDER;
    If DirectoryExists(tmp) then Begin
        {$IFDEF MSWINDOWS}
        DeleteDir(tmp);
        {$ENDIF}
        {$IFDEF LINUX}
        ExecuteProcess('/bin/bash', ['-c', 'rm -rf ' + tmp], []);
        {$ENDIF}
        CreateDir(tmp);
    End;
    writeln('TEMP Folder Cleared!');
End;

begin
    // ClrScr;
    InitBuild;
    
    // Init String
    {$IFDEF MSWINDOWS}
    Editor := 'notepad';
    TEMPFOLDER := GetEnvironmentVariable('TEMP') + '\FPConsole';
    {$ENDIF} 
    {$IFDEF LINUX}
    Editor := '/bin/nano';
    TEMPFOLDER := '/tmp/FPConsole';
    {$ENDIF}

    Writeln('FPConsole ',Build,' - Created by Winux8YT3');
    writeln('TEMP Folder: ', TEMPFOLDER);
    If ParamCount = 0 then begin
        Help;
        Return(0);
    end;
    If ParamStr(1) = '-c' then Clear
    else if Create then begin
        if (Get or SysFind) then begin
            argPos := 2;
            if (ParamStr(1) = '-f') or (ParamStr(1) = '-fs') then argPos := 3;
            InitParam;
            Execute;
        end
        else Writeln(3);
    end else writeln(4);
end.
