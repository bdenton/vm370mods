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
         LINEDIT TEXT='==> !...........................................X
               ...............! (len=...)',SUB=(CHARA,(R7,R6),DEC,(R6))X
               ,RENT=NO                  
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
:READ TSTOPR ASSEMBLE
OPR      TITLE 'DMKOPR     (CP)        VM/370 - RELEASE 6'              00001000
**       ISEQ  73,80          VALIDATE SEQUENCING OF ASSEMBLE FILE      00002000
*.                                                                      00003000
* MODULE NAME -                                                         00004000
*                                                                       00005000
*        DMKOPR                                                         00006000
*                                                                       00007000
* FUNCTION -                                                            00008000
*                                                                       00009000
*        PROVIDE THE NECCESSARY SUPPORT FOR FOR VM/370 CONSOLE.         00010000
*        CERTAIN ROUTINES WITHIN THE CONTROL PROGRAM CAN NOT            00011000
*        CALL DMKQCN TO ISSUE WRITES TO THE SYSTEM OPERATOR,            00012000
*        THIS MODULE WILL DETERMINE THE SYSTEM'S PRIMARY CONSOLE ;      00013000
*        (3210, 3215, 3066, 3270,3278), AND BUILD A CHANNEL PROGRAM     00014000
*        TO HANDLE THE REQUESTED CALL.                                  00015000
*                                                                       00016000
*.                                                                      00017000
         EJECT                                                          00018000
         COPY  OPTIONS                                                  00019000
         COPY  LOCAL OPTIONS                                            00020000
         EJECT                                                          00021000
TSTOPR   CSECT                                                          00022000
         USING PSA,R0                                                   00023000
***      USING RDEVBLOK,R8    REAL DEVICE BLOCK                         00024000
*/ D 00024000
         SPACE                                                          00025000
         WXTRN DMKRIODV,DMKRIOCN                               @V200820 00026000
*/ R 00027000 $ 00027100
         ENTRY OPRWT,OPRWR                                     HRC241DK 00027100
         SPACE                                                          00028000
*.                                                                      00029000
* SUBROUTINE NAME -                                                     00030000
*                                                                       00031000
*        DMKOPRWT - TO WRITE TO SYSTEMS CONSOLE                         00032000
*                                                                       00033000
* FUNCTION -                                                            00034000
*                                                                       00035000
*        TO INITIATE WRITE TO THE PRIMARY SYSTEMS CONSOLE               00036000
*                                                                       00037000
* ATTRIBUTES -                                                          00038000
*                                                                       00039000
*        SERIALLY REUSABLE, CALLED BY BALR  R14,R15                     00040000
*                                                                       00041000
* ENTRY CONDITIONS -                                                    00042000
*                                                                       00043000
*        GPR0  = MAXIMUM NUMBER OF BYTES                                00044000
*        GPR1  = ADDRESS OF BUFFER                                      00045000
*        GPR2  = PARAMETER REGISTER -                                   00046000
*                 NOAUTO - PREVENT AUTO-CARRIAGE RETURN                 00047000
*                 ALARM - RING THE ALARM                                00048000
*        GPR14 = RETURN ADDRESS                                         00049000
*        GPR15 = ADDRESS OF DMKOPRWT                                    00050000
*                                                                       00051000
* EXIT CONDITIONS -                                                     00052000
*                                                                       00053000
*        GPR0 - GPR15 = UNCHANGED                                       00054000
*        CONDITION CODE = 0     (NO ERRORS DETECTED)                    00055000
*        CONDITION CODE = 1     (ERROR DETECTED - EXAMINE CSW)          00056000
*        CONDITION CODE = 2     (MISUSE OF PARAMETERS)                  00057000
*        CONDITION CODE = 3     (DEVICE IS NON-EXISTANT)                00058000
*                                                                       00059000
* CALLS TO OTHER ROUTINES -   NONE                                      00060000
*                                                                       00061000
* EXTERNAL REFERENCES -                                                 00062000
*                                                                       00063000
*        DMKRIODV - ADDRESS OF REAL DEVICE BLOCKS                       00064000
*        DMKRIOCN - ADDRESS OF POINTER TO SYSTEM PRIMARY CONSOLE        00065000
*                                                                       00066000
* TABLES / WORK AREAS -       NONE                                      00067000
*                                                                       00068000
* REGISTER USAGE -                                                      00069000
*        GPR0  = MAXIMUM BYTE COUNT                                     00070000
*        GPR1  = ADDRESS OF CALLERS BUFFER                              00071000
*/ R 0072000 $ 0072100 100
*        GPR3 - GPR11  = Work registers                        HRC241DK 00072100
*        GPR12 = Module base register                          HRC241DK 00072200
*        GPR13 = UNUSED                                                 00073000
*        GPR14 = RETURN REGISTER                                        00074000
*/ R 00075000 $ 00075100
*        GPR15 = Work register                                 HRC241DK 00075100
*.                                                                      00076000
*/ R 00077000 00100000 $ 00077101 50
         SPACE 3                                               HRC241DK 00077101
OPRWT    DS    0H                                              HRC241DK 00077151
         USING *,R15              Temporary base               HRC241DK 00077201
         STM   R0,R15,OPREGS      Save caller's registers      HRC241DK 00077251
         LR    R12,R15            Setup module base register   HRC241DK 00077301
         SL    R12,=A(OPRWT-TSTOPR) ...                        HRC241DK 00077351
         DROP  R15                Set permanent addresing      HRC241DK 00077401
         USING TSTOPR,R12         ...                          HRC241DK 00077451
         SPACE 1                                               HRC241DK 00077501
         ST    R2,PARM2           Save parameters              HRC241DK 00077551
         B     COMMON               and join common code below HRC241DK 00077601
         EJECT ,                                               HRC241DK 00077651
*------------------------------------------------------------  HRC241DK 00077701
* SUBROUTINE NAME -                                            HRC241DK 00077751
*                                                              HRC241DK 00077801
*        DMKOPRWR - Write prompt to console & read response    HRC241DK 00077851
*                                                              HRC241DK 00077901
* ENTRY CONDITIONS -                                           HRC241DK 00077951
*                                                              HRC241DK 00078001
*        R0 = Length of the prompt message                     HRC241DK 00078051
*        R1 = Address of the prompt message                    HRC241DK 00078101
*        R2 = Paremeters (see EQU COPY)                        HRC241DK 00078151
*                 NOAUTO - no line feed (implied)              HRC241DK 00078201
*                 ALARM - sound the alarm                      HRC241DK 00078251
*        R14 = Return address                                  HRC241DK 00078301
*        R15 = Entry point (DMKOPRWR) address                  HRC241DK 00078351
*                                                              HRC241DK 00078401
* EXIT CONDITIONS -                                            HRC241DK 00078451
*                                                              HRC241DK 00078501
*        CC = 0 : Success                                      HRC241DK 00078551
*                 R0 = Length of the response data             HRC241DK 00078601
*                 R1 = Address of the response data            HRC241DK 00078651
*        CC ^= 0 : Error or no console available               HRC241DK 00078701
*                                                              HRC241DK 00078751
*------------------------------------------------------------  HRC241DK 00078801
         SPACE 3                                               HRC241DK 00078851
OPRWR    DS    0H                                              HRC241DK 00078901
         USING *,R15              Temporary base               HRC241DK 00078951
         STM   R0,R15,OPREGS      Save caller's registers      HRC241DK 00079001
         LR    R12,R15            Setup module base register   HRC241DK 00079051
         SL    R12,=A(OPRWR-TSTOPR) ...                        HRC241DK 00079101
         DROP  R15                Set permanent addresing      HRC241DK 00079151
         USING TSTOPR,R12         ...                          HRC241DK 00079201
         SPACE 1                                               HRC241DK 00079251
         ST    R2,PARM2           Save parameters              HRC241DK 00079301
         OI    PARM2,DOREAD         add the read option        HRC241DK 00079351
         OI    PARM,NOAUTO            and NOAUTO is default    HRC241DK 00079401 
         EJECT ,                                               HRC241DK 00079451
*------------------------------------------------------------  HRC241DK 00079501
*        Common processing for all entry points                HRC241DK 00079551
*------------------------------------------------------------  HRC241DK 00079601
         SPACE 1                                               HRC241DK 00079651
COMMON   DS    0H                                              HRC241DK 00079701
*        TM    STATUS,DIDINIT Did we already find console?     HRC241DK 00079751
*        BO    ISINIT         yes, skip                        HRC241DK 00079801
*        BAL   R10,INITCONS   no, go find available console    HRC241DK 00079851
*        BNZ   SETCC3         none found, return CC3           HRC241DK 00079901
         SPACE 3                                               HRC241DK 00079951
*------------------------------------------------------------  HRC241DK 00080001
*        Write mesage to operator console                      HRC241DK 00080051
*        -- Prepare the 3210/3215 channel program.             HRC241DK 00080101
*           It will be translated to a 3066/327x               HRC241DK 00080151
*           channel program in the Start-I/O routine           HRC241DK 00080201
*------------------------------------------------------------  HRC241DK 00080251
         SPACE 1                                               HRC241DK 00080301
ISINIT   DS    0H                                              HRC241DK 00080351
         STCM  R1,B'0111',WRT3210+1 RESOLVE CCW DATA ADDRESS   @V200731 00101000
         STH   R0,WRT3210+6   STORE CCW COUNT                           00102000
*/ R 00103000 00139000 $ 00103001 50
         MVI   WRT3210,WRT    Operation = Write/CR             HRC241DK 00103001
         TM    PARM,NOAUTO    Was NOAUTO option given?         HRC241DK 00103051 
         BNO   *+8            ..no, all is well                HRC241DK 00103101
         MVI   WRT3210,WRTNC  ..yes, use the NOCR OpCode       HRC241DK 00103151
         LA    R1,WRT3210     Point to channel program         HRC241DK 00103201
         TM    PARM,ALARM     Was ALARM option given?          HRC241DK 00103251
         BNO   *+8            ..no, ready to go                HRC241DK 00103301
         LA    R1,ALRM3210    ..yes, ring alarm first          HRC241DK 00103351
         SPACE 1                                               HRC241DK 00103401
         BAL   R10,STARTIO    Write message on console         HRC241DK 00103451
         SPACE 3                                               HRC241DK 00103501
