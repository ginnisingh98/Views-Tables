--------------------------------------------------------
--  DDL for Procedure GME_MATERIAL_DETAILS_AIP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."GME_MATERIAL_DETAILS_AIP" (A0 IN NUMBER,JB IN NUMBER,JC IN NUMBER,JD IN VARCHAR2,JF IN NUMBER,JG IN NUMBER,
JH IN NUMBER,JJ IN NUMBER,JK IN NUMBER,E0 IN NUMBER,RB IN NUMBER,RC IN NUMBER,RD IN VARCHAR2,RF IN NUMBER,RG IN NUMBER,
RH IN NUMBER,RJ IN NUMBER,RK IN NUMBER )
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
INSERT INTO GME_MATERIAL_DETAILS_A
 VALUES(SYSDATE,'I',NUSER,NULL,USERENV('SESSIONID'),NXT,CMT,ROWKEY,E0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
execute IMMEDIATE 'alter session set nls_date_format="'||nls_date_fmt||'"';

END GME_MATERIAL_DETAILS_AIP;

/
