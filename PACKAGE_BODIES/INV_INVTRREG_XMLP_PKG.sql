--------------------------------------------------------
--  DDL for Package Body INV_INVTRREG_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVTRREG_XMLP_PKG" AS
/* $Header: INVTRREGB.pls 120.2 2008/01/08 06:46:51 dwkrishn noship $ */
  FUNCTION P_STRUCT_NUMVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_STRUCT_NUMVALIDTRIGGER;
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
    RETURN ('  ');
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
    RETURN ('  ');
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
    RETURN ('  ');
  END WHERE_TXN_TYPE;
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      P_ITEM_ORDER_BY := nvl(P_ITEM_ORDER_BY,1);
      P_CATG_ORDER_BY := nvl(P_CATG_ORDER_BY,1);
      QTY_PRECISION:= inv_common_xmlp_pkg.get_precision(P_qty_precision);
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
        RETURN ('and mmt.transaction_source_id = mkts.sales_order_id  and ' || P_SOURCE_WHERE);
      ELSE
        IF P_TXN_SOURCE_TYPE_ID = 3 AND (P_TXN_SOURCE_LO IS NOT NULL OR P_TXN_SOURCE_HI IS NOT NULL) THEN
          RETURN ('and mmt.transaction_source_id = glc.code_combination_id and ' || P_SOURCE_WHERE);
        ELSE
          IF P_TXN_SOURCE_TYPE_ID = 6 AND (P_TXN_SOURCE_LO IS NOT NULL OR P_TXN_SOURCE_HI IS NOT NULL) THEN
            RETURN ('and mmt.transaction_source_id = mdsp.disposition_id
                           and ' || P_SOURCE_WHERE);
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 1 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mmt.transaction_source_id = poh.po_header_id
                 	and poh.segment1 between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mmt.transaction_source_id = poh.po_header_id
                   	and poh.segment1 >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mmt.transaction_source_id = poh.po_header_id
                     	and poh.segment1 <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 5 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mmt.transaction_source_id = wipe.wip_entity_id
                 	and wipe.wip_entity_name between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mmt.transaction_source_id = wipe.wip_entity_id
                           and wipe.wip_entity_name >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mmt.transaction_source_id = wipe.wip_entity_id
                             and wipe.wip_entity_name <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 7 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mmt.transaction_source_id = porh.requisition_header_id
                 	and porh.segment1 between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mmt.transaction_source_id = porh.requisition_header_id
                   	and porh.segment1 >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mmt.transaction_source_id = porh.requisition_header_id
                     	and porh.segment1 <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 9 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mmt.transaction_source_id = CCH.cycle_count_header_id
                 	and CCH.cycle_count_header_name between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mmt.transaction_source_id = CCH.cycle_count_header_id
                   	and CCH.cycle_count_header_name >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mmt.transaction_source_id = CCH.cycle_count_header_id
                     	and CCH.cycle_count_header_name <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 10 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mmt.transaction_source_id = mpi.physical_inventory_id
                 	and mpi.physical_inventory_name between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mmt.transaction_source_id = mpi.physical_inventory_id
                   	and mpi.physical_inventory_name >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mmt.transaction_source_id = mpi.physical_inventory_id
                     	and mpi.physical_inventory_name <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 11 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mmt.transaction_source_id = cupd.cost_update_id
                 	and cupd.description between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mmt.transaction_source_id = cupd.cost_update_id
                   	and cupd.description between >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mmt.transaction_source_id = cupd.cost_update_id
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
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID = 4 THEN
        IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mmt.transaction_source_id = mtrh.header_id
                       	and mtrh.request_number between ''' || P_TXN_SOURCE_LO || ''' and ''' || P_TXN_SOURCE_HI || ''' ');
        ELSE
          IF P_TXN_SOURCE_HI IS NULL AND P_TXN_SOURCE_LO IS NOT NULL THEN
            RETURN ('and mmt.transaction_source_id = mtrh.header_id
                   	and mtrh.request_number  >= ''' || P_TXN_SOURCE_LO || ''' ');
          ELSE
            IF P_TXN_SOURCE_HI IS NOT NULL AND P_TXN_SOURCE_LO IS NULL THEN
              RETURN ('and mmt.transaction_source_id = mtrh.header_id
                     	and mtrh.request_number <= ''' || P_TXN_SOURCE_HI || ''' ');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    RETURN ('  ');
  END C_SOURCE_WHEREFORMULA;
  FUNCTION C_TYPE_BREAK_COLUMNFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_BREAK_ID = 4 THEN
      RETURN (' mtst.transaction_source_type_name ');
    ELSE
      RETURN (' mtxt1.transaction_type_name ');
    END IF;
    RETURN NULL;
  END C_TYPE_BREAK_COLUMNFORMULA;
  FUNCTION C_TYPE_BREAK_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_BREAK_ID = 4 THEN
      RETURN (' , MTL_TXN_SOURCE_TYPES mtst ');
    ELSE
      RETURN (' , MTL_TRANSACTION_TYPES mtxt1 ');
    END IF;
    RETURN NULL;
  END C_TYPE_BREAK_FROMFORMULA;
  FUNCTION C_TYPE_BREAK_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_BREAK_ID = 4 THEN
      RETURN (' and mmt.transaction_source_type_id = mtst.transaction_source_type_id ');
    ELSE
      RETURN (' and mmt.transaction_type_id = mtxt1.transaction_type_id ');
    END IF;
    RETURN ('  ');
  END C_TYPE_BREAK_WHEREFORMULA;
  FUNCTION C_RPT_DATE_CUR_TITLEFORMULA(C_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
/*    RETURN (' From ' || TO_CHAR(P_TXN_DATE_LO
                  ,'DD-MON-RRRR') || ' to ' || TO_CHAR(P_TXN_DATE_HI
                  ,'DD-MON-RRRR') || ' (' || C_CURRENCY_CODE || ')');*/
      RETURN (' From ' || TO_CHAR(P_TXN_DATE_LO
                  ,'DD-MON-RRRR') || ' to ' || TO_CHAR(LP_TXN_DATE_HI
                  ,'DD-MON-RRRR') || ' (' || C_CURRENCY_CODE || ')');
  END C_RPT_DATE_CUR_TITLEFORMULA;
  FUNCTION C_ORDER_BYFORMULA RETURN VARCHAR2 IS
  BEGIN
   IF P_BREAK_ID = 1 THEN
     RETURN (' order by ' || P_ITEM_ORDER_BY || ' , mmt.transaction_date, mmt.revision');
    ELSE
      IF P_BREAK_ID = 2 THEN
        RETURN (' order by  mmt.transaction_date, ' || P_ITEM_ORDER_BY || ' ,mmt.revision');
      ELSE
        IF P_BREAK_ID = 3 THEN
          RETURN (' order by mtxt1.transaction_type_name, mmt.transaction_source_id,
                 mmt.transaction_source_name, mmt.transaction_date,  ' || P_ITEM_ORDER_BY);
        ELSE
          IF P_BREAK_ID = 4 THEN
            RETURN (' order by
                 mtst.transaction_source_type_name, mmt.transaction_source_id,mmt.transaction_source_name, mmt.transaction_date, ' || P_ITEM_ORDER_BY);
          ELSE
            IF P_BREAK_ID = 5 THEN
              RETURN (' order by mtr.reason_name, mmt.transaction_date, ' || P_ITEM_ORDER_BY);
            ELSE
              IF P_BREAK_ID = 6 THEN
                RETURN (' order by mmt.subinventory_code, mmt.transaction_date, ' || P_ITEM_ORDER_BY);
              ELSE
               RETURN (' order by ' || P_CATG_ORDER_BY || ' ,  mmt.transaction_date, ' || P_ITEM_ORDER_BY);
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
    RETURN (' ');
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
  FUNCTION CALC_UNIT_COST(UNROUNDED_QTY IN NUMBER
                         ,UNROUNDED_TOT_COST IN NUMBER
                         ,C_EXT_PRECISION IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    DECLARE
      IN_QTY NUMBER;
      IN_EXTD_COST NUMBER;
      IN_ROUND_AT NUMBER;
      OUT_COST NUMBER;
    BEGIN
      IN_QTY := UNROUNDED_QTY;
      IN_EXTD_COST := UNROUNDED_TOT_COST;
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
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    /*P_TXN_DATE_HI := TRUNC(P_TXN_DATE_HI);
    P_TXN_DATE_HI := TO_DATE(TO_CHAR(P_TXN_DATE_HI
                                    ,'DD-MON-RRRR') || ' 23:59:59'
                            ,'DD-MON-YYYY HH24:MI:SS');
			    */
SELECT ARGUMENT6, ARGUMENT7 INTO LP_TXN_DATE_LO1,LP_TXN_DATE_HI1 FROM FND_CONCURRENT_REQUESTS
	WHERE REQUEST_ID=FND_GLOBAL.CONC_REQUEST_ID;
LP_TXN_DATE_HI1 := SUBSTR(LP_TXN_DATE_HI1, 1, 10);
LP_TXN_DATE_LO1 := SUBSTR(LP_TXN_DATE_LO1, 1, 10);
    LP_TXN_DATE_HI := TO_DATE(LP_TXN_DATE_HI1 || ' 23:59:59'
                            ,'YYYY/MM/DD HH24:MI:SS');
    LP_TXN_DATE_LO := TO_DATE(LP_TXN_DATE_LO1 || ' 00:00:00'
                            ,'YYYY/MM/DD HH24:MI:SS');
    RETURN (TRUE);
  END AFTERPFORM;
  FUNCTION C_SOURCE_TYPE_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_TXN_SOURCE_TYPE_ID IS NOT NULL THEN
        RETURN (' and  mmt.transaction_source_type_id  = ' || TO_CHAR(P_TXN_SOURCE_TYPE_ID));
      END IF;
    END;
    RETURN ('  ');
  END C_SOURCE_TYPE_WHEREFORMULA;
  FUNCTION C_BREAK_DATE_VALUEFORMULA(BREAK_COLUMN IN VARCHAR2) RETURN DATE IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(BREAK_COLUMN)*/NULL;
      /*SRW.REFERENCE(P_BREAK_ID)*/NULL;
      IF (P_BREAK_ID <> 2) THEN
        RETURN (TO_DATE('01-01-1901','dd-mm-yyyy'));
      ELSE
        RETURN (TO_DATE(BREAK_COLUMN,'J'));
      END IF;
    END;
    RETURN ('');
  END C_BREAK_DATE_VALUEFORMULA;
END INV_INVTRREG_XMLP_PKG;



/
