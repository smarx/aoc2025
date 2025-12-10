create line-buffer 1000 allot

1 arg r/o open-file throw ( fileid )

: read-line-to-buffer ( fileid -- fileid addr len )
   dup line-buffer 1000 rot read-line throw drop
   line-buffer swap ;

create tiles 1000 cells allot
variable tile-count
0 tile-count !

: read-tiles
   begin
      read-line-to-buffer
      dup 0>
   while
      2dup s>number drop
      tiles tile-count @ 2 * cells + !
      ',' scan
      1 /string
      s>number drop
      tiles tile-count @ 2 * 1+ cells + !
      tile-count @ 1+ tile-count !
   repeat 2drop ;

: print-tiles
   tile-count @ 0 ?do
      tiles i 2 * cells + @ .
      tiles i 2 * 1+ cells + @ .
      cr
   loop ;

: x ( i -- x )
   2 * cells tiles + @ ;

: y ( i -- y )
   2 * 1+ cells tiles + @ ;

: area ( i j -- area )
   2dup x swap x - abs 1+ -rot
   y swap y - abs 1+
   * ;

variable part1
0 part1 !
variable part2
0 part2 !

: out-of-range? ( v1 v2 value -- flag )
   dup 2swap ( value value v1 v2 )
   2dup > if swap then
   ( value value min-value max-value )
   rot <= -rot <= or ;

: overlaps? ( b1 b2 l1 l2 -- flag )
   2dup > if swap then
   2swap 2dup > if swap then
   ( l1 l2 b1 b2 )
   -rot ( l1 b2 l2 b1 )
   > -rot < and ;

: process
   tile-count @ 0 ?do
      tile-count @ i 1+ ?do
         part1 @ j i area max part1 !

         -1 \ valid
         tile-count @ 0 ?do
            \ i == l1
            \ j == c2
            \ k == c1

            i i 1+ tile-count @ mod ( l1 l2 )

            x swap x = if
               \ vertical
               k x j x i x out-of-range? 0= if
                  k y j y i y i 1+ tile-count @ mod y overlaps? if
                     drop 0
                     leave
                  then
               then
            else
               \ horizontal
               k y j y i y out-of-range? 0= if
                  k x j x i x i 1+ tile-count @ mod x overlaps? if
                     drop 0
                     leave
                  then
               then
            then
         loop

         if
            part2 @ j i area max part2 !
         then
      loop
   loop ;

read-tiles drop
process
." Part 1: " part1 @ . cr
." Part 2: " part2 @ . cr
bye
