--------------------------------------------------------
--  DDL for Procedure PO_SYSTEM_PARAMETERS_ALL_AIP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."PO_SYSTEM_PARAMETERS_ALL_AIP" (A0 IN DATE,A1 IN NUMBER,JB IN NUMBER,JC IN VARCHAR2,JD IN VARCHAR2,JF IN VARCHAR2,JG IN VARCHAR2,
JH IN NUMBER,JJ IN VARCHAR2,JK IN DATE,JL IN NUMBER,JM IN VARCHAR2,
JN IN VARCHAR2,JP IN VARCHAR2,JQ IN VARCHAR2,JR IN VARCHAR2,JS IN VARCHAR2,
JT IN VARCHAR2,JV IN VARCHAR2,JW IN VARCHAR2,JX IN VARCHAR2,JZ IN VARCHAR2,
J0 IN VARCHAR2,J1 IN VARCHAR2,J2 IN VARCHAR2,J3 IN VARCHAR2,J4 IN VARCHAR2,
J5 IN VARCHAR2,J6 IN VARCHAR2,J7 IN VARCHAR2,J8 IN VARCHAR2,J9 IN VARCHAR2,
KB IN VARCHAR2,KC IN VARCHAR2,KD IN VARCHAR2,KF IN VARCHAR2,KG IN VARCHAR2,
KH IN VARCHAR2,KJ IN VARCHAR2,KK IN VARCHAR2,KL IN VARCHAR2,KM IN VARCHAR2,
KN IN VARCHAR2,KP IN VARCHAR2,KQ IN VARCHAR2,KR IN NUMBER,KS IN NUMBER,
KT IN NUMBER,KV IN NUMBER,KW IN VARCHAR2,KX IN VARCHAR2,KZ IN VARCHAR2,
K0 IN VARCHAR2,K1 IN VARCHAR2,K2 IN NUMBER,K3 IN NUMBER,K4 IN VARCHAR2,
K5 IN NUMBER,K6 IN VARCHAR2,K7 IN NUMBER,K8 IN NUMBER,K9 IN VARCHAR2,
LB IN NUMBER,LC IN VARCHAR2,LD IN VARCHAR2,LF IN NUMBER,LG IN NUMBER,
LH IN VARCHAR2,LJ IN NUMBER,LK IN NUMBER,LL IN DATE,LM IN VARCHAR2,
LN IN NUMBER,LP IN VARCHAR2,LQ IN VARCHAR2,LR IN NUMBER,LS IN VARCHAR2,
LT IN VARCHAR2,LV IN NUMBER,LW IN VARCHAR2,LX IN NUMBER,LZ IN NUMBER,
L0 IN VARCHAR2,L1 IN VARCHAR2,L2 IN VARCHAR2,L3 IN VARCHAR2,L4 IN VARCHAR2,
L5 IN VARCHAR2,L6 IN NUMBER,L7 IN NUMBER,L8 IN NUMBER,L9 IN NUMBER,
MB IN NUMBER,MC IN NUMBER,MD IN VARCHAR2,MF IN VARCHAR2,MG IN VARCHAR2,
MH IN VARCHAR2,MJ IN VARCHAR2,E0 IN DATE,E1 IN NUMBER,RB IN NUMBER,RC IN VARCHAR2,RD IN VARCHAR2,RF IN VARCHAR2,RG IN VARCHAR2,
RH IN NUMBER,RJ IN VARCHAR2,RK IN DATE,RL IN NUMBER,RM IN VARCHAR2,
RN IN VARCHAR2,RP IN VARCHAR2,RQ IN VARCHAR2,RR IN VARCHAR2,RS IN VARCHAR2,
RT IN VARCHAR2,RV IN VARCHAR2,RW IN VARCHAR2,RX IN VARCHAR2,RZ IN VARCHAR2,
R0 IN VARCHAR2,R1 IN VARCHAR2,R2 IN VARCHAR2,R3 IN VARCHAR2,R4 IN VARCHAR2,
R5 IN VARCHAR2,R6 IN VARCHAR2,R7 IN VARCHAR2,R8 IN VARCHAR2,R9 IN VARCHAR2,
SB IN VARCHAR2,SC IN VARCHAR2,SD IN VARCHAR2,SF IN VARCHAR2,SG IN VARCHAR2,
SH IN VARCHAR2,SJ IN VARCHAR2,SK IN VARCHAR2,SL IN VARCHAR2,SM IN VARCHAR2,
SN IN VARCHAR2,SP IN VARCHAR2,SQ IN VARCHAR2,SR IN NUMBER,SS IN NUMBER,
ST IN NUMBER,SV IN NUMBER,SW IN VARCHAR2,SX IN VARCHAR2,SZ IN VARCHAR2,
S0 IN VARCHAR2,S1 IN VARCHAR2,S2 IN NUMBER,S3 IN NUMBER,S4 IN VARCHAR2,
S5 IN NUMBER,S6 IN VARCHAR2,S7 IN NUMBER,S8 IN NUMBER,S9 IN VARCHAR2,
TB IN NUMBER,TC IN VARCHAR2,TD IN VARCHAR2,TF IN NUMBER,TG IN NUMBER,
TH IN VARCHAR2,TJ IN NUMBER,TK IN NUMBER,TL IN DATE,TM IN VARCHAR2,
TN IN NUMBER,TP IN VARCHAR2,TQ IN VARCHAR2,TR IN NUMBER,TS IN VARCHAR2,
TT IN VARCHAR2,TV IN NUMBER,TW IN VARCHAR2,TX IN NUMBER,TZ IN NUMBER,
T0 IN VARCHAR2,T1 IN VARCHAR2,T2 IN VARCHAR2,T3 IN VARCHAR2,T4 IN VARCHAR2,
T5 IN VARCHAR2,T6 IN NUMBER,T7 IN NUMBER,T8 IN NUMBER,T9 IN NUMBER,
VB IN NUMBER,VC IN NUMBER,VD IN VARCHAR2,VF IN VARCHAR2,VG IN VARCHAR2,
VH IN VARCHAR2,VJ IN VARCHAR2 )
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
INSERT INTO PO_SYSTEM_PARAMETERS_ALL_A
 VALUES(SYSDATE,'I',NUSER,NULL,USERENV('SESSIONID'),NXT,CMT,ROWKEY,E0,E1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
,NULL,NULL,NULL,NULL,NULL,NULL);
execute IMMEDIATE 'alter session set nls_date_format="'||nls_date_fmt||'"';

END PO_SYSTEM_PARAMETERS_ALL_AIP;

/