FPConsole
==============================

## Debug tool for Pascal Developer
This debug tool helps running Pascal codes directly from console, instead of writing new script from beginning to debug.

>**Warning**: FPConsole Requires _Free Pascal_ installed in the system. [Download here](http://www.freepascal.org/download.var)

### Instructions:

- For Command Prompt :
> `FPConsole [Command]`

- For Powershell 
> `.\FPConsole [Command]`

Example:
```
PS C:\Code> .\fpconsole "write('Hello World');"
```

- Put Bottom Code in to a file then 
> `FPConsole -f [File Include Code]`

or

> `.\FPConsole -f [File Include Code]`

Example
```
PS D:\Code> .\fpconsole -f "Code.dat"
```

- _(Optional)_ Add UNIT in to _**unit.dat**_
```
sysutils,
graph,
...
```
- _(Optional)_ Add TYPE in to _**type.dat**_
```
Int=-128..128;
a=array[1..100]of integer;
...
```
- _(Optional)_ Add CONST in to _**const.dat**_
```
s='Hello';
pi=3.14;
...
```
- _(Optional)_ Add VAR in to _**var.dat**_
```
s:string;
i,j,m,n:integer;
...
```

## Changelog

### Version 1.1 *Build 170228*
- Automatic Find FPC Directory.

### Version 1.0.1 *Build 170227*
- Fix Directory.

### Version 1.0 *Build 170226*
- First Release.

## License
[MIT License](/LICENSE) (c) Nguyễn Tuấn Dũng *(@winux8yt3)*