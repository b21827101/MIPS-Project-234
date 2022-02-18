#$s1 = 15 (array size)
	
	
	.data
arr:    .word 0, 1, 5, 400, 112, 17, 7, 0, 560, 13, 0, 11, 3, 5, 0
	.text
	.globl main

	.data
output: .asciiz "The average similarity score is: "
	.text
	.globl main2
	
# $s1 = datasize, $s0 = array base address
# $s2 = i

#initialization code

addi $s2, $0, 0 # i=0

main:
	la  $t1, arr  #address of the array

loop:
	sub $t0, $s2, $s1 #i-datasize
	bne $t0, $0, if   #if i - datasize() is 0,outside the loop
	li $s2, 0 
	li $t0, 0       #clear registers
	li $t4, 0
	li $s0, 0
	
	jal main2   #call main2
	
if: 	
	sll $t0, $s2, 2
	addu $t0, $t0, $t1
	lw $t2, 0($t0) # calc address of data[i]
	
	rem $t3, $t2, 2    #it is remainder,it gives remain (data[i]%2) 
	bne $t3, $0, else  #if it is not even,go to else block
	sra $t2, $t2, 3    #data[i]/8
	j end
	
else:
	sll $t4, $t2, 2  #$t4 = data[i]*4
	sll $t5, $t2, 0  #$t5 = data[i]*1
	add $t2, $t4, $t5  
	j end
	
end:
	sw $t2, 0($t0)
	addi $s2, $s2, 1 #i=i+1
	j loop           #restart loop
	
	
#$s0=sum, $s1=avg
#$a1=n, $a2=data
main2:
	la  $a0, arr #address of arr array
	
	add $a1,$s1,$0    #n=datasize 
	li $s1, 0
	jal average_recursive #call part 2
	
	li $v0, 4 
	la $a0, output #print "The average..." string
	syscall
	
 	add $a0, $v1, $0 # Print average.
        li $v0, 1
        syscall
	
	li $v0, 10
	syscall # Execute the 'exit' syscall

average_recursive:

	addi $sp, $sp, -12# make space on stack to store three registers
	sw $ra, 0($sp)#caller saved
	sw $s2, 4($sp) #save data[n-1]
	sw $a1, 8($sp) #save n

	beq $a1, 1, basecase #if n=1,go to the basecase

	sub $t0, $a1, 1 #[size-1]
	mul  $t0,  $t0, 4
	addu  $t0,  $t0, $a0
	lw $s2, 0($t0) #data[n-1]


	sub $a1, $a1, 1 #n=n-1
	jal average_recursive # call again with n-1,data  ,recursive call

	mul $t4, $a1,$v0 #(n-1)*average_recursive
	addu $s0, $s2, $t4 #added data[n-1] to $t4

	jal average_recursive_end

basecase:
	lw $s0, 0($a0) #sum = data[0]
	jal average_recursive_end  #call average_recursive_end

average_recursive_end:
	lw $a1, 8($sp)  #restore $a1 from stack
	
	div $s1, $s0, $a1 #avg = sum /n
	
	addi $v0, $s1, 0  #put the avg value in the $v0
	addi $v1, $s1, 0
	
	lw $ra, 0($sp) #restore $ra from stack
	lw $s2, 4($sp)  #restore $s2 from stack
	addi $sp, $sp, 12 # deallocate stack space
	 
	jr $ra #return to caller
