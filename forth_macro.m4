define(`prev_word', `0')

define(`defword', `:$3
  DAT ifelse(`prev_word', `0', `0,0,0,0' , `prev_word') ; Link to previous
  DAT "upcase($1)", 0 ; Name
  DAT $2 ; Flags
  :__$3_start
  SET [X], POP define(`prev_word', $3)')

define(`callword', ` ADD [return_stack_top], 4
 SET X, [return_stack_top]
 jsr __$1_start')

define(`next', ` SET X, [return_stack_top]
 SET PUSH, [X]
 SUB [return_stack_top], 4
 SET PC, POP')

