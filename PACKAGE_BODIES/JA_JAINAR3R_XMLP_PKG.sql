--------------------------------------------------------
--  DDL for Package Body JA_JAINAR3R_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_JAINAR3R_XMLP_PKG" AS
/* $Header: JAINAR3RB.pls 120.1 2007/12/25 16:11:41 dwkrishn noship $ */
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF P_STATUS IS NOT NULL THEN
      IF P_STATUS = 'RECEIVED' THEN
        P_W_CLAUSE := 'AND received_date IS NOT NULL';
      ELSIF P_STATUS = 'NOT RECEIVED' THEN
        P_W_CLAUSE := 'AND received_date IS NULL';
      ELSE
        P_W_CLAUSE := 'AND 1 = 1';
      END IF;
    END IF;
    IF (P_W_CLAUSE IS NULL) THEN
		P_W_CLAUSE := 'AND 1 = 1';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION CF_1FORMULA(L_TRX_NUMBER IN NUMBER
                      ,TRX_TYPE IN VARCHAR2) RETURN VARCHAR2 IS
    V_TRX_NUMBER VARCHAR2(20);
    CURSOR GET_TRX_NUMBER IS
      SELECT
        TRX_NUMBER
      FROM
        RA_CUSTOMER_TRX_ALL
      WHERE CUSTOMER_TRX_ID = L_TRX_NUMBER;
    CURSOR C_GET_ORDER_NUMBER(P_ORDER_NUMBER IN NUMBER) IS
      SELECT
        TO_CHAR(ORDER_NUMBER)
      FROM
        OE_ORDER_HEADERS_ALL
      WHERE HEADER_ID = P_ORDER_NUMBER;
  BEGIN
    IF TRX_TYPE = 'ORDER' THEN
      OPEN C_GET_ORDER_NUMBER(L_TRX_NUMBER);
      FETCH C_GET_ORDER_NUMBER
       INTO V_TRX_NUMBER;
      CLOSE C_GET_ORDER_NUMBER;
    ELSIF TRX_TYPE = 'INVOICE' THEN
      OPEN GET_TRX_NUMBER;
      FETCH GET_TRX_NUMBER
       INTO V_TRX_NUMBER;
      CLOSE GET_TRX_NUMBER;
    END IF;
    RETURN (V_TRX_NUMBER);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'No TrxNumber';
  END CF_1FORMULA;

  FUNCTION CF_1FORMULA0031(CUSTOMER_SITE_ID IN NUMBER) RETURN VARCHAR2 IS
    V_LOCATION VARCHAR2(80);
  BEGIN
    SELECT
      LOCATION
    INTO V_LOCATION
    FROM
      HZ_CUST_SITE_USES_ALL
    WHERE SITE_USE_ID = NVL(CUSTOMER_SITE_ID
       ,0);
    RETURN (V_LOCATION);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN (NULL);
  END CF_1FORMULA0031;

  FUNCTION DELIVERY_NAMEFORMULA(DELIVERY_DETAIL_ID IN NUMBER) RETURN VARCHAR2 IS
    V_DELIVERY_NAME VARCHAR2(50);
    CURSOR C_DELIVERY_NAME(P_DELIVERY_DETAIL_ID IN NUMBER) IS
      SELECT
        A.NAME
      FROM
        WSH_NEW_DELIVERIES A,
        WSH_DELIVERY_ASSIGNMENTS B
      WHERE A.DELIVERY_ID = B.DELIVERY_ID
        AND B.DELIVERY_DETAIL_ID = P_DELIVERY_DETAIL_ID;
  BEGIN
    OPEN C_DELIVERY_NAME(DELIVERY_DETAIL_ID);
    FETCH C_DELIVERY_NAME
     INTO V_DELIVERY_NAME;
    CLOSE C_DELIVERY_NAME;
    RETURN (V_DELIVERY_NAME);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'No Delivery';
  END DELIVERY_NAMEFORMULA;

  FUNCTION CF_DELIVERY_IDFORMULA(DELIVERY_DETAIL_ID IN NUMBER) RETURN NUMBER IS
    CURSOR C_DELIVERY_NAME(P_DELIVERY_DETAIL_ID IN NUMBER) IS
      SELECT
        DELIVERY_ID
      FROM
        WSH_DELIVERY_ASSIGNMENTS B
      WHERE B.DELIVERY_DETAIL_ID = P_DELIVERY_DETAIL_ID;
    V_DELIVERY_ID NUMBER;
  BEGIN
    IF DELIVERY_DETAIL_ID IS NULL THEN
      RETURN NULL;
    ELSE
      OPEN C_DELIVERY_NAME(DELIVERY_DETAIL_ID);
      FETCH C_DELIVERY_NAME
       INTO V_DELIVERY_ID;
      CLOSE C_DELIVERY_NAME;
      RETURN V_DELIVERY_ID;
    END IF;
  END CF_DELIVERY_IDFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    CURSOR C_PROGRAM_ID(P_REQUEST_ID IN NUMBER) IS
      SELECT
        CONCURRENT_PROGRAM_ID,
        NVL(ENABLE_TRACE
           ,'N')
      FROM
        FND_CONCURRENT_REQUESTS
      WHERE REQUEST_ID = P_REQUEST_ID;
    V_ENABLE_TRACE FND_CONCURRENT_PROGRAMS.ENABLE_TRACE%TYPE;
    V_PROGRAM_ID FND_CONCURRENT_PROGRAMS.CONCURRENT_PROGRAM_ID%TYPE;
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.MESSAGE(1275
               ,'Report Version is 120.2 Last modified date is 25/07/2005')*/NULL;
    BEGIN
      OPEN C_PROGRAM_ID(P_CONC_REQUEST_ID);
      FETCH C_PROGRAM_ID
       INTO V_PROGRAM_ID,V_ENABLE_TRACE;
      CLOSE C_PROGRAM_ID;
      /*SRW.MESSAGE(1275
                 ,'v_program_id -> ' || V_PROGRAM_ID || ', v_enable_trace -> ' || V_ENABLE_TRACE || ', request_id -> ' || P_CONC_REQUEST_ID)*/NULL;
      IF V_ENABLE_TRACE = 'Y' THEN
        EXECUTE IMMEDIATE
          'ALTER SESSION SET EVENTS ''10046 trace name context forever, level 4''';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(1275
                   ,'Error during enabling the trace. ErrCode -> ' || SQLCODE || ', ErrMesg -> ' || SQLERRM)*/NULL;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

END JA_JAINAR3R_XMLP_PKG;



/
