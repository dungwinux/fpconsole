PROGRAM fpconsole;
USES Crt, SysUtils {$IFDEF LINUX}, Process{$ENDIF};
VAR 
    // dir's value is the path to Free Pascal Compiler (ex. C:\path\to\fpc\fpc.exe on Windows)
    // fname's value is the file name (without file extension) of 
    //     the Pascal source code file (& its object & executable files) that the program deals with
    // tmp's value is the path of the program's temporary folder, under a directory specified by TEMP (on Windows)
    //     on Linux, temporary app data are stored in /tmp, so tmp's value should be /tmp/FPConsole
    dir, fname, tmp: AnsiString;
    m: text;     // Variable for main (temporary) Pascal source code file (.pas) to be executed

{
    Create a new Pascal source code file & open it for writing
    The source code file's name is a random number from 0 to 99999
    and the file itself is located in the program's temporary folder
}
Function Create: boolean;
Begin
    Randomize;
    Str(random(100000), fname);  // Use a random number as the name to our .pas file
    fname := '_' + fname;
    tmp := {$IFDEF MSWINDOWS}GetEnvironmentVariable('TEMP') + '\FPConsole'{$ENDIF} {$IFDEF LINUX}'/tmp/FPConsole'{$ENDIF};
    Create := (DirectoryExists(tmp)) or (CreateDir(tmp));  // Create a temporary folder for the program
    If Create then Begin
                   fname := tmp + {$IFDEF MSWINDOWS}'\'{$ENDIF} {$IFDEF LINUX}'/'{$ENDIF} + fname;
                   Assign(m, fname + '.pas');
                   Rewrite(m);
                   End;
End;

{
    Read a file which its name is passed as the argument and copy the content to the main text file
    parameter s (string) is the file name to be read
}
Procedure Input(s: string);
VAR f: text;
Begin
    Assign(f, s);
    {$I-} Reset(f); {$I+}
    If IOResult = 0 then Begin
            While not EOF(f) do Begin
                            Readln(f, s);  // Read a line from file s
                            Writeln(m, s);  // Copy that line to text file m
                                End;
            Close(f);
                         End;
    // File assigned to variable m remains unclosed for later manipulation
End;

{
    Procedure reading data from .dat files and write a complete Pascal source code to source code file m
    Note: unit.dat, type.dat, const.dat are user's manually created files
    If the user does not create any .dat file, no new line will be written by the Input function in this function (ReadDat)
    #13#10 = LineEnding (sLineBreak)
    #39 = ' (single quotation mark)
}
Procedure ReadDat;
VAR 
    i: byte;
    t: string;
