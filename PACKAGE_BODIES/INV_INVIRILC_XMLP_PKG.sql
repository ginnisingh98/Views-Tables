--------------------------------------------------------
--  DDL for Package Body INV_INVIRILC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVIRILC_XMLP_PKG" AS
/* $Header: INVIRILCB.pls 120.2 2008/01/08 06:36:36 dwkrishn noship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
      RETURN (TRUE);
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(10
                   ,'Srwexit failure after rpt trig')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION WEIGHT_CONV_RATE(MOH_ITEM_ID IN NUMBER
                           ,MSI_UOM_CODE IN VARCHAR2
                           ,MIL_WEIGHT_UOM IN VARCHAR2) RETURN NUMBER IS
    CONV_RATE NUMBER;
    CLASS_RATE NUMBER;
    ITEM_ID NUMBER;
    FROM_CLASS_RATE NUMBER;
    TO_CLASS_RATE NUMBER;
    TO_RATE NUMBER;
    FROM_RATE NUMBER;
    TO_UOM_FLAG NUMBER;
    FROM_CLASS VARCHAR2(10);
    TO_CLASS VARCHAR2(10);
    FROM_CODE VARCHAR2(3);
    TO_CODE VARCHAR2(3);
    CONV_MSG VARCHAR2(1);
  BEGIN
    ITEM_ID := MOH_ITEM_ID;
    FROM_CODE := MSI_UOM_CODE;
    TO_CODE := MIL_WEIGHT_UOM;
    CONV_MSG := '';
    CONV_RATE := 1;
    TO_CLASS_RATE := NULL;
    FROM_CLASS_RATE := NULL;
    FROM_CLASS := 0;
    TO_CLASS := 0;
    CLASS_RATE := 1;
    IF FROM_CODE = TO_CODE THEN
      GOTO end_conv;
    END IF;
    BEGIN
      SELECT
        F.CONVERSION_RATE,
        F.UOM_CLASS,
        T.CONVERSION_RATE,
        T.UOM_CLASS
      INTO FROM_RATE,FROM_CLASS,TO_RATE,TO_CLASS
      FROM
        MTL_UOM_CONVERSIONS F,
        MTL_UOM_CONVERSIONS T
      WHERE F.INVENTORY_ITEM_ID IN ( ITEM_ID , 0 )
        AND F.UOM_CODE = FROM_CODE
        AND T.INVENTORY_ITEM_ID IN ( ITEM_ID , 0 )
        AND T.UOM_CODE = TO_CODE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        CONV_RATE := -1;
      WHEN OTHERS THEN
        CONV_RATE := -2;
    END;
    IF CONV_RATE < 0 THEN
      GOTO end_conv;
    END IF;
    IF FROM_CLASS = TO_CLASS THEN
      GOTO calc_conv_rate_1;
    END IF;
    BEGIN
      SELECT
        DECODE(TO_UOM_CLASS
              ,TO_CLASS
              ,1
              ,2),
        CONVERSION_RATE
      INTO TO_UOM_FLAG,CLASS_RATE
      FROM
        MTL_UOM_CLASS_CONVERSIONS
      WHERE INVENTORY_ITEM_ID = ITEM_ID
        AND TO_UOM_CLASS IN ( FROM_CLASS , TO_CLASS )
        AND FROM_UOM_CLASS IN ( FROM_CLASS , TO_CLASS )
        AND FROM_UOM_CLASS <> TO_UOM_CLASS;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        CONV_RATE := -1;
      WHEN OTHERS THEN
        CONV_RATE := -2;
    END;
    IF CONV_RATE < 0 THEN
      GOTO end_conv;
    END IF;
    IF TO_UOM_FLAG = 0 THEN
      GOTO get_class_conv_2;
    END IF;
    IF TO_UOM_FLAG = 2 THEN
      GOTO end_conv;
    END IF;
    IF CLASS_RATE = 0 THEN
      CONV_RATE := -3;
    END IF;
    CLASS_RATE := 1 / CLASS_RATE;
    GOTO calc_conv_rate_1;
    <<GET_CLASS_CONV_2>>BEGIN
      SELECT
        F.CONVERSION_RATE,
        T.CONVERSION_RATE
      INTO FROM_CLASS_RATE,TO_CLASS_RATE
      FROM
        MTL_UOM_CLASS_CONVERSIONS F,
        MTL_UOM_CLASS_CONVERSIONS T
      WHERE F.INVENTORY_ITEM_ID = ITEM_ID
        AND T.INVENTORY_ITEM_ID = ITEM_ID
        AND F.TO_UOM_CLASS = FROM_CLASS
        AND T.TO_UOM_CLASS = TO_CLASS;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        CONV_RATE := -1;
      WHEN OTHERS THEN
        CONV_RATE := -2;
    END;
    IF CONV_RATE < 0 THEN
      GOTO end_conv;
    END IF;
    IF TO_CLASS_RATE = 0 THEN
      CONV_RATE := -3;
      GOTO end_conv;
    END IF;
    CLASS_RATE := FROM_CLASS_RATE / TO_CLASS_RATE;
    GOTO calc_conv_rate_1;
    <<CALC_CONV_RATE_1>>IF TO_RATE = 0 THEN
      CONV_RATE := -3;
      GOTO end_conv;
    END IF;
    CONV_RATE := FROM_RATE * CLASS_RATE;
    CONV_RATE := CONV_RATE / TO_RATE;
    GOTO end_conv;
    <<END_CONV>>RETURN (CONV_RATE);
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      CONV_RATE := -4;
      RETURN (CONV_RATE);
    WHEN OTHERS THEN
      CONV_RATE := -5;
      RETURN (CONV_RATE);
  END WEIGHT_CONV_RATE;

  FUNCTION DSPLY_WT_CNV_RATE(C_WEIGHT_CONV_RATE IN NUMBER) RETURN CHARACTER IS
    CONV_RATE NUMBER;
    CONV_RATE_DSPLY VARCHAR2(80);
  BEGIN
    CONV_RATE := C_WEIGHT_CONV_RATE;
    BEGIN
      IF CONV_RATE = -1 THEN
        SELECT
          MEANING
        INTO CONV_RATE_DSPLY
        FROM
          MFG_LOOKUPS
        WHERE LOOKUP_TYPE = 'INV_LOC_QTY_RPT_MSGS'
          AND LOOKUP_CODE = 1;
      END IF;
      IF CONV_RATE = -2 THEN
        SELECT
          MEANING
        INTO CONV_RATE_DSPLY
        FROM
          MFG_LOOKUPS
        WHERE LOOKUP_TYPE = 'INV_LOC_QTY_RPT_MSGS'
          AND LOOKUP_CODE = 2;
      END IF;
      IF CONV_RATE < -2 THEN
        SELECT
          MEANING
        INTO CONV_RATE_DSPLY
        FROM
          MFG_LOOKUPS
        WHERE LOOKUP_TYPE = 'INV_LOC_QTY_RPT_MSGS'
          AND LOOKUP_CODE = 3;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(90
                   ,'ERROR in fetching data from MFG_LOOKUPS table')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    IF CONV_RATE > -1 THEN
      CONV_RATE_DSPLY := TO_CHAR(ROUND(CONV_RATE
                                      ,6));
    END IF;
    RETURN (CONV_RATE_DSPLY);
  END DSPLY_WT_CNV_RATE;

  FUNCTION VOL_CONV_RATE(MOH_ITEM_ID IN NUMBER
                        ,MSI_UOM_CODE IN VARCHAR2
                        ,MIL_VOL_UOM IN VARCHAR2) RETURN NUMBER IS
    CONV_RATE NUMBER;
    CLASS_RATE NUMBER;
    ITEM_ID NUMBER;
    FROM_CLASS_RATE NUMBER;
    TO_CLASS_RATE NUMBER;
    TO_RATE NUMBER;
    FROM_RATE NUMBER;
    TO_UOM_FLAG NUMBER;
    FROM_CLASS VARCHAR2(10);
    TO_CLASS VARCHAR2(10);
    FROM_CODE VARCHAR2(3);
    TO_CODE VARCHAR2(3);
    CONV_MSG VARCHAR2(1);
  BEGIN
    ITEM_ID := MOH_ITEM_ID;
    FROM_CODE := MSI_UOM_CODE;
    TO_CODE := MIL_VOL_UOM;
    CONV_MSG := '';
    CONV_RATE := 1;
    TO_CLASS_RATE := NULL;
    FROM_CLASS_RATE := NULL;
    FROM_CLASS := 0;
    TO_CLASS := 0;
    CLASS_RATE := 1;
    IF FROM_CODE = TO_CODE THEN
      GOTO end_conv;
    END IF;
    BEGIN
      SELECT
        F.CONVERSION_RATE,
        F.UOM_CLASS,
        T.CONVERSION_RATE,
        T.UOM_CLASS
      INTO FROM_RATE,FROM_CLASS,TO_RATE,TO_CLASS
      FROM
        MTL_UOM_CONVERSIONS F,
        MTL_UOM_CONVERSIONS T
      WHERE F.INVENTORY_ITEM_ID IN ( ITEM_ID , 0 )
        AND F.UOM_CODE = FROM_CODE
        AND T.INVENTORY_ITEM_ID IN ( ITEM_ID , 0 )
        AND T.UOM_CODE = TO_CODE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        CONV_RATE := -1;
      WHEN OTHERS THEN
        CONV_RATE := -2;
    END;
    IF CONV_RATE < 0 THEN
      GOTO end_conv;
    END IF;
    IF FROM_CLASS = TO_CLASS THEN
      GOTO calc_conv_rate_1;
    END IF;
    BEGIN
      SELECT
        DECODE(TO_UOM_CLASS
              ,TO_CLASS
              ,1
              ,2),
        CONVERSION_RATE
      INTO TO_UOM_FLAG,CLASS_RATE
      FROM
        MTL_UOM_CLASS_CONVERSIONS
      WHERE INVENTORY_ITEM_ID = ITEM_ID
        AND TO_UOM_CLASS IN ( FROM_CLASS , TO_CLASS )
        AND FROM_UOM_CLASS IN ( FROM_CLASS , TO_CLASS )
        AND FROM_UOM_CLASS <> TO_UOM_CLASS;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        CONV_RATE := -1;
      WHEN OTHERS THEN
        CONV_RATE := -2;
    END;
    IF CONV_RATE < 0 THEN
      GOTO end_conv;
    END IF;
    IF TO_UOM_FLAG = 0 THEN
      GOTO get_class_conv_2;
    END IF;
    IF TO_UOM_FLAG = 2 THEN
      GOTO end_conv;
    END IF;
    IF CLASS_RATE = 0 THEN
      CONV_RATE := -3;
    END IF;
    CLASS_RATE := 1 / CLASS_RATE;
    GOTO calc_conv_rate_1;
    <<GET_CLASS_CONV_2>>BEGIN
      SELECT
        F.CONVERSION_RATE,
        T.CONVERSION_RATE
      INTO FROM_CLASS_RATE,TO_CLASS_RATE
      FROM
        MTL_UOM_CLASS_CONVERSIONS F,
        MTL_UOM_CLASS_CONVERSIONS T
      WHERE F.INVENTORY_ITEM_ID = ITEM_ID
        AND T.INVENTORY_ITEM_ID = ITEM_ID
        AND F.TO_UOM_CLASS = FROM_CLASS
        AND T.TO_UOM_CLASS = TO_CLASS;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        CONV_RATE := -1;
      WHEN OTHERS THEN
        CONV_RATE := -2;
    END;
    IF CONV_RATE < 0 THEN
      GOTO end_conv;
    END IF;
    IF TO_CLASS_RATE = 0 THEN
      CONV_RATE := -3;
      GOTO end_conv;
    END IF;
    CLASS_RATE := FROM_CLASS_RATE / TO_CLASS_RATE;
    GOTO calc_conv_rate_1;
    <<CALC_CONV_RATE_1>>IF TO_RATE = 0 THEN
      CONV_RATE := -3;
      GOTO end_conv;
    END IF;
    CONV_RATE := FROM_RATE * CLASS_RATE;
    CONV_RATE := CONV_RATE / TO_RATE;
    GOTO end_conv;
    <<END_CONV>>RETURN (CONV_RATE);
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      CONV_RATE := -4;
      RETURN (CONV_RATE);
    WHEN OTHERS THEN
      CONV_RATE := -5;
      RETURN (CONV_RATE);
  END VOL_CONV_RATE;

  FUNCTION DSPLY_VOL_CNV_RATE(C_VOL_CONV_RATE IN NUMBER) RETURN CHARACTER IS
    CONV_RATE NUMBER;
    CONV_RATE_DSPLY VARCHAR2(80);
  BEGIN
    CONV_RATE := C_VOL_CONV_RATE;
    BEGIN
      IF CONV_RATE = -1 THEN
        SELECT
          MEANING
        INTO CONV_RATE_DSPLY
        FROM
          MFG_LOOKUPS
        WHERE LOOKUP_TYPE = 'INV_LOC_QTY_RPT_MSGS'
          AND LOOKUP_CODE = 1;
      END IF;
      IF CONV_RATE = -2 THEN
        SELECT
          MEANING
        INTO CONV_RATE_DSPLY
        FROM
          MFG_LOOKUPS
        WHERE LOOKUP_TYPE = 'INV_LOC_QTY_RPT_MSGS'
          AND LOOKUP_CODE = 2;
      END IF;
      IF CONV_RATE < -2 THEN
        SELECT
          MEANING
        INTO CONV_RATE_DSPLY
        FROM
          MFG_LOOKUPS
        WHERE LOOKUP_TYPE = 'INV_LOC_QTY_RPT_MSGS'
          AND LOOKUP_CODE = 3;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(90
                   ,'ERROR in fetching data from MFG_LOOKUPS table')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    IF CONV_RATE > -1 THEN
      CONV_RATE_DSPLY := TO_CHAR(ROUND(CONV_RATE
                                      ,6));
    END IF;
    RETURN (CONV_RATE_DSPLY);
  END DSPLY_VOL_CNV_RATE;

  FUNCTION ITEM_REV_WT_CALC(C_WEIGHT_CONV_RATE IN NUMBER
                           ,C_ITEM_REV_QTY IN NUMBER) RETURN NUMBER IS
    CONV_RATE NUMBER;
    FROM_QTY NUMBER;
    CONV_WEIGHT NUMBER;
  BEGIN
    CONV_RATE := C_WEIGHT_CONV_RATE;
    FROM_QTY := C_ITEM_REV_QTY;
    IF CONV_RATE < 0 THEN
      CONV_RATE := 0;
    END IF;
    CONV_WEIGHT := FROM_QTY * CONV_RATE;
    RETURN (CONV_WEIGHT);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(12
                 ,'Wt Calc Error')*/NULL;
      RETURN (0);
  END ITEM_REV_WT_CALC;

  FUNCTION ITEM_REV_VOL_CALC(C_VOL_CONV_RATE IN NUMBER
                            ,C_ITEM_REV_QTY IN NUMBER) RETURN NUMBER IS
    CONV_RATE NUMBER;
    FROM_QTY NUMBER;
    CONV_VOL NUMBER;
  BEGIN
    CONV_RATE := C_VOL_CONV_RATE;
    FROM_QTY := C_ITEM_REV_QTY;
    IF CONV_RATE < 0 THEN
      CONV_RATE := 0;
    END IF;
    CONV_VOL := FROM_QTY * CONV_RATE;
    RETURN (CONV_VOL);
  END ITEM_REV_VOL_CALC;

  FUNCTION LOC_PCT_MAX_WT(MIL_MAX_WEIGHT IN NUMBER
                         ,C_GROSS_WT IN NUMBER) RETURN NUMBER IS
    LOC_MAX_WT NUMBER;
    SUM_ITEM_WT NUMBER;
    PCT_MAX_WT NUMBER;
  BEGIN
    LOC_MAX_WT := MIL_MAX_WEIGHT;
    SUM_ITEM_WT := C_GROSS_WT;
    PCT_MAX_WT := 0;
    IF LOC_MAX_WT = 0 THEN
      PCT_MAX_WT := 0;
    ELSE
      PCT_MAX_WT := ROUND(((SUM_ITEM_WT / LOC_MAX_WT) * 100)
                         ,4);
    END IF;
    RETURN (PCT_MAX_WT);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (0);
  END LOC_PCT_MAX_WT;

  FUNCTION LOC_PCT_MAX_VOL(MIL_MAX_CUBIC_AREA IN NUMBER
                          ,C_GROSS_VOL IN NUMBER) RETURN NUMBER IS
    LOC_MAX_VOL NUMBER;
    SUM_ITEM_VOL NUMBER;
    PCT_MAX_VOL NUMBER;
  BEGIN
    LOC_MAX_VOL := MIL_MAX_CUBIC_AREA;
    SUM_ITEM_VOL := C_GROSS_VOL;
    PCT_MAX_VOL := 0;
    IF LOC_MAX_VOL = 0 THEN
      PCT_MAX_VOL := 0;
    ELSE
      PCT_MAX_VOL := ROUND(((SUM_ITEM_VOL / LOC_MAX_VOL) * 100)
                          ,4);
    END IF;
    RETURN (PCT_MAX_VOL);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (0);
  END LOC_PCT_MAX_VOL;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      P_ORG_ID_CHAR VARCHAR2(100) := P_ORG;
    BEGIN
      FND_PROFILE.PUT('MFG_ORGANIZATION_ID'
                     ,P_ORG_ID_CHAR);
      /*SRW.USER_EXIT('FND PUTPROFILE NAME="' || 'MFG_ORGANIZATION_ID' || '" FIELD="' || P_ORG_ID_CHAR || '"')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(020
                   ,'Failed in before report trigger, setting org profile ')*/NULL;
        RAISE;
    END;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed srwinit in before rpt trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(5
                   ,'Failed flexsql loc select in before report trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(15
                   ,'Failed flexsql loc where in before report trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(16
                   ,'Failed flexsql loc order by in before report trigger. ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(20
                   ,'Failed flexsql item select in before report trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(25
                   ,'Failed flexsql item order by in before report trigger')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION F_LOC_PROJ_TASK_NUMBER(P_LOC_FLEXDATA IN VARCHAR2
                                 ,P_LOC IN VARCHAR2) RETURN CHAR IS
    L_LOC_TEMP VARCHAR2(820);
    CNT NUMBER := 0;
    L_LOC_LEFT_STR VARCHAR2(820);
    L_LOC_RIGHT_STR VARCHAR2(820);
    L_PROJECT_ID MTL_PROJECT_V.PROJECT_ID%TYPE;
    L_TASK_ID MTL_TASK_V.TASK_ID%TYPE;
    L_PROJECT_NUMBER MTL_PROJECT_V.PROJECT_NUMBER%TYPE;
    L_TASK_NUMBER MTL_TASK_V.TASK_NUMBER%TYPE;
    L_LOC_DATA VARCHAR2(820);
    L_DELIMITER VARCHAR2(10);
  BEGIN
    BEGIN
      L_DELIMITER := FND_FLEX_EXT.GET_DELIMITER('INV'
                                               ,'MTLL'
                                               ,P_LOC_NUM);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN (P_LOC);
    END;
    L_LOC_TEMP := SUBSTR(P_LOC_FLEXDATA
                        ,1
                        ,INSTR(P_LOC_FLEXDATA
                             ,'SEGMENT19') - 1);
    IF L_LOC_TEMP IS NULL THEN
      RETURN (P_LOC);
    END IF;
    WHILE (INSTR(L_LOC_TEMP
         ,'||''') > 0) LOOP

      CNT := CNT + 1;
      L_LOC_TEMP := SUBSTR(L_LOC_TEMP
                          ,1
                          ,INSTR(L_LOC_TEMP
                               ,'||''') - 1) || SUBSTR(L_LOC_TEMP
                          ,INSTR(L_LOC_TEMP
                               ,'||''') + 5);
    END LOOP;
    IF CNT = 0 THEN
      CNT := 1;
      L_LOC_LEFT_STR := NULL;
      L_LOC_TEMP := SUBSTR(P_LOC
                          ,1
                          ,INSTR(P_LOC
                               ,L_DELIMITER
                               ,1
                               ,CNT));
    ELSE
      L_LOC_LEFT_STR := SUBSTR(P_LOC
                              ,1
                              ,INSTR(P_LOC
                                   ,L_DELIMITER
                                   ,1
                                   ,CNT));
      L_LOC_TEMP := SUBSTR(P_LOC
                          ,INSTR(P_LOC
                               ,L_DELIMITER
                               ,1
                               ,CNT) + 1);
    END IF;
    SELECT
      DECODE(INSTR(L_LOC_TEMP
                  ,L_DELIMITER)
            ,0
            ,L_LOC_TEMP
            ,SUBSTR(L_LOC_TEMP
                  ,1
                  ,INSTR(L_LOC_TEMP
                       ,L_DELIMITER) - 1)),
      DECODE(INSTR(L_LOC_TEMP
                  ,L_DELIMITER)
            ,0
            ,NULL
            ,SUBSTR(L_LOC_TEMP
                  ,INSTR(L_LOC_TEMP
                       ,L_DELIMITER)))
    INTO L_PROJECT_ID,L_LOC_RIGHT_STR
    FROM
      DUAL;
    BEGIN
      SELECT
        PROJECT_NUMBER
      INTO L_PROJECT_NUMBER
      FROM
        MTL_PROJECT_V
      WHERE PROJECT_ID = L_PROJECT_ID;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN (P_LOC);
    END;
    L_LOC_DATA := L_LOC_LEFT_STR || L_PROJECT_NUMBER || L_LOC_RIGHT_STR;
    CNT := 0;
    L_LOC_TEMP := SUBSTR(P_LOC_FLEXDATA
                        ,1
                        ,INSTR(P_LOC_FLEXDATA
                             ,'SEGMENT20') - 1);
    IF L_LOC_TEMP IS NULL THEN
      RETURN (L_LOC_DATA);
    END IF;
    WHILE (INSTR(L_LOC_TEMP
         ,'||''') > 0) LOOP

      CNT := CNT + 1;
      L_LOC_TEMP := SUBSTR(L_LOC_TEMP
                          ,1
                          ,INSTR(L_LOC_TEMP
                               ,'||''') - 1) || SUBSTR(L_LOC_TEMP
                          ,INSTR(L_LOC_TEMP
                               ,'||''') + 5);
    END LOOP;
    L_LOC_LEFT_STR := L_LOC_LEFT_STR || L_PROJECT_NUMBER || L_DELIMITER;
    L_LOC_TEMP := SUBSTR(P_LOC
                        ,INSTR(P_LOC
                             ,L_DELIMITER
                             ,1
                             ,CNT) + 1);
    SELECT
      DECODE(INSTR(L_LOC_TEMP
                  ,L_DELIMITER)
            ,0
            ,L_LOC_TEMP
            ,SUBSTR(L_LOC_TEMP
                  ,1
                  ,INSTR(L_LOC_TEMP
                       ,L_DELIMITER) - 1)),
      DECODE(INSTR(L_LOC_TEMP
                  ,L_DELIMITER)
            ,0
            ,NULL
            ,SUBSTR(L_LOC_TEMP
                  ,INSTR(L_LOC_TEMP
                       ,L_DELIMITER)))
    INTO L_TASK_ID,L_LOC_RIGHT_STR
    FROM
      DUAL;
    BEGIN
      SELECT
        TASK_NUMBER
      INTO L_TASK_NUMBER
      FROM
        MTL_TASK_V
      WHERE PROJECT_ID = L_PROJECT_ID
        AND TASK_ID = L_TASK_ID;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN (L_LOC_DATA);
    END;
    L_LOC_DATA := L_LOC_LEFT_STR || L_TASK_NUMBER || L_LOC_RIGHT_STR;
    RETURN (L_LOC_DATA);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (P_LOC);
  END F_LOC_PROJ_TASK_NUMBER;

  FUNCTION CF_LOC_HIFORMULA RETURN CHAR IS
  BEGIN
    RETURN F_LOC_PROJ_TASK_NUMBER(P_LOC_FLEXDATA
                                 ,P_LOC_HI);
  END CF_LOC_HIFORMULA;

  FUNCTION CF_LOC_LOFORMULA RETURN CHAR IS
  BEGIN
    RETURN F_LOC_PROJ_TASK_NUMBER(P_LOC_FLEXDATA
                                 ,P_LOC_LO);
  END CF_LOC_LOFORMULA;

END INV_INVIRILC_XMLP_PKG;


/
