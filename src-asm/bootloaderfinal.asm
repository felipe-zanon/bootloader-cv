jmp short main 
nop

OEMname:		db "FELIPEOS"
bytesperSector: dw 512 
sectorperCluster: db 1
reserveSectors: dw 1
numfatCopies: db 2
numRootEntries: dw 224
numSectors: dw 2880
mediaType: db 0xf0
numFATSectors: dw 9
sectorPerTrack: dw 18
numHeads: dw 2
numHiddenSectors:	dd 0
numHugeSectors:	dd 0
driveNum: db 0
reserved: db 0
extendedBootSignature: db 0x29
volumeID:	dd 0xa1b2c3d4
volumeLabel:	db "FELIPEZANON"
fileSysType:	db "FAT12FZS"

nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop

main:
mov [drvnum], dl
mov ax, 0x7c00
mov ds, ax

mov ax, 0x7c0
mov es, ax

sub ax, 0x200
mov sp, ax
mov bp, ax
;preparando registradores para a interrupção 13h

;Gerar o modo de video
xor ax, ax
mov al, 0x13
int 0x10
;Modo de video 320 x 200 monocromatico estabelecido!

;Chamar fundo branco

call DesenhaFundoBranco
;Com o fundo branco, escrevemos a frase

call EscreveFrase


;Espaço acabou! Temos que ir para a parte 2 do bootloader

;call Desenhar
call ChamarParte2

cli
hlt ; desligar a maquina

; FIM DA "FUNÇÃO MAIN"
jmp $
;-------------------------------------------------------------------------
DesenhaFundoBranco:
push bp
mov bp, sp
pusha ;empurra todos os registradores para a pilha

;Interrupt 10H, function OCH BIOS
;Video: Write graphic pixel
;Draws a color pixel at the specified coordinates in graphic mode.
;Input: 	 AH= OCH
;AL = Pixel color value (see below)
;BH = Graphics page
;cx = Screen column
;dx = Screen lin
xor cx, cx ;contador horizontal
mov dx, 0x1E ; contador vertical (começa na linha 30)
mov ah, 0x0c
mov al, 0x0f
recomeca:
int 0x10
inc cx
cmp cx, 0x140
je zeraHorizontal
jmp recomeca 

fim:
popa ;devolve todos os valores para os registradores
mov sp, bp
pop bp
ret

;--------------------------------------------------------------------------------
zeraHorizontal:
xor cx, cx
inc dx
cmp dx, 0xc8 ;c8 = 200
je fim
jmp recomeca
;--------------------------------------------------------------------------------

EscreveFrase:
push bp
mov bp, sp
pusha ;empurra todos os registradores para a pilha

;Interrupt 10h, function 13U BIOS (AT only)
;Video: Write character string
;Displays a character string on the screen, starting at a specified screen position on
;a specified display page. The characters are taken from a buffer whose address
;passes to the function.
;Input: 	 
;AH= 13H
;AL = Output mode (0--3)
;0: Attribute in BL, retain cursor position
;1: Attribute in BL, update cursor position
;2: Attribute in the buffer, retain cursor position
;3: Attribute in the buffer, update cursor position
;BH = Display page number
;BL = Attribute byte of the character (modes 0 and 1 only)
;BP = Offset address of the buffer
;CX = Number of characters to be displayed
;DH = display line
;DL = display column
;ES = segment address of the buffer 

mov ah, 0x13
mov al, 0x01
xor bx, bx
mov bl, 0x0F
mov cx, 0x0f
mov dh, 0x01
mov dl, 0x0A
mov bh, 0x00
mov bl, 0x04
mov bp, mensagem ;move o offset da variavel
int 0x10

popa ;devolve todos os valores para os registradores
mov sp, bp
pop bp
ret

;------------------------------------------------------------------------
ChamarParte2:
;Interrupt 13h, function 02h BIOS
;Disk: Read disk
;Reads one or more disk sectors into a buffer.
;Input: 	 
;AH= 02H
;AL = Number of sectors to be read
;BX = Offset address ofbuffer
;CH = Track number
;CL = Sector number
;DH = Disk side number (0 or 1)
;DL = Disk drive number
;ES = Buffer segment address 

mov ah, 2
mov al, 15 ;Setores para ler
mov ch, 0
mov cl, 2 ;Carregando o setor 2 pois o primeiro já esta carregado
mov dh, 0 
mov dl, [drvnum]
mov bx, stage2
int 0x13
jmp stage2
	
drvnum db 0

;------------------------------------------------------------------------
;variaveis
mensagem db 'Me contrata! =D'

times 510 - ($ - $$) db 0x00
dw 0xAA55

