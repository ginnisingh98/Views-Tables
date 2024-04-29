--------------------------------------------------------
--  DDL for Package Body JA_JAINSTCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_JAINSTCR_XMLP_PKG" AS
/* $Header: JAINSTCRB.pls 120.1 2007/12/25 16:30:14 dwkrishn noship $ */
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF P_ORGANIZATION_ID IS NOT NULL THEN
      P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' and  dtl.organization_id =  :p_organization_id';
    END IF;
    IF P_LOCATION_ID IS NOT NULL THEN
      P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' and  dtl.location_id = :p_location_id';
    END IF;
    IF P_PARTY_ID IS NOT NULL THEN
      P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' and  hdr.party_id =  :p_party_id';
    END IF;
    IF P_PARTY_SITE_ID IS NOT NULL THEN
      P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' and  hdr.party_site_id = :p_party_site_id';
    END IF;
    IF P_MATCH_TYPE = 'P' THEN
      P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' and dtl.tax_target_amount > dtl.matched_amount and dtl.matched_amount > 0 ';
    ELSIF P_MATCH_TYPE = 'U' THEN
      P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' and dtl.matched_amount is null ';
    ELSIF P_MATCH_TYPE = 'F' THEN
      P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' and dtl.tax_target_amount = dtl.matched_amount ';
    ELSIF P_MATCH_TYPE = 'M' THEN
      P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' and dtl.matched_amount > 0 ';
    END IF;
    /*SRW.MESSAGE(1275
               ,'Where Clause Built is ' || P_WHERE_CLAUSE)*/NULL;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION CF_INVOICE_AMOUNTFORMULA(INVOICE_ID1 IN NUMBER) RETURN NUMBER IS
    CURSOR C_INV_AMOUNT(CP_ACCT_CLASS IN RA_CUST_TRX_LINE_GL_DIST_ALL.ACCOUNT_CLASS%TYPE) IS
      SELECT
        AMOUNT
      FROM
        RA_CUST_TRX_LINE_GL_DIST_ALL
      WHERE CUSTOMER_TRX_ID = INVOICE_ID1
        AND ACCOUNT_CLASS = CP_ACCT_CLASS - 'REC'
        AND LATEST_REC_FLAG = 'Y';
    V_INVOICE_AMOUNT NUMBER;
  BEGIN
    OPEN C_INV_AMOUNT('REC');
    FETCH C_INV_AMOUNT
     INTO V_INVOICE_AMOUNT;
    CLOSE C_INV_AMOUNT;
    RETURN (V_INVOICE_AMOUNT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (0);
  END CF_INVOICE_AMOUNTFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    CURSOR C_PROGRAM_ID(P_REQUEST_ID IN NUMBER) IS
      SELECT
        CONCURRENT_PROGRAM_ID,
        NVL(ENABLE_TRACE
           ,'N')
      FROM
        FND_CONCURRENT_REQUESTS
      WHERE REQUEST_ID = P_REQUEST_ID;
    CURSOR GET_AUDSID IS
      SELECT
        A.SID,
        A.SERIAL#,
        B.SPID
      FROM
        V$SESSION A,
        V$PROCESS B
      WHERE AUDSID = USERENV('SESSIONID')
        AND A.PADDR = B.ADDR;
    CURSOR GET_DBNAME IS
      SELECT
        NAME
      FROM
        V$DATABASE;
    V_ENABLE_TRACE FND_CONCURRENT_PROGRAMS.ENABLE_TRACE%TYPE;
    V_PROGRAM_ID FND_CONCURRENT_PROGRAMS.CONCURRENT_PROGRAM_ID%TYPE;
    V_AUDSID NUMBER := USERENV('SESSIONID');
    V_SID NUMBER;
    V_SERIAL NUMBER;
    V_SPID VARCHAR2(9);
    V_DBNAME VARCHAR2(25);
  BEGIN
    /*SRW.MESSAGE(1275
               ,'Report Version is 120.3 Last modified date is 20/07/2006')*/NULL;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      CP_MATCH_TYPE := LTRIM(RTRIM(P_MATCH_TYPE));
      CP_FROM_DATE := TO_CHAR(P_FROM_DATE,'DD-MON-YY');
      CP_TO_DATE := TO_CHAR(P_TO_DATE,'DD-MON-YY');

      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      OPEN C_PROGRAM_ID(P_CONC_REQUEST_ID);
      FETCH C_PROGRAM_ID
       INTO V_PROGRAM_ID,V_ENABLE_TRACE;
      CLOSE C_PROGRAM_ID;
      /*SRW.MESSAGE(1275
                 ,'v_program_id -> ' || V_PROGRAM_ID || ', v_enable_trace -> ' || V_ENABLE_TRACE || ', request_id -> ' || P_CONC_REQUEST_ID)*/NULL;
      IF V_ENABLE_TRACE = 'Y' THEN
        OPEN GET_AUDSID;
        FETCH GET_AUDSID
         INTO V_SID,V_SERIAL,V_SPID;
        CLOSE GET_AUDSID;
        OPEN GET_DBNAME;
        FETCH GET_DBNAME
         INTO V_DBNAME;
        CLOSE GET_DBNAME;
        /*SRW.MESSAGE(1275
                   ,'TraceFile Name = ' || LOWER(V_DBNAME) || '_ora_' || V_SPID || '.trc')*/NULL;
        EXECUTE IMMEDIATE
          'ALTER SESSION SET EVENTS ''10046 trace name context forever, level 4''';
      END IF;
      RETURN (TRUE);
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(1275
                   ,'Error during enabling the trace. ErrCode -> ' || SQLCODE || ', ErrMesg -> ' || SQLERRM)*/NULL;
    END;
  END BEFOREREPORT;

  FUNCTION CF_ORDER_DATEFORMULA(HEADER_ID IN NUMBER
                               ,ORDER_FLAG1 IN VARCHAR2) RETURN CHAR IS
    CURSOR C_ORDER_DATE IS
      SELECT
        ORDERED_DATE
      FROM
        OE_ORDER_HEADERS_ALL
      WHERE HEADER_ID = CF_ORDER_DATEFORMULA.HEADER_ID;
    V_ORDER_DATE DATE;
  BEGIN
    IF ORDER_FLAG1 = 'O' THEN
      OPEN C_ORDER_DATE;
      FETCH C_ORDER_DATE
       INTO V_ORDER_DATE;
      CLOSE C_ORDER_DATE;
      RETURN (TO_CHAR(V_ORDER_DATE));
    ELSE
      RETURN ('N/A');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END CF_ORDER_DATEFORMULA;

  FUNCTION CF_FORM_NUMBERFORMULA(FORM_ID IN NUMBER) RETURN CHAR IS
    CURSOR C_FORM_NUMBER IS
      SELECT
        FORM_NUMBER
      FROM
        JAI_CMN_ST_FORMS
      WHERE FORM_ID = CF_FORM_NUMBERFORMULA.FORM_ID;
    V_FORM_NUMBER JAI_CMN_ST_FORMS.FORM_NUMBER%TYPE;
  BEGIN
    OPEN C_FORM_NUMBER;
    FETCH C_FORM_NUMBER
     INTO V_FORM_NUMBER;
    CLOSE C_FORM_NUMBER;
    RETURN (V_FORM_NUMBER);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END CF_FORM_NUMBERFORMULA;

  FUNCTION CF_FORM_DATEFORMULA(FORM_ID IN NUMBER) RETURN DATE IS
    CURSOR C_FORM_DATE IS
      SELECT
        FORM_DATE
      FROM
        JAI_CMN_ST_FORMS
      WHERE FORM_ID = CF_FORM_DATEFORMULA.FORM_ID;
    V_FORM_DATE JAI_CMN_ST_FORMS.FORM_DATE%TYPE;
  BEGIN
    OPEN C_FORM_DATE;
    FETCH C_FORM_DATE
     INTO V_FORM_DATE;
    CLOSE C_FORM_DATE;
    RETURN (V_FORM_DATE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END CF_FORM_DATEFORMULA;

  FUNCTION DISPLAY_YES_NO RETURN BOOLEAN IS
    V_MATCH_TYPE VARCHAR2(20);
  BEGIN
    V_MATCH_TYPE := LTRIM(RTRIM(P_MATCH_TYPE));
    IF V_MATCH_TYPE = 'F' OR V_MATCH_TYPE = 'P' OR V_MATCH_TYPE = 'M' THEN
      RETURN (TRUE);
    ELSE
      RETURN (FALSE);
    END IF;
  END DISPLAY_YES_NO;

  FUNCTION G_ORGN_INFOGROUPFILTER RETURN BOOLEAN IS
  BEGIN
    P_REC_EXISTS := P_REC_EXISTS + 1;
    RETURN (TRUE);
  END G_ORGN_INFOGROUPFILTER;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

END JA_JAINSTCR_XMLP_PKG;



/