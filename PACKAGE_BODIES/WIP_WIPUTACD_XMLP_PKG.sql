--------------------------------------------------------
--  DDL for Package Body WIP_WIPUTACD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIPUTACD_XMLP_PKG" AS
/* $Header: WIPUTACDB.pls 120.2 2008/01/31 13:14:10 npannamp noship $ */
  FUNCTION LIMIT_DATES RETURN CHARACTER IS
    LIMIT_DATES VARCHAR2(150);
  BEGIN
    IF (P_FROM_DATE IS NOT NULL) THEN
      IF (P_TO_DATE IS NOT NULL) THEN
        LIMIT_DATES := ' AND WT.transaction_date >= TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')' || ' AND WT.transaction_date < TO_DATE(''' || TO_CHAR(P_TO_DATE + 1
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      ELSE
        LIMIT_DATES := ' AND WT.transaction_date >= TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      END IF;
    ELSE
      IF (P_TO_DATE IS NOT NULL) THEN
        LIMIT_DATES := ' AND WT.transaction_date < TO_DATE(''' || TO_CHAR(P_TO_DATE + 1
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      ELSE
        LIMIT_DATES := ' ';
      END IF;
    END IF;
    RETURN (LIMIT_DATES);
  END LIMIT_DATES;
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      L_STMT_NUM VARCHAR2(10);
DATE_FORMAT varchar2(20):='DD'||'-MON-'||'YY';
    BEGIN
    qty_precision:=wip_common_xmlp_pkg.get_precision(P_qty_precision);
      P_EXCHANGE_RATE := FND_NUMBER.CANONICAL_TO_NUMBER(P_EXCHANGE_RATE_CHAR);
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      /*SRW.USER_EXIT('
                      FND FLEXSQL
                      CODE="GL#"
                      NUM=":P_STRUCT_NUM"
                      APPL_SHORT_NAME="SQLGL"
                      OUTPUT=":P_FLEXDATA"
                      TABLEALIAS="L"
                      MODE="SELECT"
                      DISPLAY="ALL"
                    ')*/NULL;
      L_STMT_NUM := '1';
      L_STMT_NUM := '2';
      L_STMT_NUM := '3';
      L_STMT_NUM := '4';
      IF (P_PROJECT_ID IS NOT NULL) THEN
        P_PROJECT_WHERE := 'WDJ.PROJECT_ID = ' || P_PROJECT_ID;
        P_PROJ_WHERE := 'WT.PROJECT_ID = ' || P_PROJECT_ID;
      END IF;
P_FROM_DATE_DISP:=to_char(P_FROM_DATE,DATE_FORMAT);
      P_TO_DATE_DISP:=to_char(P_TO_DATE,DATE_FORMAT);
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(999
                   ,L_STMT_NUM)*/NULL;
        /*SRW.MESSAGE(999
                   ,'FND FLEXSQL(MCAT) >X')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION CLASS(R_CLASS IN VARCHAR2
                ,D_CLASS IN VARCHAR2) RETURN CHARACTER IS
    CLASS VARCHAR2(10);
  BEGIN
    IF (R_CLASS IS NULL) THEN
      CLASS := D_CLASS;
    ELSE
      CLASS := R_CLASS;
    END IF;
    RETURN (CLASS);
  END CLASS;
  FUNCTION LIMIT_CLASSES RETURN CHARACTER IS
    LIMIT_CLASSES VARCHAR2(80);
    CL_TYPE NUMBER(10);
  BEGIN
    IF (P_CLASS_CODE IS NOT NULL) THEN
      BEGIN
        SELECT
          DISTINCT
          CLASS_TYPE
        INTO CL_TYPE
        FROM
          WIP_ACCOUNTING_CLASSES
        WHERE CLASS_CODE = P_CLASS_CODE
          AND ORGANIZATION_ID = P_ORGANIZATION_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          /*SRW.MESSAGE(30
                     ,'No Rows Found for the Class Specified')*/NULL;
          RAISE;
      END;
      IF CL_TYPE = 2 THEN
        LIMIT_CLASSES := ' AND WRI.CLASS_CODE = ''' || P_CLASS_CODE || '''';
      ELSE
        LIMIT_CLASSES := ' AND WDJ.CLASS_CODE = ''' || P_CLASS_CODE || '''';
      END IF;
    ELSE
      LIMIT_CLASSES := ' ';
    END IF;
    RETURN (LIMIT_CLASSES);
  END LIMIT_CLASSES;
  FUNCTION C_SUBTITLE_CURRENCYFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN ('(' || P_CURRENCY_CODE || ')');
  END C_SUBTITLE_CURRENCYFORMULA;
  FUNCTION C_ACCT_DESCRIPFORMULA(C_FLEXDATA IN VARCHAR2
                                ,ACCOUNT IN VARCHAR2
                                ,C_ACCT_DESCRIP IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(C_FLEXDATA)*/NULL;
      /*SRW.REFERENCE(ACCOUNT)*/NULL;
      RETURN (C_ACCT_DESCRIP);
    END;
    RETURN NULL;
  END C_ACCT_DESCRIPFORMULA;
  FUNCTION C_FLEX_SORTFORMULA(C_FLEXDATA IN VARCHAR2
                             ,ACCOUNT IN VARCHAR2
                             ,C_FLEX_SORT IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(C_FLEXDATA)*/NULL;
      /*SRW.REFERENCE(ACCOUNT)*/NULL;
      RETURN (C_FLEX_SORT);
    END;
    RETURN NULL;
  END C_FLEX_SORTFORMULA;
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF P_JOB IS NOT NULL THEN
      P_LIMIT_ENTITY := 'and WT.wip_entity_id = :P_Job';
    END IF;
    IF P_ACCOUNT IS NOT NULL THEN
      P_LIMIT_ACCOUNT := 'and WA.reference_account = :P_Account';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;
END WIP_WIPUTACD_XMLP_PKG;


/
