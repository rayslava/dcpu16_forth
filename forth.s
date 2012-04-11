jmp start

; some kind of configuration
	:dictionary_end		
		dat 0
		dat 0
		dat 0
		dat 0
	:return_stack_top		
		dat 0
		dat 0
		dat 0
		dat 0
	:return
		dat return_stack_top

	:cmd1
		dat "SWap",0
	:cmd2
		dat "+",0

; data section here
	:initial_stack 			
		dat 0x0000
	:prompt
		dat "FORTH> ",0
	:result
		dat "0000000",0
	:ok_msg
		dat "Ok",0
	:program
		dat "2 4 swap / ",0
	:test1
		dat "65534",0

:start
	mov [return_stack_top], 0xb000 ; init return sp
	mov [dictionary_end], [last_word] ; last word on boot

	push cmd1
	callword(searchForWord)
	pop a
	mov b, swap

;	push program
;	callword(parse)
;	pop a

	jmp exit

defword(parse, 0, parse)
	jmp parse_begin

	:string_to_parse
		dat 0
		dat 0
		dat 0
		dat 0
	:current_pos
		dat 0
		dat 0
		dat 0
		dat 0
	:current_word
		dat 0
		dat 0
		dat 0
		dat 0
	:memory
		dat 0x00					; buffer
		dat 0x00					; buffer
		dat 0x00					; buffer
		dat 0x00					; buffer
	:parse_begin
		mov [string_to_parse], pop
		mov i, 0
		mov [memory], 0x1800		; buffer

		
		mov x, [string_to_parse]
		mov a, [current_word]
		jmp parse_add_symbol

		:parse_next_token			; init buffer
			mov a, [current_word]

			mov x, [string_to_parse]
			mov x, [current_pos]

		:parse_add_symbol
			mov	[a], [x]
			add x, 1
			add a, 1

			ife [x],0				; TEH END
			jmp parse_exit

			ifn [x],0x20			; IF NOT SPACE
			jmp parse_add_symbol

			add x, 1
			mov [current_pos], x	; WORKOUT
			mov [a], 0
			push [current_word]
			callword(isnumber)
			ife	1, pop				; that's NUMBER
			jmp parse_num

		:parse_word

			mov j, 0xdead
			mov a, [current_word]
			mov b, [a]
			add a, 1
			mov c, [a]
			add a, 1
			mov x, [a]
			add a, 1
			mov y, [a]
			add a, 1
			mov z, [a]
			add a, 1

			push [current_word]
			callword(searchForWord)
			mov a, pop
			mov i, swap
			mov j, a
			mov c,c
			mov c,c
			mov c,c
			mov c,c
			mov c,c
			mov c,c
			mov c,c
			mov c,c
			mov c,c
			mov c,c
			mov c,c
			call(a)
			jmp parse_next_token
			;mov c,i
			
		:parse_num
			mov a, [current_word]
			push [current_word]
			callword(strtoint)		; digit is on stack
			pop j
			push j
			jmp parse_next_token

		:parse_exit
next

defword(searchForWord, 0, searchForWord) ; ( n -- addr ) searches word in dictionary by name 
	mov [sfw_local_name_str], pop
	jmp sfw_begin

	:sfw_local_current_addr
		dat 0,0,0,0
	:sfw_local_name_str
		dat 0,0,0,0,0,0,0,0,0,0
	:sfw_local_name_len
		dat 0,0,0,0
	
	:sfw_begin
		mov [dictionary_end], [last_word]
		mov [sfw_local_current_addr], [dictionary_end]
		mov j, [dictionary_end]

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

defword(inttostr, 0, inttostr) ; ( num str -- str )
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

defword(strtoint, 0, strtoint) ; ( num str -- str )
	jmp strtoint_start
		:strtoint_string
			dat 0
		:strtoint_digit
			dat 0
		:strtoint_result
			dat 0

	:strtoint_start
		mov [strtoint_string], pop

		push [strtoint_string]
		callword(strlen)
		mov z, pop
		sub z, 1

		mov a, [strtoint_string]
		add a, z
		mov b, [a]
		sub b, 0x30
		mov [strtoint_result], b

		mov y, 1
	:strtoint_next_digit	
		mul y, 10
		sub z, 1
		ife z, 0xffff
		jmp strtoint_finished

		mov a, [strtoint_string]
		add a, z
		mov b, [a]
		sub b, 0x30
		mul b, y
		add [strtoint_result], b
		jmp strtoint_next_digit

	:strtoint_finished
		push [strtoint_result]
next



defword(isnumber, 0, isnumber)
	mov a, pop
	mov i, 0

	:isnumber_mainloop
		ife [a], 0
		jmp isnumber_success

		ifg 0x30, [a]
		jmp isnumber_fail
		ifg [a], 0x39
		jmp isnumber_fail
		add a, 1
		jmp isnumber_mainloop

	:isnumber_fail
		push 0xffff
		jmp isnumber_finish

	:isnumber_success
		push 1
	:isnumber_finish	
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

defword(swap, 0, swap)
	pop b
	pop a
	push b
	push a
next


:last_word
	dat prev_word

:exit