*------------------------------------------------------------  HRC241DK 00103551
*        Read the operator's response if asked                 HRC241DK 00103601
*------------------------------------------------------------  HRC241DK 00103651
         SPACE 1                                               HRC241DK 00103701
         TM    PARM2,DOREAD   Is a response required?          HRC241DK 00103751
         BNO   SETCC0         ..no, just return to caller      HRC241DK 00103801
         XC    INDATA,INDATA  Clean input area                 HRC241DK 00103851
         XC    INLEN,INLEN    and set length = 0               HRC241DK 00103901
         LA    R1,RD3210      -> console read chan program     HRC241DK 00103951
         BAL   R10,STARTIO    and read operator response       HRC241DK 00104001
         SR    R0,R0          Pass back length in R0           HRC241DK 00104051
         TM    STATUS,NODATA  no data entered?                 HRC241DK 00104101
         BO    R0ONLY         ..yes, just a zero in R0         HRC241DK 00104151
         LH    R0,INLEN       ...                              HRC241DK 00104201
         LA    R1,INDATA      and pass address in R1           HRC241DK 00104251
         ST    R1,OPREG1      ...                              HRC241DK 00104301
R0ONLY   DS    0H                                              HRC241DK 00104351
         ST    R0,OPREG0      ...                              HRC241DK 00104401
         B     SETCC0         and return to caller             HRC241DK 00104451
         EJECT ,                                               HRC241DK 00104501
*------------------------------------------------------------  HRC241DK 00104551
*        STARTIO - Perform Console I/O                         HRC241DK 00104601
*        Input R1 -> Channel program to execute                HRC241DK 00104651
*              R10 = Return sddress                            HRC241DK 00104701
*------------------------------------------------------------  HRC241DK 00104751
         SPACE 1                                               HRC241DK 00104801
STARTIO  DS    0H                                              HRC241DK 00104851
         STM   R0,R15,IOREGS                                   HRC241DK 00104901
         TM    STATUS,CNGRAF  Working with rgaphic console?    HRC241DK 00104951
         BO    GRAFXLAT      ..yes, translate the CCWs         HRC241DK 00105001
         LA    R10,GRAFRET   ..no, just return after the I/O   HRC241DK 00105001
         SPACE 1                                               HRC241DK 00105051
STARTIO1 DS    0H                                              HRC241DK 00105101
         STNSM SYSMASK,0      Disable interupts                HRC241DK 00105101
         LH    R3,CONSADDR    Get console device address       HRC241DK 00105151
         LA    R9,TIOT1       Retry TIO to clear device        HRC241DK 00105201
         L     R4,XRIGHT16    GET THE TIMEOUT COUNT            @V200731 00140000
TIOT1    EQU   *                                               @V200731 00141000
         TIO   0(R3)          CLEAR ANY OUTSTANDING STATUS     @V200731 00142000
         BO    SETCC3         NOT OPERATIONAL - SET CC = 3     @V200731 00143000
         BC    4+2,TESTLOOP   GO DECREMENT COUNT               @V200731 00144000
*/ R 00145000 $ 00145001 100
         ST    R1,CAW         Store Channel Program address    HRC241DK 00145001
         XC    CSWSTAT,CSWSTAT and clear accumulated status    HRC241DK 00145101
         XC    CSWCOUNT,CSWCOUNT and clear residual count      HRC241DK 00145201
         XC    CSW,CSW        CLEAR CSW FIELD                  @V200731 00146000
         LA    R5,10          ERROR RETRY COUNT = 10           @V200731 00147000
SIORETR1 EQU   *                                               @V200731 00148000
         SIO   0(R3)          ISSUE SIO                        @V200731 00149000
*/ R 00150000 $ 00150001 100
         BC    1,SETCC3       CC3: Not available               HRC241DK 00150001
         BC    2,TESTLOOP     CC2: Busy - retry                HRC241DK 00150101
         BC    4,CSWSTOR      CC1: CSW Stored                  HRC241DK 00150201
         LA    R9,TIOT2       Retry TIO to wait finish         HRC241DK 00150301
         L     R4,XRIGHT16    GET THE TIMEOUT COUNT            @V200731 00151000
TIOT2    EQU   *                                               @V200731 00152000
         TIO   0(R3)          WAIT FOR DEVICE END STATUS       @V200731 00153000
         BO    SETCC3         NOT OPERATIONAL - SET CC = 3     @V200731 00154000
*/ R 00155000 00184000 $ 00155001 50
         BC    2,TESTLOOP     CC2: Busy - retry                HRC241DK 00155001
         BC    4,CSWSTOR      CC1: CSW Stored                  HRC241DK 00155001
         TM    CSWSTAT,UC     Was there an arror               HRC241DK 00155001
         BNO   IOEND          ..no, operation finished         HRC241DK 00155001
SIORETRY DS    0H                                              HRC241DK 00155001
         BCT   R5,SIORETR1    Decrement & retry errors         HRC241DK 00155001
         B     SETCC1         Return CC=1 (permanent error)    HRC241DK 00155001
TESTLOOP DS    0H                                              HRC241DK 00155001
         BCTR  R4,R9          Decrement & retry the TIO        HRC241DK 00155001
         B     SETCC2         Return CC=2                      HRC241DK 00155001
         SPACE 3                                               HRC241DK 00155001
CSWSTOR  DS    0H                                              HRC241DK 00155001
         OC    CSWSTAT,CSW+4  Accomulate status flags          HRC241DK 00155001
         TM    CSWSTAT+1,X'3F' any channel-level errors?       HRC241DK 00155001
         BNZ   SETCC3         ..yes, permenent failure         HRC241DK 00155001
         BAL   R8,GETRESCT    Get residual count               HRC241DK 00155001
         B     TESTLOOP       and retry one of the TIOs        HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
IOEND    DS    0H                                              HRC241DK 00155001
         BAL   R8,GETRESCT    Capture residual count           HRC241DK 00155001
         SSM   SYSMASK        Reenable interupts               HRC241DK 00155001
         BR    R10            Return to caller                 HRC241DK 00155001
         SPACE 3                                               HRC241DK 00155001
*------------------------------------------------------------  HRC241DK 00155001
*        GETRESCT - Get posssible residual count from CCW      HRC241DK 00155001
*        -- Last executed CCW must have length > 1             HRC241DK 00155001
*------------------------------------------------------------  HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
GETRESCT DS    0H                                              HRC241DK 00155001
         SR    R1,R1          Clear register                   HRC241DK 00155001
         ICM   R1,7,CSW+1     Look at last CCW executed        HRC241DK 00155001
         BZR   R8             ... is none                      HRC241DK 00155001
         SH    R1,=H'8'       ... (back up one)                HRC241DK 00155001
         LH    R1,6(,R1)      Get CCW count field              HRC241DK 00155001
         CH    R1,=H'1'       CCW count > 1?                   HRC241DK 00155001
         BNHR  R8             ..no, don't care                 HRC241DK 00155001
         LH    R1,CSW+6       ..yes, save CSW residual count   HRC241DK 00155001
         STH   R1,CSWCOUNT    ...                              HRC241DK 00155001
         BR    R8             and return                       HRC241DK 00155001
         EJECT ,                                               HRC241DK 00155001
*------------------------------------------------------------  HRC241DK 00155001
*        GRAFXLAT - Execute the graphic console I/O            HRC241DK 00155001
*        Input R1 -> Channel program to execute                HRC241DK 00155001
*------------------------------------------------------------  HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
GRAFXLAT DS    0H                                              HRC241DK 00155001
         LR    R4,R1          Get 1st CCW address              HRC241DK 00155001
*                                                              HRC241DK 00155001
*        Loop thru the 3210/15 CCWs and perform the            HRC241DK 00155001
*        equivalent action on the graphic console              HRC241DK 00155001
*                                                              HRC241DK 00155001
GETCCW   DS    0H                                              HRC241DK 00155001
         LH    R2,6(,R4)      R2 = current CCW data length     HRC241DK 00155001
         L     R3,0(,R4)      R3 = current CCW data address    HRC241DK 00155001
         LA    R3,0(,R3)      ...                              HRC241DK 00155001
         LA    R14,GRAFOPS    Get address of routint table     HRC241DK 00155001
         LA    R15,GRAFOPSL     and number of entries          HRC241DK 00155001
CCWEXEC  DS    0H                                              HRC241DK 00155001
         L     R1,0(,R14)     Get next entry                   HRC241DK 00155001
         EX    R1,CKOPCODE    Does the opcode match?           HRC241DK 00155001
         BE    GRAFROUT       ..yes, transfer to graphic rtn   HRC241DK 00155001
         LA    R14,4(,R14)    Next table entry                 HRC241DK 00155001
         BCT   R15,CCWEXEC    and search the whole table       HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
*        Ignore CCWS we don't understand                       HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
CCWNEXT  DS    0H                                              HRC241DK 00155001
         TM    4(R4),CC       Command chaining                 HRC241DK 00155001
         LA    R4,8(,R4)      ..yes, process the next one      HRC241DK 00155001
         BO    GETCCW         ...                              HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
GRAFRET  DS    0H                                              HRC241DK 00155001
         LM    R0,R15,IOREGS  Return to caller of STARTIO      HRC241DK 00155001
         BR    R10                                             HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
GRAFROUT DS    0H             Go to the graphic routine        HRC241DK 00155001
         SRL   R1,8           ... shift out the CCW opcode     HRC241DK 00155001
         BR    R1             ... and go to the address        HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
CKOPCODE CLI   0(R4),*-*      (Executed)                       HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
         DS    0F             (alignment)                      HRC241DK 00155001
GRAFOPS  DS    0AL4                                            HRC241DK 00155001
         DC    AL3(GRAFREAD),AL1(RD)                           HRC241DK 00155001
         DC    AL3(GRAFWRIT),AL1(WRTNC)                        HRC241DK 00155001
         DC    AL3(GRAFWRIT),AL1(WRT)                          HRC241DK 00155001
         DC    AL3(CCWNEXT),AL1(ALRM)   Ignore 3210 alarm      HRC241DK 00155001
         DC    AL3(CCWNEXT),AL1(NOP)    and ignore NOP         HRC241DK 00155001
GRAFOPSL EQU   (*-GRAFOPS)/L'GRAFOPS                           HRC241DK 00155001
         EJECT ,                                               HRC241DK 00155001
*------------------------------------------------------------  HRC241DK 00155001
*        GRAFWRIT - Write message to graphic console           HRC241DK 00155001
*        Input R2 = Message length                             HRC241DK 00155001
*              R3 = Message address                            HRC241DK 00155001
*------------------------------------------------------------  HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
GRAFWRIT DS    0H                                              HRC241DK 00155001
*                                                              HRC241DK 00155001
*        First, see if there is room in the graphic            HRC241DK 00155001
*        console data area for the message. At the             HRC241DK 00155001
*        same time, truncate excessively long messages         HRC241DK 00155001
*                                                              HRC241DK 00155001
         LA    R0,80          (line length)                    HRC241DK 00155001
         LA    R1,1           Assume just a single line        HRC241DK 00155001
         CR    R2,R0          Single line message?             HRC241DK 00155001
         BNH   GWRT1          ..yes, continue                  HRC241DK 00155001
         LA    R1,2           Need 2 lines of output           HRC241DK 00155001
         SLL   R0,1           (length of 2 lines)              HRC241DK 00155001
         CR    R2,R0          Message longer than that?        HRC241DK 00155001
         BNH   GWRT1          ..no, continue                   HRC241DK 00155001
         LR    R2,R0          ..yes, truncate                  HRC241DK 00155001
