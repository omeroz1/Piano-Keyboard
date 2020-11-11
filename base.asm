IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
Clock equ es:6Ch
x dw 10
y dw 52
color db 15

note1 dw 9121  ; DO ☆
note2 dw 8609  ; DO diaz ♕
note3 dw 8126  ; RE ☆
note4 dw 7670  ; RE diaz ♕
note5 dw 7240  ; MI ☆
note6 dw 6833  ; FA ☆
note7 dw 6450  ; Fa diaz ♕
note8 dw 6088  ; SOL ☆
note9 dw 5746  ; Sol diaz ♕
note10 dw 5424 ; LA ☆
note11 dw 5119 ; La diaz ♕
note12 dw 4832 ; SI ☆

note13 dw 4561 ; DO ☆
note14 dw 4305 ; DO diaz ♕
note15 dw 4063 ; RE ☆
note16 dw 3835 ; RE diaz ♕
note17 dw 3620 ; MI ☆
note18 dw 3417 ; FA ☆
note19 dw 3225 ; Fa diaz ♕
note20 dw 3044 ; SOL ☆
note21 dw 2873 ; Sol diaz ♕
note22 dw 2712 ; LA ☆
note23 dw 2560 ; La diaz ♕
note24 dw 2416 ; SI ☆

note25 dw 2280 ; DO ☆
note26 dw 2152 ; DO diaz ♕
note27 dw 2032 ; RE ☆
note28 dw 1918 ; RE diaz ♕
note29 dw 1810 ; MI ☆
note30 dw 1708 ; FA ☆
note31 dw 1612 ; Fa diaz ♕
note32 dw 1522 ; SOL ☆
note33 dw 1437 ; Sol diaz ♕
note34 dw 1356 ; LA ☆
note35 dw 1280 ; La diaz ♕
note36 dw 1208 ; SI ☆

filehandle dw ?
Header db 54 dup (0)
Palette db 256*4 dup (0)
ScrLine db 320 dup (0)
ErrorMsg db 'Error', 13, 10,'$'

homepage db 'piano2.bmp', 0

key db 0

note dw 0
DO dw 04742h ;DO C2
RE dw 03F7Bh ;RE C2
MI dw 0388Fh ;MI C2
FA dw 03562h ;FA C2
SOL dw 02F8Fh ;SOL C2
LA dw 02A5Fh ;LA C2
SI1 dw 025C0h ;SI C2

jon db '5','3','3','0','4','2','2','0','1','2','3','4','5','5','5','0','5','3','3','0','4','2','2','0','1','3','5','5','1'
; --------------------------
CODESEG
proc OpenFile
    ; Open file
    mov ah, 3Dh
    xor al, al
    int 21h
    jc openerror
    mov [filehandle], ax
    ret

    openerror:
    mov dx, offset ErrorMsg
    mov ah, 9h
    int 21h
    ret
endp OpenFile
proc ReadHeader

    ; Read BMP file header, 54 bytes

    mov ah,3fh
    mov bx, [filehandle]
    mov cx,54
    mov dx,offset Header
    int 21h
    ret
    endp ReadHeader
    proc ReadPalette

    ; Read BMP file color palette, 256 colors * 4 bytes (400h)

    mov ah,3fh
    mov cx,400h
    mov dx,offset Palette
    int 21h
    ret
endp ReadPalette
proc CopyPal

    ; Copy the colors palette to the video memory
    ; The number of the first color should be sent to port 3C8h
    ; The palette is sent to port 3C9h

    mov si,offset Palette
    mov cx,256
    mov dx,3C8h
    mov al,0

    ; Copy starting color to port 3C8h

    out dx,al

    ; Copy palette itself to port 3C9h

    inc dx
    PalLoop:

    ; Note: Colors in a BMP file are saved as BGR values rather than RGB.

    mov al,[si+2] ; Get red value.
    shr al,2 ; Max. is 255, but video palette maximal

    ; value is 63. Therefore dividing by 4.

    out dx,al ; Send it.
    mov al,[si+1] ; Get green value.
    shr al,2
    out dx,al ; Send it.
    mov al,[si] ; Get blue value.
    shr al,2
    out dx,al ; Send it.
    add si,4 ; Point to next color.

    ; (There is a null chr. after every color.)

    loop PalLoop
    ret
endp CopyPal

proc CopyBitmap

    ; BMP graphics are saved upside-down.
    ; Read the graphic line by line (200 lines in VGA format),
    ; displaying the lines from bottom to top.

    mov ax, 0A000h
    mov es, ax
    mov cx,200
    PrintBMPLoop:
    push cx

    ; di = cx*320, point to the correct screen line

    mov di,cx
    shl cx,6
    shl di,8
    add di,cx

    ; Read one line

    mov ah,3fh
    mov cx,320
    mov dx,offset ScrLine
    int 21h

    ; Copy one line into video memory

    cld 

    ; Clear direction flag, for movsb

    mov cx,320
    mov si,offset ScrLine
    rep movsb 

    ; Copy line to the screen
    ;rep movsb is same as the following code:
    ;mov es:di, ds:si
    ;inc si
    ;inc di
    ;dec cx
    ;loop until cx=0

    pop cx
    loop PrintBMPLoop
    ret
endp CopyBitmap

proc CloseFile
; Close file
	mov ah,3Eh
	mov bx, [filehandle]
	int 21h
ret
endp CloseFile

proc sound ;sound toggle procedure 1
	mov bp, sp
	in al, 61h
	or al, 00000011b
	out 61h, al 	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	mov ax, [note]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	call Timer
	call soundclose
	call Timer1
	ret
endp sound
proc Timer ;TIMER WITH 2 TICKS
	mov ax,40h ;enable Timer
	mov es,ax
	mov ax, [clock]
	FirstTick:
	cmp ax, [clock]
	mov cx, 5 ;ticks
	je FirstTick
	DelayLoop:
	mov ax, [clock]
	Tick:
	cmp ax, [clock]
	je Tick
	loop DelayLoop

