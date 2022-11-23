;; This program print a wagon of 8x8 pixels, a barrel and a rail composed of tiles of 4x4 pixels
;; When a configurable key is pressed the wagon starts moving until the barrel
;; When a configurable key is pressed while the wagon is moving, the wagon stops
;; You can configure the speed of the wagon pressing three configurable keys
;; You can reset the position of the wagon pressing a configurable key
;; If the wagon don't stop just before the first barrel, an explosion will happen
;; If a explosion happens, the wagon will move slower the next round, if not, the wagon will move faster

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
position_explosion: dw #C000
num_barrels: db 20
speed_wagon: db 12  ;; number of halts cycles to wait before wagon is moved
initial_speed_wagon: db 12
start_brake1: db -30 ;; number of positions before starting brake, must be negative (counting from end)
start_brake2: db -10 ;; number of positions before second brake, must be negative (counting from end)
distance: db 0  ;; store the distance that the wagon has to run
explosion_enable: db 1  ;; Flag to enable the wagon explosion

init:
ld a, #1
ld (explosion_enable), a
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
call wait_routine       ;; Wait to avoid get the same key pressed if start and stop key are the same
ld hl, (initial_position_barrel)    ;; Calculate the distance between wagon and barrel for braking
ld de, (initial_position_wagon)
and a       ;; Clear the carry flag
sbc hl, de
ld de, #2
and a       ;; Clear the carry flag
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
ld a, (explosion_enable)
dec a
jr nz, check_reset_key
call print_megacrash
ld a, (initial_speed_wagon)
add a, #2
ld (initial_speed_wagon), a     ;; If lose, wagon move slower
check_reset_key:
    ld a, (key_reset)
    call #BB1E      ;; KM_TEST_KEY
    jr z, check_reset_key
call delete_wagon
ld a, (initial_speed_wagon)
dec a
jp z, init  ;; Minimum speed is 1
ld (initial_speed_wagon), a ;; Each round wagon move faster
jp init

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

;; Delete barrel
;; This routine modifies registers a, h and l
delete_barrel:
    ld hl, (position_barrel)
    ld (hl), #00            ;; Print in initial position
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), #00
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), #00
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), #00
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), #00
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), #00
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), #00
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), #00
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
    ld a, #0
    ld (explosion_enable), a    ;; Disable wagon explosion
    ld a, #5
    ld (distance), a
    change_speed_check_stop_key:
    ld a, (speed_wagon)
    add a, #A
    ld (speed_wagon), a     ;; Increase the speed value to signal the wagon is braking
    continue_check_stop_key:
    ret

;; Print the first frame of a explosion
;; This routine modifies registers a, h and l
print_explosion_frame_1:
    ld hl, (position_explosion)
    ld (hl), %10000000
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), %00010000
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %11100010
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), %01110100
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %01110010
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), %11100100
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %11101000
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), %01110001
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %01110001
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), %11101000
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %11100100
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), %01110010
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %01110100
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), %11100010
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %00010000
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), %10000000
    ret

;; Print the second frame of a explosion
;; This routine modifies registers a, h and l
print_explosion_frame_2:
    ld hl, (position_explosion)
    ld (hl), %11111000
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), %11110001
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %11111010
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), %11110101
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %11010001
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), %10111000
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %01110110
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), %11100110
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %11100110
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), %01110110
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %10111000
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), %11010001
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %11110101
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), %11111010
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %11110001
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), %11111000
    ret

;; Print the third frame of a explosion
;; This routine modifies registers a, h and l
print_explosion_frame_3:
    ld hl, (position_explosion)
    ld (hl), %01110111
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), %11101110
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %01010101
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), %10101010
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %11001100
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), %00110011
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %00010001
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), %10001000
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %10001000
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), %00010001
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %00110011
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), %11001100
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %10101010
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), %01010101
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), %11101110
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), %01110111
    ret

;; Delete the area where the explosion frame is draw
;; This routine modifies registers a, h and l
delete_explosion:
    ld hl, (position_explosion)
    ld (hl), #00
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), #00
    ld a, h
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), #00
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), #00
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), #00
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), #00
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), #00
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), #00
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), #00
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), #00
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), #00
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), #00
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), #00
    inc l                   ;; Increment for printing the second 4 bits column
    ld (hl), #00
    add a, #8
    ld h, a                 ;; Increment h in 8 to wrap the next file
    ld (hl), #00
    dec l                   ;; Decrement for printing the first 4 bits column
    ld (hl), #00
    ret

;; Print an animation of a explosion
;; This routine modifies registers a, h and l
print_explosion:
    call print_explosion_frame_1
    ld a, #30
    call wait_routine
    call print_explosion_frame_2
    ld a, #30
    call wait_routine
    call print_explosion_frame_3
    ld a, #30
    call wait_routine
    call delete_explosion
    ret

;; Print a crash where wagon dissapears and a explosion happens
;; This routine modifies registers a, h and l
print_crash:
    call delete_wagon
    ld hl, (initial_position_barrel)
    dec hl
    ld (position_explosion), hl
    call print_explosion
    ret

;; Print a mega crash where wagon dissapears and all barrels explode
;; This routine modifies registers a, b, h and l
print_megacrash:
    ld a, (num_barrels)
    ld b, a
    call print_crash
    dec b   ;; The first barrel has exploded
    loop_print_megacrash:
        ld hl, (position_explosion)
        inc hl
        inc hl
        ld (position_explosion), hl
        call print_explosion
        dec b
        jr nz, loop_print_megacrash
    ret
