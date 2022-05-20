.386
.MODEL flat, stdcall
 ExitProcess PROTO, dwExitCode: DWORD 

 include Irvine32.inc 

 .data

	MAX = 80
	stringIn BYTE MAX+1 DUP (?)
	stringSize DWORD ?

	newline BYTE 13, 10, 0
	divBy0 BYTE "inf", 13, 10, 0

	num1 DWORD ?
	num2 DWORD 0
	tempnum DWORD 0
	tempnum2 DWORD 0
	whatSign DWORD 0

 .code
 main PROC

 start:

	;call clrscr
	xor esi, esi
	mov eax, 0
	mov tempnum2, eax
	
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
			mov eax, tempnum2
			mul ebx
			add eax, tempnum
			mov tempnum2, eax
		.ELSEIF eax == '*'
			mov whatSign, '*'
			mov eax, tempnum2
			mov num1, eax
			mov tempnum2, 0
		.ELSEIF eax == '+'
			mov whatSign, '+'
			mov eax, tempnum2
			mov num1, eax
			mov tempnum2, 0
		.ELSEIF eax == '/'
			mov whatSign, '/'
			mov eax, tempnum2
			mov num1, eax
			mov tempnum2, 0
		.ELSEIF eax == '-'
			mov whatSign, '-'
			mov eax, tempnum2
			mov num1, eax
			mov tempnum2, 0
		.ELSEIF eax == '^'
			mov whatSign, '^'
			mov eax, tempnum2
			mov num1, eax
			mov tempnum2, 0
		.ENDIF
		add esi, 1
		add ecx, 1
	cmp ecx, stringSize
	jle L1
	mov eax, tempnum2
	mov num2, eax
	mov eax, num1
	.IF whatSign == '*'
		mul num2
	.ELSEIF whatSign == '+'
		add eax, num2
	.ELSEIF whatSign == '/'
		.IF num2 == 0
			mov edx, offset divBy0
			call writestring
			jmp start
		.ELSE
			div num2
			.IF edx != 0
				test eax, eax
				jl neg2
				call writedec
				jmp pos2
				neg2:
				call writeint
				pos2:

				mov ebx, num2
				mov al, '.'
				call writechar

				mov ecx, 3			; number of decimals
				L3:
				imul eax, edx, 10
				xor edx, edx
				div ebx
				call writeDec
				Loop L3

				jmp start
			.ENDIF
		.ENDIF
	.ELSEIF whatsign == '-'
		sub eax, num2
	.ELSEIF whatSign == '^'
		.IF num2 == 0
			mov eax, 1
		.ELSEIF num2 == 1
			mov eax, num1
		.ELSE
			mov ecx, num2
			sub ecx, 1
			mov esi, eax
			L2:
				mul esi
			Loop L2
		.ENDIF
	.ENDIF
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