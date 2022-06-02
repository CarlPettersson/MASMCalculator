.386
.MODEL flat, stdcall
 ExitProcess PROTO, dwExitCode: DWORD 
 include Irvine32.inc 

 .data
	MAX = 50				
	stringIn BYTE MAX+1 DUP (?)
	stringSize DWORD ?		
	newline BYTE 13, 10, 0	
	divBy0 BYTE "NaN", 13, 10, 0			; data variables
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
	mov first, 1				; reset variables and read input
	mov edx, offset stringIn
	mov ecx, MAX
	call readstring
	mov stringSize, eax
	mov ecx, 0
	xor esi, esi
	mov ebx, 10
	L1:
		movzx eax, stringIn[esi]
		cmp eax, 71h				; if input is q quit
		jz quit						  
		cmp eax, 30h				; check if number
		jb @f
		cmp eax, 39h				
		ja @f
			sub eax, 30h			; convert to real number from utf-8 encoding
			mov tempnum, eax		 
			mov eax, num			
			mul ebx
			add eax, tempnum
			mov num, eax
		@@:
		cmp eax, 2ah				
		je @f
		cmp eax, 2bh				
		je @f
		cmp eax, 2dh				; check if correct symbol
		je @f
		cmp eax, 2fh				
		je @f
		cmp eax, 5eh				
		jne endif1			
		@@:
			push eax				
			jmp GoHere				; if correct symbol start to calculate
		endif1:
		GoBack:
		add esi, 1					
		add ecx, 1
	cmp ecx, stringSize				; loop through the whole input string
	jle L1
GoHere:
	mov eax, result
	cmp whatsign, 2ah				
	jne @f
	cmp first, 1					
	je else1
	mul num							; if not first sign multiply number
	jmp endif2
	else1:
		mov eax, num				
		jmp endif2
	@@:
	cmp whatsign, 2bh				
	jne @f
		add eax, num				; add number
		jmp endif2
	@@:
	cmp whatsign, 2fh				
	jne @f
		cmp num, 0					; if div by zero give error and go to beginning
		jne divelse1
			mov edx, offset divBy0
			call writestring
			jmp start
		divelse1:
			cmp first, 1			; if first sign jmp firstdiv
			je firstDiv
				div num				; div by num
				cmp edx, 0			; check if rest is 0
				je endif2
					test eax, eax	; check if negative
					jl neg2
					call writedec	
					jmp pos2
					neg2:
					call writeint	; write num before decimal place
					pos2:
					mov ebx, num
					mov al, '.'		
					call writechar	; write decimal 
					mov ecx, 3		; number of deciaml places
					L3:
						imul eax, edx, 10	
						xor edx, edx		
						div ebx				; write decimal places
						call writeDec		
					Loop L3
					mov edx, offset newline	
					call writestring		; write a newline
					jmp start				; go to beginning
			firstDiv:
				mov eax, num				
				jmp endif2
	@@:
	cmp whatsign, 2dh			
	jne @f
	cmp first, 1				
	je subelse1
		sub eax, num				; sub eax by num
		jmp endif2
	subelse1:
		mov eax, num
		jmp endif2
	@@:
	cmp whatsign, 5eh
	jne endif2
	cmp first, 1
	jne powerelse1
		mov eax, num
		jmp endif2
	powerelse1:
		cmp num, 0	
		jne	powerelif1
			mov eax, 1				; if exponent is 0 answer is 1
			jmp endif2
		powerelif1:
		cmp num, 1
		jne powerelse2
			jmp endif2				; if exponent is 1 answer is input number
		powerelse2:
			push ecx
			push esi
			mov ecx, num			; else multiply exponent number of times
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
	cmp eax, 2ah
	jne @f
		mov whatSign, 2ah
		jmp endif4
	@@:
	cmp eax, 2dh
	jne @f
		mov whatSign, 2dh
		jmp endif4
	@@:							; set correct sign for loop
	cmp eax, 2bh
	jne @f
		mov whatSign, 2bh
		jmp endif4
	@@:
	cmp eax, 2fh
	jne @f
		mov whatsign, 2fh
		jmp endif4
	@@:
	cmp eax, 5eh
	jne endif4
		mov whatSign, 5eh
	endif4:
	mov eax, result
	cmp ecx, stringSize
	jle GoBack					; if whole input is not done go back
	test eax, eax
	jl neg1
	call writeDec
	jmp pos1					; write out result
	neg1:
	call writeint
	pos1:
	mov edx, offset newline
	call writestring
	jmp start
quit:
  INVOKE ExitProcess, 0			; quit program with code 0
 main ENDP
END main
