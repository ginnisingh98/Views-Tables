--------------------------------------------------------
--  DDL for Procedure FV_SYSTEM_PARAMETERS_AIP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."FV_SYSTEM_PARAMETERS_AIP" (A0 IN DATE,JB IN VARCHAR2,JC IN NUMBER,JD IN DATE,JF IN VARCHAR2,JG IN VARCHAR2,
JH IN VARCHAR2,JJ IN VARCHAR2,JK IN VARCHAR2,JL IN VARCHAR2,JM IN VARCHAR2,
JN IN VARCHAR2,JP IN VARCHAR2,JQ IN NUMBER,JR IN NUMBER,JS IN VARCHAR2,
JT IN VARCHAR2,JV IN VARCHAR2,JW IN VARCHAR2,JX IN VARCHAR2,E0 IN DATE,RB IN VARCHAR2,RC IN NUMBER,RD IN DATE,RF IN VARCHAR2,RG IN VARCHAR2,
RH IN VARCHAR2,RJ IN VARCHAR2,RK IN VARCHAR2,RL IN VARCHAR2,RM IN VARCHAR2,
RN IN VARCHAR2,RP IN VARCHAR2,RQ IN NUMBER,RR IN NUMBER,RS IN VARCHAR2,
RT IN VARCHAR2,RV IN VARCHAR2,RW IN VARCHAR2,RX IN VARCHAR2 )
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
INSERT INTO FV_SYSTEM_PARAMETERS_A
 VALUES(SYSDATE,'I',NUSER,NULL,USERENV('SESSIONID'),NXT,CMT,ROWKEY,E0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
execute IMMEDIATE 'alter session set nls_date_format="'||nls_date_fmt||'"';

END FV_SYSTEM_PARAMETERS_AIP;

/