--------------------------------------------------------
--  DDL for Package Body INV_INVTRHAN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVTRHAN_XMLP_PKG" AS
/* $Header: INVTRHANB.pls 120.2 2008/01/08 06:48:54 dwkrishn noship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in SRWEXIT')*/NULL;
    END;
    BEGIN
      EXECUTE IMMEDIATE
        'drop view ' || P_VIEW;
    EXCEPTION
      WHEN /*SRW.DO_SQL_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(2
                   ,'Do sql failed to drop view at end of report.')*/NULL;
    END;
    RETURN (TRUE);
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION C_TARGET_QTY_VALFORMULA(C_COST_TYPE IN NUMBER
                                  ,ASS_INV IN NUMBER
                                  ,TARGET_QTY IN NUMBER
                                  ,CUR_QTY_VAL_OLD IN NUMBER
                                  ,CUR_QTY_VAL IN NUMBER
                                  ,SOURCE_TYPE1 IN NUMBER
                                  ,SOURCE_TYPE2 IN NUMBER
                                  ,SOURCE_TYPE3 IN NUMBER
                                  ,SOURCE_TYPE4 IN NUMBER
                                  ,SOURCE_TYPE5 IN NUMBER
                                  ,OTHER IN NUMBER
                                  ,ITEM_ID IN NUMBER
                                  ,SUBINVENTORY IN VARCHAR2
                                  ,C_STD_PREC IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      MY_ORG_ID NUMBER;
      MY_ITEM_ID NUMBER;
      MY_SUB VARCHAR2(40);
      MY_MIN_TRX_ID NUMBER;
      MY_HIS_DATE VARCHAR2(40);
      MY_CUR_QTY_VAL NUMBER;
      MY_TARGET_QTY NUMBER;
      MY_HIS_VALUE NUMBER;
    BEGIN
      IF ((C_COST_TYPE = 1) AND (P_SORT_ID = 1) AND (P_SELECTION = 2) AND (ASS_INV <> 1)) THEN
        RETURN (0);
      END IF;
      IF ((C_COST_TYPE = 2) AND (TARGET_QTY = 0)) THEN
        RETURN (0);
      END IF;
      IF (P_WMS_ENABLED = 'Y' OR P_PJM_ENABLED = 'Y') AND P_SELECTION in (2,3) THEN
        RETURN CUR_QTY_VAL_OLD;
      END IF;
      IF C_COST_TYPE = 1 OR P_SELECTION = 1 THEN
        RETURN (CUR_QTY_VAL - SOURCE_TYPE1 - SOURCE_TYPE2 - SOURCE_TYPE3 - SOURCE_TYPE4 - SOURCE_TYPE5 - OTHER);
      END IF;
      MY_ORG_ID := P_ORG_ID;
      MY_ITEM_ID := ITEM_ID;
      MY_SUB := SUBINVENTORY;
      MY_HIS_DATE := P_hist_date_1;
      MY_MIN_TRX_ID := 0;
      MY_TARGET_QTY := TARGET_QTY;
      SELECT
        NVL(MIN(TRANSACTION_ID)
           ,0)
      INTO MY_MIN_TRX_ID
      FROM
        MTL_MATERIAL_TRANSACTIONS
      WHERE ORGANIZATION_ID = MY_ORG_ID
        AND INVENTORY_ITEM_ID = MY_ITEM_ID
        AND ( SUBINVENTORY_CODE in (
        SELECT
          SECONDARY_INVENTORY_NAME
        FROM
          MTL_SECONDARY_INVENTORIES
        WHERE ORGANIZATION_ID = MY_ORG_ID
          AND ASSET_INVENTORY <> 2 )
      OR SUBINVENTORY_CODE is null )
        AND TRANSACTION_DATE >= TO_DATE(MY_HIS_DATE
             ,'DD-MON-RRRR') + 1
        AND TRANSACTION_ACTION_ID <> 30;
      IF (MY_MIN_TRX_ID = 0) THEN
        RETURN (CUR_QTY_VAL);
      ELSE
        SELECT
          PRIOR_COST
        INTO MY_HIS_VALUE
        FROM
          MTL_MATERIAL_TRANSACTIONS
        WHERE ORGANIZATION_ID = MY_ORG_ID
          AND INVENTORY_ITEM_ID = MY_ITEM_ID
          AND TRANSACTION_ID = MY_MIN_TRX_ID;
        RETURN (ROUND(MY_TARGET_QTY * MY_HIS_VALUE
                    ,C_STD_PREC));
      END IF;
    END;
    RETURN NULL;
  END C_TARGET_QTY_VALFORMULA;
  FUNCTION C_FROM_CATFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (',mtl_item_categories mic, mtl_categories mc');
  END C_FROM_CATFORMULA;
  FUNCTION C_WHERE_CATFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN ('and msi.inventory_item_id = mic.inventory_item_id
           and mic.category_id = mc.category_id
           and mic.organization_id = ' || TO_CHAR(P_ORG_ID) || '
           and mic.category_set_id = ' || TO_CHAR(P_CAT_SET_ID));
  END C_WHERE_CATFORMULA;
  FUNCTION C_SOURCE_TYPE1FORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      SOURCE_TYPE_ID NUMBER;
      NAME VARCHAR2(40);
    BEGIN
      SOURCE_TYPE_ID := P_STYPE1_1;
      SELECT
        SUBSTR(TRANSACTION_SOURCE_TYPE_NAME
              ,0
              ,14)
      INTO NAME
      FROM
        MTL_TXN_SOURCE_TYPES
      WHERE TRANSACTION_SOURCE_TYPE_ID = SOURCE_TYPE_ID;
      RETURN (NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('Error');
      WHEN OTHERS THEN
        RETURN ('Error');
    END;
    RETURN NULL;
  END C_SOURCE_TYPE1FORMULA;
  FUNCTION C_SOURCE_TYPE2FORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      SOURCE_TYPE_ID NUMBER;
      NAME VARCHAR2(40);
    BEGIN
      SOURCE_TYPE_ID := P_STYPE2_1;
      SELECT
        SUBSTR(TRANSACTION_SOURCE_TYPE_NAME
              ,0
              ,14)
      INTO NAME
      FROM
        MTL_TXN_SOURCE_TYPES
      WHERE TRANSACTION_SOURCE_TYPE_ID = SOURCE_TYPE_ID;
      RETURN (NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('Error');
      WHEN OTHERS THEN
        RETURN ('Error');
    END;
    RETURN NULL;
  END C_SOURCE_TYPE2FORMULA;
  FUNCTION C_SOURCE_TYPE3FORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      SOURCE_TYPE_ID NUMBER;
      NAME VARCHAR2(40);
    BEGIN
      SOURCE_TYPE_ID := P_STYPE3_1;
      SELECT
        SUBSTR(TRANSACTION_SOURCE_TYPE_NAME
              ,0
              ,13)
      INTO NAME
      FROM
        MTL_TXN_SOURCE_TYPES
      WHERE TRANSACTION_SOURCE_TYPE_ID = SOURCE_TYPE_ID;
      RETURN (NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('Error');
      WHEN OTHERS THEN
        RETURN ('Error');
    END;
    RETURN NULL;
  END C_SOURCE_TYPE3FORMULA;
  FUNCTION C_SOURCE_TYPE4FORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      SOURCE_TYPE_ID NUMBER;
      NAME VARCHAR2(40);
    BEGIN
      SOURCE_TYPE_ID := P_STYPE4_1;
      SELECT
        SUBSTR(TRANSACTION_SOURCE_TYPE_NAME
              ,0
              ,13)
      INTO NAME
      FROM
        MTL_TXN_SOURCE_TYPES
      WHERE TRANSACTION_SOURCE_TYPE_ID = SOURCE_TYPE_ID;
      RETURN (NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('Error');
      WHEN OTHERS THEN
        RETURN ('Error');
    END;
    RETURN NULL;
  END C_SOURCE_TYPE4FORMULA;
  FUNCTION C_SOURCE_TYPE5FORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      SOURCE_TYPE_ID NUMBER;
      NAME VARCHAR2(40);
    BEGIN
      SOURCE_TYPE_ID := P_STYPE5;
      SELECT
        SUBSTR(TRANSACTION_SOURCE_TYPE_NAME
              ,0
              ,11)
      INTO NAME
      FROM
        MTL_TXN_SOURCE_TYPES
      WHERE TRANSACTION_SOURCE_TYPE_ID = SOURCE_TYPE_ID;
      RETURN (NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('Error');
      WHEN OTHERS THEN
        RETURN ('Error');
    END;
    RETURN NULL;
  END C_SOURCE_TYPE5FORMULA;
   FUNCTION C_WHERE_SUBINVFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUBINV_LO IS NOT NULL AND P_SUBINV_HI IS NOT NULL THEN
      RETURN ('and v.subinv between ''' || P_SUBINV_LO || ''' and
                        ''' || P_SUBINV_HI || '''');
    ELSE
      IF P_SUBINV_LO IS NOT NULL AND P_SUBINV_HI IS NULL THEN
        RETURN ('and v.subinv >= ''' || P_SUBINV_LO || '''');
      ELSE
        IF P_SUBINV_LO IS NULL AND P_SUBINV_HI IS NOT NULL THEN
          RETURN ('and v.subinv <= ''' || P_SUBINV_HI || '''');
        ELSE
          RETURN ('   ');
        END IF;
      END IF;
    END IF;
    RETURN '   ';
  END C_WHERE_SUBINVFORMULA;
  FUNCTION C_CAT_SET_NAMEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      CAT_SET_ID NUMBER;
      CAT_SET_NAME VARCHAR2(30);
    BEGIN
      IF P_CAT_SET_ID IS NULL THEN
        RETURN ('');
      ELSE
        CAT_SET_ID := P_CAT_SET_ID;
        SELECT
          CATEGORY_SET_NAME
        INTO CAT_SET_NAME
        FROM
          MTL_CATEGORY_SETS
        WHERE CATEGORY_SET_ID = CAT_SET_ID;
        RETURN (CAT_SET_NAME);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('');
      WHEN OTHERS THEN
        /*SRW.MESSAGE(10
                   ,'Error:No category set selected')*/NULL;
    END;
    RETURN NULL;
  END C_CAT_SET_NAMEFORMULA;
  FUNCTION C_CHANGE_VALFORMULA(C_TARGET_QTY_VAL IN NUMBER
                              ,CUR_QTY_VAL IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(C_TARGET_QTY_VAL)*/NULL;
    /*SRW.REFERENCE(CUR_QTY_VAL)*/NULL;
    RETURN (CUR_QTY_VAL - C_TARGET_QTY_VAL);
  END C_CHANGE_VALFORMULA;
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
 BEGIN
      P_Stype1_1 := P_Stype1;
      P_Stype2_1 := P_Stype2;
      P_Stype3_1 := P_Stype3;
      P_Stype4_1 := P_Stype4;
      --P_hist_date_1 := P_hist_date;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in SRWINIT')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(2
                   ,'Failed in MSTK')*/NULL;
        RAISE;
    END;
    BEGIN
      IF P_ITEM_LO IS NOT NULL OR P_ITEM_HI IS NOT NULL THEN
        NULL;
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(3
                   ,'Failed in MSTK')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(3
                   ,'Failed in MSTK/order by')*/NULL;
        RAISE;
    END;
    BEGIN
      IF P_SORT_ID = 3 THEN
        NULL;
      ELSE
        P_CAT_FLEX := '''X''';
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(4
                   ,'Failed in MCAT')*/NULL;
        RAISE;
    END;
    BEGIN
      IF P_CAT_LO IS NOT NULL OR P_CAT_HI IS NOT NULL THEN
        NULL;
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(5
                   ,'Failed in MCAT')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION C_CHANGE_QTYFORMULA(CUR_QTY IN NUMBER
                              ,TARGET_QTY IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (CUR_QTY - TARGET_QTY);
  END C_CHANGE_QTYFORMULA;
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    /*SRW.MESSAGE(1
               ,'p_wms_enabled : ' || P_WMS_ENABLED)*/NULL;
    /*SRW.MESSAGE(1
               ,'p_pjm_enabled : ' || P_PJM_ENABLED)*/NULL;
    /*SRW.MESSAGE(1
               ,'p_wms_pjm_enabled : ' || P_WMS_PJM_ENABLED)*/NULL;
    DECLARE
      SELECTION VARCHAR2(20);
      STYPE1 VARCHAR2(20);
      STYPE2 VARCHAR2(20);
      STYPE3 VARCHAR2(20);
      STYPE4 VARCHAR2(20);
      STYPE5 VARCHAR2(20);
      VAR_ORG VARCHAR2(20);
      HIST_DATE VARCHAR2(40);
      L_HIST_DATE DATE;
      VIEW_NAME VARCHAR2(30);
      CONSIGNED VARCHAR2(20);
      L_FCN_CURRENCY VARCHAR2(15);
      L_STMT_NUM NUMBER;
      L_MSG_COUNT NUMBER;
      L_MSG_DATA VARCHAR2(8000);
      L_RETURN_STATUS VARCHAR2(1);
      L_CST_INV_VAL EXCEPTION;
      L_VALUATION_DATE DATE;
    BEGIN
     P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
       P_hist_date_1 := TO_CHAR(TO_DATE(P_HIST_DATE,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-RRRR');
    P_VIEW_PUTVALIDTRIGGER_1 := P_VIEW_PUTVALIDTRIGGER;
      SELECTION := TO_CHAR(P_SELECTION);
      STYPE1 := TO_CHAR(P_STYPE1_1);
      STYPE2 := TO_CHAR(P_STYPE2_1);
      STYPE3 := TO_CHAR(P_STYPE3_1);
      STYPE4 := TO_CHAR(P_STYPE4_1);
      STYPE5 := TO_CHAR(P_STYPE5);
      VAR_ORG := TO_CHAR(P_ORG_ID);
      HIST_DATE := P_hist_date_1;
      L_HIST_DATE := TO_DATE(P_hist_date_1
                            ,'DD-MON-RRRR') + 1;
     -- VIEW_NAME := P_VIEW;
      VIEW_NAME := P_VIEW_PUTVALIDTRIGGER_1 ;
      CONSIGNED := TO_CHAR(P_CONSIGNED);
      /*SRW.MESSAGE(1
                 ,'Debugging for Bug 4361479')*/NULL;
      /*SRW.MESSAGE(1
                 ,VIEW_NAME)*/NULL;
      IF P_SELECTION = 1 THEN
        EXECUTE IMMEDIATE
          'create view ' || VIEW_NAME || ' as
          select  moqd.subinventory_code       subinv,
                 moqd.inventory_item_id        item_id,
                 0                             item_cost,
                 0                            source_type1,
                 0                            source_type2,
                 0                            source_type3,
                 0                            source_type4,
                 0                            source_type5,
                 0                            other,
                 sum(primary_transaction_quantity)    cur_qty_val,
                 sum(primary_transaction_quantity)      cur_qty,
                 sum(primary_transaction_quantity)      target_qty
          from mtl_onhand_quantities_detail moqd
          where moqd.organization_id = ' || VAR_ORG || '
          and moqd.owning_tp_type = DECODE(' || CONSIGNED || ', 2, 2, moqd.owning_tp_type)
          group by moqd.subinventory_code, moqd.inventory_item_id
          UNION
          select     mmt.subinventory_code        subinv,
                     mmt.inventory_item_id        item_id,
                     0                            item_cost,
                     sum(decode(mtst.transaction_source_type_id,' || STYPE1 || ',primary_quantity))          source_type1,
                     sum(decode(mtst.transaction_source_type_id,' || STYPE2 || ',primary_quantity))          source_type2,
                     sum(decode(mtst.transaction_source_type_id,' || STYPE3 || ',primary_quantity))          source_type3,
                     sum(decode(mtst.transaction_source_type_id,' || STYPE4 || ',primary_quantity))          source_type4,
                     0      source_type5,
                     sum(decode(mtst.transaction_source_type_id,' || STYPE1 || ',0,' || STYPE2 || ',0,' || STYPE3 || ',0,' || STYPE4 || ',0,primary_quantity ))        other,
                     0      cur_qty_val,
                     0      cur_qty,
                     -sum(primary_quantity)      target_qty
          from mtl_material_transactions mmt,
          mtl_txn_source_types      mtst,
          mtl_parameters            mp
          where mmt.organization_id = ' || VAR_ORG || '
          and   mp.organization_id = ' || VAR_ORG || '
          /*and   transaction_date >= to_date(''' || HIST_DATE || ''' , ''DD-MON-RRRR'' ) + 1   --GSCC change hist_date + 1 */
          and   transaction_date >= ''' || L_HIST_DATE || '''  --GSCC change hist_date + 1
          and   NVL(mmt.owning_tp_type, 2) = DECODE(' || CONSIGNED || ', 2, 2, NVL(mmt.owning_tp_type, 2))
          and   mmt.transaction_source_type_id = mtst.transaction_source_type_id
          and   nvl(mmt.logical_transaction,2) <> 1   --added for bug 5501066
          group by mmt.subinventory_code,mmt.inventory_item_id,mp.primary_cost_method
          ';
      ELSE
        IF NVL(P_WMS_ENABLED
           ,'N') = 'N' AND NVL(P_PJM_ENABLED
           ,'N') = 'N' THEN
          EXECUTE IMMEDIATE
            'create view ' || VIEW_NAME || ' as
            select moqv.subinventory_code        subinv,
                   moqv.inventory_item_id        item_id,
                   round(moqv.item_cost,15)              item_cost,
                   0                            source_type1,
                   0                            source_type2,
                   0                            source_type3,
                   0                            source_type4,
                   0                            source_type5,
                   0                            other,
                   decode(' || SELECTION || ',1,sum(transaction_quantity),sum(transaction_quantity * NVL(moqv.item_cost,0)))                           cur_qty_val,
                   sum(transaction_quantity)                  cur_qty,
                   sum(transaction_quantity)                  target_qty
            from mtl_onhand_qty_cost_v moqv
            where moqv.organization_id = ' || VAR_ORG || '
            group by moqv.subinventory_code, moqv.inventory_item_id, moqv.item_cost
            UNION
            select mmt.subinventory_code        subinv,
                   mmt.inventory_item_id        item_id,
                   round(cst.item_cost,15)              item_cost,
                   sum(decode(mtst.transaction_source_type_id,' || STYPE1 || ',
                         decode(' || SELECTION || ',1,primary_quantity,
                           decode(mp.primary_cost_method,2,primary_quantity,
                             decode(' || STYPE1 || ',11,quantity_adjusted * (new_cost-prior_cost),13,
                               decode(mmt.transaction_action_id,24,quantity_adjusted * (new_cost-prior_cost),primary_quantity* actual_cost),
                                    primary_quantity * actual_cost
                               )
                             )
                           )
                       ,0)
                       )    source_type1,
                   sum(decode(mtst.transaction_source_type_id,' || STYPE2 || ',
                         decode(' || SELECTION || ',1,primary_quantity,
                           decode(mp.primary_cost_method,2,primary_quantity,
                             decode(' || STYPE2 || ',11,quantity_adjusted * (new_cost-prior_cost),13,
                               decode(mmt.transaction_action_id,24,quantity_adjusted * (new_cost-prior_cost),primary_quantity* actual_cost),
                                    primary_quantity * actual_cost
                               )
                             )
                           )
                       ,0)
                       )    source_type2,
                   sum(decode(mtst.transaction_source_type_id,' || STYPE3 || ',
                         decode(' || SELECTION || ',1,primary_quantity,
                           decode(mp.primary_cost_method,2,primary_quantity,
                             decode(' || STYPE3 || ',11,quantity_adjusted * (new_cost-prior_cost),13,
                               decode(mmt.transaction_action_id,24,quantity_adjusted * (new_cost-prior_cost),primary_quantity* actual_cost),
                                      primary_quantity * actual_cost
                               )
                             )
                           )
                       ,0)
                       )    source_type3,
                   sum(decode(mtst.transaction_source_type_id,' || STYPE4 || ',
                         decode(' || SELECTION || ',1,primary_quantity,
                           decode(mp.primary_cost_method,2,primary_quantity,
                             decode(mp.primary_cost_method,2,primary_quantity,
                               decode(' || STYPE4 || ',11,quantity_adjusted * (new_cost-prior_cost),13,
                                 decode(mmt.transaction_action_id,24,quantity_adjusted * (new_cost-prior_cost),primary_quantity* actual_cost),
                                    primary_quantity * actual_cost
                                 )
                               )
                             )
                           )
                       ,0)
                       )    source_type4,
                  0   source_type5,
                  sum(decode(mtst.transaction_source_type_id,' || STYPE1 || ',0,' || STYPE2 || ',0,' || STYPE3 || ',0,' || STYPE4 || ',0,
                        decode(' || SELECTION || ',1,primary_quantity,
                          decode(mp.primary_cost_method,2,primary_quantity,
                            decode(mtst.transaction_source_type_id,11,quantity_adjusted*(new_cost-prior_cost),13,
                              decode(mmt.transaction_action_id,24,quantity_adjusted * (new_cost-prior_cost),primary_quantity* actual_cost),
                                   primary_quantity * actual_cost
                              )
                            )
                          )
                        )
                      )       other,
                   0                                                   cur_qty_val,
                   0                                                   cur_qty,
                   -sum(primary_quantity)                          target_qty
            from mtl_material_transactions mmt,
                 mtl_txn_source_types      mtst,
                 mtl_parameters            mp,
                 cst_item_costs_for_gl_view cst
            where mmt.organization_id = ' || VAR_ORG || '
            and   mp.organization_id = ' || VAR_ORG || '
            and   cst.organization_id = ' || VAR_ORG || '
            and   cst.inventory_item_id = mmt.inventory_item_id
            and   transaction_date >= ''' || L_HIST_DATE || ''' -- GSCC Change hist_date + 1
            and   NVL(mmt.owning_tp_type, 2) = 2
            and   mmt.transaction_source_type_id = mtst.transaction_source_type_id
            and   nvl(mmt.logical_transaction,2) <> 1   --added for bug 5501066
            group by mmt.subinventory_code,mmt.inventory_item_id,cst.item_cost, mp.primary_cost_method
            ';
        ELSE
          BEGIN
            L_STMT_NUM := 101;
            IF P_SELECTION = 3 THEN
              /*SRW.MESSAGE(1
                         ,'Clearing the source type defaults')*/NULL;
              P_STYPE1_1 := 0;
              P_STYPE2_1 := 0;
              P_STYPE3_1 := 0;
              P_STYPE4_1 := 0;
              P_STYPE5 := 0;
            END IF;
            EXECUTE IMMEDIATE
              'create view ' || VIEW_NAME || '
                          as
                          select
                            to_char(NULL)     subinv,
                            to_number(NULL)   item_id,
                            0                 item_cost,
                            0                 source_type1,
                            0                 source_type2,
                            0                 source_type3,
                            0                 source_type4,
                            0                 source_type5,
                            0                 other,
                            0                 cur_qty_val,
                            0                 cur_qty,
                            0                 target_qty
              from DUAL
              WHERE 1=2';
            L_STMT_NUM := 102;
            CST_INVENTORY_PUB.CALCULATE_INVENTORYVALUE(P_API_VERSION => 1.0
                                                      ,P_INIT_MSG_LIST => CST_UTILITY_PUB.GET_TRUE
                                                      ,P_ORGANIZATION_ID => P_ORG_ID
                                                      ,P_ONHAND_VALUE => 1
                                                      ,P_INTRANSIT_VALUE => NULL
                                                      ,P_RECEIVING_VALUE => 0
                                                      ,P_VALUATION_DATE => L_HIST_DATE
                                                      ,P_COST_TYPE_ID => NULL
                                                      ,P_ITEM_FROM => P_ITEM_LO
                                                      ,P_ITEM_TO => P_ITEM_HI
                                                      ,P_CATEGORY_SET_ID => P_CAT_SET_ID
                                                      ,P_CATEGORY_FROM => P_CAT_LO
                                                      ,P_CATEGORY_TO => P_CAT_HI
                                                      ,P_COST_GROUP_FROM => P_CG_LO
                                                      ,P_COST_GROUP_TO => P_CG_HI
                                                      ,P_SUBINVENTORY_FROM => P_SUBINV_LO
                                                      ,P_SUBINVENTORY_TO => P_SUBINV_HI
                                                      ,P_QTY_BY_REVISION => NULL
                                                      ,P_ZERO_COST_ONLY => NULL
                                                      ,P_ZERO_QTY => NULL
                                                      ,P_EXPENSE_ITEM => NULL
                                                      ,P_EXPENSE_SUB => NULL
                                                      ,P_UNVALUED_TXNS => 0
                                                      ,P_RECEIPT => NULL
                                                      ,P_SHIPMENT => NULL
                                                      ,X_RETURN_STATUS => L_RETURN_STATUS
                                                      ,X_MSG_COUNT => L_MSG_COUNT
                                                      ,X_MSG_DATA => L_MSG_DATA);
            L_STMT_NUM := 103;
            IF L_RETURN_STATUS <> CST_UTILITY_PUB.GET_RET_STS_SUCCESS THEN
              RAISE L_CST_INV_VAL;
            END IF;
            L_STMT_NUM := 104;
            CST_INVENTORY_PVT.CALCULATE_INVENTORYCOST(P_API_VERSION => 1.0
                                                     ,P_VALUATION_DATE => NULL
                                                     ,P_ORGANIZATION_ID => P_ORG_ID
                                                     ,X_RETURN_STATUS => L_RETURN_STATUS);
            L_STMT_NUM := 105;
            IF L_RETURN_STATUS <> CST_UTILITY_PUB.GET_RET_STS_SUCCESS THEN
              RAISE L_CST_INV_VAL;
            END IF;
            L_STMT_NUM := 106;
            L_STMT_NUM := 107;
            FND_MSG_PUB.COUNT_AND_GET(P_ENCODED => CST_UTILITY_PUB.GET_FALSE
                                     ,P_COUNT => L_MSG_COUNT
                                     ,P_DATA => L_MSG_DATA);
            L_STMT_NUM := 108;
            IF L_MSG_COUNT > 0 THEN
              FOR i IN 1 .. L_MSG_COUNT LOOP
                L_MSG_DATA := FND_MSG_PUB.GET(I
                                             ,CST_UTILITY_PUB.GET_FALSE);
                /*SRW.MESSAGE(1
                           ,'Message : ' || L_MSG_DATA)*/NULL;
              END LOOP;
            END IF;
            RETURN TRUE;
          EXCEPTION
            WHEN OTHERS THEN
              /*SRW.MESSAGE(999
                         ,L_STMT_NUM || ': ' || SQLERRM)*/NULL;
              FND_MSG_PUB.COUNT_AND_GET(P_ENCODED => CST_UTILITY_PUB.GET_FALSE
                                       ,P_COUNT => L_MSG_COUNT
                                       ,P_DATA => L_MSG_DATA);
              IF L_MSG_COUNT > 0 THEN
                FOR i IN 1 .. L_MSG_COUNT LOOP
                  L_MSG_DATA := FND_MSG_PUB.GET(I
                                               ,CST_UTILITY_PUB.GET_FALSE);
                  /*SRW.MESSAGE(1
                             ,'Message : ' || L_MSG_DATA)*/NULL;
                END LOOP;
              END IF;
              /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
          END;
        END IF;
      END IF;
    EXCEPTION
      WHEN /*SRW.DO_SQL_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Do sql failed to create view.' || SQLERRM)*/NULL;
    END;
    RETURN (TRUE);
  END AFTERPFORM;
 -- FUNCTION P_VIEW_PUTVALIDTRIGGER RETURN BOOLEAN IS
  FUNCTION P_VIEW_PUTVALIDTRIGGER RETURN VARCHAR2 IS
  BEGIN
    P_VIEW := 'txn_analysis_view' || TO_CHAR(P_CONC_REQUEST_ID);
    RETURN (P_VIEW);
  END P_VIEW_PUTVALIDTRIGGER;
  FUNCTION C_CURRENCY_CODEFORMULA(CURRENCY_CODE_REP IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN ('(' || CURRENCY_CODE_REP || ')');
  END C_CURRENCY_CODEFORMULA;
  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    DECLARE
      VIEW_TO_DROP USER_VIEWS.VIEW_NAME%TYPE;
      CURSOR SEL_VIEWS IS
        SELECT
          VIEW_NAME
        FROM
          USER_VIEWS
        WHERE VIEW_NAME LIKE 'TXN_ANALYSIS_VIEW%';
    BEGIN
      OPEN SEL_VIEWS;
      LOOP
        FETCH SEL_VIEWS
         INTO VIEW_TO_DROP;
        EXIT WHEN SEL_VIEWS%NOTFOUND;
        BEGIN
          EXECUTE IMMEDIATE
            'DROP VIEW ' || VIEW_TO_DROP;
        EXCEPTION
         /* WHEN SRW.USER_EXIT_FAILURE OTHERS THEN
            /*SRW.MESSAGE(1
                       ,'Before Form Trigger Failed')NULL;*/
          WHEN OTHERS THEN
            /*SRW.MESSAGE(2
                       ,'Before Form Trigger Failed')*/NULL;
        END;
      END LOOP;
      CLOSE SEL_VIEWS;
    END;
    /*SRW.MESSAGE(1
               ,'Just finished dropping ANALYSIS views, if any')*/NULL;
    RETURN (TRUE);
  END BEFOREPFORM;
  FUNCTION C_CAT_PADFORMULA(C_CAT_PAD IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_CAT_PAD);
  END C_CAT_PADFORMULA;
  FUNCTION CUR_QTY_VALFORMULA(ASS_INV IN NUMBER
                             ,CUR_QTY_VAL_OLD IN NUMBER
                             ,SOURCE_TYPE1 IN NUMBER
                             ,SOURCE_TYPE2 IN NUMBER
                             ,SOURCE_TYPE3 IN NUMBER
                             ,SOURCE_TYPE4 IN NUMBER
                             ,OTHER IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF ((P_SORT_ID = 1) AND (P_SELECTION = 2) AND (ASS_INV <> 1)) THEN
        RETURN (0);
      ELSIF (P_WMS_ENABLED = 'Y' OR P_PJM_ENABLED = 'Y') AND P_SELECTION = 2 THEN
        RETURN (CUR_QTY_VAL_OLD + SOURCE_TYPE1 + SOURCE_TYPE2 + SOURCE_TYPE3 + SOURCE_TYPE4 + OTHER);
      ELSIF (P_WMS_ENABLED = 'Y' OR P_PJM_ENABLED = 'Y') AND P_SELECTION = 3 THEN
        RETURN (CUR_QTY_VAL_OLD + OTHER);
      ELSE
        RETURN (CUR_QTY_VAL_OLD);
      END IF;
    END;
    RETURN NULL;
  END CUR_QTY_VALFORMULA;
  FUNCTION C_COST_TYPEFORMULA RETURN NUMBER IS
  BEGIN
    DECLARE
      ORG_ID NUMBER;
      COST_TYPE NUMBER;
    BEGIN
      ORG_ID := P_ORG_ID;
      SELECT
        PRIMARY_COST_METHOD
      INTO COST_TYPE
      FROM
        MTL_PARAMETERS
      WHERE ORGANIZATION_ID = ORG_ID;
      RETURN (COST_TYPE);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('Error');
      WHEN OTHERS THEN
        RETURN ('Error');
    END;
    RETURN NULL;
  END C_COST_TYPEFORMULA;
  FUNCTION C_OTHERSFORMULA(OTHER IN NUMBER
                          ,C_COST_TYPE IN NUMBER
                          ,ITEM_ID IN NUMBER
                          ,SUBINVENTORY IN VARCHAR2
                          ,TARGET_QTY IN NUMBER
                          ,SOURCE_TYPE1 IN NUMBER
                          ,SOURCE_TYPE2 IN NUMBER
                          ,SOURCE_TYPE3 IN NUMBER
                          ,SOURCE_TYPE4 IN NUMBER
                          ,C_STD_PREC IN NUMBER
                          ,CUR_QTY_VAL IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      CURRENT_VALUE NUMBER;
      HIST_VALUE NUMBER;
      NEW_OTHER_VALUE NUMBER;
      MY_ORG_ID NUMBER;
      MY_ITEM_ID NUMBER;
      MY_SUB VARCHAR2(40);
      MY_MIN_TRX_ID NUMBER;
      MY_HIS_DATE VARCHAR2(40);
      MY_CUR_QTY_VAL NUMBER;
      MY_TARGET_QTY NUMBER;
      MY_HIS_VALUE NUMBER;
      MY_SOURCE1 NUMBER;
      MY_SOURCE2 NUMBER;
      MY_SOURCE3 NUMBER;
      MY_SOURCE4 NUMBER;
      CURRENT_ITEM_COST NUMBER;
    BEGIN
      IF (P_SELECTION = 1) THEN
        RETURN (OTHER);
      END IF;
      IF (C_COST_TYPE = 1) THEN
        RETURN (OTHER);
      END IF;
      BEGIN
        SELECT
          ITEM_COST
        INTO CURRENT_ITEM_COST
        FROM
          CST_ITEM_COSTS_FOR_GL_VIEW
        WHERE ORGANIZATION_ID = P_ORG_ID
          AND INVENTORY_ITEM_ID = ITEM_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN (OTHER);
      END;
      IF ((C_COST_TYPE = 2) AND ((P_STYPE1_1 = 13) OR (P_STYPE2_1 = 13) OR (P_STYPE3_1 = 13) OR (P_STYPE4_1 = 13))) THEN
        RETURN (NVL(OTHER
                  ,0));
      END IF;
      MY_ORG_ID := P_ORG_ID;
      MY_ITEM_ID := ITEM_ID;
      MY_SUB := SUBINVENTORY;
      MY_HIS_DATE := P_hist_date_1;
      MY_MIN_TRX_ID := 0;
      MY_TARGET_QTY := TARGET_QTY;
      MY_SOURCE1 := SOURCE_TYPE1;
      MY_SOURCE2 := SOURCE_TYPE2;
      MY_SOURCE3 := SOURCE_TYPE3;
      MY_SOURCE4 := SOURCE_TYPE4;
      IF (TARGET_QTY = 0) THEN
        MY_HIS_VALUE := 0;
      END IF;
      SELECT
        NVL(MIN(TRANSACTION_ID)
           ,0)
      INTO MY_MIN_TRX_ID
      FROM
        MTL_MATERIAL_TRANSACTIONS
      WHERE ORGANIZATION_ID = MY_ORG_ID
        AND INVENTORY_ITEM_ID = MY_ITEM_ID
        AND TRANSACTION_DATE > TO_DATE(MY_HIS_DATE
             ,'DD-MON-RRRR');
      IF (MY_MIN_TRX_ID = 0) THEN
        RETURN (0);
      ELSE
        SELECT
          NVL(PRIOR_COST
             ,0)
        INTO MY_HIS_VALUE
        FROM
          MTL_MATERIAL_TRANSACTIONS
        WHERE ORGANIZATION_ID = MY_ORG_ID
          AND INVENTORY_ITEM_ID = MY_ITEM_ID
          AND TRANSACTION_ID = MY_MIN_TRX_ID;
      END IF;
      HIST_VALUE := ROUND(MY_TARGET_QTY * MY_HIS_VALUE
                         ,C_STD_PREC);
      CURRENT_VALUE := CUR_QTY_VAL;
      NEW_OTHER_VALUE := CURRENT_VALUE - HIST_VALUE - MY_SOURCE1 - MY_SOURCE2 - MY_SOURCE3 - MY_SOURCE4;
      RETURN (NEW_OTHER_VALUE);
    END;
    RETURN NULL;
  END C_OTHERSFORMULA;
  FUNCTION C_SOURCE_TYPE1_CFORMULA(SOURCE_TYPE1 IN NUMBER
                                  ,C_COST_TYPE IN NUMBER
                                  ,ITEM_ID IN NUMBER
                                  ,SUBINVENTORY IN VARCHAR2
                                  ,TARGET_QTY IN NUMBER
                                  ,C_SOURCE_TYPE2_C IN NUMBER
                                  ,C_SOURCE_TYPE3_C IN NUMBER
                                  ,C_SOURCE_TYPE4_C IN NUMBER
                                  ,OTHER IN NUMBER
                                  ,CUR_QTY_VAL IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      CURRENT_VALUE NUMBER;
      HIST_VALUE NUMBER;
      NEW_OTHER_VALUE NUMBER;
      MY_ORG_ID NUMBER;
      MY_ITEM_ID NUMBER;
      MY_SUB VARCHAR2(40);
      MY_MIN_TRX_ID NUMBER;
      MY_HIS_DATE VARCHAR2(40);
      MY_CUR_QTY_VAL NUMBER;
      MY_TARGET_QTY NUMBER;
      MY_HIS_VALUE NUMBER;
      NEW_SOURCE1 NUMBER;
      MY_SOURCE2 NUMBER;
      MY_SOURCE3 NUMBER;
      MY_SOURCE4 NUMBER;
      MY_OTHERS NUMBER;
      CURRENT_ITEM_COST NUMBER;
    BEGIN
      IF (P_SELECTION = 1) THEN
        RETURN (SOURCE_TYPE1);
      END IF;
      IF ((C_COST_TYPE <> 2) OR (P_STYPE1_1 <> 13)) THEN
        RETURN (SOURCE_TYPE1);
      END IF;
      MY_ORG_ID := P_ORG_ID;
      MY_ITEM_ID := ITEM_ID;
      MY_SUB := SUBINVENTORY;
      MY_HIS_DATE := P_hist_date_1;
      MY_MIN_TRX_ID := 0;
      MY_TARGET_QTY := TARGET_QTY;
      IF ((C_COST_TYPE = 2) AND (P_STYPE2_1 = 13)) THEN
        MY_SOURCE2 := 0;
      ELSE
        MY_SOURCE2 := C_SOURCE_TYPE2_C;
      END IF;
      IF ((C_COST_TYPE = 2) AND (P_STYPE3_1 = 13)) THEN
        MY_SOURCE3 := 0;
      ELSE
        MY_SOURCE3 := C_SOURCE_TYPE3_C;
      END IF;
      IF ((C_COST_TYPE = 2) AND (P_STYPE4_1 = 13)) THEN
        MY_SOURCE4 := 0;
      ELSE
        MY_SOURCE4 := C_SOURCE_TYPE4_C;
      END IF;
      SELECT
        ITEM_COST
      INTO CURRENT_ITEM_COST
      FROM
        CST_ITEM_COSTS_FOR_GL_VIEW
      WHERE ORGANIZATION_ID = P_ORG_ID
        AND INVENTORY_ITEM_ID = ITEM_ID;
      MY_OTHERS := NVL(OTHER
                      ,0);
      IF (TARGET_QTY = 0) THEN
        MY_HIS_VALUE := 0;
      END IF;
      SELECT
        NVL(MIN(TRANSACTION_ID)
           ,0)
      INTO MY_MIN_TRX_ID
      FROM
        MTL_MATERIAL_TRANSACTIONS
      WHERE ORGANIZATION_ID = MY_ORG_ID
        AND INVENTORY_ITEM_ID = MY_ITEM_ID
        AND TRANSACTION_DATE > TO_DATE(MY_HIS_DATE
             ,'DD-MON-RRRR');
      IF (MY_MIN_TRX_ID = 0) THEN
        RETURN (0);
      ELSE
        SELECT
          PRIOR_COST
        INTO MY_HIS_VALUE
        FROM
          MTL_MATERIAL_TRANSACTIONS
        WHERE ORGANIZATION_ID = MY_ORG_ID
          AND INVENTORY_ITEM_ID = MY_ITEM_ID
          AND TRANSACTION_ID = MY_MIN_TRX_ID;
      END IF;
      HIST_VALUE := MY_HIS_VALUE * MY_TARGET_QTY;
      CURRENT_VALUE := CUR_QTY_VAL;
      NEW_SOURCE1 := CURRENT_VALUE - HIST_VALUE - MY_OTHERS - MY_SOURCE2 - MY_SOURCE3 - MY_SOURCE4;
      RETURN (NEW_SOURCE1);
    END;
    RETURN NULL;
  END C_SOURCE_TYPE1_CFORMULA;
  FUNCTION C_SOURCE_TYPE2_CFORMULA(SOURCE_TYPE2 IN NUMBER
                                  ,C_COST_TYPE IN NUMBER
                                  ,ITEM_ID IN NUMBER
                                  ,SUBINVENTORY IN VARCHAR2
                                  ,TARGET_QTY IN NUMBER
                                  ,SOURCE_TYPE1 IN NUMBER
                                  ,SOURCE_TYPE3 IN NUMBER
                                  ,SOURCE_TYPE4 IN NUMBER
                                  ,OTHER IN NUMBER
                                  ,CUR_QTY_VAL IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      CURRENT_VALUE NUMBER;
      HIST_VALUE NUMBER;
      NEW_OTHER_VALUE NUMBER;
      MY_ORG_ID NUMBER;
      MY_ITEM_ID NUMBER;
      MY_SUB VARCHAR2(40);
      MY_MIN_TRX_ID NUMBER;
      MY_HIS_DATE VARCHAR2(40);
      MY_CUR_QTY_VAL NUMBER;
      MY_TARGET_QTY NUMBER;
      MY_HIS_VALUE NUMBER;
      NEW_SOURCE2 NUMBER;
      MY_SOURCE1 NUMBER;
      MY_SOURCE3 NUMBER;
      MY_SOURCE4 NUMBER;
      MY_OTHERS NUMBER;
      CURRENT_ITEM_COST NUMBER;
    BEGIN
      IF (P_SELECTION = 1) THEN
        RETURN (SOURCE_TYPE2);
      END IF;
      IF ((C_COST_TYPE <> 2) OR (P_STYPE2_1 <> 13)) THEN
        RETURN (SOURCE_TYPE2);
      END IF;
      MY_ORG_ID := P_ORG_ID;
      MY_ITEM_ID := ITEM_ID;
      MY_SUB := SUBINVENTORY;
      MY_HIS_DATE := P_hist_date_1;
      MY_MIN_TRX_ID := 0;
      MY_TARGET_QTY := TARGET_QTY;
      IF ((C_COST_TYPE = 2) AND (P_STYPE1_1 = 13)) THEN
        MY_SOURCE1 := 0;
      ELSE
        MY_SOURCE1 := SOURCE_TYPE1;
      END IF;
      IF ((C_COST_TYPE = 2) AND (P_STYPE3_1 = 13)) THEN
        MY_SOURCE3 := 0;
      ELSE
        MY_SOURCE3 := SOURCE_TYPE3;
      END IF;
      IF ((C_COST_TYPE = 2) AND (P_STYPE4_1 = 13)) THEN
        MY_SOURCE4 := 0;
      ELSE
        MY_SOURCE4 := SOURCE_TYPE4;
      END IF;
      SELECT
        ITEM_COST
      INTO CURRENT_ITEM_COST
      FROM
        CST_ITEM_COSTS_FOR_GL_VIEW
      WHERE ORGANIZATION_ID = P_ORG_ID
        AND INVENTORY_ITEM_ID = ITEM_ID;
      MY_OTHERS := NVL(OTHER
                      ,0);
      IF (TARGET_QTY = 0) THEN
        MY_HIS_VALUE := 0;
      END IF;
      SELECT
        NVL(MIN(TRANSACTION_ID)
           ,0)
      INTO MY_MIN_TRX_ID
      FROM
        MTL_MATERIAL_TRANSACTIONS
      WHERE ORGANIZATION_ID = MY_ORG_ID
        AND INVENTORY_ITEM_ID = MY_ITEM_ID
        AND TRANSACTION_DATE > TO_DATE(MY_HIS_DATE
             ,'DD-MON-RRRR');
      IF (MY_MIN_TRX_ID = 0) THEN
        RETURN (0);
      ELSE
        SELECT
          PRIOR_COST
        INTO MY_HIS_VALUE
        FROM
          MTL_MATERIAL_TRANSACTIONS
        WHERE ORGANIZATION_ID = MY_ORG_ID
          AND INVENTORY_ITEM_ID = MY_ITEM_ID
          AND TRANSACTION_ID = MY_MIN_TRX_ID;
      END IF;
      HIST_VALUE := MY_HIS_VALUE * MY_TARGET_QTY;
      CURRENT_VALUE := CUR_QTY_VAL;
      NEW_SOURCE2 := CURRENT_VALUE - HIST_VALUE - MY_OTHERS - MY_SOURCE1 - MY_SOURCE3 - MY_SOURCE4;
      RETURN (NEW_SOURCE2);
    END;
    RETURN NULL;
  END C_SOURCE_TYPE2_CFORMULA;
  FUNCTION C_SOURCE_TYPE3_CFORMULA(SOURCE_TYPE3 IN NUMBER
                                  ,C_COST_TYPE IN NUMBER
                                  ,ITEM_ID IN NUMBER
                                  ,SUBINVENTORY IN VARCHAR2
                                  ,TARGET_QTY IN NUMBER
                                  ,SOURCE_TYPE1 IN NUMBER
                                  ,SOURCE_TYPE2 IN NUMBER
                                  ,SOURCE_TYPE4 IN NUMBER
                                  ,OTHER IN NUMBER
                                  ,CUR_QTY_VAL IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      CURRENT_VALUE NUMBER;
      HIST_VALUE NUMBER;
      NEW_OTHER_VALUE NUMBER;
      MY_ORG_ID NUMBER;
      MY_ITEM_ID NUMBER;
      MY_SUB VARCHAR2(40);
      MY_MIN_TRX_ID NUMBER;
      MY_HIS_DATE VARCHAR2(40);
      MY_CUR_QTY_VAL NUMBER;
      MY_TARGET_QTY NUMBER;
      MY_HIS_VALUE NUMBER;
      NEW_SOURCE3 NUMBER;
      MY_SOURCE1 NUMBER;
      MY_SOURCE2 NUMBER;
      MY_SOURCE4 NUMBER;
      MY_OTHERS NUMBER;
      CURRENT_ITEM_COST NUMBER;
    BEGIN
      IF (P_SELECTION = 1) THEN
        RETURN (SOURCE_TYPE3);
      END IF;
      IF ((C_COST_TYPE <> 2) OR (P_STYPE3_1 <> 13)) THEN
        RETURN (SOURCE_TYPE3);
      END IF;
      MY_ORG_ID := P_ORG_ID;
      MY_ITEM_ID := ITEM_ID;
      MY_SUB := SUBINVENTORY;
      MY_HIS_DATE := P_hist_date_1;
      MY_MIN_TRX_ID := 0;
      MY_TARGET_QTY := TARGET_QTY;
      IF ((C_COST_TYPE = 2) AND (P_STYPE1_1 = 13)) THEN
        MY_SOURCE1 := 0;
      ELSE
        MY_SOURCE1 := SOURCE_TYPE1;
      END IF;
      IF ((C_COST_TYPE = 2) AND (P_STYPE2_1 = 13)) THEN
        MY_SOURCE2 := 0;
      ELSE
        MY_SOURCE2 := SOURCE_TYPE2;
      END IF;
      IF ((C_COST_TYPE = 2) AND (P_STYPE4_1 = 13)) THEN
        MY_SOURCE4 := 0;
      ELSE
        MY_SOURCE4 := SOURCE_TYPE4;
      END IF;
      SELECT
        ITEM_COST
      INTO CURRENT_ITEM_COST
      FROM
        CST_ITEM_COSTS_FOR_GL_VIEW
      WHERE ORGANIZATION_ID = P_ORG_ID
        AND INVENTORY_ITEM_ID = ITEM_ID;
      MY_OTHERS := NVL(OTHER
                      ,0);
      IF (TARGET_QTY = 0) THEN
        MY_HIS_VALUE := 0;
      END IF;
      SELECT
        NVL(MIN(TRANSACTION_ID)
           ,0)
      INTO MY_MIN_TRX_ID
      FROM
        MTL_MATERIAL_TRANSACTIONS
      WHERE ORGANIZATION_ID = MY_ORG_ID
        AND INVENTORY_ITEM_ID = MY_ITEM_ID
        AND TRANSACTION_DATE > TO_DATE(MY_HIS_DATE
             ,'DD-MON-RRRR');
      IF (MY_MIN_TRX_ID = 0) THEN
        RETURN (0);
      ELSE
        SELECT
          PRIOR_COST
        INTO MY_HIS_VALUE
        FROM
          MTL_MATERIAL_TRANSACTIONS
        WHERE ORGANIZATION_ID = MY_ORG_ID
          AND INVENTORY_ITEM_ID = MY_ITEM_ID
          AND TRANSACTION_ID = MY_MIN_TRX_ID;
      END IF;
      HIST_VALUE := MY_HIS_VALUE * MY_TARGET_QTY;
      CURRENT_VALUE := CUR_QTY_VAL;
      NEW_SOURCE3 := CURRENT_VALUE - HIST_VALUE - MY_OTHERS - MY_SOURCE1 - MY_SOURCE2 - MY_SOURCE4;
      RETURN (NEW_SOURCE3);
    END;
    RETURN NULL;
  END C_SOURCE_TYPE3_CFORMULA;
  FUNCTION C_SOURCE_TYPE4_CFORMULA(SOURCE_TYPE4 IN NUMBER
                                  ,C_COST_TYPE IN NUMBER
                                  ,ITEM_ID IN NUMBER
                                  ,SUBINVENTORY IN VARCHAR2
                                  ,TARGET_QTY IN NUMBER
                                  ,SOURCE_TYPE1 IN NUMBER
                                  ,SOURCE_TYPE2 IN NUMBER
                                  ,SOURCE_TYPE3 IN NUMBER
                                  ,OTHER IN NUMBER
                                  ,CUR_QTY_VAL IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      CURRENT_VALUE NUMBER;
      HIST_VALUE NUMBER;
      NEW_OTHER_VALUE NUMBER;
      MY_ORG_ID NUMBER;
      MY_ITEM_ID NUMBER;
      MY_SUB VARCHAR2(40);
      MY_MIN_TRX_ID NUMBER;
      MY_HIS_DATE VARCHAR2(40);
      MY_CUR_QTY_VAL NUMBER;
      MY_TARGET_QTY NUMBER;
      MY_HIS_VALUE NUMBER;
      NEW_SOURCE4 NUMBER;
      MY_SOURCE1 NUMBER;
      MY_SOURCE2 NUMBER;
      MY_SOURCE3 NUMBER;
      MY_OTHERS NUMBER;
      CURRENT_ITEM_COST NUMBER;
    BEGIN
      IF (P_SELECTION = 1) THEN
        RETURN (SOURCE_TYPE4);
      END IF;
      IF ((C_COST_TYPE <> 2) OR (P_STYPE4_1 <> 13)) THEN
        RETURN (SOURCE_TYPE4);
      END IF;
      MY_ORG_ID := P_ORG_ID;
      MY_ITEM_ID := ITEM_ID;
      MY_SUB := SUBINVENTORY;
      MY_HIS_DATE := P_hist_date_1;
      MY_MIN_TRX_ID := 0;
      MY_TARGET_QTY := TARGET_QTY;
      IF ((C_COST_TYPE = 2) AND (P_STYPE1_1 = 13)) THEN
        MY_SOURCE1 := 0;
      ELSE
        MY_SOURCE1 := SOURCE_TYPE1;
      END IF;
      IF ((C_COST_TYPE = 2) AND (P_STYPE2_1 = 13)) THEN
        MY_SOURCE2 := 0;
      ELSE
        MY_SOURCE2 := SOURCE_TYPE2;
      END IF;
      IF ((C_COST_TYPE = 2) AND (P_STYPE3_1 = 13)) THEN
        MY_SOURCE3 := 0;
      ELSE
        MY_SOURCE3 := SOURCE_TYPE3;
      END IF;
      SELECT
        ITEM_COST
      INTO CURRENT_ITEM_COST
      FROM
        CST_ITEM_COSTS_FOR_GL_VIEW
      WHERE ORGANIZATION_ID = P_ORG_ID
        AND INVENTORY_ITEM_ID = ITEM_ID;
      MY_OTHERS := NVL(OTHER
                      ,0);
      IF (TARGET_QTY = 0) THEN
        MY_HIS_VALUE := 0;
      END IF;
      SELECT
        NVL(MIN(TRANSACTION_ID)
           ,0)
      INTO MY_MIN_TRX_ID
      FROM
        MTL_MATERIAL_TRANSACTIONS
      WHERE ORGANIZATION_ID = MY_ORG_ID
        AND INVENTORY_ITEM_ID = MY_ITEM_ID
        AND TRANSACTION_DATE > TO_DATE(MY_HIS_DATE
             ,'DD-MON-RRRR');
      IF (MY_MIN_TRX_ID = 0) THEN
        RETURN (0);
      ELSE
        SELECT
          PRIOR_COST
        INTO MY_HIS_VALUE
        FROM
          MTL_MATERIAL_TRANSACTIONS
        WHERE ORGANIZATION_ID = MY_ORG_ID
          AND INVENTORY_ITEM_ID = MY_ITEM_ID
          AND TRANSACTION_ID = MY_MIN_TRX_ID;
      END IF;
      HIST_VALUE := MY_HIS_VALUE * MY_TARGET_QTY;
      CURRENT_VALUE := CUR_QTY_VAL;
      NEW_SOURCE4 := CURRENT_VALUE - HIST_VALUE - MY_OTHERS - MY_SOURCE1 - MY_SOURCE2 - MY_SOURCE3;
      RETURN (NEW_SOURCE4);
    END;
    RETURN NULL;
  END C_SOURCE_TYPE4_CFORMULA;
  FUNCTION C_SOURCE_TYPE5_CFORMULA(SOURCE_TYPE5 IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      RETURN (SOURCE_TYPE5);
    END;
    RETURN NULL;
  END C_SOURCE_TYPE5_CFORMULA;
END INV_INVTRHAN_XMLP_PKG;


/
