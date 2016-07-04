all:	test.c sscanf.o
	gcc -m32 -Wl,-no_pie test.c sscanf.o -o test

sscanf.o:	sscanf.asm
		yasm -f macho32 sscanf.asm

clean:
	-rm test sscanf.o 2>/dev/null
