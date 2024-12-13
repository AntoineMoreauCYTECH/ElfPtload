section .data
filename db 'HelloWorld', 0   ;
elf_message db 'ELF file detected', 0 
type_message db 'ELF Type: ', 0 ;

section .bss
buffer resb 64             
type_buffer resb 16         

section .text
global _start

_start:
    
    xor rax, rax             
    mov rax, 2               
    lea rdi, [rel filename]  
    xor rsi, rsi            
    syscall                  

    
    test rax, rax
    js _exit_with_error      

   
    mov rdi, rax            

    
    xor rax, rax            
    mov rax, 0               
    lea rsi, [rel buffer]    
    mov rdx, 64              
    syscall                  

  
    lea rbx, [rel buffer]    
    mov al, byte [rbx]      
    cmp al, 0x7f            
    jne _exit_with_error     

    inc rbx                 
    mov al, byte [rbx]
    cmp al, 0x45            
    jne _exit_with_error     

    inc rbx                  
    mov al, byte [rbx]
    cmp al, 0x4c            
    jne _exit_with_error    

    inc rbx                  
    mov al, byte [rbx]
    cmp al, 0x46            
    jne _exit_with_error     

    mov rax, 1               
    mov rdi, 1              
    lea rsi, [rel elf_message] 
    mov rdx, 18              
    syscall                  

    lea rbx, [rel buffer]    
    mov ax, word [rbx+16]    
    
    movzx rdi, ax            
    lea rsi, [rel type_buffer] 
    call num_to_str          

    mov rax, 1               
    mov rdi, 1               
    lea rsi, [rel type_buffer] 
    mov rdx, 16              
    syscall                  

    mov rax, 3               
    syscall                  

    xor rdi, rdi             
    mov rax, 60              
    syscall                 

_exit_with_error:
    mov rax, 60              
    xor rdi, rdi             
    syscall                  

num_to_str: 
    mov rbx, 10              
    xor rcx, rcx            
.num_to_str_loop:
    xor rdx, rdx             
    div rbx                 
    add dl, '0'             
    mov [rsi + rcx], dl      
    inc rcx                  
    test rax, rax            
    jnz .num_to_str_loop    
    mov byte [rsi + rcx], 0   
    ret




















































    
































