.model tiny
.data
    ramka db '123456789', 0c9h, 0cdh, 0bbh, 0bah, 20h, 0bah, 0c8h, 0cdh, 0bch

.code
org 100h

Start:
    cld

    xor cx, cx
    xor dx, dx

    call readArguments

    push bx
    push ax
    call alignToCenter
    pop ax

    call drawFrame
    pop si

    call alignTitleToCenter

    call drawTitle

    mov ah, 4ch
    int 21h

Error:
    mov al, 1
    mov ah, 4ch
    int 21h

;-----------------------------------------------------------
; ���뢠�� ��㬥��� ������� � ��������� ��ப�
; Entry: None
; Exit : ds:si - ���� ��砫� ��ப� � ����⠬� ࠬ��
;           bx - ᬥ饭�� � ᥣ���� ������ �� ������
;           �l - �ਭ� ࠬ��
;           dl - ���� ࠬ��
;           ah - 梥�
; Destr: ds, si, cx, dx, ax
;-----------------------------------------------------------

readArguments   proc
    mov si, 81h
    lodsb
    cmp al, 0dh
    je Error        ; �᫨ ��㬥��� �� ������, �ணࠬ�� �����頥� �訡��

    call readNumber
    mov cl, bl      ; ������� � cl �ਭ� ࠬ��

    call readNumber
    mov dl, bl      ; ������� � dl ����� ࠬ��

    call readNumber
    mov ch, bl      ; ������� � ch 梥� ࠬ��

    call readNumber ; ��।���� ����� �⨫� ࠬ��
    mov al, 9
    mul bl          ; ���᫨� ᬥ饭�� � ���ᨢ� �⨫�� ࠬ�� �� ���������

    push ax
    call readTitle  ; ��������� ᬥ饭�� �� ������
    pop ax

    lea si, [ramka] ; � ds:si ������� ���� ��ப� � ᨬ������ ࠬ��
    add si, ax      ; ��।���� 㪠��⥫� �� �㦭� �⨫� ࠬ��

    mov ah, ch ; ��६��⨫ 梥� ࠬ�� �� ch � ah
    xor ch, ch ; ���⨫ ch

    ret
    endp

;-----------------------------------------------------------
; �஢����, ���� �� ���� ᨬ��� ��ப� '$' �
; ���������� ᬥ饭�� �� ������
; Entry: ds:si - ���� ��砫� ��ப�
; Exit : bx - ᬥ饭�� � ᥣ���� ������ �� ������
; Destr: si, ax
;-----------------------------------------------------------

readTitle proc
    lodsb
    cmp al, '$'
    jne Error   ; �஢�ਫ, �� ���� ᨬ��� ���� '$'

    mov bx, si  ; ���࠭�� ᬥ饭�� � bx

    ret
    endp

;-----------------------------------------------------------
; ���뢠�� ��ப� �� ����� � �८�ࠧ�� �� � �᫮
; Entry: ds:si - ���� ��砫� ��ப�
; Exit :    bl - ��⠭��� �᫮
; Destr: si, bl, al
;-----------------------------------------------------------

readNumber  proc
    lodsb
    call numberConversion
    mov bl, al

    lodsb
    call checkForSpace
    jb EndRead

    call numberConversion
    shl bl, 4
    add bl, al
    lodsb

    EndRead:
        ret
    endp

;-----------------------------------------------------------
; �஢���� ���� �� ���祭�� al ASCII-����� �஡���
; Entry: al - ASCII-��� ᨬ����
; Exit : cf - 1 �᫨ �� � 0 �᫨ ���
; Destr:
;-----------------------------------------------------------

checkForSpace  proc
    cmp al, ' '
    je ThisIsSpace
    cmp al, 0dh
    je ThisIsSpace

    clc
    ret

    ThisIsSpace:
        stc
        ret
    endp

;-----------------------------------------------------------
; �८�ࠧ�� ASCII-��� ᨬ���� �� al � �᫮
; Entry: al - ASCII-��� ᨬ����
; Exit : al - �᫮
; Destr:
;-----------------------------------------------------------

numberConversion  proc
    cmp al, '0'
    jb Error

    cmp al, '9'
    jb DecimalNumber

    cmp al, 'A'
    jb Error

    cmp al, 'F'
    jb HexadecimalNumber

    DecimalNumber:
        sub al, '0'
        ret

    HexadecimalNumber:
        sub al, 'A'
        add al, 10
        ret
    endp

;-----------------------------------------------------------
; ��।���� ����� ��ப�, ���� '$' ������ ᨬ�����
; � ������ ᬥ饭��, ��� �뢮�� ������ �� 業��� �࠭�
; Entry: ds:si - ���� � ����� ��ப�
; Exit : di - ᬥ饭��
;        cx - ����� ������
; Destr: si, bx
;-----------------------------------------------------------

