create line-buffer 1024 allot

: read-line-to-buffer ( -- addr len )
   line-buffer 1024 stdin read-line throw drop
   line-buffer swap ;

create ranges 25000 allot
variable range-length
0 range-length !

: read-ranges
   begin
      read-line-to-buffer
      dup 0>
   while
      2dup '-' scan 1- nip
      2 pick swap 2dup s>number drop
      \ ." start of range: " dup . cr
      ranges range-length @ 2 * cells + !
      2drop
      '-' scan 1 /string s>number drop
      \ ." end of range: " dup . cr
      ranges range-length @ 2 * 1+ cells + !
      1 range-length +!
   repeat
   2drop ;

: check ( n -- flag )
   range-length @ 0 ?do
      dup ranges i 2 * cells + @ >= if
         dup ranges i 2 * 1+ cells + @ <= if
            drop -1 unloop exit
         then
      then
   loop drop 0 ;

: check-ids ( -- in-range-count )
   0
   begin
      read-line-to-buffer
      dup 0>
   while
      s>number drop
      check if 1+ then
   repeat
   2drop ;

: min-starting-at ( n )
   dup
   dup 2 * cells ranges + @
   over 2 * 1+ cells ranges + @
   ( n min-pos min-l min-r )
   third range-length @ swap ?do
      2dup
      ranges i 2 * cells + @
      ranges i 2 * 1+ cells + @
      \ ." Trying candidate:" .s cr
      ( min-l min-r candidate-l candidate-r )
      rot swap
      ( min-l candidate-l min-r candidate-r )
      > -rot 2dup = -rot >
      ( min-r>candidate-r min-l=candidate-l min-l>candidate-l )
      -rot
      ( min-l>candidate-l min-r>candidate-r min-l=candidate-l )
      and or if
         \ ." Found one." cr
         2drop drop
         i
         ranges i 2 * cells + @
         ranges i 2 * 1+ cells + @
      then
   loop
   2swap swap
   2dup
   2 * cells ranges + @
   swap
   2 * cells ranges + !

   2 * 1+ cells ranges + @
   swap
   2 * 1+ cells ranges + ! ;

: sum-ranges ( -- count )
   0 0 ( count prev )
   range-length @ 0 ?do
      i min-starting-at
      ( count prev l r )
      ." Count, prev, l, r: " .s cr
      third over < ( count prev l r prev<r )
      if
         ( count prev l r )
         dup rot fourth
         ( count prev r r l prev )
         1+ swap max - 1+ -rot
         ( count additional prev r )
         2swap + -rot
         ( count' prev r )
         max
         ( count' prev' )
      else
         2drop
      then
   loop
   drop ;

read-ranges
check-ids
." Part 1: " . cr

sum-ranges
." Part 2: " . cr
bye
