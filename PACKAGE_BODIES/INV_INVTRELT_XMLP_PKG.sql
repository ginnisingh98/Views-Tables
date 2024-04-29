--------------------------------------------------------
--  DDL for Package Body INV_INVTRELT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVTRELT_XMLP_PKG" AS
/* $Header: INVTRELTB.pls 120.1 2007/12/25 11:07:59 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed srwinit in before rpt trigger')*/NULL;
        RAISE;
    END;
    DECLARE
      P_ORG_ID_CHAR VARCHAR2(100) := (P_ORG);
    BEGIN
      /*SRW.USER_EXIT('FND PUTPROFILE NAME="' || 'MFG_ORGANIZATION_ID' || '" FIELD="' || P_ORG_ID_CHAR || '"')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(020
                   ,'Failed in before report trigger, setting org profile ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(2
                   ,'Failed Flexsql Loc Select in before rpt trig')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(3
                   ,'Failed Flexsql Item Where in before rpt trig')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(4
                   ,'Failed Flexsql Item Select in before rpt trig')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(6
                   ,'Failed flexsql item order by in before rpt trigger ')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    P_EXPIRE_DATE_1:= TO_CHAR(TO_DATE(P_EXPIRE_DATE
                                    ,'YYYY/MM/DD HH24:MI:SS')
                            ,'DD-MON-RRRR HH24:MI:SS');
    RETURN (TRUE);
  END AFTERPFORM;
END INV_INVTRELT_XMLP_PKG;


/
