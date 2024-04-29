--------------------------------------------------------
--  DDL for Procedure GMD_OPERATIONS_B_AIP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."GMD_OPERATIONS_B_AIP" (A0 IN NUMBER,JB IN NUMBER,JC IN DATE,JD IN DATE,JF IN VARCHAR2,JG IN VARCHAR2,
JH IN NUMBER,JJ IN VARCHAR2,JK IN VARCHAR2,E0 IN NUMBER,RB IN NUMBER,RC IN DATE,RD IN DATE,RF IN VARCHAR2,RG IN VARCHAR2,
RH IN NUMBER,RJ IN VARCHAR2,RK IN VARCHAR2 )
AS
ROWKEY number;
NXT number;
CMT number;
NUSER varchar2(100);
nls_date_fmt VARCHAR2(40);
BEGIN
select value into nls_date_fmt from v$NLS_PARAMETERS where parameter='NLS_DATE_FORMAT';
execute IMMEDIATE 'alter session set nls_date_format="MM/DD/YYYY HH24:MI:SS"';
NXT:=FND_AUDIT_SEQ_PKG.NXT;
CMT:=FND_AUDIT_SEQ_PKG.CMT;
ROWKEY:=(TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'))*100000 +MOD(NXT,100000)) * 100000 + USERENV('SESSIONID');
NUSER:=FND_AUDIT_SEQ_PKG.USER_NAME;
INSERT INTO GMD_OPERATIONS_B_A
 VALUES(SYSDATE,'I',NUSER,NULL,USERENV('SESSIONID'),NXT,CMT,ROWKEY,E0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
execute IMMEDIATE 'alter session set nls_date_format="'||nls_date_fmt||'"';

END GMD_OPERATIONS_B_AIP;

/