GWRT1    DS    0H                                              HRC241DK 00155001
         STH   R1,LINECT      Save line count                  HRC241DK 00155001
         STH   R2,MSGLEN      (also save message length)       HRC241DK 00155001
         STH   R0,MAXECHO     (also save for echo)             HRC241DK 00155001
         TM    STATUS,DOCLR   Clear the screen?                HRC241DK 00155001
         BNO   *+8            ..no                             HRC241DK 00155001
         MVI   @LINE,0        ..yes, reset line #              HRC241DK 00155001
         IC    R0,@LINE       Next available line#             HRC241DK 00155001
         AR    R1,R0          + lines needed                   HRC241DK 00155001
         CH    R1,MAXLINE     Greater than data area?          HRC241DK 00155001
         BNH   GWRT2          ..no, no overflow                HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
*                                                              HRC241DK 00155001
*        If it won't, set status to HOLDING and wait           HRC241DK 00155001
*        for operator to clear it                              HRC241DK 00155001
*                                                              HRC241DK 00155001
         BAL   R10,HOLDING    Process HOLDING status           HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
*                                                              HRC241DK 00155001
*        3066/327x splits here to finish channel program       HRC241DK 00155001
*                                                              HRC241DK 00155001
GWRT2    DS    0H                                              HRC241DK 00155001
         XR    R0,R0          (save as echo line number)       HRC241DK 00155001
         IC    R0,@LINE       ...                              HRC241DK 00155001
         STC   R0,@ECHO       ...                              HRC241DK 00155001
         CLI   CONSTYPE,TYP3066   3066 Console?                HRC241DK 00155001
         BE    GWRT3066           ..yes, go do that one        HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
*                                                              HRC241DK 00155001
*        327x Write...                                         HRC241DK 00155001
*                                                              HRC241DK 00155001
GWRT307X DS    0H                                              HRC241DK 00155001
         LA    R1,WRT70CCW    Execute the 327x Write           HRC241DK 00155001
         TM    STATUS,DOCLR   Clear the screen?                HRC241DK 00155001
         BNO   *+8            ..no                             HRC241DK 00155001
         LA    R1,ERS70CCW    ..yes, use erase/write           HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
         STCM  R3,7,MSG77CCW+1(R1)  Set message data address   HRC241DK 00155001
         STH   R2,MSG77CCW+6(,R1)     and length               HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
         NI    WRT70D1,255-WCCALRM assume no alary             HRC241DK 00155001
         TM    PARM,ALARM     Was ALARM option given?          HRC241DK 00155001
         BNO   *+8            ..no, all set                    HRC241DK 00155001
         OI    WRT70D1,WCCALRM yes, add ALARM to the WCC       HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
         SR    R2,R2          Current line number              HRC241DK 00155001
         IC    R2,@LINE       ...                              HRC241DK 00155001
         SLL   R2,1           *2 = 1/2 word displacement       HRC241DK 00155001
         LH    R2,TABLE70(R2)   into 327x line address table   HRC241DK 00155001
         STCM  R2,3,@LINE70   and plug into 3270 data stream   HRC241DK 00155001
         STCM  R2,3,@ECHO70   and save for possible read echo  HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
         B     GWRTGO         ...                              HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
*                                                              HRC241DK 00155001
*        3066 Write...                                         HRC241DK 00155001
*                                                              HRC241DK 00155001
GWRT3066 DS    0H                                              HRC241DK 00155001
         STCM  R3,7,WRT66MSG+1 Set message data address        HRC241DK 00155001
         STH   R2,WRT66MSG+6     and length                    HRC241DK 00155001
         LA    R1,WRT66CCW    Execute the 3066 Write           HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
         TM    STATUS,DOCLR   Clear the screen?                HRC241DK 00155001
         BNO   *+8            ..no                             HRC241DK 00155001
         LA    R1,ERS66CCW    ..yes, use erase                 HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
         MVI   WRT66ALM,NOP   Assume no alarm                  HRC241DK 00155001
         TM    PARM,ALARM     Was ALARM option given?          HRC241DK 00155001
         BNO   *+8          ..no, all set                      HRC241DK 00155001
         MVI   WRT66ALM,ALRM66 yes, sound the alarm            HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
*                                                              HRC241DK 00155001
*       All set.. Issue the I/O and finish                     HRC241DK 00155001
*                                                              HRC241DK 00155001
GWRTGO   DS    0H                                              HRC241DK 00155001
         NI    STATUS,255-DOCLR Reseet clear screen flag       HRC241DK 00155001
         BAL   R10,STARTIO1   Talk to the console              HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
         IC    R1,@LINE       Bump line # for next write       HRC241DK 00155001
         AH    R1,LINECT      ...                              HRC241DK 00155001
         STC   R1,@LINE       ...                              HRC241DK 00155001
         B     CCWNEXT        and process next CCW             HRC241DK 00155001
         EJECT ,                                               HRC241DK 00155001
*------------------------------------------------------------  HRC241DK 00155001
*        GRAFREAD - Read operator response to the prompt       HRC241DK 00155001
*        -- Unlock keyboard & set CPREAD status                HRC241DK 00155001
*        -- Wait for ATTN interrupt                            HRC241DK 00155001
*        -- RMI/Read-Modified                                  HRC241DK 00155001
*        -- Echo response to screen data area                  HRC241DK 00155001
*------------------------------------------------------------  HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
GRAFREAD DS    0H                                              HRC241DK 00155001
*                                                              HRC241DK 00155001
*        First, place the screen in CP READ status             HRC241DK 00155001
*                                                              HRC241DK 00155001
         LA    R1,CPR70CCW    327x CP READ chan prog           HRC241DK 00155001
         CLI   CONSTYPE,TYP3066 3066 Console?                  HRC241DK 00155001
         BNE   *+8              ..no, go issue i/o             HRC241DK 00155001
         LA    R1,CPR66CCW      ..yes, use 3066 chan prog      HRC241DK 00155001
         BAL   R10,STARTIO1     and talk to the console        HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
*                                                              HRC241DK 00155001
*        Then wait for the operator                            HRC241DK 00155001
*                                                              HRC241DK 00155001
GRDWAIT  DS    0H                                              HRC241DK 00155001
         BAL   R10,WAITATTN   Wait for ATTN interrupt          HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
*                                                              HRC241DK 00155001
*        Next, read the keyboard input                         HRC241DK 00155001
*                                                              HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
         XC    RMDATA,RMDATA  Clear RMI preamble               HRC241DK 00155001
         XC    INDATA,INDATA    and clear input area           HRC241DK 00155001
         OI    STATUS,NODATA   (Assume no data entered)        HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
         LA    R1,INP70CCW    327x Read-Modified CCWs          HRC241DK 00155001
         CLI   CONSTYPE,TYP3066 3066 Console?                  HRC241DK 00155001
         BNE   *+8              ..no, go issue i/o             HRC241DK 00155001
         LA    R1,INP66CCW      ..yes, use 3066 chan prog      HRC241DK 00155001
         BAL   R10,STARTIO1     and talk to the console        HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
*                                                              HRC241DK 00155001
*        Look at the key that was pressed                      HRC241DK 00155001
*                                                              HRC241DK 00155001
         CLI   CONSTYPE,TYP3066 3066 Console?                  HRC241DK 00155001
         BE    GRD66A          ..yes, different codes          HRC241DK 00155001
         CLI   RMDATA,AIDCLEAR Clear key?                      HRC241DK 00155001
         BE    GRDCLEAR        ..yes, clear screen & retry     HRC241DK 00155001
         CLI   RMDATA,AIDPA1   PA1 key?                        HRC241DK 00155001
         BE    GRDCLEAR        ..yes, clear screen & retry     HRC241DK 00155001
         CLI   RMDATA,AIDPA2   PA2 key?                        HRC241DK 00155001
         BE    GRDCLEAR        ..yes, clear screen & retry     HRC241DK 00155001
         CLI   RMDATA,AIDENTER ENTER key?                      HRC241DK 00155001
         BNE   GRAFREAD        ..no, back to CP READ state     HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
         CLC   @INPINPT,RMDATA+1 did the cursor move?          HRC241DK 00155001
         BE    GRDRUN70        ..no, no response given         HRC241DK 00155001
         LA    R0,INP70LEN    Get max 327x Read length         HRC241DK 00155001
         LA    R1,ECH70OHD    Get echo overhead                HRC241DK 00155001
         B     GRDECHO        and rejoin with 3066             HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
GRD66A   DS    0H                                              HRC241DK 00155001
         TM    RMDATA+2,CANCEL66 3066 CANCEL key?              HRC241DK 00155001
         BO    GRDCLEAR        ..yes, clear screen & retry     HRC241DK 00155001
         CLC   @INPT66,RMDATA Did the cursor move?             HRC241DK 00155001
         BE    GRDRUN         ..no, nothing entered            HRC241DK 00155001
         LA    R0,INP66LEN    Get max 3066 read length         HRC241DK 00155001
         LA    R1,ECH66OHD    Get echo overhead                HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
*                                                              HRC241DK 00155001
*        Set response length                                   HRC241DK 00155001
*                                                              HRC241DK 00155001
GRDECHO  DS    0H                                              HRC241DK 00155001
         CLI   INDATA,0        Any real data entered?          HRC241DK 00155001
         BE    GRDRUN          ..no, bypass echo               HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
         NI    STATUS,255-NODATA turn off "no data"            HRC241DK 00155001
         LH    R14,CSWCOUNT    Get last CSW count              HRC241DK 00155001
         LTR   R14,R14         Was there any?                  HRC241DK 00155001
         BZ    GRDECHO2        ..no, echo to a separate line   HRC241DK 00155001
         SR    R0,R14          Max len - residual              HRC241DK 00155001
         STH   R0,INLEN          = actual data length          HRC241DK 00155001
