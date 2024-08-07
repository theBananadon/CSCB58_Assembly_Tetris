 ##############################################################################
# Example: Keyboard Input
#
# This file demonstrates how to read the keyboard to check if the keyboard
# key q was pressed.
##############################################################################
    .data
ADDR_KBRD:
    .word 0xffff0000

    .text
	.globl keyboardifying
	.globl game_over_loop


keyboardifying:
	addi $sp, $sp, -4
    	sw $ra, 0($sp)
	lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
	lw $t8, 0($t0)                  # Load first word from keyboard
	beq $t8, 1, keyboard_input      # If first word 1, key is pressed
	jr $ra


###


keyboard_input:                     	# A key is pressed
	lw $a0, 4($t0)                  # Load second word from keyboard
	
	# list of possible commands and values
	
	beq $a0, 0x61, respond_to_A		# a key: Pressing a when game state is 1 gives us left movement
	beq $a0, 0x64, respond_to_D		# d key: Pressing d when game state is 1 gives us right movement
	beq $a0, 0x20, respond_to_SPACE		# space key: Pressing space when 
						# 		game state is 1 gives us block falling down entire way
						#		game state is 0 unpauses game
	beq $a0, 0x70, respond_to_P		# p key: pressing p whene game state is 1 pauses game
	beq $a0, 0x71, respond_to_Q     	# q key: Pressing q results in game crashing
	beq $a0, 0x73, respond_to_S		# s key: pressing s when game state is 1 gives us down movement

	beq $a0, 0x77, respond_to_W		# w key: pressing w when game state is 1 gives use rotation
	
	
	lw $ra, 0($sp)
	jr $ra

respond_to_A:
	# check collision here
	addi $sp, $sp, -8
	addi $t0, $zero, -4
	sw $t0, 0($sp)
	addi $a0, $zero, 0
	jal check_collision
	b movement_is_happening
	
respond_to_D:
	addi $sp, $sp, -8
	addi $t0, $zero, 4
	sw $t0, 0($sp)
	addi $a0, $zero, 0
	jal check_collision
	b movement_is_happening
	
respond_to_S:
	addi $sp, $sp, -8
	addi $t0, $zero, 64
	sw $t0, 0($sp)
	addi $a0, $zero, 0
	jal check_collision
	b movement_is_happening

respond_to_SPACE:

respond_to_P:
	addi $sp, $sp, -4
	jal print_pause
	lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
	lw $t8, 0($t0)                  # Load first word from keyboard
	bne $t8, 1, respond_to_P        # If first word 1, key is pressed
	lw $a0, 4($t0)
	beq $a0, 0x71, respond_to_Q	# quit if player feels like it
	beq $a0, 0x72, respond_to_R	# restart game
	bne $a0, 0x70, respond_to_P	# if letter pressed isn't P, go back to the beginning of the beginning
	j skip_gravity_return	
	
game_over_loop:
	addi $sp, $sp, -4
	jal print_game_over
	addi $sp, $sp, 4
restart_check:
	lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
	lw $t8, 0($t0)                  # Load first word from keyboard
	bne $t8, 1, restart_check       # If first word 1, key is pressed
	lw $a0, 4($t0)
	beq $a0, 0x71, respond_to_Q	# quit if player feels like it
	bne $a0, 0x72, restart_check	# if letter pressed isn't P, go back to the beginning of the beginning
	j main

respond_to_Q:
	li $v0, 10                      # Prepare to crash and burn
	syscall				#call sis

respond_to_R:
	j main
	
respond_to_W:
	# load current location into the stack
	addi $sp, $sp, 16
	lw $t2, ADDR_DSPL
	la $t0, block_Location
	lw $t1, 0($t0)
	sub $t1, $t1, $t2
	addi $s0, $t1, 0
	lw $t1, 4($t0)
	sub $t1, $t1, $t2
	addi $s1, $t1, 0
	lw $t1, 8($t0)
	sub $t1, $t1, $t2
	addi $s2, $t1, 0
	lw $t1, 12($t0)
	sub $t1, $t1, $t2
	addi $s3, $t1, 0
	
	# perform rotation calculation for each square: 
	# for coordinate (x,y) rotating over the point (a,b),
	# (x',y') = (y - b + a, a + b - x)
	# thus, all we have to do is convert from one to the other and we get the stuff.
	
	#convert block location to x and y coordinate
	jal convert_to_coordinate 
	
	addi $sp, $sp, -8
	addi $t0, $zero, 0
	sw $t0, 0($sp)
	addi $a0, $zero, 0
	jal check_collision
	b movement_is_happening


