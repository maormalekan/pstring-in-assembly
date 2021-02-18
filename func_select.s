# 321202962 Maor Malekan

	.data #data section contains global variables

	.section	.rodata			#read only data section
invalid_option:	.string "invalid option!\n"		#for invalid input
# the format we print when opt = 50||60
format_50_60:	.string	"first pstring length: %hhu, second pstring length: %hhu\n"
# the format we print when opt = 52
format_52:	.string	"old char: %c, new char: %c, first string: %s, second string: %s\n" 
# the format we print when opt = 53||54 - these otions have the same format string
format_53_54:	.string	"length: %d, string: %s\n"
# the format we print when opt = 55
format_55:	.string	"compare result: %d\n"

format_scan_char:	.string	" %c"	# format to scan char
format_scan_index:	.string	" %hhu"	# format to scan unsigned index


.align 8 # Align address to multiple of 8
.JMP_TBL:			# jump table
    .quad .OPT_50_60		# Case opt == 50
    .quad .INVALID_OPT		# Case opt == 51 - invalid option
    .quad .OPT_52 			# Case opt == 52
    .quad .OPT_53			# Case opt == 53
    .quad .OPT_54			# Case opt == 54
    .quad .OPT_55			# Case opt == 55
    .quad .INVALID_OPT		# Case opt == 56 - invalid option
    .quad .INVALID_OPT		# Case opt == 57 - invalid option
    .quad .INVALID_OPT		# Case opt == 58 - invalid option
    .quad .INVALID_OPT		# Case opt == 59 - invalid option
    .quad .OPT_50_60		# Case opt == 60

	########
	.text	#the beginnig of the code

.globl	run_func
	.type	run_func, @function	# the label "run_func" representing the beginning of a function
run_func:
	pushq	%rbp		#save the old frame pointer
	movq	%rsp, %rbp	#create the new frame pointer

    pushq   %rdx		# save pstr2 on the stack
    pushq   %rsi		# save pstr1 on the stack

	leaq -50(%rdi),%rdi		#Compute opt = opt-50
	cmpq $10, %rdi 			# Compare opt:10
	ja .INVALID_OPT 		# if opt > 60, it is invalid input
	jmp *.JMP_TBL(,%rdi,8) # Goto ja[opt]

# Case opt == 50||60
.OPT_50_60:
    # allocate place in the stack. we allocate 16 bytes because the stack need to be alligned to 16 before calling printf/scanf.
    sub 	$16, %rsp

    movq    -16(%rbp), %rdi		# we move the address of pstr1 to %rdi 		
    xorq    %rax, %rax		# reset %rax
    call    pstrlen
    movq	%rax, -32(%rbp) 	# save the return value (the length of pstr1.str) in the stack

    movq    -8(%rbp), %rdi		# we move the address of pstr2 to %rdi
    call    pstrlen
    movq	%rax, -31(%rbp)		# save the return value (the length of pstr2.str) in the stack

    #print the lengths
    movq    $format_50_60, %rdi		# move the format string to the first argumnet of printf
    movzbq	-32(%rbp), %rsi			# move the length of pstr1.str to the second argument
    movzbq	-31(%rbp), %rdx			# move the length of pstr2.str to the third argument
    xorq    %rax, %rax      		# we need to reset %rax before call printf.
    call    printf

    jmp .END_RUN

