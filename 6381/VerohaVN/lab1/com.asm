CODESEG    SEGMENT
           ASSUME  CS:CODESEG, DS:CODESEG, ES:NOTHING, SS:NOTHING
           ORG     100H
START:     JMP     BEGIN

; ������
TYPE_PC		db	'��� IBM PC:   ',0DH,0AH,'$'

MSDOS_VER 	db  '����� MS-DOS:   .  ',0DH,0AH,'$'

OEM_NUM		db	'��਩�� ����� OEM:    ',0DH,0AH,'$'

USER_NUM	db	'��਩�� ����� ���짮��⥫�:         H',0DH,0AH,'$'

        

;���������

; ��楤�� ���� ��ப�
WriteMsg  PROC  NEAR
          mov   AH,09h
          int   21h  ; �맮� �㭪樨 DOS �� ���뢠���
          ret
WriteMsg  ENDP
            
;-----------------------------------------------------
TETR_TO_HEX   PROC  near
           and      AL,0Fh
           cmp      AL,09
           jbe      NEXT
           add      AL,07
NEXT:      add      AL,30h
           ret
TETR_TO_HEX   ENDP
;-------------------------------
BYTE_TO_HEX   PROC  near
; ���� � AL ��ॢ������ � ��� ᨬ���� ���. �᫠ � AX
           push     CX
           mov      AH,AL
           call     TETR_TO_HEX
           xchg     AL,AH
           mov      CL,4
           shr      AL,CL
           call     TETR_TO_HEX ;� AL ����� ���
           pop      CX          ;� AH ������
           ret
BYTE_TO_HEX  ENDP
;-------------------------------
WRD_TO_HEX   PROC  near
;��ॢ�� � 16 �/� 16-� ࠧ�來��� �᫠
; � AX - �᫮, DI - ���� ��᫥����� ᨬ����
           push     BX
           mov      BH,AH
           call     BYTE_TO_HEX
           mov      [DI],AH
           dec      DI
           mov      [DI],AL
           dec      DI
           mov      AL,BH
           call     BYTE_TO_HEX
           mov      [DI],AH
           dec      DI
           mov      [DI],AL
           pop      BX
           ret
WRD_TO_HEX ENDP
;--------------------------------------------------
BYTE_TO_DEC   PROC  near
; ��ॢ�� ���� � 10�/�, SI - ���� ���� ����襩 ����
; AL ᮤ�ন� ��室�� ����
	   push	    AX
           push     CX
           push     DX
           xor      AH,AH
           xor      DX,DX
           mov      CX,10
loop_bd:   div      CX
           or       DL,30h
           mov      [SI],DL
           dec      SI
           xor      DX,DX
           cmp      AX,10
           jae      loop_bd
           cmp      AL,00h
           je       end_l
           or       AL,30h
           mov      [SI],AL
end_l:     pop      DX
           pop      CX
	   pop	    AX
           ret
BYTE_TO_DEC    ENDP
;-------------------------------

; ��楤�� ��।������ ⨯� PC
PC_INFO PROC	NEAR
	push	AX
	push	BX
	push	DX
	push	ES
	mov	BX,0F000H
	mov	ES,BX
	mov	AL,ES:[0FFFEH]
	call	BYTE_TO_HEX
	lea	BX,TYPE_PC
	mov	[BX+12],AX
	pop	ES
	pop	DX
	pop	BX
	pop	AX
	ret

PC_INFO	ENDP

; ��楤�� ��।������ ���ᨨ MS-DOS
SYSTEM_INFO	PROC	NEAR
	push	AX
	push	SI
	
	lea	SI,MSDOS_VER
	add	SI,16
	call	BYTE_TO_DEC

	lea	SI,MSDOS_VER
	add	SI,19
	mov	AL,AH
	call	BYTE_TO_DEC

	pop	SI
	pop	AX
	ret
SYSTEM_INFO	ENDP
        

; ��楤�� ��।������ ����� OEM
OEM_INFO	PROC	NEAR
	push	AX
	push	BX
	push	SI
	
	mov	AL,BH
	lea	SI,OEM_NUM
	add	SI,22
	call	BYTE_TO_DEC

	pop	SI
	pop	BX
	pop	AX
	ret
OEM_INFO	ENDP

; ��楤�� ��।������ ����� ���짮��⥫�
USER_INFO	PROC	NEAR
	push	AX
	push	BX
	push	CX
	push	DI
	
	mov	AX,CX
	lea	DI,USER_NUM
	add	DI,36
	call	WRD_TO_HEX

	mov	AL,BL
	call	BYTE_TO_HEX
	lea	DI,USER_NUM
	add	DI,31
	mov	[DI],AX

	pop	DI
	pop	CX
	pop	BX
	pop	AX
	ret

USER_INFO	ENDP


; ���
BEGIN:

	call	PC_INFO

	mov	AH,30H
	INT	21H	

	call	SYSTEM_INFO
	call	OEM_INFO
	call	USER_INFO
        
; �뢮� ���ᨨ PC
	lea	DX,TYPE_PC
	call	WriteMsg

; �뢮� ���ᨨ MS-DOS
	lea	DX,MSDOS_VER
	call	WriteMsg	

; �뢮� ������ OEM
	lea	DX,OEM_NUM
	call	WriteMsg

; �뢮� ����� ���짮��⥫�
	lea	DX,USER_NUM
	call	WriteMsg
        
; ��室 � DOS
           xor     AL,AL
           mov     AH,4Ch
           int     21H
CODESEG     ENDS
            END     START     ;����� �����, START - �窠 �室�
