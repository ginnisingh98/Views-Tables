--------------------------------------------------------
--  DDL for Package Body PAY_PAYIECHL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYIECHL_XMLP_PKG" AS
/* $Header: PAYIECHLB.pls 120.1 2008/01/07 15:56:53 srikrish noship $ */
  FUNCTION REPORT_DATEFORMULA RETURN DATE IS
  BEGIN
    RETURN SYSDATE;
  END REPORT_DATEFORMULA;

  FUNCTION EMPLOYEE_NAMEFORMULA(LAST_NAME IN VARCHAR2
                               ,FIRST_NAME IN VARCHAR2
                               ,MIDDLE_NAMES IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN LAST_NAME || ', ' || FIRST_NAME || ' ' || INITIALS(MIDDLE_NAMES);
  END EMPLOYEE_NAMEFORMULA;

  FUNCTION INITIALS(NAME IN VARCHAR2) RETURN VARCHAR2 IS
    L_INITIALS VARCHAR2(255);
    L_POS NUMBER;
    L_NAME VARCHAR2(255);
  BEGIN
    L_NAME := RTRIM(LTRIM(NAME));
    IF NVL(LENGTH(L_NAME)
       ,0) > 0 THEN
      L_INITIALS := SUBSTR(L_NAME
                          ,1
                          ,1) || '.';
    END IF;
    L_POS := INSTR(L_NAME
                  ,' '
                  ,1
                  ,1);
    WHILE L_POS <> 0 LOOP

      L_INITIALS := L_INITIALS || SUBSTR(L_NAME
                          ,L_POS + 1
                          ,1) || '.';
      L_POS := INSTR(L_NAME
                    ,' '
                    ,L_POS + 1
                    ,1);
    END LOOP;
    RETURN L_INITIALS;
  END INITIALS;

  FUNCTION PAYEEFORMULA(PERSONAL_PAYMENT_METHOD_ID IN NUMBER
                       ,DATE_EARNED IN DATE
                       ,LAST_NAME IN VARCHAR2
                       ,FIRST_NAME IN VARCHAR2
                       ,MIDDLE_NAMES IN VARCHAR2) RETURN VARCHAR2 IS
    CURSOR PAYMENT_METHOD IS
      SELECT
        PAYEE_ID,
        PAYEE_TYPE
      FROM
        PAY_PERSONAL_PAYMENT_METHODS_F
      WHERE PERSONAL_PAYMENT_METHOD_ID = PERSONAL_PAYMENT_METHOD_ID
        AND DATE_EARNED between EFFECTIVE_START_DATE
        AND EFFECTIVE_END_DATE;
    CURSOR PERSON(P_PERSON_ID IN NUMBER) IS
      SELECT
        FIRST_NAME,
        MIDDLE_NAMES,
        LAST_NAME
      FROM
        PER_ALL_PEOPLE_F
      WHERE PERSON_ID = P_PERSON_ID
        AND DATE_EARNED between EFFECTIVE_START_DATE
        AND EFFECTIVE_END_DATE;
    CURSOR ORGANIZATION(P_ORGANIZATION_ID IN NUMBER) IS
      SELECT
        NAME
      FROM
        HR_ALL_ORGANIZATION_UNITS
      WHERE ORGANIZATION_ID = P_ORGANIZATION_ID;
    L_PAYEE_ID NUMBER;
    L_PAYEE_TYPE VARCHAR2(30);
    L_FIRST_NAME VARCHAR2(20);
    L_MIDDLE_NAMES VARCHAR2(60);
    L_LAST_NAME VARCHAR2(40);
    L_NAME VARCHAR2(60);
  BEGIN
    IF PERSONAL_PAYMENT_METHOD_ID IS NULL THEN
      RETURN LAST_NAME || ', ' || FIRST_NAME || ' ' || INITIALS(MIDDLE_NAMES);
    ELSE
      OPEN PAYMENT_METHOD;
      FETCH PAYMENT_METHOD
       INTO L_PAYEE_ID,L_PAYEE_TYPE;
      CLOSE PAYMENT_METHOD;
      IF L_PAYEE_ID IS NULL THEN
        RETURN LAST_NAME || ', ' || FIRST_NAME || ' ' || INITIALS(MIDDLE_NAMES);
      ELSE
        IF L_PAYEE_TYPE = 'P' THEN
          OPEN PERSON(L_PAYEE_ID);
          FETCH PERSON
           INTO L_FIRST_NAME,L_MIDDLE_NAMES,L_LAST_NAME;
          CLOSE PERSON;
          RETURN L_LAST_NAME || ', ' || L_FIRST_NAME || ' ' || INITIALS(L_MIDDLE_NAMES);
        END IF;
        IF L_PAYEE_TYPE = 'O' THEN
          OPEN ORGANIZATION(L_PAYEE_ID);
          FETCH ORGANIZATION
           INTO L_NAME;
          CLOSE ORGANIZATION;
          RETURN L_NAME;
        END IF;
      END IF;
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN LAST_NAME || ', ' || FIRST_NAME || ' ' || INITIALS(MIDDLE_NAMES);
  END PAYEEFORMULA;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    IF P_SORT_ORDER_T IS NULL THEN
      P_SORT_ORDER_T := '1';
    END IF;
    P_SORT_ORDER_T := 'order by ' || P_SORT_ORDER_T;
    IF P_SORT_ORDER_T = 'order by 1' THEN
      P_SORT_ORDER_T := 'order by upper(ppf.payroll_name), 6, 1';
    END IF;
    IF P_SORT_ORDER_T = 'order by 2' THEN
      P_SORT_ORDER_T := 'order by upper(ppf.payroll_name), 6, upper(per.last_name), upper(per.first_name), upper(per.middle_names), lpad(upper(per.employee_number), 30, ''0''), lpad(upper(paf.assignment_number), 30, ''0'')';
    END IF;
    IF P_SORT_ORDER_T = 'order by 3' THEN
      P_SORT_ORDER_T := 'order by upper(ppf.payroll_name), 6, lpad(upper(per.employee_number), 30, ''0''), lpad(upper(paf.assignment_number), 30, ''0'')';
    END IF;
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  temp boolean;
  BEGIN
  P_SORT_ORDER_T := P_SORT_ORDER;
  temp := BEFOREPFORM();
    --HR_STANDARD.EVENT('BEFORE REPORT');
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    --HR_STANDARD.EVENT('AFTER REPORT');
    RETURN (TRUE);
  END AFTERREPORT;

END PAY_PAYIECHL_XMLP_PKG;

/
