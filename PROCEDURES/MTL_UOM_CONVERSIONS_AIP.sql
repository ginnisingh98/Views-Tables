--------------------------------------------------------
--  DDL for Procedure MTL_UOM_CONVERSIONS_AIP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."MTL_UOM_CONVERSIONS_AIP" (A0 IN NUMBER,A1 IN VARCHAR2,JB IN NUMBER,JC IN DATE,E0 IN NUMBER,E1 IN VARCHAR2,RB IN NUMBER,RC IN DATE )
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
INSERT INTO MTL_UOM_CONVERSIONS_A
 VALUES(SYSDATE,'I',NUSER,NULL,USERENV('SESSIONID'),NXT,CMT,ROWKEY,E0,E1,NULL,NULL);
execute IMMEDIATE 'alter session set nls_date_format="'||nls_date_fmt||'"';

END MTL_UOM_CONVERSIONS_AIP;

/
