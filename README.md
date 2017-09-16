FPConsole
==============================

## Debug tool for Pascal Developer
This debug tool helps you directly write input and get output in Free Pascal Compiler without writing new file.

>**Warning**: FPConsole Requires _Free Pascal_ installed in the system. [Download here](http://www.freepascal.org/download.var)

### Instructions:

- For Command Prompt
> `fpconsole [Command]`

Example
```batch
C:\> fpconsole "write('Hello World!');"
```
![Ex-Cmd](/img/fpconsole.gif)

- For Powershell 
> `.\fpconsole [Command]`

Example
```powershell
PS C:\> .\fpconsole "write('Hello World!');"
```
![Ex-Powershell](/img/fpconsole_power.gif)

- Get Code From a Text File

> `.\FPConsole -f [File Include Code]`

- Or Get The Whole Source Code (FPConsole 1.2+)

> `.\FPConsole -fs [Source Code File]`

Example
```powershell
PS C:\> .\fpconsole -f "Code.dat"

PS C:\> .\fpconsole -fs "Code.pas"
```

- _(Optional)_ Add UNIT in to _**unit.dat**_
```pascal
sysutils,
graph,
...
```
- _(Optional)_ Add TYPE in to _**type.dat**_
```pascal
Int = -128..128;
a = array[1..100] of integer;
...
```
- _(Optional)_ Add CONST in to _**const.dat**_
```pascal
s = 'Hello';
pi = 3.14;
...
```
- _(Optional)_ Add VAR in to _**var.dat**_
```pascal
s: string;
i, j, m, n: integer;
...
```

## Changelog

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