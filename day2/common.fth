create line-buffer 1024 allot

: read-line-to-buffer ( -- addr len )
   line-buffer 1024 stdin read-line throw drop
   line-buffer swap ;

: index-of ( addr len char -- n )
   2 pick -rot
   scan ( addr remaining len )
   if
      swap -
   else
      2drop -1
   then ;

: split-map { addr len char xt -- }
   begin
      addr len char index-of
      addr swap
      dup 0>=
   while
      dup -rot
      xt execute
      addr len rot 1 + /string to len to addr
   repeat
   drop
   len 0> if addr len xt execute then drop ; 

: count-digits ( n -- digits )
   1 swap
   begin
      10 /
      dup 0>
   while
      swap 1+ swap
   repeat
   drop ;

: ** ( base exp -- result )
   1 swap
   0 ?do
      over *
   loop nip ;

: geometric-sum ( base exp_step num_terms -- result )
   -rot ** dup 1 - -rot swap ** 1 - swap / ;

variable part1
-1 part1 !

: part1-start ( length )
   \ A bit hacky, but for part 2 we want to loop from 1 to half the length,
   \ and for part 1, we just want to try half the length. If the length isn't
   \ divisible by 0, we just return more than half the length (to skip the loop).
   \ Otherwise we return half the length.
   dup 2 mod 0= if
      2 /
   else
      2 / 1+
   then ;

: invalid? ( n )
   dup count-digits ( n length )
   dup 2 / 1+ part1 @ if over part1-start else 1 then ?do
      \ ." for number " over . ." with length " dup . ." about to try repeating length " i . cr
      dup i mod 0= if
         2dup i - 10 swap ** / ( n length prefix )
         over i / i swap 10 -rot ( n length prefix 10 i length/i )
         geometric-sum ( n length prefix geometric-sum )
         * ( n length repeated-version )
         third = ( n length did-match )
         if drop drop unloop -1 exit then
      then
   loop
   drop drop 0 ;

variable total
0 total !
: process-range ( addr len -- )
   swap 2dup swap [char] - index-of
   2dup s>number? drop drop >r
   rot swap 1+ /string s>number? drop drop 1+ r>
   do
      i invalid? if i total +! then
   loop ;

: main
   read-line-to-buffer
   [char] , ['] process-range split-map ;
