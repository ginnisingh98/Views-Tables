--------------------------------------------------------
--  DDL for Package Body INV_INVARUIR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVARUIR_XMLP_PKG" AS
/* $Header: INVARUIRB.pls 120.2 2008/01/08 06:42:19 dwkrishn noship $ */
  FUNCTION C_FORMATTEDCURRENCYCODEFORMULA(CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      TEMP_C VARCHAR2(20);
    BEGIN
      TEMP_C := '(' || CURRENCY_CODE || ')';
      RETURN (TEMP_C);
    END;
    RETURN NULL;
  END C_FORMATTEDCURRENCYCODEFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Before Report: Init')*/NULL;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Before Report: ItemFlex')*/NULL;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Order By trigger')*/NULL;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
      RETURN (TRUE);
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_CURRENTDATEFORMULA RETURN DATE IS
  BEGIN
    BEGIN
      RETURN (SYSDATE);
    END;
    RETURN NULL;
  END C_CURRENTDATEFORMULA;

  FUNCTION F_SCHEDINTERVALFORMULA(C_SCHEDINTERVAL IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      LOCAL_VAR VARCHAR2(80);
    BEGIN
      /*SRW.REFERENCE(C_SCHEDINTERVAL)*/NULL;
      IF C_SCHEDINTERVAL = -1 THEN
        LOCAL_VAR := '';
      ELSE
        SELECT
          MFG.MEANING
        INTO LOCAL_VAR
        FROM
          MFG_LOOKUPS MFG
        WHERE MFG.LOOKUP_TYPE = 'MTL_CC_SCHED_TIME'
          AND MFG.LOOKUP_CODE = C_SCHEDINTERVAL;
      END IF;
      RETURN (LOCAL_VAR);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN ('');
    END;
    RETURN NULL;
  END F_SCHEDINTERVALFORMULA;

  FUNCTION F_NWORKDAYSYEARFORMULA(S_CALENDARCODE IN VARCHAR2
                                 ,S_CALENDAREXCEPTION IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    DECLARE
      YEARBEGINDATE DATE;
      YEARENDDATE DATE;
      NWORKDAYS INTEGER;
    BEGIN
      SELECT
        TO_CHAR(MAX(BY1.YEAR_START_DATE)
               ,'DD-MON-RRRR'),
        TO_CHAR(MIN(BY2.YEAR_START_DATE) - 1
               ,'DD-MON-RRRR')
      INTO YEARBEGINDATE,YEARENDDATE
      FROM
        BOM_CAL_YEAR_START_DATES BY1,
        BOM_CAL_YEAR_START_DATES BY2
      WHERE BY1.CALENDAR_CODE = S_CALENDARCODE
        AND BY1.EXCEPTION_SET_ID = S_CALENDAREXCEPTION
        AND BY2.CALENDAR_CODE = BY1.CALENDAR_CODE
        AND BY2.EXCEPTION_SET_ID = BY1.EXCEPTION_SET_ID
        AND BY1.YEAR_START_DATE <= TRUNC(SYSDATE)
        AND BY2.YEAR_START_DATE > TRUNC(SYSDATE);
      SELECT
        BC1.NEXT_SEQ_NUM - BC2.NEXT_SEQ_NUM + 1
      INTO NWORKDAYS
      FROM
        BOM_CALENDAR_DATES BC1,
        BOM_CALENDAR_DATES BC2
      WHERE TO_CHAR(BC2.CALENDAR_DATE
             ,'DD-MON-RRRR') = YEARBEGINDATE
        AND TO_CHAR(BC1.CALENDAR_DATE
             ,'DD-MON-RRRR') = YEARENDDATE
        AND BC1.CALENDAR_CODE = S_CALENDARCODE
        AND BC1.EXCEPTION_SET_ID = S_CALENDAREXCEPTION
        AND BC2.CALENDAR_CODE = S_CALENDARCODE
        AND BC2.EXCEPTION_SET_ID = S_CALENDAREXCEPTION;
      RETURN (NWORKDAYS);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (1);
    END;
    RETURN NULL;
  END F_NWORKDAYSYEARFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

END INV_INVARUIR_XMLP_PKG;


/
