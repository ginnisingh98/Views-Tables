--------------------------------------------------------
--  DDL for Procedure CE_SYSTEM_PARAMETERS_ADP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."CE_SYSTEM_PARAMETERS_ADP" (A0 IN NUMBER,A1 IN NUMBER,JB IN VARCHAR2,JC IN VARCHAR2,JD IN VARCHAR2,JF IN VARCHAR2,JG IN VARCHAR2,
JH IN VARCHAR2,JJ IN VARCHAR2,JK IN VARCHAR2,JL IN VARCHAR2,JM IN VARCHAR2,
JN IN VARCHAR2,JP IN VARCHAR2,JQ IN VARCHAR2,JR IN VARCHAR2,JS IN VARCHAR2,
JT IN VARCHAR2,JV IN VARCHAR2,JW IN VARCHAR2,JX IN VARCHAR2,JZ IN DATE,
J0 IN VARCHAR2,J1 IN NUMBER,J2 IN DATE,J3 IN VARCHAR2,J4 IN VARCHAR2,
J5 IN NUMBER,J6 IN DATE,J7 IN NUMBER,J8 IN NUMBER,J9 IN VARCHAR2,
KB IN VARCHAR2,KC IN VARCHAR2,KD IN VARCHAR2,E0 IN NUMBER,E1 IN NUMBER,RB IN VARCHAR2,RC IN VARCHAR2,RD IN VARCHAR2,RF IN VARCHAR2,RG IN VARCHAR2,
RH IN VARCHAR2,RJ IN VARCHAR2,RK IN VARCHAR2,RL IN VARCHAR2,RM IN VARCHAR2,
RN IN VARCHAR2,RP IN VARCHAR2,RQ IN VARCHAR2,RR IN VARCHAR2,RS IN VARCHAR2,
RT IN VARCHAR2,RV IN VARCHAR2,RW IN VARCHAR2,RX IN VARCHAR2,RZ IN DATE,
R0 IN VARCHAR2,R1 IN NUMBER,R2 IN DATE,R3 IN VARCHAR2,R4 IN VARCHAR2,
R5 IN NUMBER,R6 IN DATE,R7 IN NUMBER,R8 IN NUMBER,R9 IN VARCHAR2,
SB IN VARCHAR2,SC IN VARCHAR2,SD IN VARCHAR2)
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
||decode(KD,NULL,'Y','N') INTO newTRUE_NULLS FROM SYS.DUAL;
IF(newTRUE_NULLS='NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN') THEN 
newTRUE_NULLS:= NULL;
END IF;
INSERT INTO CE_SYSTEM_PARAMETERS_A
VALUES(SYSDATE,'D',NUSER,newTRUE_NULLS,
USERENV('SESSIONID'),NXT,CMT,(TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'))*100000+MOD(NXT,100000)) * 100000 + USERENV('SESSIONID'),
A0,A1,JB,JC,JD,JF,JG,
JH,JJ,JK,JL,JM,
JN,JP,JQ,JR,JS,
JT,JV,JW,JX,JZ,
J0,J1,J2,J3,J4,
J5,J6,J7,J8,J9,
KB,KC,KD);
execute IMMEDIATE 'alter session set nls_date_format="'||nls_date_fmt||'"';
END CE_SYSTEM_PARAMETERS_ADP;

/