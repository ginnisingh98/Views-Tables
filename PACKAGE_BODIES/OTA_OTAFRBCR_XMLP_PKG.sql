--------------------------------------------------------
--  DDL for Package Body OTA_OTAFRBCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OTAFRBCR_XMLP_PKG" AS
/* $Header: OTAFRBCRB.pls 120.2 2007/12/07 05:58:57 amakrish noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      C_SESSION_DATE DATE;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      SELECT
        EFFECTIVE_DATE
      INTO
        C_SESSION_DATE
      FROM
        FND_SESSIONS
      WHERE SESSION_ID = USERENV('SESSIONID');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO FND_SESSIONS
          (SESSION_ID
          ,EFFECTIVE_DATE)
        VALUES   (USERENV('SESSIONID')
          ,SYSDATE);
    END;
    C_BUSINESS_GROUP_NAME := HR_REPORTS.GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
    C_CURR_CONV_TYPE := HR_CURRENCY_PKG.GET_RATE_TYPE(P_BUSINESS_GROUP_ID
                                                     ,SYSDATE
                                                     ,'R');
    SELECT
      NAME
    INTO
      C_TRAINING_PLAN_NAME
    FROM
      OTA_TRAINING_PLANS OTP
    WHERE OTP.TRAINING_PLAN_ID = P_TRAINING_PLAN_ID;
    SELECT
      MEANING
    INTO
      C_ROLLUP_LEVEL
    FROM
      FND_COMMON_LOOKUPS
    WHERE LOOKUP_TYPE = 'TP_REPORT_LEVEL'
      AND APPLICATION_ID = 800
      AND LOOKUP_CODE = P_ROLLUP;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION C_BUSINESS_GROUP_NAMEFORMULA RETURN CHAR IS
  BEGIN
    RETURN ('1');
  END C_BUSINESS_GROUP_NAMEFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_TRAINING_PLAN_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TRAINING_PLAN_NAME;
  END C_TRAINING_PLAN_NAME_P;

  FUNCTION C_ROLLUP_LEVEL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ROLLUP_LEVEL;
  END C_ROLLUP_LEVEL_P;

  FUNCTION C_BUSINESS_GROUP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BUSINESS_GROUP_NAME;
  END C_BUSINESS_GROUP_NAME_P;

  FUNCTION C_CURR_CONV_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_CURR_CONV_TYPE;
  END C_CURR_CONV_TYPE_P;

END OTA_OTAFRBCR_XMLP_PKG;

/
