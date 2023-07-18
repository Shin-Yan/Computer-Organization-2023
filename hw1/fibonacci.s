.data
msg1:   .asciiz "Please input a number: "
msg2:   .asciiz "The result of fibonacci(n) is "

.text
.globl main
main:
    li      $v0, 4
    la      $a0, msg1
    syscall

    li      $v0, 5
    syscall
    move    $t0, $v0    # put input to t0

    jal     fibonacci
    
    li      $v0, 4
    la      $a0, msg2
    syscall

    li      $v0, 1
    move    $a0, $v1
    syscall

    li      $v0, 10
    syscall             # end of the program

fibonacci: 
    addiu   $sp, $sp, -12
    sw      $ra, 8($sp) # store return address
    sw      $t0, 4($sp) # store n
    sw      $t1, 0($sp) # store temp value

    slti    $s0, $t0, 2
    beqz    $s0, L1     # if not less than 2, call recursively
    move    $v1, $t0    # return n if n < 2
    j restore

L1:
    addiu   $t0, $t0, -1
    jal     fibonacci
    move    $t1, $v1

    lw      $t0, 4($sp) # restore n
    addiu   $t0, $t0, -2
    jal     fibonacci
    add     $v1, $v1, $t1

restore:
    lw      $ra, 8($sp) # restore return address
    lw      $t0, 4($sp) # restore n
    lw      $t1, 0($sp) # restore temp value
    addiu   $sp, $sp, 12
    jr      $ra
