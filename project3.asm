#Daniel Nestor
#3-25-2015
#maze solver

#this program 
.data
direct_route_buffer: .space 10000
direct_route_buffer_wo_redundancy: .space 10000


.text
#make sure registers are set back to zero
add $t6, $zero, $zero
add $t7, $zero, $zero

#reset location of car
add $t8, $zero, 4



#jump to each of the functions
jal _leftHandRule

#copy what was returned from v0 into a0
add $a0, $zero, $v0

jal _clear_buffer_duplicates



#turns the car around after reaching the exit
jal _turnAround



#part 2
jal _traceBack

#post trace back corrections
jal _go_west


#turns the car around after reaching the exit
jal _turnAround

#move forward 1 space
add $t8, $zero, 1
#put approach value into the a0
add $a0, $zero, 4

jal _backTracking


j quit
#quit
j quit






#returns number of moves x4 in v0
_leftHandRule:
#load the adress of the buffer
la $t1, direct_route_buffer

#make the initial move
add $t8, $zero, 1


#add 16bits to the buffer address
add $t1, $t1, 8

#increment the length
add $v0, $v0, 8


#update Location
add $t8, $zero, 4




return_1:

#always re-update location
add $t8, $zero, 4

#using register t6 to check if there is a hole
#on the left
add $t6, $zero, 4

#anding to check
and $t6, $t9, $t6

#check to see if we are at the destination
sgt $t0, $t9, 0x07080000
bnez $t0, quick_jump

#skip section
bnez $t6, skip_2
#turn the car
add $t8, $zero, 2
add $t8, $zero, 1
#store location on buffer
#store y first
sll $t9, $t9, 1
srl $t9,$t9, 25
sb $t9, ($t1)
#increment the buffer
add $t1, $t1, 4
#increment the length
add $v0, $v0, 4
#update Location
add $t8, $zero, 4
#store x next
sll $t9, $t9, 9
srl $t9,$t9, 25
sb $t9, ($t1)
#increment the buffer
add $t1, $t1, 4
#increment the length
add $v0, $v0, 4
#update Location
add $t8, $zero, 4




#reset register t6
add $t6,$zero,$zero
j return_1

skip_2:

#reset register t6
add $t6,$zero,$zero


#add a 4 to check the 3rd bit
add $t7, $zero, 8

#anding to check
and $t7, $t9, $t7

#check to see if we are at the destination 8x8
sgt $t0, $t9, 0x07080000


bnez $t0, quick_jump


#if there is no north wall in front 
#do not turn
beqz $t7, skip_1
add $t8, $zero, 3




add $t8, $zero, 4

#reset register t7
add $t7, $zero, $zero

j return_1

skip_1:

#reset register t7
add $t7, $zero, $zero


#make move forward
add $t8, $zero, 1
#store location on buffer
#store y first
sll $t9, $t9, 1
srl $t9,$t9, 25
sb $t9, ($t1)
#increment the buffer
add $t1, $t1, 4
#increment the length
add $v0, $v0, 4
#update Location
add $t8, $zero, 4
#store x next
sll $t9, $t9, 9
srl $t9,$t9, 25
sb $t9, ($t1)
#increment the buffer
add $t1, $t1, 4
#increment the length
add $v0, $v0, 4
#update Location
add $t8, $zero, 4




#check to see if we are at the destination
sgt $t0, $t9, 0x07080000
bnez $t0, quick_jump

j return_1

#go back to main
quick_jump:

#place termination values at the end of the buffer
add $t4, $zero, 100
sb $t4, ($t1)
#increment the buffer
add $t1, $t1, 4
sb $t4, ($t1)
jr $ra






_traceBack:

#load adress of the buffer without duplicates
la $t1, direct_route_buffer_wo_redundancy

#move forward
add $t9, $zero, 1

#loop until you hit the null terminator of the buffer
go_to_end_loop:
lbu $s0,($t1)
add $t1, $t1, 4
bne $s0, 100, go_to_end_loop


#go back to where an actual value is
add $t1, $t1, -16

jump_back_trace_back:
#put the value into where you need it
lbu $s0,($t1)
#give $t2 a value
add $t2, $t1, -4
lbu $s1, ($t2)
#Get the Values of your vehicle's location
#update Location
add $t8, $zero, 4

#store y first
sll $t9, $t9, 1
srl $t9,$t9, 25
#put into the s3 register
add $s3, $zero, $t9
#update Location
add $t8, $zero, 4

