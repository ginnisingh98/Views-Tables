--------------------------------------------------------
--  DDL for Package Body PAY_PAYGBP45_A4_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYGBP45_A4_PKG" as
/* $Header: paygbp45a4.pkb 120.2.12010000.5 2010/02/19 07:11:06 rlingama noship $ */
/*===========================================================================+
|               Copyright (c) 1993 Oracle Corporation                       |
|                  Redwood Shores, California, USA                          |
|                       All rights reserved.                                |
+============================================================================
 Name
    PAY_PAYGBP45_A4_PKG
  Purpose
    To generate P45 A4 XML Data
  Notes

  History
  21-OCT-08    rlingama             115.0 Initial Version
  24-OCT-08    rlingama             115.1 Bug 7261906.Modifed the address lines logic.
  11-Dec-08    rlingama             115.2 Bug 7261906.Modifed the adress line 4 logic when town is null
  22-Jan-09    rlingama             115.3 Bug 7716343.Added space after the town_regin field
  22-Jan-09    rlingama             115.4 Bug 7716343.Restricted the field lengths.
  20-Jul-09    dwkrishn             115.5 Bug 8678216 P45 incorrectly reporting negative tax balance
  03-Dec-09    rlingama             115.6 Bug 9170440 P45 incorrectly reporting negative balance for tax and tax paid
  19-Feb-09    rlingama             115.7 Bug 9393657 Modified the code to ensure, we display visibility of the total pay/tax and
                                          total pay/tax in this employment fields depending on the tax basis.
==============================================================================*/
 FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      L_TEST NUMBER;
      L_ERS_ADDRESS VARCHAR2(60);
    BEGIN
      --HR_STANDARD.EVENT('BEFORE REPORT');
      INSERT INTO FND_SESSIONS
        (SESSION_ID
        ,EFFECTIVE_DATE)
        SELECT
          USERENV('sessionid'),
          TRUNC(SYSDATE)
        FROM
          DUAL
        WHERE not exists (
          SELECT
            1
          FROM
            FND_SESSIONS FS
          WHERE FS.SESSION_ID = USERENV('sessionid') );
      P_SESSION_DATE := SYSDATE;
      P_DATE_TODAY := SYSDATE;
      IF P_ASSIGNMENT_ACTION_ID IS NULL THEN
        P_ACTION_RESTRICTION := 'AND act.payroll_action_id = ' || P_PAYROLL_ACTION_ID;
      ELSE
        P_ACTION_RESTRICTION := 'AND act.assignment_action_id = ' || P_ASSIGNMENT_ACTION_ID;
      END IF;
      SELECT
        SUBSTR(PAY_GB_EOY_ARCHIVE.GET_PARAMETER(P.LEGISLATIVE_PARAMETERS
                                               ,'TAX_REF')
              ,1
              ,3),
        SUBSTR(LTRIM(SUBSTR(PAY_GB_EOY_ARCHIVE.GET_PARAMETER(P.LEGISLATIVE_PARAMETERS
                                                            ,'TAX_REF')
                           ,4
                           ,11)
                    ,'/')
              ,1
              ,10),
        SUBSTR(PAY_GB_EOY_ARCHIVE.GET_ARCH_STR(P.PAYROLL_ACTION_ID
                                              ,'X_EMPLOYERS_ADDRESS_LINE'
                                              ,'0')
              ,1
              ,60),
        SUBSTR(PAY_GB_EOY_ARCHIVE.GET_ARCH_STR(P.PAYROLL_ACTION_ID
                                              ,'X_EMPLOYERS_NAME'
                                              ,'0')
              ,1
              ,40)
      INTO C_TAX_DIST_NO,C_TAX_DIST_REF,L_ERS_ADDRESS,C_ERS_NAME
      FROM
        PAY_PAYROLL_ACTIONS P
      WHERE P.PAYROLL_ACTION_ID = P_PAYROLL_ACTION_ID;
      SPLIT_EMPLOYER_ADDRESS(L_ERS_ADDRESS
                            ,C_ERS_ADDR_LINE1
                            ,C_ERS_ADDR_LINE2
                            ,C_ERS_ADDR_LINE3);
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION C_FORMAT_DATA_FORMULA(TITLE IN VARCHAR2
                                ,ADDRESS_LINE1 IN VARCHAR2
                                ,ADDRESS_LINE2 IN VARCHAR2
                                ,ADDRESS_LINE3 IN VARCHAR2
                                ,TOWN_OR_CITY IN VARCHAR2
                                ,COUNTY IN VARCHAR2
                                ,COUNTRY IN VARCHAR2
                                ,POST_CODE IN VARCHAR2
                                ,TAXABLE_PAY IN NUMBER
                                ,PREVIOUS_TAXABLE_PAY IN NUMBER
                                ,TAX_PAID IN NUMBER
                                ,PREVIOUS_TAX_PAID IN NUMBER
                                ,NI_NUMBER IN VARCHAR2
                                ,TERMINATION_DATE IN DATE
                                ,C_3_PART IN VARCHAR2
                                ,W1_M1_INDICATOR IN VARCHAR2
                                ,SEX VARCHAR2
                                ,DATE_OF_BIRTH DATE) RETURN VARCHAR2 IS
  BEGIN
    C_TITLE := substr(HR_GENERAL.DECODE_LOOKUP('TITLE',TITLE),1,34);

    C_PER_ADDRESS_LINE1 := substr(ADDRESS_LINE1,1,34);
    /*C_PER_ADDRESS_LINE2 := SUBSTR(RTRIM(ADDRESS_LINE2) || RTRIM(', ' || ADDRESS_LINE3
                                       ,', ')
                                 ,1
                                 ,60);
    C_PER_ADDRESS_LINE3 := RTRIM(TOWN_OR_CITY) || ' ' || RTRIM(COUNTY);*/
    /*Assgined the address lines to corresponding address lines.*/
    C_PER_ADDRESS_LINE2 := substr(ADDRESS_LINE2,1,34);
    C_PER_ADDRESS_LINE3 := substr(ADDRESS_LINE3,1,34);
    --C_PER_ADDRESS_LINE4 := COUNTRY || ' ' || POST_CODE;
    --C_PER_ADDRESS_LINE4 := POST_CODE;
    IF upper(COUNTRY) = 'UNITED KINGDOM' then
	C_PER_ADDRESS_LINE4 := RTRIM(TOWN_OR_CITY);
    ELSE
    IF TOWN_OR_CITY is not null then
        C_PER_ADDRESS_LINE4 := RTRIM(TOWN_OR_CITY) || ', ' || RTRIM(COUNTRY);
    ELSE
        C_PER_ADDRESS_LINE4 := RTRIM(COUNTRY);
    END IF;
    END IF;
    C_PER_ADDRESS_LINE4 := substr(C_PER_ADDRESS_LINE4,1,34);

    C_TOTAL_PAY_TD := NVL(TAXABLE_PAY
                         ,0) + NVL(PREVIOUS_TAXABLE_PAY
                         ,0);
    C_TOTAL_TAX_TD := NVL(TAX_PAID
                         ,0) + NVL(PREVIOUS_TAX_PAID
                         ,0);
    C_NI12 := SUBSTR(NI_NUMBER
                    ,1
                    ,2);
    C_NI34 := SUBSTR(NI_NUMBER
                    ,3
                    ,2);
    C_NI56 := SUBSTR(NI_NUMBER
                    ,5
                    ,2);
    C_NI78 := SUBSTR(NI_NUMBER
                    ,7
                    ,2);
    C_NI9 := SUBSTR(NI_NUMBER
                   ,9
                   ,1);
    C_DATE_OF_LEAVING_DD := TO_CHAR(TERMINATION_DATE
                                   ,'DD');
    C_DATE_OF_LEAVING_MM := TO_CHAR(TERMINATION_DATE
                                   ,'MM');
    C_DATE_OF_LEAVING_YYYY := TO_CHAR(TERMINATION_DATE
                                     ,'YYYY');

    IF UPPER(SEX) = 'M' THEN
     C_SEX_M := 'X';
     C_SEX_F := '';
    ELSIF UPPER(SEX) = 'F' THEN
     C_SEX_F := 'X';
     C_SEX_M := '';
    END IF;

    C_DATE_OF_BIRTH_DD := TO_CHAR(DATE_OF_BIRTH
                                   ,'DD');
    C_DATE_OF_BIRTH_MM := TO_CHAR(DATE_OF_BIRTH
                                   ,'MM');
    C_DATE_OF_BIRTH_YYYY := TO_CHAR(DATE_OF_BIRTH
                                     ,'YYYY');

    IF SUBSTR(C_DATE_OF_LEAVING_DD
          ,1
          ,1) = '0' THEN
      C_DATE_OF_LEAVING_DD := ' ' || SUBSTR(C_DATE_OF_LEAVING_DD
                                    ,2
                                    ,2);
    END IF;
    IF SUBSTR(C_DATE_OF_LEAVING_MM
          ,1
          ,1) = '0' THEN
      C_DATE_OF_LEAVING_MM := ' ' || SUBSTR(C_DATE_OF_LEAVING_MM
                                    ,2
                                    ,2);
    END IF;
    IF C_3_PART = 'TRUE' THEN
      IF W1_M1_INDICATOR IS NULL THEN
        /*GET_POUNDS_PENCE(C_TOTAL_PAY_TD
                        ,C_PAY_TD_POUNDS
                        ,C_PAY_TD_PENCE);
        GET_POUNDS_PENCE(C_TOTAL_TAX_TD
                        ,C_TAX_TD_POUNDS
                        ,C_TAX_TD_PENCE);*/

        C_PAY_TD_POUNDS:= C_TOTAL_PAY_TD;
        C_TOTAL_TAX_TD := C_TOTAL_TAX_TD;

	-- Start of Bug 9393657
        C_PAY_IN_EMP_POUNDS := NULL;
        --C_PAY_IN_EMP_PENCE := '';
        C_TAX_IN_EMP_POUNDS := NULL;
       -- C_TAX_IN_EMP_PENCE := '';
       -- End of Bug 9393657
      ELSE
        /*GET_POUNDS_PENCE(TAXABLE_PAY
                        ,C_PAY_IN_EMP_POUNDS
                        ,C_PAY_IN_EMP_PENCE);
        GET_POUNDS_PENCE(TAX_PAID
                        ,C_TAX_IN_EMP_POUNDS
                        ,C_TAX_IN_EMP_PENCE);*/

        C_PAY_IN_EMP_POUNDS := TAXABLE_PAY;
        C_TAX_IN_EMP_POUNDS := TAX_PAID;
        -- Start of Bug 9393657
        C_PAY_TD_POUNDS := NULL;
        --C_PAY_TD_PENCE := '';
        C_TAX_TD_POUNDS := NULL;
        --C_TAX_TD_PENCE := '';
	-- End of Bug 9393657
      END IF;
    ELSIF C_3_PART = 'FALSE' THEN
      IF W1_M1_INDICATOR IS NULL THEN
        /*GET_POUNDS_PENCE(C_TOTAL_PAY_TD
                        ,C_PAY_TD_POUNDS
                        ,C_PAY_TD_PENCE);
        GET_POUNDS_PENCE(C_TOTAL_TAX_TD
                        ,C_TAX_TD_POUNDS
                        ,C_TAX_TD_PENCE);*/

        C_PAY_TD_POUNDS := C_TOTAL_PAY_TD;
        C_TAX_TD_POUNDS := C_TOTAL_TAX_TD;

        IF NVL(PREVIOUS_TAXABLE_PAY
           ,0) = 0 AND NVL(PREVIOUS_TAX_PAID
           ,0) = 0 THEN
          -- End of Bug 9393657
          C_PAY_IN_EMP_POUNDS := NULL;
          --C_PAY_IN_EMP_PENCE := '';
          C_TAX_IN_EMP_POUNDS := NULL;
          --C_TAX_IN_EMP_PENCE := '';
	  -- End of Bug 9393657
        ELSE
