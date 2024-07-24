##############################################################################
# Example: Displaying Pixels
#
# This file demonstrates how to draw pixels with different colours to the
# bitmap display.
##############################################################################

######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################
    .data
ADDR_DSPL:
    .word 0x10008000
    
    .eqv	BLUE	0x0000ff
    .eqv	GREEN	0x00ff00
    .eqv	RED	0xff0000
    .eqv	BROWN	0xbca89f
    .eqv	GREY	0xcccccc
    .eqv	GROUND		3584
    .eqv	SCREEN_WIDTH	4096
    .eqv	

    .text
	.globl initialize_border
	.globl initialize_grid
    
# Next section is dedicated to initializing border of game, 
# uses only temp registers and has no return value
initialize_border:
	lw $t0, ADDR_DSPL       # $t0 = base address for display
	li $t1, BROWN
	addi $t2, $zero, 0
	addi $t3, $zero, 16
	add $t4, $t0, GROUND
	add $t5, $t0, SCREEN_WIDTH

void_background_left:
	bgt $t0, $t4, void_background_right
	beq $t2, $t3, EQUALITY_left
	sw $t1, 0($t0)      # paint the first unit on the second row blue
	addi $t0, $t0, 4
	addi $t2, $t2, 4
	j void_background_left
void_background_right:
	bgt $t0, $t5, exit
	beq $t2, $t3, EQUALITY_right
	sw $t1, 0($t0)      # paint the first unit on the second row blue
	addi $t0, $t0, 4
	addi $t2, $t2, 4
	j void_background_right
EQUALITY_left:
	addi $t2, $zero, 0
	add $t0, $t0, $t3
	add $t0, $t0, $t3
	add $t0, $t0, $t3
	add $t0, $t0, $t3
	add $t0, $t0, $t3
	add $t0, $t0, $t3
	j void_background_right
EQUALITY_right:
	addi $t2, $zero, 0
	j void_background_left
	
# Next section dedicated to Initializing grid layout
initialize_grid:
	lw $t0, ADDR_DSPL       # $t0 = base address for display
	li $t1, GREY
	addi $t2, $zero, 0
	addi $t3, $zero, 128
	addi $t0, $t0, 512
	addi $t4, $t0, SCREEN_WIDTH
grid_horizontal:
	bgt $t0, $t4, exit
	bge $t2, $t3, next_grid_line_horizontal
	lw $t5, 128($t0)
	beq $t5, $zero, not_valid_location
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	addi $t2, $t2, 4
	j grid_horizontal
not_valid_location:
	addi $t0, $t0, 4
	addi $t2, $t2, 4
	j grid_horizontal
	
	
next_grid_line_horizontal:
	addi $t2, $zero, 0
	addi $t0, $t0, 512
	j grid_horizontal

exit:
    jr $ra
