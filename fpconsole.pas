uses crt,sysutils;
var 
    fname:string;
    m:text;     // Main File
function N2S(k:word):string;
begin
    str(k,N2S);
end;
procedure Create;
begin
    FName:='_'+N2S(random(10000))+N2S(random(10000));
    assign(m,fname+'.pas');
    rewrite(m);
end;
procedure ReadDat;
var i:byte;
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
    writeln(m,#13#10,'const',#13#10,'_ProgName=',#39,'FPConsole',#39,';');
    Input('const.dat'); // Read const
    writeln(m,#13#10,'var',#13#10,'nullStr:string;');
    Input('var.dat');   // Read Var
    writeln(m,#13#10,'begin');
    if paramstr(1)='-f' then Input(paramstr(2)) else
    for i:=1 to ParamCount do writeln(m,paramstr(i));
    write(m,'end.');
    close(m);
end;
procedure Execute;
var s:string;
    function Get:string;
    Var FileDat:TSearchRec;
    begin
        if FindFirst(s+'*',faDirectory,FileDat)=0 then
            repeat
                With FileDat do Get:=Name;
            until FindNext(FileDat)<>0;
        FindClose(FileDat);
    end;
begin
    s:='C:\FPC\';
    if not DirectoryExists(s) then write('FPC not yet installed') else begin
        ExecuteProcess(s+Get+'\bin\i386-win32\fpc.exe', ['-v0',FName], []);
        clrscr;
        assign(m,fname+'.exe');
        {$I-}reset(m);{$I+}
        if IOResult=0 then begin
            ExecuteProcess(FName+'.exe','',[]);
            close(m);
            DeleteFile(FName+'.exe');
            DeleteFile(FName+'.o');
        end else write('ERROR');
    end;
    DeleteFile(FName+'.pas');
end;
begin
    writeln('FPConsole Version 1.0.1 Build 170227 - Created by Winux8YT3');
    Create;
    ReadDat;
    Execute;
end.
