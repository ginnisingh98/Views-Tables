--------------------------------------------------------
--  DDL for Procedure FINANCIALS_SYSTEM_PARAMS_ADP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."FINANCIALS_SYSTEM_PARAMS_ADP" (A0 IN NUMBER,A1 IN NUMBER,JB IN NUMBER,JC IN VARCHAR2,JD IN VARCHAR2,JF IN NUMBER,JG IN NUMBER,
JH IN VARCHAR2,JJ IN NUMBER,JK IN DATE,JL IN NUMBER,JM IN NUMBER,
JN IN VARCHAR2,JP IN VARCHAR2,JQ IN NUMBER,JR IN VARCHAR2,JS IN VARCHAR2,
JT IN NUMBER,JV IN NUMBER,JW IN VARCHAR2,JX IN VARCHAR2,JZ IN VARCHAR2,
J0 IN VARCHAR2,J1 IN VARCHAR2,J2 IN VARCHAR2,J3 IN VARCHAR2,J4 IN VARCHAR2,
J5 IN VARCHAR2,J6 IN VARCHAR2,J7 IN VARCHAR2,J8 IN VARCHAR2,J9 IN VARCHAR2,
KB IN VARCHAR2,KC IN VARCHAR2,KD IN VARCHAR2,KF IN VARCHAR2,KG IN VARCHAR2,
KH IN VARCHAR2,KJ IN VARCHAR2,KK IN VARCHAR2,KL IN VARCHAR2,KM IN NUMBER,
KN IN VARCHAR2,KP IN NUMBER,KQ IN NUMBER,KR IN DATE,KS IN NUMBER,
KT IN VARCHAR2,KV IN VARCHAR2,KW IN NUMBER,KX IN NUMBER,KZ IN VARCHAR2,
K0 IN VARCHAR2,K1 IN VARCHAR2,K2 IN VARCHAR2,K3 IN NUMBER,K4 IN NUMBER,
K5 IN VARCHAR2,K6 IN NUMBER,K7 IN NUMBER,K8 IN NUMBER,K9 IN NUMBER,
LB IN NUMBER,LC IN VARCHAR2,LD IN NUMBER,LF IN VARCHAR2,LG IN NUMBER,
LH IN NUMBER,LJ IN NUMBER,LK IN VARCHAR2,LL IN NUMBER,LM IN VARCHAR2,
LN IN VARCHAR2,LP IN VARCHAR2,LQ IN NUMBER,LR IN VARCHAR2,LS IN VARCHAR2,
LT IN VARCHAR2,LV IN VARCHAR2,LW IN VARCHAR2,LX IN NUMBER,E0 IN NUMBER,E1 IN NUMBER,RB IN NUMBER,RC IN VARCHAR2,RD IN VARCHAR2,RF IN NUMBER,RG IN NUMBER,
RH IN VARCHAR2,RJ IN NUMBER,RK IN DATE,RL IN NUMBER,RM IN NUMBER,
RN IN VARCHAR2,RP IN VARCHAR2,RQ IN NUMBER,RR IN VARCHAR2,RS IN VARCHAR2,
RT IN NUMBER,RV IN NUMBER,RW IN VARCHAR2,RX IN VARCHAR2,RZ IN VARCHAR2,
R0 IN VARCHAR2,R1 IN VARCHAR2,R2 IN VARCHAR2,R3 IN VARCHAR2,R4 IN VARCHAR2,
R5 IN VARCHAR2,R6 IN VARCHAR2,R7 IN VARCHAR2,R8 IN VARCHAR2,R9 IN VARCHAR2,
SB IN VARCHAR2,SC IN VARCHAR2,SD IN VARCHAR2,SF IN VARCHAR2,SG IN VARCHAR2,
SH IN VARCHAR2,SJ IN VARCHAR2,SK IN VARCHAR2,SL IN VARCHAR2,SM IN NUMBER,
SN IN VARCHAR2,SP IN NUMBER,SQ IN NUMBER,SR IN DATE,SS IN NUMBER,
ST IN VARCHAR2,SV IN VARCHAR2,SW IN NUMBER,SX IN NUMBER,SZ IN VARCHAR2,
S0 IN VARCHAR2,S1 IN VARCHAR2,S2 IN VARCHAR2,S3 IN NUMBER,S4 IN NUMBER,
S5 IN VARCHAR2,S6 IN NUMBER,S7 IN NUMBER,S8 IN NUMBER,S9 IN NUMBER,
TB IN NUMBER,TC IN VARCHAR2,TD IN NUMBER,TF IN VARCHAR2,TG IN NUMBER,
TH IN NUMBER,TJ IN NUMBER,TK IN VARCHAR2,TL IN NUMBER,TM IN VARCHAR2,
TN IN VARCHAR2,TP IN VARCHAR2,TQ IN NUMBER,TR IN VARCHAR2,TS IN VARCHAR2,
TT IN VARCHAR2,TV IN VARCHAR2,TW IN VARCHAR2,TX IN NUMBER)
AS
NXT NUMBER;
CMT NUMBER;
NUSER varchar2(100);
newTRUE_NULLS VARCHAR2(250);
nls_date_fmt VARCHAR2(40);
BEGIN
select value into nls_date_fmt from v$NLS_PARAMETERS where parameter='NLS_DATE_FORMAT';
execute IMMEDIATE 'alter session set nls_date_format="MM/DD/YYYY HH24:MI:SS"';
NXT:=FND_AUDIT_SEQ_PKG.NXT;
CMT:=FND_AUDIT_SEQ_PKG.CMT;
NUSER:=FND_AUDIT_SEQ_PKG.USER_NAME;
SELECT decode(A0,NULL,'Y','N')
||decode(A1,NULL,'Y','N')
||decode(JB,NULL,'Y','N')
||decode(JC,NULL,'Y','N')
||decode(JD,NULL,'Y','N')
||decode(JF,NULL,'Y','N')
||decode(JG,NULL,'Y','N')
||decode(JH,NULL,'Y','N')
||decode(JJ,NULL,'Y','N')
||decode(JK,NULL,'Y','N')
||decode(JL,NULL,'Y','N')
||decode(JM,NULL,'Y','N')
||decode(JN,NULL,'Y','N')
||decode(JP,NULL,'Y','N')
||decode(JQ,NULL,'Y','N')
||decode(JR,NULL,'Y','N')
||decode(JS,NULL,'Y','N')
||decode(JT,NULL,'Y','N')
||decode(JV,NULL,'Y','N')
||decode(JW,NULL,'Y','N')
||decode(JX,NULL,'Y','N')
||decode(JZ,NULL,'Y','N')
||decode(J0,NULL,'Y','N')
||decode(J1,NULL,'Y','N')
||decode(J2,NULL,'Y','N')
||decode(J3,NULL,'Y','N')
||decode(J4,NULL,'Y','N')
||decode(J5,NULL,'Y','N')
||decode(J6,NULL,'Y','N')
||decode(J7,NULL,'Y','N')
||decode(J8,NULL,'Y','N')
||decode(J9,NULL,'Y','N')
||decode(KB,NULL,'Y','N')
||decode(KC,NULL,'Y','N')
||decode(KD,NULL,'Y','N')
||decode(KF,NULL,'Y','N')
||decode(KG,NULL,'Y','N')
||decode(KH,NULL,'Y','N')
||decode(KJ,NULL,'Y','N')
||decode(KK,NULL,'Y','N')
||decode(KL,NULL,'Y','N')
||decode(KM,NULL,'Y','N')
||decode(KN,NULL,'Y','N')
||decode(KP,NULL,'Y','N')
||decode(KQ,NULL,'Y','N')
||decode(KR,NULL,'Y','N')
||decode(KS,NULL,'Y','N')
||decode(KT,NULL,'Y','N')
||decode(KV,NULL,'Y','N')
||decode(KW,NULL,'Y','N')
||decode(KX,NULL,'Y','N')
||decode(KZ,NULL,'Y','N')
||decode(K0,NULL,'Y','N')
||decode(K1,NULL,'Y','N')
||decode(K2,NULL,'Y','N')
||decode(K3,NULL,'Y','N')
||decode(K4,NULL,'Y','N')
||decode(K5,NULL,'Y','N')
||decode(K6,NULL,'Y','N')
||decode(K7,NULL,'Y','N')
||decode(K8,NULL,'Y','N')
||decode(K9,NULL,'Y','N')
||decode(LB,NULL,'Y','N')
||decode(LC,NULL,'Y','N')
||decode(LD,NULL,'Y','N')
||decode(LF,NULL,'Y','N')
||decode(LG,NULL,'Y','N')
||decode(LH,NULL,'Y','N')
||decode(LJ,NULL,'Y','N')
||decode(LK,NULL,'Y','N')
||decode(LL,NULL,'Y','N')
||decode(LM,NULL,'Y','N')
||decode(LN,NULL,'Y','N')
||decode(LP,NULL,'Y','N')
||decode(LQ,NULL,'Y','N')
||decode(LR,NULL,'Y','N')
||decode(LS,NULL,'Y','N')
||decode(LT,NULL,'Y','N')
||decode(LV,NULL,'Y','N')
||decode(LW,NULL,'Y','N')
||decode(LX,NULL,'Y','N') INTO newTRUE_NULLS FROM SYS.DUAL;
IF(newTRUE_NULLS='NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN') THEN 
newTRUE_NULLS:= NULL;
END IF;
INSERT INTO FINANCIALS_SYSTEM_PARAMS_A
VALUES(SYSDATE,'D',NUSER,newTRUE_NULLS,
USERENV('SESSIONID'),NXT,CMT,(TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'))*100000+MOD(NXT,100000)) * 100000 + USERENV('SESSIONID'),
A0,A1,JB,JC,JD,JF,JG,
JH,JJ,JK,JL,JM,
JN,JP,JQ,JR,JS,
JT,JV,JW,JX,JZ,
J0,J1,J2,J3,J4,
J5,J6,J7,J8,J9,
KB,KC,KD,KF,KG,
KH,KJ,KK,KL,KM,
KN,KP,KQ,KR,KS,
KT,KV,KW,KX,KZ,
K0,K1,K2,K3,K4,
K5,K6,K7,K8,K9,
LB,LC,LD,LF,LG,
LH,LJ,LK,LL,LM,
LN,LP,LQ,LR,LS,
LT,LV,LW,LX);
execute IMMEDIATE 'alter session set nls_date_format="'||nls_date_fmt||'"';
END FINANCIALS_SYSTEM_PARAMS_ADP;

/