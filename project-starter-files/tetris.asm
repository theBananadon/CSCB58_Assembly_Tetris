#####################################################################
# CSCB58 Summer 2024 Assembly Final Project - UTSC
# Student1: Name, Student Number, UTorID, official email
# Student2: Name, Student Number, UTorID, official email
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed) 
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved features have been implemented?
# (See the assignment handout for the list of features)
# Easy Features:
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# ... (add more if necessary)
# Hard Features:
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# ... (add more if necessary)
# How to play:
# (Include any instructions)
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
   
    .eqv	BLUE		0x0000ff
    .eqv	GREEN		0x00ff00
    .eqv	RED		0xff0000
    .eqv	GREY		0x737373
    .eqv	GRIDGREY	0xa8a8a8
    .eqv	GROUND		15360
    .eqv	SCREEN_WIDTH	16384

##############################################################################
# Mutable Data
##############################################################################

game_State:
	.half	0

loop_State:
	.half	0

block_Location:
	.word	0, 0, 0, 0, 0

zig_zag_1:
	.word	0, 0, 0, 0, 0
	
zig_zag_2:
	.word	0, 0, 0, 0, 0

T_cell:
	.word	0, 0, 0, 0, 0

I_am_square:
	.word	0, 0, 0, 0, 0

l_plus_ration:
	.word	0, 0, 0, 0, 0
	
J_plus_ration:
	.word	0, 0, 0, 0, 0
	
straight_edge:
	.word	0, 0, 0, 0, 0
	
	

	
collision_map:
	.word	0:1024
##############################################################################
# Code
##############################################################################
	.text
	.globl main
	.globl check_collision
	.globl movement_is_happening
	.globl block_Location
	.globl collision_map

	# Run the Tetris game.
main:
	# Time to add some variables:
	# Explaination of variables:
	#	Variable 1: Game state (short) 
	#		0: Game is paused
	#		1: Game is playing
	#	Variable 2: Loop state (short) 
	#		This is specifically for gravity or any other value that requires 
	#		implementation at a rate not equal to the game tick rate
	#	Variable 3: Block location array (int[4]) 
	#		4 integers that store the location of each block of the tetromino
	
### initialize collision map by setting border to 1

	jal initialize_collision_map
	jal initialize_blocks

###	
	
	#Testing tetromino stuff
	
	jal create_random_new_location
	
	

game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
### Triple Hashtags used in tetris.asm file to represent temporary register scope, 
	jal keyboardifying
	addi $sp, $sp, 4

###
    
    # Collision is checked in keyboard.asm
    

### Update block location based on controls

	
	
### erase current blocks location on collision map
	jal current_block_map_location
	addi $t2, $zero, 0
	addi $t3, $zero, 4
erase_loop:
	lw $t0, 0($sp)
	la $t1, collision_map
	add $t1, $t0, $t1
	lw $zero, 0($t1)
	addi $sp, $sp, 4
	addi $t2, $t2, 1
	blt $t2, $t3, erase_loop

	
	
	
	lh $t0, loop_State
	addi $t1, $zero, 1	# Loop number
	ble $t0, $t1, skip_gravity_return
	
	addi $t0, $zero, 0
	sh $t0, loop_State
### General collision check process:
#	1. Store number to objects new location in stack
#	2. Call check_collision method
#	3. If no collision took place, the program will automatically run the 
#
#

return:
	addi $sp, $sp, -8
	addi $t0, $zero, 64
	sw $t0, 0($sp)
	jal check_collision
	b movement_is_happening

skip_gravity_return:

### updating collision map

	jal clear_board
	addi $sp, $sp, 4

###
	jal colour_board
	addi $sp, $sp, 4
	
### Painting block based on its updated location
	la $t1, block_Location
	lw $t0, 0($t1)
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	jal paint_basic_tetromino_square
	addi $sp, $sp, 4
