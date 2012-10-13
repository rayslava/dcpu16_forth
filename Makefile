SRC=forth.dasm16
all: macro
	../dcpu16/a16 processed.s
	sed -e "s/^\s\?\+pop\s\+\(.\+\)/SET \1, POP/" <processed.s >p.s
	sed -e "s/^\s\?\+push\s\+\(.\+\)/SET PUSH, \1/"  <p.s >processed.s 
	rm p.s
	../dcpu16/a16 -o ../dcpu/test.img -O binary processed.s
#	rm processed.s
#	rm macro.m4
run: all
	../dcpu16/dcpu
macro:
	cat ../dcpu16_tools/macro.m4 forth_macro.m4 > macro.m4
	m4 macro.m4 $(SRC) > processed.s
clean:
	rm out.hex processed.s macro.m4