ret
endp Timer

proc Timer1 ;TIMER WITH 2 TICKS
	mov ax,40h ;enable Timer
	mov es,ax
	mov ax, [clock]
	FirstTick1:
	cmp ax, [clock]
	mov cx, 1 ;ticks
	je FirstTick1
	DelayLoop1:
	mov ax, [clock]
	Tick1:
	cmp ax, [clock]
	je Tick1
	loop DelayLoop1
ret
endp Timer1

proc procdo 	
	mov ax, [DO]         
	mov [note],ax    
	call sound  	
ret                     	
endp procdo

proc procre 	
	mov ax, [RE]        
	mov [note],ax      
	call sound  	
ret                     	
endp procre

proc procmi 		
	mov ax, [MI]         
	mov [note],ax           
	call sound 
ret                     
endp procmi

proc procfa 	
	mov ax, [FA]         
	mov [note],ax           
	call sound
ret                     	
endp procfa

proc procsol 
	mov ax, [SOL]         
	mov [note],ax           
	call sound
ret                     	
endp procsol

proc procla 	
	mov ax, [LA]         
	mov [note],ax           
	call sound
ret                     	
endp procla

proc procsi 
	mov ax, [SI1]         
	mov [note],ax           
	call sound 
ret                     	
endp procsi

proc procsil 	
	call soundclose	  		
	call Timer
	call soundclose
	call Timer1 			
ret                     	
endp procsil

proc soundclose ;soundclose
	in al, 61h                 
	and al, 11111100b      
	out 61h, al
	ret
endp soundclose
; פרוצדורה שמדפיסה שורה
proc line ;x++
mov dx, [x]
mov cx, [y]
mov di, 8
PrintLoop2:
mov bh, 0h
mov al, [color]
mov ah,0ch
int 10h
add cx, 1
dec di
cmp di, 0
JNE PrintLoop2
ret
endp line

;פרוצדורה שמדפיסה טור
proc column ;y++
mov dx, [x]
mov cx, [y]
mov di, 53 ;the tile lenght
PrintLoop:
mov bh, 0h
mov al, [color]
mov ah,0ch
int 10h
add dx, 1
dec di
cmp di, 0
JNE PrintLoop
ret
endp column

;print black column
proc BlackColumn ;y++
mov dx, [x]
mov cx, [y]
mov di, 38 ;the tile lenght
PrintLoop1:
mov bh, 0h
mov al, [color]
mov ah,0ch
int 10h
add dx, 1
dec di
cmp di, 0
JNE PrintLoop1
ret
endp BlackColumn

proc GreySColumn ;y++
	mov dx, [x]
	mov cx, [y]
	mov di, 15 ;the tile lenght
	PrintLoop3:
	mov bh, 0h
	mov al, [color]
	mov ah,0ch
	int 10h
	add dx, 1
	dec di
	cmp di, 0
	JNE PrintLoop3
ret
endp GreySColumn


proc Pone
push si
mov [key], al
add [key], 80h
One:
	mov [x], 10 ;the cordinate of 1' tile
	mov [y], 52 ;the cordinate of 1' tile
	call Gone
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note1]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz One
	in al, 60h
	cmp [key], al
	jne skip1
	mov [x], 10 ;the cordinate of 1' tile
	mov [y], 52 ;the cordinate of 1' tile
	call Wone
	skip1:
		jmp One
pop si
ret
endp Pone

proc Gone
push si
	push [x]
	push [y]
	call Grey1
	pop [y]
	pop [x]
	add [x], 38 ;the cordinate of 1' tile
	add [y], 23 ;the cordinate of 1' tile
	call GreySC
pop si

ret
endp Gone

proc Wone
push si
	push [x]
	push [y]
	
	jmp EndMusic1
pop si
ret
endp Wone

proc Ptwo
push si
mov [key], al
add [key], 80h
Two:
	mov [x], 10 ;the cordinate of 2' tile
	mov [y], 73 ;the cordinate of 2' tile
	call Gtwo
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note2]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz Two
	in al, 60h
	cmp [key], al
		jne skip2
	mov [x], 10 ;the cordinate of 2' tile
	mov [y], 73 ;the cordinate of 2' tile
	call Wtwo
	skip2:
		jmp Two
pop si
ret
endp Ptwo

proc Gtwo
push si
	call Grey2
pop si
ret
endp Gtwo

proc Wtwo
push si
	jmp EndMusic2
pop si
ret
endp Wtwo

proc Pthree
push si
mov [key], al
add [key], 80h
Three:
	mov [x], 48 ;the cordinate of 3' tile
	mov [y], 85 ;the cordinate of 3' tile
	call Gthree
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note3]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz Three
	in al, 60h
	cmp [key], al
	jne skip3
	mov [x], 48 ;the cordinate of 3' tile
	mov [y], 85 ;the cordinate of 3' tile
	call Wthree
	skip3:
		jmp Three
pop si
ret
endp Pthree

proc Gthree
push si
	push [x]
	push [y]
	call GreySC3
	
	pop [y]
	pop [x]
	push [x]
	push [y]
	sub [x], 38 ;the cordinate of 1' tile
	add [y], 9 ;the cordinate of 1' tile
	call Grey3
	
	pop [y]
	pop [x]
	add [y], 20
	call GreySC3
pop si
ret
endp Gthree

proc Wthree
push si
	jmp EndMusic3
pop si
ret
endp Wthree

proc Pfour
push si
mov [key], al
add [key], 80h
Four:
	mov [x], 10 ;the cordinate of 2' tile
	mov [y], 106 ;the cordinate of 2' tile
	call Gfour
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note4]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz Four
	in al, 60h
	cmp [key], al
	jne skip4
	mov [x], 10 ;the cordinate of 2' tile
	mov [y], 106 ;the cordinate of 2' tile
	call Wfour
	skip4:
		jmp Four
