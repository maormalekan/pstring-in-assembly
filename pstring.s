# 321202962 Maor Malekan

    .data #data section contains global variables

    .section	.rodata			#read only data section
	invalid_input:	.string "invalid input!\n"		#for invalid input

    .align 4 # Align address to multiple of 4

    ########
    .text	#the beginnig of the code

.globl	pstrlen
	.type	pstrlen, @function	# the label "pstrlen" representing the beginning of a function
pstrlen:
	pushq	%rbp		#save the old frame pointer
	movq	%rsp, %rbp	#create the new frame pointer

    movzbq (%rdi),%rax  # the length of the pstring is in the first byte of %rdi, so %rax will hold this byte

    movq	%rbp, %rsp	#restore the old stack pointer - release all used memory.
    popq	%rbp		#restore old frame pointer (the caller function frame)
    ret		#return to caller function (OS).
    
.globl	replaceChar
	.type	replaceChar, @function	# the label "replaceChar" representing the beginning of a function
replaceChar:
	pushq	%rbp		#save the old frame pointer
	movq	%rsp, %rbp	#create the new frame pointer

    # the return value is the string after we replaced the "old char" by the "new char" so %rax will point to %rdi 
    movq  %rdi,%rax

.WHILE_DO_REP:
    incq     %rdi        # the first char of the string will be in the second byte of pstring. every step we need to increase this pointer
    cmpb    $0, (%rdi)  # if we have reached the end of the string.
    je      .END_REP
    cmpb    %sil, (%rdi)    # if the char in the string is not the "old char" (%sil is the first byte of %rsi)
    jne      .WHILE_DO_REP
    # else, the char in the string is the "old char" and we want to replace the char by the "new char".
    movb     %dl, (%rdi)    # the "new char" is in the first byte of %rdx - %dl
    jmp     .WHILE_DO_REP   # repeat this step
    
.END_REP:               # label for the end of the function
    movq	%rbp, %rsp	# restore the old stack pointer - release all used memory.
    popq	%rbp		# restore old frame pointer (the caller function frame)
    ret		            # return to caller function (OS).

.globl	pstrijcpy
	.type	pstrijcpy, @function	# the label "pstrijcpy" representing the beginning of a function
pstrijcpy:
	pushq	%rbp		#save the old frame pointer
	movq	%rsp, %rbp	#create the new frame pointer
        
    pushq   %rdi        # save the address of the dst pstring on the stack, we want to return it at the end.

    movzbq  (%rdi), %r10  # the length of the first pstring is in the first byte of %rdi, so %r10 will hold this byte
    cmpq    %r10, %rcx  # if the index j is bigger than the length of the first string
    jge      .INVALID_CPY
    cmpq    %r10, %rdx  # if the index i is bigger than the length of the first string
    jge      .INVALID_CPY
    
    movzbq  (%rsi), %r10  # the length of the second pstring is in the first byte of %rsi, so %r10 will hold this byte
    cmpq    %r10, %rcx  # if the index j is bigger than the length of the second string
    jge      .INVALID_CPY
    cmpq    %r10, %rdx  # if the index i is bigger than the length of the second string
    jge      .INVALID_CPY
    
    incq     %rdi        # we change %rdi to point on the first char of the string that in the second byte of pstring.
    incq     %rsi        # we change %rsi to point on the first char of the string that in the second byte of pstring.
    add     %rdx, %rdi  # we start to copy the substring from pstring.str[i], so we add i to the dst string.
    add     %rdx, %rsi  # we start to copy the substring from pstring.str[i], so we add i to the src string.

.WHILE_DO_CPY:
    cmpq    %rcx, %rdx  # if i>j we arrived to the end of the substring - end the function.
    ja      .END_CPY
    movzbq  (%rsi), %r10    # save the char that we want to copy in %10.
    # move the the char to his place in dst pstring. therefore we need to move the first byte of %r10 - %r10b.
    movb     %r10b, (%rdi)
    incq     %rsi   # next char in src pstring.
    incq     %rdi   # next char in dst pstring.
    incq     %rdx   # increase the index i.
    jmp     .WHILE_DO_CPY

.INVALID_CPY:
    movq    $invalid_input, %rdi    # send the format string of invalid input to the printfs argument.
    xorq    %rax, %rax      # we need to reset %rax before call printf.
    call    printf

.END_CPY:
    popq    %rax        # save the address of dst pstring in %rax - the return value.
    movq	%rbp, %rsp	#restore the old stack pointer - release all used memory.
    popq	%rbp		#restore old frame pointer (the caller function frame)
    ret		#return to caller function (OS).

.globl	swapCase
	.type	swapCase, @function	# the label "swapCase" representing the beginning of a function
