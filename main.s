	# Student: Huy Bui
	# id: hbui
	# x86-64 Connect 4

	
	.global main
	.text

	###############################
	##
	##  main function
	##
	###############################
	.type   main, @function
main:
	push    %rbp
	movq    %rsp, %rbp

	movq    $welcome, %rdi          # Welcome text
	call    printf                  # Call C function

	# ask for name
	movq    $0, %rax
	movq    $f1, %rdi
	mov     $name, %esi
	call    scanf

	# ask to go first
	call    yn

	#set up the board
	call    setup
	
	#game start
	mov	$1, %r13
	cmp	$1, user1
	je	go1st
	jmp	go2nd
go1st:
	call 	prompt		#human move
	call	comp		#computer move
	inc	%r13
	cmp	$22, %r13
	je	draw
	jmp	go1st
go2nd:
	call	comp		#computer move
	call 	prompt		#human move
	inc	%r13
	cmp	$22, %r13
	je	draw
	jmp	go2nd	

draw:
	mov	$f1, %rdi
	mov	$strdraw, %rsi
	call	printf
	# exit program
	leave
	movq    $5, %rdi
	call    exit

	###############################
	##
	##  prompt function
	##
	###############################
	.type	prompt, @function
prompt:
	push	%rbp
prprompt:	
	# print prompt	
	mov	$f4, %rdi
	mov	$pr, %rsi
	call	printf

	#get ans
	mov	$f6, %rdi
	mov	$ans, %rsi
	call	scanf
	
	#get column
	mov	ans, %ebx
	add	$-1, %ebx
	add	$35, %ebx

	#check valid column
	cmp	$7, ans
	jg	full
	cmp	$1, ans
	jl	full
	
	#check empty
checkemp:	
	cmpb	$0, board(%ebx)
	je	pout
	add	$-7, %ebx
	cmp	$0, %ebx	#check full
	jl	full
	jmp	checkemp
	
pout:	movb	$1, board(%rbx)
	jmp	done2
full:	mov	$f1, %rdi
	mov	$fstr, %rsi
	call	printf
	jmp	prprompt

done2:
	mov	%ebx, curr(,1)
	call	setup
	call	check
	cmp	$1, %rax
	je	hwin
	jmp	hnwin
hwin:
	movq	$f2, %rdi
	movq	$name, %rsi
	movq	$strhwin, %rdx
	call 	printf

	leave
	mov	$5, %rdi
	call	exit
hnwin:	
	pop	%rbp
	ret
	###############################
	##
	##  yn function
	##
	###############################
	.type   yn, @function
	#ask to go first
yn:
	push    %rbp
ynquestion:
	movq    $f2, %rdi
	movq    $name, %rsi
	movq    $ins1, %rdx
	call    printf

	# set user
	mov     $f3, %rdi
	mov     $user1, %rsi
	call    scanf
	mov     $0, %rax

	movb    user1(,1), %bl
	cmp     $0x59, %bl
	je      gofirst
	cmp     $78, %rbx
	je      gosec
	jmp     ynquestion 	#loop back
gofirst:
	mov     $0x01, %rbx
	mov     %rbx, user1(,1)
	jmp     done1
gosec:
	mov     $0x00, %rbx
	movq    %rbx, user1(,1)
	jmp     done1
done1:
	mov     $f1, %rdi
	mov     $gamestart, %rsi
	call    printf

	pop     %rbp
	ret

	###############################
	##
	##  setup function
	##
	###############################
	.type   setup, @function
setup:
	push    %rbp
	mov     $0, %r15
		
	#loop row
	
	mov	$0, %r14	# position of board var
loopcolumn:	
	mov     $0, %rbx	# square
	looprow:
	mov     $f4, %rdi
	mov     $divider, %rsi
	call    printf              # print divider

	cmpb    $0, board(%r15)
	je      emp
	jg      X1
	jl      O1
	
emp:
	mov     $f5, %rdi
	mov     sp, %sil
	call    printf              # print space
	mov     $0, %rax
	jmp     done3
X1:
	mov     $f5, %rdi
	cmp	$1, user1
	je	X2
	mov	O, %sil
	jmp	X3
X2:	
	mov     X, %sil
X3:	
	call    printf
	mov     $0, %rax
	jmp     done3
O1:
	mov     $f5, %rdi
	cmp	$1, user1
	je	O2
	mov	X, %sil
	jmp	O3