#store x next
sll $t9, $t9, 9
srl $t9,$t9, 25
#put into the s2 register
add $s2, $zero, $t9

#get out if s2 is less than zero
beq $s2, -1, trace_back_escape





#update Location
add $t8, $zero, 4


#put the subtracted values into registers s4 and s5
sub $s4, $s2, $s0
sub $s5, $s3, $s1


#get the direction you are facing
sll $t9, $t9, 20
srl $t9, $t9, 28

add $t3, $zero, $t9

#if they are all zero get out
bnez $s0, skip_here_100
bnez $s1, skip_here_100
bnez $s2, skip_here_100
bnez $s3,skip_here_100 
j trace_back_escape
skip_here_100:
#branches to the facings
beq $t3, 8, facing_north
beq $t3, 4, facing_east
beq $t3, 2, facing_south
beq $t3, 1, facing_west

#what to do depending on the direction you are facing and
#what the next direction is
facing_north:
beq $s5,1,go_straight
beq $s4,-1, turn_right
beq $s4,1, turn_left

facing_south:
beq $s5,-1,go_straight
beq $s4, 1, turn_right
beq $s4,-1, turn_left

facing_east:
beq $s5,-1,turn_right
beq $s5,1,turn_left
beq $s4, -1, go_straight


facing_west:
beq $s5,1,turn_right
beq $s5,-1,turn_left
beq $s4, 1, go_straight

#giving instructions to car
turn_left:
#do the instruction described above
add $t8, $zero, 2
add $t8, $zero, 1
j move_made

turn_right:
#do the instruction described above
add $t8, $zero, 3
add $t8, $zero, 1
j move_made

go_straight:
#do the instruction described above
add $t8, $zero, 1
j move_made



move_made:
#update the location
add $t8, $zero, 4

#subtract 8 from t1
add $t1, $t1, -8



j jump_back_trace_back

trace_back_escape:

#preemptively clear out all usable t registers
add $t0, $zero, $zero
add $t1, $zero, $zero
add $t2, $zero, $zero
add $t3, $zero, $zero
add $t4, $zero, $zero
add $t5, $zero, $zero
add $t6, $zero, $zero
add $t7, $zero, $zero

#preemptively clear out all usable s registers
add $s0, $zero, $zero
add $s1, $zero, $zero
add $s2, $zero, $zero
add $s3, $zero, $zero
add $s4, $zero, $zero
add $s5, $zero, $zero
add $s6, $zero, $zero
add $s7, $zero, $zero

jr $ra


#going through the maze
#using recursion
_backTracking:
#check if  the $v0 value is -1
beq $v0, -1, break_out_of_recursion 
#update Location
add $t8, $zero, 4

#check to see if we are at the destination 8x8
sgt $t0, $t9, 0x07080000
beq $t0, $zero, recursion_break_skip

add $v0, $v0, -1 
j quit
recursion_break_skip: 

#branch to whichever approach you think you need
beq $a0, 1, north_approach
beq $a0, 4, west_approach
beq $a0, 3, south_approach
beq $a0, 2, east_approach

#this long section is for the various possible directions
#that one may approach from
west_approach:

jal _if_south_wall
beq $v0, 1, south_skip_1
jal _go_south
addi $sp, $sp, -4
sw $ra,0($sp)
add $a0, $zero, 1
jal _backTracking
south_skip_1:

jal _if_east_wall
beq $v0, 1, east_skip_1
jal _go_east
addi $sp, $sp, -4
sw $ra,0($sp)
add $a0, $zero, 4
jal _backTracking
east_skip_1:

jal _if_north_wall
beq $v0, 1, north_skip
jal _go_north
addi $sp, $sp, -4
sw $ra,0($sp)
add $a0, $zero, 3
jal _backTracking
north_skip:



jal _if_west_wall
beq $v0, 1, west_skip_1
jal _go_west
addi $sp, $sp, -4
sw $ra,0($sp)
add $a0, $zero, 2
jal _backTracking
west_skip_1:
add $a0, $a0, 4
j approach_skipper


north_approach:

jal _if_west_wall
beq $v0, 1, west_skip_2
jal _go_west
addi $sp, $sp, -4
sw $ra,0($sp)
add $a0, $zero, 2
jal _backTracking
west_skip_2:

jal _if_south_wall
beq $v0, 1, south_skip_2
jal _go_south
addi $sp, $sp, -4
sw $ra,0($sp)
add $a0, $zero, 1
jal _backTracking
south_skip_2:

