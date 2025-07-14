ID MAINT
:READ OPRTST2 ASSEMBLE
OPRTST2  CSECT ,
         USING *,R15
         ST    R13,CMSSAVE
         LA    R13,MYSAVE
         STM   R14,R12,12(R13)
         LR    R12,R15
         DROP  R15
         USING OPRTST2,R12
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
         CLI   0(R1),C'?'
         BE    READ
         L     R15,=V(OPRWT)
         BALR  R14,R15
         B     NEXT
READ     DS    0H
         BCTR  R0,0
         LA    R1,1(,R1)
         L     R15,=V(OPRWR)
         BALR  R14,R15
         LTR   R6,R0
         BNZ   HAVE
         WRTERM '==> No data entered'
         B     NEXT
HAVE     DS    0H
         LR    R7,R1
         LINEDIT TEXT='==> |...........................................X
               ...............| (len=...)',                            X
               SUB=(CHARA,((R7),(R6)),DEC,(R6)),                       X
               RENT=NO
NEXT     DS    0H
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
LNEDIT   LINEDIT MF=L,MAXSUBS=5
MSGS     EQU   *
MSG1     DC    AL1(LEN1),C'?Prompt message 1 goes on line 0.. Enter: '
LEN1     EQU   *-MSG1-1
MSG2     DC    AL1(LEN2),C'Message number 2 goes on line 1'
LEN2     EQU   *-MSG2-1
MSG3     DC    AL1(LEN3),C'?Prompt message 3 is long and starts on '
         DC    C'line 2 but is going to overflow onto line 3......'
         DC    C' Enter: '
LEN3     EQU   *-MSG3-1
MSG4     DC    AL1(LEN4),C'Message number 4 goes on line 4'
LEN4     EQU   *-MSG4-1
MSG5     DC    AL1(LEN5),C'?Prompt message 5 goes on line 5 but len='
         DC    C'75. More than 3 chars go on ln 6:  '
LEN5     EQU   *-MSG5-1
MSG6     DC    AL1(LEN6),C'Message number 6 goes on line 6 or 7'
LEN6     EQU   *-MSG6-1
MSGCT    EQU   6
         SPACE 1
         LTORG
         REGEQU
         END
