.386
.MODEL flat, stdcall
 ExitProcess PROTO, dwExitCode: DWORD 

 include Irvine32.inc 

 .data

	MAX = 80
	stringIn BYTE MAX+1 DUP (?)
	stringSize DWORD ?

	newline BYTE 13, 10, 0
	divBy0 BYTE "NaN", 13, 10, 0

	first BYTE ?

	num DWORD 0
	result DWORD 0
	tempnum DWORD 0

	whatSign DWORD 0

 .code
 main PROC

 start:
	
	;call clrscr
	xor esi, esi
	mov eax, 0
	mov num, eax
	mov result, 0
	mov first, 1
	
	mov edx, offset stringIn
	mov ecx, MAX
	call readstring
	mov stringSize, eax

	mov ecx, 0
	xor esi, esi
	mov ebx, 10

	L1:
		movzx eax, stringIn[esi]
		.IF eax > 47 && eax < 58
			sub eax, 48	
			mov tempnum, eax
			mov eax, num
			mul ebx
			add eax, tempnum
			mov num, eax
		.ELSEIF eax == '*' || eax == '+' || eax == '-' || eax == '/' || eax == '^'
			push eax
			jmp GoHere
		.ENDIF
		GoBack:
		add esi, 1
		add ecx, 1
	cmp ecx, stringSize
	jle L1

GoHere:
	mov eax, result

	.IF whatSign == '*'
		.IF first != 1
		mul num
		.ELSE
		mov eax, num
		.ENDIF

	.ELSEIF whatSign == '+'
		add eax, num

	.ELSEIF whatSign == '/'
		.IF num == 0
			mov edx, offset divBy0
			call writestring
			jmp start
		.ELSE
			.IF first != 1
			div num
			.IF edx != 0
				test eax, eax
				jl neg2
				call writedec
				jmp pos2
				neg2:
				call writeint
				pos2:

				mov ebx, num
				mov al, '.'
				call writechar

				mov ecx, 3			; number of decimals
				L3:
				imul eax, edx, 10
				xor edx, edx
				div ebx
				call writeDec
				Loop L3
				mov edx, offset newline
				call writestring

				jmp start
			.ENDIF
			.ELSE
			mov eax, num
			.ENDIF
		.ENDIF

	.ELSEIF whatsign == '-'
		.IF first != 1
		sub eax, num
		.ELSE
		mov eax, num
		.ENDIF

	.ELSEIF whatSign == '^'
		.IF first == 1
			mov eax, num
		.ELSE
			.IF num == 0
				mov eax, 1
			.ELSEIF num == 1
				;mov eax, result
			.ELSE
				push ecx
				push esi
				mov ecx, num
				sub ecx, 1
				mov esi, eax
				L2:
					mul esi
				Loop L2
				pop esi
				pop ecx
			.ENDIF
		.ENDIF
	.ENDIF
	.IF first == 1
	mov eax, num
	mov result, eax
	.ELSE
	mov result, eax
	.ENDIF
	mov num, 0
	mov first, 0

	pop eax
	.IF eax == '*'
		mov whatSign, '*'
	.ELSEIF eax == '-'
		mov whatSign, '-'
	.ELSEIF eax == '+'
		mov whatSign, '+'
	.ELSEIF eax == '/'
		mov whatsign, '/'
	.ELSEIF eax == '^'
		mov whatSign, '^'
	.ENDIF
	mov eax, result

	cmp ecx, stringSize
	jle GoBack

	test eax, eax
	jl neg1
	call writeDec
	jmp pos1
	neg1:
	call writeint
	pos1:
	mov edx, offset newline
	call writestring

	jmp start

quit:
  INVOKE ExitProcess, eax
 main ENDP
END main
