; ������ ⥪�� �ணࠬ�� ��� ����� ⨯� .COM
TESTPC SEGMENT
 ASSUME CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
 ORG 100H
 START: JMP BEGIN
; ������
NEDOST_MEM_ db '�������� ���� ��ࢮ�� ���� ������㯭�� �����: '
NEDOST_MEM db '    ',0DH,0AH,'$'
SEG_ADRESS_SREDI_ db '�������� ���� �।�, 	��।������� �ணࠬ��: '
SEG_ADRESS_SREDI db '    ',0DH,0AH,'$'
TAIL_ db '����� ��������� ��ப�: ',0DH,0AH,'$'
SREDA_ db '����ন��� ������ �।� � ᨬ���쭮� ����: ',0DH,0AH,'$'
PATH_ db '���� ����㦠����� �����: ',0DH,0AH,'$'
STRENDL db 0DH,0AH,'$'
; ���������
;---------------------------------------
PRINT PROC
	push ax
	mov ah,09h
	int 21h
	pop ax
	ret
PRINT ENDP
;---------------------------------------
GET_ADRESS_NEDOST_MEM PROC
	mov ax,es:[2]
	mov di,offset NEDOST_MEM+3
	call WRD_TO_HEX
	lea dx,NEDOST_MEM_
	call PRINT
	ret
GET_ADRESS_NEDOST_MEM ENDP	
;---------------------------------------
GET_SEG_ADRESS_SREDI PROC
	mov ax,es:[2Ch]
	mov di,offset SEG_ADRESS_SREDI+3
	call WRD_TO_HEX
	lea dx,SEG_ADRESS_SREDI_
	call PRINT
	ret
GET_SEG_ADRESS_SREDI  ENDP
;---------------------------------------
TAIL PROC
	mov dx,offset TAIL_
	call PRINT
	mov cx,0
	mov cl,es:[80h]
	cmp cl,0
	je TAIL_END
	mov dx,81h
	mov bx,0
	mov ah,02h
	TAIL_loop:
		mov dl,es:[bx+81h]
		int 21h
		inc	bx
	loop TAIL_loop
	mov dx,offset STRENDL
	call PRINT
	TAIL_END:
	ret
TAIL ENDP
;--------------------------------------
SREDA PROC
	mov dx,offset SREDA_
	call PRINT
	push es
	; ����� � es ���� ������ �।�
	mov ax,es:[2Ch]
	mov es,ax
	mov ah,02h
	mov bx,0
	SREDA_loop:
		mov dl,es:[bx]
		int 21h
		inc	bx
		cmp byte ptr es:[bx],00h
		jne SREDA_loop
		mov dx,offset STRENDL
		call PRINT
		cmp word ptr es:[bx],0000h
		jne SREDA_loop
		
	add bx,4 ; �ய�᪠�� 0001
	mov dx,offset PATH_
	call PRINT
	
	SREDA_loop2:
		mov dl,es:[bx]
		int 21h
		inc	bx
		cmp byte ptr es:[bx],00h
		jne SREDA_loop2
	mov dx,offset STRENDL
	call PRINT
	
	pop es
	ret
SREDA ENDP
;--------------------------------------
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
; ��ॢ�� � 16�/� 16-� ࠧ�來��� �᫠
; � AX - �᫮, DI - ���� ��᫥����� ᨬ����
WRD_TO_HEX PROC near
	push BX
	mov BH,AH
	call BYTE_TO_HEX
	mov [DI],AH
	dec DI
	mov [DI],AL
	dec DI
	mov AL,BH
	call BYTE_TO_HEX
	mov [DI],AH
	dec DI
	mov [DI],AL
	pop BX
	ret
WRD_TO_HEX ENDP
;---------------------------------------
; ��ॢ�� � 10�/�, SI - ���� ���� ����襩 ����
BYTE_TO_DEC PROC near
	push CX
	push DX
	xor AH,AH
	xor DX,DX
	mov CX,10
loop_bd: div CX
	or DL,30h
	mov [SI],DL
	dec SI
	xor DX,DX
	cmp AX,10
	jae loop_bd
	cmp AL,00h
	je end_l
	or AL,30h
	mov [SI],AL
end_l: pop DX
	pop CX
	ret
BYTE_TO_DEC ENDP
;---------------------------------------
BEGIN:
	call GET_ADRESS_NEDOST_MEM
	call GET_SEG_ADRESS_SREDI
	call TAIL
	call SREDA
	xor AL,AL
	mov AH,4Ch
	int 21H
TESTPC ENDS
 END START 