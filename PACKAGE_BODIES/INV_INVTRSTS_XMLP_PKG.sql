--------------------------------------------------------
--  DDL for Package Body INV_INVTRSTS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVTRSTS_XMLP_PKG" AS
/* $Header: INVTRSTSB.pls 120.2 2008/01/08 06:47:24 dwkrishn noship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF P_DROP IS NULL THEN
        EXECUTE IMMEDIATE
          'drop view ' || P_VIEW;
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN /*SRW.DO_SQL_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(123
                   ,'Do sql failed to drop view.')*/NULL;
    END;
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Error in SRWEXIT')*/NULL;
    END;
    RETURN (TRUE);
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION C_FROM_CATFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (',mtl_item_categories mic, mtl_categories mc');
  END C_FROM_CATFORMULA;
  FUNCTION C_WHERE_CATFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN ('and msi.inventory_item_id = mic.inventory_item_id and
           mic.category_id = mc.category_id
           and mic.organization_id = ' || TO_CHAR(P_ORG_ID) || '
           and mic.category_set_id = ' || TO_CHAR(P_CAT_SET_ID));
  END C_WHERE_CATFORMULA;
  FUNCTION C_SOURCE_TYPE1FORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      SOURCE_TYPE_ID NUMBER;
      NAME VARCHAR2(40);
    BEGIN
      SOURCE_TYPE_ID := P_STYPE1;
      SELECT
        TRANSACTION_SOURCE_TYPE_NAME
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
      SOURCE_TYPE_ID := P_STYPE2;
      SELECT
        TRANSACTION_SOURCE_TYPE_NAME
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
      SOURCE_TYPE_ID := P_STYPE3;
      SELECT
        TRANSACTION_SOURCE_TYPE_NAME
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
  FUNCTION C_WHERE_SUBINVFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUBINV_LO IS NOT NULL AND P_SUBINV_HI IS NOT NULL THEN
      RETURN ('and v.subinv between ''' || P_SUBINV_LO || ''' and
                        ''' || P_SUBINV_HI || '''');
    ELSE
      IF P_SUBINV_LO IS NOT NULL AND P_SUBINV_HI IS NULL THEN
        RETURN ('and v.subinv >= ''' || P_SUBINV_LO || ''' ');
      ELSE
        IF P_SUBINV_LO IS NULL AND P_SUBINV_HI IS NOT NULL THEN
          RETURN ('and v.subinv <= ''' || P_SUBINV_HI || ''' ');
        ELSE
          RETURN ('  ');
          /*SRW.MESSAGE(1
                     ,C_WHERE_SUBINV)*/NULL;
        END IF;
      END IF;
    END IF;
    RETURN '  ';
  END C_WHERE_SUBINVFORMULA;
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      BEGIN
        /*SRW.MESSAGE(501
                   ,'Initializing Report')*/NULL;
        P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
        /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(1
                     ,'Error in SRWINIT')*/NULL;
          RAISE;
      END;
      /*SRW.MESSAGE(502
                 ,'Report Initialized')*/NULL;
      BEGIN
        NULL;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(2
                     ,'Error in MSTK/select')*/NULL;
          RAISE;
      END;
      BEGIN
        NULL;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(3
                     ,'Error in MSTK/where')*/NULL;
          RAISE;
      END;
      BEGIN
        NULL;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(3
                     ,'Error in MSTK/order by')*/NULL;
          RAISE;
      END;
      IF P_SORT_ID <> 3 THEN
        P_CAT_FLEX := '''X''';
      ELSE
        BEGIN
          NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(4
                       ,'Error in MCAT/Select')*/NULL;
            RAISE;
        END;
      END IF;
      IF P_CAT_HI IS NOT NULL OR P_CAT_LO IS NOT NULL THEN
        BEGIN
          NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(5
                       ,'Error in MCAT')*/NULL;
            RAISE;
        END;
      ELSE
        NULL;
      END IF;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    P_DATE_LO_1 := TO_CHAR(TO_DATE(P_DATE_LO
                                ,'YYYY/MM/DD HH24:MI:SS')
                        ,'DD-MON-RRRR HH24:MI:SS');
    P_DATE_HI_1 := TO_CHAR(TO_DATE(P_DATE_HI
                                ,'YYYY/MM/DD HH24:MI:SS')
                        ,'DD-MON-RRRR');
    IF (P_DATE_HI IS NOT NULL) THEN
      P_DATE_HI_1 := TO_CHAR(TO_DATE(P_DATE_HI_1 || ' 23:59:59'
                                  ,'DD-MON-RRRR HH24:MI:SS')
                          ,'DD-MON-RRRR HH24:MI:SS');
    ELSE
      P_DATE_HI_1 := TO_CHAR(TO_DATE(P_DATE_HI_1
                                  ,'DD-MON-RRRR HH24:MI:SS')
                          ,'DD-MON-RRRR HH24:MI:SS');
    END IF;
    BEGIN
      /*SRW.MESSAGE(100
                 ,'Setting optimizer goal')*/NULL;
      /*SRW.MESSAGE(101
                 ,'Optimizer goal set')*/NULL;
      /*SRW.MESSAGE(1
                 ,P_VIEW)*/NULL;
      /*SRW.MESSAGE(102
                 ,'Creating View')*/NULL;
      EXECUTE IMMEDIATE
        'create view ' || P_VIEW || ' as
        select mmt.subinventory_code        subinv,
               mmt.inventory_item_id        item_id,
               sum(decode(mmt.transaction_source_type_id,' || P_STYPE1 || ',
                          decode(' || TO_CHAR(P_SELECTION) || ',1,primary_quantity,2,1,
                                 decode(' || P_STYPE1 || ',11,quantity_adjusted*
                                        (new_cost-prior_cost),
                                         13,
                                         decode ( mmt.transaction_type_id, 80,
                                                quantity_adjusted*(new_cost-prior_cost),
                                                primary_quantity * actual_cost
                                               ),
                                        primary_quantity * actual_cost))
                          ,0))    source_type1,
               sum(decode(mmt.transaction_source_type_id,' || P_STYPE2 || ',
                          decode(' || TO_CHAR(P_SELECTION) || ',1,primary_quantity,2,1,
                                 decode(' || P_STYPE2 || ',11,quantity_adjusted*
                                        (new_cost-prior_cost),
                                         13,
                                         decode ( mmt.transaction_type_id, 80,
                                                quantity_adjusted*(new_cost-prior_cost),
                                                primary_quantity * actual_cost
                                               ),
                                        primary_quantity * actual_cost))
                          ,0))    source_type2,
               sum(decode(mmt.transaction_source_type_id,' || P_STYPE3 || ',
                          decode(' || TO_CHAR(P_SELECTION) || ',1,primary_quantity,2,1,
                                 decode(' || P_STYPE3 || ',11,quantity_adjusted*
                                        (new_cost-prior_cost),
                                        13,
                                        decode ( mmt.transaction_type_id, 80,
                                                quantity_adjusted*(new_cost-prior_cost),
                                                primary_quantity * actual_cost
                                               ),
                                        primary_quantity * actual_cost))
                          ,0))    source_type3,
               sum(decode(mmt.transaction_source_type_id,' || P_STYPE1 || ',0,
                          ' || P_STYPE2 || ',0,' || P_STYPE3 || ',0,' || P_STYPE4 || ',0,' || P_STYPE5 || ',0,
                          decode(' || TO_CHAR(P_SELECTION) || ',1,primary_quantity,2,1,
                                 decode(mmt.transaction_source_type_id,11,
                                        quantity_adjusted*(new_cost-prior_cost),
                                        13,
                                        decode ( mmt.transaction_type_id, 80,
                                                quantity_adjusted*(new_cost-prior_cost),
                                                primary_quantity * actual_cost
                                               ),
                                        primary_quantity * actual_cost))
                          ))       other
        from mtl_material_transactions mmt
        where mmt.organization_id = ' || TO_CHAR(P_ORG_ID) || '
        and   (transaction_date) >= nvl(to_date(''' || P_DATE_LO_1 || ''',' || '''DD-MON-YYYY HH24:MI:SS''' || '), (transaction_date))
        and   (transaction_date) <= nvl(to_date(''' || P_DATE_HI_1 || ''',' || '''DD-MON-YYYY HH24:MI:SS''' || '), (transaction_date))
        group by mmt.subinventory_code, mmt.inventory_item_id';
      /*SRW.MESSAGE(103
                 ,'View Created and ready to use')*/NULL;
    EXCEPTION
      WHEN /*SRW.DO_SQL_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(111
                   ,'Create view failed')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERPFORM;
  FUNCTION C_ITEM_TOTALFORMULA(SOURCE_TYPE1 IN NUMBER
                              ,SOURCE_TYPE2 IN NUMBER
                              ,SOURCE_TYPE3 IN NUMBER
                              ,OTHER IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (SOURCE_TYPE1 + SOURCE_TYPE2 + SOURCE_TYPE3 + OTHER);
  END C_ITEM_TOTALFORMULA;
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
        RETURN ('');
      WHEN OTHERS THEN
        RETURN ('Error');
    END;
    RETURN NULL;
  END C_CAT_SET_NAMEFORMULA;
  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;
  FUNCTION C_CURRENCY_CODEFORMULA(R_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN ('(' || R_CURRENCY_CODE || ')');
  END C_CURRENCY_CODEFORMULA;
  FUNCTION P_VIEW_PUTVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_VIEW := 'TXN_USAGE_VIEW' || TO_CHAR(P_CONC_REQUEST_ID);
    END;
    RETURN (TRUE);
  END P_VIEW_PUTVALIDTRIGGER;
  FUNCTION C_STATUS_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN ('  ');
  END C_STATUS_WHEREFORMULA;
  FUNCTION C_CAT_PADFORMULA(C_CAT_FIELD IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(C_CAT_FIELD)*/NULL;
    RETURN (C_CAT_FIELD);
  END C_CAT_PADFORMULA;
END INV_INVTRSTS_XMLP_PKG;


/
