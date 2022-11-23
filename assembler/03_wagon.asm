;; This program print a wagon of 8x8 pixels, a barrel and a rail composed of tiles of 4x4 pixels
;; When a configurable key is pressed the wagon starts moving until the barrel
;; When a configurable key is pressed while the wagon is moving, the wagon stops
;; You can configure the speed of the wagon pressing three configurable keys
;; You can reset the position of the wagon pressing a configurable key

org #4000
run init

;; Store the initial video memory address for printing
key_start: db 47    ;; space
key_stop: db 47     ;; space
key_reset: db 50    ;; r
key_speed1: db 64   ;; 1
key_speed2: db 65   ;; 2
key_speed3: db 57   ;; 3
initial_position_wagon: dw #C410
position_wagon: dw #C410
position_rail: dw #C460
initial_position_barrel: dw #C438
position_barrel: dw #C438
num_barrels: db 20
speed_wagon: db 12  ;; number of halts cycles to wait before wagon is moved
initial_speed_wagon: db 12
start_brake1: db -30 ;; number of positions before starting brake, must be negative (counting from end)
start_brake2: db -10 ;; number of positions before second brake, must be negative (counting from end)
distance: db 0  ;; store the distance that the wagon has to run

init:
ld hl, (initial_position_wagon)
ld (position_wagon), hl
ld hl, (initial_position_barrel)
ld (position_barrel), hl
call print_rail
call print_wagon
call print_n_barrels
call wait_start_key
ld a, (initial_speed_wagon)
ld (speed_wagon), a             ;; After pressing the start key set the speed to be modified
ld a, 50
call wait_routine
ld hl, (initial_position_barrel)    ;; Calculate the distance between wagon and barrel for braking
ld de, (initial_position_wagon)
and a
sbc hl, de
ld de, #2
and a
sbc hl, de                  ;; Substrac 2 to the distance (lenght of the wagon)
ld a, l                     ;; The distance must be only 1 byte size
ld (distance), a
loop_draw:
    call print_wagon
    ld a, (speed_wagon)
    call wait_routine
    call delete_wagon
    ld hl, (position_wagon)
    inc hl
    ld (position_wagon), hl
    call check_brake
    call check_stop_key
    ld a, (distance)
    dec a
    ld (distance), a    ;; z is unafecte with ld operation
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
;; Before call the routine the number of hats must be in register a
;; This routine modifies register a
wait_routine:
    loop_wait:
        halt
        dec a
        jr nz, loop_wait
    ret

;; Wait for pressing the start key
;; This routine modifies registers a, c h and l
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
    ld (initial_speed_wagon), a
    jr continue_wait_start_key
    set_speed2:
    ld a, 6
    ld (initial_speed_wagon), a
    jr continue_wait_start_key
    set_speed3:
    ld a, 2
    ld (initial_speed_wagon), a
    continue_wait_start_key:
    ret

;; Routine for checking when the wagon start braking
;; This routine modifies registers a and b
check_brake:
    ld a, (distance)
    ld b, a
    ld a, (start_brake1)
    add a, b
    jr z, set_brake1
    ld a, (start_brake2)
    add a, b
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

;; Print barrel
;; This routine modifies registers a, h and l
print_barrel:
    ld hl, (position_barrel)
    ld (hl), %10011001      ;; Print in initial position
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %01101111
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %10011111
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %11111111
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %01101111
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %10011111
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %11110110
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %01100000
    ret

;; Print n barrels
;; This routine modifies registers a, b, h and l
print_n_barrels:
    ld a, (num_barrels)
    ld b, a
    loop_print_barrel:
        call print_barrel
        ld hl, (position_barrel)
        inc hl
        inc hl
        ld (position_barrel), hl
        dec b
        jr nz, loop_print_barrel
    ret

;; Check if the stop key has been pressed
;; This routine modifies registers a, c, h and l
check_stop_key:
    ld a, (key_stop)
    call #BB1E      ;; KM_TEST_KEY
    jr z, continue_check_stop_key     ;; Check if stop key has been pressed
    ld a, (distance)
    sub #5
    jp m, change_speed_check_stop_key ;; Check if distance is less than 5, if not set distance to 5
    ld a, #5
    ld (distance), a
    change_speed_check_stop_key:
    ld a, (speed_wagon)
    add a, #A
    ld (speed_wagon), a     ;; Increase the speed value to signal the wagon is braking
    continue_check_stop_key:
    ret
