.data
msg0:	.asciiz "Please enter option (1: triangle, 2: inverted triangle): "
msg1:	.asciiz "Please input a triangle size: "
msg2:	.asciiz " "
msg3:	.asciiz "*"
msg4:	.asciiz "\n"


.text
.globl main
main:
    li      $v0, 4			
	la      $a0, msg0		
	syscall

    li      $v0, 5
    syscall
    move    $t0, $v0

	li      $v0, 4				
	la      $a0, msg1
	syscall

    li      $v0, 5
    syscall
    move    $t1, $v0	# store the value of triangle size in t1

	li 		$t2, 1 
	beq 	$t0, $t2, triangle
	addi 	$t2, $t2, 1
	beq		$t0, $t2, inverted

	li      $v0, 10
	syscall				# exit if input of first parameter is not 0 nor 1

printLine:
	addi	$s0, $zero, 1
Loop_p:
	blt		$s0, $t1, printSpace
	bgt		$s0, $t2, printSpace
	li		$v0, 4
	la		$a0, msg3
	syscall
	addi	$s0, $s0, 1
	ble		$s0, $t0, Loop_p
	jr 		$ra
printSpace:
	li		$v0, 4
	la		$a0, msg2
	syscall
	addi	$s0, $s0, 1
	ble		$s0, $t0, Loop_p
	jr 		$ra

triangle:
	li		$s0, 2
	mul		$t0, $t1, $s0
	addi	$t0, $t0, -1	# t0 be the range of the output
	move 	$t2, $t1
Loop_t:
	jal		printLine
	li      $v0, 4				
	la      $a0, msg4
	syscall
	addi	$t1, $t1, -1
	addi	$t2, $t2, 1
	bne		$t1, $zero, Loop_t
	li      $v0, 10
	syscall				# exit if end

inverted:
	li		$s0, 2
	mul		$t0, $t1, $s0
	addi	$t0, $t0, -1	# t0 be the range of the output
	move 	$t2, $t0
	li		$t1, 1
Loop_i:
	jal		printLine
	li      $v0, 4				
	la      $a0, msg4
	syscall
	addi	$t1, $t1, 1
	addi	$t2, $t2, -1
	ble		$t1, $t2, Loop_i
	li      $v0, 10
	syscall				# exit if end