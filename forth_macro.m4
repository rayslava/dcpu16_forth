define(`defword', `:$3
  DAT "upcase($1)", 0
  DAT len($1)
  DAT $2
  :__$3_start
  SET [X], POP')

define(`callword', ` ADD [return_stack_top], 4
 SET X, [return_stack_top]
 jsr __$1_start')

define(`next', ` SET X, [return_stack_top]
 SET PUSH, [X]
 SUB [return_stack_top], 4
 SET PC, POP')
