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
    
    .eqv	BLUE		0x0000ff
    .eqv	GREEN		0x00ff00
    .eqv	RED		0xff0000
    .eqv	BROWN		0x737373
    .eqv	GRIDGREY	0xa8a8a8
    .eqv	GROUND		15360
    .eqv	SCREEN_WIDTH	16384
    .eqv	

    .text
	.globl colour_board
	.globl clear_board
	.globl paint_basic_tetromino_square

# Colour_board: Base method of the bitmap_display, use to create grid. "Hardcoded" but math is very easy if we need to change
colour_board:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	lw $t0, ADDR_DSPL       # $t0 = base address for display
	li $t1, GRIDGREY
	addi $t2, $zero, 16
	addi $t3, $zero, 1008	#$t3 = 1024 - $2, to shift back due to initial shift
	addi $t4, $zero, 0
	add $t5, $t0, SCREEN_WIDTH
grid_vertical:
	bgt $t0, $t5, second_layer
	bgt $t4, $t3, shift_total
grid_print:
	beq $t2, $t4, shift_local
	sw $t1, 0($t0)      # paint the first unit on the second row blue
	addi $t0, $t0, 4
	addi $t4, $t4, 4
	j grid_print
shift_local:
	addi $t0, $t0, 16
	addi $t4, $t4, 16
	addi $t2, $t2, 32	#$t2 = 2 $t4, to shift over extra
	j grid_vertical
shift_total:
	addi $t6, $zero, 0
	addi $t2, $zero, 16
	addi $t4, $zero, 0
	addi $t0, $t0, 1024
	j grid_vertical

second_layer:
	lw $t0, ADDR_DSPL
	addi $t0, $t0, 1040      # $t0 = 1024 + $t2
	li $t1, GRIDGREY
	addi $t2, $zero, 16
	addi $t3, $zero, 1008	#$t3 = 1024 - $t2
	addi $t4, $zero, 0
	add $t5, $t0, SCREEN_WIDTH
grid_vertical_2:
	bgt $t0, $t5, colour_border
	bgt $t4, $t3, shift_total_2
grid_print_2:
	beq $t2, $t4, shift_local_2
	sw $t1, 0($t0)      # paint the first unit on the second row blue
	addi $t0, $t0, 4
	addi $t4, $t4, 4
	j grid_print_2
shift_local_2:
	addi $t0, $t0, 16
	addi $t4, $t4, 16
	addi $t2, $t2, 32
	j grid_vertical_2
shift_total_2:
	addi $t6, $zero, 0
	addi $t2, $zero, 16
	addi $t4, $zero, 0
	addi $t0, $t0, 1024
	j grid_vertical_2




# colour_border, Used to colour game border, currently colours 1 pixel around edge, can change for fun


colour_border:
	lw $t0, ADDR_DSPL       # $t0 = base address for display
	li $t1, BROWN
	addi $t2, $zero, 0
	addi $t3, $zero, 16
	add $t4, $t0, GROUND
	add $t5, $t0, SCREEN_WIDTH
	addi $t6, $zero, 1024
	add $t7, $t0, $t6
	addi $t7, $t7, -4
void_background_left:
	blt $t0, $t7, floor
	bgt $t0, $t4, floor
	beq $t2, $t3, EQUALITY_left
	sw $t1, 0($t0)      # paint the first unit on the second row blue
	addi $t0, $t0, 4
	addi $t2, $t2, 4
	j void_background_left
void_background_right:
	beq $t2, $t3, EQUALITY_right
	sw $t1, 0($t0)      # paint the first unit on the second row blue
	addi $t0, $t0, 4
	addi $t2, $t2, 4
	j void_background_right
EQUALITY_left:
	addi $t2, $zero, 0
	addi $t0, $t0, 224
	j void_background_right
EQUALITY_right:
	addi $t2, $zero, 0
	j void_background_left
floor:						#print floor
	bgt $t0, $t5, exit
	bgt $t0, $t4, skip			#to skip next call so it doesn't perma loop lon
	bgt $t0, $t7, EQUALITY_right
skip:
	sw $t1, 0($t0)      # paint the first unit on the second row blue
	addi $t0, $t0, 4
	addi $t2, $t2, 4
	j floor







# Clear board before every repaint


clear_board:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	lw $t0, ADDR_DSPL       # $t0 = base address for display
	add $t1, $t0, SCREEN_WIDTH
loop:
	bgt $t0, $t1, exit
	sw $zero, 0($t0)
	addi $t0, $t0, 4
	j loop





paint_basic_tetromino_square:
	lw $t0, 0($sp)
	sw $ra, 0($sp)
			# Technically not necessary, we could just manually run this 4 times, one for each piece, but thats a lot more work
	li $t1, BLUE
	addi $t2, $zero, 0
	addi $t3, $zero, 16
	addi $t4, $zero, 64
tetro_loop:
	beq $t2, $t4, exit
	beq $t2, $t3, next_row
	sw $t1, 0($t0)
	addi $t2, $t2, 4
	addi $t0, $t0, 4
	j tetro_loop
next_row:
	addi $t0, $t0, 240	# 256 (1 row down) - 16 (1 square right)
	addi $t3, $t3, 16	# 1 / 4 square
	j tetro_loop



exit:
    	jr $ra