pop si
ret
endp Pfour

proc Gfour
push si
	call Grey2
pop si
ret
endp Gfour

proc Wfour
push si
	jmp EndMusic2
pop si
ret
endp Wfour

proc Pfive
push si
mov [key], al
add [key], 80h
Five:
	mov [x], 48 ;the start cordinate of 5' tile
	mov [y], 117 ;the start cordinate of 5' tile
	call Gfive
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note5]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz Five
	in al, 60h
	cmp [key], al
	jne skip5
	mov [x], 48 ;the cordinate of 1' tile
	mov [y], 117 ;the cordinate of 1' tile
	call Wfive
	skip5:
		jmp Five
pop si
ret
endp Pfive

proc Gfive
push si
	push [x]
	push [y]
	call GreySC3
	
	pop [y]
	pop [x]
	sub [x], 38 ;the cordinate of 1' tile
	add [y], 9 ;the cordinate of 1' tile
	call Grey4
pop si
ret
endp Gfive

proc Wfive
push si
	jmp EndMusic4
pop si
ret
endp Wfive

proc Psix
push si
mov [key], al
add [key], 80h
Six:
	mov [x], 10 ;the cordinate of 6' tile
	mov [y], 149 ;the cordinate of 6' tile
	call Gsix
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note6]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz Six
	in al, 60h
	cmp [key], al
	jne skip6
	mov [x], 10 ;the cordinate of 1' tile
	mov [y], 149 ;the cordinate of 1' tile	
	call Wsix
	skip6:
		jmp Six
pop si
ret
endp Psix

proc Gsix
push si
	push [x]
	push [y]
	call Grey6
	
	pop [y]
	pop [x]
	add [x], 38 ;the cordinate of 1' tile
	add [y], 20 ;the cordinate of 1' tile
	call GreySC3
pop si
ret
endp Gsix

proc Wsix
push si
	jmp EndMusic6
pop si
ret
endp Wsix

proc Pseven
push si
mov [key], al
add [key], 80h
Seven:
	mov [x], 10 ;the cordinate of 7' tile
	mov [y], 168 ;the cordinate of 7' tile
	call Gseven
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note7]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz Seven
	in al, 60h
	cmp [key], al
	jne skip7
	mov [x], 10 ;the cordinate of 7' tile
	mov [y], 168 ;the cordinate of 7' tile
	call Wseven
	skip7:
		jmp Seven
pop si
ret
endp Pseven

proc Gseven
push si
	call Grey2
pop si
ret
endp Gseven

proc Wseven
push si
	jmp EndMusic2
pop si
ret
endp Wseven

proc Peight
push si
mov [key], al
add [key], 80h
Eight:
	mov [x], 48 ;the cordinate of 8' tile
	mov [y], 181 ;the cordinate of 8' tile
	call Geight
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note8]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz Eight
	in al, 60h
	cmp [key], al
	jne skip8
	mov [x], 48 ;the cordinate of 8' tile
	mov [y], 181 ;the cordinate of 8' tile
	call Weight
	skip8:
		jmp Eight
pop si
ret
endp Peight

proc Geight
push si
	push [x]
	push [y]
	call GreySC3
	
	pop [y]
	pop [x]
	push [x]
	push [y]
	sub [x], 38 ;the cordinate of 1' tile
	add [y], 7 ;the cordinate of 1' tile
	call Grey8
	
	pop [y]
	pop [x]
	add [y], 20
	call GreySC3
pop si
ret
endp Geight

proc Weight
push si
	jmp EndMusic8
pop si
ret
endp Weight

proc Pnine
push si
mov [key], al
add [key], 80h
Nine:
	mov [x], 10 ;the cordinate of 9' tile
	mov [y], 200 ;the cordinate of 9' tile
	call Gnine
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note9]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz Nine
	in al, 60h
	cmp [key], al
	jne skip9
	mov [x], 10 ;the cordinate of 9' tile
	mov [y], 200 ;the cordinate of 9' tile
	call Wnine
	skip9:
		jmp Nine
pop si
ret
endp Pnine

proc Gnine
push si
	call Grey2
pop si
ret
endp Gnine

proc Wnine
push si
	jmp EndMusic2
pop si
ret
endp Wnine

proc Pzero
push si
mov [key], al
add [key], 80h
Zero:
	mov [x], 48 ;the cordinate of 0' tile
	mov [y], 213 ;the cordinate of 0' tile
	call Gzero
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note10]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz Zero
	in al, 60h
	cmp [key], al
	jne skip10
	mov [x], 48 ;the cordinate of 0' tile
	mov [y], 213 ;the cordinate of 0' tile
	call Wzero
	skip10:
		jmp Zero
pop si
ret
endp Pzero

proc Gzero
push si
	push [x]
	push [y]
	call GreySC3
	
	pop [y]
	pop [x]
	push [x]
	push [y]
	sub [x], 38 ;the cordinate of 1' tile
	add [y], 7 ;the cordinate of 1' tile
	call Grey8
	
	pop [y]
	pop [x]
	add [y], 20
	call GreySC3
pop si
ret
endp Gzero

proc Wzero
push si
	jmp EndMusic8
pop si
ret
endp Wzero

proc PMinus
push si
mov [key], al
add [key], 80h
Minus:
	mov [x], 10 ;the cordinate of minus' tile
	mov [y], 232 ;the cordinate of minus' tile
	call Gminus
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note11]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz Minus
	in al, 60h
	cmp [key], al
	jne skip11
	mov [x], 10 ;the cordinate of minus' tile
	mov [y], 232 ;the cordinate of minus' tile
	call Wminus
	skip11:
		jmp Minus
