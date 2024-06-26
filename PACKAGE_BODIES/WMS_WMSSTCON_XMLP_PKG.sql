--------------------------------------------------------
--  DDL for Package Body WMS_WMSSTCON_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_WMSSTCON_XMLP_PKG" AS
/* $Header: WMSSTCONB.pls 120.3 2007/12/25 08:01:01 nchinnam noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(10
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
      RP_REPORT_NAME := substr(RP_REPORT_NAME,1,instr(RP_REPORT_NAME,' (XML)'));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RP_REPORT_NAME := 'Consolidation Report';
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(20
                   ,'Failed in before report trigger:MSTK')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(30
                   ,'Failed flexsql loc select in before report trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(200
                   ,'Failed in before report trigger:MSTK/order')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(300
                   ,'Failed in before report trigger:MTLL/order')*/NULL;
        RAISE;
    END;
    BEGIN
      P_WHERE_CLAUSE := ' 1 = 1 ';
      IF P_TRIP_ID IS NOT NULL THEN
        P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' and wt.trip_id = ' || P_TRIP_ID;
      END IF;
      IF P_DELIVERY_ID IS NOT NULL THEN
        P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' and wnd.delivery_id = ' || P_DELIVERY_ID;
      END IF;
      IF P_SALES_ORDER_HEADER_ID IS NOT NULL THEN
        P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' and oeh.header_id = ' || P_SALES_ORDER_HEADER_ID;
      END IF;
      IF P_CUSTOMER_ID IS NOT NULL THEN
        P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' and oeh.sold_to_org_id = ' || P_CUSTOMER_ID;
      END IF;
      IF P_ORDER_TYPE_ID IS NOT NULL THEN
        P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' and oeh.order_type_id = ' || P_ORDER_TYPE_ID;
      END IF;
    END;
    BEGIN
      IF P_ORG_ID IS NOT NULL THEN
        SELECT
          ORGANIZATION_CODE,
          ORGANIZATION_NAME
        INTO P_ORG_CODE,P_ORG_NAME
        FROM
          ORG_ORGANIZATION_DEFINITIONS
        WHERE ORGANIZATION_ID = P_ORG_ID;
      END IF;
      IF P_TRIP_ID IS NOT NULL THEN
        SELECT
          NAME
        INTO P_TRIP_NAME
        FROM
          WSH_TRIPS
        WHERE TRIP_ID = P_TRIP_ID;
      END IF;
      IF P_DELIVERY_ID IS NOT NULL THEN
        SELECT
          NAME
        INTO P_DELIVERY_NAME
        FROM
          WSH_NEW_DELIVERIES
        WHERE DELIVERY_ID = P_DELIVERY_ID;
      END IF;
      IF P_CUSTOMER_ID IS NOT NULL THEN
        SELECT
          PARTY.PARTY_NAME,
          PARTY.PARTY_NUMBER
        INTO P_CUSTOMER_NAME,P_CUSTOMER_NUMBER
        FROM
          HZ_PARTIES PARTY,
          HZ_CUST_ACCOUNTS CUST_ACCT
        WHERE CUST_ACCT.CUST_ACCOUNT_ID = P_CUSTOMER_ID
          AND CUST_ACCT.PARTY_ID = PARTY.PARTY_ID;
      END IF;
      IF P_SALES_ORDER_HEADER_ID IS NOT NULL THEN
        SELECT
          ORDER_NUMBER
        INTO P_SALES_ORDER
        FROM
          OE_ORDER_HEADERS_ALL
        WHERE HEADER_ID = P_SALES_ORDER_HEADER_ID;
        IF P_CUSTOMER_ID IS NULL THEN
          SELECT
            PARTY.PARTY_NAME,
            PARTY.PARTY_NUMBER
          INTO P_CUSTOMER_NAME,P_CUSTOMER_NUMBER
          FROM
            HZ_PARTIES PARTY,
            HZ_CUST_ACCOUNTS CUST_ACCT,
            OE_ORDER_HEADERS_ALL OEH
          WHERE CUST_ACCT.CUST_ACCOUNT_ID = OEH.SOLD_TO_ORG_ID
            AND CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
            AND OEH.HEADER_ID = P_SALES_ORDER_HEADER_ID;
        END IF;
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
        /*SRW.MESSAGE(99
                   ,'Failed in AFTER REPORT TRIGGER')*/NULL;
        RETURN (FALSE);
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION INMULTIPLESOFORMULA(LPN_ID IN NUMBER) RETURN CHAR IS
    MCOUNT NUMBER := 1;
  BEGIN
    IF (P_MULTIPLE_ASSOCIATION_CHECK = 1) THEN
      SELECT
        count(SOURCE_HEADER_ID)
      INTO MCOUNT
      FROM
        WSH_DELIVERY_DETAILS
      WHERE DELIVERY_DETAIL_ID in (
        SELECT
          WDA.DELIVERY_DETAIL_ID
        FROM
          WSH_DELIVERY_DETAILS WDD,
          WSH_DELIVERY_ASSIGNMENTS WDA
        WHERE WDD.ORGANIZATION_ID = P_ORG_ID
          AND WDD.LPN_ID = INMULTIPLESOFORMULA.LPN_ID
          AND WDD.DELIVERY_DETAIL_ID = WDA.PARENT_DELIVERY_DETAIL_ID )
        AND SOURCE_CODE = 'OE';
    END IF;
    IF MCOUNT > 1 THEN
      RETURN P_MULTIPLE_YES;
    ELSE
      RETURN P_MULTIPLE_NO;
    END IF;
  END INMULTIPLESOFORMULA;

  FUNCTION INMULTIPLEDELIVERYFORMULA(LPN_ID IN NUMBER) RETURN CHAR IS
    MCOUNT NUMBER := 1;
  BEGIN
    IF (P_MULTIPLE_ASSOCIATION_CHECK = 1) THEN
      SELECT
        count(WDA.DELIVERY_ID)
      INTO MCOUNT
      FROM
        WSH_DELIVERY_DETAILS WDD,
        WSH_DELIVERY_ASSIGNMENTS WDA
      WHERE WDD.ORGANIZATION_ID = P_ORG_ID
        AND WDD.LPN_ID = INMULTIPLEDELIVERYFORMULA.LPN_ID
        AND WDD.DELIVERY_DETAIL_ID = WDA.PARENT_DELIVERY_DETAIL_ID;
    END IF;
    IF MCOUNT > 1 THEN
      RETURN P_MULTIPLE_YES;
    ELSE
      RETURN P_MULTIPLE_NO;
    END IF;
  END INMULTIPLEDELIVERYFORMULA;

  FUNCTION INMULTIPLETRIPFORMULA(LPN_ID IN NUMBER) RETURN CHAR IS
    MCOUNT NUMBER := 1;
  BEGIN
    IF (P_MULTIPLE_ASSOCIATION_CHECK = 1) THEN
      SELECT
        count(WTS.TRIP_ID)
      INTO MCOUNT
      FROM
        WSH_DELIVERY_LEGS WDL,
        WSH_TRIP_STOPS WTS
      WHERE WDL.PICK_UP_STOP_ID = WTS.STOP_ID
        AND WDL.DELIVERY_ID in (
        SELECT
          WDA.DELIVERY_ID
        FROM
          WSH_DELIVERY_DETAILS WDD,
          WSH_DELIVERY_ASSIGNMENTS WDA
        WHERE WDD.ORGANIZATION_ID = P_ORG_ID
          AND WDD.LPN_ID = INMULTIPLETRIPFORMULA.LPN_ID
          AND WDD.DELIVERY_DETAIL_ID = WDA.PARENT_DELIVERY_DETAIL_ID );
    END IF;
    IF MCOUNT > 1 THEN
      RETURN P_MULTIPLE_YES;
    ELSE
      RETURN P_MULTIPLE_NO;
    END IF;
  END INMULTIPLETRIPFORMULA;

  FUNCTION P_TRIP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_TRIP_NAME;
  END P_TRIP_NAME_P;

  FUNCTION P_DELIVERY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_DELIVERY_NAME;
  END P_DELIVERY_NAME_P;

  FUNCTION P_SALES_ORDER_P RETURN NUMBER IS
  BEGIN
    RETURN P_SALES_ORDER;
  END P_SALES_ORDER_P;

  FUNCTION P_CUSTOMER_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_CUSTOMER_NAME;
  END P_CUSTOMER_NAME_P;

  FUNCTION P_ORG_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_ORG_CODE;
  END P_ORG_CODE_P;

  FUNCTION P_ORG_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_ORG_NAME;
  END P_ORG_NAME_P;

  FUNCTION P_CUSTOMER_NUMBER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN P_CUSTOMER_NUMBER;
  END P_CUSTOMER_NUMBER_P;

END WMS_WMSSTCON_XMLP_PKG;


/
