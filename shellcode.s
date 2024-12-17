section .data
    msg db 'Success!', 0xA  
section .text
    global _start
_start:
    mov rax, 1       
    mov rdi, 1        
    lea rsi, [rel msg] 
    mov rdx, 8  
    syscall
    mov rax, 60     
    xor rdi, rdi    
    syscall
