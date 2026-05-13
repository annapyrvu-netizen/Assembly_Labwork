.globl _start
.data       
a: .quad 0
b: .quad 0
c: .quad 0
input: .asciz "%llu %llu %llu"
output: .asciz "X = (8A + 9B) / 7C = %llu\nОстаток = %llu\n"
.text
_start:
    movq %rsp, %rbp                 # Сохраняем текущее состояние rsp
    subq $32, %rsp                  # Выделяем 32 байта на стеке
    andq $-16, %rsp                 # Выравниваем стек по 16 байт
    
    # Ввод трёх чисел A, B, C
    leaq input(%rip), %rdi          # Загружаем адрес строки ввода в rdi
    leaq a(%rip), %rsi              # Загружаем адрес переменной a в rsi
    leaq b(%rip), %rdx              # Загружаем адрес переменной b в rdx
    leaq c(%rip), %rcx              # Загружаем адрес переменной c в rcx
    call scanf                      # Читаем три беззнаковых числа
    
    movq (a), %rax                  # RAX = A
    movq $8, %rbx                   # RBX = 8 
    mulq %rbx                       # RDX:RAX = A * 8 
    movq %rax, %r8                  # R8 = 8A 

    movq (b), %rax                  # RAX = B 
    movq $9, %rbx                   # RBX = 9 
    mulq %rbx                       # RDX:RAX = B * 9 
    movq %rax, %r9                  # R9 = 9B 

    movq %r8, %rax                  # RAX = 8A
    addq %r9, %rax                  # RAX = 8A + 9B 
    movq %rax, %r10                 # R10 = числитель (8A + 9B)

    movq (c), %rax                  # RAX = C 
    movq $7, %rbx                   # RBX = 7 
    mulq %rbx                       # RDX:RAX = C * 7 
    movq %rax, %r11                 # R11 = знаменатель (7C)


    movq %r10, %rax                 # RAX = числитель (делимое)
    xorq %rdx, %rdx                 # Обнуляем RDX перед делением
    divq %r11                       # RAX = частное, RDX = остаток
    movq %rax, %r12                 # R12 = частное (результат X)
    movq %rdx, %r13                 # R13 = остаток

    leaq output(%rip), %rdi         # Загружаем адрес строки вывода в rdi
    movq %r12, %rsi                 # RSI = частное (первый параметр printf)
    movq %r13, %rdx                 # RDX = остаток (второй параметр printf)
    xorq %rax, %rax                 # Обнуляем RAX перед вызовом printf
    call printf                     # Выводим результат

    movq %rbp, %rsp                 # Восстанавливаем стек
    movq $0, %rdi                   # Код возврата 0
    movq $60, %rax                  # Номер системного вызова sys_exit
    syscall                         # Завершение программы