.data
msg1:   .asciiz"Please enter option (1: add, 2: sub, 3: mul): "
msg2:   .asciiz"Please enter the first number: "
msg3:   .asciiz"Please enter the second number: "
msg4:   .asciiz"The calculation result is: "

.text 
.globl main
main:
    li      $v0, 4
    la      $a0, msg1
    syscall

    li      $v0, 5
    syscall
    move    $t0, $v0

    li      $v0, 4
    la      $a0, msg2
    syscall

    li      $v0, 5
    syscall
    move    $t1, $v0

    li      $v0, 4
    la      $a0, msg3
    syscall

    li      $v0, 5
    syscall
    move    $t2, $v0

    li      $v0, 4
    la      $a0, msg3
    syscall

    li      $s0, 1
    beq     $t0, $s0, L_add
    li      $s0, 2
    beq     $t0, $s0, L_sub
    li      $s0, 3
    beq     $t0, $s0, L_mul

    li      $v0, 10
	syscall

L_add:
    li      $v0, 1
    add     $a0, $t1, $t2
    syscall

    li      $v0, 10
	syscall

L_sub:
    li      $v0, 1
    sub     $a0, $t1, $t2
    syscall

    li      $v0, 10
	syscall

L_mul:
    li      $v0, 1
    mul     $a0, $t1, $t2
    syscall

    li      $v0, 10
	syscall