--------------------------------------------------------
--  DDL for Package Body AR_ARXAPRCB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXAPRCB_XMLP_PKG" AS
/* $Header: ARXAPRCBB.pls 120.0 2007/12/27 13:27:47 abraghun noship $ */
  FUNCTION REPORT_NAMEFORMULA(COMPANY_NAME IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_REPORT_NAME VARCHAR2(80);
    BEGIN
      RP_COMPANY_NAME := COMPANY_NAME;
      SELECT
        SUBSTR(CP.USER_CONCURRENT_PROGRAM_NAME
              ,1
              ,80)
      INTO L_REPORT_NAME
      FROM
        FND_CONCURRENT_PROGRAMS_VL CP,
        FND_CONCURRENT_REQUESTS CR
      WHERE CR.REQUEST_ID = P_CONC_REQUEST_ID
        AND CP.APPLICATION_ID = CR.PROGRAM_APPLICATION_ID
        AND CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID;
      RP_REPORT_NAME := L_REPORT_NAME;
      RETURN (L_REPORT_NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RP_REPORT_NAME := 'Automatic Receipt Batch Management Report';
        RETURN ('Automatic Receipt Batch Management Report');
    END;
    RETURN NULL;
  END REPORT_NAMEFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION SUB_TITLEFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      RP_SUB_TITLE := ' ';
      RETURN (' ');
    END;
    RETURN NULL;
  END SUB_TITLEFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION DUMMY_CURRENCY_CODEFORMULA(CURRENCY_CODE_A IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (CURRENCY_CODE_A);
  END DUMMY_CURRENCY_CODEFORMULA;

  FUNCTION RP_DSP_STATUSFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_STATUS VARCHAR(50);
    BEGIN
      SELECT
        MEANING
      INTO L_STATUS
      FROM
        AR_LOOKUPS
      WHERE LOOKUP_CODE = P_STATUS
        AND LOOKUP_TYPE = 'BATCH_APPLIED_STATUS';
      RETURN (L_STATUS);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
    RETURN NULL;
  END RP_DSP_STATUSFORMULA;

  FUNCTION AMOUNTFORMULA(BATCH_APPLIED_STATUS IN VARCHAR2
                        ,ARG_BATCH_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_AMOUNT NUMBER;
    BEGIN
      IF ((BATCH_APPLIED_STATUS = 'COMPLETED_CREATION') OR (BATCH_APPLIED_STATUS = 'STARTED_CREATION') OR (BATCH_APPLIED_STATUS = 'STARTED_APPROVAL')) THEN
        SELECT
          SUM(PS.AMOUNT_DUE_REMAINING)
        INTO L_AMOUNT
        FROM
          AR_PAYMENT_SCHEDULES PS
        WHERE PS.SELECTED_FOR_RECEIPT_BATCH_ID = ARG_BATCH_ID
          AND PS.STATUS = 'OP';
        RETURN (L_AMOUNT);
      ELSE
        SELECT
          SUM(CRH.AMOUNT)
        INTO L_AMOUNT
        FROM
          AR_CASH_RECEIPT_HISTORY CRH
        WHERE CRH.BATCH_ID = ARG_BATCH_ID
          AND CRH.PRV_STAT_CASH_RECEIPT_HIST_ID is null;
      END IF;
      RETURN (L_AMOUNT);
    END;
    RETURN NULL;
  END AMOUNTFORMULA;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN substr(RP_REPORT_NAME,1,instr(RP_REPORT_NAME,' (XML)'));
  END RP_REPORT_NAME_P;

  FUNCTION RP_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DATA_FOUND;
  END RP_DATA_FOUND_P;

  FUNCTION RP_SUB_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SUB_TITLE;
  END RP_SUB_TITLE_P;

END AR_ARXAPRCB_XMLP_PKG;


/