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


keyboardifying:
	addi $sp, $sp, -4
    	sw $ra, 0($sp)
	lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
	lw $t8, 0($t0)                  # Load first word from keyboard
	beq $t8, 1, keyboard_input      # If first word 1, key is pressed
	jr $ra

keyboard_input:                     # A key is pressed
	lw $a0, 4($t0)                  # Load second word from keyboard
	
	# list of possible commands and values
	
	beq $a0, 0x71, respond_to_Q     # q key: Pressing q results in game crashing

	
	
	lw $ra, 0($sp)
	jr $ra

respond_to_Q:
	li $v0, 10                      # Prepare to crash and burn
	syscall				#call sis