swapCase:
    pushq	%rbp		#save the old frame pointer
	movq	%rsp, %rbp	#create the new frame pointer

    # the return value is the string after we replaced the "old char" by the "new char" so %rax will point to %rdi 
    movq  %rdi,%rax

.MAIN_L:
    incq     %rdi        # the first char of the string will be in the second byte of pstring. every step we need to increase this pointer
    cmpb    $0, (%rdi)  # if char == 0, it means that we have reached the end of the string.
    je      .END_L
    cmpb    $65, (%rdi)     # if the char is smaller than 'A' (char < 'A'), the char is not a english letter.
    jb      .MAIN_L
    cmpb    $122, (%rdi)    # if the char is bigger than 'z' (char > 'A'), the char is not a english letter.
    ja      .MAIN_L

.LOW_OR_UP:     # in case that 65 <= char <= 122
    cmpb    $91, (%rdi)    # if 65 <= char <= 90, the char is upper case letter.
    jb      .UPPER_CASE
    cmpb    $96, (%rdi)    # if 97 <= char <= 122, the char is lower case letter.
    ja      .LOWER_CASE
    jmp     .MAIN_L     # else, (90 < char < 97), the char is not a english letter.

.UPPER_CASE:
    add     $32, (%rdi)     # in upper case we need add 32 to the char to change it to lower case letter.
    jmp     .MAIN_L

.LOWER_CASE:
    sub     $32, (%rdi)     # in lower case we need subtract 32 from the char to change it to upper case letter.
    jmp     .MAIN_L

.END_L:
    movq	%rbp, %rsp	#restore the old stack pointer - release all used memory.
    popq	%rbp		#restore old frame pointer (the caller function frame)
    ret		#return to caller function (OS).

.globl	pstrijcmp
	.type	pstrijcmp, @function	# the label "pstrijcmp" representing the beginning of a function
pstrijcmp:
    pushq	%rbp		#save the old frame pointer
	movq	%rsp, %rbp	#create the new frame pointer
    
    movzbq  (%rdi), %r10  # the length of the first pstring is in the first byte of %rdi, so %r10 will hold this byte
    cmpq    %r10, %rcx  # if the index j is bigger than the length of the first string
    jge      .INVALID_CMP
    movzbq  (%rsi), %r10  # the length of the second pstring is in the first byte of %rsi, so %r10 will hold this byte
    cmpq    %r10, %rcx  # if the index j is bigger than the length of the second string
    jge      .INVALID_CMP

    add     %rdx, %rdi  # we start to check the substring from pstr1.str[i], so we add i to the dst string.
    add     %rdx, %rsi  # we start to check the substring from pstr2.str[i], so we add i to the src string.

.WHILE_DO_CMP:
    incq     %rdi   # next char in dst pstring. in the first time we increase the address to point on the first char.
    incq     %rsi   # next char in src pstring. in the first time we increase the address to point on the first char.

    cmpq    %rcx, %rdx  # if we finished to ran over the substrings, it means that they equals.
    ja      .EQUAL      # if the substring in pstr1 and the substring in pstr2 are equals

    movzbq  (%rdi), %r10    # save the char of pstr1 in %r10.
    movzbq  (%rsi), %r11    # save the char of pstr2 in %r11.

    cmpq    %r11, %r10      # compare between the char in pstr1 and the char in pstr2
    ja      .PSTR1_BIGGER   # if the substring in pstr1 bigger than the substring in pstr2
    jb      .PSTR2_BIGGER   # if the substring in pstr2 bigger than the substring in pstr1

    incq     %rdx           # increase the index i.
    jmp     .WHILE_DO_CMP   # repeat this step

.EQUAL:                     # if the substring in pstr1 and the substring in pstr2 are equals
    xorq    %rax, %rax      # put 0 in the return value
    jmp     .END_CMP        # end the function
.PSTR1_BIGGER:              # if the substring in pstr1 bigger than the substring in pstr2
    movq    $1, %rax        # put 1 in the return value
    jmp     .END_CMP        # end the function
.PSTR2_BIGGER:              # if the substring in pstr2 bigger than the substring in pstr1
    movq    $-1, %rax       # put -1 in the return value
    jmp     .END_CMP        # end the function

.INVALID_CMP:               # if the input is invalid
    movq    $invalid_input, %rdi    # send the format string of invalid input to the first argument of printf.
    xorq    %rax, %rax      # we need to reset %rax before call printf.
    call    printf          # print the invalid format string
    movq    $-2, %rax       # put -2 in the return value

.END_CMP:                   # label for the end of the function
    movq	%rbp, %rsp	    #restore the old stack pointer - release all used memory.
    popq	%rbp		    #restore old frame pointer (the caller function frame)
    ret		                #return to caller function (OS).


