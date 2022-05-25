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
		cmp eax, 47
		jbe @f
		cmp eax, 58
		jae @f
			sub eax, 48	
			mov tempnum, eax
			mov eax, num
			mul ebx
			add eax, tempnum
			mov num, eax
		@@:
		cmp eax, 42
		je @f
		cmp eax, 43
		je @f
		cmp eax, 45
		je @f
		cmp eax, 47
		je @f
		cmp eax, 94
		jne endif1
		@@:
			push eax
			jmp GoHere
		endif1:
		GoBack:
		add esi, 1
		add ecx, 1
	cmp ecx, stringSize
	jle L1
GoHere:
	mov eax, result
	cmp whatsign, 42		
	jne @f
	cmp first, 1
	je else1
	mul num
	jmp endif2
	else1:
		mov eax, num
		jmp endif2
	@@:
	cmp whatsign, 43
	jne @f
		add eax, num
		jmp endif2
	@@:
	cmp whatsign, 47
	jne @f
		cmp num, 0
		jne divelse1
			mov edx, offset divBy0
			call writestring
			jmp start
		divelse1:
			cmp first, 1
			je firstDiv
				div num
				cmp edx, 0
				je endif2
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
					mov ecx, 3
					L3:
						imul eax, edx, 10
						xor edx, edx
						div ebx
						call writeDec
					Loop L3
					mov edx, offset newline
					call writestring
					jmp start
			firstDiv:
				mov eax, num
				jmp endif2
	@@:
	cmp whatsign, 45
	jne @f
	cmp first, 1
	je subelse1
		sub eax, num
		jmp endif2
	subelse1:
		mov eax, num
		jmp endif2
	@@:
	cmp whatsign, 94 
	jne endif2
	cmp first, 1
	jne powerelse1
		mov eax, num
		jmp endif2
	powerelse1:
		cmp num, 0
		jne	powerelif1
			mov eax, 1
			jmp endif2
		powerelif1:
		cmp num, 1
		jne powerelse2
			jmp endif2
		powerelse2:
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
	endif2:
	cmp first, 1
	jne @f
		mov eax, num
		mov result, eax
		jmp endif3
	@@:
	mov result, eax
	endif3:
	mov num, 0
	mov first, 0
	pop eax
	cmp eax, 42
	jne @f
		mov whatSign, '*'
		jmp endif4
	@@:
	cmp eax, 45
	jne @f
		mov whatSign, '-'
		jmp endif4
	@@:
	cmp eax, 43
	jne @f
		mov whatSign, '+'
		jmp endif4
	@@:
	cmp eax, 47
	jne @f
		mov whatsign, '/'
		jmp endif4
	@@:
	cmp eax, 94
	jne endif4
		mov whatSign, '^'
	endif4:
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
