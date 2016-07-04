	section .text
	global _sscanf_asm

_sscanf_asm:
	push esi
	push ebx
	push ecx
	push edx

	mov [ShiftResource], dword 0
	mov [ShiftFormat], dword 0
	mov [ShiftDestination], dword 28
	mov [CompliteCount], dword 0

	mov esi, [esp + 24] 		;Format string
	mov ebx, [esp + 20] 		;Resource string
	
_find_first_format_char:
	mov edx, [ShiftFormat]
	mov al, [esi + edx]			;if Format[i] == ' ' -> inc i
	cmp al, '%'					;else if Format[i] == '%' -> inc i
	jz _FoundPercent			;read F second
	cmp al, ' '					;read F first
	jz _FoundSpace
	cmp al, 9h					;horiz tab \r
	jz _FoundSpace
	cmp al, Ah					; \n
	jz _FoundSpace
	cmp al, Dh					; \r
	jz _FoundSpace
	jmp _ReturnCompliteCount
_FoundSpace:
	add [ShiftFormat], dword 1
	jmp _find_first_format_char
_FoundPercent:
	add [ShiftFormat], dword 1
	jmp _read_second_format_char
	
_read_second_format_char:
	mov edx, [ShiftFormat]
	mov al, [esi + edx]			;if Format[i] == 's' -> inc i 
	add [ShiftFormat], dword 1	;if Format[i] == ' ' -> read address next container from stack
	cmp al, 's'
	jz _s_func
	cmp al, 'S'
	jz _s_func
	cmp al, 'i'
	jz _i_func
	cmp al, 'I'
	jz _i_func
	cmp al, 'd'
	jz _i_func
	cmp al, 'D'
	jz _i_func
	cmp al, 'X'
	jz _x_func
	cmp al, 'x'
	jz _x_func
	jmp _ReturnCompliteCount	;else GOTO _ReturnCompliteCount

_s_func:
	mov edx, [ShiftDestination]
	mov eax, [esp + edx]
	mov [eax], dword 0
	mov [ShiftStringR], dword 0
_find_first_char:
	mov edx, [ShiftResource]
	mov cl, [ebx + edx]	
	cmp cl, ' '
	jz _pre_find_first_char
	cmp cl, 9h
	jz _pre_find_first_char
	cmp cl, 0Ah
	jz _pre_find_first_char
	cmp cl, 0Dh
	jz _pre_find_first_char
	cmp cl, 0
	jz _ReturnCompliteCount
	jmp _read_next_chr
_pre_find_first_char:
	add [ShiftResource], dword 1
	jmp _find_first_char
_read_next_chr:
	mov edx, [ShiftStringR]
	mov [eax + edx], cl	
	add [ShiftStringR], dword 1
	add [ShiftResource], dword 1
	mov edx, [ShiftResource]
	mov cl, [ebx + edx]
	cmp cl, ' '
	jz _ReadStrComplite
	cmp cl, 9h
	jz _ReadStrComplite
	cmp cl, 0Ah
	jz _ReadStrComplite
	cmp cl, 0Dh
	jz _ReadStrComplite
	cmp cl, 0
	jz _ReadStrComplite_end
	jmp _read_next_chr
_ReadStrComplite:
	mov edx, [ShiftStringR]
	mov [eax + edx], byte 0	
	add [CompliteCount], dword 1
	add [ShiftDestination], dword 4
	jmp _find_first_format_char
_ReadStrComplite_end:
	mov edx, [ShiftStringR]
	mov [eax + edx], byte 0	
	add [CompliteCount], dword 1
	jmp _ReturnCompliteCount

_i_func:
	mov [NegVal], byte 0
	mov eax, [ShiftDestination]
	mov edx, [esp + eax]
	mov [edx], dword 0
	mov [ShiftStringR], dword 0
_find_first_int:
	mov eax, [ShiftResource]
	xor ecx, ecx
	mov cl, byte [ebx + eax]
	cmp cl, ' '
	jz _pre_find_first_int
	cmp cl, 9h
	jz _pre_find_first_int
	cmp cl, 0Ah
	jz _pre_find_first_int
	cmp cl, 0Dh
	jz _pre_find_first_int
	cmp cl, 0
	jz _ReturnCompliteCount
	cmp cl, '-'
	jz _findNeg
	jmp _read_next_int
_pre_find_first_int:
	add [ShiftResource], dword 1
	jmp _find_first_int	
_findNeg:
	test byte [NegVal], 0Fh
	jnz _ReturnCompliteCount
	mov byte [NegVal], 1
	jmp _pre_find_first_int
_read_next_int:
	jmp _save_number
