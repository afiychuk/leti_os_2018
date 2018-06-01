CODE SEGMENT
 ASSUME CS:CODE, DS:DATA, ES:DATA, SS:STACKSEG
START: JMP BEGIN
; ���������
;---------------------------------------
; ��뢠�� ���뢠���, �����饥 ��ப�.
PRINT PROC near
	push ax
	mov AH,09h
	int 21h
	pop ax
	ret
PRINT ENDP
;---------------------------------------
TETR_TO_HEX PROC near
	and AL,0Fh
	cmp AL,09
	jbe NEXT
	add AL,07
NEXT: add AL,30h
	ret
TETR_TO_HEX ENDP
;---------------------------------------
BYTE_TO_HEX PROC near
	push CX
	mov AH,AL
	call TETR_TO_HEX
	xchg AL,AH
	mov CL,4
	shr AL,CL
	call TETR_TO_HEX 
	pop CX 
	ret
BYTE_TO_HEX ENDP
;---------------------------------------
; �㭪�� �᢮�������� ��譥� �����
FREE_MEM PROC
	; ����塞 � BX ����室���� ������⢮ ����� ��� �⮩ �ணࠬ�� � ��ࠣ���
		mov ax,STACKSEG ; � ax ᥣ����� ���� �⥪�
		mov bx,es
		sub ax,bx ; ���⠥� ᥣ����� ���� PSP
		add ax,10h ; �ਡ���塞 ࠧ��� �⥪� � ��ࠣ���
		mov bx,ax
	; �஡㥬 �᢮������ ����� ������
		mov ah,4Ah
		int 21h
		jnc FREE_MEM_SUCCESS
	
	; ��ࠡ�⪠ �訡��
		mov dx,offset STR_ERR_FREE_MEM
		call PRINT
		cmp ax,7
		mov dx,offset STR_ERR_MCB_DESTROYED
		je FREE_MEM_PRINT_ERROR
		cmp ax,8
		mov dx,offset STR_ERR_NOT_ENOUGH_MEM
		je FREE_MEM_PRINT_ERROR
		cmp ax,9
		mov dx,offset STR_ERR_WRNG_MEM_BL_ADDR
		
		FREE_MEM_PRINT_ERROR:
		call PRINT
		mov dx,offset STRENDL
		call PRINT
	
	; ��室 � DOS
		xor AL,AL
		mov AH,4Ch
		int 21H
	
	FREE_MEM_SUCCESS:
	ret
FREE_MEM ENDP
;---------------------------------------
; �㭪�� ᮧ����� ����� ��ࠬ��஢
CREATE_PARAM_BLOCK PROC
	mov ax, es:[2Ch]
	mov PARMBLOCK,ax ; ����� ᥣ����� ���� �।�
	mov PARMBLOCK+2,es ; �������� ���� ��ࠬ��஢ ��������� ��ப�(PSP)
	mov PARMBLOCK+4,80h ; ���饭�� ��ࠬ��஢ ��������� ��ப�
	ret