### 
	
	la $t1, block_Location
	lw $t0, 4($t1)
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	jal paint_basic_tetromino_square
	addi $sp, $sp, 4

### 
	la $t1, block_Location	
	lw $t0, 8($t1)
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	jal paint_basic_tetromino_square
	addi $sp, $sp, 4
### 
	la $t1, block_Location
	lw $t0, 12($t1)
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	jal paint_basic_tetromino_square
	addi $sp, $sp, 4
    
### Next loop state

	lh $t0, loop_State
	addi $t0, $t0, 1
	sh $t0, loop_State
	
###

	li $v0, 32
	addi $a0, $zero, 100
	syscall
	b game_loop







###

# current block map location, required to be called from other place, returns 4 integers in stack corresponding to the 4 locations in the 
# collision map that the current block is located
current_block_map_location:
	# Store location of each collision map point in stack and access from there whenever needed
	addi $t7, $zero, 0
	addi $t8, $zero, 4
	la $t1, block_Location
	lw $t2, ADDR_DSPL
current_block_map_location_loop:
	# converts address of each block into its corresponding location in the collision map
	lw $t0, 0($t1)
	sub $t0, $t0, $t2	# get raw shifted value of the block
	addi $t6, $zero, 1024
	div $t0, $t6		# get row and column through remainder
	mflo $t0
	mfhi $t3
	addi $t6, $zero, 16	# HATE, ANGER
	div $t3, $t6		# divide by 16 to get exact column
	mflo $t3
	addi $t4, $zero, 16	# multiply row value by 16
	mult $t0, $t4
	mflo $t0		
	add $t0, $t0, $t3	
	addi $t4, $zero, 4	# compensate for address being in .word
	mult $t0, $t4
	mflo $t0		# This (In theory), is the exact value in the collision map where this specific block is located
				# Now if we temp store this in stack and repeat the above process a couple more times, we get the 
				# The collision map location of every block
	addi $sp, $sp, -4	# store in stack and whatnot
	sw $t0, 0($sp)
	addi $t7, $t7, 1
	addi $t1, $t1, 4
	blt $t7, $t8, current_block_map_location_loop
	
	jr $ra
	
	

### Run gravity only if all 4 blocks below the main blcok is equal to 0
# Requires 1 input, 64 for gravity and s press, 4 for d press, -4 for w press
check_collision:
	sw $ra, 4($sp)
	jal current_block_map_location
	lw $t5, 16($sp)
	lw $t0, 0($sp)
	add $t0, $t0, $t5
	lw $t1, 4($sp)
	add $t1, $t1, $t5
	lw $t2, 8($sp)
	add $t2, $t2, $t5
	lw $t3, 12($sp)
	add $t3, $t3, $t5
	addi $sp, $sp, 16
	la $t4, collision_map
	add $t0, $t4, $t0
	lw $t0, 0($t0)
	add $t1, $t4, $t1
	lw $t1, 0($t1)
	add $t2, $t4, $t2
	lw $t2, 0($t2)
	add $t3, $t4, $t3
	lw $t3, 0($t3)
	bne $zero, $t0, check_if_stop
	bne $zero, $t1, check_if_stop
	bne $zero, $t2, check_if_stop
	bne $zero, $t3, check_if_stop
	lw $ra, 4($sp)
	lw $t0, 0($sp)
	sw $t0, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
### if check_if_stop runs, movement is automatically terminated
# this method is to check to see if the next block should be generated

check_if_stop:
	lw $t0, 0($sp)
	addi $t1, $zero, 64
	addi $sp, $sp, 8
	bne $t0, $t1, return
	jal current_block_map_location
	la $t1, block_Location
	la $t2, collision_map
	lw $t1, 16($t1)
	lw $t0, 0($sp)		# Put all the colour onto the map
	add $t0, $t0, $t2
	sw $t1, 0($t0)
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	add $t0, $t0, $t2
	sw $t1, 0($t0)
	add $sp, $sp, 4
	lw $t0, 0($sp)
	add $t0, $t0, $t2
	sw $t1, 0($t0)
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	add $t0, $t0, $t2
	sw $t1, 0($t0)
	addi $sp, $sp, 4
	
	j check_row_delete
	
### goes through every row and checks for row deletion
# if row needs to be deleted, will call row delete function with given row input
# starts checking from row 15 all the way till row 1
check_row_delete:
# create temporary variables
	la $t0, collision_map
	addi $t1, $zero, 64	
	addi $t2, $zero, 56	# max column
	addi $t3, $zero, 14	# row counting variable (stop when row = 0)
	addi $t1, $zero, 64
	mult $t3, $t1
	mflo $t4
	addi $t4, $t4, 4
	la $t0, collision_map	# set $t0 as starting position
	add $t0, $t0, $t4
	addi $t1, $zero, 0	# column counting variable
check_row_delete_loop:
	# check if any given row has any 0's in it, if not, syscall 10
	beq $t3, $zero, create_random_new_location	
	beq $t1, $t2, check_row_delete_row
	lw $t4, 0($t0)
	beq $t4, $zero, check_row_delete_loop_end
	addi $t0, $t0, 4
	addi $t1, $t1, 4
	j check_row_delete_loop

	
check_row_delete_loop_end:
	sub $t3, $t3, 1
	addi $t1, $zero, 64
	mult $t3, $t1
	mflo $t4
	addi $t4, $t4, 4
	la $t0, collision_map	# set back to prev row place 1
	add $t0, $t0, $t4
	addi $t1, $zero, 0
	j check_row_delete_loop


### section that deletes the row and shifts everything down 1, kind of similar implementation as check, except we dont check

check_row_delete_row:
	addi $sp, $sp, -4
	sw $t3, 0($sp)
	la $t0, collision_map
	addi $t1, $zero, 64	
	addi $t2, $zero, 56	# max column
	sw $t3, 0($sp)		# row counting variable (stop when row = 1
	addi $t1, $zero, 64
	mult $t3, $t1
	mflo $t4
	addi $t4, $t4, 4
	la $t0, collision_map	# set $t0 as starting position
	add $t0, $t0, $t4
	addi $t1, $zero, 0	# column counting variable
	addi $t6, $zero, 1	# min row
check_row_delete_row_loop:
	# check if any given row has any 0's in it, if not, syscall 10
	beq $t3, $t6, check_row_delete_row_end
	beq $t1, $t2, check_row_delete_row_loop_end
	sub $t4, $t0, 64	# shift up one row
	lw $t4, 0($t4)		# load the above value into same reg
	sw $t4, 0($t0)		# save that value into the row below
	addi $t0, $t0, 4
	addi $t1, $t1, 4
	j check_row_delete_row_loop

	
check_row_delete_row_loop_end:
	sub $t3, $t3, 1
	addi $t1, $zero, 64
	mult $t3, $t1
	mflo $t4
	addi $t4, $t4, 4
	la $t0, collision_map	# set back to prev row place 1
	add $t0, $t0, $t4
	addi $t1, $zero, 0
	j check_row_delete_row_loop
	
check_row_delete_row_end:
	la $t0, collision_map
	addi $t1, $zero, 64	
	addi $t2, $zero, 56	# max column
	lw $t3, 0($sp)		# current row stored in $t3
	addi $sp, $sp, 4
	addi $t1, $zero, 64
	mult $t3, $t1
	mflo $t4
	addi $t4, $t4, 4
	la $t0, collision_map	# set $t0 as starting position
	add $t0, $t0, $t4
	addi $t1, $zero, 0	# column counting variable
	j check_row_delete_loop
	
### Name is self explanitory, Can be called from anywhere actually, since its a void function
	
