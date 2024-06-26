--------------------------------------------------------
--  DDL for Package Body WSH_WSHRDVLS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_WSHRDVLS_XMLP_PKG" AS
/* $Header: WSHRDVLSB.pls 120.3 2008/01/04 10:58:23 npannamp noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed FND SRWINIT.')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION C_COMPANY_NAME RETURN VARCHAR2 IS
    COMPANY_NAME VARCHAR2(50);
  BEGIN
    SELECT
      NAME
    INTO COMPANY_NAME
    FROM
      GL_LEDGERS_PUBLIC_V
    WHERE LEDGER_ID = P_SOB_ID;
    RETURN (COMPANY_NAME);
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN (NULL);
  END C_COMPANY_NAME;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in SRWEXIT')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF P_TRIP_ID IS NOT NULL THEN
      LP_TRIP := ' and trp.trip_id =  :P_trip_id ';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION CF_CONSOL_DELIVERY_NAMEFORMULA(PARENT_DELIVERY_LEG_ID IN NUMBER) RETURN CHAR IS
    CURSOR CUR_GET_CONSOL_DELIVERY_NAME(P_PARENT_DELIVERY_LEG_ID IN NUMBER) IS
      SELECT
        WND.NAME
      FROM
        WSH_NEW_DELIVERIES WND,
        WSH_DELIVERY_LEGS WDL
      WHERE WND.DELIVERY_ID = WDL.DELIVERY_ID
        AND WDL.DELIVERY_LEG_ID = P_PARENT_DELIVERY_LEG_ID;
    L_CONSOL_DELIVERY_NAME VARCHAR2(30) := NULL;
  BEGIN
    IF PARENT_DELIVERY_LEG_ID IS NOT NULL THEN
      OPEN CUR_GET_CONSOL_DELIVERY_NAME(PARENT_DELIVERY_LEG_ID);
      FETCH CUR_GET_CONSOL_DELIVERY_NAME
       INTO L_CONSOL_DELIVERY_NAME;
      CLOSE CUR_GET_CONSOL_DELIVERY_NAME;
    END IF;
    RETURN (L_CONSOL_DELIVERY_NAME);
  EXCEPTION
    WHEN OTHERS THEN
      IF CUR_GET_CONSOL_DELIVERY_NAME%ISOPEN THEN
        CLOSE CUR_GET_CONSOL_DELIVERY_NAME;
      END IF;
      /*SRW.MESSAGE(1
                 ,'Failed in formula column CF_consol_delivery_name !')*/NULL;
      RAISE;
  END CF_CONSOL_DELIVERY_NAMEFORMULA;

  FUNCTION RP_SUB_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SUB_TITLE;
  END RP_SUB_TITLE_P;

END WSH_WSHRDVLS_XMLP_PKG;


/
