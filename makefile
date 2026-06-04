NAME = analyze

$(NAME): analyze.o
	ld $^ -o $@
analyze.o: start.s
	nasm -f elf64 start.s -o $@

