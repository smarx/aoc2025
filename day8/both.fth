create line-buffer 10000 allot

1 arg r/o open-file throw ( fileid )

: read-line-to-buffer ( fileid -- fileidd addr len )
   dup line-buffer 10000 rot read-line throw drop
   line-buffer swap ;

create boxes 3000 cells allot
variable box-count
0 box-count !

create circuits 1000 cells allot
create circuit-counts 1000 cells allot
create distances 3000000 cells allot
variable distance-count
create indexes 1000000 cells allot

: read-boxes ( fileid -- fileid )
   begin
      read-line-to-buffer
      dup 0>
   while
      2dup s>number drop -rot
      ',' scan
      1 /string
      2dup s>number drop -rot
      ',' scan
      1 /string
      s>number drop

      swap rot

      box-count @ 1+ 3 * cells boxes + box-count @ 3 * cells boxes + do
         i !
      cell +loop

      box-count @ 1+ box-count !
   repeat 2drop ;

: init-circuits
   box-count @ 0 do
      i dup cells circuits + !
   loop ;

: init-indexes
   distance-count @ 0 do
      i dup cells indexes + !
   loop ;

: count-circuits
   circuit-counts box-count @ cells erase
   box-count @ 0 do
      circuits i cells + @
      cells circuit-counts + dup @ 1+ swap !
   loop ;

: just-one-circuit? ( -- flag )
   0
   box-count @ 0 do
      i cells circuit-counts + @
      0> if
         1+
         dup 1 > if
            drop 0 unloop exit
         then
      then
   loop drop -1 ;

: replace-circuit ( from to -- )
   2dup = if 2drop exit then
   box-count @ 0 do
      over circuits i cells + @
      = if dup circuits i cells + ! then
   loop 2drop ;

: compute-distances
   0 \ count
   box-count @ 0 ?do
      box-count @ i 1+ ?do
         0 \ square distance
         3 0 do
            boxes k 3 * i + cells + @
            boxes j 3 * i + cells + @
            - dup * +
         loop
         over ( count square-distance count )
         3 * cells distances + ! ( count )
         j over 3 * 1 + cells distances + !
         i over 3 * 2 + cells distances + !
         1+
      loop
   loop distance-count ! ;

: print-distances
   distance-count @ 0 ?do
      distances i 3 * cells + @ .
      distances i 3 * 1 + cells + @ .
      distances i 3 * 2 + cells + @ .
      cr
   loop ;

: dist0@ ( i -- distance ) 3 * cells distances + @ ;
: dist1@ ( i -- i ) 3 * 1+ cells distances + @ ;
: dist2@ ( i -- j ) 3 * 2 + cells distances + @ ;

: idx@ ( i -- actual-index ) cells indexes + @ ;
: idx! ( val i -- ) cells indexes + ! ;
: idx-swap ( i j -- )
   2dup = if 2drop exit then
   over idx@ over idx@ ( i j vi vj )
   swap third ( i j vj vi j )
   idx! ( i j vj )
   nip swap idx! ;

: lte ( i j -- flag )
   over dist0@ over dist0@ 2dup <> if
      ( i j i0 j0 )
      < ( i j flag )
      nip nip exit
   then 2drop

   over dist1@ over dist1@ 2dup <> if < nip nip exit then 2drop
   dist2@ ( i j0 ) swap ( j0 i ) dist2@ ( j0 i0 ) swap <= ;

: print-indexes
   distance-count @ 0 ?do
      i idx@ . cr
   loop ;

: print-sorted-distances
   distance-count @ 0 ?do
      i idx@ dist0@ . ." = " i idx@ dist1@ . ." from " i idx@ dist2@ . cr
   loop ;

: partition ( lo hi -- pivot-index )
   ( lo hi==pivot )
   2dup swap ?do
      ( last pivot )
      i idx@ over idx@ lte if
         over i idx-swap
         swap 1+ swap
      then
   loop

   ( last pivot )
   over idx-swap ;

: qsort ( lo hi -- )
   2dup < if
      2dup partition ( lo hi pivot )
      rot over ( hi pivot lo pivot )
      1- recurse
      1+ swap recurse
   else
      2drop
   then ;

: sort-distances
   init-indexes
   0 distance-count @ 1- qsort ;

: join ( n -- )
   0 ?do
      circuits i idx@ dist1@ cells + @
      circuits i idx@ dist2@ cells + @
      replace-circuit
   loop ;

: join-until-one ( -- x-product )
   distance-count 0 ?do
      circuits i idx@ dist1@ cells + @
      circuits i idx@ dist2@ cells + @
      replace-circuit

      count-circuits
      just-one-circuit? if
         i idx@ dist1@ 3 * cells boxes + @
         i idx@ dist2@ 3 * cells boxes + @
         * unloop exit
      then
   loop -1 ;

: max-circuit-count
   circuit-counts @ 0 ( pos max )
   box-count @ 0 do
      circuit-counts i cells + @
      ( pos max candidate )
      2dup < if
         \ new max
         nip nip i swap
      else
         drop
      then
   loop
   swap cells circuit-counts + 0 swap ! ;

read-boxes drop

compute-distances
sort-distances

init-circuits
1000 join
count-circuits
max-circuit-count max-circuit-count max-circuit-count * *
." Part 1: " . cr

init-circuits
join-until-one
." Part 2: " . cr

bye
