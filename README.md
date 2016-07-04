# sscanf
Assembler realization of C `sscanf` function  

#####Signature:  
`int sscanf_asm(const char * from, const char * format[, list of destinations])`

#####Available formats:  
* `%i` - integer positive/negative number
* `%x` - integer hex number
* `%s` - string

#####Example:  
Look in `test.c` file

#####Dependencies
`yasm`: http://yasm.tortall.net/
