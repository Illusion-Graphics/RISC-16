fibonacci:
    ; Load the operating registers
    mov r1, r0
    movl r2, #0x01

    ; Max number of loops
    movl r4, #0x0a

    ; Address in memory where the result wil be stored
    movl r6, #0x00
    movu r6, #0x00

loop:
    ; Calculate the next number in the sequence
    add r3, r1, r2
    mov r1, r2
    mov r2, r3

    ; Store the value in memory
    str r6, r3
    inc r6, r6

    ; Check the number of iteration and jump back to the start
    dec r4, r4
    bnzo r4, #-7

end:
    hlt