pop si
ret
endp PMinus

proc Gminus
push si
	call Grey2
pop si
ret
endp Gminus

proc Wminus
push si
	jmp EndMusic2
pop si
ret
endp Wminus

proc PPlus
push si
mov [key], al
add [key], 80h
Plus:
	mov [x], 48 ;the start cordinate of plus' tile
	mov [y], 245 ;the start cordinate of plus' tile
	call Gplus
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note12]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz Plus
	in al, 60h
	cmp [key], al
	jne skip12
	mov [x], 48 ;the cordinate of plus' tile
	mov [y], 245 ;the cordinate of plus' tile	
	call Wplus
	skip12:
		jmp Plus
pop si
ret
endp PPlus

proc Gplus
push si
	push [x]
	push [y]
	call GreySC3
	
	pop [y]
	pop [x]
	sub [x], 38 ;the cordinate of 1' tile
	add [y], 8 ;the cordinate of 1' tile
	call Grey12
pop si
ret
endp Gplus

proc Wplus
push si
	jmp EndMusic12
pop si
ret
endp Wplus

;----------------------------------- FIRST OCTAVE
;----------------------------------- FIRST OCTAVE
;----------------------------------- FIRST OCTAVE

proc PQ
push si
mov [key], al
add [key], 80h
Q:
	mov [x], 73 ;the cordinate of q' tile
	mov [y], 52 ;the cordinate of q' tile
	call Gone
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note13]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz Q
	in al, 60h
	cmp [key], al
	jne skip13
	mov [x], 73 ;the cordinate of q' tile
	mov [y], 52 ;the cordinate of q' tile
	call Wone
	jmp EndMusic1
	skip13:
		jmp Q
pop si
ret
endp PQ

proc PW
push si
mov [key], al
add [key], 80h
W:
	mov [x], 73 ;the cordinate of w' tile
	mov [y], 73 ;the cordinate of w' tile
	call Gtwo
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note14]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz W
	in al, 60h
	cmp [key], al
	jne skip14
	mov [x], 73 ;the cordinate of w' tile
	mov [y], 73 ;the cordinate of w' tile
	call Wtwo
	jmp EndMusic2
	skip14:
		jmp W
pop si
ret
endp PW

proc PE
push si
mov [key], al
add [key], 80h
E:
	mov [x], 111 ;the cordinate of e' tile
	mov [y], 85 ;the cordinate of e' tile
	call Gthree

	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note15]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz E
	in al, 60h
	cmp [key], al
	jne skip15
	mov [x], 111 ;the cordinate of e' tile
	mov [y], 85 ;the cordinate of e' tile
	call Wthree
	jmp EndMusic3
	skip15:
		jmp E
pop si
ret
endp PE

proc PR
push si
mov [key], al
add [key], 80h
R:
	mov [x], 73 ;the cordinate of r' tile
	mov [y], 106 ;the cordinate of r' tile
	call Gfour
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note16]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz R
	in al, 60h
	cmp [key], al
	jne skip16
	mov [x], 73 ;the cordinate of r' tile
	mov [y], 106 ;the cordinate of r' tile
	call Wfour
	jmp EndMusic2
	skip16:
		jmp R
pop si
ret
endp PR

proc PT
push si
mov [key], al
add [key], 80h
T:
	mov [x], 111 ;the start cordinate of t' tile
	mov [y], 117 ;the start cordinate of t' tile
	call Gfive
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note17]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz T
	in al, 60h
	cmp [key], al
	jne skip17
	mov [x], 111 ;the start cordinate of t' tile
	mov [y], 117 ;the start cordinate of t' tile
	call Wfive
	jmp EndMusic4
	skip17:
		jmp T
pop si
ret
endp PT

proc PY
push si
mov [key], al
add [key], 80h
YY:
	mov [x], 73 ;the cordinate of y' tile
	mov [y], 149 ;the cordinate of y' tile
	call Gsix
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note18]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz YY
	in al, 60h
	cmp [key], al
	jne skip18
	mov [x], 73 ;the cordinate of y' tile
	mov [y], 149 ;the cordinate of y' tile
	call wsix
	jmp EndMusic6
	skip18:
		jmp YY
pop si
ret
endp PY

proc PU
push si
mov [key], al
add [key], 80h
U:
	mov [x], 73 ;the cordinate of u' tile
	mov [y], 168 ;the cordinate of u' tile
	call Gseven
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note19]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz U
	in al, 60h
	cmp [key], al
	jne skip19
	mov [x], 73 ;the cordinate of u' tile
	mov [y], 168 ;the cordinate of u' tile
	call Wseven
	jmp EndMusic2
	skip19:
		jmp U
pop si
ret
endp PU

proc PI
push si
mov [key], al
add [key], 80h
I:
	mov [x], 111 ;the cordinate of i' tile
	mov [y], 181 ;the cordinate of i' tile
	call Geight

	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note20]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz I
	in al, 60h
	cmp [key], al
	jne skip20
	mov [x], 111 ;the cordinate of i' tile
	mov [y], 181 ;the cordinate of i' tile
	call Weight
	jmp EndMusic8
	skip20:
		jmp I
pop si
ret
endp PI

proc PO
push si
mov [key], al
add [key], 80h
O:
	mov [x], 73 ;the cordinate of o' tile
	mov [y], 200 ;the cordinate of o' tile
	call Gnine
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note21]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz O
	in al, 60h
	cmp [key], al
	jne skip21
	mov [x], 73 ;the cordinate of o' tile
	mov [y], 200 ;the cordinate of o' tile
	call Wnine
	jmp EndMusic2
	skip21:
		jmp O
pop si
ret
endp PO

