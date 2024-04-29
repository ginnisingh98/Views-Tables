--------------------------------------------------------
--  DDL for Procedure FND_AUDIT_GROUPS_ADP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."FND_AUDIT_GROUPS_ADP" (A0 IN NUMBER,A1 IN NUMBER,JB IN VARCHAR2,JC IN VARCHAR2,E0 IN NUMBER,E1 IN NUMBER,RB IN VARCHAR2,RC IN VARCHAR2)
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
||decode(JC,NULL,'Y','N') INTO newTRUE_NULLS FROM SYS.DUAL;
IF(newTRUE_NULLS='NNNN') THEN 
newTRUE_NULLS:= NULL;
END IF;
INSERT INTO FND_AUDIT_GROUPS_A
VALUES(SYSDATE,'D',NUSER,newTRUE_NULLS,
USERENV('SESSIONID'),NXT,CMT,(TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'))*100000+MOD(NXT,100000)) * 100000 + USERENV('SESSIONID'),
A0,A1,JB,JC);
execute IMMEDIATE 'alter session set nls_date_format="'||nls_date_fmt||'"';
END FND_AUDIT_GROUPS_ADP;

/