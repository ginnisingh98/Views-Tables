--------------------------------------------------------
--  DDL for Package Body BOM_CSTRCTCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTRCTCR_XMLP_PKG" AS
/* $Header: CSTRCTCRB.pls 120.0 2007/12/24 09:53:15 dwkrishn noship $ */
  FUNCTION TOT_PER_CHANGEFORMULA(TOT_ITEM_COST1 IN NUMBER
                                ,TOT_ITEM_COST2 IN NUMBER
                                ,TOT_DIFFERENCE IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF TOT_ITEM_COST1 = 0 THEN
      IF TOT_ITEM_COST2 = 0 THEN
        RETURN 0;
      ELSE
        RETURN 100;
      END IF;
    ELSE
      RETURN (ROUND(TOT_DIFFERENCE / TOT_ITEM_COST1 * 100
                  ,2));
    END IF;
    RETURN NULL;
  END TOT_PER_CHANGEFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
CURSOR c1 IS
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
    DECLARE
      SQL_STMT_NUM VARCHAR2(5);
      CREATE_WHERE VARCHAR2(875);
    BEGIN
    QTY_PRECISION:= bom_common_xmlp_pkg.get_precision(P_EXT_PRECISION);
      SQL_STMT_NUM := '0: ';
      P_TABLE_ORDER := ' mtl_system_items_vl msi, mtl_item_categories mic, mtl_categories_kfv mc, cst_item_costs cic, cst_detail_cost_view cdcv';
      SQL_STMT_NUM := '1: ';
      IF P_VIEW_COST <> 1 THEN
        FND_MESSAGE.SET_NAME('null'
                            ,'null');
        /*SRW.USER_EXIT('FND MESSAGE_DISPLAY')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      END IF;
      SQL_STMT_NUM := '2: ';
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      SQL_STMT_NUM := '3: ';
      SQL_STMT_NUM := '4: ';
      SQL_STMT_NUM := '5: ';
      IF P_FROM_ITEM IS NULL AND P_TO_ITEM IS NULL THEN
        P_WHERE_ITEM := '1 = 1';
        P_TABLE_ORDER := 'mtl_categories_kfv mc, mtl_item_categories mic, cst_item_costs cic, mtl_system_items_vl msi, cst_detail_cost_view cdcv';
      ELSE
        P_TABLE_ORDER := ' cst_detail_cost_view cdcv, cst_item_costs cic, mtl_categories_kfv mc, mtl_item_categories mic,  mtl_system_items_vl msi';
        --CREATE_WHERE := ' msi.inventory_item_id in (select inventory_item_id from mtl_system_items MSLT where ' || P_WHERE_ITEM || ' and MSLT.organization_id = ' || TO_CHAR(ORG_ID) || ' )';
	CREATE_WHERE_ITEM1 := ' msi.inventory_item_id in (select inventory_item_id from mtl_system_items MSLT where ';
	CREATE_WHERE_ITEM2 := ' and MSLT.organization_id = ' || TO_CHAR(ORG_ID) || ' )';
        --P_WHERE_ITEM := CREATE_WHERE;
      END IF;
      CREATE_WHERE := NULL;
      SQL_STMT_NUM := '6: ';
      IF P_FROM_CAT IS NULL AND P_TO_CAT IS NULL THEN
        P_WHERE_CAT := '1 = 1';
      ELSE
        --CREATE_WHERE := 'mc.category_id in (select category_id from mtl_categories MCT where ' || P_WHERE_CAT || 'and MCT.structure_id =  ' || TO_CHAR(P_STRUCT_NUM) || '  )';
        --P_WHERE_CAT := CREATE_WHERE;
        P_TABLE_ORDER := 'cst_detail_cost_view cdcv, cst_item_costs cic, mtl_system_items_vl msi, mtl_item_categories mic, mtl_categories_kfv mc';
	CREATE_WHERE_CAT1 := 'mc.category_id in (select category_id from mtl_categories MCT where ';
	CREATE_WHERE_CAT2 := 'and MCT.structure_id =  ' || TO_CHAR(P_STRUCT_NUM) || '  )';
      END IF;

      SQL_STMT_NUM := '7: ';
      IF COMPARISON_OPT = 2 THEN
        COLUMN1 := 'cdcv.resource_code';
      ELSIF COMPARISON_OPT = 3 THEN
        COLUMN1 := 'cdcv.activity';
      ELSIF COMPARISON_OPT = 4 THEN
        COLUMN1 := 'cdcv.operation_seq_num';
      ELSIF COMPARISON_OPT = 5 THEN
        COLUMN1 := 'cdcv.department';
      ELSIF COMPARISON_OPT = 6 THEN
        COLUMN1 := 'cdcv.cost_level';
      ELSE
        COLUMN1 := 'cdcv.cost_element';
      END IF;
      SQL_STMT_NUM := '8: ';
      SELECT
        NVL(FC.EXTENDED_PRECISION
           ,FC.PRECISION),
        NVL(FC.PRECISION
           ,0)
      INTO P_EXT_PRECISION,P_PRECISION
      FROM
        ORG_ORGANIZATION_DEFINITIONS O,
        GL_SETS_OF_BOOKS GL,
        MTL_PARAMETERS P,
        FND_CURRENCIES FC
      WHERE O.ORGANIZATION_ID = ORG_ID
        AND P.ORGANIZATION_ID = ORG_ID
        AND O.SET_OF_BOOKS_ID = GL.SET_OF_BOOKS_ID
        AND FC.CURRENCY_CODE = GL.CURRENCY_CODE;
--Added
OPEN C1;
FETCH C1 INTO PID_FLEX_NUM;
CLOSE C1;
--Added till this

      RETURN (TRUE);
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(999
                   ,SQL_STMT_NUM || SQLERRM)*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    /*SRW.MESSAGE(100
               ,TO_CHAR(SYSDATE
                      ,'"Before report trigger completed at "Dy Mon DD HH:MI:SS YYYY'))*/NULL;
   RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    /*SRW.MESSAGE(100
               ,TO_CHAR(SYSDATE
                      ,'"After report trigger completed  at "Dy Mon DD HH:MI:SS YYYY'))*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION DISP_CURRENCYFORMULA(CURR_CODE_SAVED IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN ('(' || CURR_CODE_SAVED || ')');
  END DISP_CURRENCYFORMULA;

  FUNCTION MIN_PERC_DIFF_SAVEDFORMULA(EXT_PRECISION_SAVED IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF (MIN_PERC_DIFF IS NULL) THEN
      RETURN (0);
    ELSE
      RETURN (ROUND(MIN_PERC_DIFF
                  ,EXT_PRECISION_SAVED));
    END IF;
    RETURN NULL;
  END MIN_PERC_DIFF_SAVEDFORMULA;

  FUNCTION MIN_AMT_DIFF_SAVEDFORMULA(EXT_PRECISION_SAVED IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF (MIN_AMT_DIFF IS NULL) THEN
      RETURN (0);
    ELSE
      RETURN (ROUND(MIN_AMT_DIFF
                  ,EXT_PRECISION_SAVED));
    END IF;
    RETURN NULL;
  END MIN_AMT_DIFF_SAVEDFORMULA;

  FUNCTION MIN_UNIT_COST_SAVEDFORMULA(EXT_PRECISION_SAVED IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF (MIN_UNIT_COST IS NULL) THEN
      RETURN (0);
    ELSE
      RETURN (ROUND(MIN_UNIT_COST
                  ,EXT_PRECISION_SAVED));
    END IF;
    RETURN NULL;
  END MIN_UNIT_COST_SAVEDFORMULA;

  FUNCTION COLUMN1_TITLE_HDRFORMULA(COLUMN1_TITLE_SAVED IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (COLUMN1_TITLE_SAVED);
  END COLUMN1_TITLE_HDRFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

END BOM_CSTRCTCR_XMLP_PKG;


/
