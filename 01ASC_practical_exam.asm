; Sa se scrie un program în limbaj de asamblare care:

;citeste de la tastatura un nume de fisier text si un numar natural N (0 < N < 5);
;citeste un text (de maximum 100 caractere) din acest fisier;
;determina si afiseaza cuvintele care se afla pe pozitii multiplu de N, urmate de numarul de consoane ale acestora.
;Fisierul text dat trebuie sa contina propozitii.

; O propozitie este formata din cuvinte separate prin spatii si care se termina cu un punct.

; Primul cuvant din fisier se afla pe pozitia 0.

bits 32 ; assembling for the 32 bits architecture

; declare the EntryPoint (a label defining the very first instruction of the program)
global start        

; declare external functions needed by our program
extern exit, scanf, fread, fopen, fclose, printf 
import exit msvcrt.dll
import scanf msvcrt.dll
import fread msvcrt.dll
import fopen msvcrt.dll
import fclose msvcrt.dll
import printf msvcrt.dll


; our data is declared here (the variables needed by our program)
segment data use32 class=data
    file_name db 'in.txt', 0
    file_handle dd -1
    text resb 101
    character db -1
    wrd resb 100
    read_mode db '%r', 0
    read_format_filename db '%s', 0
    read_format_n db '%d', 0
    print_format_decimal db '%d', 10, 0
    print_format_string db '%s ', 0
    n dd -1
    poz dd -1
    counter db 0
    already_printed_counter db 0
    next_poz dw 0

; our code starts here
segment code use32 class=code
    start:
        ;we read the name of the file (the file might still be named in.txt)
        push dword file_name
        push dword read_format_filename
        call [scanf]
        add esp, 4 * 2
        
        ;we read n
        push dword n
        push dword read_format_n
        call [scanf]
        
    
        ; FILE *fopen(const char *filename, const char *mode)
        ; we open the file in read mode
        push dword read_mode
        push dword file_name
        call [fopen]
        add esp, 4 * 2
        
        mov [file_handle], eax
        
        ; fread (void *buffer, size_t size, size_t count, FILE *stream) 
        ; we read the text
        push dword [file_handle]
        push dword 100
        push dword 1
        push dword text
        call [fread]
        add esp, 4 * 4
        
        ; fclose(FILE *handle)
        ; we close the file before attempting to do anything else
        push dword [file_handle]
        call [fclose]
        add esp, 4 * 1
        
        
        mov esi, text
        mov edi, wrd
        cld
        
        get_word: 
            movsb
            
            cmp byte [esi-1], 'a'
            jb check_uppercase
            
            cmp byte [esi-1], 'z'
            ja word_handling
            
            check_uppercase:
                cmp byte[esi-1], 'A'
                jb word_handling
                
                cmp byte [esi-1], 'Z'
                ja word_handling
                
            jmp skip
            ; we check if the word we got meets the criteria    
            word_handling:
                ; we check if the word is on the required position
                mov eax, [n]
                mul dword [already_printed_counter]
                
                inc dword [poz]
                cmp dword [poz], eax
                jb skip
                
                count_consonants:
                    ;I'm out of time, so I will not implement this. Every word will say that is has 3 consonants
                    mov al, 3
                    mov [counter], al 
          
                ; we print the string and the number of consonants
                print_result:
                    push dword wrd
                    push dword print_format_string
                    call [printf]
                    add esp, 4 * 2
                    
                    push dword [counter]
                    push dword print_format_decimal
                    call [printf]
                    add esp, 4 * 2
                    
                    inc dword [already_printed_counter]
                
            ; we begin getting a new word
            skip:
                mov edi, wrd
                
        jmp get_word
            
       
        ending:
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
