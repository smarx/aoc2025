create line-buffer 10000 allot

1 arg r/o open-file throw ( fileid )

: read-line-to-buffer ( fileid -- fileid addr len )
   dup line-buffer 10000 rot read-line throw drop
   line-buffer swap ;

create text 100000 allot
variable length
0 length !
variable width
0 width !
: read-data ( fileid )
   begin
      read-line-to-buffer
      dup
   while
      width @ 0= if
         dup width !
      then
      ( addr len )
      dup -rot
      text length @ + swap move
      length +!
   repeat 2drop ;

: process-data
   0 -1 ( total sentinel )
   width @ 0 ?do
      -1 ( current-value )
      length @ width @ / 1- 0 ?do
         width @ i * width @ 1- j - + text + c@
         dup bl <> if
            over -1 = if swap drop 0 swap then
            '0' - swap 10 * +
         else
            drop
         then
      loop

      length @ 1- i - text + c@ \ get last row
      dup '+' = if
         drop
         dup -1 = if drop then \ drop value if it's -1
         0
         begin
            over -1 <>
         while
            +
         repeat
         swap drop +
      else
         '*' = if
            dup -1 = if drop then \ drop value if it's -1
            1
            begin
               over -1 <>
            while
               *
            repeat
            swap drop +
         then
      then
   loop ;

read-data drop
process-data
." Part 2: " . cr
bye
