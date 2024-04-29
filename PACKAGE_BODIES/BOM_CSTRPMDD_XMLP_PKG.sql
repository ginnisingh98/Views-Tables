--------------------------------------------------------
--  DDL for Package Body BOM_CSTRPMDD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTRPMDD_XMLP_PKG" AS
/* $Header: CSTRPMDDB.pls 120.0 2007/12/24 10:14:13 dwkrishn noship $ */
  FUNCTION C_SOURCE_TYPE_NAMEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      SOURCE_TYPE_ID NUMBER;
      SOURCE_TYPE_NAME VARCHAR2(30);
    BEGIN
      SOURCE_TYPE_ID := P_SOURCE_TYPE_ID;
      IF P_SOURCE_TYPE_ID IS NOT NULL THEN
        SELECT
          TRANSACTION_SOURCE_TYPE_NAME
        INTO SOURCE_TYPE_NAME
        FROM
          MTL_TXN_SOURCE_TYPES
        WHERE TRANSACTION_SOURCE_TYPE_ID = SOURCE_TYPE_ID;
        RETURN (SOURCE_TYPE_NAME);
      ELSE
        RETURN ('');
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('No Data');
    END;
    RETURN NULL;
  END C_SOURCE_TYPE_NAMEFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    IF P_SORT_ID = 1 THEN
      /*SRW.SET_MAXROW('Q_acct_item'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_item_acct'
                    ,0)*/NULL;
    ELSIF P_SORT_ID = 2 THEN
      /*SRW.SET_MAXROW('Q_item_acct'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_acct'
                    ,0)*/NULL;
    ELSIF P_SORT_ID = 3 THEN
      /*SRW.SET_MAXROW('Q_acct'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_acct_item'
                    ,0)*/NULL;
    ELSE
      NULL;
    END IF;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in SRWINIT')*/NULL;
        RAISE;
    END;
    BEGIN
      SELECT
        FRV.RESPONSIBILITY_NAME,
        TO_CHAR(FCR.REQUEST_DATE
               ,'YYYY/MM/DD HH24:MI:SS'),
        FAV.APPLICATION_NAME,
        FU.USER_NAME
      INTO CP_RESPONSIBILITY,CP_REQUEST_TIME,CP_APPLICATION,CP_REQUESTED_BY
      FROM
        FND_CONCURRENT_REQUESTS FCR,
        FND_RESPONSIBILITY_VL FRV,
        FND_APPLICATION_VL FAV,
        FND_USER FU
      WHERE FCR.REQUEST_ID = P_CONC_REQUEST_ID
        AND FCR.RESPONSIBILITY_APPLICATION_ID = FRV.APPLICATION_ID
        AND FCR.RESPONSIBILITY_ID = FRV.RESPONSIBILITY_ID
        AND FRV.APPLICATION_ID = FAV.APPLICATION_ID
        AND FU.USER_ID = FCR.REQUESTED_BY;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        /*SRW.MESSAGE(30
                   ,'Failed Request By and Request time Init, no data')*/NULL;
      WHEN OTHERS THEN
        /*SRW.MESSAGE(31
                   ,'Failed Request By and Request time Init.')*/NULL;
    END;
    BEGIN
      SELECT
        DISTINCT
        XFI.NAME,
        CCG.COST_GROUP,
        CCT.COST_TYPE,
        NVL(FC.PRECISION
           ,2),
        NVL(FC.EXTENDED_PRECISION
           ,5),
        CPP.PERIOD_NAME
      INTO CP_LEGAL_ENTITY,CP_COST_GROUP,CP_COST_TYPE,CP_PRECISION,CP_EXT_PRECISION,CP_PERIOD_NAME
      FROM
        CST_PAC_PERIODS CPP,
        XLE_FIRSTPARTY_INFORMATION_V XFI,
        FND_CURRENCIES FC,
        CST_COST_GROUPS CCG,
        CST_COST_TYPES CCT
      WHERE XFI.LEGAL_ENTITY_ID = P_LEGAL_ENTITY_ID
        AND CPP.PAC_PERIOD_ID = P_PERIOD_ID
        AND FC.CURRENCY_CODE = P_CURRENCY_CODE
        AND CCG.COST_GROUP_ID = P_COST_GROUP_ID
        AND CCT.COST_TYPE_ID = P_COST_TYPE_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        /*SRW.MESSAGE(30
                   ,'Failed in Legal Entity Init. no data')*/NULL;
      WHEN OTHERS THEN
        /*SRW.MESSAGE(31
                   ,'Failed in legal entity Init.')*/NULL;
    END;
    Qty_precision := bom_common_xmlp_pkg.get_precision(CP_PRECISION);
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(2
                   ,'Failed in MSTK/Select')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(3
                   ,'Failed in GL#/Select')*/NULL;
        RAISE;
    END;
    BEGIN
      IF P_ACCT_LO IS NOT NULL OR P_ACCT_HI IS NOT NULL THEN
        NULL;
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(4
                   ,'Failed in GL#/Where')*/NULL;
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
        /*SRW.MESSAGE(5
                   ,'Failed in MSTK/Where')*/NULL;
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
        /*SRW.MESSAGE(6
                   ,'Failed in MCAT/Where')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(9
                   ,'Failed in MKTS/Sel')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(10
                   ,'Failed in MDSP/Sel')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(11
                   ,'Failed in GL#/Sel')*/NULL;
        RAISE;
    END;
    BEGIN
      IF P_SOURCE_TYPE_ID in (2,8,12) THEN
        BEGIN
          IF P_SOURCE_HI IS NOT NULL OR P_SOURCE_LO IS NOT NULL THEN
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
      ELSIF P_SOURCE_TYPE_ID = 6 THEN
        BEGIN
          IF P_SOURCE_HI IS NOT NULL OR P_SOURCE_LO IS NOT NULL THEN
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
      ELSIF P_SOURCE_TYPE_ID = 3 THEN
        BEGIN
          IF P_SOURCE_HI IS NOT NULL OR P_SOURCE_LO IS NOT NULL THEN
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
    END;
    BEGIN
      IF P_SOURCE_TYPE_ID in (2,8,12) AND (P_SOURCE_LO IS NOT NULL OR P_SOURCE_HI IS NOT NULL) THEN
        P_SOURCE_WHERE2 := 'AND mmt.transaction_source_id = mkts.sales_order_id
                                     AND ' || P_SOURCE_WHERE;
      ELSIF P_SOURCE_TYPE_ID = 3 AND (P_SOURCE_LO IS NOT NULL OR P_SOURCE_HI IS NOT NULL) THEN
        P_SOURCE_WHERE2 := 'AND mmt.transaction_source_id = glc.code_combination_id
                                     AND ' || P_SOURCE_WHERE;
      ELSIF P_SOURCE_TYPE_ID = 6 AND (P_SOURCE_LO IS NOT NULL OR P_SOURCE_HI IS NOT NULL) THEN
        P_SOURCE_WHERE2 := 'AND mmt.transaction_source_id = mdsp.disposition_id
                                      and ' || P_SOURCE_WHERE;
      END IF;
    END;
    BEGIN
      SELECT
        MEANING
      INTO CP_SORT_BY_COV
      FROM
        MFG_LOOKUPS
      WHERE LOOKUP_TYPE = 'CST_SRS_PAC_BOM_CSTRPMDD_XMLP_PKG_SORT'
        AND LOOKUP_CODE = P_SORT_ID;
      SELECT
        MEANING
      INTO CP_TYPE_OPTION_COV
      FROM
        MFG_LOOKUPS
      WHERE LOOKUP_TYPE = 'INV_SRS_DST_TYPE'
        AND LOOKUP_CODE = P_TYPE_OPTION
        AND ENABLED_FLAG = 'Y';
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(2
                   ,'Failed in initializing sort by for cover page')*/NULL;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in SRWEXIT')*/NULL;
    END;
    RETURN (TRUE);
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_ACCT_PAD0FORMULA(C_ACCT_PAD0 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_ACCT_PAD0);
  END C_ACCT_PAD0FORMULA;

  FUNCTION C_ACCT_PAD1FORMULA(C_ACCT_PAD1 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_ACCT_PAD1);
  END C_ACCT_PAD1FORMULA;

  FUNCTION C_ACCT_PAD2FORMULA(C_ACCT_PAD2 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_ACCT_PAD2);
  END C_ACCT_PAD2FORMULA;

  FUNCTION C_ITEM_PAD1FORMULA(C_ITEM_PAD1 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_ITEM_PAD1);
  END C_ITEM_PAD1FORMULA;

  FUNCTION C_ITEM_PAD2FORMULA(C_ITEM_PAD2 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_ITEM_PAD2);
  END C_ITEM_PAD2FORMULA;

  FUNCTION C_SOURCE_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_SOURCE_TYPE_ID = 1 THEN
        IF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('AND mmt.transaction_source_id = poh.po_header_id
                 	    AND poh.segment1 BETWEEN ''' || P_SOURCE_LO || ''' AND ''' || P_SOURCE_HI || ''' ');
        ELSIF P_SOURCE_HI IS NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('AND mmt.transaction_source_id = poh.po_header_id
                             AND poh.segment1 >= ''' || P_SOURCE_LO || ''' ');
        ELSIF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NULL THEN
          RETURN ('AND mmt.transaction_source_id = poh.po_header_id
                             AND poh.segment1 <= ''' || P_SOURCE_HI || ''' ');
        END IF;
      END IF;
    END;
    BEGIN
      IF P_SOURCE_TYPE_ID = 5 THEN
        IF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('AND mmt.transaction_source_id = wipe.wip_entity_id
                             AND wipe.wip_entity_name BETWEEN ''' || P_SOURCE_LO || '''
                                                     AND ''' || P_SOURCE_HI || ''' ');
        ELSIF P_SOURCE_HI IS NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('AND mmt.transaction_source_id = wipe.wip_entity_id
                             AND wipe.wip_entity_name >= ''' || P_SOURCE_LO || ''' ');
        ELSIF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NULL THEN
          RETURN ('AND mmt.transaction_source_id = wipe.wip_entity_id
                             AND wipe.wip_entity_name <= ''' || P_SOURCE_HI || ''' ');
        END IF;
      END IF;
    END;
    BEGIN
      IF P_SOURCE_TYPE_ID = 7 THEN
        IF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('AND mmt.transaction_source_id = prh.requisition_header_id
                 	    AND prh.segment1 BETWEEN ''' || P_SOURCE_LO || ''' AND ''' || P_SOURCE_HI || ''' ');
        ELSIF P_SOURCE_HI IS NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('AND mmt.transaction_source_id = prh.requisition_header_id
                 	    AND prh.segment1 >= ''' || P_SOURCE_LO || ''' ');
        ELSIF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NULL THEN
          RETURN ('AND mmt.transaction_source_id = prh.requisition_header_id
                 	    AND prh.segment1 <= ''' || P_SOURCE_HI || ''' ');
        END IF;
      END IF;
    END;
    BEGIN
      IF P_SOURCE_TYPE_ID = 9 THEN
        IF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('AND mmt.transaction_source_id = cch.cycle_count_header_id
                 	    AND cch.cycle_count_header_name BETWEEN ''' || P_SOURCE_LO || '''
                                                             AND ''' || P_SOURCE_HI || ''' ');
        ELSIF P_SOURCE_HI IS NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('AND mmt.transaction_source_id = cch.cycle_count_header_id
                 	    AND cch.cycle_count_header_name >= ''' || P_SOURCE_LO || ''' ');
        ELSIF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NULL THEN
          RETURN ('AND mmt.transaction_source_id = cch.cycle_count_header_id
                 	    AND cch.cycle_count_header_name <= ''' || P_SOURCE_HI || ''' ');
        END IF;
      END IF;
    END;
    BEGIN
      IF P_SOURCE_TYPE_ID = 10 THEN
        IF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('AND mmt.transaction_source_id = pi.physical_inventory_id
                 	    AND pi.physical_inventory_name BETWEEN ''' || P_SOURCE_LO || '''
                                                            AND ''' || P_SOURCE_HI || ''' ');
        ELSIF P_SOURCE_HI IS NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('AND mmt.transaction_source_id = pi.physical_inventory_id
                 	    AND pi.physical_inventory_name >= ''' || P_SOURCE_LO || ''' ');
        ELSIF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NULL THEN
          RETURN ('AND mmt.transaction_source_id = pi.physical_inventory_id
                 	    AND pi.physical_inventory_name <= ''' || P_SOURCE_HI || ''' ');
        END IF;
      END IF;
    END;
    BEGIN
      IF P_SOURCE_TYPE_ID = 11 THEN
        IF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('AND mmt.transaction_source_id = cst.cost_update_id
                 	    AND cst.description BETWEEN ''' || P_SOURCE_LO || ''' AND ''' || P_SOURCE_HI || ''' ');
        ELSIF P_SOURCE_HI IS NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('AND mmt.transaction_source_id = cst.cost_update_id
                 	    AND cst.description BETWEEN >= ''' || P_SOURCE_LO || ''' ');
        ELSIF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NULL THEN
          RETURN ('AND mmt.transaction_source_id = cst.cost_update_id
                 	    AND cst.description <= ''' || P_SOURCE_HI || ''' ');
        END IF;
      END IF;
    END;
    BEGIN
      IF P_SOURCE_TYPE_ID >= 13 THEN
        IF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('AND mmt.transaction_source_name BETWEEN ''' || P_SOURCE_LO || '''
                                                             AND ''' || P_SOURCE_HI || ''' ');
        ELSIF P_SOURCE_HI IS NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('AND mmt.transaction_source_name >= ''' || P_SOURCE_LO || ''' ');
        ELSIF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NULL THEN
          RETURN ('AND mmt.transaction_source_name <= ''' || P_SOURCE_HI || ''' ');
        END IF;
      END IF;
    END;
    RETURN ' ';
  END C_SOURCE_WHEREFORMULA;

  FUNCTION WHERE_VALUE RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      HI VARCHAR2(16);
      LO VARCHAR2(16);
    BEGIN
      HI := TO_CHAR(ABS(P_VALUE_HI));
      LO := TO_CHAR(ABS(P_VALUE_LO));
      IF P_VALUE_HI IS NOT NULL AND P_VALUE_LO IS NOT NULL THEN
        RETURN ('AND nvl(nvl(cal.accounted_dr,cal.accounted_cr),0)
                               BETWEEN ''' || LO || ''' AND ''' || HI || '''');
      ELSIF P_VALUE_HI IS NULL AND P_VALUE_LO IS NOT NULL THEN
        RETURN ('AND nvl(nvl(cal.accounted_dr,cal.accounted_cr),0)
                               >= ''' || LO || ''' ');
      ELSIF P_VALUE_HI IS NOT NULL AND P_VALUE_LO IS NULL THEN
        RETURN ('AND nvl(nvl(cal.accounted_dr,cal.accounted_cr),0)
                               <= ''' || HI || '''');
      ELSE
        RETURN (' ');
      END IF;
    END;
    RETURN ' ';
  END WHERE_VALUE;

  FUNCTION C_WHERE_REASONFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_REASON_ID IS NOT NULL THEN
      RETURN ('AND mmt.reason_id = ' || TO_CHAR(P_REASON_ID));
    ELSE
      RETURN (' ');
    END IF;
    RETURN ' ';
  END C_WHERE_REASONFORMULA;

  FUNCTION C_FROM_CATFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_CAT_LO IS NOT NULL OR P_CAT_HI IS NOT NULL THEN
      RETURN (', mtl_item_categories mic, mtl_categories_b mc');
    ELSE
      RETURN (', mtl_item_categories mic');
    END IF;
    RETURN NULL;
  END C_FROM_CATFORMULA;

  FUNCTION C_WHERE_CATFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_CAT_LO IS NOT NULL OR P_CAT_HI IS NOT NULL THEN
      RETURN ('AND mmt.inventory_item_id = mic.inventory_item_id
                       AND mmt.organization_id = mic.organization_id
                       AND mic.category_set_id = ' || P_CAT_SET_ID || ' AND mic.category_id = mc.category_id');
    ELSE
      RETURN ('AND mmt.inventory_item_id = mic.inventory_item_id
                       AND mmt.organization_id = mic.organization_id
             	  AND mic.category_set_id = ' || P_CAT_SET_ID);
    END IF;
    RETURN NULL;
  END C_WHERE_CATFORMULA;

  FUNCTION C_CAT_SET_NAMEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      CAT_SET_ID NUMBER;
      CAT_SET_NAME VARCHAR2(30);
    BEGIN
      CAT_SET_ID := P_CAT_SET_ID;
      SELECT
        CATEGORY_SET_NAME
      INTO CAT_SET_NAME
      FROM
        MTL_CATEGORY_SETS
      WHERE CATEGORY_SET_ID = CAT_SET_ID;
      RETURN (CAT_SET_NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('');
      WHEN OTHERS THEN
        RETURN ('Error');
    END;
    RETURN NULL;
  END C_CAT_SET_NAMEFORMULA;

  FUNCTION C_TXN_TYPE_NAMEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      TXN_TYPE_ID NUMBER;
      TXN_TYPE_NAME VARCHAR2(30);
    BEGIN
      TXN_TYPE_ID := P_TXN_TYPE_ID;
      IF TXN_TYPE_ID IS NOT NULL THEN
        SELECT
          TRANSACTION_TYPE_NAME
        INTO TXN_TYPE_NAME
        FROM
          MTL_TRANSACTION_TYPES
        WHERE TRANSACTION_TYPE_ID = TXN_TYPE_ID;
        RETURN (TXN_TYPE_NAME);
      ELSE
        RETURN ('');
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('No Data');
    END;
    RETURN NULL;
  END C_TXN_TYPE_NAMEFORMULA;

  FUNCTION C_REASON_NAMEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      TXN_REASON_ID VARCHAR2(20);
      REASON_NAME VARCHAR2(30);
    BEGIN
      TXN_REASON_ID := P_REASON_ID;
      IF TXN_REASON_ID IS NOT NULL THEN
        SELECT
          REASON_NAME
        INTO REASON_NAME
        FROM
          MTL_TRANSACTION_REASONS
        WHERE REASON_ID = TXN_REASON_ID;
        RETURN (REASON_NAME);
      ELSE
        RETURN ('');
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('No Data');
    END;
    RETURN NULL;
  END C_REASON_NAMEFORMULA;

  FUNCTION C_TYPE_OPTIONFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_TYPE_OPTION = 1 THEN
      RETURN ('mtst.transaction_source_type_name');
    ELSE
      RETURN ('mtt.transaction_type_name');
    END IF;
    RETURN NULL;
  END C_TYPE_OPTIONFORMULA;

  FUNCTION C_FROM_TYPEFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_TYPE_OPTION = 1 THEN
      RETURN (', mtl_txn_source_types mtst');
    ELSE
      RETURN (', mtl_transaction_types mtt');
    END IF;
    RETURN NULL;
  END C_FROM_TYPEFORMULA;

  FUNCTION C_WHERE_TYPEFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_TYPE_OPTION = 1 THEN
      RETURN ('AND mmt.transaction_source_type_id
                       = mtst.transaction_source_type_id');
    ELSE
      RETURN ('AND mmt.transaction_type_id = mtt.transaction_type_id');
    END IF;
    RETURN NULL;
  END C_WHERE_TYPEFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_SOURCE_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_SOURCE_TYPE_ID = 1 AND (P_SOURCE_HI IS NOT NULL OR P_SOURCE_LO IS NOT NULL) THEN
        RETURN (', po_headers_all poh');
      END IF;
      IF P_SOURCE_TYPE_ID = 5 AND (P_SOURCE_HI IS NOT NULL OR P_SOURCE_LO IS NOT NULL) THEN
        RETURN (', wip_entities wipe');
      END IF;
      IF P_SOURCE_TYPE_ID = 7 AND (P_SOURCE_HI IS NOT NULL OR P_SOURCE_LO IS NOT NULL) THEN
        RETURN (', po_requisition_headers prh');
      END IF;
      IF P_SOURCE_TYPE_ID = 9 AND (P_SOURCE_HI IS NOT NULL OR P_SOURCE_LO IS NOT NULL) THEN
        RETURN (', mtl_cycle_count_headers cch');
      END IF;
      IF P_SOURCE_TYPE_ID = 10 AND (P_SOURCE_HI IS NOT NULL OR P_SOURCE_LO IS NOT NULL) THEN
        RETURN (', mtl_physical_inventories pi');
      END IF;
      IF P_SOURCE_TYPE_ID = 11 AND (P_SOURCE_HI IS NOT NULL OR P_SOURCE_LO IS NOT NULL) THEN
        RETURN (', cst_cost_updates cst');
      END IF;
    END;
    RETURN ' ';
  END C_SOURCE_FROMFORMULA;

  FUNCTION C_ACCT_VALUE0_RFORMULA(C_ACCT_VALUE0 IN NUMBER) RETURN NUMBER IS
    C_ACCT_VALUE0_R NUMBER;
  BEGIN
    C_ACCT_VALUE0_R := ROUND(C_ACCT_VALUE0
                            ,CP_PRECISION);
    RETURN C_ACCT_VALUE0_R;
  END C_ACCT_VALUE0_RFORMULA;

  FUNCTION VALUE_RFORMULA(VALUE IN NUMBER) RETURN NUMBER IS
    VALUE_R NUMBER;
  BEGIN
    VALUE_R := ROUND(VALUE
                    ,CP_PRECISION);
    RETURN VALUE_R;
  END VALUE_RFORMULA;

  FUNCTION C_REPORT_VALUE_RFORMULA(C_REPORT_VALUE IN NUMBER) RETURN NUMBER IS
    C_REPORT_VALUE_R NUMBER;
  BEGIN
    C_REPORT_VALUE_R := ROUND(C_REPORT_VALUE
                             ,CP_PRECISION);
    RETURN C_REPORT_VALUE_R;
  END C_REPORT_VALUE_RFORMULA;

  FUNCTION C_ACCT_VALUE1_RFORMULA(C_ACCT_VALUE1 IN NUMBER) RETURN NUMBER IS
    C_ACCT_VALUE1_R NUMBER;
  BEGIN
    C_ACCT_VALUE1_R := ROUND(C_ACCT_VALUE1
                            ,CP_PRECISION);
    RETURN C_ACCT_VALUE1_R;
  END C_ACCT_VALUE1_RFORMULA;

  FUNCTION C_ITEM_VALUE2_RFORMULA(C_ITEM_VALUE2 IN NUMBER) RETURN NUMBER IS
    C_ITEM_VALUE2_R NUMBER;
  BEGIN
    C_ITEM_VALUE2_R := ROUND(C_ITEM_VALUE2
                            ,CP_PRECISION);
    RETURN C_ITEM_VALUE2_R;
  END C_ITEM_VALUE2_RFORMULA;

  FUNCTION C_REPORT_VALUE1_RFORMULA(C_REPORT_VALUE1 IN NUMBER) RETURN NUMBER IS
    C_REPORT_VALUE1_R NUMBER;
  BEGIN
    C_REPORT_VALUE1_R := ROUND(C_REPORT_VALUE1
                              ,CP_PRECISION);
    RETURN C_REPORT_VALUE1_R;
  END C_REPORT_VALUE1_RFORMULA;

  FUNCTION C_REPORT_VALUE2_RFORMULA(C_REPORT_VALUE2 IN NUMBER) RETURN NUMBER IS
    C_REPORT_VALUE2_R NUMBER;
  BEGIN
    C_REPORT_VALUE2_R := ROUND(C_REPORT_VALUE2
                              ,CP_PRECISION);
    RETURN C_REPORT_VALUE2_R;
  END C_REPORT_VALUE2_RFORMULA;

  FUNCTION VALUE1_RFORMULA(VALUE1 IN NUMBER) RETURN NUMBER IS
    VALUE1_R NUMBER;
  BEGIN
    VALUE1_R := ROUND(VALUE1
                     ,CP_PRECISION);
    RETURN VALUE1_R;
  END VALUE1_RFORMULA;

  FUNCTION VALUE2_RFORMULA(VALUE2 IN NUMBER) RETURN NUMBER IS
    VALUE2_R NUMBER;
  BEGIN
    VALUE2_R := ROUND(VALUE2
                     ,CP_PRECISION);
    RETURN VALUE2_R;
  END VALUE2_RFORMULA;

  FUNCTION C_RT_WHERE_CATFORMULA RETURN CHAR IS
  BEGIN
    IF P_CAT_LO IS NOT NULL OR P_CAT_HI IS NOT NULL THEN
      RETURN ('AND rsl.item_id = mic.inventory_item_id
                       AND cah.organization_id = mic.organization_id
                       AND mic.category_set_id = ' || TO_CHAR(P_CAT_SET_ID) || ' AND mic.category_id = mc.category_id');
    ELSE
      RETURN ('AND rsl.item_id = mic.inventory_item_id
                       AND cah.organization_id = mic.organization_id
                       AND mic.category_set_id  = ' || TO_CHAR(P_CAT_SET_ID));
    END IF;
    RETURN ' ';
  END C_RT_WHERE_CATFORMULA;

  FUNCTION C_RT_WHERE_REASONFORMULA RETURN CHAR IS
  BEGIN
    IF P_REASON_ID IS NOT NULL THEN
      RETURN ('AND rt.reason_id = ' || TO_CHAR(P_REASON_ID));
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_RT_WHERE_REASONFORMULA;

  FUNCTION C_RT_TYPE_OPTIONFORMULA RETURN CHAR IS
  BEGIN
    IF P_TYPE_OPTION = 1 THEN
      RETURN ('rt.source_document_code');
    ELSE
      RETURN ('rt.transaction_type');
    END IF;
    RETURN NULL;
  END C_RT_TYPE_OPTIONFORMULA;

  FUNCTION C_TXN_QUANTITY(L_AE_LINE_ID IN NUMBER
                         ,L_QUANTITY IN NUMBER) RETURN NUMBER IS
    L_TXN_QUANTITY NUMBER;
    L_EVENT_TYPE VARCHAR2(15);
    L_TRANSACTION_ID NUMBER;
    L_PO_DISTRIBUTION_ID NUMBER;
    L_ACCRUAL_QTY NUMBER;
    L_ENCUM_QTY NUMBER;
    L_SERVICE_FLAG NUMBER;
    L_PO_LINE_LOCATION_ID NUMBER;
    L_SHIPMENT_QTY NUMBER;
    L_DIST_QTY NUMBER;
    L_MATCH_OPTION VARCHAR2(1);
    L_PERIOD_END_DATE DATE;
    L_RETURN_STATUS VARCHAR2(1);
    L_MSG_COUNT NUMBER;
    L_MSG_DATA VARCHAR2(240);
    L_STMT_NUM NUMBER;
    PROCESS_ERROR EXCEPTION;
  BEGIN
    L_RETURN_STATUS := CST_UTILITY_PUB.GET_RET_STS_SUCCESS;
    L_STMT_NUM := 10;
    SELECT
      CAH.AE_CATEGORY,
      CAH.ACCOUNTING_EVENT_ID,
      CAL.PO_DISTRIBUTION_ID
    INTO L_EVENT_TYPE,L_TRANSACTION_ID,L_PO_DISTRIBUTION_ID
    FROM
      CST_AE_HEADERS CAH,
      CST_AE_LINES CAL
    WHERE CAL.AE_LINE_ID = L_AE_LINE_ID
      AND CAH.AE_HEADER_ID = CAL.AE_HEADER_ID;
    IF (L_EVENT_TYPE = 'Accrual') THEN
      L_STMT_NUM := 20;
      SELECT
        PERIOD_END_DATE
      INTO L_PERIOD_END_DATE
      FROM
        CST_PAC_PERIODS CPP
      WHERE CPP.PAC_PERIOD_ID = P_PERIOD_ID;
      L_STMT_NUM := 30;
      SELECT
        DECODE(POLL.MATCHING_BASIS
              ,'AMOUNT'
              ,1
              ,0),
        POLL.LINE_LOCATION_ID,
        DECODE(POLL.MATCHING_BASIS
              ,'AMOUNT'
              ,POLL.AMOUNT - NVL(POLL.AMOUNT_CANCELLED
                 ,0)
              ,POLL.QUANTITY - NVL(POLL.QUANTITY_CANCELLED
                 ,0)),
        DECODE(POLL.MATCHING_BASIS
              ,'AMOUNT'
              ,POD.AMOUNT_ORDERED - NVL(POD.AMOUNT_CANCELLED
                 ,0)
              ,POD.QUANTITY_ORDERED - NVL(POD.QUANTITY_CANCELLED
                 ,0)),
        NVL(POLL.MATCH_OPTION
           ,'P')
      INTO L_SERVICE_FLAG,L_PO_LINE_LOCATION_ID,L_SHIPMENT_QTY,L_DIST_QTY,L_MATCH_OPTION
      FROM
        PO_DISTRIBUTIONS_ALL POD,
        PO_LINE_LOCATIONS_ALL POLL,
        PO_LINES_ALL POL
      WHERE POD.PO_DISTRIBUTION_ID = L_PO_DISTRIBUTION_ID
        AND POD.LINE_LOCATION_ID = POLL.LINE_LOCATION_ID
        AND POLL.PO_LINE_ID = POL.PO_LINE_ID
        AND NVL(POLL.ACCRUE_ON_RECEIPT_FLAG
         ,'N') = 'N';
      L_STMT_NUM := 40;
      CST_PERENDACCRUALS_PVT.CALCULATE_ACCRUALAMOUNT(P_API_VERSION => 1.0
                                                    ,P_INIT_MSG_LIST => CST_UTILITY_PUB.GET_FALSE
                                                    ,P_VALIDATION_LEVEL => 100
                                                    ,X_RETURN_STATUS => L_RETURN_STATUS
                                                    ,X_MSG_COUNT => L_MSG_COUNT
                                                    ,X_MSG_DATA => L_MSG_DATA
                                                    ,P_MATCH_OPTION => L_MATCH_OPTION
                                                    ,P_DISTRIBUTION_ID => L_PO_DISTRIBUTION_ID
                                                    ,P_SHIPMENT_ID => L_PO_LINE_LOCATION_ID
                                                    ,P_TRANSACTION_ID => L_TRANSACTION_ID
                                                    ,P_SERVICE_FLAG => L_SERVICE_FLAG
                                                    ,P_DIST_QTY => L_DIST_QTY
                                                    ,P_SHIPMENT_QTY => L_SHIPMENT_QTY
                                                    ,P_END_DATE => L_PERIOD_END_DATE
                                                    ,X_ACCRUAL_QTY => L_ACCRUAL_QTY
                                                    ,X_ENCUM_QTY => L_ENCUM_QTY);
      IF (L_RETURN_STATUS <> CST_UTILITY_PUB.GET_RET_STS_SUCCESS) THEN
        RAISE PROCESS_ERROR;
      END IF;
      L_STMT_NUM := 50;
      SELECT
        DECODE(CAL.ACCOUNTED_DR
              ,NULL
              ,-1 * L_ACCRUAL_QTY
              ,L_ACCRUAL_QTY)
      INTO L_TXN_QUANTITY
      FROM
        CST_AE_LINES CAL
      WHERE CAL.AE_LINE_ID = L_AE_LINE_ID;
    ELSE
      L_STMT_NUM := 100;
      L_TXN_QUANTITY := L_QUANTITY;
    END IF;
    RETURN (L_TXN_QUANTITY);
  EXCEPTION
    WHEN PROCESS_ERROR THEN
      /*SRW.MESSAGE(998
                 ,'Failed calculating accrual quantity :' || TO_CHAR(L_STMT_NUM) || ':' || L_MSG_DATA)*/NULL;
      RAISE;
    WHEN OTHERS THEN
      /*SRW.MESSAGE(999
                 ,'c_txn_quantity : failed calculating transaction quantity :' || TO_CHAR(L_STMT_NUM) || ':' || SUBSTR(SQLERRM
                       ,1
                       ,170))*/NULL;
      RAISE;
  END C_TXN_QUANTITY;

  FUNCTION C_QUANTITYFORMULA(AE_LINE_ID IN NUMBER
                            ,QUANTITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(AE_LINE_ID)*/NULL;
    /*SRW.REFERENCE(QUANTITY)*/NULL;
    RETURN (C_TXN_QUANTITY(AE_LINE_ID
                         ,QUANTITY));
  END C_QUANTITYFORMULA;

  FUNCTION C_QUANTITY1FORMULA(AE_LINE_ID1 IN NUMBER
                             ,QUANTITY1 IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(AE_LINE_ID1)*/NULL;
    /*SRW.REFERENCE(QUANTITY1)*/NULL;
    RETURN (C_TXN_QUANTITY(AE_LINE_ID1
                         ,QUANTITY1));
  END C_QUANTITY1FORMULA;

  FUNCTION C_QUANTITY2FORMULA(AE_LINE_ID2 IN NUMBER
                             ,QUANTITY2 IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(AE_LINE_ID2)*/NULL;
    /*SRW.REFERENCE(QUANTITY2)*/NULL;
    RETURN (C_TXN_QUANTITY(AE_LINE_ID2
                         ,QUANTITY2));
  END C_QUANTITY2FORMULA;

  FUNCTION CP_APPLICATION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_APPLICATION;
  END CP_APPLICATION_P;

  FUNCTION CP_COST_GROUP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_COST_GROUP;
  END CP_COST_GROUP_P;

  FUNCTION CP_COST_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_COST_TYPE;
  END CP_COST_TYPE_P;

  FUNCTION CP_LEGAL_ENTITY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_LEGAL_ENTITY;
  END CP_LEGAL_ENTITY_P;

  FUNCTION CP_PERIOD_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PERIOD_NAME;
  END CP_PERIOD_NAME_P;

  FUNCTION CP_REQUESTED_BY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REQUESTED_BY;
  END CP_REQUESTED_BY_P;

  FUNCTION CP_REQUEST_TIME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REQUEST_TIME;
  END CP_REQUEST_TIME_P;

  FUNCTION CP_RESPONSIBILITY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_RESPONSIBILITY;
  END CP_RESPONSIBILITY_P;

  FUNCTION CP_PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN CP_PRECISION;
  END CP_PRECISION_P;

  FUNCTION CP_SORT_BY_COV_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SORT_BY_COV;
  END CP_SORT_BY_COV_P;

  FUNCTION CP_TYPE_OPTION_COV_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_TYPE_OPTION_COV;
  END CP_TYPE_OPTION_COV_P;

  FUNCTION CP_EXT_PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN CP_EXT_PRECISION;
  END CP_EXT_PRECISION_P;

END BOM_CSTRPMDD_XMLP_PKG;




/
