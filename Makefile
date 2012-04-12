SRC=forth.dasm16
all: macro
	../dcpu16/a16 processed.s
#	rm processed.s
#	rm macro.m4
run: all
	../dcpu16/dcpu
macro:
	cat ../dcpu16_tools/macro.m4 forth_macro.m4 > macro.m4
	m4 macro.m4 $(SRC) > processed.s
clean:
	rm out.hex processed.s macro.m4
