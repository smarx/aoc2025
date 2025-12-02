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
        read-line-to-buffer over 0 <> swap -1 = and
    while
        \ read the first character from the string
        line-buffer c@

        \ check first character, push -1 for L and +1 for R (direction of spin)
        [char] L = if -1 else 1 then swap

        \ /string increments the address and decrements the count (consumes a character)
        line-buffer swap 1 /string

        \ convert to number (two flags that need to get dropped)
        s>number? drop drop

        \ magic I can't quite explain...
        \ turns ( direction, amount ) into ( old dial possibly +100, direction, amount )
        \ We add 100 specifically if the direction is -1 and we're starting at 0. This avoids having
        \ to figure out that going -1 from 0 did not pass 0 at all.
        over -1 = dial @ dup -rot 0= and if 100 + then -rot
        
        \ multiply by the direction
        *

        \ s>d converts a single-cell signed int to a double-cell one via sign extension
        \ 100 sm/rem divides by 100 and gets both the quotient and remainder, doing symmetric
        \ division rather than floored
        \ Then we count all the 100s (laps around the whole dial) up front.
        s>d 100 sm/rem abs counter +!

        \ Finally we add whatever's left to the dial.
        +

        \ If we hit 100 or dropped to 0 or below, then we have one more to count.
        dup dup 0<= swap 100 >= or if 1 counter +! then

        \ Finally mod the result by 100 to get a new dial position.
        100 mod dial !
    repeat
    drop ;

process-lines
counter @ . cr
bye