;FIM DA PARTE 1
;------------------------------------------------------------------------





;INICIO DA PARTE 2
;------------------------------------------------------------------------
stage2:

call desenhar
final:
jmp $


desenhar:

;Interrupt 10H, function OCH BIOS
;Video: Write graphic pixel
;Draws a color pixel at the specified coordinates in graphic mode.
;Input: 	 AH= OCH
;AL = Pixel color value (see below)
;BH = Graphics page
;ex = Screen column
;dx = Screen line
push bp
mov bp, sp
pusha
xor ax, ax
mov ds, ax
mov si, ax

push 0x0f ; Cor do pixel (sp + 6)
push 0x00 ; contador horizontal (sp + 0x04)
push 0xc7 ; contador vertical (sp + 0x02)
push 0x00 ; repetições (sp)

mov di, sp 
mov bl, byte [0x7c00 + dados + di] ;Numero de repetições

inicio:
mov dx, [di + 0x02] ;Posição vertical

volta1:
xor bh, bh
mov cx, [di + 0x04]
mov al, [di + 0x06]
mov ah, 0x0c
int 0x10
dec bl ;decrementa a repeticao
mov [di], bl ;Salva as repetições que faltam

cmp bl, 0
je trocaCor
volta2:
xor ax, ax
mov ax, word [di + 0x04]
inc ax
cmp ax, 0x13f ; confere se chegamos ao fim da linha
je preparaRetorno
mov [di + 0x04], ax
jmp volta1 

preparaRetorno:
xor ax, ax
mov [di + 0x04], ax ; contador horizontal
mov ax, [di + 0x02] ;contador vertical
dec ax
mov [di + 0x02], ax
inc si
mov bl, byte [0x7c00 + dados + di]
cmp bl, 0xff
je final
jmp inicio

trocaCor:
mov al, [di + 0x06]
cmp al, 0x0f
je preto
mov al, 0x0f
jmp salva

preto:
mov al, 0x00


salva:
mov [di + 0x06], al
inc si
mov bl, byte [0x7c00 + dados + di] ;Numero de repetições
cmp bl, 0xff
je final
mov [di], bl
jmp volta2
popa
mov sp, bp
pop bp
ret