jal _if_east_wall
beq $v0, 1, east_skip_2
jal _go_east
addi $sp, $sp, -4
sw $ra,0($sp)
add $a0, $zero, 4
jal _backTracking
east_skip_2:


jal _if_north_wall
beq $v0, 1, north_skip_2
jal _go_north
addi $sp, $sp, -4
sw $ra,0($sp)
add $a0, $zero, 3
jal _backTracking
north_skip_2:
add $a0, $a0, 1
j approach_skipper

east_approach:

jal _if_north_wall
beq $v0, 1, north_skip_3
jal _go_north
addi $sp, $sp, -4
sw $ra,0($sp)
add $a0, $zero, 3
jal _backTracking
north_skip_3:

jal _if_west_wall
beq $v0, 1, west_skip_3
jal _go_west
addi $sp, $sp, -4
sw $ra,0($sp)
add $a0, $zero, 2
jal _backTracking
west_skip_3:

jal _if_south_wall
beq $v0, 1, south_skip_3
jal _go_south
addi $sp, $sp, -4
sw $ra,0($sp)
add $a0, $zero, 1
jal _backTracking
south_skip_3:





jal _if_east_wall
beq $v0, 1, east_skip_3
jal _go_east
addi $sp, $sp, -4
sw $ra,0($sp)
add $a0, $zero, 4
jal _backTracking
east_skip_3:

add $a0, $a0, 2
j approach_skipper


south_approach:

jal _if_east_wall
beq $v0, 1, east_skip_4
jal _go_east
addi $sp, $sp, -4
sw $ra,0($sp)
add $a0, $zero, 4
jal _backTracking
east_skip_4:


jal _if_north_wall
beq $v0, 1, north_skip_4
jal _go_north
addi $sp, $sp, -4
sw $ra,0($sp)
add $a0, $zero, 3
jal _backTracking
north_skip_4:

jal _if_west_wall
beq $v0, 1, west_skip_4
jal _go_west
addi $sp, $sp, -4
sw $ra,0($sp)
add $a0, $zero, 2
jal _backTracking
west_skip_4:



jal _if_south_wall
beq $v0, 1, south_skip_4
jal _go_south
addi $sp, $sp, -4
sw $ra,0($sp)
add $a0, $zero, 1
jal _backTracking
south_skip_4:

add $a0, $a0, 3
j approach_skipper



approach_skipper:
#restoring your pointers
lw $ra 4($sp) 
addi $sp, $sp, 4 
#jump back out
jr $ra 



#escape the recursion if the end is reached
#base case here
break_out_of_recursion:
jr $ra

_turnAround:
add $t8, $zero, 2
add $t8, $zero, 2

jr $ra



_clear_buffer_duplicates:
#preemptively clear out all usable t registers
add $t0, $zero, $zero
add $t1, $zero, $zero
add $t2, $zero, $zero
add $t3, $zero, $zero
add $t4, $zero, $zero
add $t5, $zero, $zero
add $t6, $zero, $zero
add $t7, $zero, $zero

#preemptively clear out all usable s registers
add $s0, $zero, $zero
add $s1, $zero, $zero
add $s2, $zero, $zero
add $s3, $zero, $zero
add $s4, $zero, $zero
add $s5, $zero, $zero
add $s6, $zero, $zero
add $s7, $zero, $zero

#load direct route buffer
la $t0, direct_route_buffer

la $t2, direct_route_buffer_wo_redundancy


#increment the adress for the second buffer
add $t3, $t2, 4

#increment adress for x
add $t1, $t0, 4

#outer loop return
outer_loop_return:




#put copies of adresses into othere t registers
add $t4, $t0, $zero
add $t5, $t1, $zero

#load the byte values into
#registers $s0 and $s1 
lbu $s0, ($t0)
lbu $s1, ($t1)


#inner loop
inner_loop_return:
#escape in case of issues
beq $s0, 100, escape_1
beq $s1, 100, escape_1

#increase both by 8
add $t4, $t4, 8
add $t5, $t5, 8

#load for comparison
lbu $s2, ($t4)
lbu $s3, ($t5)

#skip in the case that the numbers do not match
bne $s2, $s0, transfer_skip
bne $s3, $s1, transfer_skip



#replace adress for $t0 and $t1
add $t0, $zero, $t4
add $t1, $zero, $t5



