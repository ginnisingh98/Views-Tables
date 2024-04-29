--------------------------------------------------------
--  DDL for Procedure CE_SYSTEM_PARAMETERS_AIP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."CE_SYSTEM_PARAMETERS_AIP" (A0 IN NUMBER,A1 IN NUMBER,JB IN VARCHAR2,JC IN VARCHAR2,JD IN VARCHAR2,JF IN VARCHAR2,JG IN VARCHAR2,
JH IN VARCHAR2,JJ IN VARCHAR2,JK IN VARCHAR2,JL IN VARCHAR2,JM IN VARCHAR2,
JN IN VARCHAR2,JP IN VARCHAR2,JQ IN VARCHAR2,JR IN VARCHAR2,JS IN VARCHAR2,
JT IN VARCHAR2,JV IN VARCHAR2,JW IN VARCHAR2,JX IN VARCHAR2,JZ IN DATE,
J0 IN VARCHAR2,J1 IN NUMBER,J2 IN DATE,J3 IN VARCHAR2,J4 IN VARCHAR2,
J5 IN NUMBER,J6 IN DATE,J7 IN NUMBER,J8 IN NUMBER,J9 IN VARCHAR2,
KB IN VARCHAR2,KC IN VARCHAR2,KD IN VARCHAR2,E0 IN NUMBER,E1 IN NUMBER,RB IN VARCHAR2,RC IN VARCHAR2,RD IN VARCHAR2,RF IN VARCHAR2,RG IN VARCHAR2,
RH IN VARCHAR2,RJ IN VARCHAR2,RK IN VARCHAR2,RL IN VARCHAR2,RM IN VARCHAR2,
RN IN VARCHAR2,RP IN VARCHAR2,RQ IN VARCHAR2,RR IN VARCHAR2,RS IN VARCHAR2,
RT IN VARCHAR2,RV IN VARCHAR2,RW IN VARCHAR2,RX IN VARCHAR2,RZ IN DATE,
R0 IN VARCHAR2,R1 IN NUMBER,R2 IN DATE,R3 IN VARCHAR2,R4 IN VARCHAR2,
R5 IN NUMBER,R6 IN DATE,R7 IN NUMBER,R8 IN NUMBER,R9 IN VARCHAR2,
SB IN VARCHAR2,SC IN VARCHAR2,SD IN VARCHAR2 )
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
INSERT INTO CE_SYSTEM_PARAMETERS_A
 VALUES(SYSDATE,'I',NUSER,NULL,USERENV('SESSIONID'),NXT,CMT,ROWKEY,E0,E1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL);
execute IMMEDIATE 'alter session set nls_date_format="'||nls_date_fmt||'"';

END CE_SYSTEM_PARAMETERS_AIP;

/