proc PP
push si
mov [key], al
add [key], 80h
P:
	mov [x], 111 ;the cordinate of p' tile
	mov [y], 213 ;the cordinate of p' tile
	call Gzero

	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note22]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz P
	in al, 60h
	cmp [key], al
	jne skip22
	mov [x], 111 ;the cordinate of p' tile
	mov [y], 213 ;the cordinate of p' tile
	call Wzero
	jmp EndMusic8
	skip22:
		jmp P
pop si
ret
endp PP

proc PLM
push si
mov [key], al
add [key], 80h
LM:
	mov [x], 73 ;the cordinate of lm' tile
	mov [y], 232 ;the cordinate of lm' tile
	call Gminus
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note23]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz LM
	in al, 60h
	cmp [key], al
	jne skip23
	mov [x], 73 ;the cordinate of lm' tile
	mov [y], 232 ;the cordinate of lm' tile
	call Wminus
	jmp EndMusic2
	skip23:
		jmp LM
pop si
ret
endp PLM

proc PRM
push si
mov [key], al
add [key], 80h
RM:
	mov [x], 111 ;the start cordinate of rm' tile
	mov [y], 245 ;the start cordinate of rm' tile
	call Gplus
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note24]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz RM
	in al, 60h
	cmp [key], al
	jne skip24
	mov [x], 111 ;the start cordinate of rm' tile
	mov [y], 245 ;the start cordinate of rm' tile
	call Wplus
	jmp EndMusic12
	skip24:
		jmp RM
pop si
ret
endp PRM

;----------------------------------- SECOND OCTAVE
;----------------------------------- SECOND OCTAVE
;----------------------------------- SECOND OCTAVE

proc PA
push si
mov [key], al
add [key], 80h
A:
	mov [x], 136 ;the cordinate of a' tile
	mov [y], 52 ;the cordinate of a' tile
	call Gone
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note25]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz A
	in al, 60h
	cmp [key], al
	jne skip25
	mov [x], 136 ;the cordinate of a' tile
	mov [y], 52 ;the cordinate of a' tile
	call Wone
	jmp EndMusic1
	skip25:
		jmp A
pop si
ret
endp PA

proc PS
push si
mov [key], al
add [key], 80h
S:
	mov [x], 136 ;the cordinate of s' tile
	mov [y], 73 ;the cordinate of s' tile
	call Gtwo
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note26]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz S
	in al, 60h
	cmp [key], al
	jne skip26
	mov [x], 136 ;the cordinate of s' tile
	mov [y], 73 ;the cordinate of s' tile
	call Wtwo
	jmp EndMusic2
	skip26:
		jmp S
pop si
ret
endp PS

proc PD
push si
mov [key], al
add [key], 80h
D:
	mov [x], 174 ;the cordinate of d' tile
	mov [y], 85 ;the cordinate of d' tile
	call Gthree
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note27]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz D
	in al, 60h
	cmp [key], al
	jne skip27
	mov [x], 174 ;the cordinate of d' tile
	mov [y], 85 ;the cordinate of d' tile
	call Wthree
	jmp EndMusic3
	skip27:
		jmp D
pop si
ret
endp PD

proc PF
push si
mov [key], al
add [key], 80h
F:
	mov [x], 136 ;the cordinate of f' tile
	mov [y], 106 ;the cordinate of f' tile
	call Gfour
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note28]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz F
	in al, 60h
	cmp [key], al
	jne skip28
	mov [x], 136 ;the cordinate of f' tile
	mov [y], 106 ;the cordinate of f' tile
	call Wfour
	jmp EndMusic2
	skip28:
		jmp F
pop si
ret
endp PF

proc PG
push si
mov [key], al
add [key], 80h
G:
	mov [x], 174 ;the start cordinate of g' tile
	mov [y], 117 ;the start cordinate of g' tile
	call Gfive
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note29]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz G
	in al, 60h
	cmp [key], al
	jne skip29

	mov [x], 174 ;the start cordinate of g' tile
	mov [y], 117 ;the start cordinate of g' tile
	call Wfive
	jmp EndMusic4
	skip29:
		jmp G
pop si
ret
endp PG

proc PH
push si
mov [key], al
add [key], 80h
H:
	mov [x], 136 ;the cordinate of h' tile
	mov [y], 149 ;the cordinate of h' tile
	call Gsix
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note30]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz H
	
	in al, 60h
	cmp [key], al
	jne skip30
	
	mov [x], 136 ;the cordinate of h' tile
	mov [y], 149 ;the cordinate of h' tile
	call Wsix
	jmp EndMusic6
	skip30:
		jmp H
pop si
ret
endp PH

proc PJ
push si
mov [key], al
add [key], 80h
J:
	mov [x], 136 ;the cordinate of j' tile
	mov [y], 168 ;the cordinate of j' tile
	call Gseven
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note31]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz J
	in al, 60h
	cmp [key], al
	jne skip31
	mov [x], 136 ;the cordinate of j' tile
	mov [y], 168 ;the cordinate of j' tile
	call Wseven
	jmp EndMusic2
	skiP31:
		jmp J
pop si
ret
endp PJ

proc PK
push si
mov [key], al
add [key], 80h
K:
	mov [x], 174 ;the cordinate of k' tile
	mov [y], 181 ;the cordinate of k' tile
	call Geight
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note32]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz K
	in al, 60h
	cmp [key], al
	jne skip32
	mov [x], 174 ;the cordinate of k' tile
	mov [y], 181 ;the cordinate of k' tile
	call Weight
	jmp EndMusic8
	skip32:
		jmp K
pop si
ret
endp PK

proc PL
push si
mov [key], al
add [key], 80h
L:
	mov [x], 136 ;the cordinate of l' tile
	mov [y], 200 ;the cordinate of l' tile
	call Gnine
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note33]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz L
	in al, 60h
	cmp [key], al
	jne skip33
	mov [x], 136 ;the cordinate of l' tile
	mov [y], 200 ;the cordinate of l' tile
	call Wnine
	jmp EndMusic2
	skip33:
		jmp L
