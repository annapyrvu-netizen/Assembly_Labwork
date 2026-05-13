#set page(
  paper: "a4",
  margin: (top: 2cm, bottom: 2cm, left: 3cm, right: 1cm),
  numbering: none,
  footer: context {
    let p = counter(page).get().first()
    if p > 1 {
      align(center)[#p]
    }
  }
)

#set text(
  lang: "ru",
  font: "Times New Roman",
  size: 12pt
)

//Рамка для блока с кодом
#show raw: block.with(
  fill: luma(245),
  inset: 10pt,
  radius: 5pt,
  stroke: luma(200),
)

//Для таблиц - подпись сверху
#show figure.where(kind: table): set figure.caption(position: top)



#align(center)[
  #upper[ГУАП]
  #v(0.5cm)
  #upper[КАФЕДРА № 14]
  #v(2cm)
]

#grid(
  columns: (2fr),
  align(left)[
    #upper[ОТЧЕТ]\
    #upper[ЗАЩИЩЕН С ОЦЕНКОЙ]\
    #upper[]\
    #upper[ПРЕПОДАВАТЕЛЬ]
  ],
  align(center)[
    #v(0.5cm)
    #grid(
      columns: (2fr, 1fr, 2fr),
      gutter: 0.3em,
      [Старший преподаватель],
      [],
      [Н.И. Синёв],
      line(length: 100%),
      line(length: 100%),
      line(length: 100%),
      [должность, уч. степень, звание],
      [подпись, дата],
      [инициалы, фамилия]
    )
  ]
)

#align(center)[
  #v(2cm)
  #upper[ОТЧЕТ О ЛАБОРАТОРНОЙ РАБОТЕ №1]
  #v(0.8cm)
  #text[Вычисление для беззнаковых чисел]
  #v(0.8cm)
  #text[по курсу:]
  #text[Программирование на языках Ассемблера]
  #v(4cm)
]

#grid(
  columns: (2fr),
  align(left)[
    #upper[РАБОТУ ВЫПОЛНИЛ]
  ],
  align(center)[
    #v(0.5cm)
    #grid(
      columns: (1fr, 1fr, 1fr, 1.5fr),
      gutter: 0.3em,
      align(left)[#upper[СТУДЕНТ гр. №]],
      [1446],
      [13.05.2026],
      [А.С. Пырву],
      line(length: 0%),
      line(length: 100%),
      line(length: 100%),
      line(length: 100%),
      [],
      [],
      [подпись, дата],
      [инициалы, фамилия]
    )

    #v(4cm)

    Санкт-Петербург 2026
]
)


= Описание задачи
Вычислить значение функции с использованием ассемблера (GAS или Apple ARM 64) для беззнаковых чисел. Функция: $ X = (8A + 9B)/(7C) $

= Формализация
Вводимые значения — целые беззнаковые числа от 0 до 2 147 483 647 (ограничение выбрано для гарантии отсутствия переполнения при промежуточных вычислениях). C (третье вводимое значение) не должно быть нулём. В выводимых результатах: первое значение – частное, второе значение – остаток от деления.

https://github.com/annapyrvu-netizen/Assembly_Labwork



= Исходный код программы






Код на ассемблере:
```asm
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
```

= Тестирование


#figure(
  table(
    columns: 6,
    align: center + horizon,
    // stroke: none,
    table.hline(),
    [*Набор тестовых данных *], [*A*], [*B*], [*C*], [*Результат*],[*Остаток*],
    table.hline(),
    [1], [9],   [99],   [6],  [22],[39],
    [2], [8],  [11],  [55],  [0],[163],
    [3], [1],  [13],   [5],  [3],[20],
    table.hline(),
  ),
  caption: [Расчёт выражения $X = (8A + 9B)/(7C)$ для трёх различных наборов],
)

#figure(
  image("test_assembly1.png", width: 80%),
  caption: [Вывод тестовых результатов],
) <glacier>

= Выводы
По результатам тестирования можно судить о том, что программа работает корректно. При вводе значений, удовлетворяющих формализации (беззнаковые целые числа от 0 до 2 147 483 647, C ≠ 0), программа вычисляет выражение X = (8A + 9B) / 7C и выводит частное и остаток от деления. При несоблюдении условий, прописанных в формализации (C = 0), программа завершается аварийно, не выдавая результата, что соответствует ожидаемому поведению — деление на ноль в целочисленной арифметике невозможно. Все арифметические операции в программе реализованы исключительно командами для беззнаковых чисел: mulq для умножения и divq для деления, что полностью соответствует требованию использования только беззнаковых команд.
