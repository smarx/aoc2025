256 constant max-line
create line-buffer max-line allot

: read-line-to-buffer
    line-buffer max-line stdin read-line throw ;

variable dial
50 dial !

variable counter
0 counter !

: process-lines
    begin
        read-line-to-buffer
    while
        \ grab the first character of the string
        line-buffer c@
        
        \ check first character, push -1 for L and +1 for R (direction of spin)
        [char] L = if -1 else 1 then swap

        \ /string increments the address and decrements the count (consumes a character)
        line-buffer swap 1 /string

        \ convert to number (two flags that need to get dropped)
        s>number? drop drop

        \ multiply by the direction
        *

        \ add to the current dial, modulo by 100, and put it back in dial, keeping a copy on the stack
        dial @ + 100 mod dup dial !

        \ check if the dial is currently at 0, if so increment counter
        0= if 1 counter +! then
    repeat
    drop ;

process-lines
counter @ . cr
bye
