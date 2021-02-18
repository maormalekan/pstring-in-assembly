# 321202962 Maor Malekan

	.data #data section contains global variables

	.section	.rodata			#read only data section
format_scan_int:	.string	"%hhu"	# format to scan the length of the string
format_scan_str:	.string	"%s"	# format to scan the the string

	########
	.text	#the beginnig of the code
.globl	run_main	#the label "main" is used to state the initial point of this program
	.type	run_main, @function	# the label "main" representing the beginning of a function

run_main:	# the main function:
	pushq	%rbp		#save the old frame pointer
	movq	%rsp, %rbp	#create the new frame pointer
    pushq	%rbx		#saving a callee save register.
    # size of pstring is maximum 129 bytes
    # (127 bytes for the length of the string, 1 byte for the zero at the end of the string and one byte for the length)
    # so we need to allocate place on the stack for 258 bytes for the two pstrings, and another one byte for the option.
    # 272 is the minimum number for that.
    sub     $272, %rsp
    
    # scan the length of the first string
    movq    $format_scan_int, %rdi      #send the format scan to the first argument of the scanf
    leaq    -272(%rbp), %rsi      #the second argument will be in rsi
   	xorq    %rax, %rax      # we need to reset %rax before call sacnf.
    call    scanf
    
    # scan the first string
    movq    $format_scan_str, %rdi
    leaq    -271(%rbp), %rsi
   	xorq    %rax, %rax      # we need to reset %rax before call sacnf.
    call    scanf
    
    # scan the length of the second string
    movq    $format_scan_int, %rdi      #send the format scan to the first argument of the scanf
    leaq    -143(%rbp), %rsi      #the second argument will be in rsi
   	xorq    %rax, %rax      # we need to reset %rax before call sacnf.
    call    scanf
    
    # scan the second string
    movq    $format_scan_str, %rdi
    leaq    -142(%rbp), %rsi
   	xorq    %rax, %rax      # we need to reset %rax before call sacnf.
    call    scanf

    # scan the option
    movq    $format_scan_int, %rdi      #send the format scan to the first argument of the scanf
    leaq    -14(%rbp), %rsi      #the second argument will be in rsi
   	xorq    %rax, %rax      # we need to reset %rax before call sacnf.
    call    scanf

    # call run_func
    leaq    -14(%rbp), %rdi
    movzbq  (%rdi), %rdi
    leaq    -272(%rbp), %rsi      #send
    leaq    -143(%rbp), %rdx      #send
    call    run_func

    movq	%rbp, %rsp	#restore the old stack pointer - release all used memory.
	popq	%rbp		#restore old frame pointer (the caller function frame)
    xorq    %rax, %rax
	ret		#return to caller function (OS).




