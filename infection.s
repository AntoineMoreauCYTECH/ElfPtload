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
    

   


section .bss
    buffer resb 64         
    programmheader resb 56        
    type_buffer resb 16
    bufferconv resb 16  
  

section .text
global _start

_start:
    ; Ouvrir le fichier ELF
    mov rax, 2               
    lea rdi, [rel filename]  
    mov rsi, 2              
    syscall
    test rax, rax            
    js _exit_with_error                  
    mov r12, rax            

    ; Afficher un message après l'ouverture réussie
    ;mov rax, 1               ; syscall: write
    ;mov rdi, 1               ; stdout
    ;lea rsi, [rel open_success_msg]
    ;mov rdx, 25              ; Longueur du message
    ;syscall

    ; Lire l'en-tête ELF (Elf64_Ehdr)
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



    ; Afficher le nombre d'en-têtes de programme 
    mov rcx, [buffer + 56]     
    lea rsi, [rel bufferconv] 
    mov rdi, rcx             
    call num_to_str          

    mov rax, 1               
    mov rdi, 1               
    lea rsi, [rel nbheaders]
    mov rdx, 20              
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
    

    ; Obtenir les informations des en-têtes de programme
    mov rbx, [buffer+ 32]    
    mov rcx, [buffer + 56]     
    mov rdx, [buffer + 54]     



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

    ; Lire l'en-tête de programme actuel
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
    dec rcx                 
    jmp boucle

;Ptnote trouvé
ptnote:
 ; Modifier ptnote en ptload
   mov dword [programmheader], 1   

   
   mov rax, 1
   mov rdi, 1               ; stdout
   lea rsi, [rel success_msg2]
   mov rdx, 14              ; Longueur du message
   syscall

   
   mov rax, 1               ; syscall: write
   mov rdi, r12             ; Descripteur de fichier
   lea rsi, [rel programmheader]  ; Adresse du buffer modifié
   mov rdx, 56              ; Taille de Elf64_Phdr
   syscall

   
   jmp close_file



;ptnote pas trouvée
pasdeptnote:
    ; Afficher un message d'échec
    mov rax, 1               
    mov rdi, 1              
    lea rsi, [rel failure]
    mov rdx, 18              
    syscall
    jmp close_file


close_file:
    ; Fermer le fichier
    mov rax, 3               
    mov rdi, r12             
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
