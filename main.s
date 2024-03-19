####################################################################
#
#					 	   TIC TAC TOE GAME
#
####################################################################
#
# Name: Ana Oro
# Class: CISS360 - Assembly Programming
# Midterm takehome part
#
####################################################################

				.text
				.globl main


####################################################################
# 	        INITIALIZING the board to all zeros
####################################################################

initialize_board:
		la 	$t0, BOARD        		# loading the address of the board
		mul 	$a0, $a0, $a0     		# n x n board  
		addu 	$a0, $a0, $a0                     
		addu 	$a0, $a0, $a0			# a0 = 4 * a0
		addu 	$a0, $t0, $a0    		# a0 = &board[n * n]

putting_zero:
		bge 	$t0, $a0, all_zero 		# if (t0 >= a0) goto allzero
		sw 	$zero, 0($t0)      		# setting to zero
		addiu 	$t0, $t0, 4         	        # incrementing current index by 1
		j 	putting_zero

all_zero:
		# placing the 0 in the middle or closest to the middle
		move 	$t0, $s0        		# t0 = n
		li 	$t1, 2            		# t1 = 2 
		addi 	$t0, $t0, -1    		# t0 = n - 1       
		div 	$t0, $t1         		# t0 / 2
		mflo 	$t0             		# t0 = (n - 1) / 2
		move 	$t1, $t0        		# t1 = (n - 1) / 2   
		mul 	$t0, $t0, $s0    		# t0 = (n - 1) / 2 * n    
		add 	$t0, $t0, $t1    		# t0 = (n - 1) / 2 * n + (n - 1) / 2  
		add 	$t0, $t0, $t0    
		add 	$t0, $t0, $t0    		# t0 = 4 * t0
		la	$t1, BOARD        		# load the &board[0,0]  
		add 	$t0, $t1, $t0			# t0 - address where 0 to be placed 
		li 	$t1, 1				
		sw	$t1, 0($t0)         	        # check here
		jr 	$ra				# jump back to return address

####################################################################
## print_board (3x3 example)
## +-+-+-+
## | | | |
## +-+-+-+
## | | | |
## +-+-+-+
## | | | |
## +-+-+-+ 
####################################################################

print_board:
		li 	$t0, 0       			# t0 = starting row index
		la 	$t2, BOARD   			# t1 = &board[0,0]
		addiu	$sp, $sp, -4			# make space for $ra in stack
		sw 	$ra, 0($sp)			# store the point of return 
		jal 	PRINT_PLUS_MINUS
    
row_loop:
		bge 	$t0, $s0, exit_rloop 	        # if r >= n goto exit_inner 
		li 	$t1, 0        			# t2 = starting col index
		la 	$a0, PIPE      			# loading the address of '|'
		li 	$v0, 4				# printing the pipe
		syscall

col_loop:
		bge 	$t1, $s0, exit_cloop	        # if c < n goto end 
		lw 	$a0, 0($t2)			# load a0 into base address
		add 	$a0, $a0, $a0
		add 	$a0, $a0, $a0   		# a0 = 4 * a0
		la 	$t3, jump_table			# load &L into t3 
		addu 	$a0, $t3, $a0			# a0 = 4 * a0 + t3
		lw 	$a0, 0($a0)			# loading the address of L 
		jr 	$a0				# using jump table

# case 0 (0($a0)
space:
		la 	$a0, SPACE			# print pipe '|'
		j 	end_switch			# jump to end_switch
# case 1 (4($a0)
O:
		la 	$a0, comp_piece			# print comp char 'O'
		j 	end_switch			# jump to end_switch
# case 2 (8($a0)
X:
		la 	$a0, player_piece		# print player char 'X'
		j 	end_switch			# jump to end_switch

end_switch:    
		li 	$v0, 4				# print case 
		syscall
		la 	$a0, PIPE			# print pipe '|'
		li 	$v0, 4					
		syscall
		addiu 	$t2, $t2, 4 			# move to the next element 
		addi 	$t1, $t1, 1			# col index counter (c++)
		j 	col_loop			# jump to col_loop

exit_cloop:
		la 	$a0, NEWLINE			# print newline
		li 	$v0, 4
		syscall
		jal 	PRINT_PLUS_MINUS   		# print plusminus bar after each row
 		addi 	$t0, $t0, 1    			# row index counter (r++)
		j 	row_loop			# goto row_loop

