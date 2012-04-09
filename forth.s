jmp start

; some kind of configuration
	:dictionary_start		dat 0,0,0,0
	:return_stack_top		dat 0,0,0,3

; data section here
	:initial_stack 			dat 0x0000

:start
	mov	initial_stack, sp 	; saving initial stack pointer if we should inline into other program (OS)
	mov I, return_stack_top
	mov [I], 0x3000


	set push, 2
	callword(dup)
	set push, 3
	callword(rot)
	set a, pop
	set b, pop
	set c, pop
	
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

:exit
	dat 0x0000