*                                                              HRC241DK 00155001
*        See if echo will fit on same line                     HRC241DK 00155001
*                                                              HRC241DK 00155001
         AH    R1,MSGLEN       Overhead + prompt length        HRC241DK 00155001
         AR    R1,R0             + response length             HRC241DK 00155001
         CH    R1,MAXECHO      Is there room?                  HRC241DK 00155001
         BH    GRDECHO2        ..no, echo to separate line     HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
*                                                              HRC241DK 00155001
*        Write echo:                                           HRC241DK 00155001
*        -- Clear input area                                   HRC241DK 00155001
*        -- rewrite prompt message                             HRC241DK 00155001
*        -- hilite attr (327x 0nly)                            HRC241DK 00155001
*        -- response                                           HRC241DK 00155001
*        -- lolite attr (327x only)                            HRC241DK 00155001
*        -- Reset status to RUNNING                            HRC241DK 00155001
*                                                              HRC241DK 00155001
         CLI   CONSTYPE,TYP3066 3066 Console?                  HRC241DK 00155001
         BE    GRDECH66        ..yes, different codes          HRC241DK 00155001
         STH   R0,ECH70DTA+6   Set echo data length            HRC241DK 00155001
         LA    R1,ECH70CCW     Use 327x echo chan prog         HRC241DK 00155001
         B     GRDECHIO        and go do the I/O               HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
GRDECH66 DS    0H                                              HRC241DK 00155001
         STH   R0,ECH66DTA+6   Set echo data length            HRC241DK 00155001
         LA    R1,ECH66CCW     Use 3066 echo chan prog         HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
GRDECHIO DS    0H                                              HRC241DK 00155001
         BAL   R10,STARTIO1    Echo response to data area      HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
         B     CCWNEXT         Done.. get next CCW             HRC241DK 00155001
         SPACE 3                                               HRC241DK 00155001
*                                                              HRC241DK 00155001
*        Response doesn't fit next to prompt:                  HRC241DK 00155001
*        Just echo response back to its own line               HRC241DK 00155001
*                                                              HRC241DK 00155001
GRDECHO2 DS    0H                                              HRC241DK 00155001
         SR    R2,R2          R2 = response length             HRC241DK 00155001
         IC    R2,INLEN       ...                              HRC241DK 00155001
         LA    R3,INDATA      R3 -> response data              HRC241DK 00155001
         B     GRAFWRIT       and call the write code          HRC241DK 00155001
         SPACE 3                                               HRC241DK 00155001
*                                                              HRC241DK 00155001
*        No operator response given                            HRC241DK 00155001
*        -- Clear input area                                   HRC241DK 00155001
*        -- Reset status to RUNNING                            HRC241DK 00155001
*                                                              HRC241DK 00155001
GRDRUN   DS    0H                                              HRC241DK 00155001
         LA    R1,RUN66CCW      ..yes, use 3066 chan prog      HRC241DK 00155001
         CLI   CONSTYPE,TYP3066 3066 Console?                  HRC241DK 00155001
         BE    *+8              ..yes, go issue i/o            HRC241DK 00155001
GRDRUN70 DS    0H                                              HRC241DK 00155001
         LA    R1,RUN70CCW      327x Read-Modified CCWs        HRC241DK 00155001
         BAL   R10,STARTIO1     and talk to the console        HRC241DK 00155001
         SPACE 1                                               HRC241DK 00155001
         B     CCWNEXT          and back to CCW loop           HRC241DK 00155001
         SPACE 3                                               HRC241DK 00155001
*                                                              HRC241DK 00155001
*        CLEAR or PA key pressed                               HRC241DK 00155001
*                                                              HRC241DK 00155001
GRDCLEAR DS    0H                                              HRC241DK 00155001
         LA    R1,CLR70CCW    Clear screen to CP READ          HRC241DK 00155001
         CLI   CONSTYPE,TYP3066 3066 Console?                  HRC241DK 00155001
         BNE   *+8              ..no, go issue i/o             HRC241DK 00155001
         LA    R1,CLR66CCW      ..yes, use 3066 chan prog      HRC241DK 00155001
         BAL   R10,STARTIO1     and talk to the console        HRC241DK 00155001
         B     GRDWAIT        and wait for input               HRC241DK 00155001
         EJECT                                                          00185000
SETCC0   CLI   *+1,255        SET CONDITION CODE = 0                    00186000
         B     RSTREGS        RESTORE USERS REGISTERS                   00187000
SETCC1   TM    *,X'FF'        SET CONDITION CODE = 1                    00188000
         B     RSTREGS        RESTORE USERS REGISTERS                   00189000
SETCC2   CLI   *,X'00'        SET CONDITION CODE = 2                    00190000
         B     RSTREGS        RESTORE USERS REGISTERS                   00191000
SETCC3   TM    *+1,255        SET CONDITION CODE = 3                    00192000
RSTREGS  LM    R0,R15,OPREGS  RESTORE CALLERS REGISTERS        @V200730 00193000
         BR    R14            RETURN TO CALLER                          00194000
*/ R 00194100 00195000 $ 00194101 10
         EJECT ,                                               HRC241DK 00194101
*------------------------------------------------------------  HRC241DK 00194101
*        INITCONS - Discover and setup operator console        HRC241DK 00194101
*        R10 = return address                                  HRC241DK 00194101
*------------------------------------------------------------  HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
INITCONS DS    0H                                              HRC241DK 00194101
         STM   R0,R15,OP2REGS Save incoming registers          HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
         STIDP CPUID          Store CPU Id                     HRC241DK 00194101
         CLI   CPUVERSN,X'FF' Running in a VM?                 HRC241DK 00194101
         BNE   GETRIOCN       ..no, check RIOCN                HRC241DK 00194101
         L     R1,FFS         Rx=-1 (get console addr)         HRC241DK 00194101
         DIAG  R1,R2,X'24'    Get console info CP              HRC241DK 00194101
         BNZ   SETCC3         error or disconnected            HRC241DK 00194101
         STH   R1,CONSADDR    Save console address             HRC241DK 00194101
         STCM  R2,12,CONSTYPC Save vdev class/type             HRC241DK 00194101
         B     SETCONS        and finish setup                 HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
*                                                              HRC241DK 00194101
*        Running on a bare system.                             HRC241DK 00194101
*        Find one of the operator consoles configured          HRC241DK 00194101
*        in DMKRIO                                             HRC241DK 00194101
*                                                              HRC241DK 00194101
GETRIOCN DS    0H                                              HRC241DK 00194101
         L     R2,=A(DMKRIOCN) Search defined consoles         HRC241DK 00194101
         LH    R1,2(,R2)      Get device address               HRC241DK 00194101
         BAL   R10,TESTDEV    See if exists                    HRC241DK 00194101
         BZ    HAVECN         ..yes, Use it                    HRC241DK 00194101
         L     R0,4(,R2)      ..no, search alternates          HRC241DK 00194101
         LA    R2,4(,R2)      ..                               HRC241DK 00194101
ALTCNLP  DS    0H                                              HRC241DK 00194101
         LA    R2,4(,R2)      1st or next ALTCONS              HRC241DK 00194101
         LH    R1,2(,R2)      Get device address               HRC241DK 00194101
         BAL   R10,TESTDEV    See if exists                    HRC241DK 00194101
         BZ    HAVECN         ..yes, Use it                    HRC241DK 00194101
         BCT   R0,ALTCNLP     loop thru them all               HRC241DK 00194101
         B     SETCC3         Error.. no functional consoles   HRC241DK 00194101
HAVECN   DS    0H                                              HRC241DK 00194101
         STH   R1,CONSADDR    Save console addr                HRC241DK 00194101
         LH    R8,0(,R4)      Get RDEVBLOK addr                HRC241DK 00194101
         SLL   R8,3           ... dwords to bytes              HRC241DK 00194101
         AL    R8,=A(DMKRIODV) .. offset into table            HRC241DK 00194101
         USING RDEVBLOK,R8                                     HRC241DK 00194101
         LH    R0,RDEVTYPC    Save real device class/type      HRC241DK 00194101
         STH   R0,CONSTYPC    ...                              HRC241DK 00199001
         IC    R0,RDEVGRTY    also save the screen type        HRC241DK 00199001
         STC   R0,CONSGRTY    ...                              HRC241DK 00199001
         DROP  R8                                              HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
*                                                              HRC241DK 00194101
*        Finish the setup based on the device type             HRC241DK 00194101
*        of the operator console                               HRC241DK 00194101
*                                                              HRC241DK 00194101
SETCONS  DS    0H                                              HRC241DK 00194101
         CLI   CONSTYPC,CLASGRAF  Display device               HRC241DK 00194101
         BNE   SETTERM            ..no, setup terminal         HRC241DK 00194101
         OI    STATUS,CNGRAF+DOCLR                             HRC241DK 00194101
         LA    R0,LASTLN66    3066 has 33 data lines           HRC241DK 00194101
         CLI   CONSTYPE,TYP3066                                HRC241DK 00194101
         BE    FINGRF                                          HRC241DK 00194101
         LA    R0,LASTLN70    327x M2 has 22 data lines        HRC241DK 00194101
         CLI   CONSGRTY,MODEL2A Special stuff for model 2A     HRC241DK 00194101
         BNE   FINGRF                                          HRC241DK 00194101
         LH    R0,@INPT2A         Set Model 2A InputArea       HRC241DK 00194101
         STCM  R0,3,@WRTINPT      ... Write orders             HRC241DK 00194101
         STCM  R0,3,@CPRINPT      ... CP READ orders           HRC241DK 00194101
         STCM  R0,3,@ECHINPT      ... Echo orders              HRC241DK 00194101
         STCM  R0,3,@CLRINPT      ... Clear orders             HRC241DK 00194101
         LH    R0,@STAT2A         Set Model 2A StatusArea      HRC241DK 00194101
         STCM  R0,3,@WRTSTAT      ... Write orders             HRC241DK 00194101
         STCM  R0,3,@CPRSTAT      ... CP READ orders           HRC241DK 00194101
         STCM  R0,3,@ECHSTAT      ... Echo orders              HRC241DK 00194101
         STCM  R0,3,@ECHSTA3      ...                          HRC241DK 00194101
         STCM  R0,3,@RUNSTAT      ... RUNNING orders           HRC241DK 00194101
         STCM  R0,3,@RUNSTA2      ...                          HRC241DK 00194101
         STCM  R0,3,@HLDSTAT      ... HOLDING orders           HRC241DK 00194101
         LH    R0,@RA3@2A         Set Model 2A RA#3 ending     HRC241DK 00194101
         STCM  R0,3,@CLRRA3       ... Clear orders             HRC241DK 00194101
         LA    R0,LASTLN2A    Model 2A only has 18 data lines  HRC241DK 00194101
