INCLUDE     "hardware.inc"

SECTION     "Start", HOME[$100]
nop
jp          Start

SECTION     "Example", HOME[$150]

Start:
    di
    ld      sp, $E000

.wait_vbl
    ld      a, [rLY]
    cp      $90
    jr      nz, .wait_vbl       ; Wait for vblank

    xor     a
    ld      [rIF], a            ; Reset usual regs
    ld      [rLCDC], a
    ld      [rSTAT], a
    ld      [rSCX], a
    ld      [rSCY], a
    ld      [rLYC], a
    ld      [rIE], a

    ld      hl, _RAM            ; Fill RAM with a, a = 0 here
    ld      bc, $2000-2
    call    Fill

    ld      hl, _VRAM
    ld      b, $18              ; bc should be $1800
    call    Fill

    ld      a, $20              ; Space char
    ; No need to setup hl since _SCRN0 and _SCRN1 are part of _VRAM
    ld      b, 8
    call    Fill

    ld      a, %10010011        ; 00 - White, 01 - Light grey, 10 - Dark gray, 11 - Black
    ld      [rBGP], a           ; BG pallete
    ld      [rOBP0], a          ; Obj palletes
    ld      [rOBP1], a

    ld      hl, font            ; Font data
    ld      de, _VRAM+$200      ; Place it here to get ASCII mapping
    ld      bc, 1776            ; Font size
    call Copy

    ld      hl, text
    ld      de, _SCRN0+$100     ; Center it a bit
    ld      c, text_end-text    ; b = 0, our string = 12 chars
    call    Copy                ; LCDC is disabled so we have easy access to VRAM

    ld      a, LCDCF_ON | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_OBJ8 | LCDCF_OBJOFF | LCDCF_WINOFF | LCDCF_BGON
    ld      [rLCDC], a

.the_end:
    halt
    nop

    jr      .the_end

;------------------------------------------------------------
Copy:
;------------------------------------------------------------
; hl - from
; dc - to
; bc - h
    inc     b
    inc     c
    jr      .skip

.copy:
    ld      a, [hl+]
    ld      [de], a
    inc     de

.skip:
    dec     c
    jr      nz, .copy
    dec     b
    jr      nz, .copy
    ret

;------------------------------------------------------------
Fill:
;------------------------------------------------------------
; a - byte to fill with
; hl - destination address
; bc - size of area to fill
    inc     b
    inc     c
    jr      .skip

.fill:
    ld      [hl+], a

.skip:
    dec     c
    jr      nz, .fill
    dec     b
    jr      nz, .fill
    ret

;------------------------------------------------------------
font:
    INCBIN  "speccy.chr"          ; font data

text:
    DB      "Hello world! "
text_end:
