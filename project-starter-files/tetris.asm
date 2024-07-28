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
	.word	0, 0, 0, 0

collision_map:
	.word	0:1024
##############################################################################
# Code
##############################################################################
	.text
	.globl main
	.globl check_collision
	.globl movement_is_happening
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

###	
	
	#Testing tetromino stuff
	
	lw $t0, ADDR_DSPL
	la $t1, block_Location
	addi $t0, $t0, 1040
	sw $t0, 0($t1)
	addi $t0, $t0, 16
	sw $t0, 4($t1)
	addi $t0, $t0, 1024
	sw $t0, 8($t1)
	addi $t0, $t0, 16
	sw $t0, 12($t1)
	
	

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
	


check_if_stop:
	j return

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
