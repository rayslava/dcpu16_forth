jmp start

; some kind of configuration
	:dictionary_start		
		dat 0,0,0,0
	:return_stack_top		
		dat 0,0,0,3

; data section here
	:initial_stack 			
		dat 0x0000
	:prompt
		dat "FORTH> ",0
	:result
		dat "0000000",0
	:ok_msg
		dat "Ok",0

:start
	mov [return_stack_top], 0x3000 ; init return sp

	set push, result
	set push, 12345
	callword(inttostr)
	callword(writeline)

	jmp exit

defword(dup, 0, dup)
	set a, pop
	set push, a
	set push, a
next

defword(rot, 0, rot)
	set a, pop
	set b, pop
	set c, pop
	set push, b
	set push, a
	set push, c
next

defword(strcmp, 0, strcmp)

next

defword(writeline, 0, writeline)
	mov a, pop
	mov i, 0

	:__writeline_loop1
		mov [0x8000+i], [a]
		add i, 1
		add a, 1
		ifn [a], 0
		jmp __writeline_loop1
next

defword(strlen, 0, strlen)
	mov a, pop
	mov i, 0

	:__strlen_loop
		ife [a], 0
		jmp __strlen_exit
		add i, 1
		add a,1
		jmp __strlen_loop
	:__strlen_exit
	set push, i
next

defword(i2s, 0, inttostr)
	mov a, pop
	mov b, pop
	mov z, b
	mov x, a

	mov y, 10000
	jmp __next_digit_start

	:__digit		
		add x, 48
		
		mov [b],x
		add b, 1
		ret

	:__next_digit
		mov x, a
		mod x, y
		div y, 10

	:__next_digit_start 
		div x, y
		jsr __digit
		ifg y, 1
		jmp __next_digit
	set push, z
next

:exit
	dat 0x0000
