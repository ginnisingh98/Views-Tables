--------------------------------------------------------
--  DDL for Package Body JL_JLBRPCCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_JLBRPCCR_XMLP_PKG" AS
/* $Header: JLBRPCCRB.pls 120.1 2007/12/25 16:38:13 dwkrishn noship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN OTHERS THEN
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN IS
    L_CHART_OF_ACCOUNTS_ID NUMBER;
    L_NAME VARCHAR2(30);
    L_SOB_ID NUMBER;
    L_ORG_ID NUMBER;
  BEGIN
    SELECT
      SET_OF_BOOKS_ID,
      ORG_ID
    INTO L_SOB_ID,L_ORG_ID
    FROM
      AP_SYSTEM_PARAMETERS;
    P_SOB_ID := L_SOB_ID;
    P_SET_OF_BOOKS_ID := L_SOB_ID;
    SELECT
      SUBSTR(NAME
            ,1
            ,30),
      CHART_OF_ACCOUNTS_ID
    INTO L_NAME,L_CHART_OF_ACCOUNTS_ID
    FROM
      GL_SETS_OF_BOOKS
    WHERE SET_OF_BOOKS_ID = L_SOB_ID;
    C_COMPANY_NAME_HEADER := L_NAME;
    C_CHART_OF_ACCOUNTS_ID := L_CHART_OF_ACCOUNTS_ID;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COMPANY_NAME;
  FUNCTION SET_P_WHERE RETURN BOOLEAN IS
    L_NLS_YES VARCHAR2(4);
    L_TYPE_OF_REPORT VARCHAR2(40);
  BEGIN
    IF (C_USER_ID IS NOT NULL) THEN
      C_CREATED_BY_PREDICATE := 'and cons.created_by = ' || C_USER_ID;
      else
      C_created_by_predicate :='and 1=1';
    END IF;
    RETURN (TRUE);
  END SET_P_WHERE;
  FUNCTION GET_NLS_STRINGS RETURN BOOLEAN IS
    NLS_ALL AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_NO_DATA VARCHAR2(2008);
    NLS_END VARCHAR2(2008);
    NLS_YES FND_LOOKUPS.MEANING%TYPE;
    NLS_NO FND_LOOKUPS.MEANING%TYPE;
  BEGIN
    NLS_ALL := '';
    NLS_NO_DATA := '';
    NLS_YES := '';
    NLS_NO := '';
    SELECT
      LY.MEANING,
      LN.MEANING,
      LA.DISPLAYED_FIELD
    INTO NLS_YES,NLS_NO,NLS_ALL
    FROM
      FND_LOOKUPS LY,
      FND_LOOKUPS LN,
      AP_LOOKUP_CODES LA
    WHERE LY.LOOKUP_TYPE = 'YES_NO'
      AND LY.LOOKUP_CODE = 'Y'
      AND LN.LOOKUP_TYPE = 'YES_NO'
      AND LN.LOOKUP_CODE = 'N'
      AND LA.LOOKUP_TYPE = 'NLS REPORT PARAMETER'
      AND LA.LOOKUP_CODE = 'ALL';
    C_NLS_YES := NLS_YES;
    C_NLS_NO := NLS_NO;
    C_NLS_ALL := NLS_ALL;
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_APPRVL_NO_DATA');
    NLS_NO_DATA :=  FND_MESSAGE.GET ;
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_ALL_END_OF_REPORT');
    NLS_END := FND_MESSAGE.GET ;
    C_NLS_NO_DATA_EXISTS := NLS_NO_DATA;
    C_NLS_END_OF_REPORT := NLS_END;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_NLS_STRINGS;
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF (P_START_DATE IS NOT NULL) THEN
      LP_START_DATE_PREDICATE := ' and cons.invoice_date >= :P_start_date ';
    END IF;
    IF (P_END_DATE IS NOT NULL) THEN
      LP_END_DATE_PREDICATE := ' and cons.invoice_date <=  :P_end_date ';
    END IF;
P_START_DATE1 := to_char(P_START_DATE,'DD-MON-YY');
P_END_DATE1 := to_char(P_END_DATE,'DD-MON-YY');
    RETURN (TRUE);
  END AFTERPFORM;
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    INIT_FAILURE EXCEPTION;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    IF (GET_COMPANY_NAME <> TRUE) THEN
      RAISE INIT_FAILURE;
    END IF;
    IF (GET_NLS_STRINGS <> TRUE) THEN
      RAISE INIT_FAILURE;
    END IF;
    IF (SET_P_WHERE <> TRUE) THEN
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END IF;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
      RETURN (FALSE);
  END BEFOREREPORT;
  FUNCTION C_CHART_OF_ACCOUNTS_ID_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_CHART_OF_ACCOUNTS_ID;
  END C_CHART_OF_ACCOUNTS_ID_P;
  FUNCTION C_START_DATE_PREDICATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_START_DATE_PREDICATE;
  END C_START_DATE_PREDICATE_P;
  FUNCTION C_END_DATE_PREDICATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_END_DATE_PREDICATE;
  END C_END_DATE_PREDICATE_P;
  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMPANY_NAME_HEADER;
  END C_COMPANY_NAME_HEADER_P;
  FUNCTION C_USER_ID_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_USER_ID;
  END C_USER_ID_P;
  FUNCTION C_CREATED_BY_PREDICATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_CREATED_BY_PREDICATE;
  END C_CREATED_BY_PREDICATE_P;
  FUNCTION C_NLS_END_OF_REPORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_END_OF_REPORT;
  END C_NLS_END_OF_REPORT_P;
  FUNCTION C_NLS_NO_DATA_EXISTS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NO_DATA_EXISTS;
  END C_NLS_NO_DATA_EXISTS_P;
  FUNCTION C_NLS_YES_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_YES;
  END C_NLS_YES_P;
  FUNCTION C_NLS_NO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NO;
  END C_NLS_NO_P;
  FUNCTION C_NLS_ALL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_ALL;
  END C_NLS_ALL_P;
  FUNCTION C_NLA_NA_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLA_NA;
  END C_NLA_NA_P;
  FUNCTION P_FLEX_DATA_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_FLEX_DATA;
  END P_FLEX_DATA_P;
END JL_JLBRPCCR_XMLP_PKG;




/