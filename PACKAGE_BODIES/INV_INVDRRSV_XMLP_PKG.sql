--------------------------------------------------------
--  DDL for Package Body INV_INVDRRSV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVDRRSV_XMLP_PKG" AS
/* $Header: INVDRRSVB.pls 120.1 2008/01/08 06:44:37 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      DATE_LO DATE;
      DATE_HI DATE;
    BEGIN
      DATE_LO := TO_DATE(P_DATE_LO
                        ,'YYYY/MM/DD HH24:MI:SS');
      DATE_HI := TO_DATE(P_DATE_HI
                        ,'YYYY/MM/DD HH24:MI:SS');
      /*P_DATE_LO := TO_CHAR(DATE_LO
                          ,'DD-MON-RR');
      P_DATE_HI := TO_CHAR(DATE_HI
                          ,'DD-MON-RR');
      P_DATE_HI := P_DATE_HI || ' 23:59:59';*/
      --added as fix
      P_DATE_LO_V := TO_CHAR(DATE_LO
                                ,'DD-MON-RR');
            P_DATE_HI_V := TO_CHAR(DATE_HI
                                ,'DD-MON-RR');
      P_DATE_HI_V := P_DATE_HI_V || ' 23:59:59';
    END;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      qty_precision:=inv_common_xmlp_pkg.get_precision(P_qty_precision);
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in before report trigger:SRWINIT')*/NULL;
    END;
    DECLARE
      P_ORG_ID_CHAR VARCHAR2(100) := TO_CHAR(P_ORG_ID);
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
        /*SRW.MESSAGE(1
                   ,'Failed in before report trigger:MSTK')*/NULL;
    END;
    BEGIN
      IF P_SORT_ID = 3 THEN
        BEGIN
          NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(1
                       ,'Failed in before report trigger:MSTK:ORDERBY')*/NULL;
        END;
        BEGIN
          IF P_SOURCE_TYPE_ID in (2,8) THEN
            NULL;
          ELSE
            IF P_SOURCE_TYPE_ID = 3 THEN
              NULL;
            ELSE
              IF P_SOURCE_TYPE_ID = 6 THEN
                NULL;
              ELSE
                IF P_SOURCE_TYPE_ID = 5 THEN
                  P_ORDER_SOURCE := 'wip_entity_name';
                ELSE
                  IF P_SOURCE_TYPE_ID >= 13 THEN
                    P_ORDER_SOURCE := 'md.demand_source_name';
                  ELSE
                    P_ORDER_SOURCE := '12';
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(1
                       ,'Failed in before report trigger:SOURCE:ORDERBY')*/NULL;
        END;
      ELSE
        NULL;
      END IF;
    END;
    BEGIN
      IF P_ITEM_LO IS NOT NULL OR P_ITEM_HI IS NOT NULL THEN
        NULL;
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in before report trigger:MSTK:WHERE')*/NULL;
    END;
    BEGIN
      IF P_BREAK_ID = 1 THEN
        NULL;
      ELSE
        P_CAT_FLEX := '''MC''';
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in before report trigger:MCAT/sel')*/NULL;
    END;
    BEGIN
      IF P_CAT_LO IS NOT NULL OR P_CAT_HI IS NOT NULL THEN
        NULL;
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in before report trigger:MCAT/WHERE')*/NULL;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in before report trigger:MTLL')*/NULL;
    END;
    BEGIN
      IF NVL(P_SOURCE_TYPE_ID
         ,2) = 2 THEN
        NULL;
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(9
                   ,'Failed in MKTS/Sel')*/NULL;
    END;
    BEGIN
      IF NVL(P_SOURCE_TYPE_ID
         ,6) = 6 THEN
        NULL;
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(10
                   ,'Failed in MDSP/Sel')*/NULL;
    END;
    BEGIN
      IF NVL(P_SOURCE_TYPE_ID
         ,8) = 8 THEN
        NULL;
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(9
                   ,'Failed in MKTS/Sel')*/NULL;
    END;
    BEGIN
      IF NVL(P_SOURCE_TYPE_ID
         ,3) = 3 THEN
        NULL;
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(11
                   ,'Failed in GL#/Sel')*/NULL;
    END;
    IF P_SOURCE_TYPE_ID = 2 THEN
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
      END;
    ELSE
      IF P_SOURCE_TYPE_ID = 8 THEN
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
        END;
      ELSE
        IF P_SOURCE_TYPE_ID = 6 THEN
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
          END;
        ELSE
          IF P_SOURCE_TYPE_ID = 3 THEN
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
            END;
          ELSE
            NULL;
          END IF;
        END IF;
      END IF;
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'SRWEXIT failed')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_CURRENCY_CODEFORMULA(R_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN ('(' || R_CURRENCY_CODE || ')');
  END C_CURRENCY_CODEFORMULA;

  FUNCTION C_FROM_CATFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_BREAK_ID = 1 OR P_CAT_LO IS NOT NULL OR P_CAT_HI IS NOT NULL THEN
      RETURN (',mtl_item_categories mic, mtl_categories mc');
    ELSE
      RETURN ('/* Do not select from category tables.*/');
    END IF;
    RETURN NULL;
  END C_FROM_CATFORMULA;

  FUNCTION C_CAT_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_BREAK_ID = 1 OR P_CAT_LO IS NOT NULL OR P_CAT_HI IS NOT NULL THEN
      RETURN ('and msi.inventory_item_id = mic.inventory_item_id
                     and mic.organization_id = msi.organization_id
                    and mic.category_set_id = ' || TO_CHAR(P_CAT_SET_ID) || '
                     and mic.category_id = mc.category_id
                     and mic.organization_id = ' || TO_CHAR(P_ORG_ID));
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_CAT_WHEREFORMULA;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION C_ORDER_BYFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_ID in (1,2) THEN
      RETURN ('order by revision, lot_number, subinventory');
    ELSE
      IF P_SORT_ID = 3 THEN
        RETURN ('order by ' || P_ORDER_SOURCE || ', ' || P_ORDER_ITEM || ', revision');
      ELSE
        RETURN ('order by 1,2,3,4,5,6');
      END IF;
    END IF;
    RETURN NULL;
  END C_ORDER_BYFORMULA;

  FUNCTION C_CAT_PADFORMULA(C_CAT_PAD IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_CAT_PAD);
  END C_CAT_PADFORMULA;

  FUNCTION C_SORT_PADFORMULA(C_SORT_PAD IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_SORT_PAD);
  END C_SORT_PADFORMULA;

  FUNCTION C_ITEM_PADFORMULA(C_ITEM_PAD IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_ITEM_PAD);
  END C_ITEM_PADFORMULA;

  FUNCTION C_SOURCE_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SOURCE_TYPE_ID = 2 THEN
      RETURN ('and md.demand_source_header_id = mkts.sales_order_id
                     and ' || P_SOURCE_WHERE);
    ELSE
      IF P_SOURCE_TYPE_ID = 3 THEN
        RETURN ('and md.demand_source_header_id = gl1.code_combination_id
                       and ' || P_SOURCE_WHERE);
      ELSE
        IF P_SOURCE_TYPE_ID = 6 THEN
          RETURN ('and md.demand_source_header_id = mdsp.disposition_id
                         and ' || P_SOURCE_WHERE);
        ELSE
          IF P_SOURCE_TYPE_ID = 8 THEN
            RETURN ('and md.demand_source_header_id = mkts.sales_order_id
                           and ' || P_SOURCE_WHERE);
          ELSE
            IF P_SOURCE_TYPE_ID = 5 AND P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NOT NULL THEN
              RETURN ('and md.demand_source_header_id = wip1.wip_entity_id
                     	and wip1.wip_entity_name between ''' || P_SOURCE_LO || ''' and ''' || P_SOURCE_HI || ''' ');
            ELSE
              IF P_SOURCE_TYPE_ID = 5 AND P_SOURCE_HI IS NULL AND P_SOURCE_LO IS NOT NULL THEN
                RETURN ('and md.demand_source_header_id = wip1.wip_entity_id
                               and wip1.wip_entity_name >= ''' || P_SOURCE_LO || ''' ');
              ELSE
                IF P_SOURCE_TYPE_ID = 5 AND P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NULL THEN
                  RETURN ('and md.demand_source_header_id = wip1.wip_entity_id
                                 and wip1.wip_entity_name <= ''' || P_SOURCE_HI || ''' ');
                ELSE
                  IF P_SOURCE_TYPE_ID >= 13 AND P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NOT NULL THEN
                    RETURN ('and md.demand_source_name between ''' || P_SOURCE_LO || ''' and ''' || P_SOURCE_HI || ''' ');
                  ELSE
                    IF P_SOURCE_TYPE_ID >= 13 AND P_SOURCE_HI IS NULL AND P_SOURCE_LO IS NOT NULL THEN
                      RETURN ('and md.demand_source_name >= ''' || P_SOURCE_LO || ''' ');
                    ELSE
                      IF P_SOURCE_TYPE_ID >= 13 AND P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NULL THEN
                        RETURN ('and md.demand_source_name <= ''' || P_SOURCE_HI || ''' ');
                      ELSE
                        IF P_SOURCE_TYPE_ID IS NULL THEN
                          RETURN ('and md.demand_source_header_id = mkts.sales_order_id(+)
                                      and md.demand_source_header_id = gl1.code_combination_id(+)
                                         and md.demand_source_header_id = mdsp.disposition_id(+)
                                 ');
                        ELSE
                          NULL;
                        END IF;
                      END IF;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
    RETURN NULL;
  END C_SOURCE_WHEREFORMULA;

  FUNCTION C_SOURCE_FROMFORMULA(C_SOURCE_WHERE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF P_SOURCE_TYPE_ID = 2 THEN
      RETURN (',MTL_SALES_ORDERS mkts');
    ELSE
      IF P_SOURCE_TYPE_ID = 3 THEN
        RETURN (',GL_CODE_COMBINATIONS gl1');
      ELSE
        IF P_SOURCE_TYPE_ID = 6 THEN
          RETURN (',MTL_GENERIC_DISPOSITIONS mdsp');
        ELSE
          IF P_SOURCE_TYPE_ID = 5 THEN
            IF C_SOURCE_WHERE IS NULL THEN
              RETURN NULL;
            ELSE
              RETURN (',WIP_ENTITIES wip1');
            END IF;
          ELSE
            IF P_SOURCE_TYPE_ID = 8 THEN
              RETURN (',MTL_SALES_ORDERS mkts');
            ELSE
              IF P_SOURCE_TYPE_ID IS NULL THEN
                RETURN (',MTL_SALES_ORDERS            	mkts,
                                MTL_GENERIC_DISPOSITIONS    mdsp,
                                GL_CODE_COMBINATIONS       gl1 ');
              ELSE
                NULL;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
    RETURN NULL;
  END C_SOURCE_FROMFORMULA;

  FUNCTION C_SOURCE_TYPE_NAMEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      SOURCE_TYPE_ID NUMBER;
      NAME VARCHAR2(40);
    BEGIN
      IF P_SOURCE_TYPE_ID IS NOT NULL THEN
        SOURCE_TYPE_ID := P_SOURCE_TYPE_ID;
        SELECT
          MAX(TRANSACTION_SOURCE_TYPE_NAME)
        INTO NAME
        FROM
          MTL_TXN_SOURCE_TYPES
        WHERE TRANSACTION_SOURCE_TYPE_ID = SOURCE_TYPE_ID;
        RETURN (NAME);
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('No Data');
      WHEN OTHERS THEN
        RETURN ('Error');
    END;
    RETURN NULL;
  END C_SOURCE_TYPE_NAMEFORMULA;

  FUNCTION C_CAT_SET_NAMEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      NAME VARCHAR2(30);
      SET_ID NUMBER;
    BEGIN
      IF P_CAT_SET_ID IS NULL THEN
        RETURN ('');
      ELSE
        SET_ID := P_CAT_SET_ID;
        SELECT
          CATEGORY_SET_NAME
        INTO NAME
        FROM
          MTL_CATEGORY_SETS
        WHERE CATEGORY_SET_ID = SET_ID;
        RETURN (NAME);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('No Data');
      WHEN OTHERS THEN
        RETURN ('Error');
    END;
    RETURN NULL;
  END C_CAT_SET_NAMEFORMULA;

  FUNCTION C_DATE_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_DATE_LO_V IS NOT NULL AND P_DATE_HI_V IS NOT NULL THEN
      RETURN ('and md.requirement_date between ' || 'to_date(''' || P_DATE_LO_V || ''',' || '''DD-MON-RRRR HH24:MI:SS''' || ')' || ' and ' || 'to_date(''' || P_DATE_HI_V || ''',' || '''DD-MON-RRRR HH24:MI:SS''' || ')');
    ELSE
      IF P_DATE_LO_V IS NULL AND P_DATE_HI_V IS NOT NULL THEN
        RETURN ('and md.requirement_date <= ' || 'to_date(''' || P_DATE_HI_V || ''',' || '''DD-MON-RRRR HH24:MI:SS''' || ')');
      ELSE
        IF P_DATE_HI_V IS NULL AND P_DATE_LO_V IS NOT NULL THEN
          RETURN ('and md.requirement_date >= ' || 'to_date(''' || P_DATE_LO_V || ''',' || '''DD-MON-RRRR HH24:MI:SS''' || ')');
        ELSE
          NULL;
        END IF;
      END IF;
    END IF;
    RETURN NULL;
  END C_DATE_WHEREFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_SRC_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN ('and md.demand_source_name between ''' || P_SOURCE_LO || ''' and ''' || P_SOURCE_HI || ''' ');
  END C_SRC_WHEREFORMULA;

  FUNCTION C_SORT_DATE_FIELDFORMULA(C_SORT_FLEX IN VARCHAR2) RETURN DATE IS
  BEGIN
    IF P_SORT_ID = 1 THEN
      RETURN TO_DATE(C_SORT_FLEX
                    ,'J');
    ELSE
      NULL;
    END IF;
    RETURN NULL;
  END C_SORT_DATE_FIELDFORMULA;

END INV_INVDRRSV_XMLP_PKG;


/
