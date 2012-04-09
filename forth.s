jmp start

; some kind of configuration
	:dictionary_end		
		dat 0,0,0,0
	:return_stack_top		
		dat 0,0,0,0
	:return
		dat return_stack_top

	:cmd1
		dat "rot",0
	:cmd2
		dat "strlen",0

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
	mov [dictionary_end], upstr ; last word on boot

	push 8
	push 8
	callword(multiply)
	pop a

	jmp exit

defword(searchForWord, 0, searchForWord) ; ( n -- addr ) searches word in dictionary by name 
	mov [sfw_local_name_str], pop
	jmp sfw_begin

	:sfw_local_current_addr
		dat 0,0,0,0
	:sfw_local_name_str
		dat 0,0,0,0
	:sfw_local_name_len
		dat 0,0,0,0
	
	:sfw_begin
		mov [sfw_local_current_addr], [dictionary_end]

		mov push, [sfw_local_name_str]
		callword(upstr)
		callword(strlen)
		mov [sfw_local_name_len], pop					; name_length
		
		:sfw_mainloop
			mov b, [sfw_local_current_addr]
			add b, 3
			push b

			callword(strlen)
			mov a, pop

			ifn [sfw_local_name_len], a
			jmp nextword
			push [sfw_local_name_str]
			push b
			callword(strcmp)
			ife [sfw_local_name_len],pop
			jmp sfw_found

		:nextword
			mov b, [sfw_local_current_addr]		; Load current name
			add b, 3

			ife [b], 0							; 0 - dictionary start
			jmp sfw_not_found					; exit

			sub b, 1							; switch to link
			mov [sfw_local_current_addr], [b]	; load previous link
			jmp sfw_mainloop

		:sfw_found
			mov a, [sfw_local_current_addr]
			push a
			jmp sfw_exit
		:sfw_not_found
			push 0
		:sfw_exit

	next

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
	mov a, pop
	mov b, pop

	mov i, 0
	:strcmp_loop
		ifn [a],[b]
		jmp strcmp_exit
		add a, 1
		add b, 1
		add i, 1
		ifn [a], 0
		jmp strcmp_loop

	:strcmp_exit
	push i
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

defword(inttostr, 0, inttostr)
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

defword(upstr, 0, upstr)
	mov a, pop
	mov z, a
	jmp __upstr_begin

	:__upstr_loop
		add a, 1
	:__upstr_begin
		ife [a], 0
		jmp __upstr_exit

		ifg	0x60, [a]
		jmp __upstr_loop
		ifg [a], 0x7a
		jmp __upstr_loop

		sub [a], 0x20
		jmp __upstr_loop

	:__upstr_exit
	set push, z
next

defword(+, 0, plus)
	pop a
	pop b
	add a,b
	push a
next

defword(-, 0, minus)
	pop b
	pop a
	sub a,b
	push a
next

defword(*, 0, multiply)
	pop b
	pop a
	mul a,b
	push a
next

defword(/, 0, divide)
	pop b
	pop a
	div a,b
	push a
next


:exit
	dat 0x0000
