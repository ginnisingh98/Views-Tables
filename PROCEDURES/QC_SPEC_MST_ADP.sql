--------------------------------------------------------
--  DDL for Procedure QC_SPEC_MST_ADP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."QC_SPEC_MST_ADP" (A0 IN NUMBER,JB IN VARCHAR2,JC IN NUMBER,JD IN DATE,JF IN NUMBER,JG IN VARCHAR2,
JH IN NUMBER,JJ IN NUMBER,JK IN NUMBER,JL IN VARCHAR2,JM IN NUMBER,
JN IN NUMBER,JP IN NUMBER,JQ IN VARCHAR2,JR IN DATE,JS IN VARCHAR2,E0 IN NUMBER,RB IN VARCHAR2,RC IN NUMBER,RD IN DATE,RF IN NUMBER,RG IN VARCHAR2,
RH IN NUMBER,RJ IN NUMBER,RK IN NUMBER,RL IN VARCHAR2,RM IN NUMBER,
RN IN NUMBER,RP IN NUMBER,RQ IN VARCHAR2,RR IN DATE,RS IN VARCHAR2)
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
||decode(JK,NULL,'Y','N')
||decode(JL,NULL,'Y','N')
||decode(JM,NULL,'Y','N')
||decode(JN,NULL,'Y','N')
||decode(JP,NULL,'Y','N')
||decode(JQ,NULL,'Y','N')
||decode(JR,NULL,'Y','N')
||decode(JS,NULL,'Y','N') INTO newTRUE_NULLS FROM SYS.DUAL;
IF(newTRUE_NULLS='NNNNNNNNNNNNNNNN') THEN 
newTRUE_NULLS:= NULL;
END IF;
INSERT INTO QC_SPEC_MST_A
VALUES(SYSDATE,'D',NUSER,newTRUE_NULLS,
USERENV('SESSIONID'),NXT,CMT,(TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'))*100000+MOD(NXT,100000)) * 100000 + USERENV('SESSIONID'),
A0,JB,JC,JD,JF,JG,
JH,JJ,JK,JL,JM,
JN,JP,JQ,JR,JS);
execute IMMEDIATE 'alter session set nls_date_format="'||nls_date_fmt||'"';
END QC_SPEC_MST_ADP;

/
