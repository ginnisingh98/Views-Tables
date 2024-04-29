--------------------------------------------------------
--  DDL for Package Body JL_JLCOFAAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_JLCOFAAR_XMLP_PKG" AS
/* $Header: JLCOFAARB.pls 120.1 2007/12/25 16:44:01 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    CURRENCY_VALIDATION;
    GET_BASE_CURR_DATA;
    RETURN (TRUE);
  END BEFOREREPORT;

  PROCEDURE GET_BASE_CURR_DATA IS
    COMPANY_NAME FA_SYSTEM_CONTROLS.COMPANY_NAME%TYPE;
  BEGIN
    COMPANY_NAME := '';
    BEGIN
      SELECT
        FS.COMPANY_NAME
      INTO COMPANY_NAME
      FROM
        FA_SYSTEM_CONTROLS FS;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_ORA_ERR('JL_CO_FA_GENERAL_ERROR');
    END;
    C_COMPANY_NAME := COMPANY_NAME;
    IF P_ALL_ROWS = 'Y' THEN
      C_STATUS := ' ';
    ELSIF P_ALL_ROWS = 'N' THEN
      C_STATUS := 'AND aspa.status not in (''V'', ''P'')';
    END IF;
    P_MIN_PRECISION := 2;
  END GET_BASE_CURR_DATA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      NULL;
    EXCEPTION
      WHEN OTHERS THEN
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  PROCEDURE RAISE_ORA_ERR(MSGNAME IN VARCHAR2) IS
    ERRMSG VARCHAR2(1000);
    ERRNUM NUMBER;
  BEGIN
    FND_MESSAGE.SET_NAME('JL'
                        ,MSGNAME);
    ERRMSG := FND_MESSAGE.GET;
    /*SRW.MESSAGE(JL_ZZ_FA_UTILITIES_PKG.GET_APP_ERRNUM('JL'
                                                     ,MSGNAME)
               ,ERRMSG)*/NULL;
    ERRNUM := SQLCODE;
    ERRMSG := SQLERRM;
    /*SRW.MESSAGE(ERRNUM
               ,ERRMSG)*/NULL;
    /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
  END RAISE_ORA_ERR;

  PROCEDURE RAISE_ERR(MSGNAME IN VARCHAR2) IS
    ERRMSG VARCHAR2(1000);
  BEGIN
    FND_MESSAGE.SET_NAME('JL'
                        ,MSGNAME);
    ERRMSG := FND_MESSAGE.GET;
    /*SRW.MESSAGE(JL_ZZ_FA_UTILITIES_PKG.GET_APP_ERRNUM('JL'
                                                     ,MSGNAME)
               ,ERRMSG)*/NULL;
    /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
  END RAISE_ERR;

  PROCEDURE CURRENCY_VALIDATION IS
    CURSOR CURRENCY IS
      SELECT
        DISTINCT
        CURRENCY_CODE
      FROM
        JL_CO_FA_APPRAISALS
      WHERE APPRAISAL_ID = P_APPRAISAL_ID;
    CURRVAR VARCHAR2(15);
    DUMMY VARCHAR2(15);
    ERRMSG VARCHAR2(1000);
  BEGIN
    OPEN CURRENCY;
    LOOP
      FETCH CURRENCY
       INTO CURRVAR;
      EXIT WHEN CURRENCY%NOTFOUND;
      CP_VALID_CURR_CODE := 0;
      BEGIN
        SELECT
          1
        INTO DUMMY
        FROM
          FND_CURRENCIES
        WHERE CURRENCY_CODE = CURRVAR;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('JL'
                              ,'JL_CO_FA_INVALID_CURRENCY_CODE');
          FND_MESSAGE.SET_TOKEN('APPRAISAL_NUMBER'
                               ,TO_CHAR(P_APPRAISAL_ID)
                               ,FALSE);
          ERRMSG := FND_MESSAGE.GET;
          /*SRW.MESSAGE(JL_ZZ_FA_UTILITIES_PKG.GET_APP_ERRNUM('JL'
                                                           ,'JL_CO_FA_INVALID_CURRENCY_CODE')
                     ,ERRMSG)*/NULL;
          CP_VALID_CURR_CODE := 1;
        WHEN OTHERS THEN
          RAISE_ORA_ERR('JL_CO_FA_GENERAL_ERROR');
      END;
    END LOOP;
  END CURRENCY_VALIDATION;

  FUNCTION CF_1FORMULA RETURN NUMBER IS
    X NUMBER;
  BEGIN
    SELECT
      COUNT(*)
    INTO X
    FROM
      JL_CO_FA_APPRAISALS AP,
      JL_CO_FA_ASSET_APPRS ASP,
      FND_LOOKUPS FLH,
      FND_LOOKUPS FLD
    WHERE AP.APPRAISAL_ID = P_APPRAISAL_ID
      AND ASP.APPRAISAL_ID = AP.APPRAISAL_ID
      AND DECODE(P_ALL_ROWS
          ,NULL
          ,'1'
          ,'Y'
          ,'1'
          ,ASP.STATUS) NOT IN ( DECODE(P_ALL_ROWS
          ,NULL
          ,'2'
          ,'Y'
          ,'2'
          ,'P') )
      AND FLH.LOOKUP_TYPE = 'JLCO_FA_ASSET_APPRAISAL_STATUS'
      AND FLH.LOOKUP_CODE = AP.APPRAISAL_STATUS
      AND FLD.LOOKUP_TYPE = FLH.LOOKUP_TYPE
      AND FLD.LOOKUP_CODE = ASP.STATUS
      AND UPPER(FLD.ENABLED_FLAG) = 'Y'
      AND SYSDATE BETWEEN NVL(FLD.START_DATE_ACTIVE
       ,SYSDATE - 1)
      AND NVL(FLD.END_DATE_ACTIVE
       ,SYSDATE + 1);
    RETURN X;
  END CF_1FORMULA;

  FUNCTION CF_2FORMULA(STATUS_CODE IN VARCHAR2) RETURN NUMBER IS
    X NUMBER;
  BEGIN
    SELECT
      COUNT(*)
    INTO X
    FROM
      JL_CO_FA_APPRAISALS AP,
      JL_CO_FA_ASSET_APPRS ASP,
      FND_LOOKUPS FLH,
      FND_LOOKUPS FLD
    WHERE AP.APPRAISAL_ID = P_APPRAISAL_ID
      AND ASP.APPRAISAL_ID = AP.APPRAISAL_ID
      AND DECODE(P_ALL_ROWS
          ,NULL
          ,'1'
          ,'Y'
          ,'1'
          ,ASP.STATUS) NOT IN ( DECODE(P_ALL_ROWS
          ,NULL
          ,'2'
          ,'Y'
          ,'2'
          ,'P') )
      AND ASP.STATUS = STATUS_CODE
      AND FLH.LOOKUP_TYPE = 'JLCO_FA_ASSET_APPRAISAL_STATUS'
      AND FLH.LOOKUP_CODE = AP.APPRAISAL_STATUS
      AND FLD.LOOKUP_TYPE = FLH.LOOKUP_TYPE
      AND FLD.LOOKUP_CODE = ASP.STATUS
      AND UPPER(FLD.ENABLED_FLAG) = 'Y'
      AND SYSDATE BETWEEN NVL(FLD.START_DATE_ACTIVE
       ,SYSDATE - 1)
      AND NVL(FLD.END_DATE_ACTIVE
       ,SYSDATE + 1);
    RETURN X;
  END CF_2FORMULA;

  FUNCTION CF_3FORMULA(STATUS_DESC IN VARCHAR2) RETURN VARCHAR2 IS
    MSG_TEXT VARCHAR2(2000);
  BEGIN
    FND_MESSAGE.SET_NAME('JL'
                        ,'JL_CO_FA_ASSET_SUMMARY_TEXT');
    MSG_TEXT := FND_MESSAGE.GET || ' ' || STATUS_DESC;
    RETURN (MSG_TEXT);
  END CF_3FORMULA;

  FUNCTION C_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMPANY_NAME;
  END C_COMPANY_NAME_P;

  FUNCTION C_STATUS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_STATUS;
  END C_STATUS_P;

  FUNCTION CP_VALID_CURR_CODE_P RETURN NUMBER IS
  BEGIN
    RETURN CP_VALID_CURR_CODE;
  END CP_VALID_CURR_CODE_P;

END JL_JLCOFAAR_XMLP_PKG;




/