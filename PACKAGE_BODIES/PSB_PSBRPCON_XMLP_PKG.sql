--------------------------------------------------------
--  DDL for Package Body PSB_PSBRPCON_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_PSBRPCON_XMLP_PKG" AS
/* $Header: PSBRPCONB.pls 120.0 2008/01/07 10:37:08 vijranga noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    SOB_ID NUMBER;
    BGP_ID NUMBER;
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    IF P_SOB_ID IS NULL THEN
      FND_MESSAGE.SET_NAME('PSB'
                          ,'PSB_ALL');
      CP_SOB := FND_MESSAGE.GET;
      IF P_BGP_ID IS NULL THEN
        FND_MESSAGE.SET_NAME('PSB'
                            ,'PSB_ALL');
        CP_BGP := FND_MESSAGE.GET;
      ELSE
        SELECT
          SHORT_NAME
        INTO CP_BGP
        FROM
          PSB_BUDGET_GROUPS
        WHERE BUDGET_GROUP_ID = P_BGP_ID;
      END IF;
    ELSE
      SELECT
        NAME
      INTO CP_SOB
      FROM
        GL_SETS_OF_BOOKS
      WHERE SET_OF_BOOKS_ID = P_SOB_ID;
      IF (P_BGP_ID IS NULL) THEN
        FND_MESSAGE.SET_NAME('PSB'
                            ,'PSB_ALL');
        CP_BGP := FND_MESSAGE.GET;
      ELSE
        SELECT
          SHORT_NAME
        INTO CP_BGP
        FROM
          PSB_BUDGET_GROUPS
        WHERE BUDGET_GROUP_ID = P_BGP_ID;
      END IF;
    END IF;
    IF P_SET_ID IS NULL THEN
      FND_MESSAGE.SET_NAME('PSB'
                          ,'PSB_ALL');
      CP_SET := FND_MESSAGE.GET;
    ELSE
      SELECT
        NAME
      INTO CP_SET
      FROM
        PSB_CONSTRAINT_SETS_V
      WHERE CONSTRAINT_SET_ID = P_SET_ID;
      SELECT
        SET_OF_BOOKS_ID,
        BUDGET_GROUP_ID
      INTO SOB_ID,BGP_ID
      FROM
        PSB_CONSTRAINT_SETS_V
      WHERE CONSTRAINT_SET_ID = P_SET_ID;
      SELECT
        SHORT_NAME
      INTO CP_BGP
      FROM
        PSB_BUDGET_GROUPS
      WHERE BUDGET_GROUP_ID = BGP_ID;
      SELECT
        NAME
      INTO CP_SOB
      FROM
        GL_SETS_OF_BOOKS
      WHERE SET_OF_BOOKS_ID = SOB_ID;
    END IF;
    FND_MESSAGE.SET_NAME('PSB'
                        ,'PSB_NO_DATA_FOUND');
    CP_NLS_NO_DATA_EXISTS := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME('PSB'
                        ,'PSB_END_OF_REPORT');
    CP_NLS_END_OF_REPORT := FND_MESSAGE.GET;
    RETURN (TRUE);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION M_SET_GRPFRFORMATTRIGGER(CS_REC_COUNT IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    IF (CS_REC_COUNT > 0) THEN
      RETURN (TRUE);
    ELSE
      RETURN (FALSE);
    END IF;
    RETURN (TRUE);
  END M_SET_GRPFRFORMATTRIGGER;

  FUNCTION M_1FORMATTRIGGER(CS_REC_COUNT IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    IF (CS_REC_COUNT = 0) THEN
      RETURN (TRUE);
    ELSE
      RETURN (FALSE);
    END IF;
    RETURN (TRUE);
  END M_1FORMATTRIGGER;

  FUNCTION F_2FORMATTRIGGER(CS_REC_COUNT IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    RETURN (CS_REC_COUNT > 0);
    RETURN (TRUE);
  END F_2FORMATTRIGGER;

  FUNCTION F_1FORMATTRIGGER(CS_REC_COUNT IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    RETURN (CS_REC_COUNT = 0);
    RETURN (TRUE);
  END F_1FORMATTRIGGER;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION BETWEENPAGE RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BETWEENPAGE;

  FUNCTION P_CONC_REQUEST_ID_P RETURN NUMBER IS
  BEGIN
    RETURN P_CONC_REQUEST_ID;
  END P_CONC_REQUEST_ID_P;

  FUNCTION CP_NLS_NO_DATA_EXISTS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NLS_NO_DATA_EXISTS;
  END CP_NLS_NO_DATA_EXISTS_P;

  FUNCTION CP_NLS_END_OF_REPORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NLS_END_OF_REPORT;
  END CP_NLS_END_OF_REPORT_P;

  FUNCTION CP_SOB_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SOB;
  END CP_SOB_P;

  FUNCTION CP_BGP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BGP;
  END CP_BGP_P;

  FUNCTION CP_SET_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SET;
  END CP_SET_P;

END PSB_PSBRPCON_XMLP_PKG;






/
