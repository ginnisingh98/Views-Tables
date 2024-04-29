--------------------------------------------------------
--  DDL for Package Body AR_ARBRRMBM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARBRRMBM_XMLP_PKG" AS
/* $Header: ARBRRMBMB.pls 120.1 2008/01/07 14:49:32 npannamp noship $ */
  FUNCTION REPORT_NAMEFORMULA(COMPANY_NAME IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_REPORT_NAME VARCHAR2(240);
    BEGIN
      RP_COMPANY_NAME := COMPANY_NAME;
      SELECT
        CP.USER_CONCURRENT_PROGRAM_NAME
      INTO L_REPORT_NAME
      FROM
        FND_CONCURRENT_PROGRAMS_VL CP,
        FND_APPLICATION_VL AP
      WHERE AP.APPLICATION_ID = CP.APPLICATION_ID
        AND CP.CONCURRENT_PROGRAM_NAME = 'ARBRRMBM'
        AND AP.APPLICATION_SHORT_NAME = 'AR';
      RP_REPORT_NAME := L_REPORT_NAME;
      RETURN (L_REPORT_NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RP_REPORT_NAME := 'Bills Receivable Remittance Batch Management Report';
        RETURN ('Bills Receivable Remittance Batch Management Report');
    END;
    RETURN NULL;
  END REPORT_NAMEFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      CP_SORT_BY := NVL(P_SORT_BY,'REMITTANCE ACCOUNT');
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(100
                   ,'Foundation is not initialised')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
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

  FUNCTION DUMMY_CURRENCYFORMULA(B_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (B_CURRENCY_CODE);
  END DUMMY_CURRENCYFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    DECLARE
      L_DEBUG VARCHAR2(3) := 'NO';
    BEGIN
      IF P_STATUS IS NOT NULL THEN
        LP_STATUS := ' and bat.batch_applied_status = ''' || P_STATUS || '''';
      ELSE
        LP_STATUS :=' ';
      END IF;
      IF P_REMITTANCE_METHOD IS NOT NULL THEN
        LP_REMIT_METHOD := '  and bat.remit_method_code = ''' || P_REMITTANCE_METHOD || '''';
      ELSE
        LP_REMIT_METHOD := ' ';
      END IF;
      IF P_REMIT_BANK_ACCOUNT IS NOT NULL THEN
        LP_BANK_ACCOUNT := '  and bat.remit_bank_acct_use_id = ''' || P_REMIT_BANK_ACCOUNT || '''';
      ELSE
        LP_BANK_ACCOUNT := ' ';
      END IF;
      IF P_REMIT_BANK_BRANCH IS NOT NULL THEN
        LP_BANK_BRANCH := '  and abb.bank_branch_name = ''' || P_REMIT_BANK_BRANCH || '''';
      ELSE
        LP_BANK_BRANCH := ' ';
      END IF;
      IF P_REMIT_BANK IS NOT NULL THEN
        LP_BANK := '  and abb.bank_name = ''' || P_REMIT_BANK || '''';
      ELSE
        LP_BANK := ' ';
      END IF;
      IF P_BATCH_NAME_LOW IS NOT NULL THEN
        IF P_BATCH_NAME_HIGH IS NOT NULL THEN
          LP_BATCH_NAME_RANGE := '  and bat.name between  ''' || P_BATCH_NAME_LOW || ''' and ''' || P_BATCH_NAME_HIGH || '''';
        ELSE
          LP_BATCH_NAME_RANGE := '  and bat.name >=  ''' || P_BATCH_NAME_LOW || '''';
        END IF;
      ELSIF P_BATCH_NAME_HIGH IS NOT NULL THEN
        LP_BATCH_NAME_RANGE := '  and bat.name <=  ''' || P_BATCH_NAME_HIGH || '''';
      ELSE
        LP_BATCH_NAME_RANGE := ' ';
      END IF;
      IF P_DEPNO_LOW IS NOT NULL THEN
        IF P_DEPNO_HIGH IS NOT NULL THEN
          LP_DEPOSIT_RANGE := 'and bat.bank_deposit_number between ''' || P_DEPNO_LOW || ''' and ''' || P_DEPNO_HIGH || '''';
        ELSE
          LP_DEPOSIT_RANGE := '  and bat.bank_deposit_number >=  ''' || P_DEPNO_LOW || '''';
        END IF;
      ELSIF P_DEPNO_HIGH IS NOT NULL THEN
        LP_DEPOSIT_RANGE := '  and bat.bank_deposit_number <=  ''' || P_DEPNO_HIGH || '''';
      ELSE
        LP_DEPOSIT_RANGE := ' ';
      END IF;
      IF P_REM_DATE_FROM IS NOT NULL THEN
        IF P_REM_DATE_TO IS NOT NULL THEN
          LP_DATE_RANGE := 'and bat.batch_date between''' || TRUNC(P_REM_DATE_FROM) || ''' and ''' || TRUNC(P_REM_DATE_TO + 1) || '''';
        ELSE
          LP_DATE_RANGE := '  and bat.batch_date >=  ''' || TRUNC(P_REM_DATE_FROM) || '''';
        END IF;
      ELSIF P_REM_DATE_TO IS NOT NULL THEN
        LP_DATE_RANGE := '  and bat.batch_date <=  ''' || TRUNC(P_REM_DATE_TO + 1) || '''';
      ELSE
        LP_DATE_RANGE := ' ';
      END IF;
      IF P_INCLUDE_FORMATTED = 'N' THEN
        LP_INC_FORMATTED := '  and bat.batch_applied_status <> ''COMPLETED_FORMAT''';
      ELSE
        LP_INC_FORMATTED := ' ';
      END IF;
      IF L_DEBUG = 'YES' THEN
        /*SRW.MESSAGE(007
                   ,':LP_REMIT_METHOD ' || LP_REMIT_METHOD)*/NULL;
        /*SRW.MESSAGE(007
                   ,':LP_BANK_ACCOUNT ' || LP_BANK_ACCOUNT)*/NULL;
        /*SRW.MESSAGE(007
                   ,':LP_BANK_BRANCH ' || LP_BANK_BRANCH)*/NULL;
        /*SRW.MESSAGE(007
                   ,':LP_BANK ' || LP_BANK)*/NULL;
        /*SRW.MESSAGE(007
                   ,':LP_BATCH_NAME_RANGE ' || LP_BATCH_NAME_RANGE)*/NULL;
        /*SRW.MESSAGE(007
                   ,':LP_DEPOSIT_RANGE ' || LP_DEPOSIT_RANGE)*/NULL;
        /*SRW.MESSAGE(007
                   ,':LP_DATE_RANGE ' || LP_DATE_RANGE)*/NULL;
        /*SRW.MESSAGE(007
                   ,':LP_INC_FORMATTED ' || LP_INC_FORMATTED)*/NULL;
        /*SRW.MESSAGE(007
                   ,':LP_STATUS ' || LP_STATUS)*/NULL;
      END IF;
      RETURN (TRUE);
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION RP_DSP_SORT_BYFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_SORT_BY VARCHAR(40);
    BEGIN
      SELECT
        MEANING
      INTO L_SORT_BY
      FROM
        AR_LOOKUPS
      WHERE LOOKUP_TYPE = 'SORT_BY_ARXAPRMB'
        AND LOOKUP_CODE = CP_SORT_BY;
      RETURN (L_SORT_BY);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
    RETURN NULL;
  END RP_DSP_SORT_BYFORMULA;

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
      WHERE LOOKUP_TYPE = 'BATCH_APPLIED_STATUS'
        AND LOOKUP_CODE = P_STATUS;
      RETURN (L_STATUS);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
    RETURN NULL;
  END RP_DSP_STATUSFORMULA;

  FUNCTION DISP_REMIT_METHODFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_REM_MET VARCHAR(40);
    BEGIN
      SELECT
        MEANING
      INTO L_REM_MET
      FROM
        AR_LOOKUPS
      WHERE LOOKUP_TYPE = 'REMITTANCE_METHOD'
        AND ENABLED_FLAG = 'Y'
        AND LOOKUP_CODE = P_REMITTANCE_METHOD;
      RETURN (L_REM_MET);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
    RETURN NULL;
  END DISP_REMIT_METHODFORMULA;

  FUNCTION DISP_REMIT_ACCOUNTFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_REM_ACC VARCHAR(40);
    BEGIN
      SELECT
        BANK_ACCOUNT_NAME
      INTO L_REM_ACC
      FROM
        CE_BANK_ACCOUNTS
      WHERE BANK_ACCOUNT_ID = P_REMIT_BANK_ACCOUNT;
      RETURN (L_REM_ACC);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
    RETURN NULL;
  END DISP_REMIT_ACCOUNTFORMULA;

  FUNCTION DISP_INC_FORMATTEDFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_INC_FORM VARCHAR(40);
    BEGIN
      SELECT
        MEANING
      INTO L_INC_FORM
      FROM
        FND_LOOKUPS
      WHERE LOOKUP_TYPE = 'YES_NO'
        AND ENABLED_FLAG = 'Y'
        AND LOOKUP_CODE = P_INCLUDE_FORMATTED;
      RETURN (L_INC_FORM);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
    RETURN NULL;
  END DISP_INC_FORMATTEDFORMULA;

  FUNCTION DISP_SUM_OR_DETFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_SUM_OR_DET VARCHAR(80);
    BEGIN
      SELECT
        MEANING
      INTO L_SUM_OR_DET
      FROM
        AR_LOOKUPS
      WHERE LOOKUP_TYPE = 'ARXAPRMB_SD'
        AND ENABLED_FLAG = 'Y'
        AND LOOKUP_CODE = P_SUMMARY_OR_DETAILED;
      RETURN (L_SUM_OR_DET);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
    RETURN NULL;
  END DISP_SUM_OR_DETFORMULA;

  FUNCTION DET_BATCH_STATUSFORMULA(B_BATCH_STATUS IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF P_SUMMARY_OR_DETAILED = 'DETAILED' THEN
      RETURN (B_BATCH_STATUS);
    END IF;
    RETURN NULL;
  END DET_BATCH_STATUSFORMULA;

  FUNCTION CF_SYSDATEFORMULA RETURN CHAR IS
  BEGIN
    RETURN (FND_DATE.DATE_TO_CHARDT(SYSDATE));
  END CF_SYSDATEFORMULA;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;

  FUNCTION RP_SUB_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SUB_TITLE;
  END RP_SUB_TITLE_P;

  FUNCTION RP_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DATA_FOUND;
  END RP_DATA_FOUND_P;

END AR_ARBRRMBM_XMLP_PKG;


/