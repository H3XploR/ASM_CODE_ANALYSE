default rel
BITS 64

%define PID_CAPACITY 1024
%define PID_BUFFER_BYTES (PID_CAPACITY * 4)
%define STD_OUTPUT_HANDLE -11

section .text
global _start
extern EnumProcesses
extern ExitProcess
extern GetStdHandle
extern WriteFile

_start:
	and  rsp, -16
	sub  rsp, 48

	lea  rcx, [pid_list]          ; DWORD* lpidProcessIds
	mov  rdx, PID_BUFFER_BYTES    ; DWORD cb
	lea  r8,  [nb_pid_returned]   ; LPDWORD lpcbNeeded
	call EnumProcesses
	test eax, eax
	jz   exit

	mov  rcx, STD_OUTPUT_HANDLE
	call GetStdHandle
	mov  r12, rax                 ; stdout handle

	mov  eax, [nb_pid_returned]
	shr  eax, 2                   ; bytes returned / sizeof(DWORD)
	mov  r13d, eax                ; PID count
	xor  r14d, r14d               ; current index
	lea  rsi, [pid_list]

print_pid:
	cmp  r14d, r13d
	jae  exit

	mov  rcx, r12
	lea  rdx, [pid_prefix]
	mov  r8d, pid_prefix_len
	lea  r9,  [bytes_written]
	mov  qword [rsp + 32], 0
	call WriteFile

	mov  eax, [rsi + r14 * 4]
	lea  r15, [pid_digits + 10]
	xor  ebx, ebx
	test eax, eax
	jnz  convert_pid

	dec  r15
	mov  byte [r15], '0'
	mov  ebx, 1
	jmp  write_pid_digits

convert_pid:
	xor  edx, edx
	mov  ecx, 10
	div  ecx
	add  dl, '0'
	dec  r15
	mov  [r15], dl
	inc  ebx
	test eax, eax
	jnz  convert_pid

write_pid_digits:
	mov  rcx, r12
	mov  rdx, r15
	mov  r8d, ebx
	lea  r9,  [bytes_written]
	mov  qword [rsp + 32], 0
	call WriteFile

	mov  rcx, r12
	lea  rdx, [newline]
	mov  r8d, newline_len
	lea  r9,  [bytes_written]
	mov  qword [rsp + 32], 0
	call WriteFile

	inc  r14d
	jmp  print_pid

exit:
	xor  ecx, ecx
	call ExitProcess


section .bss
	pid_list:        resb PID_BUFFER_BYTES ; tableau de DWORD pour les PID
	nb_pid_returned: resd 1                ; nombre d'octets retournes
	bytes_written:   resd 1
	pid_digits:      resb 10

section .data
	pid_prefix:     db "PID: "
	pid_prefix_len: equ $ - pid_prefix
	newline:        db 13, 10
	newline_len:    equ $ - newline
