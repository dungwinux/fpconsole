uses crt,sysutils;
var 
    dir,fname:string;
    m:text;     // Main File
function N2S(k:word):string;    // Convert
begin
    str(k,N2S);
end;
procedure Create;
begin
    randomize;
    FName:='_'+N2S(random(10000)+random(10000));
    assign(m,fname+'.pas');
    rewrite(m);
end;
procedure ReadDat;
var i:byte;
    t:string;
    procedure Input(s:string);
    var f:text;
    begin
        assign(f,s);
        {$I-}reset(f);{$I+}
        if IOResult=0 then begin
            while not eof(f) do begin
                readln(f,s);
                writeln(m,s);
            end;
            close(f);
        end;
    end;
begin
    write(m,'uses ');
    Input('unit.dat');  // Read unit
    writeln(m,'crt;');
    writeln(m,#13#10,'type',#13#10,'Int=Integer;');
    Input('type.dat');  // Read type
    writeln(m,#13#10,'const',#13#10,'_Default=',#39,'FPConsole',#39,';');
    Input('const.dat'); // Read const
    writeln(m,#13#10,'var',#13#10,'_nuStr:string;',#13#10,'_nInt:integer;',#13#10,'_nReal:real;');
    Input('var.dat');   // Read Var
    writeln(m,#13#10,'begin');
    if paramstr(1)='-f' then Input(paramstr(2)) else
    for i:=1 to ParamCount do writeln(m,paramstr(i));
    if paramstr(1)='' then begin
        writeln('[INPUT] ( // to stop entering code )');
        repeat
            readln(t);
            writeln(m,t);
        until t='//';
    end;
    write(m,'end.');
    close(m);
end;
function Get:boolean;
var FileDat:TSearchRec;
begin
    Get:=DirectoryExists('C:\FPC\');
    if Get then begin
        if FindFirst('C:\FPC\*',faDirectory,FileDat)=0 then
            repeat
                dir:=FileDat.Name;
            until FindNext(FileDat)<>0;
        FindClose(FileDat);
        if Dir='..' then Get:=False
        else Dir:='C:\FPC\'+Dir+'\bin\i386-win32\fpc.exe';
    end;
    Get:=Get and FileExists(dir);
    writeln('Find FPC (Default):',Get);
end;
function Find(s:string):boolean;
var FileDat:TSearchRec;
    b:boolean;
begin
    s:=s+'\';
    Find:=DirectoryExists(s);
    if Find then begin
        if FindFirst(s+'*',faAnyFile,FileDat)=0 then
            repeat b:=(Find and (FileDat.Name='fpc.exe')) until (FindNext(FileDat)<>0) or b;
        Find:=b;
        FindClose(FileDat);
    end;
end;
function SysFind:boolean;
var s:ansistring;
begin
    s:=GetEnvironmentVariable('PATH')+';';
    repeat
        dir:=copy(s,1,pos(';',s)-1);
        SysFind:=Find(dir);
        delete(s,1,pos(';',s)); 
    until SysFind or (s='');
    writeln('Find FPC (Custom):',SysFind);
end;
procedure Execute;
begin
    writeln('FPC Dir:',dir);
    ReadDat;
    ExecuteProcess(dir, ['-v0',FName], []);
    writeln('[OUTPUT]');
    DeleteFile(FName+'.pas');
    assign(m,fname+'.exe');
    {$I-}reset(m);{$I+}
    if IOResult=0 then begin
        close(m);
        DeleteFile(FName+'.o');
        ExecuteProcess(FName+'.exe','',[]);
        DeleteFile(FName+'.exe');
    end else write('ERROR');
end;
begin
    writeln('FPConsole Version 1.1 Build 170228 - Created by Winux8YT3');
    Create;
    if Get or SysFind then Execute else write('FPC Not Found');
end.