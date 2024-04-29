--------------------------------------------------------
--  DDL for Package Body PSB_PSBRPWPC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_PSBRPWPC_XMLP_PKG" AS
/* $Header: PSBRPWPCB.pls 120.0 2008/01/07 10:54:25 vijranga noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    CURSOR Y1 IS
      SELECT
        NAME
      FROM
        PSB_BUDGET_PERIODS
      WHERE BUDGET_PERIOD_ID = P_BUDGET_GROUP_ID1;
    CURSOR Y2 IS
      SELECT
        NAME
      FROM
        PSB_BUDGET_PERIODS
      WHERE BUDGET_PERIOD_ID = P_BUDGET_GROUP_ID2;
    CURSOR Y3 IS
      SELECT
        NAME
      FROM
        PSB_BUDGET_PERIODS
      WHERE BUDGET_PERIOD_ID = P_BUDGET_GROUP_ID3;
    CURSOR Y4 IS
      SELECT
        NAME
      FROM
        PSB_BUDGET_PERIODS
      WHERE BUDGET_PERIOD_ID = P_BUDGET_GROUP_ID4;
    L_CALENDAR_ID NUMBER;
    L_FLEX_MAPPING_SET_ID NUMBER;
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    FND_MESSAGE.SET_NAME('PSB'
                        ,'PSB_NO_DATA_FOUND');
    CP_NO_DATA_FOUND := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME('PSB'
                        ,'PSB_END_OF_REPORT');
    CP_END_OF_REPORT := FND_MESSAGE.GET;
    FOR y1_rec IN Y1 LOOP
      CP_YEAR_NAME1 := Y1_REC.NAME;
    END LOOP;
    FOR y2_rec IN Y2 LOOP
      CP_YEAR_NAME2 := Y2_REC.NAME;
    END LOOP;
    FOR y3_rec IN Y3 LOOP
      CP_YEAR_NAME3 := Y3_REC.NAME;
    END LOOP;
    FOR y4_rec IN Y4 LOOP
      CP_YEAR_NAME4 := Y4_REC.NAME;
    END LOOP;
    IF P_SERVICE_PACKAGE_ID IS NULL THEN
      FND_MESSAGE.SET_NAME('PSB'
                          ,'PSB_ALL');
      CP_PARAM_SP_NAME := FND_MESSAGE.GET;
    ELSE
      SELECT
        NAME
      INTO CP_PARAM_SP_NAME
      FROM
        PSB_SERVICE_PACKAGES
      WHERE SERVICE_PACKAGE_ID = P_SERVICE_PACKAGE_ID;
    END IF;
    IF P_STAGE_ID IS NOT NULL THEN
      SELECT
        NAME,
        SEQUENCE_NUMBER
      INTO CP_PARAM_STAGE_NAME,CP_SEQUENCE_NUMBER
      FROM
        PSB_BUDGET_STAGES
      WHERE BUDGET_STAGE_ID = P_STAGE_ID;
    ELSE
      SELECT
        ST.NAME,
        ST.SEQUENCE_NUMBER
      INTO CP_PARAM_STAGE_NAME,CP_SEQUENCE_NUMBER
      FROM
        PSB_BUDGET_STAGES ST,
        PSB_WORKSHEETS WS
      WHERE WS.WORKSHEET_ID = P_GLOBAL_WORKSHEET_ID
        AND ST.BUDGET_STAGE_SET_ID = WS.STAGE_SET_ID
        AND ST.SEQUENCE_NUMBER = WS.CURRENT_STAGE_SEQ;
    END IF;
    IF P_GLOBAL_WORKSHEET_ID IS NULL THEN
      FND_MESSAGE.SET_NAME('PSB'
                          ,'PSB_ALL');
      CP_PARAM_WS_NAME := FND_MESSAGE.GET;
    ELSE
      SELECT
        NAME,
        BUDGET_CALENDAR_ID,
        FLEX_MAPPING_SET_ID
      INTO CP_PARAM_WS_NAME,L_CALENDAR_ID,CP_FLEX_MAPPING_SET_ID
      FROM
        PSB_WORKSHEETS
      WHERE WORKSHEET_ID = P_GLOBAL_WORKSHEET_ID;
      /*SELECT
        BUDGET_YEAR_TYPE_ID
      INTO CP_CY_PERIOD_ID
      FROM
        PSB_BUDGET_PERIODS
      WHERE BUDGET_CALENDAR_ID = L_CALENDAR_ID
        AND BUDGET_PERIOD_TYPE = 'Y';*/
    END IF;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     raise_application_error(-20101,SQLERRM);
      RETURN (FALSE);
   WHEN OTHERS THEN NULL;
	RETURN NULL;
  END BEFOREREPORT;
  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END AFTERPFORM;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION CP_NO_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NO_DATA_FOUND;
  END CP_NO_DATA_FOUND_P;
  FUNCTION CP_END_OF_REPORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_END_OF_REPORT;
  END CP_END_OF_REPORT_P;
  FUNCTION SELECT_AMT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SELECT_AMT;
  END SELECT_AMT_P;
  FUNCTION CP_PARAM_WS_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PARAM_WS_NAME;
  END CP_PARAM_WS_NAME_P;
  FUNCTION CP_PARAM_SP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PARAM_SP_NAME;
  END CP_PARAM_SP_NAME_P;
  FUNCTION CP_PARAM_ORDER_BY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PARAM_ORDER_BY;
  END CP_PARAM_ORDER_BY_P;
  FUNCTION CP_SORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SORT;
  END CP_SORT_P;
  FUNCTION CP_WS_STAGE_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_WS_STAGE_NAME;
  END CP_WS_STAGE_NAME_P;
  FUNCTION CP_PARAM_STAGE_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PARAM_STAGE_NAME;
  END CP_PARAM_STAGE_NAME_P;
  FUNCTION CP_SEQUENCE_NUMBER_P RETURN NUMBER IS
  BEGIN
    RETURN CP_SEQUENCE_NUMBER;
  END CP_SEQUENCE_NUMBER_P;
  FUNCTION CP_YEAR_NAME1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_YEAR_NAME1;
  END CP_YEAR_NAME1_P;
  FUNCTION CP_YEAR_NAME2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_YEAR_NAME2;
  END CP_YEAR_NAME2_P;
  FUNCTION CP_YEAR_NAME3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_YEAR_NAME3;
  END CP_YEAR_NAME3_P;
  FUNCTION CP_YEAR_NAME4_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_YEAR_NAME4;
  END CP_YEAR_NAME4_P;
  FUNCTION CP_FLEX_MAPPING_SET_ID_P RETURN NUMBER IS
  BEGIN
    RETURN CP_FLEX_MAPPING_SET_ID;
  END CP_FLEX_MAPPING_SET_ID_P;
  FUNCTION CP_CY_PERIOD_ID_P RETURN NUMBER IS
  BEGIN
    RETURN CP_CY_PERIOD_ID;
  END CP_CY_PERIOD_ID_P;
END PSB_PSBRPWPC_XMLP_PKG;






/