O2:	
	mov     O, %sil
O3:	
	call    printf
	mov     $0, %rax
	jmp     done3

	done3:
	add     $1, %r15
	inc     %rbx
	cmp     $7, %rbx
	jl      looprow

	#print end of row
	mov     $f4, %rdi
	mov     $divider, %rsi
	call    printf              # print divider
	mov     $0, %rax
	mov     $0, %rsi
	# \n and hline
	mov   	$n, %rdi
	call    printf
	mov     $0, %rax
	mov	$hline, %rdi
	call	printf
	mov	$0, %rax

	#inc column
	inc	%r14
	cmp	$6, %r14
	jl	loopcolumn

	mov	$f4, %rdi
	mov	$cnum, %rsi
	call	printf
	
	pop     %rbp
	ret

	
	###############################
	##
	##  comp function
	##
	###############################
	.type   comp, @function
comp:
	push    %rbp
	mov	$f1, %rdi
	mov	$cturn, %rsi
	call	printf

	#AI - win

	mov	$0, %rcx	#loop 7 times
scomp1:	
	mov	$35, %rbx
	add	%rcx, %rbx
	#check empty
checkemp2:	
	cmpb	$0, board(%ebx)
	je	pout2
	add	$-7, %ebx
	cmp	$0, %ebx	#check full
	jl	full1
	jmp	checkemp2	
pout2:	
	movb	$-1, board(%rbx)
	mov	%rbx, curr(,1)
	push	%rbx
	push	%rcx
	call	check		#check if win
	pop	%rcx
	pop	%rbx
	cmp	$1, %rax
	je	done4
	movb	$0, board(%rbx)	#return back value
full1:	
	inc	%rcx
	cmp	$7, %rcx
	jl	scomp1

	#AI - stop player

	mov	$0, %rcx	#loop 7 times
scomp2:	
	mov	$35, %rbx
	add	%rcx, %rbx
	#check empty
checkemp3:	
	cmpb	$0, board(%ebx)
	je	pout3
	add	$-7, %ebx
	cmp	$0, %ebx	#check full
	jl	full2
	jmp	checkemp3	
pout3:	
	movb	$1, board(%rbx)
	mov	%rbx, curr(,1)
	push	%rbx
	push	%rcx
	call	check		#check if win
	pop	%rcx
	pop	%rbx
	cmp	$1, %rax
	je	done5
	movb	$0, board(%rbx)	#return back value
full2:	
	inc	%rcx
	cmp	$7, %rcx
	jl	scomp2
	
	#random
scomp:
	call 	rand
	mov	$7, %rcx
	mov	$0, %rdx
	idiv	%rcx

	#get column
	mov	%edx, %ebx
	add	$35, %ebx
	
	#check empty
checkemp1:	
	cmpb	$0, board(%ebx)
	je	pout1
	add	$-7, %ebx
	cmp	$0, %ebx	#check full
	jl	scomp
	jmp	checkemp1
	
pout1:	
	movb	$-1, board(%rbx)
done4:
	mov	%rbx, curr(,1)
	call 	setup
	call	check
	cmp 	$1, %rax
	je	cwin
	jmp	cnwin
cwin:
	movq	$f2, %rdi
	movq	$strcwin, %rdx
	movq	$name, %rsi
	call	printf

	leave
	mov	$5, %rdi
	call exit
done5:
	movb	$-1, board(%rbx)
	call	setup
cnwin:	
	pop	%rbp
	ret

	###############################
	##
	##  check function
	##
	###############################
	.type	check, @function
check:
	push	%rbp
#check horizontal
	#check which row
	mov	curr, %eax
	mov	$0, %edx
	mov	$7, %ebx
	idiv	%ebx

	#set bounds
	lea	(,%rax,8), %r14
	sub	%rax, %r14
	mov	%r14, %rax
	add	$6, %rax
	mov	%rax, %r15

	#loop check
	mov	$0, %rbx	#4 times
loopcheck1:	
	mov	curr, %ecx
	sub	$3, %rcx
	add	%rbx, %rcx
	mov	$0, %rdx	#4 times
loopcheck12:	
	cmp	%r14, %rcx
	jl	lc1
	cmp	%r15, %rcx
	jg	lc1
	movb	board(%rcx), %sil
	mov	curr, %r12d
	cmpb	%sil, board(%r12)
	jne	lc1
	inc	%rdx
	inc	%rcx
	cmp	$4, %rdx
	je	end
	jmp	loopcheck12