.OPT_52:
    # allocate place in the stack. we allocate 32 bytes because the stack need to be alligned to 16 before calling printf/scanf.
    sub		$32, %rsp		# allocate place in the stack for the chars we will get.
    
    movq	$format_scan_char, %rdi		# move the format scan of char to the first argument of scanf
    # move the place that we allocated on the stack to the second argument of scanf
    # the char that will scan will be in this place 
    leaq	-32(%rbp), %rsi			
    xorq    %rax, %rax      		# we need to reset %rax before call sacnf.
    call    scanf
    
    movq	$format_scan_char, %rdi		# move the format scan of char to the first argument of scanf
    # move the place that we allocated on the stack to the second argument of scanf
    # the char that we will scan will be in this place
    leaq	-31(%rbp), %rsi
    xorq    %rax, %rax      		# we need to reset %rax before call sacnf.
    call    scanf
    
    # reset registers before using them because we change their first byte
    xorq    %rsi, %rsi
    xorq    %rdx, %rdx
    # call replaceChar - first time
    movq	-16(%rbp), %rdi			# move pstr1 to the first argument of replaceChar		 
    movb    -32(%rbp), %sil 		# move the old char to the second argument
    movb    -31(%rbp), %dl			# move the new char to the third argument
    call    replaceChar

    movq	%rax, -48(%rbp)			# save the return value (new pstr1) in the stack 
    
    # reset registers before using them because we change their first byte
    xorq    %rsi, %rsi
    xorq    %rdx, %rdx
    # call replaceChar - second time
    movq    -8(%rbp), %rdi			# move pstr2 to the first argument of replaceChar
    movb    -32(%rbp), %sil			# move the old char to the second argument
    movb    -31(%rbp), %dl			# move the new char to the third argument
    call    replaceChar
    # the return value (new pstr1) is in %r10 
            
    # reset registers before using them
    xorq    %rsi, %rsi
    xorq    %rdx, %rdx
    movq    $format_52, %rdi	# move the format string of this case the first argument of printf	
    movb    -32(%rbp), %sil		# move the old char to first byte of the second argument of printf
    movb    -31(%rbp), %dl		# move the new char to first byte of the third argument of printf
    movq    -48(%rbp), %rcx		# move the new pstr1 to the fifth argumnet of printf
    incq	%rcx				# %rcx saves the address to pstr1 we increase this address by 1 to reach pstr1.str
    leaq    1(%rax), %r8		# move the new pstr2.str to the sixth argumnet of printf
    xorq    %rax, %rax      	# we need to reset %rax before call printf.
    call    printf

    jmp .END_RUN
		
.OPT_53:
    # allocate place in the stack. we allocate 16 bytes because the stack need to be alligned to 16 before calling printf/scanf.
    sub		$16, %rsp		# allocate place in the stack for the indexes we will get
    
    movq	$format_scan_index, %rdi		# move the format scan of int to the first argument of scanf
    # move the place that we allocated on the stack to the second argument of scanf
    # the index will be in this place 
    leaq	-32(%rbp), %rsi			
    xorq    %rax, %rax      		# we need to reset %rax before call sacnf.
    call    scanf
    
    movq	$format_scan_index, %rdi		# move the format scan of int to the first argument of scanf
    # move the place that we allocated on the stack to the second argument of scanf
    # the index will be in this place 
    leaq	-31(%rbp), %rsi			
    xorq    %rax, %rax      		# we need to reset %rax before call sacnf.
    call    scanf
    
    # reset registers before using them because we change their first byte
    xorq    %rdx, %rdx
    xorq    %rcx, %rcx
    # call pstrijcpy
    movq	-16(%rbp), %rdi			# move pstr1 to the first argument of pstrijcpy		 
    movq	-8(%rbp), %rsi			# move pstr2 to the second argument of pstrijcpy		 
    movb    -32(%rbp), %dl 			# move the first index (i) to the third argument
    movb    -31(%rbp), %cl			# move the second index (j) to the fourth argument
    call    pstrijcpy
    
    movq    $format_53_54, %rdi		# move the format string of this case to the first argument of printf	
    # new pstr1 is in %rax and its length is in the first byte so we move the length to the second argumnet of printf
    movzbq	(%rax), %rsi
    # new pstr1 is in %rax and its str start from the second byte so we move the str to the third argumnet of printf
    leaq    1(%rax), %rdx
    xorq    %rax, %rax      		# we need to reset %rax before call printf.
    call    printf

    movq	-8(%rbp), %r10			# move pstr2 to new register - %r10		 
    
    movq    $format_53_54, %rdi		# move the format string of this case to the first argument of printf	
    # pstr2 is in %r10 and its length is in the first byte so we move the length to the second argumnet of printf
    movzbq	(%r10), %rsi
    # pstr2 is in %r10 and its str start from the second byte so we move the str to the third argumnet of printf
    leaq	1(%r10), %rdx		 			
    xorq    %rax, %rax      		# we need to reset %rax before call printf.
    call    printf

    jmp .END_RUN
    
