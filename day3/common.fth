create line-buffer 1024 allot

: read-line-to-buffer ( -- addr len )
   line-buffer 1024 stdin read-line throw drop
   line-buffer swap ;

variable total
0 total !
variable digit-count
2 digit-count !

: max-digit ( addr len )
   0 0 ( addr len best-location best-value )
   rot 0 ?do
      ( addr best-location best-value )
      third c@ '0' - over > if
         2drop i over c@ '0' -
      then
      rot 1+ -rot
   loop
   rot drop ;

variable max-joltage
: process-line ( addr len -- )
   0 max-joltage !
   digit-count @ 0 ?do
      2dup digit-count @ i - - 1+
      max-digit ( addr len location value )
      max-joltage @ 10 * + max-joltage !
      1+ /string
   loop
   max-joltage @ total +!
   2drop ;

: process-lines ( -- )
   begin
      read-line-to-buffer
      dup 0>
   while
      process-line
   repeat
   2drop ;
