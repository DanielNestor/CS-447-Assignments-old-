.data
	buffer: .space 100
.text
#make sure register t9 is zero
add $t9, $zero, $zero
#Start the game
Start_Loop:
bne $t9, 16, Start_Loop

#play the start up sound
add $t8, $zero, 16

#reset register t3
add $t3, $zero, $zero

Repeat:

#jump to the random generator where I will
#get a random number and then put it
#into a buffer
jal _Random_Generator

#jump to convert the randomly 
#generated number into a beep
#onto the screen
jal _playSequence


#now let the user play the game
jal _userPlay


#jump back
beqz $v0, Repeat

#play the lose sound
add $t8, $zero, 15

j clear_buffer
clear_buffer_return:



#reset the replay register
add $t9, $zero, $zero
j Start_Loop


#generate a random number here
_Random_Generator:
#Generate the seed value for a random integer
	addi $v0, $zero, 42
	add $a0, $zero, $zero
	addi $a1, $zero, 4
	syscall
	
	#branches to a handler that puts the value
	#into the buffer
	beq $a0, $zero, blue_handler
	beq $a0, 1, red_handler
	beq $a0, 2, yellow_handler
	beq $a0, 3, green_handler

	
random_return:		
	#increment $t3 so we know where to 
	#point next time if the player is
	#correct
	add $t3, $t3, 4

jr  $ra

#Play the computer's sequence 
#afterwards put the next item
#into the sequence
_playSequence:
#load the adress of the buffer
la $t2, buffer

play_sequence_return:
#store in register $t5 the value you 
#get from the buffer
lbu $t5,($t2)
#put the byte into t8
add $t8,$zero,$t5

#increment t2
add $t2, $t2, 4

#branch back if a zero is
#not encountered
bne $t5, $zero, play_sequence_return

#clear out the registers t2 and t5
add $t2, $zero, $zero
add $t5, $zero, $zero



jr $ra

#this section is where
#the user inputs their
#code and trys to match 
#the displayed sequence
_userPlay:

#reset the value in v0
add $v0, $zero, $zero
#load the address of buffer again
la $t1, buffer

#set register $t9 to zero
add $t9, $zero, $zero


Loop_Return_up:
#play sound if possible
add $t8, $t9, $zero
#set register $t9 to zero
add $t9, $zero, $zero

lbu $t5,($t1)

beq $t5, 0, Skip

#loop to hold the user off
Hold_1:
beqz $t9, Hold_1

#increment t1
add $t1, $t1, 4


beq $t5, $t9, Loop_Return_up

#set the value in v0 to 1
#to know that the user failed to
#do the sequence correctly
add $v0, $zero, 1

#skip the return
Skip:
#clear $t9
add $t9, $zero, $zero

jr $ra


#handlers for the numbers generated
#the value is then stored onto the 
#buffer to be played later

red_handler:
la $t1, buffer
add $t1, $t1, $t3
add $t2, $zero, 8
sw $t2,($t1)

#reset registers that aren't t3
add $t1, $zero, $zero
add $t2, $zero, $zero

j random_return

yellow_handler:

la $t1, buffer
add $t1, $t1, $t3
add $t2, $zero, 2
sw $t2,($t1)

#reset registers that aren't t3
add $t1, $zero, $zero
add $t2, $zero, $zero

j random_return

blue_handler:

la $t1, buffer
add $t1, $t1, $t3
add $t2, $zero, 1
sw $t2,($t1)

#reset registers that aren't t3
add $t1, $zero, $zero
add $t2, $zero, $zero

j random_return

green_handler:

la $t1, buffer
add $t1, $t1, $t3
add $t2, $zero, 4
sw $t2,($t1)

#reset registers that aren't t3
add $t1, $zero, $zero
add $t2, $zero, $zero

j random_return

clear_buffer:
#load the address into t1
la $t1, buffer
clear_loop:
lbu $t5,($t1)
sw $zero,($t1)
#incrementing ti again
add $t1, $t1, 4

bne $zero, $t5, clear_loop

#clear out register t1
add $t1, $zero, $zero
j clear_buffer_return