_read_next_int_resume:
	add [ShiftStringR], dword 1
	add [ShiftResource], dword 1
	mov eax, [ShiftResource]
	xor ecx, ecx
	mov cl, [ebx + eax]
	jmp _read_next_int
_save_number:
	cmp cl, 48
	js _NAN_
	cmp cl, 58
	jns _NAN_
	push edx
	push ebx

	xor ebx, ebx
	mov ebx, dword [edx]
	xor edx, edx
	xor eax, eax
	mov eax, 10
	mul ebx
	sub ecx, 48
	add eax, ecx

	pop ebx
	pop edx
	mov dword [edx], eax
	jmp _read_next_int_resume
_NAN_:
	test byte [NegVal], 0Fh
	jnz _NegInt
	test dword [ShiftStringR], 0FFFFFFFFh
	jnz _ReadIntComplite
	jmp _ReturnCompliteCount
_NegInt:
	mov eax, dword [edx]
	neg eax
	mov dword [edx], eax
	test dword [ShiftStringR], 0FFFFFFFFh
	jnz _ReadIntComplite
	jmp _ReturnCompliteCount
_ReadIntComplite:
	add [CompliteCount], dword 1
	add [ShiftDestination], dword 4
	jmp _find_first_format_char

_x_func:
	mov [NegVal], byte 0
	mov eax, [ShiftDestination]
	mov edx, [esp + eax]
	mov [edx], dword 0
	mov [ShiftStringR], dword 0
_find_first_hex:
	mov eax, [ShiftResource]
	xor ecx, ecx
	mov cl, byte [ebx + eax]
	cmp cl, ' '
	jz _pre_find_first_hex
	cmp cl, 9h
	jz _pre_find_first_hex
	cmp cl, 0Ah
	jz _pre_find_first_hex
	cmp cl, 0Dh
	jz _pre_find_first_hex
	cmp cl, 0
	jz _ReturnCompliteCount
	cmp cl, '-'
	jz _findNegHex
	jmp _read_next_hex
_pre_find_first_hex:
	add [ShiftResource], dword 1
	jmp _find_first_hex	
_findNegHex:
	test byte [NegVal], 0Fh
	jnz _ReturnCompliteCount
	mov byte [NegVal], 1
	jmp _pre_find_first_hex
_read_next_hex:
	jmp _test_number_hex
_read_next_hex_resume:
	add [ShiftStringR], dword 1
	add [ShiftResource], dword 1
	mov eax, [ShiftResource]
	xor ecx, ecx
	mov cl, [ebx + eax]
	jmp _read_next_hex
_test_number_hex:
	cmp cl, 103
	jns _NAN_hex
	cmp cl, 48
	js _NAN_hex
	cmp cl, 58
	jns _test2_hex
	sub cl, '0'
	jmp _save_number_hex
_test2_hex:
	cmp cl, 65
	js _NAN_hex
	cmp cl, 71
	jns _test3_hex
	js _hex_upper_to_int
_test3_hex:
	cmp cl, 97
	js _NAN_hex
	jns _hex_lower_to_int
_hex_upper_to_int:
	sub cl, 'A'
	add cl, 10	
	jmp _save_number_hex
_hex_lower_to_int:
	sub cl, 'a'
	add cl, 10
	jmp _save_number_hex
_save_number_hex:
	push edx
	push ebx

	xor ebx, ebx
	mov ebx, dword [edx]
	xor edx, edx
	xor eax, eax
	mov eax, 16
	mul ebx
	;sub ecx, 48
	add eax, ecx

	pop ebx
	pop edx
	mov dword [edx], eax
	jmp _read_next_hex_resume
_NAN_hex:
	test byte [NegVal], 0Fh
	jnz _NegHex
	test dword [ShiftStringR], 0FFFFFFFFh
	jnz _ReadHexComplite
	jmp _ReturnCompliteCount
_NegHex:
	mov eax, dword [edx]
	neg eax
	mov dword [edx], eax
	test dword [ShiftStringR], 0FFFFFFFFh
	jnz _ReadHexComplite
	jmp _ReturnCompliteCount
_ReadHexComplite:
	add [CompliteCount], dword 1
	add [ShiftDestination], dword 4
	jmp _find_first_format_char



_ReturnCompliteCount:

	pop edx
	pop ecx
	pop ebx
	pop esi

	mov eax, [CompliteCount];

	ret 

end

	section .bss
	
	ShiftResource resb 4
	ShiftFormat resb 4
	ShiftDestination resb 4
	CompliteCount resb 4
	
	ShiftStringR resb 4
	NegVal resb 1