create_random_new_location:
	li $v0, 42
	addi $a1, $zero, 7
	syscall
	addi $a0, $zero, 5
	addi $t0, $zero, 0
	beq $a0, $t0, zig_zag_1_creater
	addi $t0, $t0, 1
	beq $a0, $t0, zig_zag_2_creater
	addi $t0, $t0, 1
	beq $a0, $t0, T_cell_creater
	addi $t0, $t0, 1
	beq $a0, $t0, l_plus_ration_creater
	addi $t0, $t0, 1
	beq $a0, $t0, J_plus_ration_creater
	addi $t0, $t0, 1
	beq $a0, $t0, I_am_square_creater
	addi $t0, $t0, 1
	beq $a0, $t0, straight_edge_creater
	
	# if we somehow end up here, terminal error has occured and it may be over, so we kill the program
	li $v0, 10
	syscall
	
### Create random new block


zig_zag_1_creater:
	la $t0, zig_zag_1
	j create_skip
zig_zag_2_creater:
	la $t0, zig_zag_2
	j create_skip
T_cell_creater:
	la $t0, T_cell
	j create_skip
I_am_square_creater:
	la $t0, I_am_square
	j create_skip
l_plus_ration_creater:
	la $t0, l_plus_ration
	j create_skip
J_plus_ration_creater:
	la $t0, J_plus_ration
	j create_skip
straight_edge_creater:
	la $t0, straight_edge
create_skip:	
	la $t1, block_Location
	lw $t2, 0($t0)
	sw $t2, 0($t1)
	lw $t2, 4($t0)
	sw $t2, 4($t1)
	lw $t2, 8($t0)
	sw $t2, 8($t1)
	lw $t2, 12($t0)
	sw $t2, 12($t1)
	lw $t2, 16($t0)
	sw $t2, 16($t1)

	j skip_gravity_return
	





movement_is_happening:
	lw $t4, 0($sp)
	addi $sp, $sp, 4
	addi $t5, $zero, 64
	beq $t4, $t5, down
	
	addi $t5, $zero, 4
	mult $t4, $t5
	mflo $t4
	j normal
down:
	addi $t5, $zero, 16
	mult $t4, $t5
	mflo $t4
	
	la $t2, block_Location
	lw $t3, 0($t2)
	add $t3, $t3, $t4
	sw $t3, 0($t2)
	
	lw $t3, 4($t2)
	add $t3, $t3, $t4
	sw $t3, 4($t2)
	
	lw $t3, 8($t2)
	add $t3, $t3, $t4
	sw $t3, 8($t2)
	
	lw $t3, 12($t2)
	add $t3, $t3, $t4
	sw $t3, 12($t2)
	
	j skip_gravity_return
	
normal:
	la $t2, block_Location
	lw $t3, 0($t2)
	add $t3, $t3, $t4
	sw $t3, 0($t2)
	
	lw $t3, 4($t2)
	add $t3, $t3, $t4
	sw $t3, 4($t2)
	
	lw $t3, 8($t2)
	add $t3, $t3, $t4
	sw $t3, 8($t2)
	
	lw $t3, 12($t2)
	add $t3, $t3, $t4
	sw $t3, 12($t2)
	
	j return
	
	
initialize_collision_map:
	la $t0, collision_map
	li $t1, GREY
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	sw $t1, 252($t0)
	sw $t1, 256($t0)
	sw $t1, 316($t0)
	sw $t1, 320($t0)
	sw $t1, 380($t0)
	sw $t1, 384($t0)
	sw $t1, 444($t0)
	sw $t1, 448($t0)
	sw $t1, 508($t0)
	sw $t1, 512($t0)
	sw $t1, 572($t0)
	sw $t1, 576($t0)
	sw $t1, 636($t0)
	sw $t1, 640($t0)
	sw $t1, 700($t0)
	sw $t1, 704($t0)
	sw $t1, 764($t0)
	sw $t1, 768($t0)
	sw $t1, 828($t0)
	sw $t1, 832($t0)
	sw $t1, 892($t0)
	sw $t1, 896($t0)
	sw $t1, 956($t0)
	sw $t1, 960($t0)
	sw $t1, 964($t0)
	sw $t1, 968($t0)
	sw $t1, 972($t0)
	sw $t1, 976($t0)
	sw $t1, 980($t0)
	sw $t1, 984($t0)
	sw $t1, 988($t0)
	sw $t1, 992($t0)
	sw $t1, 996($t0)
	sw $t1, 1000($t0)
	sw $t1, 1004($t0)
	sw $t1, 1008($t0)
	sw $t1, 1012($t0)
	sw $t1, 1016($t0)
	sw $t1, 1020($t0)
	jr $ra
	
	
