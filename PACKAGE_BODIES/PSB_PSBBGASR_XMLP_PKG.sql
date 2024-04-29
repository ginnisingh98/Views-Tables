--------------------------------------------------------
--  DDL for Package Body PSB_PSBBGASR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_PSBBGASR_XMLP_PKG" AS
/* $Header: PSBBGASRB.pls 120.1 2008/02/22 07:58:25 vijranga noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    IF P_SET_OF_BOOKS_ID IS NULL THEN
      FND_MESSAGE.SET_NAME('PSB'
                          ,'PSB_ALL');
      CP_SET_OF_BOOKS_NAME := FND_MESSAGE.GET;
      FND_MESSAGE.SET_NAME('PSB'
                          ,'PSB_ALL');
      CP_BUDGET_GROUP_NAME := FND_MESSAGE.GET;
    ELSE
      SELECT
        NAME
      INTO CP_SET_OF_BOOKS_NAME
      FROM
        GL_SETS_OF_BOOKS
      WHERE SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID;
      IF P_BUDGET_GROUP_ID IS NULL THEN
        FND_MESSAGE.SET_NAME('PSB'
                            ,'PSB_ALL');
        CP_BUDGET_GROUP_NAME := FND_MESSAGE.GET;
      ELSE
        SELECT
          NAME
        INTO CP_BUDGET_GROUP_NAME
        FROM
          PSB_BUDGET_GROUPS
        WHERE BUDGET_GROUP_ID = P_BUDGET_GROUP_ID;
      END IF;
    END IF;
    SELECT
      MEANING
    INTO CP_PRINT_SUBGROUPS
    FROM
      FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'YES_NO'
      AND LOOKUP_CODE = P_PRINT_SUBGROUPS_FLAG;
    FND_MESSAGE.SET_NAME('PSB'
                        ,'PSB_NO_DATA_FOUND');
    CP_NO_DATA_FOUND := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME('PSB'
                        ,'PSB_END_OF_REPORT');
    CP_END_OF_REPORT := FND_MESSAGE.GET;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_FLEXFIELD_HIGHFORMULA(COA_ID IN NUMBER
                                   ,FLEXDATA_HIGH IN VARCHAR2
                                   ,CF_FLEXFIELD_HIGH IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(COA_ID)*/NULL;
    /*SRW.REFERENCE(FLEXDATA_HIGH)*/NULL;
    /*SRW.USER_EXIT('FND FLEXRIDVAL
                                   CODE            = "GL#"
                                   NUM             = ":coa_id"
                                   APPL_SHORT_NAME = "SQLGL"
                                   DATA            = ":flexdata_high"
                                   VALUE           = ":cf_flexfield_high"
                                   DISPLAY         = "ALL"')*/NULL;
    RETURN (CF_FLEXFIELD_HIGH);
  END CF_FLEXFIELD_HIGHFORMULA;

  FUNCTION CF_FLEXFIELD_LOWFORMULA(COA_ID IN NUMBER
                                  ,FLEXDATA_LOW IN VARCHAR2
                                  ,CF_FLEXFIELD_LOW IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(COA_ID)*/NULL;
    /*SRW.REFERENCE(FLEXDATA_LOW)*/NULL;
    /*SRW.USER_EXIT('FND FLEXRIDVAL
                                   CODE            = "GL#"
                                   NUM             = ":coa_id"
                                   APPL_SHORT_NAME = "SQLGL"
                                   DATA            = ":flexdata_low"
                                   VALUE           = ":cf_flexfield_low"
                                   DISPLAY         = "ALL"')*/NULL;
    RETURN (CF_FLEXFIELD_LOW);
  END CF_FLEXFIELD_LOWFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_USER_EXIT_DUMMYFORMULA(COA_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(COA_ID)*/NULL;
    /*SRW.USER_EXIT('FND FLEXRSQL
                                    CODE = "GL#"
                                    NUM = ":coa_id"
                                    APPL_SHORT_NAME = "SQLGL"
                                    OUTPUT = ":CP_FLEXDATA"
                                    TABLEALIAS = "lines" ')*/NULL;
    RETURN (COA_ID);
  END CF_USER_EXIT_DUMMYFORMULA;

  FUNCTION BETWEENPAGE RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BETWEENPAGE;

  FUNCTION CP_FLEXDATA_HIGH_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_FLEXDATA_HIGH;
  END CP_FLEXDATA_HIGH_P;

  FUNCTION CP_FLEXDATA_LOW_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_FLEXDATA_LOW;
  END CP_FLEXDATA_LOW_P;

  FUNCTION P_STRUCT_NUM_P RETURN NUMBER IS
  BEGIN
    RETURN P_STRUCT_NUM;
  END P_STRUCT_NUM_P;

  FUNCTION CP_SET_OF_BOOKS_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SET_OF_BOOKS_NAME;
  END CP_SET_OF_BOOKS_NAME_P;

  FUNCTION CP_BUDGET_GROUP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BUDGET_GROUP_NAME;
  END CP_BUDGET_GROUP_NAME_P;

  FUNCTION CP_PRINT_SUBGROUPS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PRINT_SUBGROUPS;
  END CP_PRINT_SUBGROUPS_P;

  FUNCTION CP_NO_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NO_DATA_FOUND;
  END CP_NO_DATA_FOUND_P;

  FUNCTION CP_END_OF_REPORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_END_OF_REPORT;
  END CP_END_OF_REPORT_P;

END PSB_PSBBGASR_XMLP_PKG;







/