.OPT_54:
    movq    -16(%rbp), %rdi		# we move the address of pstr1 to %rdi 		
    call    swapCase
    pushq	%rax			# save the return value (the pstr1.str after swapCase) in the stack (%rbp-24)
    
    movq    -8(%rbp), %rdi		# we move the address of pstr2 to %rdi
    call    swapCase
    pushq	%rax			# save the return value (the pstr2.str after swapCase) in the stack (%rbp-32)
    
    movq	-24(%rbp), %r10
    
    movq    $format_53_54, %rdi		# move the format string to the first argumnet of printf
    movzbq	(%r10), %rsi			# move the new pstr1.str to the second argumnet of printf
    leaq	1(%r10), %rdx		 			
    xorq    %rax, %rax      		# we need to reset %rax before call printf.
    call    printf
    
    movq	-32(%rbp), %r11		# save the return value (the pstr1.str after swapCase) in %r11
    
    movq    $format_53_54, %rdi		# move the format string to the first argumnet of printf
    movzbq	(%r11), %rsi			# move the new pstr2.str to the second argumnet of printf
    leaq	1(%r11), %rdx		 			
    xorq    %rax, %rax      		# we need to reset %rax before call printf.
    call    printf

    jmp .END_RUN

.OPT_55:
    # allocate place in the stack. we allocate 16 bytes because the stack need to be alligned to 16 before calling printf/scanf.
    sub		$16, %rsp		# allocate place in the stack for the indexes we will get

    movq	$format_scan_index, %rdi		# move the format scan of int to the first argument of scanf
    # move the place that we allocated on the stack to the second argument of scanf
    # the int that will scan will be in this place 
    leaq	-32(%rbp), %rsi			
    xorq    %rax, %rax      		# we need to reset %rax before call sacnf.
    call    scanf
    
    movq	$format_scan_index, %rdi		# move the format scan of int to the first argument of scanf
    # move the place that we allocated on the stack to the second argument of scanf
    # the int that we will scan will be in this place 
    leaq	-31(%rbp), %rsi			
    xorq    %rax, %rax      		# we need to reset %rax before call sacnf.
    call    scanf
    
    # reset registers before using them because we change their first byte
    xorq    %rdx, %rdx
    xorq    %rcx, %rcx
    # call pstrijcmp
    movq	-16(%rbp), %rdi			# move pstr1 to the first argument of pstrijcmp		 
    movq	-8(%rbp), %rsi			# move pstr2 to the second argument of pstrijcmp		 
    movb    -32(%rbp), %dl 			# move the first index (i) to the third argument
    movb    -31(%rbp), %cl			# move the second index (j) to the fourth argument
    call    pstrijcmp
    
    movq    $format_55, %rdi		# move the format string of this case to the first argument of printf.
    movq	%rax,%rsi				# the compare result is in %rax so we move it to the second argumnet of printf.
    xorq    %rax, %rax      		# we need to reset %rax before call printf.
    call    printf

    jmp .END_RUN

.INVALID_OPT:	# case for invalid option
    movq    $invalid_option, %rdi
    xorq    %rax, %rax
    call    printf

# end of the function, after every case we jump to this label
.END_RUN:
    movq	%rbp, %rsp	#restore the old stack pointer - release all used memory.
    popq	%rbp		#restore old frame pointer (the caller function frame)
    xorq    %rax, %rax		# reset %rax
    ret		#return to caller function (OS).
