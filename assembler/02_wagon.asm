;; This program print a wagon of 8x8 pixels and a rail composed of tiles of 4x4 pixels
;; When a configurable key is pressed the wagon starts moving until the end of the rail
;; You can configure the speed of the wagon pressing three configurable keys

org #4000
run init

;; Store the initial video memory address for printing
key_start: db 47    ;; space
key_reset: db 50    ;; r
key_speed1: db 64   ;; 1
key_speed2: db 65   ;; 2
key_speed3: db 57   ;; 3
initial_position_wagon: dw #C410
position_wagon: dw #C410
position_rail: dw #C460
speed_wagon: db 12  ;; number of halts cycles to wait before wagon is moved
start_brake1: db -30 ;; number of positions before starting brake, must be negative (counting from end)
start_brake2: db -10 ;; number of positions before second brake, must be negative (counting from end)

init:
ld hl, (initial_position_wagon)
ld (position_wagon), hl
call print_rail
call print_wagon
call wait_start_key
ld c, #4E
loop_draw:
    call print_wagon
    call wait_routine
    call delete_wagon
    ld hl, (position_wagon)
    inc hl
    ld (position_wagon), hl
    call check_brake
    dec c
    jr nz, loop_draw
call print_wagon
check_reset_key:
    ld a, (key_reset)
    call #BB1E      ;; KM_TEST_KEY
    jr z, check_reset_key
call delete_wagon
jr init

;; Print wagon
;; This routine modifies registers a, h and l
print_wagon:
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
    ret

;; Delete wagon
;; This routine modifies registers a, h and l
delete_wagon:
    ld hl, (position_wagon)
    ld (hl), %00000000
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), %00000000
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %00000000
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), %00000000
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %00000000
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), %00000000
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %00000000
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), %00000000
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %00000000
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), %00000000
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %00000000
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), %00000000
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %00000000
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), %00000000
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %00000000
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), %00000000
    ret

;; Print rail
;; This routine modifies registers a, b, h and l
print_rail:
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
    ret

;; Wait a number of halts
;; This routine modifies register b
wait_routine:
    ld a, (speed_wagon)
    loop_wait:
        halt
        dec a
        jr nz, loop_wait
    ret

;; Wait for pressing the start key
wait_start_key:
    check_start_key:
        ld a, (key_start)
        call #BB1E      ;; KM_TEST_KEY
        jr nz, continue_wait_start_key
        ld a, (key_speed1)
        call #BB1E      ;; KM_TEST_KEY
        jr nz, set_speed1
        ld a, (key_speed2)
        call #BB1E      ;; KM_TEST_KEY
        jr nz, set_speed2
        ld a, (key_speed3)
        call #BB1E      ;; KM_TEST_KEY
        jr nz, set_speed3
    jr check_start_key
    set_speed1:
    ld a, 12
    ld (speed_wagon), a
    jr continue_wait_start_key
    set_speed2:
    ld a, 6
    ld (speed_wagon), a
    jr continue_wait_start_key
    set_speed3:
    ld a, 2
    ld (speed_wagon), a
    continue_wait_start_key:
    ret

;; Routine for checking when the wagon start braking
check_brake:
    ld a, (start_brake1)
    add a, c
    jr z, set_brake1
    ld a, (start_brake2)
    add a, c
    jr z, set_brake2
    jr continue_check_brake
    set_brake2:
    ld a, (speed_wagon)
    add a, 12
    ld (speed_wagon), a
    jr continue_check_brake
    set_brake1:
    ld a, (speed_wagon)
    add a, 4
    ld (speed_wagon), a
    continue_check_brake:
    ret
