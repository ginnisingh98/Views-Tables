--------------------------------------------------------
--  DDL for Procedure IBY_EXT_BANK_ACCOUNTS_AUP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."IBY_EXT_BANK_ACCOUNTS_AUP" (A0 IN NUMBER,JB IN VARCHAR2,JC IN DATE,JD IN VARCHAR2,JF IN DATE,E0 IN NUMBER,RB IN VARCHAR2,RC IN DATE,RD IN VARCHAR2,RF IN DATE)
AS
NXT NUMBER;
CMT NUMBER;
NUSER varchar2(100);
newtransaction_TYPE VARCHAR2(1);
newTRUE_NULLS VARCHAR2(250);
tmpPRIMCHANGE NUMBER;
nls_date_fmt VARCHAR2(40);
I0 NUMBER(15,0);
YB VARCHAR2(100);
YC DATE;
YD VARCHAR2(50);
YF DATE;
BEGIN
select value into nls_date_fmt from v$NLS_PARAMETERS where parameter='NLS_DATE_FORMAT';
execute IMMEDIATE 'alter session set nls_date_format="MM/DD/YYYY HH24:MI:SS"';

NUSER:=FND_AUDIT_SEQ_PKG.USER_NAME;
SELECT 0+decode(E0,A0,0,1) into tmpPRIMCHANGE FROM SYS.DUAL;
IF tmpPRIMCHANGE>=1 THEN
SELECT decode(A0,NULL,'Y','N')
||decode(JB,NULL,'Y','N')
||decode(JC,NULL,'Y','N')
||decode(JD,NULL,'Y','N')
||decode(JF,NULL,'Y','N') INTO newTRUE_NULLS FROM SYS.DUAL;
IF(newTRUE_NULLS='NNNNN')THEN
 newTRUE_NULLS:=NULL;END IF;
NXT:=FND_AUDIT_SEQ_PKG.NXT;
CMT:=FND_AUDIT_SEQ_PKG.CMT;
INSERT INTO IBY_EXT_BANK_ACCOUNTS_A
VALUES(SYSDATE,'D',NUSER,newTRUE_NULLS,
USERENV('SESSIONID'),NXT,CMT,(TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'))*100000+MOD(NXT,100000)) * 100000 + USERENV('SESSIONID'),
A0,JB,JC,JD,JF);
NXT:=FND_AUDIT_SEQ_PKG.NXT;
CMT:=FND_AUDIT_SEQ_PKG.CMT;
NUSER:=FND_AUDIT_SEQ_PKG.USER_NAME;
INSERT INTO IBY_EXT_BANK_ACCOUNTS_A
VALUES(SYSDATE,'I',NUSER,NULL,USERENV('SESSIONID'),NXT,CMT,(TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'))*100000+MOD(NXT,100000)) * 100000 + USERENV('SESSIONID'),
E0,NULL,NULL,NULL,NULL);
ELSE
SELECT DECODE(JB,RB,NULL,JB)INTO YB FROM SYS.DUAL;
SELECT DECODE(JC,RC,NULL,JC)INTO YC FROM SYS.DUAL;
SELECT DECODE(JD,RD,NULL,JD)INTO YD FROM SYS.DUAL;
SELECT DECODE(JF,RF,NULL,JF)INTO YF FROM SYS.DUAL;
SELECT decode(A0,NULL,decode(E0,NULL,'N','Y'),'N')
||decode(JB,NULL,decode(RB,NULL,'N','Y'),'N')
||decode(JC,NULL,decode(RC,NULL,'N','Y'),'N')
||decode(JD,NULL,decode(RD,NULL,'N','Y'),'N')
||decode(JF,NULL,decode(RF,NULL,'N','Y'),'N') INTO newTRUE_NULLS FROM SYS.DUAL;
IF(newTRUE_NULLS='NNNNN')THEN newTRUE_NULLS:=NULL;END IF;
IF(newTRUE_NULLS is not NULL)OR 
YB IS NOT NULL OR 
YC IS NOT NULL OR 
YD IS NOT NULL OR 
YF IS NOT NULL THEN
NXT:=FND_AUDIT_SEQ_PKG.NXT;
CMT:=FND_AUDIT_SEQ_PKG.CMT;
INSERT INTO IBY_EXT_BANK_ACCOUNTS_A
VALUES(SYSDATE,'U',NUSER,newTRUE_NULLS,USERENV('SESSIONID'),NXT,CMT,(TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'))*100000+MOD(NXT,100000)) * 100000 + USERENV('SESSIONID'),
E0,YB,YC,YD,YF);
END IF;
END IF;

execute IMMEDIATE 'alter session set nls_date_format="'||nls_date_fmt||'"';
END IBY_EXT_BANK_ACCOUNTS_AUP;

/
