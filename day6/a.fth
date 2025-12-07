: skip-whitespace ( addr len -- addr' len' found-newline )
   0 -rot
   begin
      over c@
      dup 10 = if
         2swap swap drop -1 swap 2swap
      then
      dup 10 = swap bl = or
   while
      1 /string
   repeat
   rot ;

create numbers 100000 allot
variable numbers-count
0 numbers-count !

variable per-row
0 per-row !

: read-numbers ( addr len - )
   begin
      skip-whitespace
      per-row @ 0= and if
         numbers-count @ per-row !
      then
      over c@ dup '*' <> swap '+' <> and
   while
      0 -rot
      begin
         over c@
         dup dup bl <> swap 10 <> and
      while
         '0' -
         -rot 2swap swap 10 * + -rot
         1 /string
      repeat
      drop
      rot numbers-count @ cells numbers + !
      numbers-count @ 1+ numbers-count !
   repeat ;

: print-numbers
   numbers-count @ 0 ?do
      i cells numbers + @ . cr
   loop ;

: do-math ( addr len -- total )
   0 -rot
   per-row @ 0 ?do
      skip-whitespace
      drop
      over c@ '*' = if
         1
         numbers-count @ per-row @ / 0 ?do
            per-row @ i * j + cells numbers + @ *
         loop
      else over c@ '+' = if
         0
         numbers-count @ per-row @ / 0 ?do
            per-row @ i * j + cells numbers + @ +
         loop
      then then
      ( total addr len result )
      -rot 2swap + -rot
      1 /string
   loop 2drop ;

next-arg slurp-file
2dup 10 scan drop third - -rot

read-numbers
do-math
." Part 1: " . cr
bye
