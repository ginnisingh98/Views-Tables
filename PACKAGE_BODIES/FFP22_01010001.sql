--------------------------------------------------------
--  DDL for Package Body FFP22_01010001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FFP22_01010001" AS
/*
Code generated by Oracle FastFormula - do not edit. Formula Name:
PTO_ROLLING_CARRYOVER
*/
PROCEDURE FORMULA (
V0 IN OUT NUMBER,
I1 IN OUT NUMBER,
V2 IN OUT DATE,
I3 IN OUT NUMBER,
V8 IN OUT VARCHAR2,
I9 IN OUT NUMBER,
V4 IN OUT DATE,
I5 IN OUT NUMBER,
V6 IN OUT DATE,
I7 IN OUT NUMBER,
FFERLN IN OUT NUMBER,
FFERCD IN OUT NUMBER,
FFERMT IN OUT VARCHAR2) IS
/* PTO_ROLLING_CARRYOVER*/
LEMT VARCHAR2(255);
L_ERCD NUMBER(15,0);
L_ NUMBER(15,0);
BEGIN
DECLARE
EX1  EXCEPTION;
NULL_FOUND  EXCEPTION;
BEGIN
L_ERCD:=0;
LEMT:='OB';
L_:=12;
V0:=0;
I1:=-1;

L_:=13;
IF I5=0 THEN
V4:=V4;
LEMT:='CALCULATION_DATE';
RAISE EX1;
END IF;
V2:=V4;
I3:=-1;

L_:=14;
V6:=V4;
I7:=-1;

L_:=15;
V8:='NO';
I9:=-1;

L_:=17;
I1:=1;
I3:=2;
I7:=3;
I9:=4;
GOTO FFX;
<<FFX>>
NULL;
EXCEPTION
WHEN EX1 THEN L_ERCD := 1;
WHEN ZERO_DIVIDE THEN L_ERCD := 2;
WHEN NO_DATA_FOUND THEN L_ERCD := 3;
WHEN TOO_MANY_ROWS THEN L_ERCD:=4;
WHEN VALUE_ERROR THEN L_ERCD:=5;
WHEN INVALID_NUMBER THEN L_ERCD:=6;
WHEN NULL_FOUND THEN L_ERCD:=7;
WHEN HR_UTILITY.HR_ERROR THEN
BEGIN
  LEMT:=SUBSTRB(HR_UTILITY.GET_MESSAGE,1,255);
  L_ERCD:=8;
END;
WHEN OTHERS THEN
IF SQLCODE = 1 THEN L_ERCD:=-6510;
ELSE L_ERCD:=SQLCODE; END IF;
LEMT:=LEMT||' '||SQLERRM;
END;
FFERLN:=L_; FFERCD:=L_ERCD; FFERMT:=LEMT;
END FORMULA;
END 
FFP22_01010001
;

/