FINGRF   DS    0H                                              HRC241DK 00194101
         STH   R0,MAXLINE     Set the last data line #         HRC241DK 00194101
         B     CONSRET        and return                       HRC241DK 00194101
SETTERM  DS    0H                                              HRC241DK 00194101
         OI    STATUS,CN3215  Set as hardcopy console          HRC241DK 00194101
CONSRET  DS    0H                                              HRC241DK 00194101
         OI    STATUS,DIDINIT Initialization finished          HRC241DK 00194101
         LM    R0,R15,OP2REGS Restore caller's regs            HRC241DK 00194101
         BR    R10            and return                       HRC241DK 00194101
         SPACE 3                                               HRC241DK 00194101
*                                                              HRC241DK 00194101
*        TESTDEV  - Check to see if a device exists            HRC241DK 00194101
*        Input R1  = device address                            HRC241DK 00194101
*              R10 = return address                            HRC241DK 00194101
*                                                              HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
TESTDEV  DS    0H                                              HRC241DK 00194101
         TIO   0(R1)          Ping the device                  HRC241DK 00194101
         BCR   1,R10          CC3: NotOp - return              HRC241DK 00194101
         BR    R10            Return with CC=0                 HRC241DK 00194101
         EJECT ,                                               HRC241DK 00194101
*------------------------------------------------------------  HRC241DK 00194101
*        HOLDING - Place screen in HOLDING status and          HRC241DK 00194101
*                  wait for operator to clear it               HRC241DK 00194101
*        R10 = return address                                  HRC241DK 00194101
*------------------------------------------------------------  HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
HOLDING  DS    0H                                              HRC241DK 00194101
         ST    R10,HLDSAVE    Save return address              HRC241DK 00194101
         STM   R0,R4,HLDSAVE2 also save other regs             HRC241DK 00194101
*                                                              HRC241DK 00194101
*        First, place screen in HOLDING status                 HRC241DK 00194101
*                                                              HRC241DK 00194101
         LA    R1,HLD70CCW    327x HOLDING chan prog           HRC241DK 00194101
         CLI   CONSTYPE,TYP3066 3066 Console?                  HRC241DK 00194101
         BNE   *+8              ..no, go issue i/o             HRC241DK 00194101
         LA    R1,HLD66CCW      ..yes, use 3066 chan prog      HRC241DK 00194101
         BAL   R10,STARTIO1     and talk to the console        HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
*                                                              HRC241DK 00194101
*        Then wait for the operator                            HRC241DK 00194101
*                                                              HRC241DK 00194101
HLDWAIT  DS    0H                                              HRC241DK 00194101
         BAL   R10,WAITATTN   Wait for ATTN interrupt          HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
*                                                              HRC241DK 00194101
*        Next, read the keyboard input                         HRC241DK 00194101
*                                                              HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
         XC    RMDATA,RMDATA  Clear RMI preamble               HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
         LA    R1,RMI70CCW    327x Read-Modified CCWs          HRC241DK 00194101
         CLI   CONSTYPE,TYP3066 3066 Console?                  HRC241DK 00194101
         BNE   *+8              ..no, go issue i/O             HRC241DK 00194101
         LA    R1,RMI66CCW      ..yes, use 3066 chan prog      HRC241DK 00194101
         BAL   R10,STARTIO1     and talk to the console        HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
*                                                              HRC241DK 00194101
*        Look for "clearing" key press                         HRC241DK 00194101
*                                                              HRC241DK 00194101
         CLI   CONSTYPE,TYP3066 3066 Console?                  HRC241DK 00194101
         BE    HLD66A          ..yes, different codes          HRC241DK 00194101
         CLI   RMDATA,AIDCLEAR Clear key?                      HRC241DK 00194101
         BE    HLDCLEAR        ..yes, clear screen & return    HRC241DK 00194101
         CLI   RMDATA,AIDPA1   PA1 key?                        HRC241DK 00194101
         BE    HLDCLEAR        ..yes, clear screen & return    HRC241DK 00194101
         CLI   RMDATA,AIDPA2   PA2 key?                        HRC241DK 00194101
         BE    HLDCLEAR        ..yes, clear screen & return    HRC241DK 00194101
         B     HLDWAIT         ..no, ignore other keys         HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
HLD66A   DS    0H                                              HRC241DK 00194101
         TM    RMDATA+2,CANCEL66 3066 CANCEL key?              HRC241DK 00194101
         BNO   HLDWAIT         ..no, ignore other keys         HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
*                                                              HRC241DK 00194101
*        Clear the screen and set RUNNING status               HRC241DK 00194101
*                                                              HRC241DK 00194101
HLDCLEAR DS    0H                                              HRC241DK 00194101
         LA    R1,CLR70CCW    Clear screen to RUNNING          HRC241DK 00194101
         CLI   CONSTYPE,TYP3066 3066 Console?                  HRC241DK 00194101
         BNE   *+8              ..no, go issue i/o             HRC241DK 00194101
         LA    R1,CLR66CCW      ..yes, use 3066 chan prog      HRC241DK 00194101
         BAL   R10,STARTIO1     and talk to the console        HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
*                                                              HRC241DK 00194101
*        Reset coordinates & return                            HRC241DK 00194101
*                                                              HRC241DK 00194101
         MVI   @LINE,0        Reset line numbver               HRC241DK 00194101
         LM    R0,R4,HLDSAVE2 restore working regs             HRC241DK 00194101
         L     R10,HLDSAVE    restore return address           HRC241DK 00194101
         BR    R10            and return                       HRC241DK 00194101
         EJECT ,                                               HRC241DK 00194101
*------------------------------------------------------------  HRC241DK 00194101
*        WAITATTN - Wait for an attention interrupt            HRC241DK 00194101
*        R10 = return address                                  HRC241DK 00194101
*------------------------------------------------------------  HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
WAITATTN DS    0H                                              HRC241DK 00194101
         ST    R10,ATTNSAVE   Save return address              HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
*                                                              HRC241DK 00194101
*        First setup a "resume" PSW with the                   HRC241DK 00194101
*        current System Mask, etc.                             HRC241DK 00194101
*                                                              HRC241DK 00194101
         TM    STATUS,DIDRES      Already did this?            HRC241DK 00194101
         BO    WAITA              ..yes, bypass                HRC241DK 00194101
         MVC   CPPRNPSW,PRNPSW    Swap out ProgNew PSW         HRC241DK 00194101
         MVC   PRNPSW,=A(0,PRGINT)  ...                        HRC241DK 00194101
         DC    H'0'               Cause a Program Check        HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
PRGINT   DS    0H             Prorgam Check handler            HRC241DK 00194101
         STM   R14,R15,CPULOG     Use Logout Area              HRC241DK 00194101
         BALR  R15,0              Temp base reg                HRC241DK 00194101
         USING *,R15              ...                          HRC241DK 00194101
         MVC   RESUMPSW,PROPSW    Save ProgChk Old PSW         HRC241DK 00194101
         LA    R14,WAITA          Set resume PSW               HRC241DK 00194101
         STCM  R14,7,RESUMPSW+5   ...                          HRC241DK 00194101
         MVC   WAITPSW,PROPSW     Also set up Wait PSW         HRC241DK 00194101
         OI    WAITPSW+1,X'02'    ... add WAIT flag            HRC241DK 00194101
         SR    R14,R14            ... and address = 0          HRC241DK 00194101
         STCM  R14,7,WAITPSW+5    ...                          HRC241DK 00194101
         OI    STATUS,DIDRES      Set one-time flag            HRC241DK 00194101
         MVC   PRNPSW,CPPRNPSW    Restore ProgNew PSW          HRC241DK 00194101
         DROP  R15                                             HRC241DK 00194101
         LM    R14,R15,CPULOG     Restore all registers        HRC241DK 00194101
         LPSW  RESUMPSW            and continue                HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
*                                                              HRC241DK 00194101
*        Save CP's I/O New PSW and set a temp                  HRC241DK 00194101
*        one to come here                                      HRC241DK 00194101
*                                                              HRC241DK 00194101
WAITA    DS    0H                                              HRC241DK 00194101
         MVC   CPIONPSW,IONPSW    Save current I/O New PSW     HRC241DK 00194101
         MVC   IONPSW,IOPSW         and set our I/O New PSW    HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
*                                                              HRC241DK 00194101
*        Wait for the ATTN interrupt                           HRC241DK 00194101
*                                                              HRC241DK 00194101
         LPSW  WAITPSW            Wait for operator            HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
*                                                              HRC241DK 00194101
*        Swap back the I/O New PSW and return                  HRC241DK 00194101
*                                                              HRC241DK 00194101
WAITDONE DS    0H                                              HRC241DK 00194101
         MVC   IONPSW,CPIONPSW    Put CP back in control       HRC241DK 00194101
         L     R10,ATTNSAVE       and return                   HRC241DK 00194101
         BR    R10                ...                          HRC241DK 00194101
         SPACE 3                                               HRC241DK 00194101
*------------------------------------------------------------  HRC241DK 00194101
*        I/O Interrupt Handler                                 HRC241DK 00194101
*------------------------------------------------------------  HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
IOINT    DS    0H                                              HRC241DK 00194101
         STM   R14,R15,CPULOG     Use Logout Area              HRC241DK 00194101
         BALR  R15,0              Temp base reg                HRC241DK 00194101
         USING *,R15              ...                          HRC241DK 00194101
         CLC   CONSADDR,IOOPSW+2  Interrupt from console?      HRC241DK 00194101
         BE    CONSINT            ..yes, check it out          HRC241DK 00194101
         LM    R14,R15,CPULOG     ..no, restore all registers  HRC241DK 00194101
         LPSW  CPIONPSW           ..    and pass intr to CP    HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
CONSINT  DS    0H                                              HRC241DK 00194101
         TM    CSW+4,ATTN         Got ATTN interrupt?          HRC241DK 00194101
         BO    WAITFIN            ..yes, finish up             HRC241DK 00194101
         LPSW  IOOPSW             ..no, keep waiting           HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
WAITFIN  DS    0H                                              HRC241DK 00194101
         LA    R14,WAITDONE       Set resume PSW               HRC241DK 00194101
         STCM  R14,7,RESUMPSW+5   ...                          HRC241DK 00194101
         MVC   IONPSW,CPIONPSW    Restore IONew PSW            HRC241DK 00194101
         DROP  R15                                             HRC241DK 00194101
         LM    R14,R15,CPULOG     Restore all registers        HRC241DK 00194101
         LPSW  RESUMPSW            and continue as WAITDONE    HRC241DK 00194101
         EJECT ,                                               HRC241DK 00194101