alignTitleToCenter  proc
    push si
    xor cx, cx
    xor di, di  ; ���⨫ ���� ���祭��

    Count:      ; �����⠫ ����� ������
        lodsb
        cmp al, '$'
        je CalculatingOffset
        inc cx
        jmp Count

    CalculatingOffset:
    mov di, 12 * 80 * 2 ; ����� ᬥ饭�� � 12 ��ப

    mov bx, 80
    sub bx, cx  ; ���-�� ������ ᨬ����� � ��ப� � ��������
    shr bx, 1   ; ����砥� �������� ������ ᨬ����� �� ������
    shl bx, 1   ; �������� ��� �� ���, ⠪ ��� �� �����
                ; ᨬ��� ��室���� ��� ���� � �����

    add di, bx  ; ������塞 ᬥ饭�� ����� ��ப�

    pop si
    ret
    endp

;-----------------------------------------------------------
; �뢮��� �� �࠭ ��ப� �������� ������, ��������� 梥�
; � ������� ᬥ饭���
; Entry: ds:si - ���� � ����� ��ப�
;           ah - 梥� ������
;           di - ᬥ饭��
;           cx - ����� ������
; Exit : None
; Destr: si, di, cx
;-----------------------------------------------------------

drawTitle   proc
    WriteByCharacter:
        lodsb
        stosw
        loop WriteByCharacter

    ret
    endp

;-----------------------------------------------------------
; �����뢠�� ����� ��� �ᯮ������� ࠬ�� ��।��񭭮��
; ࠧ��� �� 業��� �࠭� (80 * 25)
; Entry: cx - �ਭ� ࠬ��
;        dx - ���� ࠬ��
; Exit : di - ᬥ饭��
; Destr: ax, bl
;-----------------------------------------------------------

alignToCenter   proc
    xor di, di

    xor ax, ax
    mov ax, 25  ; ����� � ax ����� �࠭� � ��ப��
    sub ax, dx  ; ����砥� ���-�� ������ ��ப
    shr ax, 1   ; ����砥� �������� ������ ��ப (�� � �ய��⨬)
    mov bl, 80
    mul bl      ; �������� �� �ਭ� �࠭�
    shl ax, 1   ; �������� ��� �� ���, ⠪ ��� �� ����� ᨬ��� ��室���� ��� ���� � �����

    add di, ax

    xor ax, ax
    mov ax, 80  ; ����� � �� �ਭ� �࠭�
    sub ax, cx  ; ��室�� ���-�� ������ �⮫�殢
    shr ax, 1   ; ����砥� �������� ������ �⮫�殢
    shl ax, 1   ; �������� ��� �� ���, ⠪ ��� �� ����� ᨬ��� ��室���� ��� ���� � �����

    add di, ax

    ret
    endp

;-----------------------------------------------------------
; ����� ࠬ�� �� �������� ᨬ�����, ��������� ࠧ��� �
; 梥� � ������� ����㯮�.
; Entry: ds:si - ���� � ����� ��ப� � ࠬ���
;           ah - 梥� ࠬ��
;           di - ᬥ饭��
;           cx - �ਭ� ࠬ��
;           dx - ���� ࠬ��
; Exit : None
; Destr: al, bx, di, si, es
;-----------------------------------------------------------

drawFrame   proc
    sub cx, 2       ; ������ ����७��� ���� �ਭ� ࠬ��
    sub dx, 2       ; ������ ����७��� ���� ����� ࠬ��

    call drawLine   ; ����� ����� ����� ࠬ��

    DrawMiddle:
        add di, 80 * 2  ; ����� �����
        call drawLine   ; ����� �����
        sub si, 3       ; ������� 㪠��⥫� �� 4 ᨬ��� ࠬ��

        dec dx
        cmp dx, 0
        jne DrawMiddle

    add di, 80 * 2  ; ����㯠� �� ��砫� ᫥���饩 �����
    add si, 3       ; �⠢�� 㪠��⥫� �� 7 ᨬ��� ࠬ��
    call drawLine   ; ����� ��᫥���� �����

    ret
    endp

;-----------------------------------------------------------
; ����� ��ப� �� ᨬ����� (����, ��᫥���� �
; �஬������), � �������� �������, 梥⮬ � ����㯮�
; Entry: ds:si - ���� � ����� ��ப� � ࠬ���
;           ah - 梥� ࠬ��
;           di - ᬥ饭��
;           cx - �ਭ� ����७��� ��� ࠬ��
; Exit : None
; Destr: al, bx, si, es
;-----------------------------------------------------------


drawLine    proc
    push cx
    push di
    mov bx, 0b800h
    mov es, bx

    lodsb   ; ����㧨� � al ���� ᨬ��� ࠬ��
    stosw   ; � ����������� ������� ���祭�� �� ax

    lodsb   ; ����㧨� � al ��ன ᨬ��� ࠬ��
    rep stosw   ; � ����������� cx ᨬ����� �� ax

    lodsb   ; ����㧨� � al ��᫥���� ᨬ��� ࠬ��
    stosw   ; � ����������� ������� ���祭�� �� ax

    pop di
    pop cx
    ret
    endp

end Start
