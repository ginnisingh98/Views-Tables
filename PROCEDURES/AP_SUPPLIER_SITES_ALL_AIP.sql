--------------------------------------------------------
--  DDL for Procedure AP_SUPPLIER_SITES_ALL_AIP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."AP_SUPPLIER_SITES_ALL_AIP" (A0 IN NUMBER,JB IN NUMBER,JC IN VARCHAR2,JD IN VARCHAR2,JF IN NUMBER,JG IN VARCHAR2,
JH IN NUMBER,JJ IN VARCHAR2,JK IN VARCHAR2,JL IN NUMBER,JM IN VARCHAR2,
JN IN VARCHAR2,JP IN VARCHAR2,JQ IN VARCHAR2,JR IN VARCHAR2,JS IN VARCHAR2,
JT IN NUMBER,JV IN NUMBER,JW IN VARCHAR2,JX IN VARCHAR2,JZ IN NUMBER,
J0 IN NUMBER,J1 IN NUMBER,J2 IN VARCHAR2,E0 IN NUMBER,RB IN NUMBER,RC IN VARCHAR2,RD IN VARCHAR2,RF IN NUMBER,RG IN VARCHAR2,
RH IN NUMBER,RJ IN VARCHAR2,RK IN VARCHAR2,RL IN NUMBER,RM IN VARCHAR2,
RN IN VARCHAR2,RP IN VARCHAR2,RQ IN VARCHAR2,RR IN VARCHAR2,RS IN VARCHAR2,
RT IN NUMBER,RV IN NUMBER,RW IN VARCHAR2,RX IN VARCHAR2,RZ IN NUMBER,
R0 IN NUMBER,R1 IN NUMBER,R2 IN VARCHAR2 )
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
INSERT INTO AP_SUPPLIER_SITES_ALL_A
 VALUES(SYSDATE,'I',NUSER,NULL,USERENV('SESSIONID'),NXT,CMT,ROWKEY,E0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL);
execute IMMEDIATE 'alter session set nls_date_format="'||nls_date_fmt||'"';

END AP_SUPPLIER_SITES_ALL_AIP;

/