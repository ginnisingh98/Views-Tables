--------------------------------------------------------
--  DDL for Procedure RCV_PARAMETERS_AIP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."RCV_PARAMETERS_AIP" (A0 IN NUMBER,JB IN VARCHAR2,JC IN VARCHAR2,JD IN VARCHAR2,JF IN VARCHAR2,JG IN VARCHAR2,
JH IN NUMBER,JJ IN NUMBER,JK IN DATE,JL IN NUMBER,JM IN NUMBER,
JN IN VARCHAR2,JP IN VARCHAR2,JQ IN VARCHAR2,JR IN VARCHAR2,JS IN VARCHAR2,
JT IN VARCHAR2,JV IN VARCHAR2,JW IN VARCHAR2,JX IN VARCHAR2,JZ IN VARCHAR2,
J0 IN VARCHAR2,J1 IN VARCHAR2,J2 IN VARCHAR2,J3 IN VARCHAR2,J4 IN VARCHAR2,
J5 IN VARCHAR2,J6 IN VARCHAR2,J7 IN VARCHAR2,J8 IN VARCHAR2,J9 IN VARCHAR2,
KB IN VARCHAR2,KC IN VARCHAR2,KD IN VARCHAR2,KF IN VARCHAR2,KG IN NUMBER,
KH IN NUMBER,KJ IN DATE,KK IN VARCHAR2,KL IN NUMBER,KM IN NUMBER,
KN IN DATE,KP IN VARCHAR2,KQ IN NUMBER,KR IN VARCHAR2,KS IN VARCHAR2,
KT IN NUMBER,KV IN NUMBER,KW IN NUMBER,KX IN NUMBER,KZ IN NUMBER,
K0 IN VARCHAR2,E0 IN NUMBER,RB IN VARCHAR2,RC IN VARCHAR2,RD IN VARCHAR2,RF IN VARCHAR2,RG IN VARCHAR2,
RH IN NUMBER,RJ IN NUMBER,RK IN DATE,RL IN NUMBER,RM IN NUMBER,
RN IN VARCHAR2,RP IN VARCHAR2,RQ IN VARCHAR2,RR IN VARCHAR2,RS IN VARCHAR2,
RT IN VARCHAR2,RV IN VARCHAR2,RW IN VARCHAR2,RX IN VARCHAR2,RZ IN VARCHAR2,
R0 IN VARCHAR2,R1 IN VARCHAR2,R2 IN VARCHAR2,R3 IN VARCHAR2,R4 IN VARCHAR2,
R5 IN VARCHAR2,R6 IN VARCHAR2,R7 IN VARCHAR2,R8 IN VARCHAR2,R9 IN VARCHAR2,
SB IN VARCHAR2,SC IN VARCHAR2,SD IN VARCHAR2,SF IN VARCHAR2,SG IN NUMBER,
SH IN NUMBER,SJ IN DATE,SK IN VARCHAR2,SL IN NUMBER,SM IN NUMBER,
SN IN DATE,SP IN VARCHAR2,SQ IN NUMBER,SR IN VARCHAR2,SS IN VARCHAR2,
ST IN NUMBER,SV IN NUMBER,SW IN NUMBER,SX IN NUMBER,SZ IN NUMBER,
S0 IN VARCHAR2 )
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
INSERT INTO RCV_PARAMETERS_A
 VALUES(SYSDATE,'I',NUSER,NULL,USERENV('SESSIONID'),NXT,CMT,ROWKEY,E0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
);
execute IMMEDIATE 'alter session set nls_date_format="'||nls_date_fmt||'"';

END RCV_PARAMETERS_AIP;

/
