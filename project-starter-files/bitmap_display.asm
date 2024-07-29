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
    .eqv	GREY		0x737373
    .eqv	GRIDGREY	0xa8a8a8
    .eqv	GROUND		15360
    .eqv	SCREEN_WIDTH	16384

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
	bgt $t0, $t5, colour_with_map
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



# colour_with_map: Colours board with collision map
colour_with_map:
	lw $t0, ADDR_DSPL       # Set values for every value, note, 
				# collision_map + $t2 = collision_map[i][j] = ADDR_DSPL + 1024 * j + 16 * i 
				# = ADDR_DSPL + 1024 * ($t2) // 64 + 4 * ($t2) mod 64
	la $t1, collision_map
	addi $t2, $zero, 0
	addi $t3, $zero, 64
	add $t4, $zero, 1024
	
colour_with_map_loop:
	bge $t2, $t4, exit
	lw $t9, 0($t1)
	beq $t9, $zero, colour_with_map_loop_end
	# converting coordinates from $t2 to bitmap
	addi $t6, $zero, 4
	div $t2, $t3
	mflo $t7
	mfhi $t8
	mult $t7, $t4
	mflo $t7
	mult $t8, $t6
	mflo $t8		# convert $t2 coordinate into values usable by bitmap
	add $t8, $t7, $t8	# add values together into ADDR_DSPL to get location of next display point.
				# DO NOT ERASE $t8 UNTIL NEXT ITERATION
	add $t8, $t8, $t0	 
	
	
	
	# Variables $t5-$t8 are now free do be used as needed
	addi $t5, $zero, 0	#loop variable
	addi $t6, $zero, 16	#loop repeat
	
	
colour_with_map_loop_loop:
	bge $t5, $t3, colour_with_map_loop_end
	bge $t5, $t6, colour_with_map_loop_loop_end
	sw $t9, 0($t8)
	addi $t8, $t8, 4
	addi $t5, $t5, 4
	j colour_with_map_loop_loop
	
colour_with_map_loop_loop_end:
	addi $t6, $t6, 16
	addi $t8, $t8, 240
	j colour_with_map_loop_loop

colour_with_map_loop_end:
	addi $t2, $t2, 4
	addi $t1, $t1, 4
	j colour_with_map_loop
	
	
	

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
	la $t1, block_Location
	lw $t1, 16($t1)
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


#Basic exit for all values


exit:
    	jr $ra