transfer_skip:
#if you reach the end of the buffer. Jump back up


bne $s2, 100, inner_loop_return
bne $s3, 100, inner_loop_return

#before incrementing store on the new buffer
sb $s0,($t2)
sb $s1,($t3)

#change the values of the second buffer's pointers
add $t3, $t3, 8
add $t2, $t2, 8
#change the first buffer's pointers
add $t0, $t0, 8
add $t1, $t1, 8

#check to see if you need to return
bne $s0, 100, outer_loop_return
bne $s1, 100, outer_loop_return

escape_1:
#put some terminators at the end
add $s0, $zero, 100
add $s0, $zero, 100
sb $s0,($t2)
sb $s0,($t3)

#clear out registers again
add $t0, $zero, $zero
add $t1, $zero, $zero
add $t2, $zero, $zero
add $t3, $zero, $zero
add $t4, $zero, $zero
add $t5, $zero, $zero
add $t6, $zero, $zero
add $t7, $zero, $zero

#clear out registers
add $s0, $zero, $zero
add $s1, $zero, $zero
add $s2, $zero, $zero
add $s3, $zero, $zero
add $s4, $zero, $zero
add $s5, $zero, $zero
add $s6, $zero, $zero
add $s7, $zero, $zero

jr $ra


_go_north:
#update Location
add $t8, $zero, 4
#get the direction you are facing
sll $t9, $t9, 20
srl $t9, $t9, 28
#put facing direction into $t3
add $t3, $zero, $t9

#branches to the facings
beq $t3, 8, facing_north_1
beq $t3, 4, facing_east_1
beq $t3, 2, facing_south_1
beq $t3, 1, facing_west_1

facing_north_1:
#make move forward
add $t8, $zero, 1
j go_here_12
facing_east_1:
add $t8, $zero, 2
#make move forward
add $t8, $zero, 1
j go_here_12
facing_south_1:
add $t8, $zero, 2
add $t8, $zero, 2
#make move forward
add $t8, $zero, 1
j go_here_12
facing_west_1:
add $t8, $zero, 3
#make move forward
add $t8, $zero, 1

go_here_12:
jr $ra
_go_south:

#update Location
add $t8, $zero, 4
#get the direction you are facing
sll $t9, $t9, 20
srl $t9, $t9, 28
#put facing direction into $t3
add $t3, $zero, $t9

#branches to the facings
beq $t3, 8, facing_north_2
beq $t3, 4, facing_east_2
beq $t3, 2, facing_south_2
beq $t3, 1, facing_west_2

facing_north_2:
add $t8, $zero, 2
add $t8, $zero, 2
#make move forward
add $t8, $zero, 1
j go_here_8
facing_east_2:
add $t8, $zero, 3
#make move forward
add $t8, $zero, 1
j go_here_8
facing_south_2:
#make move forward
add $t8, $zero, 1
j go_here_8
facing_west_2:
add $t8, $zero, 2
#make move forward
add $t8, $zero, 1
go_here_8:
jr $ra

_go_east:

#update Location
add $t8, $zero, 4
#get the direction you are facing
sll $t9, $t9, 20
srl $t9, $t9, 28
#put facing direction into $t3
add $t3, $zero, $t9

#branches to the facings
beq $t3, 8, facing_north_3
beq $t3, 4, facing_east_3
beq $t3, 2, facing_south_3
beq $t3, 1, facing_west_3

facing_north_3:
add $t8, $zero, 3
#make move forward
add $t8, $zero, 1
j go_here_7
facing_east_3:
#make move forward
add $t8, $zero, 1
j go_here_7
facing_south_3:
add $t8, $zero, 2
#make move forward
add $t8, $zero, 1
j go_here_7
facing_west_3:
add $t8, $zero, 2
add $t8, $zero, 2
#make move forward
add $t8, $zero, 1
go_here_7:
jr $ra

_go_west:

#update Location
add $t8, $zero, 4
#get the direction you are facing
sll $t9, $t9, 20
srl $t9, $t9, 28
#put facing direction into $t3
add $t3, $zero, $t9


#branches to the facings
beq $t3, 8, facing_north_4
beq $t3, 4, facing_east_4
beq $t3, 2, facing_south_4
beq $t3, 1, facing_west_4

