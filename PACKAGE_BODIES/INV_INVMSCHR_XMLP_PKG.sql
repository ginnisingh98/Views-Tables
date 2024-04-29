--------------------------------------------------------
--  DDL for Package Body INV_INVMSCHR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVMSCHR_XMLP_PKG" AS
/* $Header: INVMSCHRB.pls 120.3 2008/01/11 10:32:04 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;

    IF P_LOC_LOW IS NOT NULL OR P_LOC_HI IS NOT NULL
      THEN
       P_XML_WHERE := '1=1';
      ELSE
       P_XML_WHERE := '1=2';
     END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Before Report: Init')*/NULL;
    END;
    DECLARE
      L_REPORT_NAME VARCHAR2(240);
    BEGIN
      SELECT
        CP.USER_CONCURRENT_PROGRAM_NAME
      INTO L_REPORT_NAME
      FROM
        FND_CONCURRENT_PROGRAMS_VL CP,
        FND_CONCURRENT_REQUESTS CR
      WHERE CR.REQUEST_ID = P_CONC_REQUEST_ID
        AND CP.APPLICATION_ID = CR.PROGRAM_APPLICATION_ID
        AND CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID;
      RP_REPORT_NAME := L_REPORT_NAME;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RP_REPORT_NAME := 'Material Status Change History Report';
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(2
                   ,'Failed in before report trigger:MSTK')*/NULL;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(5
                   ,'Failed flexsql loc select in before report trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      IF P_LOC_LOW IS NOT NULL OR P_LOC_HI IS NOT NULL THEN
        BEGIN
          NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(15
                       ,'Failed flexsql loc where in before report trigger')*/NULL;
            RAISE;
        END;
        BEGIN
          NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(16
                       ,'Failed flexsql loc order by in before report trigger. ')*/NULL;
            RAISE;
        END;
      ELSE
        P_LOC_WHERE := ' 1=2 ';
      END IF;


    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in AFTER REPORT TRIGGER')*/NULL;
        RETURN (FALSE);
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF (P_DATE_FROM IS NOT NULL) AND (P_DATE_TO IS NOT NULL) THEN
        L_DATE_RANGE := ' and mmsh.creation_date between :p_date_from and :p_date_to ';
      ELSIF (P_DATE_FROM IS NULL) AND (P_DATE_TO IS NOT NULL) THEN
        L_DATE_RANGE := ' and mmsh.creation_date <= :p_date_to ';
      ELSIF (P_DATE_FROM IS NOT NULL) AND (P_DATE_TO IS NULL) THEN
        L_DATE_RANGE := ' and mmsh.creation_date >= :p_date_from ';
      ELSE
        L_DATE_RANGE := ' ';
      END IF;
    END;
    if L_DATE_RANGE is null then L_DATE_RANGE:= ' '; end if;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;

END INV_INVMSCHR_XMLP_PKG;



/
