create line-buffer 1024 allot

: read-line-to-buffer ( -- addr len )
   line-buffer 1024 stdin read-line throw drop
   line-buffer swap ;

create grid 25000 allot
variable grid-length
0 grid-length !

: append-blanks ( n )
   grid-length @ swap
   0 ?do
      dup '.' swap grid + c!
      1+
   loop
   grid-length ! ;

: incr ( addr )   
   1 swap +! ;

: fill-grid ( -- width )
   begin
      read-line-to-buffer
      grid-length @ 0= if
         dup 2 + dup append-blanks
         -rot ( width, buffer-addr, buffer-len )
      then
      dup 0>
   while
      '.' grid grid-length @ + c!
      grid-length incr
      dup -rot
      grid grid-length @ + swap move
      grid-length @ + grid-length !
      '.' grid grid-length @ + c!
      grid-length incr
   repeat
   2drop dup append-blanks ;

: check ( nc width pos -- nc' width )
   grid + c@ '@' = if swap 1+ swap then ;

: remove-accessible ( width -- removed )
   0 swap ( removed width )
   grid-length @ 0 ?do
      grid i + c@ '@' = if
         0 swap ( removed nc width )
         dup i swap - 1- check
         dup i swap - check
         dup i swap - 1+ check
         i 1- check
         i 1+ check
         dup i + 1- check
         dup i + check
         dup i + 1+ check
         swap 4 < if
            ( removed width )
            '.' grid i + c!
            swap 1+ swap
         then
      then
   loop drop ( removed ) ;

: main
   fill-grid
   0 swap
   begin
      dup
      remove-accessible
      dup 0>
   while
      rot + swap
   repeat 2drop ;

main
." Part 2: " . cr
bye
