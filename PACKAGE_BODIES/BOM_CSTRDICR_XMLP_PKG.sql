--------------------------------------------------------
--  DDL for Package Body BOM_CSTRDICR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTRDICR_XMLP_PKG" AS
/* $Header: CSTRDICRB.pls 120.0 2007/12/24 09:54:33 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  L_NUM number;
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    BEGIN
        SELECT fifst.id_flex_num
        into L_NUM
        FROM fnd_id_flex_structures fifst
        WHERE fifst.application_id = 401
          AND fifst.id_flex_code = 'MSTK'
          AND fifst.enabled_flag = 'Y'
          AND fifst.freeze_flex_definition_flag = 'Y'
          AND rownum =1
          ORDER BY fifst.id_flex_num;
        L_ITEM_FLEX_NUM := L_NUM;
    END;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.MESSAGE(100
               ,TO_CHAR(SYSDATE
                      ,'"Before report trigger started   at "Dy Mon DD HH:MI:SS YYYY'))*/NULL;
    IF P_VIEW_COST <> 1 THEN
      FND_MESSAGE.SET_NAME('null'
                          ,'null');
      /*SRW.USER_EXIT('FND MESSAGE_DISPLAY')*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END IF;
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
    /*SRW.MESSAGE(100
               ,TO_CHAR(SYSDATE
                      ,'"Before report trigger completed at "Dy Mon DD HH:MI:SS YYYY'))*/NULL;
    FORMAT_MASK := BOM_common_xmlp_pkg.get_precision(P_QTY_PRECISION);
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
                     ,C_FLEXPAD_CAT IN VARCHAR2
                     ,UOM IN VARCHAR2) RETURN CHARACTER IS
    TEMP VARCHAR2(2000);
  BEGIN
    /*SRW.REFERENCE(C_FLEXPAD_ITEM)*/NULL;
    /*SRW.REFERENCE(C_FLEXPAD_CAT)*/NULL;
    /*SRW.REFERENCE(UOM)*/NULL;
    IF REPORT_SORT_OPT = 1 THEN
      TEMP := C_FLEXPAD_ITEM || C_FLEXPAD_CAT || RPAD(UOM
                  ,3);
    ELSE
      TEMP := C_FLEXPAD_CAT || C_FLEXPAD_ITEM || RPAD(UOM
                  ,3);
    END IF;
    RETURN (TEMP);
  END ORDER_FUNC;
  FUNCTION C_FLEXPAD_ITEMFORMULA(C_ITEM_NUM_FLEX IN VARCHAR2
                                ,C_FLEXPAD_ITEM IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(C_ITEM_NUM_FLEX)*/NULL;
    RETURN (C_FLEXPAD_ITEM);
  END C_FLEXPAD_ITEMFORMULA;
  FUNCTION C_FLEXPAD_CATFORMULA(C_CAT_FLEX IN VARCHAR2
                               ,C_FLEXPAD_CAT IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(C_CAT_FLEX)*/NULL;
    RETURN (C_FLEXPAD_CAT);
  END C_FLEXPAD_CATFORMULA;
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;
END BOM_CSTRDICR_XMLP_PKG;


/
