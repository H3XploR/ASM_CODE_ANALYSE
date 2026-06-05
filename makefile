NAME = analyze.exe

$(NAME): analyze.o
	link.exe $^ kernel32.lib psapi.lib /OUT:$@ /ENTRY:_start /SUBSYSTEM:console
analyze.o: start.s
	nasm -f win64 start.s -o $@