exit_rloop:
		lw 	$ra, 0($sp)			# restore the point of return 
		addiu	$sp, $sp, 4			# give back 4 bytes to stack
		jr 	$ra				# jump to $ra

######################################################################
#    				print PLUS-MINUS bar (+-+-+-+)
######################################################################

PRINT_PLUS_MINUS:   
		li 	$t4, 0				# t4 - i counter starts at 0

plus_minus_loop:
		bge 	$t4, $s0, end_loop		# if i >= n goto end_loop
		la 	$a0, PLUSMINUS			# load &PLUSMINUS char
		li 	$v0, 4				# print "+-"
		syscall	
		addi 	$t4, $t4, 1			# (i++)
		j 	plus_minus_loop			# jump to plus_minus_loop

end_loop:
		la 	$a0, PLUS			# when i >= n, print last '+'
		li 	$v0, 4					
		syscall
		la 	$a0, NEWLINE			# print newline (end of bar)
		li 	$v0, 4
		syscall
		jr 	$ra				# jump back to point of return

######################################################################
# 				functipns to print string and read int
######################################################################

print_string:
		li 	$v0, 4				# syscall for printing string
		syscall
		jr 	$ra

read_int:
		li 	$v0, 5				# syscall for read int from keyboard
		syscall
		jr 	$ra

######################################################################
#       function place_piece (places piece on the board)
######################################################################

place_piece:
		mul 	$a0, $a0, $s0     		# a0 = row * n
		add 	$a0, $a0, $a1     		# a0 = row * n + col (piece position)
		add 	$a0, $a0, $a0     
		add 	$a0, $a0, $a0     		# a0 = 4 * a0 
		la 	$t1, BOARD		  	# load the &board into t1
		add 	$t1, $t1, $a0	  		# t1 - &board[piece position]
		la 	$t0, turn 		 	# t0 - &turn (this address holds the value 1 or 2)
		lw 	$t0, 0($t0)		  	# load piece at &t0
		sw 	$t0, 0($t1)		  	# store piece into &board[piece position]
		li 	$t1, 1			  	# used for comparison later
		beq 	$t1, $t0, player_turn           # if (turn == 1) switch turn to player
		la 	$t0, turn		  	# load &turn into t0 again
		sw 	$t1, 0($t0)       		# switch to turn == 1 - comp turn
		j 	piece_placed

player_turn:
		li	$t1, 2			        # case 2 is player piece 'X'
		la 	$t0, turn		  	# load &turn into t0
		sw 	$t1, 0($t0)  	  		# store 2 into turn -player's turn)

piece_placed:
		jr 	$ra

#######################################################################
#		check if winnging colum
#######################################################################

check_if_winning_column:
		li 	$t1,0				# row counter = 0
rowLoop:
		beq 	$t1,$s0, columns_checked	# r == n goto columns_checked
		la 	$t0,BOARD			# load &board into t0
		move 	$t5,$t1				# store t1 in t5
		add 	$t5, $t5, $t5	
		add 	$t5, $t5, $t5			# t5 = 4 * t1
		add 	$t0, $t0, $t5			# t0 = &board + 4 * r
		lw 	$t2, 0($t0)			# load t2 into t0 address
		li 	$t4, -1					
		beq 	$t2, $zero, column_winner_move	# if t2 == 0 goto cwmove
		mul 	$t3, $s0, $s0     		# t3 = n *  n
		add 	$t3, $t3, $t3			
		add 	$t3, $t3, $t3     		# t3 = 4 * n * n
		la 	$t6, BOARD		        # load &board into t6
		add 	$t3, $t3, $t6		        # t3 = base address of board + 4 * n * n
    
c_elements_loop:
     	        bge 	$t0, $t3,column_winner_move	
	        lw 	$t4, 0($t0)
	        bne 	$t4, $t2, column_winner_move
	        add 	$t5, $s0, $s0
	        add 	$t5, $t5, $t5
	        add 	$t0, $t0, $t5 			# jump to next row
	        j 	c_elements_loop

column_winner_move:   
		beq 	$t4, $t2, WINNER_COLUMN	        # if t4 == t2 goto WINNER_COLUMN
		j 	winner_column

WINNER_COLUMN:
                move 	$s1, $t4			# store winning column move s1
                j 	columns_checked			# checked all columns
    
winner_column:
		addi 	$t1, $t1, 1			# increment the row counter(r++)
		j 	rowLoop				# jump back to rowLoop

columns_checked:
		jr 	$ra

#######################################################################
#		 check_if_winning_row
#######################################################################
check_if_winning_row:
		li 	$t1, 0				# column counter = 0

