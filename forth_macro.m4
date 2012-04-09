define(`defword', `:$3
  DAT "upcase($1)", 0
  DAT len($1)
  DAT $2
  __$3_start:
  SET [Y], POP')

define(`callword', ` SET X, return_stack_top 
 ADD [X], 4
 SET Y, [X]
 jsr __$1_start')

define(`next', ` SET X, return_stack_top
 SET Y, [X]
 SET PUSH, [Y]
 SUB [X], 4
 SET PC, POP')
