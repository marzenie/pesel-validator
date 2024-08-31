include Irvine32.inc

.data

    msg1 db "Wpisz PESEL: ",0
    msg2 db "Podany PESEL ma nieprawidlowa dlugosc",0
    msg3 db "PESEL musi skladac sie z samych cyfr",0
    msg4 db "Suma kontrolna PESEL'u jest nieprawidlowa",0
    msg5 db "PESEL jest prawidlowy",0

    pesel byte 13 dup (0) ; ustawione na 13 aby pesel MÓGŁ być za długi i wyskoczył błąd (normalnie długość powinna wynosić 12, 11 + 0)
    pesel_instruction_weight byte 1, 3, 7, 9, 1, 3, 7, 9, 1, 3
    sum_weight dword 0
    last_pesel_nr dword 0

.code

    main proc

        mov eax, 0

        mov edx, offset msg1
        call WriteString

        mov edx, offset pesel
        mov ecx, lengthof pesel
        call ReadString

        cmp eax,11
        jne bad_pesel_lenght

        mov ecx,eax
        mov ebx, offset pesel_instruction_weight
        mov esi, offset pesel
        mov edx, 0

        iteration:
            mov eax, [esi]
            cmp al,48

            jge number_check
            jl number_check_2

            number_check_back:
                sub al, '0'

                cmp ecx,1

                je nr_10

                movzx edx, byte ptr [ebx] 
                movzx eax, al

                imul edx,eax

                add sum_weight, edx

            nr_10_back:
                inc esi
                inc ebx 

        loop iteration



        mov eax, sum_weight
        mov edx, 0
        mov ebx, 10

        idiv ebx

        mov eax, 10

        sub eax, edx

        cmp eax,10

        je validate_10
        jne validate

        exit

        bad_pesel_lenght:
            mov edx, offset msg2
            call WriteString
            exit

        number_check:
            cmp al, 57
            jle number_check_back
            mov edx, offset msg3
            call WriteString
            exit

        number_check_2:
            mov edx, offset msg3
            call WriteString
            exit

        nr_10:
            movzx eax, al
            mov last_pesel_nr,eax
            jmp nr_10_back

        validate_10:
            cmp last_pesel_nr,0
            je success_message
            jmp error_message 

        validate:
            cmp last_pesel_nr,eax
            je success_message
            jmp error_message 

        success_message:
            mov edx, offset msg5
            call WriteString
            exit

        error_message:
            mov edx, offset msg4
            call WriteString
            exit

    main endp
    end main