dados: db 1, 255, 0, 64, 1, 255, 0, 64, 1, 255, 0, 64, 1, 198, 6, 115, 1, 196, 12, 111    
    db 1, 190, 21, 108, 1, 180, 18, 121, 1, 176, 14, 129, 1, 173, 15, 131, 1, 170, 16, 133
    db 1, 168, 16, 135, 1, 165, 18, 136, 1, 162, 4, 1, 15, 137, 1, 159, 5, 4, 13, 34      
    db 1, 103, 1, 157, 4, 8, 11, 1, 1, 32, 5, 100, 1, 154, 5, 9, 12, 35, 2, 1
    db 4, 97, 1, 152, 3, 60, 4, 1, 1, 1, 1, 96, 1, 150, 2, 64, 3, 2, 1, 97
    db 1, 218, 2, 1, 1, 97, 1, 218, 3, 255, 0, 65, 2, 97, 1, 255, 0, 64, 5, 219
    db 2, 94, 7, 218, 1, 94, 9, 217, 1, 93, 12, 255, 0, 53, 14, 255, 0, 51, 16, 255  
    db 0, 49, 19, 255, 0, 46, 21, 255, 0, 44, 23, 255, 0, 42, 26, 255, 0, 39, 30, 255
    db 0, 35, 44, 255, 0, 21, 53, 255, 0, 9, 2, 1, 64, 242, 13, 1, 73, 221, 25, 1
    db 78, 206, 35, 1, 82, 192, 45, 1, 86, 180, 53, 1, 90, 170, 59, 1, 96, 161, 166, 85
    db 2, 1, 11, 1, 1, 7, 2, 43, 179, 73, 18, 3, 2, 3, 2, 39, 181, 74, 18, 46
    db 183, 72, 9, 6, 1, 2, 2, 44, 185, 134, 187, 131, 190, 128, 194, 124, 197, 108, 1, 12
    db 201, 106, 2, 8, 206, 104, 1, 2, 1, 3, 208, 109, 209, 49, 21, 38, 2, 3, 206, 51
    db 3, 1, 1, 5, 14, 13, 1, 16, 1, 3, 3, 1, 206, 72, 2, 31, 2, 1, 3, 1
    db 207, 107, 3, 1, 208, 104, 1, 1, 213, 55, 9, 38, 3, 1, 213, 48, 2, 4, 18, 5
    db 4, 1, 5, 14, 2, 1, 215, 30, 1, 19, 11, 9, 18, 2, 2, 6, 19, 1, 201, 26
    db 11, 12, 1, 6, 1, 16, 1, 2, 3, 1, 13, 1, 7, 1, 217, 23, 19, 2, 1, 1
    db 2, 28, 1, 1, 4, 2, 33, 1, 202, 21, 1, 1, 24, 31, 3, 2, 236, 23, 24, 34
    db 40, 1, 198, 23, 24, 34, 45, 1, 189, 3, 1, 18, 2, 1, 25, 32, 236, 3, 2, 16
    db 1, 1, 28, 35, 232, 4, 2, 14, 1, 3, 27, 39, 42, 1, 187, 4, 2, 13, 1, 2
    db 2, 1, 24, 43, 37, 2, 2, 1, 186, 3, 2, 17, 26, 44, 34, 3, 1, 3, 185, 1
    db 7, 9, 1, 1, 30, 5, 2, 38, 36, 6, 182, 3, 7, 1, 1, 4, 1, 1, 33, 6
    db 2, 13, 15, 5, 41, 2, 1, 1, 182, 3, 13, 2, 3, 2, 1, 1, 27, 6, 2, 1
    db 76, 2, 179, 1, 4, 2, 8, 1, 2, 1, 1, 1, 35, 6, 74, 1, 3, 2, 179, 6
    db 49, 8, 254, 8, 50, 2, 1, 6, 253, 8, 51, 9, 83, 1, 167, 8, 56, 6, 248, 1
    db 1, 8, 56, 2, 1, 4, 246, 2, 2, 7, 58, 1, 1, 4, 244, 4, 1, 6, 56, 1
    db 3, 5, 243, 5, 1, 6, 11, 1, 1, 24, 23, 6, 241, 13, 7, 36, 17, 6, 79, 2
    db 160, 13, 6, 46, 7, 7, 79, 4, 157, 14, 5, 61, 79, 4, 157, 13, 5, 62, 79, 4
    db 157, 5, 3, 5, 7, 59, 23, 32, 24, 5, 163, 7, 7, 58, 20, 38, 22, 4, 168, 3
    db 7, 58, 17, 1, 1, 43, 24, 1, 164, 3, 7, 59, 17, 46, 2, 4, 16, 3, 162, 4
    db 7, 60, 16, 55, 6, 1, 6, 4, 160, 4, 9, 61, 12, 57, 6, 1, 5, 5, 159, 5
    db 11, 59, 10, 58, 7, 1, 5, 6, 158, 5, 15, 56, 7, 34, 1, 2, 1, 21, 7, 2
    db 4, 7, 157, 6, 17, 52, 7, 60, 8, 3, 4, 6, 156, 8, 23, 1, 1, 43, 10, 56
    db 9, 1, 1, 3, 4, 3, 157, 9, 3, 1, 33, 27, 13, 54, 11, 1, 167, 15, 39, 1
    db 6, 1, 1, 1, 3, 3, 19, 3, 1, 51, 8, 1, 165, 20, 73, 1, 2, 49, 9, 1
    db 165, 21, 87, 35, 11, 2, 164, 23, 96, 20, 15, 2, 163, 26, 11, 1, 117, 2, 162, 29
    db 126, 3, 162, 30, 125, 4, 161, 31, 122, 7, 159, 34, 119, 7, 1, 2, 157, 37, 115, 9
    db 1, 2, 156, 37, 1, 1, 111, 12, 1, 2, 155, 41, 3, 1, 104, 17, 154, 46, 102, 19
    db 152, 48, 101, 19, 152, 46, 102, 20, 151, 50, 98, 21, 152, 56, 77, 4, 2, 2, 3, 25
    db 151, 60, 70, 6, 2, 32, 150, 61, 67, 5, 1, 2, 1, 33, 150, 68, 59, 44, 149, 74
    db 49, 49, 148, 79, 42, 52, 147, 85, 31, 1, 2, 53, 149, 86, 11, 4, 6, 4, 4, 57
    db 148, 90, 4, 79, 148, 172, 150, 170, 150, 170, 150, 171, 149, 169, 152, 166, 155, 163, 158, 160
    db 161, 157, 164, 155, 166, 154, 168, 151, 171, 148, 175, 143, 181, 136, 187, 132, 191, 127, 195, 121
    db 203, 101, 1, 6, 1, 6, 209, 95, 3, 1, 1, 3, 2, 4, 215, 88, 6, 2, 1, 1
    db 1, 4, 222, 80, 9, 4, 2, 1, 235, 1, 2, 23, 20, 7, 1, 11, 255, 0, 176, 255
