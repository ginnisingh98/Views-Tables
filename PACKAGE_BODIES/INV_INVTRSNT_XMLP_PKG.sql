--------------------------------------------------------
--  DDL for Package Body INV_INVTRSNT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVTRSNT_XMLP_PKG" AS
/* $Header: INVTRSNTB.pls 120.1 2007/12/25 11:13:35 dwkrishn noship $ */
  FUNCTION P_STRUCT_NUMVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_STRUCT_NUMVALIDTRIGGER;

  FUNCTION WHERE_SERIAL RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      LO VARCHAR2(30);
      HI VARCHAR2(30);
    BEGIN
      LO := P_SERIAL_LO;
      HI := P_SERIAL_HI;
      IF P_SERIAL_LO IS NULL AND P_SERIAL_HI IS NULL THEN
        RETURN ('  ');
      ELSE
        IF P_SERIAL_LO IS NOT NULL AND P_SERIAL_HI IS NULL THEN
          RETURN (' and mut.serial_number >= ''' || LO || ''' ');
        ELSE
          IF P_SERIAL_LO IS NULL AND P_SERIAL_HI IS NOT NULL THEN
            RETURN (' and mut.serial_number <= ''' || HI || ''' ');
          ELSE
            RETURN (' and mut.serial_number between ''' || LO || '''  and  ''' || HI || ''' ');
          END IF;
        END IF;
      END IF;
    END;
    RETURN NULL;
  END WHERE_SERIAL;

  FUNCTION C_LOT_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_LOT_DETAIL <> 1 THEN
        NULL;
      ELSE
        RETURN ('  ,  MTL_TRANSACTION_LOT_NUMBERS MTLN ');
      END IF;
    END;
    RETURN '  ';
  END C_LOT_FROMFORMULA;

  FUNCTION C_LOT_COLUMNFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_LOT_DETAIL <> 1 THEN
        RETURN ('''Y''');
      ELSE
        RETURN (' mtln.lot_number ');
      END IF;
    END;
    RETURN NULL;
  END C_LOT_COLUMNFORMULA;

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
    RETURN '   ';
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
          RETURN ('  AND mut.subinventory_code >= ''' || LO || ''' ');
        ELSE
          IF P_SUBINV_LO IS NULL AND P_SUBINV_HI IS NOT NULL THEN
            RETURN ('  AND mut.subinventory_code <=  ''' || HI || ''' ');
          ELSE
            RETURN ('  AND mut.subinventory_code between  ''' || LO || '''  and ''' || HI || ''' ');
          END IF;
        END IF;
      END IF;
    END;
    RETURN '   ';
  END WHERE_SUBINV;

  FUNCTION WHERE_TXN_TYPE RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      LO VARCHAR2(240);
      HI VARCHAR2(240);
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
    RETURN '   ';
  END WHERE_TXN_TYPE;

  FUNCTION C_DATE_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_TXN_DATE_LO IS NULL AND P_TXN_DATE_HI IS NULL THEN
        NULL;
      ELSE
        IF P_TXN_DATE_LO IS NOT NULL AND P_TXN_DATE_HI IS NULL THEN
          RETURN (' AND  mmt.transaction_date >= ' || TO_CHAR(P_TXN_DATE_LO
                        ,'DD-MON-RRRR'));
        ELSE
          IF P_TXN_DATE_LO IS NULL AND P_TXN_DATE_HI IS NOT NULL THEN
            RETURN (' AND mmt.transaction_date <= ' || TO_CHAR(P_TXN_DATE_HI
                          ,'DD-MON-RRRR'));
          ELSE
            RETURN (' and ( mmt.transaction_date between ' || TO_CHAR(P_TXN_DATE_LO
                          ,'DD-MON-RRRR') || ' and ' || TO_CHAR(P_TXN_DATE_HI
                          ,'DD-MON-RRRR') || ' )');
          END IF;
        END IF;
      END IF;
    END;
    RETURN '   ';
  END C_DATE_WHEREFORMULA;

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
      P_ORG_ID_CHAR VARCHAR2(100) := TO_CHAR(P_G_ORG);
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
        RETURN ('and mut.transaction_source_id = mkts.sales_order_id
                       and ' || P_SOURCE_WHERE);
      ELSE
        IF P_TXN_SOURCE_TYPE_ID = 3 AND (P_TXN_SOURCE_LO IS NOT NULL OR P_TXN_SOURCE_HI IS NOT NULL) THEN
          RETURN ('and mut.transaction_source_id = gl1.code_combination_id
                         and ' || P_SOURCE_WHERE);
        ELSE
          IF P_TXN_SOURCE_TYPE_ID = 6 AND (P_TXN_SOURCE_LO IS NOT NULL OR P_TXN_SOURCE_HI IS NOT NULL) THEN
            RETURN ('and mut.transaction_source_id = mdsp.disposition_id
                           and ' || P_SOURCE_WHERE);
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 1 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mut.transaction_source_id = poh.po_header_id
                 	and poh.segment1 between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mut.transaction_source_id = poh.po_header_id
                   	and poh.segment1 >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mut.transaction_source_id = poh.po_header_id
                     	and poh.segment1 <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 5 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mut.transaction_source_id = wip1.wip_entity_id
                 	and wip1.wip_entity_name between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mut.transaction_source_id = wip1.wip_entity_id
                           and wip1.wip_entity_name >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mut.transaction_source_id = wip1.wip_entity_id
                             and wip1.wip_entity_name <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 7 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mut.transaction_source_id = porh.requisition_header_id
                 	and porh.segment1 between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mut.transaction_source_id = porh.requisition_header_id
                   	and porh.segment1 >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mut.transaction_source_id = porh.requisition_header_id
                     	and porh.segment1 <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 9 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mut.transaction_source_id = CCH.cycle_count_header_id
                 	and CCH.cycle_count_header_name between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mut.transaction_source_id = CCH.cycle_count_header_id
                   	and CCH.cycle_count_header_name >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mut.transaction_source_id = CCH.cycle_count_header_id
                     	and CCH.cycle_count_header_name <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 10 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mut.transaction_source_id = MPI.physical_inventory_id
                 	and MPI.physical_inventory_name between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mut.transaction_source_id = MPI.physical_inventory_id
                   	and MPI.physical_inventory_name >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mut.transaction_source_id = MPI.physical_inventory_id
                     	and MPI.physical_inventory_name <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 11 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mut.transaction_source_id = cupd.cost_update_id
                 	and cupd.description between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mut.transaction_source_id = cupd.cost_update_id
                   	and cupd.description between >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mut.transaction_source_id = cupd.cost_update_id
                     	and cupd.description <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID >= 13 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mmt.transaction_source_name between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mmt.transaction_source_name >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mmt.transaction_source_name <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    RETURN '  ';
  END C_SOURCE_WHEREFORMULA;

  FUNCTION C_TYPE_BREAK_COLUMNFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_BREAK_ID = 4 THEN
      RETURN (' mtst.transaction_source_type_name ');
    ELSE
      RETURN (' mtxt.transaction_type_name ');
    END IF;
    RETURN NULL;
  END C_TYPE_BREAK_COLUMNFORMULA;

  FUNCTION C_TYPE_BREAK_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_BREAK_ID = 4 THEN
      RETURN (' MTL_TXN_SOURCE_TYPES mtst , ');
    ELSE
      RETURN ('  ');
    END IF;
    RETURN NULL;
  END C_TYPE_BREAK_FROMFORMULA;

  FUNCTION C_TYPE_BREAK_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_BREAK_ID = 4 THEN
      RETURN (' and mmt.transaction_source_type_id = mtst.transaction_source_type_id ');
    ELSE
      RETURN (' and mmt.transaction_type_id = mtxt.transaction_type_id ');
    END IF;
    RETURN NULL;
  END C_TYPE_BREAK_WHEREFORMULA;

  FUNCTION C_REPORT_DATE_CURRENCY_TITFORM(C_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (' From ' || TO_CHAR(P_TXN_DATE_LO
                  ,'DD-MON-YYYY') || ' to ' || TO_CHAR(P_TXN_DATE_HI
                  ,'DD-MON-YYYY') || ' (' || C_CURRENCY_CODE || ')');
  END C_REPORT_DATE_CURRENCY_TITFORM;

  FUNCTION C_ORDER_BYFORMULA RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(P_ITEM_ORDER_BY)*/NULL;
    /*SRW.REFERENCE(P_CATG_ORDER_BY)*/NULL;
    IF P_BREAK_ID = 1 THEN
      RETURN (' order by ' || P_ITEM_ORDER_BY || ' , mut.serial_number, mut.transaction_date, mut.transaction_id ');
    ELSE
      IF P_BREAK_ID = 2 THEN
        RETURN (' order by  mut.transaction_date,  ' || P_ITEM_ORDER_BY || ' , mut.serial_number, mut.transaction_id ');
      ELSE
        RETURN (' order by mut.serial_number,  ' || P_ITEM_ORDER_BY || '  , mut.transaction_date, mut.transaction_id ');
      END IF;
    END IF;
    RETURN NULL;
  END C_ORDER_BYFORMULA;

  FUNCTION P_MDSP_ORDER_BYVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_MDSP_ORDER_BYVALIDTRIGGER;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CALC_UNIT_COST(TOT_QTY IN NUMBER
                         ,EXTD_COST IN NUMBER
                         ,C_EXT_PRECISION IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    DECLARE
      IN_QTY NUMBER;
      IN_EXTD_COST NUMBER;
      IN_ROUND_AT NUMBER;
      OUT_COST NUMBER;
    BEGIN
      IN_QTY := TOT_QTY;
      IN_EXTD_COST := EXTD_COST;
      IN_ROUND_AT := C_EXT_PRECISION;
      IF IN_QTY = 0 THEN
        OUT_COST := ROUND(0
                         ,IN_ROUND_AT);
      ELSE
        OUT_COST := ROUND(ABS(EXTD_COST)
                         ,IN_ROUND_AT);
      END IF;
      RETURN (OUT_COST);
    END;
    RETURN NULL;
  END CALC_UNIT_COST;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_SOURCE_TYPE_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(P_TXN_SOURCE_TYPE_ID)*/NULL;
      IF P_TXN_SOURCE_TYPE_ID IS NOT NULL THEN
        RETURN (' and mut.transaction_source_type_id = ' || P_TXN_SOURCE_TYPE_ID);
      END IF;
    END;
    RETURN '   ';
  END C_SOURCE_TYPE_WHEREFORMULA;

END INV_INVTRSNT_XMLP_PKG;



/
