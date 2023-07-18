.data
msg1:	.asciiz "Please input a number: "
msg2:	.asciiz "It's a prime"
msg3:	.asciiz	"It's not a prime"

.text
.globl main
main:
    # read the input first
	li      $v0, 4				
	la      $a0, msg1			
	syscall
	
	li      $v0, 5          	
  	syscall
  	         	
  	move	$a0, $v0
  	jal	    prime
  	beq	    $v1, $zero, L4
	
	li      $v0, 4				
	la      $a0, msg2			
	syscall
	
	li      $v0, 10
	syscall
	
	L4:
	li      $v0, 4				
	la      $a0, msg3		
	syscall

    li      $v0, 10
	syscall
	
.text
# return 1 if input is prime else 0
prime:	
	addi	$s0, $a0, -1			
	bne	    $s0, $zero, L1
	move	$v1, $zero
	jr	    $ra
L1:	
	addi	$t0, $zero, 2	# t0 = i
Loop:
	mul	    $t2, $t0, $t0	# t2 = i * i
	bgt	    $t2, $a0, L3
	div	    $t3, $a0, $t0
	mfhi	$t3	            # t3 = n % i
	bne	    $t3, $zero, L2
	move	$v1, $zero
	jr	    $ra
L2:
	addi	$t0, $t0, 1
	j	    Loop
L3:
	addi	$v1, $zero, 1
	jr	    $ra	