lc1:	
	inc	%rbx
	cmp	$4, %rbx
	jl	loopcheck1

# check vertical

	#loop check
	mov	$0, %rbx	#4 times
	mov	curr, %ecx
	sub	$21, %rcx
loopcheck2:	
	mov	$0, %rdx	#4 times
loopcheck22:	
	cmp	$0, %rcx
	jl	lc2
	cmp	$41, %rcx
	jg	lc2
	movb	board(%rcx), %sil
	mov	curr, %r12d
	cmpb	%sil, board(%r12)
	jne	lc2
	inc	%rdx
	add	$7, %rcx
	cmp	$4, %rdx
	je	end
	jmp	loopcheck22
lc2:	
	inc	%rbx
	add	$7, %rcx
	cmp	$4, %rbx
	jl	loopcheck2

# check diagonal 1
	#loop check
	mov	$0, %rbx	#4 times
	mov	curr, %ecx
	sub	$24, %rcx
loopcheck3:	
	mov	$0, %rdx	#4 times
loopcheck32:	
	cmp	$0, %rcx
	jl	lc3
	cmp	$41, %rcx
	jg	lc3
	movb	board(%rcx), %sil
	mov	curr, %r12d
	cmpb	%sil, board(%r12)
	jne	lc3
	inc	%rdx
	add	$8, %rcx
	cmp	$4, %rdx
	je	end
	jmp	loopcheck32
lc3:	
	inc	%rbx
	add	$8, %rcx
	cmp	$4, %rbx
	jl	loopcheck3

	# check diagonal 2
	#loop check
	mov	$0, %rbx	#4 times
	mov	curr, %ecx
	sub	$18, %rcx
loopcheck4:	
	mov	$0, %rdx	#4 times
loopcheck42:	
	cmp	$0, %rcx
	jl	lc4
	cmp	$41, %rcx
	jg	lc4
	movb	board(%rcx), %sil
	mov	curr, %r12d
	cmpb	%sil, board(%r12)
	jne	lc4
	inc	%rdx
	add	$6, %rcx
	cmp	$4, %rdx
	je	end
	jmp	loopcheck42
lc4:	
	inc	%rbx
	add	$6, %rcx
	cmp	$4, %rbx
	jl	loopcheck4
	
	jmp 	notend
end:
	mov	$1, %rax
	jmp	endcheck
notend:
	mov	$0, %rax
endcheck:	
	pop	%rbp
	ret
	
##################################################	
	.data
welcome:
	.ascii  "Hello User!\n"
	.ascii  "This is Connect Four game.\n"
	.ascii  "Two players will take turn to drop their piece\nof X or O onto columns.\n"
	.ascii  "The first one who has a line of 4 vertical, horizontal, \nor diagonal pieces wins.\n"
	.ascii  "Have fun!\n"
	.asciz  "What is your name?\n"
ins1:
	.asciz ", do you want to go first and be X? (Y/N) "
name:
	.long 0, 0, 0, 0
user1:
	.long 0
board:
	.byte 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0
gamestart:
	.ascii  "------------------------------\n"
	.ascii  "         GAME START\n"
	.asciz  "------------------------------\n"

X:
	.byte 0x58
O:
	.byte 0x4f
sp:
	.byte 0x20
divider:
	.asciz  " | "
hline:
	.asciz	"-------------------------------\n"
cnum:
	.asciz	"   1   2   3   4   5   6   7\n"
ans:
	.long 0
pr:
	.string	"\nPlease select a column to drop piece (1-7)\n"
fstr:
	.string	"Please select a valid column\n"
cturn:
	.string	"\nComputer's Turn. Please wait . . . \n\n"
strdraw:
	.string	"It's a draw!\n"
curr:
	.long	0
strtest:
	.asciz "testing 123\n"
strcwin:
	.asciz	", you lost! Given that you are beaten\ny an AI, maybe you should stop pursuing \nur career as a programmer.\n"
strhwin:
	.asciz	", you win!\nCongratulation. You have beaten my AI.\n"
	# format
f1:
	.asciz  "%s\0\n"
f2:
	.asciz  "%s%s\n"
f3:
	.asciz  " %c\0\n"
f4:
	.asciz  "%s\0"
f5:
	.asciz  "%c\0"
f6:
	.asciz	" %d\0"
n:
	.asciz  "\n"
test:
	.string  "%d"
