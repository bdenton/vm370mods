OPRTEST  CSECT ,
         USING *,R15
         ST    R13,CMSSAVE
         LA    R13,MYSAVE
         STM   R14,R12,12(R13)
         LR    R12,R15
         DROP  R15
         USING OPRTEST,R12
         SPACE 1
* Simple test.. write a few lines, cause a HOLDING
         SPACE 1
         LA    R3,MSGS
         LA    R4,MSGCT
LOOP     DS    0H
         SR    R5,R5
         IC    R5,0(,R3)
         LR    R0,R5
         LA    R1,1(,R3)
         L     R15,=V(OPRWT)
         BALR  R14,R15
         LA    R3,1(R5,R3)
         BCT   R4,LOOP
         SPACE 1
         LA    R13,MYSAVE
         LM    R14,R12,12(R13)
         L     R13,CMSSAVE
         SR    R15,R15
         BR    R14
         SPACE 1
CMSSAVE  DC    F'0'
MYSAVE   DC    18F'0'
MSGS     EQU   *
MSG1     DC    AL1(LEN1),C'Message number 1 goes on line 0'
LEN1     EQU   *-MSG1-1
MSG2     DC    AL1(LEN2),C'Message number 2 goes on line 1'
LEN2     EQU   *-MSG2-1
MSG3     DC    AL1(LEN3),C'Message number 3 goes on line 2'
LEN3     EQU   *-MSG3-1
MSG4     DC    AL1(LEN4),C'Message number 4 goes on line 3'
LEN4     EQU   *-MSG4-1
MSG5     DC    AL1(LEN5),C'Message number 5 goes on line 4'
LEN5     EQU   *-MSG5-1
MSG6     DC    AL1(LEN6),C'Message number 6 is long and starts on '
         DC    C'line 5 but is going to overflow onto line 6......'
LEN6     EQU   *-MSG6-1
MSG7     DC    AL1(LEN7),C'Message number 7 goes on line 7'
LEN7     EQU   *-MSG7-1
MSG8     DC    AL1(LEN8),C'Message number 8 goes on line 8'
LEN8     EQU   *-MSG8-1
MSG9     DC    AL1(LEN9),C'Message number 9 goes on line 9'
LEN9     EQU   *-MSG9-1
MSG10    DC    AL1(LEN10),C'Message number 10 goes on line 10'
LEN10    EQU   *-MSG10-1
MSG11    DC    AL1(LEN11),C'Message number 11 goes on line 11'
LEN11    EQU   *-MSG11-1
MSG12    DC    AL1(LEN12),C'Message number 12 goes on line 12'
LEN12    EQU   *-MSG12-1
MSG13    DC    AL1(LEN13),C'Message number 13 goes on line 13'
LEN13    EQU   *-MSG13-1
MSG14    DC    AL1(LEN14),C'Message number 14 goes on line 14'
LEN14    EQU   *-MSG14-1
MSG15    DC    AL1(LEN15),C'Message number 15 goes on line 15'
LEN15    EQU   *-MSG15-1
MSG16    DC    AL1(LEN16),C'Message number 16 goes on line 16'
LEN16    EQU   *-MSG16-1
MSG17    DC    AL1(LEN17),C'Message number 17 goes on line 17'
LEN17    EQU   *-MSG17-1
MSG18    DC    AL1(LEN18),C'Message number 18 goes on line 18'
LEN18    EQU   *-MSG18-1
MSG19    DC    AL1(LEN19),C'Message number 19 goes on line 19'
LEN19    EQU   *-MSG19-1
MSG20    DC    AL1(LEN20),C'Message number 20 goes on line 20'
LEN20    EQU   *-MSG20-1
MSG21    DC    AL1(LEN21),C'Message number 21 is also very long and '
         DC    C'should get pushed to the next page after HOLDING'
LEN21    EQU   *-MSG21-1
MSG22    DC    AL1(LEN22),C'Message number 22 goes on page 2 line 1 '
         DC    C'but is very, very, very long and will ev'
         DC    C'entually get truncated at one point whic'
         DC    C'h should happen about................now'
         DC    C'+++and not see any plus signs'
LEN22    EQU   *-MSG22-1
MSGCT    EQU   22
         SPACE 1
         LTORG
         REGEQU
         END