column_loop:
		beq 	$t1, $s0, rows_checked	        # if c == n goto endloop
		la 	$t0, BOARD			# load &board into t0
		mul 	$t3, $t1, $s0			# t3 = c * n
		add 	$t3, $t3, $t3
		add 	$t3, $t3, $t3			# t3 = c * n * 4
		add 	$t0, $t0, $t3			# t0 = &board at [c*n*4]
		lw 	$t2, 0($t0)			# load t2 into &board[c*n*4]
		li 	$t4, -1					 
		beq 	$t2, $zero, row_winner_move     # if t2 == 0 goto rowwinnermove
		mul 	$t6, $s0, 4       		# t6 = 4 * n
		add 	$t6, $t0, $t6     		# t6 = &board + 4 * n (last element in row)

r_elements_loop:
		bge 	$t0, $t6, row_winner_move       # if (current_elem >= last_elem goto rwmove)
		lw 	$t4, 0($t0)	                # load t4 into current element
		bne 	$t4, $t2, row_winner_move       # if t4 != t2 goto rwmove
		addi 	$t0, $t0, 4		        # move to the next element on board
		j 	r_elements_loop		        # jump back to loop9

row_winner_move:
		beq 	$t4, $t2, WINNER_ROW            # if t4 == t2 goto winner_found2		
		j 	increment

WINNER_ROW:					   
		move 	$s1, $t4			# store row winner move in s1
		j 	rows_checked		        # jump to end the check

increment:
		addi 	$t1, $t1, 1			# increment the column counter
		j 	column_loop

rows_checked:
		jr 	$ra
			
#######################################################################
# 	check if topleft-bottomright winning diagonal
#######################################################################

check_first_diag:
		li 	$t0, 0				# set counter to 0
		la 	$t1, BOARD			# load &board into t1
		lw 	$t2, 0($t1)			# load t2 onto 0(&board)
		li 	$t4, -1					 
		beq 	$t2, $zero, diag1_checked	# if t2 == 0 goto diag1_checked
	    
diag1_check:
	        bge 	$t0, $s0, diag1_checked	        # if i >= n diag1_checked
	        lw 	$t4, 0($t1)			# load t4 in 0(&board)
	        bne 	$t4, $t2, diag1_checked	        # if t4 != t2 diag1_checked
		add 	$t3, $s0, $s0			# t3 = n x n
	        add 	$t3, $t3, $t3			
	        addi	$t3, $t3, 4				
	        add 	$t1, $t1, $t3			# t1 =	board + 4 * n x n
		addi 	$t0, $t0, 1			# i++
	        j 	diag1_check			# jump to diag_check loop
    
diag1_checked:   
		beq 	$t4, $t2, WINNER_DIAG1	        # if t4 == t2 winner is found
		j 	winner_diag1
    
WINNER_DIAG1:
                move 	$s1, $t4			# winning diag move stored in s1
    
winner_diag1:
		jr 	$ra 				# return 

#######################################################################
# 		check if topright - bottomleft winning diagonal
#######################################################################

check_second_diag:
		li	$t0, 0				# loop counter i = 0
		la 	$t1, BOARD			# load &board in t1
		add 	$t2, $s0, $s0			# t2 = n x n
		add 	$t2, $t2, $t2			
		addi	$t2, $t2, -4			
		add 	$t1, $t1, $t2		
		lw 	$t2, 0($t1)			# load t2 into current position on the board
		li 	$t4, -1
		beq 	$t2, $zero, diag2_checked	# if t2 == 0 diag2_checked

diag2_check:
      	        bge 	$t0, $s0, diag2_checked	        # if i >= n, diag2 is checked
	        lw 	$t4, 0($t1)			# load t4 into base address of t1
	        bne 	$t4, $t2, diag2_checked         # if t4 == t2, diag2 is checked
	        add 	$t5, $s0, $s0			# t5 = n x n
	        add 	$t5, $t5, $t5			
	        addi 	$t5, $t5, -4
	        add 	$t1, $t1, $t5			# t1 - &board + 2 * n x n - 4
	        addi 	$t0, $t0, 1			# i++
	        j 	diag2_check			# jump back to diag2 check loop

diag2_checked:   
		beq 	$t4, $t2, WINNER_DIAG2	        # if t4 == t2, we have winning diag2 move
		j 	winner_diag2					

WINNER_DIAG2:
                move 	$s1, $t4			# winner diag2 move stored in s1
    
