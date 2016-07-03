#include <stdio.h>
           
extern "C" int sscanf_asm(const char * from, const char * format,...);

int main() {
	char source_string[] = "ASM is 100500Awesome! -999 A1b2C3";
	int succ_counter = 0;

	char word_1[10];
	char word_2[10];
	char word_3[10];
	char word_4[10];

	int positive_integer;
	int negative_integer;
	int hex_integer;

	succ_counter = sscanf_asm(
		source_string, 
		"%s %s %i %s %i %X", 
		word_1, 
		word_2, 
		&positive_integer, 
		word_3, 
		&negative_integer, 
		&hex_integer);

	printf("Source string: %s\n", source_string);
	printf("Successfully assigned items: %d\n", succ_counter);
	printf(
		"1 word:\t\t%s\n"
		"2 word:\t\t%s\n"
		"positive int:   %d\n"
		"3 word:\t\t%s\n"
		"negative int:   %d\n"
		"hex int:\t%06x\n", 
		word_1,
                word_2,
                positive_integer,
                word_3,
                negative_integer,
                hex_integer);

	return 0;
}

