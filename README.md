FPConsole
==============================

## Debug tool for Pascal Developer.
**FPConsole Requires _Free Pascal_ installed in your computer. [Download here](http://www.freepascal.org/download.var)**

### Instructions:

- For Command Prompt :
> `FPConsole [Command]`

- For Powershell 
> `.\FPConsole [Command]`
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

- _(Optional)_ Put Unit in to _**unit.dat**_
```
sysutils,
graph,
...
```
- _(Optional)_ Put Type in to _**type.dat**_
```
Int=-128..128;
a=array[1..100]of integer;
...
```
- _(Optional)_ Put Const in to _**const.dat**_
```
s='Hello';
pi=3.14;
...
```
- _(Optional)_ Put Var in to _**var.dat**_
```
s:string;
i,j,m,n:integer;
...
```

## Changelog

### Version 1.0 *Build 170226*
- First Release.

## License
[MIT License](/LICENSE) (c) Nguyễn Tuấn Dũng *(@winux8yt3)*