winner_diag2:
		jr 	$ra				# jump back to return point
		
#######################################################################
#  	   check_if_it's_draw (board filled but no winner)
#######################################################################

check_draw:
		la 	$t0, BOARD			# load &board into t0
		li 	$t1, 0					
		mul 	$t2, $s0, $s0			# t2 = n x n

board_loop:
		beq 	$t1, $t2, end_board_loop        # if t1 == n x n 
		lw 	$t3, 0($t0)			# current element
		bne 	$t3, $zero, checknext           # if there is empty element, break
		jr	$ra						
		
checknext:
		addi 	$t0, $t0, 4
		addi 	$t1, $t1, 1
		j 	board_loop

end_board_loop:						# board is full
		li 	$s1, 0				# case0 - it's a draw
		jr 	$ra

#######################################################################
# 					check if there is winner move
#######################################################################

check_winner:
		sw 	$ra, 0($sp)			# store point of return in stack
		li 	$t5, -1				# sentinel value
		jal 	check_if_winning_row	        # checks if the player can make winning row
		bne 	$s1, $t5, END_CHECK		# if s1 != -1 END CHECK
		jal 	check_if_winning_column         # checks if the player can make the winnin col
		bne 	$s1, $t5, END_CHECK		# if s1 != -1 END CHECK
		jal 	check_first_diag		# checks if the player can make winning diag1
		bne 	$s1, $t5, END_CHECK		# if s1 != -1 END CHECK
		jal 	check_second_diag		# checks if the player can make winning diag2
		bne 	$s1, $t5, END_CHECK		# if s1 != -1 END CHECK
		jal 	check_draw			# check if there is a draw
		bne 	$s1, $t5, END_CHECK		# if s1 != -1 END CHECK
 
END_CHECK:
		lw 	$ra, 0($sp)			# give back 4 bytes to the stack
		j 	$ra

#######################################################################
#			 computer_move
# 	finds the move and set $a0, and $a1 to row and col, 
#	 $a0 has a value in it which indicates the turn
#######################################################################

computer_move:
		move	$s2, $ra			# store $ra in s2
#######################################################################
#				look for row winner first
#######################################################################

		li 	$t0, 0				# counter is set to 0
		la 	$t1, BOARD			# t1 holds the base &board
		mul 	$t3, $s0, $s0			# t3 = n x n
BLOCK_ROW:
		beq 	$t0, $t3, checked		# if i >= n x n, 
		lw 	$t2, 0($t1)			# load t2 into &board
		bne 	$t2, $zero, CHECK_NEXT	        # if t2 != 0
		sw 	$a0, 0($t1)			# store turn into &board
		move 	$s4, $t0			# store t0 - 0
		move 	$s5, $t1			# store t1 - &board
		move 	$s6, $t2			# store t2 - 0[&board]
		move 	$s7, $t3			# store t3 - n x n
		jal 	check_if_winning_row	        # check if winning row
		move 	$t0, $s4			# restore t- registers back
		move 	$t1, $s5
		move 	$t2, $s6
		move 	$t3, $s7
		beq 	$s1, $a0, WIN_MOVE_FOUND        # if s1 == 1 win move found 
		sw 	$zero, 0($t1)			# store 0 in 0[&board]
		j	CHECK_NEXT2

WIN_MOVE_FOUND:
     	        sw 	$zero, 0($t1)			
	        div 	$t0, $s0			# t0 / n
	        mflo 	$a0				# row
	        mfhi 	$a1				# column
		move	$ra, $s2			# restore point of return 
		jr	$ra

CHECK_NEXT2:
CHECK_NEXT:
		addi 	$t1, $t1, 4			# move to the next element
		addi 	$t0, $t0, 1			# i++
		j 	BLOCK_ROW

checked:

#######################################################################
#			look for column winner next
#######################################################################

		li 	$t0, 0				# counter set to 0
BLOCK_COL:
		beq 	$t0, $s0, checked2
		li 	$t1, 0
		la 	$t2, BOARD
		add 	$t3, $t0, $t0
		add 	$t3, $t3, $t3
		add 	$t2, $t2, $t3

Block_col:
       	        beq 	$t1, $s0, checkedc		
	        lw 	$t4, 0($t2)
	        bne 	$t4, $zero, CHECK_NEXTC
	        sw 	$a0, 0($t2)
	        move 	$s4, $t0
	        move 	$s5, $t1
	        move 	$s6, $t2
	        move 	$s7, $t3
	        jal 	check_if_winning_column
	        move 	$t0, $s4
	        move 	$t1, $s5
	        move 	$t2, $s6
	        move 	$t3, $s7
	        beq 	$s1, $a0, WIN_MOVE_FOUND2
	        sw 	$zero, 0($t2)
	        j	ENDIF11

