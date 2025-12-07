create line-buffer 10000 allot

1 arg r/o open-file throw ( file id )

: read-line-to-buffer ( fileid -- fileid addr len )
   dup line-buffer 10000 rot read-line throw drop
   line-buffer swap ;

create beams here 10000 dup allot erase
variable width
0 width !

variable split-count
0 split-count !

: print-beams
   width @ 0 ?do
      beams i cells + @ .
   loop cr ;

: sum-beams
   0
   width @ 0 ?do
      beams i cells + @ +
   loop ;

: process-lines ( fileid -- )
   begin
      read-line-to-buffer
      dup
   while
      width @ 0= if width ! else drop then
      width @ 0 ?do
         dup i + c@
         dup 'S' = if
            1 i cells beams + !
         then
         '^' = if
            i cells beams + @
            dup 0> if
               split-count @ 1+ split-count !

               0 i cells beams + !

               i 0> if
                  dup i 1- cells beams + +!
               then

               i width @ 1- < if
                  dup i 1+ cells beams + +!
               then
            then
            drop
         then
      loop
      drop
   repeat 2drop drop ;

process-lines
." Part 1: " split-count @ . cr
." Part 2: " sum-beams . cr
bye