Begin
    If Paramstr(1) = '-fs' then Input(paramstr(2))  // The case in which the user has written his/her Pascal code in a .dat file
    else Begin
        Write(m, 'uses ');
        Input('unit.dat');  // Get unit
        Writeln(m, 'crt;');
        Writeln(m, #13#10, 'type', #13#10, 'Int=Integer;');
        Input('type.dat');  // Get type
        Writeln(m, #13#10, 'const', #13#10, '_Default=', #39, 'FPConsole', #39, ';');
        Input('const.dat'); // Get const
        Writeln(m, #13#10, 'var', #13#10, '_nuStr:string;', #13#10, '_nInt:integer;', #13#10, '_nReal:real;', #13#10, '_nText:text;');
        Input('var.dat');   // Get var
        Writeln(m, #13#10, 'begin');
        Case paramstr(1) of
            '-f' :  Input(paramstr(2));
            ''   :  Begin  // Begin user's session for entering Pascal code
                    Writeln('[INPUT] ( type "//" to stop entering code )');
                    Repeat
                        Readln(t);  // Get user's input (Pascal code)
                        Writeln(m, t);  // Append user's input to writing file
                    Until t = '//';
                    End;
            else For i := 1 to ParamCount do Writeln(m, paramstr(i));
        End;
        Write(m, 'end.');
    End;
    Close(m);  // Finish writing to source code file, ready to be compiled & executed
End;

{
    Attempt to find FPC, assuming the user put FPC in its default home directory
    On Windows, it should be C:\FPC\[FPC version name]\bin\i386-win32\fpc.exe
    Return true if FPC is found in the FPC default home directory, false otherwise
}
Function Get: boolean;
VAR FileDat: TSearchRec;
Begin
    {$IFDEF MSWINDOWS}
    Get := DirectoryExists('C:\FPC\');
    If Get then Begin
                If FindFirst('C:\FPC\*', faDirectory, FileDat) = 0 then
                    // Start looking for a folder that possibly holding FPC
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

{
    Function for finding FPC executable in a given directory s
    Return true if FPC is found, false otherwise
}
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

{
    Look for FPC in directories specified by the PATH variable
    Return true if FPC is found in any of the directories, false otherwise
}
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

{
    Compile the source code created and execute the output binary
    Should remove the source code file (.pas), the object file (.o) and the executable (.exe) after execution
}
Procedure Execute;
Begin
    Writeln('FPC Dir:', dir);
    ReadDat;
    {$IFDEF MSWINDOWS}ExecuteProcess(dir, ['-v0', fname], []);{$ENDIF}
    {$IFDEF LINUX}ExecuteProcess('/bin/bash', ['-c', 'fpc ' + fname + ' &>/dev/null']);{$ENDIF}
    Writeln('[OUTPUT]');
    DeleteFile(fname + '.pas');
    Assign(m, fname {$IFDEF MSWINDOWS}+ '.exe'{$ENDIF});
    {$I-} Reset(m); {$I+}
    If IOResult = 0 then begin
                       Close(m);
                       DeleteFile(fname + '.o');
                       ExecuteProcess(fname {$IFDEF MSWINDOWS}+ '.exe'{$ENDIF}, '', []);
                       DeleteFile(fname {$IFDEF MSWINDOWS}+ '.exe'{$ENDIF});
                       End 
    else Writeln('COMPILE ERROR');
End;

{
    Delete all files in the program's temporary folder
}
Procedure Clear;
CONST tmp = {$IFDEF MSWINDOWS}GetEnvironmentVariable('TEMP') + '\FPConsole'{$ENDIF}
            {$IFDEF LINUX}'/tmp/FPConsole'{$ENDIF};
Begin
    (* RemoveDir only removes directory when empty. Implemented a new way.
    If DirectoryExists(tmp) and RemoveDir(tmp) then CreateDir(tmp)
    else Writeln('DIR ERROR');
    *)
    If DirectoryExists(tmp) 
        then Begin
             {$IFDEF MSWINDOWS}ExecuteProcess('C:\Windows\System32\cmd.exe', ['/c', 'rmdir', tmp], []);{$ENDIF}
             {$IFDEF LINUX}ExecuteProcess('/bin/bash', ['-c', 'rm -rf ' + tmp], []);{$ENDIF}
             CreateDir(tmp);
             End;
End;

{
    Log program's info and manual lines to the console
}
Procedure Help;
Begin
    Writeln('INFO: FPConsole is a tool that helps you directly write input and get output with the Free Pascal Compiler');
    Writeln('To make it easy, you can directly throw input as the argument or write it in a file');
    Writeln('Sometimes, when there is an error or an infinite loop and the program exited improperly, you can review the code in %TMP%\FPConsole folder');
    Writeln('All FPConsole Switch:');
    Writeln('[blank]:   Read Function and Procedure by input');
    Writeln('-c     :   Clear TEMP');
    Writeln('-fs    :   Read the whole file in formatted type (.pas)');
    Writeln('-f     :   Read text file with only Function and Procedure');
    Writeln('-h     :   Show this help');
    Writeln('FPConsole is an Open-Source Program. Github: fpconsole');   // Use writeln as usual
End;

// Main
BEGIN
    ClrScr;
    Writeln('FPConsole Version 1.2.2 Build 170326 - Created by Winux8YT3');
    If paramstr(1) = '-h' then Help
    else if paramstr(1) = '-c' then Clear
    else if Create and (Get or SysFind) then Execute else Writeln('FPC NOT FOUND');
END.