WIN_MOVE_FOUND2:
      	        sw 	$zero, 0($t2)
	        move 	$a0, $t1
	        move 	$a1, $t0
	        jr 	$s2
	        
ENDIF11: 
CHECK_NEXTC:
       	        addi 	$t1, $t1, 1			# increment the counter
	        add 	$t4, $s0, $s0
	        add 	$t4, $t4, $t4
	        add 	$t2, $t2, $t4
	        j 	Block_col
	    
checkedc:
		addi 	$t0, $t0, 1
		j 	BLOCK_COL

checked2:

#######################################################################
#  		check for winning diag1 next
#######################################################################
	
		li 	$t0, 0
		la 	$t1, BOARD

BLOCK_DIAG1:
		beq 	$t0, $s0, checkedd1
		lw 	$t2, 0($t1)
		bne 	$t2, $zero, CHECK_NEXTd1
		sw 	$a0, 0($t1)
		move 	$s3, $t0
		move 	$s4, $t1
		jal 	check_first_diag
		move 	$t0, $s3
		move 	$t1, $s4
		sw 	$zero, 0($t1)
		beq 	$s1, $a0, WIN_MOVE_FOUND3
		j 	CHECK_NEXT_d1					
	
WIN_MOVE_FOUND3:
		move 	$a0, $t0
		move 	$a1, $a0
		jr 	$s2
    
CHECK_NEXT_d1:
CHECK_NEXTd1:
		add 	$t3, $s0, $s0
		add 	$t3, $t3, $t3
		add 	$t1, $t1, $t3
		addi	$t1, $t1, 4
		addi	$t0, $t0, 1
		j 	BLOCK_DIAG1

checkedd1:

#######################################################################
#              chek for winning diag2 next
#######################################################################

		li 	$t0, 0
		la 	$t1, BOARD
		addi	$t2, $s0, -1
		add 	$t2, $t2, $t2
		add 	$t2, $t2, $t2
		add 	$t1, $t1, $t2			

BLOCK_DIAG2:
		beq 	$t0, $s0, checkedd2
		lw 	$t3, 0($t1)
		bne 	$t3, $zero, CHECK_NEXTd2
		sw	$a0, 0($t1)
		move	$s3, $t0
		move	$s4, $t1
		move	$s5, $t2
		jal 	check_second_diag
		move 	$t0, $s3
		move 	$t1, $s4
		move 	$t2, $s5
		sw	$zero, 0($t1)
		beq 	$s1, $a0, WIN_MOVE_FOUND4
		j 	CHECK_NEXTD2

WIN_MOVE_FOUND4:
		move 	$a0, $t0
		addi 	$a1, $s0, -1   
		sub 	$a1, $a1, $a0
		jr 	$s2
	
CHECK_NEXTD2:								
CHECK_NEXTd2:
		addi 	$t0, $t0, 1
		add 	$t1, $t1, $t2
		j 	BLOCK_DIAG2

checkedd2:
		jr 	$s2

#######################################################################
# 		finds the first empty move
#######################################################################

sequential_move:
		li 	$t0, 0				# counter set to 0
		la 	$t1, BOARD			# t1- base address of the board
		mul 	$t3, $s0, $s0			# t3 = n x n
find_sequential_move:
		beq 	$t0, $t3, MOVE_NOT_FOUND        # loops from i = 0 to n x n
		lw 	$t2, 0($t1)			# load t2 into &board
		beq 	$t2, $zero, MOVE_FOUND          # if current element == 0, empty move found
		j 	NEXT_CHECK					

MOVE_FOUND:
		div 	$t0, $s0  			# i / n
		mflo 	$a0				# a0 = i / n
		mfhi 	$a1				# a1 = i % n
		jr 	$ra                		# return 

NEXT_CHECK:
		addi 	$t1, $t1, 4			# move to the next element
		addi 	$t0, $t0, 1			# increment the counter i++
		j 	find_sequential_move

MOVE_NOT_FOUND:
		jr 	$ra

#######################################################################
# 			MAIN:
#######################################################################