/*          GET_POUNDS_PENCE(TAXABLE_PAY
                          ,C_PAY_IN_EMP_POUNDS
                          ,C_PAY_IN_EMP_PENCE);
          GET_POUNDS_PENCE(TAX_PAID
                          ,C_TAX_IN_EMP_POUNDS
                          ,C_TAX_IN_EMP_PENCE);*/
        C_PAY_IN_EMP_POUNDS := TAXABLE_PAY;
        C_TAX_IN_EMP_POUNDS := TAX_PAID;
        END IF;
      ELSE
/*        GET_POUNDS_PENCE(TAXABLE_PAY
                        ,C_PAY_IN_EMP_POUNDS
                        ,C_PAY_IN_EMP_PENCE);
        GET_POUNDS_PENCE(TAX_PAID
                        ,C_TAX_IN_EMP_POUNDS
                        ,C_TAX_IN_EMP_PENCE);*/

        C_PAY_IN_EMP_POUNDS := TAXABLE_PAY;
        C_TAX_IN_EMP_POUNDS := TAX_PAID;
        -- Start of Bug 9393657
        C_PAY_TD_POUNDS := NULL;
        --C_PAY_TD_PENCE := '';
        C_TAX_TD_POUNDS := NULL;
        --C_TAX_TD_PENCE := '';
	-- End of Bug 9393657
      END IF;



    END IF;

    RETURN NULL;
  END C_FORMAT_DATA_FORMULA;

  PROCEDURE GET_POUNDS_PENCE(P_TOTAL IN NUMBER
                            ,P_POUNDS IN OUT NOCOPY NUMBER
                            ,P_PENCE IN OUT NOCOPY NUMBER) IS
  BEGIN
    IF P_TOTAL <> 0 THEN
      P_POUNDS := TRUNC(P_TOTAL);
      P_PENCE := ABS(100 * (P_TOTAL - P_POUNDS));
    ELSE
      P_POUNDS := NULL;
      P_PENCE := NULL;
    END IF;
  END GET_POUNDS_PENCE;

  PROCEDURE SPLIT_EMPLOYER_ADDRESS(P_EMPLOYER_ADDRESS IN VARCHAR2
                                  ,P_EMP_ADDR_LINE_1 IN OUT NOCOPY VARCHAR2
                                  ,P_EMP_ADDR_LINE_2 IN OUT NOCOPY VARCHAR2
                                  ,P_EMP_ADDR_LINE_3 IN OUT NOCOPY VARCHAR2) IS
    LINE_LENGTH CONSTANT NUMBER DEFAULT 34;
    OUT_LINE1 VARCHAR2(34) := NULL;
    OUT_LINE2 VARCHAR2(34) := NULL;
    CURRENT_CHAR VARCHAR2(1);
    IND NUMBER;
    REMAINING_CHARS NUMBER;
    WRAP_POINT NUMBER := 34;
    P_REMAINING_ADDRESS VARCHAR2(600);
  BEGIN
    IF NVL(LENGTH(RTRIM(P_EMPLOYER_ADDRESS))
       ,0) > 34 THEN
      FOR ind IN REVERSE 1 .. LINE_LENGTH LOOP
        CURRENT_CHAR := SUBSTR(P_EMPLOYER_ADDRESS
                              ,IND
                              ,1);
        IF IND = LINE_LENGTH AND CURRENT_CHAR = ',' THEN
          WRAP_POINT := LINE_LENGTH;
          EXIT;
        ELSIF IND = LINE_LENGTH AND CURRENT_CHAR <> ',' THEN
          NULL;
        ELSIF IND < LINE_LENGTH AND CURRENT_CHAR <> ',' THEN
          NULL;
        ELSIF IND < LINE_LENGTH AND CURRENT_CHAR = ',' THEN
          WRAP_POINT := IND;
          EXIT;
        END IF;
      END LOOP;
      IF length(P_EMPLOYER_ADDRESS) - WRAP_POINT > 34 THEN
        REMAINING_CHARS := length(P_EMPLOYER_ADDRESS) - WRAP_POINT;
        P_EMP_ADDR_LINE_1 := SUBSTR(P_EMPLOYER_ADDRESS
                                   ,1
                                   ,WRAP_POINT);
        P_REMAINING_ADDRESS := SUBSTR(P_EMPLOYER_ADDRESS
                                     ,WRAP_POINT + 1
                                     ,REMAINING_CHARS);
        WRAP_POINT := 34;
        FOR ind IN REVERSE 1 .. LINE_LENGTH LOOP
          CURRENT_CHAR := SUBSTR(P_REMAINING_ADDRESS
                                ,IND
                                ,1);
          IF IND = LINE_LENGTH AND CURRENT_CHAR = ',' THEN
            WRAP_POINT := LINE_LENGTH;
            EXIT;
          ELSIF IND = LINE_LENGTH AND CURRENT_CHAR <> ',' THEN
            NULL;
          ELSIF IND < LINE_LENGTH AND CURRENT_CHAR <> ',' THEN
            NULL;
          ELSIF IND < LINE_LENGTH AND CURRENT_CHAR = ',' THEN
            WRAP_POINT := IND;
            EXIT;
          END IF;
        END LOOP;
        REMAINING_CHARS := length(P_REMAINING_ADDRESS) - WRAP_POINT;
        P_EMP_ADDR_LINE_2 := LTRIM(SUBSTR(P_REMAINING_ADDRESS
                                         ,1
                                         ,WRAP_POINT));
        P_EMP_ADDR_LINE_3 := LTRIM(SUBSTR(P_REMAINING_ADDRESS
                                         ,WRAP_POINT + 1
                                         ,34));
      ELSE
        REMAINING_CHARS := length(P_EMPLOYER_ADDRESS) - WRAP_POINT;
        P_EMP_ADDR_LINE_1 := SUBSTR(P_EMPLOYER_ADDRESS
                                   ,1
                                   ,WRAP_POINT);
        P_EMP_ADDR_LINE_2 := LTRIM(SUBSTR(P_EMPLOYER_ADDRESS
                                         ,WRAP_POINT + 1
                                         ,34));
      END IF;
    ELSE
      P_EMP_ADDR_LINE_1 := P_EMPLOYER_ADDRESS;
      P_EMP_ADDR_LINE_2 := NULL;
    END IF;
  END SPLIT_EMPLOYER_ADDRESS;

  FUNCTION C_3_PARTFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_3_PART NUMBER(1);
    BEGIN
      SELECT
        1
      INTO L_3_PART
      FROM
        FF_GLOBALS_F
      WHERE GLOBAL_NAME = 'P45_REPORT_TYPE'
        AND SUBSTR(GLOBAL_VALUE
            ,1
            ,1) = '3'
        AND sysdate between EFFECTIVE_START_DATE
        AND EFFECTIVE_END_DATE;
      RETURN ('TRUE');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('FALSE');
    END;
    RETURN NULL;
  END C_3_PARTFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    --HR_STANDARD.EVENT('AFTER REPORT');
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TITLE;
  END C_TITLE_P;

  FUNCTION C_NI12_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NI12;
  END C_NI12_P;

  FUNCTION C_NI34_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NI34;
  END C_NI34_P;

  FUNCTION C_NI56_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NI56;
  END C_NI56_P;

  FUNCTION C_NI78_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NI78;
  END C_NI78_P;

  FUNCTION C_NI9_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NI9;
  END C_NI9_P;

  FUNCTION C_DATE_OF_LEAVING_DD_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DATE_OF_LEAVING_DD;
  END C_DATE_OF_LEAVING_DD_P;

  FUNCTION C_DATE_OF_LEAVING_MM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DATE_OF_LEAVING_MM;
  END C_DATE_OF_LEAVING_MM_P;

  FUNCTION C_DATE_OF_LEAVING_YYYY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DATE_OF_LEAVING_YYYY;
  END C_DATE_OF_LEAVING_YYYY_P;

  FUNCTION C_DATE_OF_BIRTH_DD_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DATE_OF_BIRTH_DD;
  END C_DATE_OF_BIRTH_DD_P;

  FUNCTION C_DATE_OF_BIRTH_MM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DATE_OF_BIRTH_MM;
  END C_DATE_OF_BIRTH_MM_P;

  FUNCTION C_DATE_OF_BIRTH_YYYY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DATE_OF_BIRTH_YYYY;
  END C_DATE_OF_BIRTH_YYYY_P;

  FUNCTION C_SEX_M_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_SEX_M;
  END C_SEX_M_P;

  FUNCTION C_SEX_F_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_SEX_F;
  END C_SEX_F_P;

  FUNCTION C_TOTAL_TAX_TD_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_TAX_TD;
  END C_TOTAL_TAX_TD_P;

  FUNCTION C_TOTAL_PAY_TD_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_PAY_TD;
  END C_TOTAL_PAY_TD_P;

  FUNCTION C_PER_ADDRESS_LINE1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PER_ADDRESS_LINE1;
  END C_PER_ADDRESS_LINE1_P;

  FUNCTION C_PER_ADDRESS_LINE2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PER_ADDRESS_LINE2;
  END C_PER_ADDRESS_LINE2_P;

  FUNCTION C_PER_ADDRESS_LINE3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PER_ADDRESS_LINE3;
  END C_PER_ADDRESS_LINE3_P;

  FUNCTION C_PER_ADDRESS_LINE4_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PER_ADDRESS_LINE4;
  END C_PER_ADDRESS_LINE4_P;

  FUNCTION C_PAY_IN_EMP_POUNDS_P RETURN NUMBER IS
  BEGIN
  if C_PAY_IN_EMP_POUNDS <= 0  then -- Bug 9170440
     C_PAY_IN_EMP_POUNDS := NULL; --Bug 9393657
   end if;
    RETURN C_PAY_IN_EMP_POUNDS;
  END C_PAY_IN_EMP_POUNDS_P;

  FUNCTION C_PAY_IN_EMP_PENCE_P RETURN NUMBER IS
  BEGIN
    RETURN C_PAY_IN_EMP_PENCE;
  END C_PAY_IN_EMP_PENCE_P;

  FUNCTION C_TAX_IN_EMP_POUNDS_P RETURN NUMBER IS
  BEGIN
   if C_TAX_IN_EMP_POUNDS <= 0  then -- Bug 8678216
     C_TAX_IN_EMP_POUNDS := NULL; --Bug 9393657
   end if;
    RETURN C_TAX_IN_EMP_POUNDS;
  END C_TAX_IN_EMP_POUNDS_P;

  FUNCTION C_TAX_IN_EMP_PENCE_P RETURN NUMBER IS
  BEGIN
    RETURN C_TAX_IN_EMP_PENCE;
  END C_TAX_IN_EMP_PENCE_P;

  FUNCTION C_PAY_TD_POUNDS_P RETURN NUMBER IS
  BEGIN
  if C_PAY_TD_POUNDS <= 0  then -- Bug 9170440
     C_PAY_TD_POUNDS := NULL; --Bug 9393657
   end if;
    RETURN C_PAY_TD_POUNDS;
  END C_PAY_TD_POUNDS_P;

  FUNCTION C_PAY_TD_PENCE_P RETURN NUMBER IS
  BEGIN
    RETURN C_PAY_TD_PENCE;
  END C_PAY_TD_PENCE_P;

  FUNCTION C_TAX_TD_POUNDS_P RETURN NUMBER IS
  BEGIN
  if C_TAX_TD_POUNDS <= 0  then -- Bug 9170440
     C_TAX_TD_POUNDS := NULL; --Bug 9393657
  end if;
    RETURN C_TAX_TD_POUNDS;
  END C_TAX_TD_POUNDS_P;

  FUNCTION C_TAX_TD_PENCE_P RETURN NUMBER IS
  BEGIN
    RETURN C_TAX_TD_PENCE;
  END C_TAX_TD_PENCE_P;

  FUNCTION C_BUSINESS_GROUP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BUSINESS_GROUP_NAME;
  END C_BUSINESS_GROUP_NAME_P;

  FUNCTION C_REPORT_SUBTITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_REPORT_SUBTITLE;
  END C_REPORT_SUBTITLE_P;

  FUNCTION C_FORMULA_ID_P RETURN NUMBER IS
  BEGIN
    RETURN C_FORMULA_ID;
  END C_FORMULA_ID_P;

  FUNCTION C_MESSAGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_MESSAGE;
  END C_MESSAGE_P;

  FUNCTION C_ERS_ADDR_LINE1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ERS_ADDR_LINE1;
  END C_ERS_ADDR_LINE1_P;

  FUNCTION C_ERS_ADDR_LINE2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ERS_ADDR_LINE2;
  END C_ERS_ADDR_LINE2_P;

  FUNCTION C_ERS_ADDR_LINE3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ERS_ADDR_LINE3;
  END C_ERS_ADDR_LINE3_P;

  FUNCTION C_ERS_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ERS_NAME;
  END C_ERS_NAME_P;

  FUNCTION C_TAX_DIST_NO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TAX_DIST_NO;
  END C_TAX_DIST_NO_P;

  FUNCTION C_TAX_DIST_REF_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TAX_DIST_REF;
  END C_TAX_DIST_REF_P;

END PAY_PAYGBP45_A4_PKG;

/
