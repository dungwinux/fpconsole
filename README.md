FPConsole
==============================

## Debug tool for Pascal Developer
This debug tool helps you directly write input and get output in Free Pascal Compiler without writing a new file.

**Note**: FPConsole requires _Free Pascal_ installed on the system. [Download here](http://www.freepascal.org/download.var)

### Instructions:

- For Windows Command Prompt
> `fpconsole [command]`

Example
```batch
C:\> fpconsole "write('Hello World!');"
```
![Ex-Cmd](/img/fpconsole_cmd.gif)

- For Windows Powershell 
> `.\fpconsole [command]`

Example
```powershell
PS C:\> .\fpconsole "write('Hello World!');"
```
![Ex-Powershell](/img/fpconsole_powershell.gif)

- For Linux terminal
> `./fpconsole [command]`

Example
```bash
$ ./fpconsole -fs HelloWorld.pas
```
![Ex-Terminal](/img/fpconsole_linux-terminal.gif)

- Get Code From a Text File

> `.\FPConsole -f [File Include Code]`

- ...or Get The Whole Source Code (FPConsole 1.2+)

> `.\FPConsole -fs [Source Code File]`

Example
```powershell
PS C:\> .\fpconsole -f "Code.dat"

PS C:\> .\fpconsole -fs "Code.pas"
```

- _(Optional)_ Add UNIT to _**unit.dat**_
```pascal
sysutils,
graph,
...
```
- _(Optional)_ Add TYPE to _**type.dat**_
```pascal
Int = -128..128;
a = array[1..100] of integer;
...
```
- _(Optional)_ Add CONST to _**const.dat**_
```pascal
s = 'Hello';
pi = 3.14;
...
```
- _(Optional)_ Add VAR to _**var.dat**_
```pascal
s: string;
i,j,m,n: integer;
...
```

## History

### Version 1.3
- Add support for Linux
- Fix #5

### Version 1.2.2 *Build 170326*
- Change Work Folder to %TEMP%.
- Add Help (`-h`), Clear (`-c`), Read Source (`-fs`).

### Version 1.1 *Build 170228*
- Automatic Find FPC Directory.

### Version 1.0.1 *Build 170227*
- Fix Directory.

### Version 1.0 *Build 170226*
- First Release.

## License
[MIT License](/LICENSE) (c) Nguyễn Tuấn Dũng *(@winux8yt3)*