convert_to_coordinate:
	
	# get rotation coordinate, as first coordinate of block saved in 
	# block location. Note we will change order of blocks later to account
	# for rotation
	addi $t0, $s0, 0
	addi $t1, $zero, 1024
	div $t0, $t1
	mflo $t3	# set $t3 to y
	mfhi $t2	# set $t2 to 16*x
	addi $t1, $zero, 16
	div $t2, $t1
	mflo $t2	# set $t2 to x
	# coordinate of rotation stored in ($t2, $t3)
	
	# time to get (x',y') for $s1 Stored as ($t4, $t5)
	addi $t0, $s1, 0
	addi $t1, $zero, 1024
	div $t0, $t1
	mflo $t5	# set $t5 to y
	mfhi $t4	# set $t4 to 16*x
	addi $t1, $zero, 16
	div $t4, $t1
	mflo $t4	# set $t4 to x
	# (x,y) = ($t4, $t5)
	# (x',y') = (y - b + a, a + b - x)
	add $t6, $t5, $t2
	sub $t6, $t6, $t3
	add $t7, $t2, $t3
	sub $t7, $t7, $t4
	# now (x',y') = ($t6, $t7), now we convert from (x,y) to addresses
	addi $t1, $zero, 16
	mult $t1, $t6
	mflo $t6
	addi $t1, $zero, 1024
	mult $t1, $t7
	mflo $t7
	add $t0, $t6, $t7
	addi $t1, $zero, 16
	sub $t0, $t0, $t1	#$t0 shifted 16 left to account for rotating 90* clockwise
	lw $t1, ADDR_DSPL
	add $t0, $t0, $t1	# $t0 now holds the address of the rotated block.
				# we now store it in the proper location 
	la $t1, block_Location
	sw $t0, 4($t1)
	# now we just repeat for $s2 and $s3
	
	
	# location for $s2
	addi $t0, $s0, 0
	addi $t1, $zero, 1024
	div $t0, $t1
	mflo $t3	# set $t3 to y
	mfhi $t2	# set $t2 to 16*x
	addi $t1, $zero, 16
	div $t2, $t1
	mflo $t2	# set $t2 to x
	# coordinate of rotation stored in ($t2, $t3)
	
	# time to get (x',y') for $s1 Stored as ($t4, $t5)
	addi $t0, $s2, 0
	addi $t1, $zero, 1024
	div $t0, $t1
	mflo $t5	# set $t5 to y
	mfhi $t4	# set $t4 to 16*x
	addi $t1, $zero, 16
	div $t4, $t1
	mflo $t4	# set $t4 to x
	# (x,y) = ($t4, $t5)
	# (x',y') = (y - b + a, a + b - x)
	add $t6, $t5, $t2
	sub $t6, $t6, $t3
	add $t7, $t2, $t3
	sub $t7, $t7, $t4
	# now (x',y') = ($t6, $t7), now we convert from (x,y) to addresses
	addi $t1, $zero, 16
	mult $t1, $t6
	mflo $t6
	addi $t1, $zero, 1024
	mult $t1, $t7
	mflo $t7
	add $t0, $t6, $t7
	addi $t1, $zero, 16
	sub $t0, $t0, $t1	#$t0 shifted 16 left to account for rotating 90* clockwise
	lw $t1, ADDR_DSPL
	add $t0, $t0, $t1	# $t0 now holds the address of the rotated block.
				# we now store it in the proper location 
	la $t1, block_Location
	sw $t0, 8($t1)
	
	# location for $s3
	addi $t0, $s0, 0
	addi $t1, $zero, 1024
	div $t0, $t1
	mflo $t3	# set $t3 to y
	mfhi $t2	# set $t2 to 16*x
	addi $t1, $zero, 16
	div $t2, $t1
	mflo $t2	# set $t2 to x
	# coordinate of rotation stored in ($t2, $t3)
	
	# time to get (x',y') for $s1 Stored as ($t4, $t5)
	addi $t0, $s3, 0
	addi $t1, $zero, 1024
	div $t0, $t1
	mflo $t5	# set $t5 to y
	mfhi $t4	# set $t4 to 16*x
	addi $t1, $zero, 16
	div $t4, $t1
	mflo $t4	# set $t4 to x
	# (x,y) = ($t4, $t5)
	# (x',y') = (y - b + a, a + b - x)
	add $t6, $t5, $t2
	sub $t6, $t6, $t3
	add $t7, $t2, $t3
	sub $t7, $t7, $t4
	# now (x',y') = ($t6, $t7), now we convert from (x,y) to addresses
	addi $t1, $zero, 16
	mult $t1, $t6
	mflo $t6
	addi $t1, $zero, 1024
	mult $t1, $t7
	mflo $t7
	add $t0, $t6, $t7
	addi $t1, $zero, 16
	sub $t0, $t0, $t1	#$t0 shifted 16 left to account for rotating 90* clockwise
	lw $t1, ADDR_DSPL
	add $t0, $t0, $t1	# $t0 now holds the address of the rotated block.
				# we now store it in the proper location 
	la $t1, block_Location
	sw $t0, 12($t1)
	
	# finally:
	lw $t0, 0($t1)
	addi $t2, $zero, 16
	sub $t0, $t0, $t2
	sw $t0, 0($t1)
	
	# now the original block is stored in $s0-$s3 and 
	# the rotated block is stored in current location
	# thus if at any point we get some collision problem, 
	# the we revert back to $s0-$s3, else we tread onwards
	
	jr $ra


	
	
