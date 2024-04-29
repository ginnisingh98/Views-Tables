--------------------------------------------------------
--  DDL for Package Body INV_INVCCIER_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVCCIER_XMLP_PKG" AS
/* $Header: INVCCIERB.pls 120.1 2007/12/25 10:14:20 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  temp_date_format varchar2(20):='DD'||'-MON-'||'YYYY';
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;

      CP_COUNT_DATE_LOW := TO_DATE(P_COUNT_DATE_LOW,temp_date_format);

      CP_COUNT_DATE_HIGH := TO_DATE(P_COUNT_DATE_HIGH,temp_date_format);

      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(010
                   ,'Failed in before report trigger, srwinit. ')*/NULL;
        RAISE;
    END;
    BEGIN
      SELECT
        ORGANIZATION_NAME
      INTO P_ORG_NAME
      FROM
        ORG_ORGANIZATION_DEFINITIONS
      WHERE ORGANIZATION_ID = P_ORG_ID;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(020
                   ,'Failed in before report trigger, item select. ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(030
                   ,'Failed in before report trigger, locator select. ')*/NULL;
        RAISE;
    END;
    IF P_ORG_ID IS NOT NULL THEN
      P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' AND MCCI.ORGANIZATION_ID = ' || TO_CHAR(P_ORG_ID);
    END IF;
    IF P_CYCLE_COUNT_HEADER_ID IS NOT NULL THEN
      P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' AND MCCI.CYCLE_COUNT_HEADER_ID = ' || TO_CHAR(P_CYCLE_COUNT_HEADER_ID);
      BEGIN
        SELECT
          CYCLE_COUNT_HEADER_NAME
        INTO P_CYCLE_COUNT_HEADER_NAME
        FROM
          MTL_CYCLE_COUNT_HEADERS
        WHERE CYCLE_COUNT_HEADER_ID = P_CYCLE_COUNT_HEADER_ID;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    IF P_ACTION_CODE IS NOT NULL THEN
      P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' AND MCCI.ACTION_CODE = ' || TO_CHAR(P_ACTION_CODE);
      BEGIN
        SELECT
          MEANING
        INTO P_ACTION
        FROM
          MFG_LOOKUPS
        WHERE LOOKUP_TYPE = 'MTL_CCEOI_ACTION_CODE'
          AND LOOKUP_CODE = P_ACTION_CODE;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    IF P_REQUEST_ID IS NOT NULL THEN
      P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' AND MCCI.REQUEST_ID = ' || TO_CHAR(P_REQUEST_ID);
    END IF;
    IF P_COUNT_DATE_LOW IS NOT NULL THEN
      P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' AND TO_CHAR(MCCI.COUNT_DATE,''YYYY-MM-DD'' ) >= ''' || TO_CHAR(CP_COUNT_DATE_LOW
                               ,'YYYY-MM-DD') || '''';
    END IF;
    IF P_COUNT_DATE_HIGH IS NOT NULL THEN
      P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' AND TO_CHAR(MCCI.COUNT_DATE,''YYYY-MM-DD'' ) <= ''' || TO_CHAR(CP_COUNT_DATE_HIGH
                               ,'YYYY-MM-DD') || '''';
    END IF;
    BEGIN
      DECLARE
        X_ERROR_CODE NUMBER;
        X_RETURN_STATUS VARCHAR2(1);
        X_MSG_COUNT NUMBER;
        X_MSG_DATA VARCHAR2(240);
      BEGIN
        IF WMS_INSTALL.CHECK_INSTALL(X_RETURN_STATUS
                                 ,X_MSG_COUNT
                                 ,X_MSG_DATA
                                 ,P_ORG_ID) THEN
          P_WMS_INSTALLED := 1;
        ELSE
          P_WMS_INSTALLED := 2;
        END IF;
      END;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

END INV_INVCCIER_XMLP_PKG;


/
