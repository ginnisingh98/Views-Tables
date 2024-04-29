--------------------------------------------------------
--  DDL for Package Body BOM_CSTRELCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTRELCR_XMLP_PKG" AS
/* $Header: CSTRELCRB.pls 120.0 2007/12/24 09:58:23 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    cursor c1 is
    SELECT fifst.id_flex_num
    FROM fnd_id_flex_structures fifst
    WHERE fifst.application_id = 401
    AND fifst.id_flex_code = 'MSTK'
    AND fifst.enabled_flag = 'Y'
    AND fifst.freeze_flex_definition_flag = 'Y'
    ORDER BY fifst.id_flex_num;


  BEGIN
    /*SRW.MESSAGE(100
               ,TO_CHAR(SYSDATE
                      ,'"Before report trigger started   at "Dy Mon DD HH:MI:SS YYYY'))*/NULL;
    P_EXCHANGE_RATE := FND_NUMBER.CANONICAL_TO_NUMBER(P_EXCHANGE_RATE_CHAR);
    IF P_VIEW_COST <> 1 THEN
      FND_MESSAGE.SET_NAME('null'
                          ,'null');
      /*SRW.USER_EXIT('FND MESSAGE_DISPLAY')*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END IF;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.USER_EXIT('FND FLEXSQL CODE="MSTK" SET=":ORG_ID"
                          APPL_SHORT_NAME="INV" OUTPUT=":P_FLEXDATA_ITEM"
                          MODE="SELECT"  DISPLAY="ALL"
                          TABLEALIAS="MSI"')*/NULL;
    IF P_FROM_ITEM IS NULL AND P_TO_ITEM IS NULL THEN
      P_WHERE_ITEM := '1 = 1';
    ELSE
      NULL;
    END IF;
    IF P_FROM_CAT IS NULL AND P_TO_CAT IS NULL THEN
      P_WHERE_CAT := '1 = 1';
    ELSE
      NULL;
    END IF;
    IF ZERO_COST_ONLY = 2 THEN
      WHERE_ZERO := '1 = 1';
    ELSE
      WHERE_ZERO := 'nvl(item_cost, 0) = 0';
    END IF;
    /*SRW.MESSAGE(100
               ,TO_CHAR(SYSDATE
                      ,'"Before report trigger completed at "Dy Mon DD HH:MI:SS YYYY'))*/NULL;
    open c1;
    fetch c1 into pid_flex_num;
    close c1;

    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    /*SRW.MESSAGE(100
               ,TO_CHAR(SYSDATE
                      ,'"After report trigger completed at "Dy Mon DD HH:MI:SS YYYY'))*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION DISP_CURRENCYFORMULA(CURR_CODE_SAVED IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN ('(' || CURR_CODE_SAVED || ')');
  END DISP_CURRENCYFORMULA;

  FUNCTION ORDER_FUNC(C_FLEXPAD_ITEM IN VARCHAR2
                     ,C_FLEXPAD_CAT IN VARCHAR2) RETURN CHARACTER IS
    TEMP VARCHAR2(2000);
  BEGIN
    /*SRW.REFERENCE(C_FLEXPAD_ITEM)*/NULL;
    /*SRW.REFERENCE(C_FLEXPAD_CAT)*/NULL;
    IF REPORT_SORT_OPT = 1 THEN
      TEMP := C_FLEXPAD_ITEM;
    ELSE
      TEMP := C_FLEXPAD_CAT;
    END IF;
    RETURN (TEMP);
  END ORDER_FUNC;

  FUNCTION C_FLEXPAD_ITEMFORMULA(C_FLEXFIELD_ITEM IN VARCHAR2
                                ,C_FLEXPAD_ITEM IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(C_FLEXFIELD_ITEM)*/NULL;
    RETURN (C_FLEXPAD_ITEM);
  END C_FLEXPAD_ITEMFORMULA;

  FUNCTION C_FLEXPAD_CATFORMULA(C_FLEXFIELD_CAT IN VARCHAR2
                               ,C_FLEXPAD_CAT IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(C_FLEXFIELD_CAT)*/NULL;
    RETURN (C_FLEXPAD_CAT);
  END C_FLEXPAD_CATFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

END BOM_CSTRELCR_XMLP_PKG;


/
