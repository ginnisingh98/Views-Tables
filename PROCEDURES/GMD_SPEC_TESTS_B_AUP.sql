--------------------------------------------------------
--  DDL for Procedure GMD_SPEC_TESTS_B_AUP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."GMD_SPEC_TESTS_B_AUP" (A0 IN NUMBER,A1 IN NUMBER,JB IN VARCHAR2,JC IN VARCHAR2,JD IN NUMBER,JF IN NUMBER,JG IN VARCHAR2,
JH IN VARCHAR2,JJ IN NUMBER,JK IN NUMBER,JL IN VARCHAR2,JM IN NUMBER,
JN IN VARCHAR2,JP IN NUMBER,JQ IN VARCHAR2,JR IN VARCHAR2,JS IN NUMBER,
JT IN NUMBER,E0 IN NUMBER,E1 IN NUMBER,RB IN VARCHAR2,RC IN VARCHAR2,RD IN NUMBER,RF IN NUMBER,RG IN VARCHAR2,
RH IN VARCHAR2,RJ IN NUMBER,RK IN NUMBER,RL IN VARCHAR2,RM IN NUMBER,
RN IN VARCHAR2,RP IN NUMBER,RQ IN VARCHAR2,RR IN VARCHAR2,RS IN NUMBER,
RT IN NUMBER)
AS
NXT NUMBER;
CMT NUMBER;
NUSER varchar2(100);
newtransaction_TYPE VARCHAR2(1);
newTRUE_NULLS VARCHAR2(250);
tmpPRIMCHANGE NUMBER;
nls_date_fmt VARCHAR2(40);
I0 NUMBER;
I1 NUMBER;
YB VARCHAR2(32);
YC VARCHAR2(32);
YD NUMBER;
YF NUMBER;
YG VARCHAR2(32);
YH VARCHAR2(32);
YJ NUMBER;
YK NUMBER;
YL VARCHAR2(16);
YM NUMBER;
YN VARCHAR2(16);
YP NUMBER;
YQ VARCHAR2(32);
YR VARCHAR2(16);
YS NUMBER;
YT NUMBER;
BEGIN
select value into nls_date_fmt from v$NLS_PARAMETERS where parameter='NLS_DATE_FORMAT';
execute IMMEDIATE 'alter session set nls_date_format="MM/DD/YYYY HH24:MI:SS"';

NUSER:=FND_AUDIT_SEQ_PKG.USER_NAME;
SELECT 0+decode(E0,A0,0,1)+decode(E1,A1,0,1) into tmpPRIMCHANGE FROM SYS.DUAL;
IF tmpPRIMCHANGE>=1 THEN
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
||decode(JT,NULL,'Y','N') INTO newTRUE_NULLS FROM SYS.DUAL;
IF(newTRUE_NULLS='NNNNNNNNNNNNNNNNNN')THEN
 newTRUE_NULLS:=NULL;END IF;
