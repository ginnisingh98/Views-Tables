--------------------------------------------------------
--  DDL for Package Body PSB_PSBRPACV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_PSBRPACV_XMLP_PKG" AS
/* $Header: PSBRPACVB.pls 120.0 2008/01/07 10:29:56 vijranga noship $ */
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
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        STAGENAME := NULL;
        RETURN STAGENAME;
    END;
  END CF_STAGENAME3FORMULA;

  FUNCTION CF_STAGENAME4FORMULA RETURN CHAR IS
  BEGIN
    DECLARE
      CURSOR STAGENAME_CUR IS
        SELECT
          NAME
        FROM
          PSB_BUDGET_STAGES
        WHERE BUDGET_STAGE_ID = P_STAGE4;
      STAGENAME PSB_BUDGET_STAGES.NAME%TYPE;
    BEGIN
      OPEN STAGENAME_CUR;
      FETCH STAGENAME_CUR
       INTO STAGENAME;
      CLOSE STAGENAME_CUR;
      RETURN STAGENAME;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        STAGENAME := NULL;
        RETURN STAGENAME;
    END;
  END CF_STAGENAME4FORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_NODATAFOUNDFORMULA RETURN CHAR IS
    VDATAFOUND NUMBER := 0;
    VNODATAMESG VARCHAR2(100);
  BEGIN
    SELECT
      count(*)
    INTO VDATAFOUND
    FROM
      PSB_WORKSHEETS PW,
      PSB_WS_LINES PWL,
      PSB_WS_ACCOUNT_LINES PWAL,
      PSB_SERVICE_PACKAGES PSP,
      PSB_BUDGET_GROUPS PBG,
      PSB_BUDGET_STAGE_SETS PBSS,
      PSB_BUDGET_STAGES PBS,
      PSB_BUDGET_PERIODS PBP
    WHERE PW.WORKSHEET_ID = PWL.WORKSHEET_ID
      AND PWL.ACCOUNT_LINE_ID = PWAL.ACCOUNT_LINE_ID
      AND PW.BUDGET_GROUP_ID = PBG.BUDGET_GROUP_ID
      AND PWAL.SERVICE_PACKAGE_ID = PSP.SERVICE_PACKAGE_ID
      AND PW.STAGE_SET_ID = PBSS.BUDGET_STAGE_SET_ID
      AND PBS.BUDGET_STAGE_SET_ID = PBSS.BUDGET_STAGE_SET_ID
      AND PBP.BUDGET_PERIOD_ID = PWAL.BUDGET_YEAR_ID
      AND PBS.SEQUENCE_NUMBER BETWEEN PWAL.START_STAGE_SEQ
      AND NVL(PWAL.END_STAGE_SEQ
       ,PWAL.CURRENT_STAGE_SEQ)
      AND BALANCE_TYPE = 'E'
      AND PW.WORKSHEET_ID = P_WORKSHEET_ID
      AND PBS.BUDGET_STAGE_ID IN ( P_STAGE1 , P_STAGE2 , P_STAGE3 , P_STAGE4 )
      AND PWAL.BUDGET_YEAR_ID LIKE NVL(P_BUDGET_YEAR_ID
       ,PWAL.BUDGET_YEAR_ID);
    IF VDATAFOUND = 0 THEN
      VNODATAMESG := '	****No Data Found****	 ';
    ELSE
      VNODATAMESG := NULL;
    END IF;
    RETURN VNODATAMESG;
  END CF_NODATAFOUNDFORMULA;

  FUNCTION CF_ACCOUNTINGFLEXFIELDFORMULA(CC_ID IN NUMBER) RETURN CHAR IS
    CURSOR ACCTFLEX_CUR IS
      SELECT
        CONCATENATED_SEGMENTS
      FROM
        GL_CODE_COMBINATIONS_KFV
      WHERE CODE_COMBINATION_ID = CC_ID;
    VACCOUNTINGFLEXFIELD GL_CODE_COMBINATIONS_KFV.CONCATENATED_SEGMENTS%TYPE;
  BEGIN
    OPEN ACCTFLEX_CUR;
    FETCH ACCTFLEX_CUR
     INTO VACCOUNTINGFLEXFIELD;
    CLOSE ACCTFLEX_CUR;
    RETURN VACCOUNTINGFLEXFIELD;
  END CF_ACCOUNTINGFLEXFIELDFORMULA;

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

END PSB_PSBRPACV_XMLP_PKG;






/