*------------------------------------------------------------- HRC241DK 00194101
*        CCWs and other double word things                     HRC241DK 00194101
*------------------------------------------------------------- HRC241DK 00194101
         SPACE 1                                               HRC241DK 00194101
         DC    0D'0'              (alignment)                  HRC241DK 00194101
IOPSW    DC    X'00040000',A(IOINT)   Our I/O New PSW          HRC241DK 00194101
CPIONPSW DC    D'0'               Saved CP I/O New PSW         HRC241DK 00194101
CPPRNPSW DC    D'0'               Saved CP Prog New PSW        HRC241DK 00194101
RESUMPSW DC    D'0'               Resume after interupts       HRC241DK 00194101
WAITPSW  DC    D'0'               Enabled WAIT PSW             HRC241DK 00194101
         SPACE 3                                               HRC241DK 00194101
*---------------------------------------------------------------------* 00196000
*/ R 00197000 $ 00197001
*              3066 Graphic Support CCWs                       HRC241DK 00197001
*---------------------------------------------------------------------* 00198000
*/ R 00199000 00223000 $ 00199001 50
         SPACE 1                                               HRC241DK 00199001
*        3066 CCW Op Codes                                     HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
WRT66    EQU   X'01'          Write                            HRC241DK 00199001
CSR66    EQU   X'0F'          Set Cursor                       HRC241DK 00199001
SBA66    EQU   X'27'          Set Buffer Address               HRC241DK 00199001
RD66     EQU   X'06'          Read                             HRC241DK 00199001
RMI66    EQU   X'0E'          Read Manual Input                HRC241DK 00199001
ALRM66   EQU   X'0B'          Set Audible Alarm                HRC241DK 00199001
LOCK66   EQU   X'67'          Lock keyboarad                   HRC241DK 00199001
ERS66    EQU   X'07'          Erase                            HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        Initial screen formatting (DOCLR flag)                HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
ERS66CCW CCW   ERS66,0,CC+SILI,1            Erase the screen   HRC241DK 00199001
         CCW   CSR66,@INPT66,CC+SILI,2      Cursor = InputArea HRC241DK 00199001
*        Continues to WRT66CCW                                 HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        Write message to data area                            HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
WRT66CCW CCW   SBA66,@LINE,CC+SILI,2        Move to data line  HRC241DK 00199001
WRT66MSG CCW   WRT66,*-*,CC+SILI,*-*        Write the message  HRC241DK 00199001
         CCW   SBA66,@STAT66,CC+SILI,2      Move to StatusArea HRC241DK 00199001
         CCW   WRT66,$RUNNING,CC+SILI,20    Status = RUNNING   HRC241DK 00199001
WRT66ALM CCW   NOP,0,CC+SILI,1              Alarm if needed    HRC241DK 00199001
         CCW   NOP,0,SILI,1                 (the end)          HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        Set Status Area = CP READ                             HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
CPR66CCW CCW   CSR66,@INPT66,CC+SILI,2      Cursor = InputArea HRC241DK 00199001
         CCW   SBA66,@STAT66,CC+SILI,2      Move to StatusArea HRC241DK 00199001
         CCW   WRT66,$CPREAD,CC+SILI,20     Status = CP READ   HRC241DK 00199001
         CCW   NOP,0,SILI,1                 (the end)          HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        Read Input Area (after ATTN)                          HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
INP66CCW CCW   RMI66,RMDATA,CC+SILI,3       Read CSR addr & keyHRC241DK 00199001 
         CCW   SBA66,@INPT66,CC+SILI,2      Move to InputArea  HRC241DK 00199001
         CCW   RD66,INDATA,CC+SILI,L'INDATA Read response      HRC241DK 00199001
         CCW   NOP,0,SILI,1                 (the end)          HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        Get key press in HOLDING state                        HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
RMI66CCW CCW   RMI66,RMDATA,CC+SILI,3       Read CSR addr & keyHRC241DK 00199001
         CCW   NOP,0,SILI,1                 (the end)          HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        Echo operator input to prompt line                    HRC241DK 00199001
*        -- clear input area                                   HRC241DK 00199001
*        -- restore RUNNING status                             HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
ECH66CCW CCW   SBA66,@ECHO,CC+SILI,2        Move to prompt ln  HRC241DK 00199001
ECH66MSG CCW   WRT66,*-*,CC+SILI,*-*        Write the message  HRC241DK 00199001
ECH66DTA CCW   WRT66,*-*,CC+SILI,*-*        Echo the response  HRC241DK 00199001
         CCW   SBA66,@INPT66,CC+SILI,2      Move to InputArea  HRC241DK 00199001
         CCW   WRT66,NULLINPT,CC+SILI,140   set to nulls       HRC241DK 00199001
         CCW   CSR66,@INPT66,CC+SILI,2      Cursor = InputArea HRC241DK 00199001
         CCW   SBA66,@STAT66,CC+SILI,2      Move to StatusArea HRC241DK 00199001
         CCW   WRT66,$RUNNING,CC+SILI,20    Status = RUNNING   HRC241DK 00199001
         CCW   NOP,0,SILI,1                 (the end)          HRC241DK 00199001
ECH66OHD EQU   0              Echo line overhead               HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        Set Status = RUNNING                                  HRC241DK 00199001
*        -- clear input area                                   HRC241DK 00199001
*        -- restore RUNNING status                             HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
RUN66CCW CCW   SBA66,@INPT66,CC+SILI,2      Move to InputArea  HRC241DK 00199001
         CCW   WRT66,NULLINPT,CC+SILI,140   set to nulls       HRC241DK 00199001
         CCW   CSR66,@INPT66,CC+SILI,2      Cursor = InputArea HRC241DK 00199001
         CCW   SBA66,@STAT66,CC+SILI,2      Move to StatusArea HRC241DK 00199001
         CCW   WRT66,$RUNNING,CC+SILI,20    Status = RUNNING   HRC241DK 00199001
         CCW   NOP,0,SILI,1                 (the end)          HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        Set Status Area = HOLDING                             HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
HLD66CCW CCW   SBA66,@STAT66,CC+SILI,2      Move to StatusArea HRC241DK 00199001
         CCW   WRT66,$HOLDING,CC+SILI,20    Status = HOLDING   HRC241DK 00199001
         CCW   NOP,0,SILI,1                 (the end)          HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        Clear data area preserving                            HRC241DK 00199001
*        Cursor, Input Area, and Status                        HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
CLR66CCW CCW   RMI66,CLRMI,CC+SILI,3        Save cursor adr    HRC241DK 00199001                
         CCW   CSR66,@ORIG66,CC+SILI,2      Set cursor = 0,0   HRC241DK 00199001             
         CCW   SBA66,@INPT66,CC+SILI,2      Move to InputArea  HRC241DK 00199001              
         CCW   RD66,CLRDATA,CC+SILI,160     Save last 2 lines  HRC241DK 00199001             
         CCW   ERS66,0,CC+SILI,1            Erase the screen   HRC241DK 00199001             
         CCW   SBA66,@INPT66,CC+SILI,2      Move to InputArea  HRC241DK 00199001              
         CCW   WRT66,CLRDATA,CC+SILI,160    Restore last 2 lineHRC241DK 00199001                
         CCW   CSR66,CLRMI,CC+SILI,2        Restore cursor addrHRC241DK 00199001
         CCW   NOP,0,SILI,1                 (the end)          HRC241DK 00199001
         EJECT ,                                               HRC241DK 00199001
*------------------------------------------------------------- HRC241DK 00199001
*              327x Graphic Support CCWs                       HRC241DK 00199001
*------------------------------------------------------------- HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        327x CCW Opcodes                                      HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
WRT70    EQU   X'01'          Write                            HRC241DK 00199001
ERS70    EQU   X'05'          Erase/Write                      HRC241DK 00199001 
RB70     EQU   X'02'          Read Buffer                      HRC241DK 00199001
RM70     EQU   X'06'          Read Modified                    HRC241DK 00199001
SEL70    EQU   X'0B'          Select                           HRC241DK 00199001
EAU70    EQU   X'0F'          Erase All Unprotected            HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        Initial screen formatting (DOCLR flag)                HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
ERS70CCW CCW   ERS70,WRT70D1,CD+SILI,WRT70D1L  WCC; SBA        HRC241DK 00199001
         CCW   0,@LINE70,CD+SILI,2             current line    HRC241DK 00199001
MSG77CCW EQU   *-ERS70CCW                                      HRC241DK 00199001
ERS70MSG CCW   0,*-*,CD+SILI,*-*               message data    HRC241DK 00199001
         CCW   0,WRT70D2,SILI,ERS70D2L         SBA Input       HRC241DK 00199001
*                                              SF uprot        HRC241DK 00199001
*                                              SBA Status      HRC241DK 00199001
*                                              SF prot;RUNNING HRC241DK 00199001
*                                              SF prot         HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        Write message to data area                            HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
WRT70CCW CCW   WRT70,WRT70D1,CD+SILI,WRT70D1L  WCC; SBA        HRC241DK 00199001
         CCW   0,@LINE70,CD+SILI,2             current line    HRC241DK 00199001
WRT70MSG CCW   0,*-*,CD+SILI,*-*               message data    HRC241DK 00199001
         CCW   0,WRT70D2,SILI,WRT70D2L         SBA Input       HRC241DK 00199001
*                                              SF uprot        HRC241DK 00199001
*                                              SBA Status      HRC241DK 00199001
*                                              SF prot;RUNNING HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        Set Status = CP READ                                  HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
CPR70CCW CCW   WRT70,CPR70D1,SILI,CPR70D1L     WCC; SBA Input  HRC241DK 00199001
*                                              SF uprot; IC    HRC241DK 00199001
*                                              SBA Status      HRC241DK 00199001
*                                              SF high;CP READ HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        Read operator input                                   HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
INP70CCW CCW   WRT70,INP70D1,CC+SILI,INP70D1L  WCC; SBA Input  HRC241DK 00199001
         CCW   RM70,RMDATA,CD+SILI,6           AID;csr;SBA;addrHRC241DK 00199001
         CCW   0,INDATA,SILI,L'INDATA          InputArea       HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        Get key press in HOLDING state                        HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
RMI70CCW CCW   RM70,RMDATA,SILI,3              AID; C1,C2      HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        Echo operator input to prompt line                    HRC241DK 00199001
*        -- clear input area                                   HRC241DK 00199001
*        -- restore RUNNING status                             HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
ECH70CCW CCW   WRT70,ECH70D1,CD+SILI,ECH70D1L  WCC; SBA Input  HRC241DK 00199001
*                                              SF hide; IC;    HRC241DK 00199001
*                                              EAU Status      HRC241DK 00199001
*                                              SBA             HRC241DK 00199001
         CCW   0,@ECHO70,CD+SILI,2             prompt line     HRC241DK 00199001
