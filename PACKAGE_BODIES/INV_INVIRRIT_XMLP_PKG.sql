--------------------------------------------------------
--  DDL for Package Body INV_INVIRRIT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVIRRIT_XMLP_PKG" AS
/* $Header: INVIRRITB.pls 120.1 2007/12/25 10:30:21 dwkrishn noship $ */
  FUNCTION C_RPT_TITLEFORMULA(C_RELATION_NAME IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(C_RELATION_NAME)*/NULL;
    RETURN (C_RELATION_NAME || ' Items ');
  END C_RPT_TITLEFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'FAILED SRWINIT IN BEFORE REPORT TRIGGER')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(2
                   ,'ITEM FLEX1 SELECT FAILED IN BEFORE REPORT TRIGGER')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(3
                   ,'ITEM FLEX2 SELECT FAILED IN BEFORE REPORT TRIGGER')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(4
                   ,'CATG FLEX SELECT FAILED IN BEFORE REPORT TRIGGER')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(5
                   ,'CATG FLEX2 SELECT FAILED IN BEFORE REPORT TRIGGER')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(6
                   ,'ITEM FLEX1 WHERE FAILED IN BEFORE REPORT TRIGGER')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(7
                   ,'CATG FLEX WHERE FAILED IN BEFORE REPORT TRIGGER')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION C_ITEM_LABELFORMULA(C_RELATION_NAME IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(C_RELATION_NAME)*/NULL;
    IF NVL(LENGTH(C_RELATION_NAME)
       ,0) < 26 THEN
      RETURN (C_RELATION_NAME || ' Item');
    ELSE
      RETURN (SUBSTR(C_RELATION_NAME
                   ,1
                   ,25) || ' Item');
    END IF;
    RETURN NULL;
  END C_ITEM_LABELFORMULA;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_RECIPROCAL_VALUEFORMULA(RECIPROCAL_FLAG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(RECIPROCAL_FLAG)*/NULL;
    IF RECIPROCAL_FLAG = 'Y' THEN
      RETURN ('Yes');
    ELSE
      RETURN ('No');
    END IF;
    RETURN NULL;
  END C_RECIPROCAL_VALUEFORMULA;

  FUNCTION C_ICG_DESC_1FORMULA(ITEM_ID1 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      AA VARCHAR2(240);
      PROFILE_VAL VARCHAR2(240);
    BEGIN
      AA := NULL;
      PROFILE_VAL := NULL;
      IF (P_DESC_TYPE_FLAG = 2) THEN
        FND_PROFILE.GET('USE_NAME_ICG_DESC'
                       ,PROFILE_VAL);
        IF (PROFILE_VAL = 'Y' OR (PROFILE_VAL IS NULL)) THEN
          AA := INVICGDS.INV_FN_GET_ICG_DESC(ITEM_ID1
                                            ,30
                                            ,'Y'
                                            ,P_SEGMENT_DELIMITER
                                            ,'Y'
                                            ,'Y');
        ELSE
          AA := INVICGDS.INV_FN_GET_ICG_DESC(ITEM_ID1
                                            ,30
                                            ,'N'
                                            ,P_SEGMENT_DELIMITER
                                            ,'Y'
                                            ,'Y');
        END IF;
      END IF;
      RETURN (AA);
    END;
    RETURN NULL;
  END C_ICG_DESC_1FORMULA;

  FUNCTION C_ICG_DESC_2FORMULA(ITEM_ID2 IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      AA VARCHAR2(240);
      PROFILE_VAL VARCHAR2(240);
    BEGIN
      AA := NULL;
      PROFILE_VAL := NULL;
      IF (P_DESC_TYPE_FLAG = 2) THEN
        FND_PROFILE.GET('USE_NAME_ICG_DESC'
                       ,PROFILE_VAL);
        IF (PROFILE_VAL = 'Y' OR (PROFILE_VAL IS NULL)) THEN
          AA := INVICGDS.INV_FN_GET_ICG_DESC(ITEM_ID2
                                            ,30
                                            ,'Y'
                                            ,P_SEGMENT_DELIMITER
                                            ,'Y'
                                            ,'Y');
        ELSE
          AA := INVICGDS.INV_FN_GET_ICG_DESC(ITEM_ID2
                                            ,30
                                            ,'N'
                                            ,P_SEGMENT_DELIMITER
                                            ,'Y'
                                            ,'Y');
        END IF;
      END IF;
      RETURN (AA);
    END;
    RETURN NULL;
  END C_ICG_DESC_2FORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

END INV_INVIRRIT_XMLP_PKG;


/
