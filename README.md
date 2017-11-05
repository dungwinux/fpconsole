![FPConsole](docs/images/terminal-icon.png) FPConsole
==============================

[![Download FPConsole](https://img.shields.io/sourceforge/dw/fpconsole.svg?style=flat-square)](https://sourceforge.net/projects/fpconsole/files/latest/download)
[![Download FPConsole](https://img.shields.io/sourceforge/dt/fpconsole.svg?style=flat-square)](https://sourceforge.net/projects/fpconsole/files/latest/download)

## Debug tool for Pascal Developer
This debug tool helps you directly write input and get output in Free Pascal Compiler without writing a new file.

**Note**: FPConsole requires _Free Pascal Compiler_ installed on the system. [Download here](http://www.freepascal.org/download.var)

## Instructions:
> These instructions are available in latest version ( **v1.5** ). For old version, checkout wiki page for proper parameter.

### Simple Execute
`fpconsole [command]`

- Command Prompt : `fpconsole [command]`
```batch
C:\> fpconsole "write('Hello World');"
```
![Command Prompt Example](/img/fpcs_cmd.gif)

- Powershell : `.\fpconsole [command]`

```powershell
PS C:\> .\fpconsole "write('Hello World');"
```
![Powershell Example](/img/fpcs_ps.gif)

- Linux Terminal : `./fpconsole [command]`

```bash
$ ./fpconsole "write('Hello World');"
```
![Linux Example](/img/fpcs_linux.gif)

### Advanced Execute

- Execute With Custom Parameter

`fpconsole [Code] [Parameter]`

- Get Code From a Text File

`fpconsole -f [File Include Code] [Parameter]`

- Edit Source File Before Compiling

`fpconsole -fe [Parameter]`

- ...or Get The Whole Source Code

`fpconsole -fs [Source Code File] [Parameter]`

Example
```powershell
PS C:\> .\fpconsole "write('Hello World')" "-e" "Hello"
# This will execute with parameter "-e" and "Hello"

PS C:\> .\fpconsole -f "Code.dat"
# This will read main program from "Code.dat"

PS C:\> .\fpconsole -fe
# This will open notepad/nano to edit

PS C:\> .\fpconsole -fs "Code.pas"
# This will copy "Code.pas" then compile
```

### _(Optional Files)_ 
- Add UNIT to _**_unit.dat**_
```pascal
sysutils,
graph,
...
```

- Add TYPE to _**_type.dat**_
```pascal
Int = -128..128;
a = array[1..100] of integer;
...
```
- Add CONST to _**_const.dat**_
```pascal
s = 'Hello';
pi = 3.14;
...
```
- Add VAR to _**_var.dat**_
```pascal
s: string;
i,j,m,n: integer;
...
```

## Changelog

### Version 1.5
- Open defualt editor to edit source before compiling (`-fe`) (#13)
- Add execution time (#11)
- Code now can execute with custom parameters
- Add color
- Change Input Folder:

|Old File Name|New File Name|
|:------------|:------------|
|unit.dat     |_unit.dat    |
|var.dat      |_var.dat     |
|const.dat    |_const.dat   |
|type.dat     |_type.dat    |

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
