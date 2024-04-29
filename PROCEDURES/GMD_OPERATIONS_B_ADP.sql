--------------------------------------------------------
--  DDL for Procedure GMD_OPERATIONS_B_ADP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."GMD_OPERATIONS_B_ADP" (A0 IN NUMBER,JB IN NUMBER,JC IN DATE,JD IN DATE,JF IN VARCHAR2,JG IN VARCHAR2,
JH IN NUMBER,JJ IN VARCHAR2,JK IN VARCHAR2,E0 IN NUMBER,RB IN NUMBER,RC IN DATE,RD IN DATE,RF IN VARCHAR2,RG IN VARCHAR2,
RH IN NUMBER,RJ IN VARCHAR2,RK IN VARCHAR2)
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
||decode(JB,NULL,'Y','N')
||decode(JC,NULL,'Y','N')
||decode(JD,NULL,'Y','N')
||decode(JF,NULL,'Y','N')
||decode(JG,NULL,'Y','N')
||decode(JH,NULL,'Y','N')
||decode(JJ,NULL,'Y','N')
||decode(JK,NULL,'Y','N') INTO newTRUE_NULLS FROM SYS.DUAL;
IF(newTRUE_NULLS='NNNNNNNNN') THEN 
newTRUE_NULLS:= NULL;
END IF;
INSERT INTO GMD_OPERATIONS_B_A
VALUES(SYSDATE,'D',NUSER,newTRUE_NULLS,
USERENV('SESSIONID'),NXT,CMT,(TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'))*100000+MOD(NXT,100000)) * 100000 + USERENV('SESSIONID'),
A0,JB,JC,JD,JF,JG,
JH,JJ,JK);
execute IMMEDIATE 'alter session set nls_date_format="'||nls_date_fmt||'"';
END GMD_OPERATIONS_B_ADP;

/
