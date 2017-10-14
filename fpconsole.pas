uses crt, SysUtils, DateUtils;
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
    Writeln('INFO: FPConsole is a tool that helps you directly write input and get output with the Free Pascal Compiler');
    Writeln('To make it easy, you can directly throw input as the argument or write it in a file');
    Writeln('Sometimes, when there is an error or an infinite loop and the program exited improperly, you can review the code in %TMP%\FPConsole folder');
    Writeln('All FPConsole Switch:');
    Writeln('-c     :   Clear TEMP');
    Writeln('-fs    :   Read the whole file in formatted type (.pas)');
    Writeln('-f     :   Read text file with only Function and Procedure');
    Writeln('-h     :   Show this help');
    Writeln('FPConsole is an Open-Source Program. Github: fpconsole');
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

Procedure ReadDat;
VAR 
    i: byte;
    t: string;
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
            // ''   :  Begin 
            //         Writeln('[INPUT] ( type "//" to stop entering code )');
            //         Repeat
            //             Readln(t);
            //             Writeln(m, t);
            //         Until t = '//';
            //         End;
            ''  :   Help;
            else For i := 1 to ParamCount do Writeln(m, ParamStr(i));
        End;
        Write(m, 'end.');
    End;
    Close(m); 
End;

Function Get: boolean;
VAR FileDat: TSearchRec;
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
var exitcode: integer;
Begin
    Writeln('FPC Dir:', dir);
    ReadDat;
    if (ParamStr(1)<>'') then begin
        {$IFDEF MSWINDOWS}ExecuteProcess(dir, ['-v0', fname], []);{$ENDIF}
        {$IFDEF LINUX}ExecuteProcess('/bin/bash', ['-c', 'fpc ' + fname + ' &>/dev/null']);{$ENDIF}
        DeleteFile(fname + '.pas');

        Writeln('[OUTPUT]');
        Assign(m, fname {$IFDEF MSWINDOWS}+ '.exe'{$ENDIF});
        {$I-} Reset(m); {$I+}
        If IOResult = 0 then begin
            Close(m);
            DeleteFile(fname + '.o');
            StartFlag := Now;
            exitcode := ExecuteProcess(fname {$IFDEF MSWINDOWS}+ '.exe'{$ENDIF}, '', []);
            EndFlag := Now;
            DeleteFile(fname {$IFDEF MSWINDOWS}+ '.exe'{$ENDIF});
            // This may affects execute time
            // ExecTime := SecondsBetween(StartFlag, EndFlag);
            ExecTime := SecondSpan(StartFlag, EndFlag);
            writeln;
            writeln('--------------------');
            writeln('Execution Time: ', ExecTime:0:16, ' s');
            writeln('Process Exited with Exit code ', exitcode);
        End
        else Writeln('COMPILE ERROR');
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
        {$IFDEF MSWINDOWS}DeleteDir(tmp);{$ENDIF}
        {$IFDEF LINUX}ExecuteProcess('/bin/bash', ['-c', 'rm -rf ' + tmp], []);{$ENDIF}
        CreateDir(tmp);
    End;
    writeln('TEMP Folder Removed!');
End;

begin
    Clrscr;InitBuild;
    TEMPFOLDER := {$IFDEF MSWINDOWS}GetEnvironmentVariable('TEMP') + '\FPConsole'{$ENDIF} {$IFDEF LINUX}'/tmp/FPConsole'{$ENDIF};
    Writeln('FPConsole ',Build,' - Created by Winux8YT3');
    writeln('TEMP Folder: ', TEMPFOLDER);
    If ParamStr(1) = '-h' then Help
    else if ParamStr(1) = '-c' then Clear
    else if Create and (Get or SysFind) then Execute else Writeln('FPC NOT FOUND');
end.
