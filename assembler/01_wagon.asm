;; This program print a wagon of 8x8 pixels and a rail composed of tiles of 4x4 pixels

org #4000
run init

;; Store the initial video memory address for printing
position_wagon: dw #C410
position_rail: dw #C460

init:

;; Print wagon
ld hl, (position_wagon)
ld (hl), %10001000      ;; Print in initial position
inc l                   ;; Increment for printing the second 4 bits column
ld (hl), %00010001
ld a, h
add a, #8
ld h, a                 ;; Increment h in 8 to wrap the next file
ld (hl), %11110001
dec l                   ;; Decrement for printing the first 4 bits column
ld (hl), %11111000
add a, #8
ld h, a                 ;; Increment h in 8 to wrap the next file
ld (hl), %11111110
inc l                   ;; Increment for printing the second 4 bits column
ld (hl), %11110111
add a, #8
ld h, a                 ;; Increment h in 8 to wrap the next file
ld (hl), %11111111
dec l                   ;; Decrement for printing the first 4 bits column
ld (hl), %11111111
add a, #8
ld h, a                 ;; Increment h in 8 to wrap the next file
ld (hl), %10111011
inc l                   ;; Increment for printing the second 4 bits column
ld (hl), %11011101
add a, #8
ld h, a                 ;; Increment h in 8 to wrap the next file
ld (hl), %10001010
dec l                   ;; Decrement for printing the first 4 bits column
ld (hl), %00010101
add a, #8
ld h, a                 ;; Increment h in 8 to wrap the next file
ld (hl), %01001010
inc l                   ;; Increment for printing the second 4 bits column
ld (hl), %00100101
add a, #8
ld h, a                 ;; Increment h in 8 to wrap the next file
ld (hl), %00000010
dec l                   ;; Decrement for printing the first 4 bits column
ld (hl), %00000100

;; Print rail
ld hl, (position_rail)
ld b, #50                   ;; Do the loop 80 times (a file contains 320 pixels)
loop_print_rail:
    ld (hl), %01011111
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %01000000
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %01100000
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %01010000
    inc l
    add a, #E8
    ld h, a                 ;; Add -24 to h to return the original file
    dec b
    jr nz, loop_print_rail

jr $