ECH70MSG CCW   0,*-*,CD+SILI,*-*               message data    HRC241DK 00199001
         CCW   0,ECH70D2,CD+SILI,ECH70D2L      SF high         HRC241DK 00199001
ECH70DTA CCW   0,INDATA,CD+SILI,*-*            response data   HRC241DK 00199001
         CCW   0,ECH70D3,SILI,ECH70D3L         SF prot         HRC241DK 00199001
*                                              SBA Status      HRC241DK 00199001
*                                              SF prot;RUNNING HRC241DK 00199001
ECH70OHD EQU   2              Overhead for echo attributes     HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        After null operator response:                         HRC241DK 00199001
*        -- clear input area                                   HRC241DK 00199001
*        -- restore RUNNING status                             HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
RUN70CCW CCW   WRT70,RUN70D1,SILI,RUN70D1L     WCC; SBA Input  HRC241DK 00199001
*                                              SF hide; IC;    HRC241DK 00199001
*                                              EAU Status      HRC241DK 00199001
*                                              SBA Status      HRC241DK 00199001
*                                              SF prot;RUNNING HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        Set Status = HOLDING                                  HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
HLD70CCW CCW   WRT70,HLD70D1,SILI,HLD70D1L     WCC; SBA Status HRC241DK 00199001
*                                              SF high;HOLDING HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
*        Clear data area (after HOLDING)                       HRC241DK 00199001
         SPACE 1                                               HRC241DK 00199001
CLR70CCW CCW   WRT70,CLR70D1,SILI,CLR70D1L     WCC; SBA[0,0]   HRC241DK 00199001
*                                              RA[5,79],00     HRC241DK 00199001
*                                              RA[11,79],00    HRC241DK 00199001
*                                              RA[@RA3],00     HRC241DK 00199001
*                                              RA[Input],00    HRC241DK 00199001
         EJECT ,                                               HRC241DK 00199001
*---------------------------------------------------------------------* 00224000
*/ R 00225000 $ 00225001 
*        CCWs for 3210/3215 Console                            HRC241DK 00225001    
*---------------------------------------------------------------------* 00226000
*/ R 00227000  00231000 $ 00227100
         SPACE 1                                               HRC241DK 00227100
*        CCW Op Codes                                          HRC241DK 00227100
         SPACE 1                                               HRC241DK 00227100
NOP      EQU   X'03'          Nop CCW opcode                   HRC241DK 00227100
WRT      EQU   X'09'          Console write CCW opcode         HRC241DK 00227100
WRTNC    EQU   X'01'          Console write no CR CCW opcode   HRC241DK 00227100
ALRM     EQU   X'0B'          Console alarm CCw                HRC241DK 00227100
RD       EQU   X'0A'          Console read CCW opcode          HRC241DK 00227100
         SPACE 1                                               HRC241DK 00227100
ALRM3210 CCW   ALRM,0,CC+SILI,1         Sound the alarm        HRC241DK 00227100           
WRT3210  CCW   WRT,*-*,CC+SILI,*-*      Write/carriage return  HRC241DK 00227100
         CCW   NOP,0,SILI,1             (the end)              HRC241DK 00227100
         SPACE 1                                               HRC241DK 00227100
RD3210   CCW   RD,INDATA,CC+SILI,INDATAL Read operator responseHRC241DK 00227100
         SPACE                                                          00232000
*---------------------------------------------------------------------* 00233000
*        FIRST DC ARE ADDRESSES FOR LINES 1 -6                        * 00234000
*        SECOND DC ARE ADDRESSES FOR LINES 7 - 12                     * 00235000
*        THIRD  DC ARE ADDRESSES FOR LINES 13 - 18                    * 00236000
*        FOURTH DC ARE ADDRESSES FOR LINES 19 - 24                    * 00237000
*---------------------------------------------------------------------* 00238000
         SPACE 2                                                        00239000
TABLE70  DS    0D                                              @V200731 00240000
         DC    X'4040C150C260C3F0C540C650'                     @V200731 00241000
         DC    X'C760C8F04A404B504C604DF0'                     @V200731 00242000
         DC    X'4F405050D160D2F0D440D550'                     @V200731 00243000
         DC    X'D660D7F0D9405A505B605CF0'                     @V200731 00244000
*/ R 00245000 00262000
         EJECT ,                                               HRC241DK 00245001
*------------------------------------------------------------- HRC241DK 00245001
*              3066 Constants & Buffer Locations               HRC241DK 00245001
*------------------------------------------------------------- HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
*                             RMI byte 2:                      HRC241DK 00245001
ENTER66  EQU   X'80'            3066 ENTER Mask                HRC241DK 00245001
CANCEL66 EQU   X'40'            3066 CANCEL Mask               HRC241DK 00245001
LASTLN66 EQU   33             3066 last line of data area      HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
@ORIG66  DC    AL1(0,0)       3066 Screen origin               HRC241DK 00245001
@INPT66  DC    AL1(33,0)      3066 Input area                  HRC241DK 00245001
@STAT66  DC    AL1(34,60)     3066 Status area                 HRC241DK 00245001
         SPACE 3                                               HRC241DK 00245001
*------------------------------------------------------------- HRC241DK 00245001
*              327x Buffer Locations, Orders, & Attributes     HRC241DK 00245001
*------------------------------------------------------------- HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
*        Write Control Characters (WCC)                        HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
WCCNULL  EQU   X'C0'          Nothing special                  HRC241DK 00245001
WCCRSMDT EQU   X'C3'          KB Restore; Reset MDTs           HRC241DK 00245001
WCCNOMDT EQU   X'C2'          KB Restore                       HRC241DK 00245001
WCCALRM  EQU   X'04'          WCC Alarm bit                    HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
*        327x Buffer Orders                                    HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
SBA      EQU   X'11'          Set Buffer Address               HRC241DK 00245001
SF       EQU   X'1D'          Start Field                      HRC241DK 00245001
IC       EQU   X'13'          Insert Cursor                    HRC241DK 00245001
RA       EQU   X'3C'          Repeat to Address                HRC241DK 00245001
EAU      EQU   X'12'          Erase All Unprotected            HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
*        Field Attributes                                      HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
ATTRPROT EQU   X'60'          Protected; normal                HRC241DK 00245001
ATTRHIGH EQU   X'E8'          Protected; intense               HRC241DK 00245001
ATTRINPT EQU   X'C1'          Unprotected; normal; MDT         HRC241DK 00245001
ATTRHIDE EQU   X'4D'          Unprotected; hidden; MDT         HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
*        327x Attention Id (AID) Codes                         HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
AIDCLEAR EQU   X'6D'          Clear                            HRC241DK 00245001
AIDPA1   EQU   X'6C'          PA1/Dup                          HRC241DK 00245001
AIDPA2   EQU   X'6E'          PA2/Cancel                       HRC241DK 00245001
AIDENTER EQU   X'7D'          Enter                            HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
*        Buffer Locations                                      HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
@LINE70  DC    AL2(*-*)       327x current output line         HRC241DK 00245001
@ECHO70  DC    AL2(*-*)       327x last prompt line            HRC241DK 00245001
@ORIG70  EQU   X'4040'        327x Screen origin (0,0)         HRC241DK 00245001
@INPT70  EQU   X'5B5F'        327x Input area    (21,79)       HRC241DK 00245001
@STAT70  EQU   X'5D6B'        327x Status area   (23,59)       HRC241DK 00245001
@LAST70  EQU   X'5D7F'        327x Last location (23,79)       HRC241DK 00245001
@RA1@70  EQU   X'C75F'        327x RA#1 end      (5,79)        HRC241DK 00245001
@RA2@70  EQU   X'4E7F'        327x RA#2 end      (11,79)       HRC241DK 00245001
@RA3@70  EQU   X'D65F'        327x RA#3 end      (17,79)       HRC241DK 00245001
LASTLN70 EQU   22             327x last line of data area      HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
*        Alternate buffer addresses for 3278-2A                HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
@INPT2A  DC    X'D65F'        Mod2A Input area   (17,79)       HRC241DK 00245001
@STAT2A  DC    X'D86B'        Mod2A Status area  (19,59)       HRC241DK 00245001
@LAST2A  DC    X'D87F'        Mod2A Last location(19,79)       HRC241DK 00245001
@RA3@2A  DC    X'D26F'        Mod2A RA#3 end     (14,79)       HRC241DK 00245001
LASTLN2A EQU   18             Mod2A last line of data area     HRC241DK 00245001
         EJECT ,                                               HRC241DK 00245001
*------------------------------------------------------------- HRC241DK 00245001
*              327x Data Streams                               HRC241DK 00245001
*------------------------------------------------------------- HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
*        Write message to data area                            HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
WRT70D1  EQU   *                                               HRC241DK 00245001
         DC    AL1(WCCRSMDT)      Restore keyboard, reset MDTs HRC241DK 00245001
         DC    AL1(SBA)           SBA [@LINE70]                HRC241DK 00245001
WRT70D1L EQU   *-WRT70D1                                       HRC241DK 00245001
*                                 message data                 HRC241DK 00245001
WRT70D2  EQU   *                                               HRC241DK 00245001
         DC    AL1(SBA)           SBA                          HRC241DK 00245001
@WRTINPT DC    AL2(@INPT70)       InputArea                    HRC241DK 00245001
         DC    AL1(SF,ATTRINPT)   SF Unprotected MDT           HRC241DK 00245001
         DC    AL1(IC)            IC                           HRC241DK 00245001
         DC    AL1(SBA)           SBA                          HRC241DK 00245001
@WRTSTAT DC    AL2(@STAT70)       StatusArea                   HRC241DK 00245001
         DC    AL1(SF,ATTRPROT)   SF Protected                 HRC241DK 00245001
         DC    CL19'RUNNING'      'RUNNING'                    HRC241DK 00245001
WRT70D2L EQU   *-WRT70D2                                       HRC241DK 00245001
         DC    AL1(SF,ATTRPROT)   SF Protected (if formatting) HRC241DK 00245001
ERS70D2L EQU   *-WRT70D2                                       HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
*        Set Status = CP READ                                  HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
CPR70D1  EQU   *                                               HRC241DK 00245001
         DC    AL1(WCCNOMDT)      Restore keyboard             HRC241DK 00245001
         DC    AL1(SBA)           SBA                          HRC241DK 00245001
@CPRINPT DC    AL2(@INPT70)       InputArea                    HRC241DK 00245001
         DC    AL1(SF,ATTRINPT)   SF Unprotected MDT           HRC241DK 00245001
         DC    AL1(IC)            IC                           HRC241DK 00245001
         DC    AL1(SBA)           SBA [@STAT70]                HRC241DK 00245001