facing_north_4:
add $t8, $zero, 2
#make move forward
add $t8, $zero, 1
j go_here_2
facing_east_4:
add $t8, $zero, 2
add $t8, $zero, 2
#make move forward
add $t8, $zero, 1
j go_here_2
facing_south_4:
add $t8, $zero, 3
#make move forward
add $t8, $zero, 1
j go_here_2
facing_west_4:
#make move forward
add $t8, $zero, 1
j go_here_2


go_here_2:
jr $ra












#check here for north south east and west walls
#return 1 if there is and 0 if not into v0
_if_north_wall:
#clear out v0
add $v0, $zero, $zero

#update Location
add $t8, $zero, 4
#get the direction you are facing
sll $t9, $t9, 20
srl $t9, $t9, 28
#put facing direction into $t3
add $t3, $zero, $t9
#update Location
add $t8, $zero, 4

#branches to the facings
beq $t3, 8, facing_north_402
beq $t3, 4, facing_east_402
beq $t3, 2, facing_south_402
beq $t3, 1, facing_west_402

facing_north_402:
and $t1, $t9, 8
seq $v0, $t1, 8
j a402_escaped
facing_east_402:
and $t1, $t9, 4
seq $v0, $t1, 4
j a402_escaped
facing_south_402:
and $t1, $t9, 1
seq $v0, $t1, 1
j a402_escaped
facing_west_402:
and $t1, $t9, 2
seq $v0, $t1, 2
j a402_escaped
a402_escaped:

#clear out $t1
add $t1, $zero, $zero

jr $ra

_if_south_wall:
#clear out v0
add $v0, $zero, $zero
#update Location
add $t8, $zero, 4
#get the direction you are facing
sll $t9, $t9, 20
srl $t9, $t9, 28
#put facing direction into $t3
add $t3, $zero, $t9

#update Location
add $t8, $zero, 4

#branches to the facings
beq $t3, 8, facing_north_302
beq $t3, 4, facing_east_302
beq $t3, 2, facing_south_302
beq $t3, 1, facing_west_302


facing_north_302:
and $t1, $t9, 1
seq $v0, $t1, 1
j a302_escape
facing_east_302:
and $t1, $t9, 2
seq $v0, $t1, 2
j a302_escape
facing_south_302:
and $t1, $t9, 8
seq $v0, $t1, 8
j a302_escape
facing_west_302:
and $t1, $t9, 4
seq $v0, $t1, 4
j a302_escape
a302_escape:
#clear out $t1
add $t1, $zero, $zero

jr $ra


_if_east_wall:
#clear out v0
add $v0, $zero, $zero
#update Location
add $t8, $zero, 4
#get the direction you are facing
sll $t9, $t9, 20
srl $t9, $t9, 28
#put facing direction into $t3
add $t3, $zero, $t9

#update Location
add $t8, $zero, 4

#branches to the facings
beq $t3, 8, facing_north_202
beq $t3, 4, facing_east_202
beq $t3, 2, facing_south_202
beq $t3, 1, facing_west_202

#update Location
add $t8, $zero, 4

facing_north_202:
and $t1, $t9, 2
seq $v0, $t1, 2
j a202_escape
facing_east_202:
and $t1, $t9, 8
seq $v0, $t1, 8
j a202_escape
facing_south_202:
and $t1, $t9, 4
seq $v0, $t1, 4
j a202_escape
facing_west_202:
and $t1, $t9, 1
seq $v0, $t1, 1
j a202_escape
a202_escape:
#clear out $t1
add $t1, $zero, $zero
jr $ra


_if_west_wall:
#clear out v0
add $v0, $zero, $zero
#update Location
add $t8, $zero, 4
#get the direction you are facing
sll $t9, $t9, 20
srl $t9, $t9, 28
#put facing direction into $t3
add $t3, $zero, $t9
#update Location
add $t8, $zero, 4
#branches to the facings
beq $t3, 8, facing_north_102
beq $t3, 4, facing_east_102
beq $t3, 2, facing_south_102
beq $t3, 1, facing_west_102

#update Location
add $t8, $zero, 4


facing_north_102:
and $t1, $t9, 4
seq $v0, $t1, 4
j a102_escape
facing_east_102:
and $t1, $t9, 1
seq $v0, $t1, 1
j a102_escape
facing_south_102:
and $t1, $t9, 2
seq $v0, $t1, 2
j a102_escape
facing_west_102:
and $t1, $t9, 8
seq $v0, $t1, 8
j a102_escape
a102_escape:
#clear out $t1
add $t1, $zero, $zero

jr $ra


quit:
add $v0, $zero, 10
syscall
