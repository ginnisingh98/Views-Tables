--------------------------------------------------------
--  DDL for Package Body INV_INVTRLNT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVTRLNT_XMLP_PKG" AS
/* $Header: INVTRLNTB.pls 120.0 2007/12/28 11:16:50 dwkrishn noship $ */
  FUNCTION P_STRUCT_NUMVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_STRUCT_NUMVALIDTRIGGER;

  FUNCTION WHERE_LOT RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      LO VARCHAR2(80);
      HI VARCHAR2(80);
    BEGIN
      LO := P_LOT_LO;
      HI := P_LOT_HI;
      IF P_LOT_LO IS NULL AND P_LOT_HI IS NULL THEN
        RETURN ('  ');
      ELSE
        IF P_LOT_LO IS NOT NULL AND P_LOT_HI IS NULL THEN
          RETURN (' and mtln.lot_number >= ''' || LO || ''' ');
        ELSE
          IF P_LOT_LO IS NULL AND P_LOT_HI IS NOT NULL THEN
            RETURN (' and mtln.lot_number <= ''' || HI || ''' ');
          ELSE
            RETURN (' and mtln.lot_number between ''' || LO || '''  and  ''' || HI || ''' ');
          END IF;
        END IF;
      END IF;
    END;
    RETURN NULL;
  END WHERE_LOT;

  FUNCTION WHERE_REASON RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      LO VARCHAR2(50);
      HI VARCHAR2(50);
    BEGIN
      LO := P_REASON_LO;
      HI := P_REASON_HI;
      IF P_REASON_LO IS NULL AND P_REASON_HI IS NULL THEN
        RETURN ('  ');
      ELSE
        IF P_REASON_LO IS NOT NULL AND P_REASON_HI IS NULL THEN
          RETURN ('  AND  mtr.reason_name >=  ''' || LO || ''' ');
        ELSE
          IF P_REASON_LO IS NULL AND P_REASON_HI IS NOT NULL THEN
            RETURN ('  AND mtr.reason_name <= ''' || HI || ''' ');
          ELSE
            RETURN (' AND mtr.reason_name between  ''' || LO || '''  and  ''' || HI || ''' ');
          END IF;
        END IF;
      END IF;
    END;
    RETURN NULL;
  END WHERE_REASON;

  FUNCTION WHERE_SUBINV RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      LO VARCHAR2(10);
      HI VARCHAR2(10);
    BEGIN
      LO := P_SUBINV_LO;
      HI := P_SUBINV_HI;
      IF P_SUBINV_LO IS NULL AND P_SUBINV_HI IS NULL THEN
        RETURN ('  ');
      ELSE
        IF P_SUBINV_LO IS NOT NULL AND P_SUBINV_HI IS NULL THEN
          RETURN ('  AND mmt.subinventory_code >= ''' || LO || ''' ');
        ELSE
          IF P_SUBINV_LO IS NULL AND P_SUBINV_HI IS NOT NULL THEN
            RETURN ('  AND mmt.subinventory_code <=  ''' || HI || ''' ');
          ELSE
            RETURN ('  AND mmt.subinventory_code between  ''' || LO || '''  and ''' || HI || ''' ');
          END IF;
        END IF;
      END IF;
    END;
    RETURN NULL;
  END WHERE_SUBINV;

  FUNCTION WHERE_TXN_TYPE RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      LO VARCHAR2(80);
      HI VARCHAR2(80);
    BEGIN
      LO := P_TXN_TYPE_LO;
      HI := P_TXN_TYPE_HI;
      IF P_TXN_TYPE_LO IS NULL AND P_TXN_TYPE_HI IS NULL THEN
        RETURN ('  ');
      ELSE
        IF P_TXN_TYPE_LO IS NOT NULL AND P_TXN_TYPE_HI IS NULL THEN
          RETURN ('  AND  mtxt.transaction_type_name >= ''' || LO || ''' ');
        ELSE
          IF P_TXN_TYPE_LO IS NULL AND P_TXN_TYPE_HI IS NOT NULL THEN
            RETURN ('  AND mtxt.transaction_type_name <= ''' || HI || ''' ');
          ELSE
            RETURN (' AND  mtxt.transaction_type_name between ''' || LO || '''  and  ''' || HI || ''' ');
          END IF;
        END IF;
      END IF;
    END;
    RETURN NULL;
  END WHERE_TXN_TYPE;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(010
                   ,'Failed in before report trigger, srwinit. ')*/NULL;
        RAISE;
    END;
    DECLARE
      P_ORG_ID_CHAR VARCHAR2(100) := TO_CHAR(P_ORG);
    BEGIN
      /*SRW.USER_EXIT('FND PUTPROFILE NAME="' || 'MFG_ORGANIZATION_ID' || '" FIELD="' || P_ORG_ID_CHAR || '"')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(020
                   ,'Failed in before report trigger, setting org profile ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(020
                   ,'Failed in before report trigger, item select. ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(030
                   ,'Failed in before report trigger, locator select. ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(040
                   ,'Failed in before report trigger, mkts select. ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(045
                   ,'Failed in before report trigger, mkts order by.')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(050
                   ,'Failed in before report trigger, mdsp select. ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(055
                   ,'Failed in before report trigger, mdsp order by. ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(060
                   ,'Failed in before report triger, glcc select. ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(065
                   ,'Failed in before report trigger, glcc order by. ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(070
                   ,'Failed in before report trigger, catg select. ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(080
                   ,'Failed in before report trigger, item order by. ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(100
                   ,'Failed in before report trigger, catg order by. ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(110
                   ,'Failed in before report trigger, item where. ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(120
                   ,'Failed in before report trigger, catg where. ')*/NULL;
        RAISE;
    END;
    IF P_TXN_SOURCE_TYPE_ID in (2,8,12) THEN
      BEGIN
        IF P_TXN_SOURCE_HI IS NOT NULL OR P_TXN_SOURCE_LO IS NOT NULL THEN
          NULL;
        ELSE
          NULL;
        END IF;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(1
                     ,'Failed in before report trigger:MKTS/where')*/NULL;
          RAISE;
      END;
    ELSE
      IF P_TXN_SOURCE_TYPE_ID = 6 THEN
        BEGIN
          IF P_TXN_SOURCE_HI IS NOT NULL OR P_TXN_SOURCE_LO IS NOT NULL THEN
            NULL;
          ELSE
            NULL;
          END IF;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(1
                       ,'Failed in before report trigger:MDSP/where')*/NULL;
            RAISE;
        END;
      ELSE
        IF P_TXN_SOURCE_TYPE_ID = 3 THEN
          BEGIN
            IF P_TXN_SOURCE_HI IS NOT NULL OR P_TXN_SOURCE_LO IS NOT NULL THEN
              NULL;
            ELSE
              NULL;
            END IF;
          EXCEPTION
            WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
              /*SRW.MESSAGE(1
                         ,'Failed in before report trigger:GL/where')*/NULL;
              RAISE;
          END;
        ELSE
          NULL;
        END IF;
      END IF;
    END IF;
    RETURN (TRUE);
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION C_SOURCE_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID in (2,8,12) AND (P_TXN_SOURCE_LO IS NOT NULL OR P_TXN_SOURCE_HI IS NOT NULL) THEN
        RETURN ('and mtln.transaction_source_id = mkts.sales_order_id
                       and ' || P_SOURCE_WHERE);
      ELSE
        IF P_TXN_SOURCE_TYPE_ID = 3 AND (P_TXN_SOURCE_LO IS NOT NULL OR P_TXN_SOURCE_HI IS NOT NULL) THEN
          RETURN ('and mtln.transaction_source_id = glcc.code_combination_id
                         and ' || P_SOURCE_WHERE);
        ELSE
          IF P_TXN_SOURCE_TYPE_ID = 6 AND (P_TXN_SOURCE_LO IS NOT NULL OR P_TXN_SOURCE_HI IS NOT NULL) THEN
            RETURN ('and mtln.transaction_source_id = mdsp.disposition_id
                           and ' || P_SOURCE_WHERE);
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 1 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mtln.transaction_source_id = poh.po_header_id
                 	and poh.segment1 between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mtln.transaction_source_id = poh.po_header_id
                   	and poh.segment1 >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mtln.transaction_source_id = poh.po_header_id
                     	and poh.segment1 <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 5 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mtln.transaction_source_id = wipe.wip_entity_id
                 	and wipe.wip_entity_name between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mtln.transaction_source_id = wipe.wip_entity_id
                           and wipe.wip_entity_name >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mtln.transaction_source_id = wipe.wip_entity_id
                             and wipe.wip_entity_name <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 7 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mtln.transaction_source_id = porh.requisition_header_id
                 	and porh.segment1 between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mtln.transaction_source_id = porh.requisition_header_id
                   	and porh.segment1 >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mtln.transaction_source_id = porh.requisition_header_id
                     	and porh.segment1 <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 9 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mtln.transaction_source_id = CCH.cycle_count_header_id
                 	and CCH.cycle_count_header_name between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mtln.transaction_source_id = CCH.cycle_count_header_id
                   	and CCH.cycle_count_header_name >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mtln.transaction_source_id = CCH.cycle_count_header_id
                     	and CCH.cycle_count_header_name <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 10 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mtln.transaction_source_id = mpi.physical_inventory_id
                 	and mpi.physical_inventory_name between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mtln.transaction_source_id = mpi.physical_inventory_id
                   	and mpi.physical_inventory_name >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mtln.transaction_source_id = mpi.physical_inventory_id
                     	and mpi.physical_inventory_name <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 11 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mtln.transaction_source_id = cupd.cost_update_id
                 	and cupd.description between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mtln.transaction_source_id = cupd.cost_update_id
                   	and cupd.description between >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mtln.transaction_source_id = cupd.cost_update_id
                     	and cupd.description <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID >= 13 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mtln.transaction_source_name between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mtln.transaction_source_name >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mtln.transaction_source_name <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    RETURN '  ';
  END C_SOURCE_WHEREFORMULA;

  FUNCTION C_REPORT_DATE_CURRENCY_TITFORM(C_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (' From ' || TO_CHAR(P_TXN_DATE_LO
                  ,'DD-MON-RRRR') || ' to ' || TO_CHAR(P_TXN_DATE_HI
                  ,'DD-MON-RRRR') || ' (' || C_CURRENCY_CODE || ')');
  END C_REPORT_DATE_CURRENCY_TITFORM;

  FUNCTION P_MDSP_ORDER_BYVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_MDSP_ORDER_BYVALIDTRIGGER;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CALC_UNIT_COST(RPT_QTY IN NUMBER
                         ,EXTD_COST IN NUMBER
                         ,C_EXT_PRECISION IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    DECLARE
      IN_QTY NUMBER;
      IN_EXTD_COST NUMBER;
      IN_ROUND_AT NUMBER;
      OUT_COST NUMBER;
    BEGIN
      IN_QTY := RPT_QTY;
      IN_EXTD_COST := EXTD_COST;
      IN_ROUND_AT := C_EXT_PRECISION;
      IF IN_QTY = 0 THEN
        OUT_COST := ROUND(0
                         ,IN_ROUND_AT);
      ELSE
        OUT_COST := ROUND((IN_EXTD_COST / IN_QTY)
                         ,IN_ROUND_AT);
      END IF;
      RETURN (OUT_COST);
    END;
    RETURN NULL;
  END CALC_UNIT_COST;

  FUNCTION C_SERIAL_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SERIAL_DETAIL = 1 THEN
      RETURN (' and  mtln.serial_transaction_id  = mut.transaction_id(+) ');
    ELSE
      RETURN ('  ');
    END IF;
    RETURN NULL;
  END C_SERIAL_WHEREFORMULA;

  FUNCTION C_SERIAL_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SERIAL_DETAIL = 1 THEN
      RETURN (' ,  mtl_unit_transactions mut ');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_SERIAL_FROMFORMULA;

  FUNCTION C_SERIAL_COLUMNFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SERIAL_DETAIL = 1 THEN
      RETURN (' mut.serial_number ');
    ELSE
      RETURN ('''X''');
    END IF;
    RETURN NULL;
  END C_SERIAL_COLUMNFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_TXN_SOURCE_TYPE_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID IS NOT NULL THEN
        RETURN (' and  mtln.transaction_source_type_id  = ' || TO_CHAR(P_TXN_SOURCE_TYPE_ID));
      END IF;
    END;
    RETURN '  ';
  END C_TXN_SOURCE_TYPE_WHEREFORMULA;

  FUNCTION C_SECONDARY_UOMFORMULA(BREAK_ITEM_ID IN NUMBER
                                 ,SEC_QTY IN NUMBER
                                 ,SECONDARY_UOM_CODE IN VARCHAR2) RETURN CHAR IS
    CURSOR GET_ITEM_TRACK IS
      SELECT
        TRACKING_QUANTITY_IND
      FROM
        MTL_SYSTEM_ITEMS
      WHERE INVENTORY_ITEM_ID = BREAK_ITEM_ID
        AND ORGANIZATION_ID = P_ORG;
    L_TRACKING_QUANTITY_IND VARCHAR2(30);
    L_UOM_CODE VARCHAR2(10);
  BEGIN
    OPEN GET_ITEM_TRACK;
    FETCH GET_ITEM_TRACK
     INTO L_TRACKING_QUANTITY_IND;
    CLOSE GET_ITEM_TRACK;
    IF L_TRACKING_QUANTITY_IND = 'PS' THEN
      CP_SEC_QTY := SEC_QTY;
      L_UOM_CODE := SECONDARY_UOM_CODE;
    ELSE
      CP_SEC_QTY := NULL;
      L_UOM_CODE := NULL;
    END IF;
    RETURN L_UOM_CODE;
  END C_SECONDARY_UOMFORMULA;

  FUNCTION CP_SEC_QTY_P RETURN NUMBER IS
  BEGIN
    RETURN CP_SEC_QTY;
  END CP_SEC_QTY_P;

END INV_INVTRLNT_XMLP_PKG;



/