initialize_blocks:

	# initialize zig zag 1
	lw $t0, ADDR_DSPL
	la $t1, zig_zag_1
	addi $t0, $t0, 1136
	sw $t0, 0($t1)
	addi $t0, $t0, 16
	sw $t0, 4($t1)
	addi $t0, $t0, 1024
	sw $t0, 8($t1)
	addi $t0, $t0, 16
	sw $t0, 12($t1)
	li $t0, BLUE
	sw $t0, 16($t1)
	
	# intialize zig zag 2
	lw $t0, ADDR_DSPL
	la $t1, zig_zag_2
	addi $t0, $t0, 1152
	sw $t0, 0($t1)
	addi $t0, $t0, 16
	sw $t0, 4($t1)
	addi $t0, $t0, 992
	sw $t0, 8($t1)
	addi $t0, $t0, 16
	sw $t0, 12($t1)
	li $t0, GREEN
	sw $t0, 16($t1)
	
	# intialize T cell
	lw $t0, ADDR_DSPL
	la $t1, T_cell
	addi $t0, $t0, 1152
	sw $t0, 0($t1)
	addi $t0, $t0, 1008
	sw $t0, 4($t1)
	addi $t0, $t0, 16
	sw $t0, 8($t1)
	addi $t0, $t0, 16
	sw $t0, 12($t1)
	li $t0, RED
	sw $t0, 16($t1)
	
	# intialize I am square
	lw $t0, ADDR_DSPL
	la $t1, I_am_square
	addi $t0, $t0, 1152
	sw $t0, 0($t1)
	addi $t0, $t0, 16
	sw $t0, 4($t1)
	addi $t0, $t0, 1008
	sw $t0, 8($t1)
	addi $t0, $t0, 16
	sw $t0, 12($t1)
	li $t0, BLUE
	sw $t0, 16($t1)
	
	# intialize l plus ration
	lw $t0, ADDR_DSPL
	la $t1, l_plus_ration
	addi $t0, $t0, 1136
	sw $t0, 0($t1)
	addi $t0, $t0, 1024
	sw $t0, 4($t1)
	addi $t0, $t0, 16
	sw $t0, 8($t1)
	addi $t0, $t0, 16
	sw $t0, 12($t1)
	li $t0, GREEN
	sw $t0, 16($t1)
	
	# intialize J plus ration
	lw $t0, ADDR_DSPL
	la $t1, J_plus_ration
	addi $t0, $t0, 1168
	sw $t0, 0($t1)
	addi $t0, $t0, 992
	sw $t0, 4($t1)
	addi $t0, $t0, 16
	sw $t0, 8($t1)
	addi $t0, $t0, 16
	sw $t0, 12($t1)
	li $t0, RED
	sw $t0, 16($t1)
	
	# intialize straight edge
	lw $t0, ADDR_DSPL
	la $t1, straight_edge
	addi $t0, $t0, 1120
	sw $t0, 0($t1)
	addi $t0, $t0, 16
	sw $t0, 4($t1)
	addi $t0, $t0, 16
	sw $t0, 8($t1)
	addi $t0, $t0, 16
	sw $t0, 12($t1)
	li $t0, BLUE
	sw $t0, 16($t1)
	
	jr $ra