@CPRSTAT DC    AL2(@STAT70)       StatusArea                   HRC241DK 00245001
         DC    AL1(SF,ATTRHIGH)   SF high                      HRC241DK 00245001
         DC    CL19'CP READ'      'CP READ'                    HRC241DK 00245001
CPR70D1L EQU   *-CPR70D1                                       HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
*        Prepare to read operator input                        HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
INP70D1  EQU   *                                               HRC241DK 00245001
         DC    AL1(WCCNULL,SBA)                                HRC241DK 00245001
@INPINPT DC    AL2(@INPT70)       InputArea                    HRC241DK 00245001
INP70D1L EQU   *-INP70D1                                       HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
*        Echo operator input to prompt line                    HRC241DK 00245001
*        -- clear input area                                   HRC241DK 00245001
*        -- restore RUNNING status                             HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
ECH70D1  EQU   *                                               HRC241DK 00245001
         DC    AL1(WCCRSMDT)      Restore keyboard, reset MDTs HRC241DK 00245001
         DC    AL1(SBA)           SBA                          HRC241DK 00245001
@ECHINPT DC    AL2(@INPT70)       InputArea                    HRC241DK 00245001
         DC    AL1(SF,ATTRHIDE)   SF hide                      HRC241DK 00245001
         DC    AL1(IC)            IC                           HRC241DK 00245001
         DC    AL1(EAU)           EAU                          HRC241DK 00245001
@ECHSTAT DC    AL2(@STAT70)       StatusArea                   HRC241DK 00245001
         DC    AL1(SBA)           SBA [@ECHO70]                HRC241DK 00245001
ECH70D1L EQU   *-ECH70D1                                       HRC241DK 00245001
*                                 message data                 HRC241DK 00245001
ECH70D2  EQU   *                                               HRC241DK 00245001
         DC    AL1(SF,ATTRHIGH)   SF high                      HRC241DK 00245001
ECH70D2L EQU   *-ECH70D2                                       HRC241DK 00245001
*                                 response data                HRC241DK 00245001
ECH70D3  EQU   *                                               HRC241DK 00245001
         DC    AL1(SF,ATTRPROT)   SF prot                      HRC241DK 00245001
         DC    AL1(SBA)           SBA                          HRC241DK 00245001
@ECHSTA3 DC    AL2(@STAT70)       StatusArea                   HRC241DK 00245001
         DC    AL1(SF,ATTRPROT)   SF prot                      HRC241DK 00245001
         DC    CL19'RUNNING'      'RUNNING'                    HRC241DK 00245001
ECH70D3L EQU   *-ECH70D3                                       HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
*        Set Status = RUNNING                                  HRC241DK 00245001
*        -- clear input area                                   HRC241DK 00245001
*        -- restore RUNNING status                             HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
RUN70D1  EQU   *                                               HRC241DK 00245001
         DC    AL1(WCCRSMDT)      Restore keyboard, reset MDTs HRC241DK 00245001
         DC    AL1(SBA)           SBA                          HRC241DK 00245001
@RUNINPT DC    AL2(@INPT70)       InputArea                    HRC241DK 00245001
         DC    AL1(SF,ATTRHIDE)   SF hide                      HRC241DK 00245001
         DC    AL1(IC)            IC                           HRC241DK 00245001
         DC    AL1(EAU)           EAU                          HRC241DK 00245001
@RUNSTAT DC    AL2(@STAT70)       StatusArea                   HRC241DK 00245001
         DC    AL1(SBA)           SBA                          HRC241DK 00245001
@RUNSTA2 DC    AL2(@STAT70)       StatusArea                   HRC241DK 00245001
         DC    AL1(SF,ATTRPROT)   SF prot                      HRC241DK 00245001
         DC    CL19'RUNNING'      'RUNNING'                    HRC241DK 00245001
RUN70D1L EQU   *-RUN70D1                                       HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
*        Set Status = HOLDING                                  HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
HLD70D1  EQU   *                                               HRC241DK 00245001
         DC    AL1(WCCNOMDT)      Restore keyboard             HRC241DK 00245001
         DC    AL1(SBA)           SBA                          HRC241DK 00245001
@HLDSTAT DC    AL2(@STAT70)       StatusArea                   HRC241DK 00245001
         DC    AL1(SF,ATTRHIGH)   SF high                      HRC241DK 00245001
         DC    CL19'HOLDING'      'HOLDING'                    HRC241DK 00245001
HLD70D1L EQU   *-HLD70D1                                       HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
*        Clear data area                                       HRC241DK 00245001
         SPACE 1                                               HRC241DK 00245001
CLR70D1  EQU   *                                               HRC241DK 00245001
         DC    AL1(WCCRSMDT)      Restore keyboard, reset MDTs HRC241DK 00245001
         DC    AL1(SBA),AL2(@ORIG70)      SBA [0,0]            HRC241DK 00245001
         DC    AL1(RA),AL2(@RA1@70),X'00' RA [5,79] 00         HRC241DK 00245001
         DC    AL1(RA),AL2(@RA2@70),X'00' RA [11,79] 00        HRC241DK 00245001
         DC    AL1(RA)                    RA                   HRC241DK 00245001
@CLRRA3  DC    AL2(@RA3@70)               RA-end-3             HRC241DK 00245001
         DC    AL1(0,RA)                  00; RA               HRC241DK 00245001
@CLRINPT DC    AL2(@INPT70)               InputArea            HRC241DK 00245001
         DC    AL1(0)                     00                   HRC241DK 00245001
CLR70D1L EQU   *-CLR70D1                                       HRC241DK 00245001
         EJECT ,                                               HRC241DK 00245001
OPREGS   DC    16F'0'         REGISTER SAVE AREA               @V200730 00263000
*/ I 00263000 $ 00263050 50
         ORG   OPREGS         Map the return registers         HRC241DK 00263050
OPREG0   DS    F              Return R0 = response length      HRC241DK 00263050
OPREG1   DS    F              Return R1 -> response data       HRC241DK 00263050
         ORG   ,                                               HRC241DK 00263050
         SPACE 1                                               HRC241DK 00263050
OP2REGS  DC    16F'0'         2nd level register save          HRC241DK 00263050
IOREGS   DC    16F'0'         I/O routine register save        HRC241DK 00263050
HLDSAVE  DC    F'0'           Save area for HOLDING            HRC241DK 00263050
HLDSAVE2 DC    5F'0'          more regs from HOLDING           HRC241DK 00263050
ATTNSAVE DC    F'0'           Save area for WAITATTN           HRC241DK 00263050
         SPACE                                                          00264000
PARM2    DC    F'0'           PARMS PASSED                              00265000
PARM     EQU   PARM2+3                                                  00266000
*/ R 00267000 00272200 $ 00267001 50      
DOREAD   EQU   X'80'          Read flag (in PARM2)             HRC241DK 00267001
         SPACE 1                                               HRC241DK 00267001
STATUS   DC    X'D0'          Status flags                     HRC241DK 00267001
DIDINIT  EQU   X'80'          X------- Did One-time init       HRC241DK 00267001
CNGRAF   EQU   X'40'          -X------ Graphic console         HRC241DK 00267001
CN3215   EQU   X'20'          --X----- Hardcopy console        HRC241DK 00267001
DOCLR    EQU   X'10'          ---X---- Clear screen needed     HRC241DK 00267001
NODATA   EQU   X'08'          ----X--- No data entered         HRC241DK 00267001
DIDRES   EQU   X'04'          -----X-- Resume PSW built        HRC241DK 00267001
*        EQU   X'02'          ------X- (available)             HRC241DK 00267001
*        EQU   X'01'          -------X (available)             HRC241DK 00267001
         SPACE 1                                               HRC241DK 00267001
CONSGRTY DC    X'00'          Graphic screen type (RDEVDVTY)   HRC241DK 00267001
MODEL2A  EQU   X'0C'          .. value for  3278-2A            HRC241DK 00267001
CONSTYPC DC    AL1(CLASGRAF)  Console device class             HRC241DK 00267001
CONSTYPE DC    AL1(TYP3278)   Console device type              HRC241DK 00267001
CONSADDR DC    XL2'0C0'       Console address                  HRC241DK 00267001
         SPACE 1                                               HRC241DK 00267001
$RUNNING DC    CL20'RUNNING'  Status = RUNNING                 HRC241DK 00267001
$CPREAD  DC    CL20'CP READ'  Status = CP READ                 HRC241DK 00267001
$HOLDING DC    CL20'HOLDING'  Status = HOLDING                 HRC241DK 00267001
         SPACE 1                                               HRC241DK 00267001
SYSMASK  DC    X'00'          System Mask save                 HRC241DK 00267001
         DC    XL1'0'         (available)                      HRC241DK 00267001
@LINE    DC    H'0'           Next data line addr (r,c)        HRC241DK 00267001
@ECHO    DC    H'0'           Prompt line addr (r,c)           HRC241DK 00267001
MAXLINE  DC    H'22'          Highest line in data area        HRC241DK 00267001
LINECT   DC    H'0'           Lines in last message            HRC241DK 00267001
MSGLEN   DC    H'0'           Length of last message           HRC241DK 00267001
MAXECHO  DC    H'0'           Max length for echo              HRC241DK 00267001
CSWSTAT  DC    H'0'           Accumulated CSW status           HRC241DK 00267001
CSWCOUNT DC    H'0'           CSW residual count               HRC241DK 00267001
         SPACE 1                                               HRC241DK 00267001
INLEN    DC    H'0'           Length of operator response      HRC241DK 00267001
RMDATA   DC    XL6'00'        AID, Cursor, SBA, addr           HRC241DK 00267001
INDATA   DC    XL140'00'      Response data                    HRC241DK 00267001
INDATAL  EQU   L'INDATA       (length)                         HRC241DK 00267001
INP66LEN EQU   L'INDATA       Max read length                  HRC241DK 00267001
INP70LEN EQU   L'INDATA       Max read length                  HRC241DK 00267001
NULLINPT DC    XL140'00'      Nulls to clear InputArea         HRC241DK 00267001
CLRMI    DS    XL3            Save 3066 cursor                 HRC241DK 00267001
CLRDATA  DS    XL160          Save last 2 3066 rows            HRC241DK 00267001
         EJECT                                                          00273000
         LTORG                                                          00274000
         EJECT                                                          00275000
         COPY  RBLOKS                                                   00276000
         COPY  EQU                                                      00277000
         COPY  DEVTYPES                                                 00278000
         PSA                                                            00279000
         END                                                            00280000