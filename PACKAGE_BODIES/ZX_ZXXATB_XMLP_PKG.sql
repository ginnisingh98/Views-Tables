--------------------------------------------------------
--  DDL for Package Body ZX_ZXXATB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_ZXXATB_XMLP_PKG" AS
/* $Header: ZXXATBB.pls 120.1.12010000.1 2008/07/28 13:27:57 appldev ship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF (P_REPORTING_LEVEL = '1000') THEN
        SELECT
          B.NAME,
          B.LEDGER_ID
        INTO RP_COMPANY_NAME,P_SOB_ID
        FROM
          GL_LEDGERS B
        WHERE LEDGER_ID = P_REPORTING_CONTEXT;
      ELSIF (P_REPORTING_LEVEL = '2000') THEN
        SELECT
          LEDGER_NAME,
          LEDGER_ID
        INTO RP_COMPANY_NAME,P_SOB_ID
        FROM
          GL_LEDGER_LE_V
        WHERE LEGAL_ENTITY_ID = P_REPORTING_CONTEXT;
      ELSE
        SELECT
          B.NAME,
          B.LEDGER_ID
        INTO RP_COMPANY_NAME,P_SOB_ID
        FROM
          HR_OPERATING_UNITS A,
          GL_LEDGERS B
        WHERE A.ORGANIZATION_ID = P_REPORTING_CONTEXT
          AND A.SET_OF_BOOKS_ID = B.LEDGER_ID;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION REPORT_NAMEFORMULA(FUNCTIONAL_CURRENCY IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_REPORT_NAME VARCHAR2(80);
      L_START_TRX_DATE VARCHAR2(11);
      L_END_TRX_DATE VARCHAR2(11);
    BEGIN
      IF P_START_TRX_DATE IS NULL THEN
        L_START_TRX_DATE := '   ';
      ELSE
        L_START_TRX_DATE := TO_CHAR(P_START_TRX_DATE
                                   ,'DD-MON-YYYY');
      END IF;
      IF P_END_TRX_DATE IS NULL THEN
        L_END_TRX_DATE := '   ';
      ELSE
        L_END_TRX_DATE := TO_CHAR(P_END_TRX_DATE
                                 ,'DD-MON-YYYY');
      END IF;
      RP_TRX_DATE := ARP_STANDARD.FND_MESSAGE('AR_REPORTS_INV_DATE_FROM_TO'
                                             ,'FROM_DATE'
                                             ,L_START_TRX_DATE
                                             ,'TO_DATE'
                                             ,L_END_TRX_DATE);
      /*SRW.REFERENCE(FUNCTIONAL_CURRENCY)*/NULL;
      RP_REPORT_CURRENCY := NVL(P_CURRENCY_CODE
                               ,FUNCTIONAL_CURRENCY);
      SELECT
        SUBSTRB(CP.USER_CONCURRENT_PROGRAM_NAME
               ,1
               ,80)
      INTO L_REPORT_NAME
      FROM
        FND_CONCURRENT_PROGRAMS_VL CP,
        FND_CONCURRENT_REQUESTS CR
      WHERE CR.REQUEST_ID = P_CONC_REQUEST_ID
        AND CP.APPLICATION_ID = CR.PROGRAM_APPLICATION_ID
        AND CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID;
	l_report_name := substr(l_report_name,1,instr(l_report_name,' (XML)'));
      RP_REPORT_NAME := L_REPORT_NAME;
      RETURN (L_REPORT_NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RP_REPORT_NAME := NULL;
        RETURN (NULL);
    END;
    RETURN NULL;
  END REPORT_NAMEFORMULA;

  FUNCTION C_DATA_NOT_FOUNDFORMULA(INVOICE_NUMBER IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    RP_DATA_FOUND := INVOICE_NUMBER;
    RETURN (0);
  END C_DATA_NOT_FOUNDFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    BEGIN
      FND_MO_REPORTING_API.INITIALIZE(P_REPORTING_LEVEL
                                     ,P_REPORTING_CONTEXT
                                     ,'AUTO');
      LP_REP_CONTEXT_WH := FND_MO_REPORTING_API.GET_PREDICATE('paysch'
                                                             ,NULL
                                                             ,P_REPORTING_CONTEXT);
      /*SRW.MESSAGE(10
                 ,'LP_REP_CONTEXT_WH : ' || LP_REP_CONTEXT_WH)*/NULL;
      /*SRW.MESSAGE(20
                 ,'P_TAX_INVOICE_DATE_LOW: ' || P_TAX_INVOICE_DATE_LOW)*/NULL;
      /*SRW.MESSAGE(30
                 ,'P_TAX_INVOICE_DATE_HIGH: ' || P_TAX_INVOICE_DATE_HIGH)*/NULL;
      IF P_TAX_INVOICE_DATE_LOW IS NOT NULL THEN
        LP_START_TRX_DATE := 'and  paysch.trx_date >= :P_TAX_INVOICE_DATE_LOW';
	else
LP_START_TRX_DATE := '  ';
      END IF;
      IF P_TAX_INVOICE_DATE_HIGH IS NOT NULL THEN
        LP_END_TRX_DATE := ' and  paysch.trx_date <= :P_TAX_INVOICE_DATE_HIGH';
	else
LP_END_TRX_DATE := '  ';
      END IF;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;

  FUNCTION RP_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DATA_FOUND;
  END RP_DATA_FOUND_P;

  FUNCTION RP_REPORT_CURRENCY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_CURRENCY;
  END RP_REPORT_CURRENCY_P;

  FUNCTION RP_TRX_DATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_TRX_DATE;
  END RP_TRX_DATE_P;

  FUNCTION RPD_AMOUNT_OUTSTANDING_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RPD_AMOUNT_OUTSTANDING;
  END RPD_AMOUNT_OUTSTANDING_P;

END ZX_ZXXATB_XMLP_PKG;


/
