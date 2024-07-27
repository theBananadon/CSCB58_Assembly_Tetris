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

##############################################################################
# Mutable Data
##############################################################################

game_State:
	.half	0

loop_State:
	.half	0

block_Location:
	.word	0, 0, 0, 0
##############################################################################
# Code
##############################################################################
	.text
	.globl main

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

game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    
	jal keyboardifying
	addi $sp, $sp, 4
    
    # Collision is checked in keyboard.asm
    
	jal clear_board
	addi $sp, $sp, 4
	jal colour_board
	addi $sp, $sp, 4
    
	lh $t0, loop_State
	addi $t1, $zero, 10
	bne $t0, $t1, stop_chaos
gravity_has_struck:
	li $v0, 10
	syscall
    
stop_chaos:
	addi $t0, $t0, 1
	sh $t0, loop_State
    
	li $v0, 32
	addi $a0, $zero, 100
	syscall
	b game_loop
