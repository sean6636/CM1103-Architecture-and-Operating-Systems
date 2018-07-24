.586
.model flat, stdcall
option casemap :none
.stack 4096
extrn ExitProcess@4: proc

GetStdHandle proto :dword
ReadConsoleA  proto :dword, :dword, :dword, :dword, :dword
WriteConsoleA proto :dword, :dword, :dword, :dword, :dword
MessageBoxA proto	:dword, :dword, :dword, :dword
STD_INPUT_HANDLE equ -10
STD_OUTPUT_HANDLE equ -11


.data
		
		bufSize = 80
 	 	inputHandle DWORD ?
 	    buffer db bufSize dup(?)
 	    bytes_read  DWORD  ?
		sum_string db "Your value converted to fahrenheit is ",0
		sum_string2 db "			Your value converted to celsius is ",0
		outputHandle DWORD ?
		bytes_written dd ?
		actualNumber dw 0 ; This is the input number as binary
		actualNumber2 dw 0
		asciiBuf db 4 dup (" ")
.code

	main:
		
 	    invoke GetStdHandle, STD_INPUT_HANDLE
 	    mov inputHandle, eax
 		invoke ReadConsoleA, inputHandle, addr buffer, bufSize, addr bytes_read,0
		sub bytes_read, 2	; -2 to remove cr,lf
 		mov ebx,0		
		mov al, byte ptr buffer+[ebx] 
		sub al,30h
		add	[actualNumber],ax ; Actualnumber contains binary value at this point
		

	getNext:

	inc	bx
		cmp ebx,bytes_read
		jz cont
		mov	ax,10
		mul	[actualNumber]
		mov actualNumber,ax
		mov al, byte ptr buffer+[ebx] 
		sub	al,30h
		add actualNumber,ax
		
		jmp getNext

	cont:

		mov dx, actualNumber
		mov actualNumber2, dx

		mov cx, actualNumber
		mov ax, 9
		imul cx
		mov cx, 5
		idiv cx
		add ax, 32
		mov actualNumber, ax

		invoke GetStdHandle, STD_OUTPUT_HANDLE
 	    mov outputHandle, eax
		mov	eax,LENGTHOF sum_string	;length of sum_string
		invoke WriteConsoleA, outputHandle, addr sum_string, eax, addr bytes_written, 0
		mov ax,[actualNumber]
		mov cl,10
		mov	ebx,3

	nextNum:

		div	cl
		add	ah,30h
		mov byte ptr asciiBuf+[ebx],ah
		dec	ebx
		mov	ah,0
		cmp al,0
		ja nextNum
		
		mov	eax,4

 	    invoke WriteConsoleA, outputHandle, addr asciiBuf, eax, addr bytes_written, 0
	
		invoke MessageBoxA, 0, addr asciiBuf, addr sum_string,0
		mov eax,0
		mov eax,bytes_written
		push	0

	cont2:
		mov cx, actualNumber2
		sub cx, 32
		mov ax, 5
		imul cx
		mov cx, 9
		idiv cx
		mov actualNumber2, ax

		invoke GetStdHandle, STD_OUTPUT_HANDLE
 	    mov outputHandle, eax
		mov	eax,LENGTHOF sum_string	;length of sum_string
		invoke WriteConsoleA, outputHandle, addr sum_string2, eax, addr bytes_written, 0
		mov ax,[actualNumber2]
		mov cl,10
		mov	ebx,3

	
	nextNum2:
	
		div	cl
		add	ah,30h
		mov byte ptr asciiBuf+[ebx],ah
		dec	ebx
		mov	ah,0
		cmp al,0
		ja nextNum2
		
		mov	eax,4

 	    invoke WriteConsoleA, outputHandle, addr asciiBuf, eax, addr bytes_written, 0
	
		invoke MessageBoxA, 0, addr asciiBuf, addr sum_string2,0
		mov eax,0
		mov eax,bytes_written
		push	0

		call	ExitProcess@4
end		main