NXT:=FND_AUDIT_SEQ_PKG.NXT;
CMT:=FND_AUDIT_SEQ_PKG.CMT;
INSERT INTO GMD_SPEC_TESTS_B_A
VALUES(SYSDATE,'D',NUSER,newTRUE_NULLS,
USERENV('SESSIONID'),NXT,CMT,(TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'))*100000+MOD(NXT,100000)) * 100000 + USERENV('SESSIONID'),
A0,A1,JB,JC,JD,JF,JG,
JH,JJ,JK,JL,JM,
JN,JP,JQ,JR,JS,
JT);
NXT:=FND_AUDIT_SEQ_PKG.NXT;
CMT:=FND_AUDIT_SEQ_PKG.CMT;
NUSER:=FND_AUDIT_SEQ_PKG.USER_NAME;
INSERT INTO GMD_SPEC_TESTS_B_A
VALUES(SYSDATE,'I',NUSER,NULL,USERENV('SESSIONID'),NXT,CMT,(TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'))*100000+MOD(NXT,100000)) * 100000 + USERENV('SESSIONID'),
E0,E1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL);
ELSE
SELECT DECODE(JB,RB,NULL,JB)INTO YB FROM SYS.DUAL;
SELECT DECODE(JC,RC,NULL,JC)INTO YC FROM SYS.DUAL;
SELECT DECODE(JD,RD,NULL,JD)INTO YD FROM SYS.DUAL;
SELECT DECODE(JF,RF,NULL,JF)INTO YF FROM SYS.DUAL;
SELECT DECODE(JG,RG,NULL,JG)INTO YG FROM SYS.DUAL;
SELECT DECODE(JH,RH,NULL,JH)INTO YH FROM SYS.DUAL;
SELECT DECODE(JJ,RJ,NULL,JJ)INTO YJ FROM SYS.DUAL;
SELECT DECODE(JK,RK,NULL,JK)INTO YK FROM SYS.DUAL;
SELECT DECODE(JL,RL,NULL,JL)INTO YL FROM SYS.DUAL;
SELECT DECODE(JM,RM,NULL,JM)INTO YM FROM SYS.DUAL;
SELECT DECODE(JN,RN,NULL,JN)INTO YN FROM SYS.DUAL;
SELECT DECODE(JP,RP,NULL,JP)INTO YP FROM SYS.DUAL;
SELECT DECODE(JQ,RQ,NULL,JQ)INTO YQ FROM SYS.DUAL;
SELECT DECODE(JR,RR,NULL,JR)INTO YR FROM SYS.DUAL;
SELECT DECODE(JS,RS,NULL,JS)INTO YS FROM SYS.DUAL;
SELECT DECODE(JT,RT,NULL,JT)INTO YT FROM SYS.DUAL;
SELECT decode(A0,NULL,decode(E0,NULL,'N','Y'),'N')
||decode(A1,NULL,decode(E1,NULL,'N','Y'),'N')
||decode(JB,NULL,decode(RB,NULL,'N','Y'),'N')
||decode(JC,NULL,decode(RC,NULL,'N','Y'),'N')
||decode(JD,NULL,decode(RD,NULL,'N','Y'),'N')
||decode(JF,NULL,decode(RF,NULL,'N','Y'),'N')
||decode(JG,NULL,decode(RG,NULL,'N','Y'),'N')
||decode(JH,NULL,decode(RH,NULL,'N','Y'),'N')
||decode(JJ,NULL,decode(RJ,NULL,'N','Y'),'N')
||decode(JK,NULL,decode(RK,NULL,'N','Y'),'N')
||decode(JL,NULL,decode(RL,NULL,'N','Y'),'N')
||decode(JM,NULL,decode(RM,NULL,'N','Y'),'N')
||decode(JN,NULL,decode(RN,NULL,'N','Y'),'N')
||decode(JP,NULL,decode(RP,NULL,'N','Y'),'N')
||decode(JQ,NULL,decode(RQ,NULL,'N','Y'),'N')
||decode(JR,NULL,decode(RR,NULL,'N','Y'),'N')
||decode(JS,NULL,decode(RS,NULL,'N','Y'),'N')
||decode(JT,NULL,decode(RT,NULL,'N','Y'),'N') INTO newTRUE_NULLS FROM SYS.DUAL;
IF(newTRUE_NULLS='NNNNNNNNNNNNNNNNNN')THEN newTRUE_NULLS:=NULL;END IF;
IF(newTRUE_NULLS is not NULL)OR 
YB IS NOT NULL OR 
YC IS NOT NULL OR 
YD IS NOT NULL OR 
YF IS NOT NULL OR 
YG IS NOT NULL OR 
YH IS NOT NULL OR 
YJ IS NOT NULL OR 
YK IS NOT NULL OR 
YL IS NOT NULL OR 
YM IS NOT NULL OR 
YN IS NOT NULL OR 
YP IS NOT NULL OR 
YQ IS NOT NULL OR 
YR IS NOT NULL OR 
YS IS NOT NULL OR 
YT IS NOT NULL THEN
NXT:=FND_AUDIT_SEQ_PKG.NXT;
CMT:=FND_AUDIT_SEQ_PKG.CMT;
INSERT INTO GMD_SPEC_TESTS_B_A
VALUES(SYSDATE,'U',NUSER,newTRUE_NULLS,USERENV('SESSIONID'),NXT,CMT,(TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'))*100000+MOD(NXT,100000)) * 100000 + USERENV('SESSIONID'),
E0,E1,YB,YC,YD,YF,YG,
YH,YJ,YK,YL,YM,
YN,YP,YQ,YR,YS,
YT);
END IF;
END IF;

execute IMMEDIATE 'alter session set nls_date_format="'||nls_date_fmt||'"';
END GMD_SPEC_TESTS_B_AUP;

/