pop si
ret
endp PL

proc PLD
push si
mov [key], al
add [key], 80h
LD:
	mov [x], 174 ;the cordinate of ld' tile
	mov [y], 213 ;the cordinate of ld' tile
	call Gzero

	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note34]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz LD
	in al, 60h
	cmp [key], al
	jne skip34
	mov [x], 174 ;the cordinate of ld' tile
	mov [y], 213 ;the cordinate of ld' tile
	call Wzero
	jmp EndMusic8
	skip34:
		jmp LD
pop si
ret
endp PLD

proc PMD
push si
mov [key], al
add [key], 80h
MD:
	mov [x], 136 ;the cordinate of md' tile
	mov [y], 232 ;the cordinate of md' tile
	call Gminus
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note35]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz MD
	in al, 60h
	cmp [key], al
	jne skip35
	mov [x], 136 ;the cordinate of md' tile
	mov [y], 232 ;the cordinate of md' tile
	call Wminus
	jmp EndMusic2
	skip35:
		jmp MD
pop si
ret
endp PMD

proc PRD
push si
mov [key], al
add [key], 80h
RD:
	mov [x], 174 ;the start cordinate of rd' tile
	mov [y], 245 ;the start cordinate of rd' tile
	call Gplus
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	mov ax, [note36]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ah, 1
	int 16h
	jz RD
	in al, 60h
	cmp [key], al
	jne skip36
	mov [x], 174 ;the start cordinate of rd' tile
	mov [y], 245 ;the start cordinate of rd' tile
	call Wplus
	jmp EndMusic12
	skip36:
		jmp RD
pop si
ret
endp PRD



proc Grey1
	mov [color], 8 ;grey
	mov si, 23 ; the lenght of the piano tile (white)
		GreyT1:
			call column
			inc [y]
			dec si
			cmp si, 0
			jne GreyT1
ret
endp Grey1

proc GreySC
	mov [color], 8 ;grey
	mov si, 8 ; the lenght we need to paint
		GreyTSC:
			call GreySColumn
			inc [y]
			dec si
			cmp si, 0
			jne GreyTSC
ret
endp GreySC

proc GreySC3
	mov [color], 8 ;grey
	mov si, 10 ; the lenght we need to paint
		GreyTSC3:
			call GreySColumn
			inc [y]
			dec si
			cmp si, 0
			jne GreyTSC3
ret
endp GreySC3

proc Grey2
	mov [color], 8 ;grey
	mov si, 21 ; the lenght we need to paint
		GreyT2:
			call BlackColumn
			inc [y]
			dec si
			cmp si, 0
			jne GreyT2
ret
endp Grey2

proc Grey3
	mov [color], 8 ;grey
	mov si, 12 ; the lenght we need to paint
		GreyT3:
			call column
			inc [y]
			dec si
			cmp si, 0
			jne GreyT3
ret
endp Grey3

proc Grey4
	mov [color], 8 ;grey
	mov si, 21 ; the lenght of the piano tile (white)
		GreyT4:
			call column
			inc [y]
			dec si
			cmp si, 0
			jne GreyT4
ret
endp Grey4

proc Grey6
	mov [color], 8 ;grey
	mov si, 20 ; the lenght of the piano tile (white)
		GreyT6:
			call column
			inc [y]
			dec si
			cmp si, 0
			jne GreyT6
ret
endp Grey6

proc Grey8
	mov [color], 8 ;grey
	mov si, 14 ; the lenght we need to paint
		GreyT8:
			call column
			inc [y]
			dec si
			cmp si, 0
			jne GreyT8
ret
endp Grey8

proc Grey12
	mov [color], 8 ;grey
	mov si, 22 ; the lenght of the piano tile (white)
		GreyT12:
			call column
			inc [y]
			dec si
			cmp si, 0
			jne GreyT12
ret
endp Grey12

proc White1
	mov [color], 15 ;grey
	mov si, 23 ; the lenght of the piano tile (white)
		WhiteT1:
			call column
			inc [y]
			dec si
			cmp si, 0
			jne WhiteT1
ret
endp White1

proc WhiteSC
	mov [color], 15 ;grey
	mov si, 8 ; the lenght of the piano tile (white)
		WhiteTSC:
			call GreySColumn
			inc [y]
			dec si
			cmp si, 0
			jne WhiteTSC
ret
endp WhiteSC

proc WhiteSC3
	mov [color], 15 ;grey
	mov si, 10 ; the lenght of the piano tile (white)
		WhiteTSC3:
			call GreySColumn
			inc [y]
			dec si
			cmp si, 0
			jne WhiteTSC3
ret
endp WhiteSC3

proc White3
	mov [color], 15 ;grey
	mov si, 12 ; the lenght we need to paint
		WhiteT3:
			call column
			inc [y]
			dec si
			cmp si, 0
			jne WhiteT3
ret
endp White3

proc White4
	mov [color], 15 ;grey
	mov si, 21 ; the lenght of the piano tile (white)
		WhiteT4:
			call column
			inc [y]
			dec si
			cmp si, 0
			jne WhiteT4
ret
endp White4

proc White6
	mov [color], 15 ;grey
	mov si, 20 ; the lenght of the piano tile (white)
		WhiteT6:
			call column
			inc [y]
			dec si
			cmp si, 0
			jne WhiteT6
ret
endp White6

proc White8
	mov [color], 15 ;grey
	mov si, 14 ; the lenght we need to paint
		WhiteT8:
			call column
			inc [y]
			dec si
			cmp si, 0
			jne WhiteT8
ret
endp White8

proc White12
	mov [color], 15 ;grey
	mov si, 22 ; the lenght we need to paint
		WhiteT12:
			call column
			inc [y]
			dec si
			cmp si, 0
			jne WhiteT12
