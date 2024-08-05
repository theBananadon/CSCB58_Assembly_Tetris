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

	
	
