\ tests/some_test.4th — ttester sanity (fmix scaffold).

require ../forth-packages/ttester/1.2.1/ttester.4th

0 #ERRORS !

T{ 1 2 3 SWAP -> 1 3 2 }T

#ERRORS @ 0= [IF] ." some_test OK" cr [ELSE] ." some_test FAILED" cr [THEN]
