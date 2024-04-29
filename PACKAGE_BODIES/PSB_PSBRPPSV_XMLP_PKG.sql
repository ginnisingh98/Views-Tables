--------------------------------------------------------
--  DDL for Package Body PSB_PSBRPPSV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_PSBRPPSV_XMLP_PKG" AS
/* $Header: PSBRPPSVB.pls 120.0 2008/01/07 10:46:34 vijranga noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_STAGENAME1FORMULA RETURN CHAR IS
  BEGIN
    DECLARE
      CURSOR STAGENAME_CUR IS
        SELECT
          NAME
        FROM
          PSB_BUDGET_STAGES
        WHERE BUDGET_STAGE_ID = P_STAGE1;
      STAGENAME PSB_BUDGET_STAGES.NAME%TYPE;
    BEGIN
      OPEN STAGENAME_CUR;
      FETCH STAGENAME_CUR
       INTO STAGENAME;
      CLOSE STAGENAME_CUR;
      RETURN STAGENAME;
    END;
  END CF_STAGENAME1FORMULA;

  FUNCTION CF_STAGENAME2FORMULA RETURN CHAR IS
  BEGIN
    DECLARE
      CURSOR STAGENAME_CUR IS
        SELECT
          NAME
        FROM
          PSB_BUDGET_STAGES
        WHERE BUDGET_STAGE_ID = P_STAGE2;
      STAGENAME PSB_BUDGET_STAGES.NAME%TYPE;
    BEGIN
      OPEN STAGENAME_CUR;
      FETCH STAGENAME_CUR
       INTO STAGENAME;
      CLOSE STAGENAME_CUR;
      RETURN STAGENAME;
    END;
  END CF_STAGENAME2FORMULA;

  FUNCTION CF_STAGENAME3FORMULA RETURN CHAR IS
  BEGIN
    DECLARE
      CURSOR STAGENAME_CUR IS
        SELECT
          NAME
        FROM
          PSB_BUDGET_STAGES
        WHERE BUDGET_STAGE_ID = P_STAGE3;
      STAGENAME PSB_BUDGET_STAGES.NAME%TYPE;
    BEGIN
      OPEN STAGENAME_CUR;
      FETCH STAGENAME_CUR
       INTO STAGENAME;
      CLOSE STAGENAME_CUR;
      RETURN STAGENAME;
    END;
  END CF_STAGENAME3FORMULA;

  FUNCTION CF_AMOUNTFORMULA RETURN CHAR IS
  BEGIN
    IF (P_STAGE3 IS NOT NULL) THEN
      RETURN 'Amount';
    ELSE
      RETURN '';
    END IF;
  END CF_AMOUNTFORMULA;

  FUNCTION CF_FTEAMOUNTFORMULA RETURN CHAR IS
  BEGIN
    IF (P_STAGE3 IS NOT NULL) THEN
      RETURN 'FTE Amount';
    ELSE
      RETURN '';
    END IF;
  END CF_FTEAMOUNTFORMULA;

  FUNCTION CF_AMOUNTLINEFORMULA RETURN CHAR IS
  BEGIN
    IF (P_STAGE3 IS NOT NULL) THEN
      RETURN '------------';
    ELSE
      RETURN '';
    END IF;
  END CF_AMOUNTLINEFORMULA;

  FUNCTION CF_FTEAMOUNTLINEFORMULA RETURN CHAR IS
  BEGIN
    IF (P_STAGE3 IS NOT NULL) THEN
      RETURN '--------------';
    ELSE
      RETURN '';
    END IF;
  END CF_FTEAMOUNTLINEFORMULA;

  FUNCTION CF_DATAFOUNDFORMULA RETURN NUMBER IS
  BEGIN
    DECLARE
      CURSOR DATA_FOUND_CUR IS
        SELECT
          count(*)
        FROM
          PSB_WORKSHEETS PW,
          PSB_WS_LINES PWL,
          PSB_WS_ACCOUNT_LINES PWAL,
          PSB_SERVICE_PACKAGES PSP,
          PSB_BUDGET_GROUPS PBG,
          PSB_BUDGET_STAGE_SETS PBSS,
          PSB_BUDGET_STAGES PBS,
          PSB_WS_FTE_LINES PWFL,
          PSB_WS_POSITION_LINES PWPL,
          PSB_POSITIONS PP,
          PSB_BUDGET_PERIODS PBP
        WHERE PW.WORKSHEET_ID = PWL.WORKSHEET_ID
          AND PWL.ACCOUNT_LINE_ID = PWAL.ACCOUNT_LINE_ID
          AND PW.BUDGET_GROUP_ID = PBG.BUDGET_GROUP_ID
          AND PWAL.SERVICE_PACKAGE_ID = PSP.SERVICE_PACKAGE_ID
          AND PW.STAGE_SET_ID = PBSS.BUDGET_STAGE_SET_ID
          AND PBS.BUDGET_STAGE_SET_ID = PBSS.BUDGET_STAGE_SET_ID
          AND PWAL.POSITION_LINE_ID = PWPL.POSITION_LINE_ID
          AND PWPL.POSITION_ID = PP.POSITION_ID
          AND PWPL.POSITION_ID = PWFL.POSITION_LINE_ID
          AND PBP.BUDGET_PERIOD_ID = PWAL.BUDGET_YEAR_ID
          AND PBS.SEQUENCE_NUMBER BETWEEN PWAL.START_STAGE_SEQ
          AND NVL(PWAL.END_STAGE_SEQ
           ,PWAL.CURRENT_STAGE_SEQ)
          AND BALANCE_TYPE = 'E'
          AND PW.WORKSHEET_ID = P_WORKSHEET_ID
          AND PBS.BUDGET_STAGE_ID IN ( P_STAGE1 , P_STAGE2 , P_STAGE3 )
          AND PWAL.BUDGET_YEAR_ID LIKE NVL(P_BUDGET_YEAR_ID
           ,PWAL.BUDGET_YEAR_ID);
      DATA_COUNT NUMBER;
    BEGIN
      OPEN DATA_FOUND_CUR;
      FETCH DATA_FOUND_CUR
       INTO DATA_COUNT;
      CLOSE DATA_FOUND_CUR;
      RETURN DATA_COUNT;
    END;
  END CF_DATAFOUNDFORMULA;

  FUNCTION CF_VARIANCE_AMOUNTFORMULA(YEAR_AMOUNT2 IN NUMBER
                                    ,YEAR_AMOUNT1 IN NUMBER) RETURN NUMBER IS
    L_VARIANCE NUMBER;
  BEGIN
    L_VARIANCE := NVL(YEAR_AMOUNT2
                     ,0) - NVL(YEAR_AMOUNT1
                     ,0);
    RETURN (L_VARIANCE);
  END CF_VARIANCE_AMOUNTFORMULA;

  FUNCTION CF_VARIANCE_PERCENTFORMULA(CF_VARIANCE_AMOUNT IN NUMBER
                                     ,YEAR_AMOUNT1 IN NUMBER) RETURN NUMBER IS
    L_PERCENT NUMBER;
  BEGIN
    L_PERCENT := (CF_VARIANCE_AMOUNT / (NVL(YEAR_AMOUNT1
                    ,0))) * 100;
    RETURN (L_PERCENT);
  EXCEPTION
    WHEN OTHERS THEN
      L_PERCENT := NULL;
      RETURN (L_PERCENT);
  END CF_VARIANCE_PERCENTFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

END PSB_PSBRPPSV_XMLP_PKG;






/
