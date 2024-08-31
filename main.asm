include Irvine32.inc

.data

    msg1 db "Wpisz PESEL: ",0
    msg2 db "Podany PESEL ma nieprawidlowa dlugosc",0
    msg3 db "PESEL musi skladac sie z samych cyfr",0
    msg4 db "Suma kontrolna PESEL'u jest nieprawidlowa",0
    msg5 db "PESEL jest prawidlowy",10,0
    msg7 db "Plec: ",0
    msg8 db "Kobieta",10,0
    msg9 db "Mezczyzna",10,0
    msg10 db "Data urodzenia: ",0
    msg11 db 10,"-----DANE-----",10,0
    msg12 db 10,"--------------",10,0
    pesel byte 13 dup (0) ; ustawione na 13 aby pesel MÓGŁ być za długi i wyskoczył błąd (normalnie długość powinna wynosić 12, 11 + 0)
    pesel_instruction_weight byte 1, 3, 7, 9, 1, 3, 7, 9, 1, 3
    sex byte 0; 0-k, 1-m
    br_day db 2 dup(0),0;
    br_month_type byte 0
    br_month byte 0
    br_year_1 byte 0; pierwsza polowa
    br_year_2 db 2 dup(0),0; druga polowa
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
                cmp ecx,11
                je nr_1

                cmp ecx,10
                je nr_2

                cmp ecx,7
                je nr_5

                cmp ecx,6
                je nr_6

                nr1_2_5_6back:

                sub al, '0'

                cmp ecx,9
                je nr_3

                cmp ecx,8
                je nr_4

                cmp ecx,2
                je nr_10

                nr_back:

                cmp ecx,1
                je nr_11

                movzx edx, byte ptr [ebx] 
                movzx eax, al

                imul edx,eax

                add sum_weight, edx

            nr_11_back:
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

        jmp end_message

        bad_pesel_lenght:
            mov edx, offset msg2
            call WriteString
            jmp end_message

        number_check:
            cmp al, 57
            jle number_check_back
            mov edx, offset msg3
            call WriteString
            jmp end_message

        number_check_2:
            mov edx, offset msg3
            call WriteString
            jmp end_message
        nr_1:
            mov br_year_2[0], al
            jmp nr1_2_5_6back
        nr_2:
            mov br_year_2[1], al
            jmp nr1_2_5_6back
        nr_3:
            ;switch 
            ; 8|9 - 18
            ; 0|1 - 19
            ; 2|3 - 20
            ; 4|5 - 21
            ; 6|7 - 22
            ; jezeli drugi wariant październik/listopad/grudzień 10/11/12

            cmp al,8
            je year18XX
            cmp al,9
            je year18XXs

            cmp al,0
            je year19XX
            cmp al,1
            je year19XXs

            cmp al,2
            je year20XX
            cmp al,3
            je year20XXs

            cmp al,4
            je year21XX
            cmp al,5
            je year21XXs

            cmp al,6
            je year22XX
            cmp al,7
            je year22XXs

            jmp nr_back

                year18XX:
                    mov br_year_1, 18
                    mov br_month_type, 0
                    jmp nr_back
                year18XXs:
                    mov br_year_1, 18
                    mov br_month_type, 1
                    jmp nr_back

                year19XX:
                    mov br_year_1, 19
                    mov br_month_type, 0
                    jmp nr_back
                year19XXs:
                    mov br_year_1, 19
                    mov br_month_type, 1
                    jmp nr_back

                year20XX:
                    mov br_year_1, 20
                    mov br_month_type, 0
                    jmp nr_back
                year20XXs:
                    mov br_year_1, 20
                    mov br_month_type, 1
                    jmp nr_back

                year21XX:
                    mov br_year_1, 21
                    mov br_month_type, 0
                    jmp nr_back
                year21XXs:
                    mov br_year_1, 21
                    mov br_month_type, 1
                    jmp nr_back

                year22XX:
                    mov br_year_1, 22
                    mov br_month_type, 0
                    jmp nr_back
                year22XXs:
                    mov br_year_1, 22
                    mov br_month_type, 1
                    jmp nr_back
        nr_4:
            mov br_month, al
            jmp nr_back
        nr_5:
            mov br_day[0], al
            jmp nr1_2_5_6back
        nr_6:
            mov br_day[1], al
            jmp nr1_2_5_6back
        nr_10:
             mov   sex, al
             and   sex, 01
            jmp nr_back

        nr_11:
            movzx eax, al
            mov last_pesel_nr,eax
            jmp nr_11_back

        validate_10:
            cmp last_pesel_nr,0
            je success_message
            jmp error_message 

        validate:
            cmp last_pesel_nr,eax
            je success_message
            jmp error_message 

        success_message:
            jmp calculate_month
            calculate_month_back:

            mov edx, offset msg5
            call WriteString

            mov edx, offset msg11
            call WriteString

            mov edx, offset msg7
            call WriteString

            cmp sex,1
            je sex_man
            jne sex_woman

            sex_back:

            mov edx, offset msg10
            call WriteString

            mov eax,0
            mov al, br_year_1
            call WriteDec

            mov edx, offset br_year_2
            call WriteString

            mov  al,'-'
            call WriteChar

            mov  al,'0'
            call WriteChar

            mov  al, br_month
            call WriteDec

            mov  al,'-'
            call WriteChar


            mov edx, offset br_day
            call WriteString

            mov edx, offset msg12
            call WriteString

            jmp end_message


        sex_man:
            mov edx, offset msg9
            call WriteString
            jmp sex_back
        sex_woman:
            mov edx, offset msg8
            call WriteString
            jmp sex_back
        calculate_month:
            cmp br_month_type, 0
            je calculate_month_type_2
            jmp calculate_month_back

            calculate_month_type_2:
                cmp br_month, 0
                je october

                cmp br_month, 1
                je november

                cmp br_month, 2
                je december

                jmp calculate_month_back

                october:
                    mov br_month, 10
                    jmp calculate_month_back
                november:
                    mov br_month, 11
                    jmp calculate_month_back
                december:
                    mov br_month, 11
                    jmp calculate_month_back

        error_message:
            mov edx, offset msg4
            call WriteString
            jmp end_message

        end_message:
            mov eax, 10
            call WriteChar

            call WaitMsg
            exit

    main endp
    end main