ret
endp White12

proc Black2
	mov [color], 0 ;black
	mov si, 21 ; the lenght of the piano tile (white)
		BlackT2:
			call BlackColumn
			inc [y]
			dec si
			cmp si, 0
			jne BlackT2
ret
endp Black2

proc song ;Jonathan the little one array
push si
xor si,si
mov bx, offset jon
jonbeginning:
	cmp [byte ptr bx +si], '1'
	jne jon2
	call procdo
	inc si
	loop jonbeginning
jon2:
	cmp [byte ptr bx +si], '2'
	jne jon3
	call procre
	inc si
	loop jonbeginning
jon3:
	cmp [byte ptr bx +si], '3'
	jne jon4
	call procmi
	inc si
	loop jonbeginning
jon4:
	cmp [byte ptr bx +si], '4'
	jne jon5
	call procfa
	inc si
	loop jonbeginning
jon5:
	cmp [byte ptr bx +si], '5'
	jne jon6
	call procsol
	inc si
	loop jonbeginning
jon6:
	cmp [byte ptr bx +si], '6'
	jne jon7
	call procla
	inc si
	loop jonbeginning
jon7:
	cmp [byte ptr bx +si], '7'
	jne jon0
	call procsi
	inc si
	loop jonbeginning
jon0:
	cmp [byte ptr bx +si], '0'
	jne jonend
	call procsil
	inc si
	loop jonbeginning
jonend:
pop si
ret 
endp song

;-------------------------------------------------------
start:
mov ax, @data
mov ds, ax

mov ax, 13h
int 10h

    ; Process BMP file
	mov dx, offset homepage
    call OpenFile
    call ReadHeader
    call ReadPalette
    call CopyPal
    call CopyBitmap
	call CloseFile

  WaitForKey4:
mov ah, 1
Int 16h
jz WaitForKey4
in al, 60h
cmp al, 1
jne sskip1
call piano
sskip1:

proc piano
	push si
	push bp
	push sp
	mov ax, 13h
	int 10h
	mov bp, 3; the number of octave in the layout
	Layout:
		mov [y], 52 ;make sure its in the same line
		mov sp, 7; the number of tiles in one octave
		Octave:
			mov [color], 6 ;the outline color (brown)
			call column
			inc [y]
			mov si, 30 ; the lenght of the piano tile (white)
			WhiteTile:
				mov [color], 15 ;the inside color (white)
				call column
				inc [y]
				dec si
				cmp si, 0
				jne WhiteTile
				mov [color], 6 ;the outline color (brown)
				call column
				inc [y] ;if I want some longer margins		
			mov [color], 6 ;the outline color (brown)
			call column
			dec sp
			cmp sp, 0
			jne Octave
			
		add [x], 63 ;jump to the next octave
		dec bp
		cmp bp, 0
		jne Layout
		
		
	mov [color], 0 ;the inside color (black)
	mov [x], 10 ;the cordinates
	mov [y], 73 ;the cordinates

	mov bp, 3
	BlackLayout:
		mov sp, 2
		Double:
			mov bl, 21 ; the width of the black piano tile 
			BlackTile1:
				call BlackColumn ;makes a black column
				inc [y]
				dec bl
				cmp bl, 0
				jne BlackTile1
			add [y], 11 ; the lenght between two near black tiles ;half of the white tile
			dec sp
			cmp sp, 0
			jne Double
		
		add [y], 31 ;the lenght of the jump between the two other black tiles
		mov si, 3
		Triple:
			mov bl, 21 ; the width of the black piano tile 
			BlackTile2:
				call BlackColumn ;makes a black column
				inc [y]
				dec bl
				cmp bl, 0
				jne BlackTile2
			add [y], 11 ; the lenght between two near black tiles ;half of the white tile
			dec si
			cmp si, 0
			jne Triple
	add [x], 63 ;jump to the next octave
	mov [y], 74
	dec bp
	cmp bp, 0
	jne BlackLayout
	pop sp
	pop bp
	pop si
endp piano

WaitForKey:
mov ah, 1
Int 16h
jz WaitForKey
in al, 60h
cmp al, 2
jne sskip2
jmp doOne
sskip2:
cmp al, 3
jne sskip3
jmp doTwo
sskip3:
cmp al, 4
jne sskip4
jmp doThree
sskip4:
cmp al, 5
jne sskip5
jmp doFour
sskip5:
cmp al, 6
jne sskip6
jmp doFive
sskip6:
cmp al, 7
jne sskip7
jmp doSix
sskip7:
cmp al, 8
jne sskip8
jmp DoSeven
sskip8:
cmp al, 9
jne sskip9
jmp doEight
sskip9:
cmp al, 0Ah
jne sskip10
jmp doNine
sskip10:
cmp al, 0Bh
jne sskip11
jmp doZero
sskip11:
cmp al, 0Ch
jne sskip12
jmp doMinus
sskip12:
cmp al, 0Dh
jne sskip13
jmp doPlus
sskip13:

