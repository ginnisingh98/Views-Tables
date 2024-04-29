--------------------------------------------------------
--  DDL for Package Body QA_QLTCHARR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_QLTCHARR_XMLP_PKG" AS
/* $Header: QLTCHARRB.pls 120.0 2007/12/24 10:32:55 krreddy noship $ */
  FUNCTION C_DEFAULT_VALUE_NUMFORMULA(DATATYPE_NUM IN NUMBER
                                     ,DEFAULT_VALUE IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF (DATATYPE_NUM = 2) THEN
      RETURN (TO_NUMBER(DEFAULT_VALUE
                      ,'9999999999999999.999999'));
    ELSE
      RETURN (2);
    END IF;
    RETURN NULL;
  END C_DEFAULT_VALUE_NUMFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF P_ELEMENT IS NOT NULL THEN
      SELECT
        NAME
      INTO P_ELEMENT
      FROM
        QA_CHARS
      WHERE CHAR_ID = P_ELEMENT;
      P_ELEMENT_LIMITER := 'and qcv.Name = ''' || P_ELEMENT || '''';
    END IF;
    IF P_ENABLED = 1 THEN
      P_ENABLED_LIMITER := 'and qcv.ENABLED_FLAG = 1';
    END IF;
    IF P_ENABLED IS NOT NULL THEN
      SELECT
        MEANING
      INTO P_ENABLED_MEANING
      FROM
        MFG_LOOKUPS
      WHERE LOOKUP_TYPE = 'SYS_YES_NO'
        AND LOOKUP_CODE = P_ENABLED;
    END IF;
    IF P_ELEMENT_TYPE IS NOT NULL THEN
      P_ELEMENT_TYPE_LIMITER := 'and qcv.char_type_code = ''' || P_ELEMENT_TYPE || '''';
      SELECT
        MEANING
      INTO P_ELEMENT_TYPE_MEANING
      FROM
        FND_COMMON_LOOKUPS
      WHERE LOOKUP_TYPE = 'ELEMENT_TYPE'
        AND LOOKUP_CODE = P_ELEMENT_TYPE;
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
   apf boolean;
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    apf := AFTERPFORM;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION BETWEENPAGE RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BETWEENPAGE;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

END QA_QLTCHARR_XMLP_PKG;


/