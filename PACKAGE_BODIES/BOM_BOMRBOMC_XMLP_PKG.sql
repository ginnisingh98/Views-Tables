--------------------------------------------------------
--  DDL for Package Body BOM_BOMRBOMC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BOMRBOMC_XMLP_PKG" AS
/* $Header: BOMRBOMCB.pls 120.0 2007/12/24 09:36:52 dwkrishn noship $ */

  FUNCTION GET_REV(D3_COMPO_ORG_ID IN NUMBER
                  ,D3_COMPONENT_ITEM_ID IN NUMBER) RETURN VARCHAR2 IS
    ITM_REV VARCHAR2(3);
    ORG_ID NUMBER := D3_COMPO_ORG_ID;
    ITEM_ID NUMBER := D3_COMPONENT_ITEM_ID;
    CURSOR C1 IS
      SELECT
        REVISION
      FROM
        MTL_ITEM_REVISIONS MIR
      WHERE INVENTORY_ITEM_ID = ITEM_ID
        AND ORGANIZATION_ID = ORG_ID
        AND MIR.EFFECTIVITY_DATE <= TO_DATE(LP_REVISION_DATE
             ,'YYYY/MM/DD HH24:MI:SS')
        AND ( ( P_IMPL_FLAG = 2 )
      OR ( P_IMPL_FLAG = 1
        AND IMPLEMENTATION_DATE IS NOT NULL ) )
      ORDER BY
        EFFECTIVITY_DATE,
        REVISION;
  BEGIN
    OPEN C1;
    FETCH C1
     INTO ITM_REV;
    IF C1%NOTFOUND THEN
      CLOSE C1;
      RETURN NULL;
    END IF;
    CLOSE C1;
    RETURN ITM_REV;
  END GET_REV;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      L_ORGANIZATION_NAME VARCHAR2(240);
      L_EXPLODE_OPTION VARCHAR2(80);
      L_IMPL VARCHAR2(80);
      L_RANGE_OPTION VARCHAR2(80);
      L_SPECIFIC_ITEM VARCHAR2(81);
      L_CATEGORY_SET VARCHAR2(40);
      L_PRINT_OPTION1 VARCHAR2(80);
      L_PLAN_FACTOR VARCHAR2(80);
      L_ALT_OPTION VARCHAR2(80);
      L_ORDER_BY VARCHAR2(80);
      L_SEQ_ID NUMBER;
      L_STR VARCHAR2(2000);
      L_BOM_OR_ENG NUMBER;
      L_ERR_MSG VARCHAR2(80);
      L_ERR_CODE NUMBER;
      EXPLODER_ERROR EXCEPTION;
      LOOP_ERROR EXCEPTION;
      TABLE_NAME VARCHAR2(20);
      ITEM_ID_NULL EXCEPTION;
    BEGIN
    LP_REVISION_DATE:=P_REVISION_DATE;

      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      TABLE_NAME := 'P_DEBUG';
      IF (P_RANGE_OPTION_TYPE = 1) AND (P_ITEM_ID IS NULL) THEN
        FND_MESSAGE.SET_NAME('null'
                            ,'MFG_REQUIRED_VALUE');
        FND_MESSAGE.SET_TOKEN('ENTITY'
                             ,'specific item');
        P_MSG_BUF := FND_MESSAGE.GET;
        /*SRW.MESSAGE('999'
                   ,P_MSG_BUF)*/NULL;
        RAISE ITEM_ID_NULL;
      END IF;
      IF P_PRINT_OPTION1_FLAG = 2 THEN
        /*SRW.SET_MAXROW('Q_ELEMENT'
                      ,0)*/NULL;
      END IF;
      TABLE_NAME := 'ORG_DEF';
      SELECT
        O.ORGANIZATION_NAME
      INTO L_ORGANIZATION_NAME
      FROM
        ORG_ORGANIZATION_DEFINITIONS O
      WHERE O.ORGANIZATION_ID = P_ORGANIZATION_ID;
      TABLE_NAME := 'MTL_ITEM_FLEXFIELDS';
      IF (P_RANGE_OPTION_TYPE = 1) THEN
        SELECT
          ITEM_NUMBER
        INTO L_SPECIFIC_ITEM
        FROM
          MTL_ITEM_FLEXFIELDS
        WHERE ITEM_ID = P_ITEM_ID
          AND ORGANIZATION_ID = P_ORGANIZATION_ID;
        P_SPECIFIC_ITEM := L_SPECIFIC_ITEM;
      END IF;
      TABLE_NAME := 'MTL_CATEGORY_SETS';
      IF P_CATEGORY_SET_ID > 0 THEN
        SELECT
          CATEGORY_SET_NAME
        INTO L_CATEGORY_SET
        FROM
          MTL_CATEGORY_SETS
        WHERE CATEGORY_SET_ID = P_CATEGORY_SET_ID;
        P_CATEGORY_SET := L_CATEGORY_SET;
      END IF;
      TABLE_NAME := 'MFG_LOOKUPS1';
      SELECT
        SUBSTR(L1.MEANING
              ,1
              ,40),
        SUBSTR(L2.MEANING
              ,1
              ,4),
        SUBSTR(L3.MEANING
              ,1
              ,40),
        SUBSTR(L4.MEANING
              ,1
              ,4),
        SUBSTR(L5.MEANING
              ,1
              ,4)
      INTO L_EXPLODE_OPTION,L_IMPL,L_RANGE_OPTION,L_PRINT_OPTION1,L_PLAN_FACTOR
      FROM
        MFG_LOOKUPS L1,
        MFG_LOOKUPS L2,
        MFG_LOOKUPS L3,
        MFG_LOOKUPS L4,
        MFG_LOOKUPS L5
      WHERE L1.LOOKUP_TYPE = 'BOM_INQUIRY_DISPLAY_TYPE'
        AND L1.LOOKUP_CODE = P_EXPLODE_OPTION_TYPE
        AND L2.LOOKUP_TYPE = 'SYS_YES_NO'
        AND L2.LOOKUP_CODE = P_IMPL_FLAG
        AND L3.LOOKUP_TYPE = 'BOM_SELECTION_TYPE'
        AND L3.LOOKUP_CODE = P_RANGE_OPTION_TYPE
        AND L4.LOOKUP_TYPE = 'SYS_YES_NO'
        AND L4.LOOKUP_CODE = P_PRINT_OPTION1_FLAG
        AND L5.LOOKUP_TYPE = 'SYS_YES_NO'
        AND L5.LOOKUP_CODE = P_PLAN_FACTOR_FLAG;
      TABLE_NAME := 'MFG_LOOKUPS2';
      SELECT
        SUBSTR(L1.MEANING
              ,1
              ,40),
        SUBSTR(L2.MEANING
              ,1
              ,40)
      INTO L_ALT_OPTION,L_ORDER_BY
      FROM
        MFG_LOOKUPS L1,
        MFG_LOOKUPS L2
      WHERE L1.LOOKUP_TYPE = 'MCG_AUTOLOAD_OPTION'
        AND L1.LOOKUP_CODE = P_ALT_OPTION_TYPE
        AND L2.LOOKUP_TYPE = 'BOM_BILL_SORT_ORDER_TYPE'
        AND L2.LOOKUP_CODE = P_ORDER_BY_TYPE;
      P_ORGANIZATION_NAME := L_ORGANIZATION_NAME;
      P_EXPLODE_OPTION := L_EXPLODE_OPTION;
      P_IMPL := L_IMPL;
      P_RANGE_OPTION := L_RANGE_OPTION;
      P_PRINT_OPTION1 := L_PRINT_OPTION1;
      P_ALT_OPTION := L_ALT_OPTION;
      P_ORDER_BY := L_ORDER_BY;
      P_PLAN_FACTOR := L_PLAN_FACTOR;
      IF P_BOM_OR_ENG = 'BOM' THEN
        L_BOM_OR_ENG := 1;
      ELSE
        L_BOM_OR_ENG := 2;
      END IF;
      TABLE_NAME := 'DUAL_SEQUENCE';
      SELECT
        BOM_LISTS_S.NEXTVAL
      INTO L_SEQ_ID
      FROM
        DUAL;
      P_SEQUENCE_ID := L_SEQ_ID;
      TABLE_NAME := 'ITEM FLEX RANGE';
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      IF P_RANGE_OPTION_TYPE = 2 THEN
        IF (P_ITEM_FROM IS NOT NULL) THEN
          IF (P_ITEM_TO IS NOT NULL) THEN
            NULL;
          ELSE
            NULL;
          END IF;
        ELSE
          IF (P_ITEM_TO IS NOT NULL) THEN
            NULL;
          END IF;
        END IF;
        TABLE_NAME := 'CATEGORY FLEX RANGE';
        IF (P_CATEGORY_FROM IS NOT NULL) THEN
          IF (P_CATEGORY_TO IS NOT NULL) THEN
            NULL;
          ELSE
            NULL;
          END IF;
        ELSE
          IF (P_CATEGORY_TO IS NOT NULL) THEN
            NULL;
          END IF;
        END IF;
      END IF;
      TABLE_NAME := 'BUILD SQL';
      L_STR := 'INSERT INTO BOM_LISTS (SEQUENCE_ID, ASSEMBLY_ITEM_ID,
                                               ALTERNATE_DESIGNATOR) ';
      IF P_RANGE_OPTION_TYPE = 1 THEN
        L_STR := L_STR || '  SELECT DISTINCT ' || TO_CHAR(L_SEQ_ID) || ',
                                 ' || TO_CHAR(P_ITEM_ID) || ',
                                 bbom.alternate_bom_designator
                          FROM   bom_bill_of_materials bbom
                          WHERE  bbom.organization_id = ' || TO_CHAR(P_ORGANIZATION_ID) || '
                          AND    bbom.assembly_item_id = ' || TO_CHAR(P_ITEM_ID);
      ELSE
        L_STR := L_STR || '  SELECT DISTINCT ' || TO_CHAR(L_SEQ_ID) || ',
                                 msi.inventory_item_id,
                                 bbom.alternate_bom_designator
                          FROM   mtl_item_categories mic,
                                 mtl_system_items msi,
                                 mtl_categories mc,
                                 bom_bill_of_materials bbom
                          WHERE  ' || P_ASS_BETWEEN || '
                          AND    msi.inventory_item_id = mic.inventory_item_id
                          AND    msi.organization_id =
                                 ' || TO_CHAR(P_ORGANIZATION_ID) || '
                          AND    mic.organization_id =
                                 ' || TO_CHAR(P_ORGANIZATION_ID) || '
                          AND    mic.category_set_id =
                                 ' || TO_CHAR(P_CATEGORY_SET_ID) || '
                          AND    mic.category_id = mc.category_id
                          AND    mc.structure_id =
                                 ' || TO_CHAR(P_CATEGORY_STRUCTURE_ID) || '
                          AND    ' || P_CAT_BETWEEN || '
                          AND    msi.inventory_item_id = bbom.assembly_item_id
                          AND    msi.organization_id = bbom.organization_id
                   	 AND 	msi.bom_enabled_flag = ''Y''';
      END IF;
      L_STR := L_STR || '  AND    (  (' || TO_CHAR(P_ALT_OPTION_TYPE) || ' = 1)
                                OR
                                  (' || TO_CHAR(P_ALT_OPTION_TYPE) || ' = 2
                                   AND bbom.alternate_bom_designator IS NULL)
                                OR
                                  (' || TO_CHAR(P_ALT_OPTION_TYPE) || ' = 3
                                   AND NVL(bbom.alternate_bom_designator,''XXX'')=
                                       NVL(''' || P_ALTERNATE_DESG || ''', ''XXX''))
                               )
                         AND   (  (''' || P_BOM_OR_ENG || ''' = ''BOM''
                                   AND bbom.assembly_type = 1)
                                OR
                                  (''' || P_BOM_OR_ENG || ''' = ''ENG'')
                               )';
      TABLE_NAME := 'EXECUTE SQL';
      EXECUTE IMMEDIATE
        L_STR;
      TABLE_NAME := 'CALL EXPLODER';
      IF LP_REVISION_DATE IS NULL THEN
        LP_REVISION_DATE := TO_CHAR(SYSDATE
                                  ,'YYYY/MM/DD HH24:MI:SS');
      END IF;
      EXPLOSION_REPORT(ORG_ID => P_ORGANIZATION_ID
                      ,ORDER_BY => P_ORDER_BY_TYPE
                      ,LIST_ID => L_SEQ_ID
                      ,GRP_ID => P_GROUP_ID
                      ,SESSION_ID => -1
                      ,LEVELS_TO_EXPLODE => P_EXPLOSION_LEVEL
                      ,BOM_OR_ENG => L_BOM_OR_ENG
                      ,IMPL_FLAG => P_IMPL_FLAG
                      ,EXPLODE_OPTION => P_EXPLODE_OPTION_TYPE
                      ,MODULE => 2
                      ,CST_TYPE_ID => -1
                      ,STD_COMP_FLAG => -1
                      ,EXPL_QTY => P_EXPLOSION_QUANTITY
                      ,REPORT_OPTION => -1
                      ,REQ_ID => P_CONC_REQUEST_ID
                      ,LOCK_FLAG => -1
                      ,ROLLUP_OPTION => -1
                      ,ALT_RTG_DESG => ''
                      ,ALT_DESG => P_ALTERNATE_DESG
                      ,REV_DATE => LP_REVISION_DATE
                      ,ERR_MSG => L_ERR_MSG
                      ,ERROR_CODE => L_ERR_CODE
                      ,VERIFY_FLAG => 0
                      ,CST_RLP_ID => 0
                      ,PLAN_FACTOR_FLAG => P_PLAN_FACTOR_FLAG
                      ,INCL_LT_FLAG => 2);
      TABLE_NAME := 'EXPLODE COMPLETE';
      IF L_ERR_CODE = 9999 THEN
        RAISE LOOP_ERROR;
      END IF;
      IF L_ERR_CODE < 0 THEN
        RAISE EXPLODER_ERROR;
      END IF;
      RETURN (TRUE);
    EXCEPTION
    /*  WHEN SRW.DO_SQL_FAILURE OTHERS THEN
        SRW.MESSAGE('2000'
                   ,TABLE_NAME || SQLERRM)NULL;
        RETURN (FALSE);*/
      WHEN EXPLODER_ERROR THEN
        /*SRW.MESSAGE('2001'
                   ,L_ERR_MSG)*/NULL;
        RETURN (FALSE);
      WHEN LOOP_ERROR THEN
        P_ERR_MSG := L_ERR_MSG;
        FND_MESSAGE.SET_NAME('null'
                            ,':P_ERR_MSG');
        P_MSG_BUF := FND_MESSAGE.GET;
        /*SRW.MESSAGE('9999'
                   ,P_MSG_BUF)*/NULL;
        RETURN (FALSE);
      WHEN ITEM_ID_NULL THEN
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      WHEN NO_DATA_FOUND THEN
        /*SRW.MESSAGE('2003'
                   ,TABLE_NAME || SQLERRM)*/NULL;

        RETURN (TRUE);
      WHEN OTHERS THEN
        /*SRW.MESSAGE('2000'
                   ,TABLE_NAME || SQLERRM)*/NULL;

        RETURN (FALSE);
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION GET_ELE_DESC(M_BOM_ITEM_TYPE IN NUMBER
                       ,D2_ELEMENT_NAME IN VARCHAR2
                       ,M_ITEM_CATALOG_GROUP_ID IN NUMBER) RETURN VARCHAR2 IS
    L_DESC VARCHAR2(240);
    ORG_ID NUMBER := P_ORGANIZATION_ID;
    L_ITEM_TYPE NUMBER := M_BOM_ITEM_TYPE;
    L_ELEMENT_NAME VARCHAR(30) := D2_ELEMENT_NAME;
    L_CATALOG_GROUP_ID NUMBER := M_ITEM_CATALOG_GROUP_ID;
  BEGIN
    IF L_ITEM_TYPE = 1 THEN
      SELECT
        DESCRIPTION
      INTO L_DESC
      FROM
        MTL_DESCRIPTIVE_ELEMENTS
      WHERE ITEM_CATALOG_GROUP_ID = L_CATALOG_GROUP_ID
        AND ELEMENT_NAME = L_ELEMENT_NAME;
    ELSIF L_ITEM_TYPE = 2 THEN
      SELECT
        MIN(DESCRIPTION)
      INTO L_DESC
      FROM
        MTL_DESCRIPTIVE_ELEMENTS
      WHERE ELEMENT_NAME = L_ELEMENT_NAME;
    END IF;
    RETURN (L_DESC);
  END GET_ELE_DESC;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      ROLLBACK;
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN (TRUE);
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  PROCEDURE EXPLODER_USEREXIT(VERIFY_FLAG IN NUMBER
                             ,ORG_ID IN NUMBER
                             ,ORDER_BY IN NUMBER
                             ,GRP_ID IN NUMBER
                             ,SESSION_ID IN NUMBER
                             ,LEVELS_TO_EXPLODE IN NUMBER
                             ,BOM_OR_ENG IN NUMBER
                             ,IMPL_FLAG IN NUMBER
                             ,PLAN_FACTOR_FLAG IN NUMBER
                             ,EXPLODE_OPTION IN NUMBER
                             ,MODULE IN NUMBER
                             ,CST_TYPE_ID IN NUMBER
                             ,STD_COMP_FLAG IN NUMBER
                             ,EXPL_QTY IN NUMBER
                             ,ITEM_ID IN NUMBER
                             ,ALT_DESG IN VARCHAR2
                             ,COMP_CODE IN VARCHAR2
                             ,REV_DATE IN VARCHAR2
                             ,ERR_MSG OUT NOCOPY VARCHAR2
                             ,ERROR_CODE OUT NOCOPY NUMBER) IS
  BEGIN
  /*  STPROC.INIT('begin BOMPEXPL.EXPLODER_USEREXIT(:VERIFY_FLAG,
  :ORG_ID, :ORDER_BY, :GRP_ID, :SESSION_ID, :LEVELS_TO_EXPLODE, :BOM_OR_ENG,
  :IMPL_FLAG, :PLAN_FACTOR_FLAG, :EXPLODE_OPTION, :MODULE, :CST_TYPE_ID, :STD_COMP_FLAG, :EXPL_QTY, :ITEM_ID, :ALT_DESG, :COMP_CODE, :REV_DATE, :ERR_MSG, :ERROR_CODE); end;');
    STPROC.BIND_I(VERIFY_FLAG);
    STPROC.BIND_I(ORG_ID);
    STPROC.BIND_I(ORDER_BY);
    STPROC.BIND_I(GRP_ID);
    STPROC.BIND_I(SESSION_ID);
    STPROC.BIND_I(LEVELS_TO_EXPLODE);
    STPROC.BIND_I(BOM_OR_ENG);
    STPROC.BIND_I(IMPL_FLAG);
    STPROC.BIND_I(PLAN_FACTOR_FLAG);
    STPROC.BIND_I(EXPLODE_OPTION);
    STPROC.BIND_I(MODULE);
    STPROC.BIND_I(CST_TYPE_ID);
    STPROC.BIND_I(STD_COMP_FLAG);
    STPROC.BIND_I(EXPL_QTY);
    STPROC.BIND_I(ITEM_ID);
    STPROC.BIND_I(ALT_DESG);
    STPROC.BIND_I(COMP_CODE);
    STPROC.BIND_I(REV_DATE);
    STPROC.BIND_O(ERR_MSG);
    STPROC.BIND_O(ERROR_CODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(19
                   ,ERR_MSG);
    STPROC.RETRIEVE(20
                   ,ERROR_CODE);*/null;
  END EXPLODER_USEREXIT;

  PROCEDURE EXPLOSION_REPORT(VERIFY_FLAG IN NUMBER
                            ,ORG_ID IN NUMBER
                            ,ORDER_BY IN NUMBER
                            ,LIST_ID IN NUMBER
                            ,GRP_ID IN NUMBER
                            ,SESSION_ID IN NUMBER
                            ,LEVELS_TO_EXPLODE IN NUMBER
                            ,BOM_OR_ENG IN NUMBER
                            ,IMPL_FLAG IN NUMBER
                            ,PLAN_FACTOR_FLAG IN NUMBER
                            ,INCL_LT_FLAG IN NUMBER
                            ,EXPLODE_OPTION IN NUMBER
                            ,MODULE IN NUMBER
                            ,CST_TYPE_ID IN NUMBER
                            ,STD_COMP_FLAG IN NUMBER
                            ,EXPL_QTY IN NUMBER
                            ,REPORT_OPTION IN NUMBER
                            ,REQ_ID IN NUMBER
                            ,CST_RLP_ID IN NUMBER
                            ,LOCK_FLAG IN NUMBER
                            ,ROLLUP_OPTION IN NUMBER
                            ,ALT_RTG_DESG IN VARCHAR2
                            ,ALT_DESG IN VARCHAR2
                            ,REV_DATE IN VARCHAR2
                            ,ERR_MSG OUT NOCOPY VARCHAR2
                            ,ERROR_CODE OUT NOCOPY NUMBER) IS
  BEGIN
  /*  STPROC.INIT('begin BOMPEXPL.EXPLOSION_REPORT(:VERIFY_FLAG
  , :ORG_ID, :ORDER_BY, :LIST_ID, :GRP_ID, :SESSION_ID, :LEVELS_TO_EXPLODE,
  :BOM_OR_ENG, :IMPL_FLAG, :PLAN_FACTOR_FLAG, :INCL_LT_FLAG, :EXPLODE_OPTION, :MODULE, :CST_TYPE_ID,
  :STD_COMP_FLAG, :EXPL_QTY, :REPORT_OPTION, :REQ_ID, :CST_RLP_ID, :LOCK_FLAG, :ROLLUP_OPTION, :ALT_RTG_DESG,
  :ALT_DESG, :REV_DATE, :ERR_MSG, :ERROR_CODE); end;');
    STPROC.BIND_I(VERIFY_FLAG);
    STPROC.BIND_I(ORG_ID);
    STPROC.BIND_I(ORDER_BY);
    STPROC.BIND_I(LIST_ID);
    STPROC.BIND_I(GRP_ID);
    STPROC.BIND_I(SESSION_ID);
    STPROC.BIND_I(LEVELS_TO_EXPLODE);
    STPROC.BIND_I(BOM_OR_ENG);
    STPROC.BIND_I(IMPL_FLAG);
    STPROC.BIND_I(PLAN_FACTOR_FLAG);
    STPROC.BIND_I(INCL_LT_FLAG);
    STPROC.BIND_I(EXPLODE_OPTION);
    STPROC.BIND_I(MODULE);
    STPROC.BIND_I(CST_TYPE_ID);
    STPROC.BIND_I(STD_COMP_FLAG);
    STPROC.BIND_I(EXPL_QTY);
    STPROC.BIND_I(REPORT_OPTION);
    STPROC.BIND_I(REQ_ID);
    STPROC.BIND_I(CST_RLP_ID);
    STPROC.BIND_I(LOCK_FLAG);
    STPROC.BIND_I(ROLLUP_OPTION);
    STPROC.BIND_I(ALT_RTG_DESG);
    STPROC.BIND_I(ALT_DESG);
    STPROC.BIND_I(REV_DATE);
    STPROC.BIND_O(ERR_MSG);
    STPROC.BIND_O(ERROR_CODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(25
                   ,ERR_MSG);
    STPROC.RETRIEVE(26
                   ,ERROR_CODE);*/
		   BOMPEXPL.EXPLOSION_REPORT(VERIFY_FLAG,ORG_ID,ORDER_BY,LIST_ID,GRP_ID,SESSION_ID,
		   LEVELS_TO_EXPLODE,BOM_OR_ENG,IMPL_FLAG,PLAN_FACTOR_FLAG,INCL_LT_FLAG,
		   EXPLODE_OPTION,MODULE,CST_TYPE_ID,STD_COMP_FLAG,EXPL_QTY,REPORT_OPTION,REQ_ID,
		   CST_RLP_ID,LOCK_FLAG,ROLLUP_OPTION,ALT_RTG_DESG,ALT_DESG,REV_DATE,ERR_MSG,ERROR_CODE);
  END EXPLOSION_REPORT;

  PROCEDURE EXPLODERS(VERIFY_FLAG IN NUMBER
                     ,ONLINE_FLAG IN NUMBER
                     ,ORG_ID IN NUMBER
                     ,ORDER_BY IN NUMBER
                     ,GRP_ID IN NUMBER
                     ,SESSION_ID IN NUMBER
                     ,L_LEVELS_TO_EXPLODE IN NUMBER
                     ,BOM_OR_ENG IN NUMBER
                     ,IMPL_FLAG IN NUMBER
                     ,PLAN_FACTOR_FLAG IN NUMBER
                     ,INCL_LT_FLAG IN NUMBER
                     ,L_EXPLODE_OPTION IN NUMBER
                     ,MODULE IN NUMBER
                     ,CST_TYPE_ID IN NUMBER
                     ,STD_COMP_FLAG IN NUMBER
                     ,REV_DATE IN VARCHAR2
                     ,ERR_MSG OUT NOCOPY VARCHAR2
                     ,ERROR_CODE OUT NOCOPY NUMBER) IS
  BEGIN
/*    STPROC.INIT('begin BOMPEXPL.EXPLODERS(:VERIFY_FLAG, :ONLINE_FLAG, :ORG_ID,
:ORDER_BY, :GRP_ID, :SESSION_ID, :L_LEVELS_TO_EXPLODE, :BOM_OR_ENG,
:IMPL_FLAG, :PLAN_FACTOR_FLAG, :INCL_LT_FLAG, :L_EXPLODE_OPTION, :MODULE, :CST_TYPE_ID, :STD_COMP_FLAG, :REV_DATE, :ERR_MSG, :ERROR_CODE); end;');
    STPROC.BIND_I(VERIFY_FLAG);
    STPROC.BIND_I(ONLINE_FLAG);
    STPROC.BIND_I(ORG_ID);
    STPROC.BIND_I(ORDER_BY);
    STPROC.BIND_I(GRP_ID);
    STPROC.BIND_I(SESSION_ID);
    STPROC.BIND_I(L_LEVELS_TO_EXPLODE);
    STPROC.BIND_I(BOM_OR_ENG);
    STPROC.BIND_I(IMPL_FLAG);
    STPROC.BIND_I(PLAN_FACTOR_FLAG);
    STPROC.BIND_I(INCL_LT_FLAG);
    STPROC.BIND_I(L_EXPLODE_OPTION);
    STPROC.BIND_I(MODULE);
    STPROC.BIND_I(CST_TYPE_ID);
    STPROC.BIND_I(STD_COMP_FLAG);
    STPROC.BIND_I(REV_DATE);
    STPROC.BIND_O(ERR_MSG);
    STPROC.BIND_O(ERROR_CODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(17
                   ,ERR_MSG);
    STPROC.RETRIEVE(18
                   ,ERROR_CODE);*/null;
  END EXPLODERS;

  PROCEDURE LOOPSTR2MSG(GRP_ID IN NUMBER
                       ,VERIFY_MSG OUT NOCOPY VARCHAR2) IS
  BEGIN
 /*   STPROC.INIT('begin BOMPEXPL.LOOPSTR2MSG(:GRP_ID, :VERIFY_MSG); end;');
    STPROC.BIND_I(GRP_ID);
    STPROC.BIND_O(VERIFY_MSG);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,VERIFY_MSG);*/null;
  END LOOPSTR2MSG;
 FUNCTION g_filter RETURN boolean is
  BEGIN
  IF P_PRINT_OPTION1_FLAG = 2 THEN
    RETURN(FALSE);
  ELSE
     RETURN(TRUE);
  end if;
END g_filter;
END BOM_BOMRBOMC_XMLP_PKG;


/