main:
		la 	$a0, greeting          	        # loads the address of the opening message
		jal	print_string          	        # prints the string  
		la 	$a0, askfor_n		 	# prompts the input for n
		jal 	print_string		  	# prints the string
		jal 	read_int              	        # reads the int input      
		move 	$s0, $v0             	        # s0 = n
		move 	$a0, $v0             	        # a0 = n


		jal	initialize_board	  	# function call to initialize the board 
	    
		la 	$a0, comp_first	      	        # prints the message before computer puts O in the middle
		jal	print_string
		li 	$s1, -1          	  	# sentinel value for winner 
		li 	$s3, 0                 	        # bool computer_turn
		jal 	print_board           	        # prints the board      

WHILE_NOT_SENTINEL:
		li 	$t0, -1				# sentinel value is -1
		bne 	$t0, $s1, PRINT_RESULT		# if t0 != -1 print result
		la 	$t0, turn_case			# load &turn_case into t0
		la 	$t1, turn			# load &turn into t1 
		lw 	$t1, 0($t1)			# load value (0, 1 or 2) into &t1
		add 	$t1, $t1, $t1			
		add 	$t1, $t1, $t1			# t1 = t1 * 4
		add 	$t0, $t0, $t1			# t0 = t1 * 4 + t0 - address of turn_case
		lw 	$t0, 0($t0)			# load value in turn_case
		jr 	$t0				# jump table (zero_case, comp_turn or player_turn)

zero_case:						# blank case

comp_turn_case:		
		li 	$a0, 1				# computer's turn
		jal 	computer_move			# generate computer move
		li 	$t0, -1					
		bne 	$s1, $t0, move_found	        # if s1 != -1 no winning moves
		li 	$a0, 2				# 2 - player turn 
		jal 	computer_move			# checks if the player has possible winning moves
		li 	$t0, -1
		bne 	$s1, $t0, move_found	        # if s1 != -1 means computer needs to block player
		jal 	sequential_move			# find the sequential_move starting from row
move_found:
		li 	$s1, -1
		j 	make_move

player_turn_case:
		la 	$a0, enter_row		        # prompts the user for row
		jal 	print_string

		jal 	read_int			# accepts row from keyboard
		move 	$a2, $v0                        # a2 = input_row  

		la 	$a0, enter_col		        # prompts the user for column
		jal 	print_string			

		jal 	read_int                        # accepts column from keyboard
		move	$a1, $v0                        # a1 = input_col
		move 	$a0, $a2                        # a0 = input_row    

make_move:		
		jal 	place_piece			# places a piece on the board
		jal 	print_board                     # prints the board
		jal 	check_winner		        # checks if there is a winner
		j 	WHILE_NOT_SENTINEL

PRINT_RESULT:
		add 	$s1, $s1, $s1			
		add 	$s1, $s1, $s1		        # s1 = s1 * 4
		la 	$t1, RESULT		        # load &RESULT into t1
		add 	$t1, $t1, $s1		        # use jump table
		lw 	$t1, 0($t1)			# load result_case into t1
		jr 	$t1				# jump to result_case

DRAW:
		la 	$a0, its_DRAW		        # result case when it's draw
		j	EXIT_PROGRAM

WIN:
		la 	$a0, comp_WINS		        # result case when computer wins
		j 	EXIT_PROGRAM

LOSE:
		la 	$a0, player_WINS	        # result case when player wins
		j 	EXIT_PROGRAM

EXIT_PROGRAM:
		jal 	print_string
		li 	$v0, 10                         # EXIT syscall
		syscall
		
#######################################################################
#			data segment    
#######################################################################
				.data

greeting: .asciiz	 "		  	LET'S PLAY TicTacToe \n\n"
askfor_n: .asciiz	 "Enter n (size of the board): "

comp_first: .asciiz	 "\nI'll go first.\n\n"
enter_row: .asciiz	 "\nEnter row: "
enter_col: .asciiz	 "Enter col: "

SPACE: .asciiz " "

player_piece: .asciiz "X"
comp_piece: .asciiz	 "O"

turn: .word 2
turn_case: .word zero_case comp_turn_case player_turn_case

NEWLINE: .asciiz "\n"
PLUS: .asciiz "+"
MINUS: .asciiz "-"
PLUSMINUS: .asciiz "+-"
PIPE: .asciiz "|"

its_DRAW: .asciiz	 "We have a draw."
comp_WINS: .asciiz		 "I'm the winner!"
player_WINS: .asciiz	 "You are the winner!"

jump_table: .word space O X

RESULT: .word DRAW WIN LOSE

BOARD: .word 0