CREATE_PARAM_BLOCK ENDP
;---------------------------------------
; �㭪�� ����᪠ ���୥�� �����
RUN_CHILD PROC
	mov dx,offset STRENDL
	call PRINT
	; ��⠭�������� DS:DX �� ��� ��뢠���� �ணࠬ��
		
		mov dx,offset STD_CHILD_PATH
		; ����ਬ, ���� �� 墮��
		xor ch,ch
		mov cl,es:[80h]
		cmp cx,0
		je RUN_CHILD_NO_TAIL ; �᫨ ��� 墮��, � �ᯮ��㥬 �⠭���⭮� ��� ��뢠���� �ணࠬ��
		mov si,cx ; si - ����� �����㥬��� ᨬ����
		push si ; ���࠭塞 ���-�� ᨬ�����
		RUN_CHILD_LOOP:
			mov al,es:[81h+si]
			mov [offset CHILD_PATH+si-1],al			
			dec si
		loop RUN_CHILD_LOOP
		pop si
		mov [CHILD_PATH+si-1],0 ; ����� � ����� 0
		mov dx,offset CHILD_PATH ; ����� ����, �ᯮ��㥬 ���
		RUN_CHILD_NO_TAIL:
		
	; ��⠭�������� ES:BX �� ���� ��ࠬ��஢
		push ds
		pop es
		mov bx,offset PARMBLOCK

	; ���࠭塞 SS, SP
		mov KEEP_SP, SP
		mov KEEP_SS, SS
	
	; ��뢠�� �����稪:
		mov ax,4b00h
		int 21h
		jnc RUN_CHILD_SUCCESS
	
	; ����⠭�������� DS, SS, SP
		push ax
		mov ax,DATA
		mov ds,ax
		pop ax
		mov SS,KEEP_SS
		mov SP,KEEP_SP
	
	; ��ࠡ��뢠�� �訡��:
		cmp ax,1
		mov dx,offset STR_ERR_WRNG_FNCT_NUMB
		je RUN_CHILD_PRINT_ERROR
		cmp ax,2
		mov dx,offset STR_ERR_FL_NOT_FND
		je RUN_CHILD_PRINT_ERROR
		cmp ax,5
		mov dx,offset STR_ERR_DISK_ERR
		je RUN_CHILD_PRINT_ERROR
		cmp ax,8
		mov dx,offset STR_ERR_NOT_ENOUGH_MEM2
		je RUN_CHILD_PRINT_ERROR
		cmp ax,10
		mov dx,offset STR_ERR_WRONG_ENV_STR
		je RUN_CHILD_PRINT_ERROR
		cmp ax,11
		mov dx,offset STR_ERR_WRONG_FORMAT	
		je RUN_CHILD_PRINT_ERROR
		mov dx,offset STR_ERR_UNKNWN
		RUN_CHILD_PRINT_ERROR:
		call PRINT
		mov dx,offset STRENDL
		call PRINT
	
	; ��室�� � DOS
		xor AL,AL
		mov AH,4Ch
		int 21H
		
	RUN_CHILD_SUCCESS:
	mov ax,4d00h
	int 21h
	; �뢮� ��稭� �����襭��
		cmp ah,0
		mov dx,offset STR_NRML_END
		je RUN_CHILD_PRINT_END_RSN
		cmp ah,1
		mov dx,offset STR_CTRL_BREAK
		je RUN_CHILD_PRINT_END_RSN
		cmp ah,2
		mov dx,offset STR_DEVICE_ERROR
		je RUN_CHILD_PRINT_END_RSN
		cmp ah,3
		mov dx,offset STR_RSDNT_END
		je RUN_CHILD_PRINT_END_RSN
		mov dx,offset STR_UNKNWN
		RUN_CHILD_PRINT_END_RSN:
		call PRINT
		mov dx,offset STRENDL
		call PRINT

	; �뢮� ���� �����襭��:
		mov dx,offset STR_END_CODE
		call PRINT
		call BYTE_TO_HEX
		push ax
		mov ah,02h
		mov dl,al
		int 21h
		pop ax
		xchg ah,al
		mov ah,02h
		mov dl,al
		int 21h
		mov dx,offset STRENDL
		call PRINT

	ret
RUN_CHILD ENDP
;---------------------------------------
BEGIN:
	mov ax,data
	mov ds,ax
	
	call FREE_MEM
	call CREATE_PARAM_BLOCK
	call RUN_CHILD
	
	xor AL,AL
	mov AH,4Ch
	int 21H
CODE ENDS
; ������
DATA SEGMENT
	; ��ப� �訡��:
		STR_ERR_FREE_MEM	 		db 'Error when freeing memory: $'
		STR_ERR_MCB_DESTROYED 		db 'MCB is destroyed$'
		STR_ERR_NOT_ENOUGH_MEM 		db 'Not enough memory for function processing$'
		STR_ERR_WRNG_MEM_BL_ADDR 	db 'Wrong addres of memory block$'
		STR_ERR_UNKNWN				db 'Unknown error$'
		
		; �訡�� �� �����稪� OS
		STR_ERR_WRNG_FNCT_NUMB		db 'Function number is wrong$'
		STR_ERR_FL_NOT_FND			db 'File is not found$'
		STR_ERR_DISK_ERR			db 'Disk error$'
		STR_ERR_NOT_ENOUGH_MEM2		db 'Not enough memory$'
		STR_ERR_WRONG_ENV_STR		db 'Wrong environment string$'
		STR_ERR_WRONG_FORMAT		db 'Wrong format$'
	; ��ப�, ᮤ�ঠ騥 ��稭� �����襭�� ���୥� �ணࠬ��
		STR_NRML_END		db 'Normal end$'
		STR_CTRL_BREAK		db 'End by Ctrl-Break$'
		STR_DEVICE_ERROR	db 'End by device error$'
		STR_RSDNT_END		db 'End by 31h function$'
		STR_UNKNWN			db 'End by unknown reason$'
		STR_END_CODE		db 'End code: $'
		
	STRENDL db 0DH,0AH,'$'
	; ���� ��ࠬ��஢. ��। ����㧪�� ���୥� �ணࠬ�� �� ���� ������ 㪠�뢠�� ES:BX
	PARMBLOCK 	dw 0 ; �������� ���� �।�
				dd ? ; �������� ���� � ᬥ饭�� ��ࠬ��஢ ��������� ��ப�
				dd 0 ; ������� � ᬥ饭�� ��ࢮ�� FCB
				dd 0 ; ��ண�
	
	CHILD_PATH  	db 50h dup ('$')
	STD_CHILD_PATH	db 'LAB2.EXE',0
	; ��६���� ��� �࠭���� SS, SP
	KEEP_SS dw 0
	KEEP_SP dw 0
DATA ENDS
; ����
STACKSEG SEGMENT STACK
	dw 80h dup (?) ; 100h ����
STACKSEG ENDS
 END START