;----- FIRST OCTAVE
cmp al, 10h
jne sskip14
jmp doQ
sskip14:
cmp al, 11h
jne sskip15
jmp doW
sskip15:
cmp al, 12h
jne sskip16
jmp doE
sskip16:
cmp al, 13h
jne sskip17
jmp doR
sskip17:
cmp al, 14h
jne sskip18
jmp doT
sskip18:
cmp al, 15h
jne sskip19
jmp doY
sskip19:
cmp al, 16h
jne sskip20
jmp doU
sskip20:
cmp al, 17h
jne sskip21
jmp doI
sskip21:
cmp al, 18h
jne sskip22
jmp doO
sskip22:
cmp al, 19h
jne sskip23
jmp doP
sskip23:
cmp al, 1Ah
jne sskip24
jmp doLM
sskip24:
cmp al, 1Bh
jne sskip25
jmp doRM
sskip25:
;---------------- SECOND OCTAVE
cmp al, 1Eh
jne sskip26
jmp doA
sskip26:
cmp al, 1Fh
jne sskip27
jmp doS
sskip27:
cmp al, 20h
jne sskip28
jmp doD
sskip28:
cmp al, 21h
jne sskip29
jmp doF
sskip29:
cmp al, 22h
jne sskip30
jmp doG
sskip30:
cmp al, 23h
jne sskip31
jmp doH
sskip31:
cmp al, 24h
jne sskip32
jmp doJ
sskip32:
cmp al, 25h
jne sskip33
jmp doK
sskip33:
cmp al, 26h
jne sskip34
jmp doL
sskip34:
cmp al, 27h
jne sskip35
jmp doLD
sskip35:
cmp al, 28h
jne sskip36
jmp doMD
sskip36:
cmp al, 2Bh
jne sskip37
jmp doRD
sskip37:
cmp al, 2ch
jne sskip38
jmp doJonSong
sskip38:
jmp WaitForKey
;---------------------- THIRD OCTAVE

doOne:
in al, 60h
cmp al, 2
call Pone
doTwo:
in al, 60h
cmp al, 3
call Ptwo
doThree:
in al, 60h
cmp al, 4
call Pthree
doFour:
in al, 60h
cmp al, 5
call Pfour
doFive:
in al, 60h
cmp al, 6
call Pfive
doSix:
in al, 60h
cmp al, 7
call Psix
doSeven:
in al, 60h
cmp al, 8
call Pseven
doEight:
in al, 60h
cmp al, 9
call Peight
doNine:
in al, 60h
cmp al, 0Ah
call Pnine
doZero:
in al, 60h
cmp al, 0Bh
call Pzero
doMinus:
in al, 60h
cmp al, 0Ch
call PMinus
doPlus:
in al, 60h
cmp al, 0Dh
call PPlus
doQ:
in al, 60h
cmp al, 10h
call PQ
doW:
in al, 60h
cmp al, 11h
call PW
doE:
in al, 60h
cmp al, 12h
call PE
doR:
in al, 60h
cmp al, 13h
call PR
doT:
in al, 60h
cmp al, 14h
call PT
doY:
in al, 60h
cmp al, 15h
call PY
doU:
in al, 60h
cmp al, 16h
call PU
doI:
in al, 60h
cmp al, 17h
call PI
doO:
in al, 60h
cmp al, 18h
call PO
doP:
in al, 60h
cmp al, 19h
call PP
doLM:
in al, 60h
cmp al, 1Ah
call PLM
doRM:
in al, 60h
cmp al, 1Bh
call PRM
doA:
in al, 60h
cmp al, 1Eh
call PA
doS:
in al, 60h
cmp al, 1Fh
call PS
doD:
in al, 60h
cmp al, 20h
call PD
doF:
in al, 60h
cmp al, 21h
call PF
doG:
in al, 60h
cmp al, 22h
call PG
doH:
in al, 60h
cmp al, 23h
call PH
doJ:
in al, 60h
cmp al, 24h
call PJ
doK:
in al, 60h
cmp al, 25h
call PK
doL:
in al, 60h
cmp al, 26h
call PL
doLD:
in al, 60h
cmp al, 27h
call PLD
doMD:
in al, 60h
cmp al, 28h
call PMD
doRD:
in al, 60h
cmp al, 2Bh
call PRD
doJonSong:
in al, 60h
cmp al, 2ch
call song
;doUpDown:
;in al, 60h
;cmp al, 2dh
;call updownsong

EndMusic1:
	call White1
	pop [y]
	pop [x]
	add [x], 38 
	add [y], 23 
	call WhiteSC
	in al, 61h
	and al, 11111100b
	out 61h, al
	jmp WaitForKey
	
EndMusic2:
	call Black2
	in al, 61h
	and al, 11111100b
	out 61h, al
	jmp WaitForKey
	
EndMusic3:
	push [x]
	push [y]
	call WhiteSC3
	
	pop [y]
	pop [x]
	push [x]
	push [y]
	sub [x], 38 
	add [y], 9 
	call White3
	
	pop [y]
	pop [x]
	push [x]
	push [y]
	add [y], 20
	call WhiteSC3
	in al, 61h
	and al, 11111100b
	out 61h, al
	jmp WaitForKey

EndMusic4:
	push [x]
	push [y]
	call WhiteSC3
	
	pop [y]
	pop [x]
	push [x]
	push [y]
	sub [x], 38 ;the cordinate of 1' tile
	add [y], 9 ;the cordinate of 1' tile
	call White4
	in al, 61h
	and al, 11111100b
	out 61h, al
	jmp WaitForKey

EndMusic6:
	push [x]
	push [y]
	call White6
	pop [y]
	pop [x]
	add [x], 38 
	add [y], 20
	call WhiteSC3
	in al, 61h
	and al, 11111100b
	out 61h, al
	jmp WaitForKey
	
EndMusic8:
	push [x]
	push [y]
	call WhiteSC3
	
	pop [y]
	pop [x]
	push [x]
	push [y]
	sub [x], 38 
	add [y], 7
	call White8
	
	pop [y]
	pop [x]
	push [x]
	push [y]
	add [y], 20
	call WhiteSC3
	in al, 61h
	and al, 11111100b
	out 61h, al
	jmp WaitForKey
	
EndMusic12:
	push [x]
	push [y]
	call WhiteSC3
	
	pop [y]
	pop [x]
	push [x]
	push [y]
	sub [x], 38 ;the cordinate of 1' tile
	add [y], 8 ;the cordinate of 1' tile
	call White12
	in al, 61h
	and al, 11111100b
	out 61h, al
	jmp WaitForKey

exit:
	mov ax, 4c00h
	int 21h
END start