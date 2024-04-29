--------------------------------------------------------
--  DDL for Package Body INV_INVTRDST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVTRDST_XMLP_PKG" AS
/* $Header: INVTRDSTB.pls 120.2 2008/01/08 06:51:45 dwkrishn noship $ */
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
        RETURN (' ');
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('No Data');
    END;
    RETURN NULL;
  END C_SOURCE_TYPE_NAMEFORMULA;
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_EXCHANGE_RATE := FND_NUMBER.CANONICAL_TO_NUMBER(P_EXCHANGE_RATE_CHAR);
    IF (P_SOURCE_TYPE_ID IS NOT NULL) THEN
      IF (P_SOURCE_TYPE_ID = 7 AND P_TXN_TYPE_ID = 54) THEN
        P_SOURCE_TYPE := 'and (mta.transaction_source_type_id = 8
                         			      and mmt.transaction_action_id = 3)';
      ELSE
        P_SOURCE_TYPE := 'and mta.transaction_source_type_id = ' || P_SOURCE_TYPE_ID;
      END IF;
    END IF;
    IF (P_TXN_TYPE_ID IS NOT NULL) THEN
      P_TXN_TYPE := 'and mmt.transaction_type_id = ' || P_TXN_TYPE_ID;
    END IF;
    IF (P_GL_BATCH_ID IS NOT NULL) THEN
      P_GL_BATCH := 'and mta.gl_batch_id = ' || P_GL_BATCH_ID;
    END IF;
    IF P_SORT_ID = 1 THEN
      /*SRW.SET_MAXROW('Q_acct_item'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_item_acct'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_acct_subinv'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_subinv_acct'
                    ,0)*/NULL;
    ELSIF P_SORT_ID = 2 THEN
      /*SRW.SET_MAXROW('Q_item_acct'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_acct'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_acct_subinv'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_subinv_acct'
                    ,0)*/NULL;
    ELSIF P_SORT_ID = 3 THEN
      /*SRW.SET_MAXROW('Q_acct'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_acct_item'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_acct_subinv'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_subinv_acct'
                    ,0)*/NULL;
    ELSIF P_SORT_ID = 4 THEN
      /*SRW.SET_MAXROW('Q_acct'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_acct_item'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_item_acct'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_subinv_acct'
                    ,0)*/NULL;
    ELSIF P_SORT_ID = 5 THEN
      /*SRW.SET_MAXROW('Q_acct'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_acct_item'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_item_acct'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_acct_subinv'
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
    FORMAT_MASK := inv_common_xmlp_pkg.GET_PRECISION(P_QTY_PRECISION);
    RETURN (TRUE);
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
  FUNCTION C_ACCT_PAD3FORMULA(C_ACCT_PAD3 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_ACCT_PAD3);
  END C_ACCT_PAD3FORMULA;
  FUNCTION C_ACCT_PAD4FORMULA(C_ACCT_PAD4 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_ACCT_PAD4);
  END C_ACCT_PAD4FORMULA;
  FUNCTION C_ITEM_PAD1FORMULA(C_ITEM_PAD1 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_ITEM_PAD1);
  END C_ITEM_PAD1FORMULA;
  FUNCTION C_ITEM_PAD2FORMULA(C_ITEM_PAD2 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_ITEM_PAD2);
  END C_ITEM_PAD2FORMULA;
  FUNCTION WHERE_SUBINV RETURN VARCHAR2 IS
    HI VARCHAR2(10);
    LO VARCHAR2(10);
    COMMON_SQL VARCHAR2(2000);
  BEGIN
    HI := P_SUBINV_HI;
    LO := P_SUBINV_LO;
    COMMON_SQL := ' AND DECODE (mmt.transaction_action_id, 3,
                                  DECODE ( mmt.organization_id, mta.organization_id, mmt.subinventory_code, mmt.transfer_subinventory) ,
                                  2,
                                  DECODE ( SIGN(mta.primary_quantity), - 1, mmt.subinventory_code, 1, mmt.transfer_subinventory, mmt.subinventory_code),
                                  28,
                                  decode(sign(mta.primary_quantity),-1,mmt.subinventory_code,1, mmt.transfer_subinventory,mmt.subinventory_code),
                                  5,
                                  mmt.SUBINVENTORY_CODE,
                                    mmt.subinventory_code) ';
    IF P_SUBINV_LO IS NOT NULL AND P_SUBINV_HI IS NOT NULL THEN
      RETURN (COMMON_SQL || ' BETWEEN ''' || LO || ''' AND ''' || HI || ''' ');
    ELSIF P_SUBINV_LO IS NULL AND P_SUBINV_HI IS NOT NULL THEN
      RETURN (COMMON_SQL || ' <= ''' || HI || ''' ');
    ELSIF P_SUBINV_LO IS NOT NULL AND P_SUBINV_HI IS NULL THEN
      RETURN (COMMON_SQL || ' >= ''' || LO || ''' ');
    ELSE
      RETURN (' ');
    END IF;
  END WHERE_SUBINV;
  FUNCTION WHERE_VALUE RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      HI VARCHAR2(16);
      LO VARCHAR2(16);
    BEGIN
      HI := TO_CHAR(P_VALUE_HI);
      LO := TO_CHAR(P_VALUE_LO);
      IF P_VALUE_HI IS NOT NULL AND P_VALUE_LO IS NOT NULL THEN
        RETURN ('and mta.base_transaction_value between ''' || LO || ''' and ''' || HI || '''');
      ELSIF P_VALUE_HI IS NULL AND P_VALUE_LO IS NOT NULL THEN
        RETURN ('and mta.base_transaction_value >= ''' || LO || ''' ');
      ELSIF P_VALUE_HI IS NOT NULL AND P_VALUE_LO IS NULL THEN
        RETURN ('and mta.base_transaction_value <= ''' || HI || '''');
      ELSE
        RETURN (' ');
      END IF;
    END;
    RETURN '  ';
  END WHERE_VALUE;
  FUNCTION C_WHERE_REASONFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_REASON_ID IS NOT NULL THEN
      RETURN ('and mmt.reason_id = ' || TO_CHAR(P_REASON_ID));
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_WHERE_REASONFORMULA;
  FUNCTION C_FROM_CATFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_CAT_LO IS NOT NULL OR P_CAT_HI IS NOT NULL THEN
      RETURN ('mtl_item_categories mic, mtl_categories mc,');
    ELSE
      RETURN ('mtl_item_categories mic,');
    END IF;
    RETURN NULL;
  END C_FROM_CATFORMULA;
  FUNCTION C_WHERE_CATFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_CAT_LO IS NOT NULL OR P_CAT_HI IS NOT NULL THEN
      RETURN ('and mta.inventory_item_id = mic.inventory_item_id
             	and mic.category_id = mc.category_id
             	and mic.category_set_id = ' || TO_CHAR(P_CAT_SET_ID) || '
             	and mic.organization_id = ' || TO_CHAR(P_ORG_ID));
    ELSE
      RETURN ('and mta.inventory_item_id = mic.inventory_item_id
             	and mic.category_set_id+0 = ' || TO_CHAR(P_CAT_SET_ID) || '
             	and mic.organization_id = ' || TO_CHAR(P_ORG_ID));
    END IF;
    RETURN NULL;
  END C_WHERE_CATFORMULA;
  FUNCTION C_CAT_SET_NAMEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      CAT_SET_ID NUMBER;
      CAT_SET_NAME VARCHAR2(30);
    BEGIN
      IF P_CAT_SET_ID IS NULL THEN
        RETURN (' ');
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
        RETURN (' ');
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
        RETURN (' ');
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
        RETURN (' ');
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
      RETURN ('mtl_txn_source_types mtst,');
    ELSE
      RETURN ('mtl_transaction_types mtt,');
    END IF;
    RETURN NULL;
  END C_FROM_TYPEFORMULA;
  FUNCTION C_WHERE_TYPEFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_TYPE_OPTION = 1 THEN
      RETURN ('and mta.transaction_source_type_id
             = mtst.transaction_source_type_id');
    ELSE
      RETURN ('and mmt.transaction_type_id = mtt.transaction_type_id');
    END IF;
    RETURN NULL;
  END C_WHERE_TYPEFORMULA;
  FUNCTION C_CURRENCY_CODEFORMULA(R_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN ('(' || R_CURRENCY_CODE || ')');
  END C_CURRENCY_CODEFORMULA;
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  C_DATE_FORMAT  varchar2(30);
  BEGIN
    C_DATE_FORMAT := 'DD-MON-YYYY';
    P_DATE_LO_1 := TO_CHAR(TO_DATE(P_DATE_LO
                                ,'YYYY/MM/DD HH24:MI:SS')
                        ,'DD-MON-RRRR HH24:MI:SS');
    P_DATE_HI_1 := TO_CHAR(TO_DATE(P_DATE_HI
                                ,'YYYY/MM/DD HH24:MI:SS')
                        ,'DD-MON-RRRR');
  CP_DATE_LO := to_char(TO_DATE(P_DATE_LO,'YYYY/MM/DD HH24:MI:SS'),C_DATE_FORMAT);
  CP_DATE_HI := to_char(TO_DATE(P_DATE_HI,'YYYY/MM/DD HH24:MI:SS'),C_DATE_FORMAT);
    IF (P_DATE_HI_1 IS NOT NULL) THEN
      P_DATE_HI_1 := TO_CHAR(TO_DATE(P_DATE_HI_1 || ' 23:59:59'
                                  ,'DD-MON-RRRR HH24:MI:SS')
                          ,'DD-MON-RRRR HH24:MI:SS');
    ELSE
      P_DATE_HI_1 := TO_CHAR(TO_DATE(P_DATE_HI_1
                                  ,'DD-MON-RRRR HH24:MI:SS')
                          ,'DD-MON-RRRR HH24:MI:SS');
    END IF;
    BEGIN
      IF P_DATE_LO_1 IS NOT NULL AND P_DATE_HI_1 IS NOT NULL THEN
        P_DATE_RANGE := 'and (mta.transaction_date) between ' || 'to_date(''' || P_DATE_LO_1 || ''',' || '''DD-MON-YYYY HH24:MI:SS''' || ')' || ' and ' || 'to_date(''' || P_DATE_HI_1 || ''',' || '''DD-MON-YYYY HH24:MI:SS''' || ')';
      ELSIF P_DATE_LO_1 IS NOT NULL AND P_DATE_HI_1 IS NULL THEN
        P_DATE_RANGE := 'and (mta.transaction_date) >= ' || 'to_date(''' || P_DATE_LO_1 || ''',' || '''DD-MON-YYYY HH24:MI:SS''' || ')';
      ELSIF P_DATE_LO_1 IS NULL AND P_DATE_HI_1 IS NOT NULL THEN
        P_DATE_RANGE := 'and  (mta.transaction_date) <=  ' || 'to_date(''' || P_DATE_HI_1 || ''',' || '''DD-MON-YYYY HH24:MI:SS''' || ')';
      ELSE
        P_DATE_RANGE := ' ';
      END IF;
    END;
    RETURN (TRUE);
  END AFTERPFORM;
  FUNCTION C_DATE_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_DATE_LO_1 IS NOT NULL AND P_DATE_HI_1 IS NOT NULL THEN
      RETURN ('and mta.transaction_date between ''' || P_DATE_LO_1 || ''' and
                        ''' || P_DATE_HI_1 || '''');
    ELSIF P_DATE_LO_1 IS NOT NULL AND P_DATE_HI_1 IS NULL THEN
      RETURN ('and mta.transaction_date >= ''' || P_DATE_LO_1 || '''');
    ELSIF P_DATE_LO_1 IS NULL AND P_DATE_HI_1 IS NOT NULL THEN
      RETURN ('and  mta.transaction_date <= ''' || P_DATE_HI_1 || '''');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_DATE_WHEREFORMULA;
  FUNCTION C_SOURCE_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_SOURCE_TYPE_ID = 1 AND (P_SOURCE_HI IS NOT NULL OR P_SOURCE_LO IS NOT NULL) THEN
        RETURN ('po_headers poh,');
      END IF;
      IF P_SOURCE_TYPE_ID = 4 AND (P_SOURCE_HI IS NOT NULL OR P_SOURCE_LO IS NOT NULL) THEN
        RETURN ('mtl_txn_request_headers mtrh,');
      END IF;
      IF P_SOURCE_TYPE_ID = 5 AND (P_SOURCE_HI IS NOT NULL OR P_SOURCE_LO IS NOT NULL) THEN
        RETURN ('wip_entities wipe,');
      END IF;
      IF P_SOURCE_TYPE_ID = 7 AND (P_SOURCE_HI IS NOT NULL OR P_SOURCE_LO IS NOT NULL) THEN
        RETURN ('po_requisition_headers prh,');
      END IF;
      IF P_SOURCE_TYPE_ID = 9 AND (P_SOURCE_HI IS NOT NULL OR P_SOURCE_LO IS NOT NULL) THEN
        RETURN ('mtl_cycle_count_headers cch,');
      END IF;
      IF P_SOURCE_TYPE_ID = 10 AND (P_SOURCE_HI IS NOT NULL OR P_SOURCE_LO IS NOT NULL) THEN
        RETURN ('mtl_physical_inventories pi,');
      END IF;
      IF P_SOURCE_TYPE_ID = 11 AND (P_SOURCE_HI IS NOT NULL OR P_SOURCE_LO IS NOT NULL) THEN
        RETURN ('cst_cost_updates cst,');
      END IF;
    END;
    RETURN '  ';
  END C_SOURCE_FROMFORMULA;
  FUNCTION C_ACCT_VALUE0_RFORMULA(C_ACCT_VALUE0 IN NUMBER
                                 ,C_EXT_PREC IN NUMBER) RETURN NUMBER IS
    C_ACCT_VALUE0_R NUMBER;
  BEGIN
    C_ACCT_VALUE0_R := ROUND(C_ACCT_VALUE0
                            ,C_EXT_PREC);
    RETURN C_ACCT_VALUE0_R;
  END C_ACCT_VALUE0_RFORMULA;
  FUNCTION VALUE_RFORMULA(VALUE IN NUMBER
                         ,C_EXT_PREC IN NUMBER) RETURN NUMBER IS
    VALUE_R NUMBER;
  BEGIN
    VALUE_R := ROUND(VALUE
                    ,C_EXT_PREC);
    RETURN VALUE_R;
  END VALUE_RFORMULA;
  FUNCTION C_REPORT_VALUE_RFORMULA(C_REPORT_VALUE IN NUMBER
                                  ,C_EXT_PREC IN NUMBER) RETURN NUMBER IS
    C_REPORT_VALUE_R NUMBER;
  BEGIN
    C_REPORT_VALUE_R := ROUND(C_REPORT_VALUE
                             ,C_EXT_PREC);
    RETURN C_REPORT_VALUE_R;
  END C_REPORT_VALUE_RFORMULA;
  FUNCTION C_ACCT_VALUE1_RFORMULA(C_ACCT_VALUE1 IN NUMBER
                                 ,C_EXT_PREC IN NUMBER) RETURN NUMBER IS
    C_ACCT_VALUE1_R NUMBER;
  BEGIN
    C_ACCT_VALUE1_R := ROUND(C_ACCT_VALUE1
                            ,C_EXT_PREC);
    RETURN C_ACCT_VALUE1_R;
  END C_ACCT_VALUE1_RFORMULA;
  FUNCTION C_ACCT_VALUE3_RFORMULA(C_ACCT_VALUE3 IN NUMBER
                                 ,C_EXT_PREC IN NUMBER) RETURN NUMBER IS
    C_ACCT_VALUE3_R NUMBER;
  BEGIN
    C_ACCT_VALUE3_R := ROUND(C_ACCT_VALUE3
                            ,C_EXT_PREC);
    RETURN C_ACCT_VALUE3_R;
  END C_ACCT_VALUE3_RFORMULA;
  FUNCTION C_ITEM_VALUE2_RFORMULA(C_ITEM_VALUE2 IN NUMBER
                                 ,C_EXT_PREC IN NUMBER) RETURN NUMBER IS
    C_ITEM_VALUE2_R NUMBER;
  BEGIN
    C_ITEM_VALUE2_R := ROUND(C_ITEM_VALUE2
                            ,C_EXT_PREC);
    RETURN C_ITEM_VALUE2_R;
  END C_ITEM_VALUE2_RFORMULA;
  FUNCTION C_SUBINV_VALUE4_RFORMULA(C_SUBINV_VALUE4 IN NUMBER
                                   ,C_EXT_PREC IN NUMBER) RETURN NUMBER IS
    C_SUBINV_VALUE4_R NUMBER;
  BEGIN
    C_SUBINV_VALUE4_R := ROUND(C_SUBINV_VALUE4
                              ,C_EXT_PREC);
    RETURN C_SUBINV_VALUE4_R;
  END C_SUBINV_VALUE4_RFORMULA;
  FUNCTION C_REPORT_VALUE1_RFORMULA(C_REPORT_VALUE1 IN NUMBER
                                   ,C_EXT_PREC IN NUMBER) RETURN NUMBER IS
    C_REPORT_VALUE1_R NUMBER;
  BEGIN
    C_REPORT_VALUE1_R := ROUND(C_REPORT_VALUE1
                              ,C_EXT_PREC);
    RETURN C_REPORT_VALUE1_R;
  END C_REPORT_VALUE1_RFORMULA;
  FUNCTION C_REPORT_VALUE2_RFORMULA(C_REPORT_VALUE2 IN NUMBER
                                   ,C_EXT_PREC IN NUMBER) RETURN NUMBER IS
    C_REPORT_VALUE2_R NUMBER;
  BEGIN
    C_REPORT_VALUE2_R := ROUND(C_REPORT_VALUE2
                              ,C_EXT_PREC);
    RETURN C_REPORT_VALUE2_R;
  END C_REPORT_VALUE2_RFORMULA;
  FUNCTION C_REPORT_VALUE3_RFORMULA(C_REPORT_VALUE3 IN NUMBER
                                   ,C_EXT_PREC IN NUMBER) RETURN NUMBER IS
    C_REPORT_VALUE3_R NUMBER;
  BEGIN
    C_REPORT_VALUE3_R := ROUND(C_REPORT_VALUE3
                              ,C_EXT_PREC);
    RETURN C_REPORT_VALUE3_R;
  END C_REPORT_VALUE3_RFORMULA;
  FUNCTION C_REPORT_VALUE4_RFORMULA(C_REPORT_VALUE4 IN NUMBER
                                   ,C_EXT_PREC IN NUMBER) RETURN NUMBER IS
    C_REPORT_VALUE4_R NUMBER;
  BEGIN
    C_REPORT_VALUE4_R := ROUND(C_REPORT_VALUE4
                              ,C_EXT_PREC);
    RETURN C_REPORT_VALUE4_R;
  END C_REPORT_VALUE4_RFORMULA;
  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;
  FUNCTION C_SOURCE_WHERE_SOFORMULA RETURN CHAR IS
  BEGIN
    IF P_SOURCE_TYPE_ID in (2,8,12) AND (P_SOURCE_LO IS NOT NULL OR P_SOURCE_HI IS NOT NULL) THEN
      RETURN ('and mta.transaction_source_id = mkts.sales_order_id
                     and ' || P_SOURCE_WHERE);
    ELSE
      RETURN '  ';
    END IF;
  END C_SOURCE_WHERE_SOFORMULA;
  FUNCTION C_SOURCE_WHERE_GLFORMULA RETURN CHAR IS
  BEGIN
    IF P_SOURCE_TYPE_ID = 3 AND (P_SOURCE_LO IS NOT NULL OR P_SOURCE_HI IS NOT NULL) THEN
      RETURN ('and mta.transaction_source_id = glc.code_combination_id
                     and ' || P_SOURCE_WHERE);
    ELSE
      RETURN '  ';
    END IF;
  END C_SOURCE_WHERE_GLFORMULA;
  FUNCTION C_SOURCE_WHERE_ALIASFORMULA RETURN CHAR IS
  BEGIN
    IF P_SOURCE_TYPE_ID = 6 AND (P_SOURCE_LO IS NOT NULL OR P_SOURCE_HI IS NOT NULL) THEN
      RETURN ('and mta.transaction_source_id = mdsp.disposition_id
                     and ' || P_SOURCE_WHERE);
    ELSE
      RETURN '  ';
    END IF;
  END C_SOURCE_WHERE_ALIASFORMULA;
  FUNCTION C_SOURCE_WHERE_NOFORMULA RETURN CHAR IS
  BEGIN
    BEGIN
      IF P_SOURCE_TYPE_ID = 1 THEN
        IF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mta.transaction_source_id = poh.po_header_id
                 	and poh.segment1 between ''' || P_SOURCE_LO || ''' and ''' || P_SOURCE_HI || ''' ');
        ELSIF P_SOURCE_HI IS NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mta.transaction_source_id = poh.po_header_id
                 	and poh.segment1 >= ''' || P_SOURCE_LO || ''' ');
        ELSIF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NULL THEN
          RETURN ('and mta.transaction_source_id = poh.po_header_id
                 	and poh.segment1 <= ''' || P_SOURCE_HI || ''' ');
        END IF;
      END IF;
    END;
    BEGIN
      IF P_SOURCE_TYPE_ID = 4 THEN
        IF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mta.transaction_source_id = mtrh.header_id
                 	and mtrh.request_number between ''' || P_SOURCE_LO || ''' and ''' || P_SOURCE_HI || ''' ');
        ELSIF P_SOURCE_HI IS NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mta.transaction_source_id = mtrh.header_id
                 	and mtrh.request_number >= ''' || P_SOURCE_LO || ''' ');
        ELSIF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NULL THEN
          RETURN ('and mta.transaction_source_id = mtrh.header_id
                 	and mtrh.request_number <= ''' || P_SOURCE_HI || ''' ');
        END IF;
      END IF;
    END;
    BEGIN
      IF P_SOURCE_TYPE_ID = 5 THEN
        IF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mta.transaction_source_id = wipe.wip_entity_id
                 	and wipe.wip_entity_name between ''' || P_SOURCE_LO || ''' and ''' || P_SOURCE_HI || ''' ');
        ELSIF P_SOURCE_HI IS NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mta.transaction_source_id = wipe.wip_entity_id
                         and wipe.wip_entity_name >= ''' || P_SOURCE_LO || ''' ');
        ELSIF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NULL THEN
          RETURN ('and mta.transaction_source_id = wipe.wip_entity_id
                         and wipe.wip_entity_name <= ''' || P_SOURCE_HI || ''' ');
        END IF;
      END IF;
    END;
    BEGIN
      IF P_SOURCE_TYPE_ID = 7 THEN
        IF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mta.transaction_source_id = prh.requisition_header_id
                 	and prh.segment1 between ''' || P_SOURCE_LO || ''' and ''' || P_SOURCE_HI || ''' ');
        ELSIF P_SOURCE_HI IS NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mta.transaction_source_id = prh.requisition_header_id
                 	and prh.segment1 >= ''' || P_SOURCE_LO || ''' ');
        ELSIF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NULL THEN
          RETURN ('and mta.transaction_source_id = prh.requisition_header_id
                 	and prh.segment1 <= ''' || P_SOURCE_HI || ''' ');
        END IF;
      END IF;
    END;
    BEGIN
      IF P_SOURCE_TYPE_ID = 9 THEN
        IF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mta.transaction_source_id = CCH.cycle_count_header_id
                 	and CCH.cycle_count_header_name between ''' || P_SOURCE_LO || ''' and ''' || P_SOURCE_HI || ''' ');
        ELSIF P_SOURCE_HI IS NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mta.transaction_source_id = CCH.cycle_count_header_id
                 	and CCH.cycle_count_header_name >= ''' || P_SOURCE_LO || ''' ');
        ELSIF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NULL THEN
          RETURN ('and mta.transaction_source_id = CCH.cycle_count_header_id
                 	and CCH.cycle_count_header_name <= ''' || P_SOURCE_HI || ''' ');
        END IF;
      END IF;
    END;
    BEGIN
      IF P_SOURCE_TYPE_ID = 10 THEN
        IF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mta.transaction_source_id = PI.physical_inventory_id
                 	and PI.physical_inventory_name between ''' || P_SOURCE_LO || ''' and ''' || P_SOURCE_HI || ''' ');
        ELSIF P_SOURCE_HI IS NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mta.transaction_source_id = PI.physical_inventory_id
                 	and PI.physical_inventory_name >= ''' || P_SOURCE_LO || ''' ');
        ELSIF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NULL THEN
          RETURN ('and mta.transaction_source_id = PI.physical_inventory_id
                 	and PI.physical_inventory_name <= ''' || P_SOURCE_HI || ''' ');
        END IF;
      END IF;
    END;
    BEGIN
      IF P_SOURCE_TYPE_ID = 11 THEN
        IF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mta.transaction_source_id = CST.cost_update_id
                 	and CST.description between ''' || P_SOURCE_LO || ''' and ''' || P_SOURCE_HI || ''' ');
        ELSIF P_SOURCE_HI IS NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mta.transaction_source_id = CST.cost_update_id
                 	and CST.description between >= ''' || P_SOURCE_LO || ''' ');
        ELSIF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NULL THEN
          RETURN ('and mta.transaction_source_id = CST.cost_update_id
                 	and CST.description <= ''' || P_SOURCE_HI || ''' ');
        END IF;
      END IF;
    END;
    BEGIN
      IF P_SOURCE_TYPE_ID >= 13 THEN
        IF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mmt.transaction_source_name between ''' || P_SOURCE_LO || ''' and ''' || P_SOURCE_HI || ''' ');
        ELSIF P_SOURCE_HI IS NULL AND P_SOURCE_LO IS NOT NULL THEN
          RETURN ('and mmt.transaction_source_name >= ''' || P_SOURCE_LO || ''' ');
        ELSIF P_SOURCE_HI IS NOT NULL AND P_SOURCE_LO IS NULL THEN
          RETURN ('and mmt.transaction_source_name <= ''' || P_SOURCE_HI || ''' ');
        END IF;
      END IF;
    END;
    RETURN '  ';
  END C_SOURCE_WHERE_NOFORMULA;
function C_sourceFormula(Source in varchar2, Type_id in number) return VARCHAR2 is
begin
declare
        txn_source_id      VARCHAR2(480);
        txn_source         VARCHAR2(480);
        org_id             number;
begin
        txn_source_id  :=  Source;
        org_id         :=  P_org_id;
if Type_id = 1 then select segment1 into txn_source
                          from po_headers_all
                          where  po_header_id = to_number(txn_source_id);
                          return(txn_source);
elsif Type_id = 4 then 	--for Bug#3919355
			select request_number into txn_source
			from mtl_txn_request_headers
			where header_id = to_number(txn_source_id);
		return(txn_source);
elsif Type_id = 5 then
                          select wip_entity_name into txn_source
                          from wip_entities
                          where wip_entity_id = to_number(txn_source_id);
                          return(txn_source);
elsif Type_id = 7 then select segment1 into txn_source
                                    from po_requisition_headers_all
                                    where requisition_header_id =
                                          txn_source_id;
                                    return(txn_source);
elsif Type_id = 9 then
                   select CYCLE_COUNT_HEADER_NAME into txn_source
                   from mtl_cycle_count_headers
                   where cycle_count_header_id = to_number(txn_source_id)
                   and   organization_id = org_id;
                   return(txn_source);
elsif Type_id = 10 then
                   select physical_inventory_name into txn_source
                   from  mtl_physical_inventories
                   where physical_inventory_id = to_number(txn_source_id)
                   and   organization_id = org_id;
                   return(txn_source);
elsif Type_id = 11 then
                      select description into txn_source
                      from  cst_cost_updates
                      where cost_update_id = to_number(txn_source_id);
                      return(txn_source);
/*elsif Type_id in (2,8,12) then
BEGIN
SRW.USER_EXIT('FND FLEXIDVAL CODE="MKTS" NUM=":P_STRUCT_NUM"
               APPL_SHORT_NAME="INV" DATA=":source"
               VALUE=":C_source" DISPLAY="ALL"');
  RETURN(C_source);
EXCEPTION when srw.user_exit_failure
          then return('Flexidval Error');
END;
elsif Type_id = 3 then
BEGIN
SRW.USER_EXIT('FND FLEXIDVAL CODE="GL#" NUM=":P_ACCT_STRUCT_NUM"
               APPL_SHORT_NAME="SQLGL" DATA=":source"
               VALUE=":C_source" DISPLAY="ALL"');
  RETURN(C_source);
EXCEPTION when srw.user_exit_failure
          then return('Flexidval Error');
END;
elsif Type_id = 6 then
BEGIN
SRW.USER_EXIT('FND FLEXIDVAL CODE="MDSP" NUM=":P_STRUCT_NUM"
               APPL_SHORT_NAME="INV" DATA=":source"
               VALUE=":C_source" DISPLAY="ALL"');
  RETURN(C_source);
EXCEPTION when srw.user_exit_failure
          then return('Flexidval Error');
END;*/
else
  return(source);
end if;
exception
  when NO_DATA_FOUND then return('Error: No Data');
end;
RETURN NULL; end;
function C_Source1Formula(Source1 in varchar2, Type_id1 in number) return VARCHAR2 is
begin
declare
        txn_source_id      VARCHAR2(480);
        txn_source         VARCHAR2(480);
        org_id             number;
begin
        txn_source_id  :=  Source1;
        org_id         :=  P_org_id;
if Type_id1 = 1 then select segment1 into txn_source
                          from po_headers_all
                          where  po_header_id = to_number(txn_source_id);
                          return(txn_source);
elsif Type_id1 = 4 then 	--For Bug#3919355
			select request_number into txn_source
			from mtl_txn_request_headers
			where header_id = to_number(txn_source_id);
		return(txn_source);
elsif Type_id1 = 5 then
                          select wip_entity_name into txn_source
                          from wip_entities
                          where wip_entity_id = to_number(txn_source_id);
                          return(txn_source);
elsif Type_id1 = 7 then select segment1 into txn_source
                                    from po_requisition_headers_all
                                    where requisition_header_id =
                                          txn_source_id;
                                    return(txn_source);
elsif Type_id1 = 9 then
                   select CYCLE_COUNT_HEADER_NAME into txn_source
                   from mtl_cycle_count_headers
                   where cycle_count_header_id = to_number(txn_source_id)
                   and   organization_id = org_id;
                   return(txn_source);
elsif Type_id1 = 10 then
                   select physical_inventory_name into txn_source
                   from  mtl_physical_inventories
                   where physical_inventory_id = to_number(txn_source_id)
                   and   organization_id = org_id;
                   return(txn_source);
elsif Type_id1 = 11 then
                      select description into txn_source
                      from  cst_cost_updates
                      where cost_update_id = to_number(txn_source_id);
                      return(txn_source);
/*elsif Type_id1 in (2,8,12) then
BEGIN
SRW.USER_EXIT('FND FLEXIDVAL CODE="MKTS" NUM=":P_STRUCT_NUM"
               APPL_SHORT_NAME="INV" DATA=":source1"
               VALUE=":C_source1" DISPLAY="ALL"');
  RETURN(C_source1);
EXCEPTION when srw.user_exit_failure
          then return('Flexidval Error');
END;
elsif Type_id1 = 3 then
BEGIN
SRW.USER_EXIT('FND FLEXIDVAL CODE="GL#" NUM=":P_ACCT_STRUCT_NUM"
               APPL_SHORT_NAME="SQLGL" DATA=":source1"
               VALUE=":C_source1" DISPLAY="ALL"');
  RETURN(C_source1);
EXCEPTION when srw.user_exit_failure
          then return('Flexidval Error');
END;
elsif Type_id1 = 6 then
BEGIN
SRW.USER_EXIT('FND FLEXIDVAL CODE="MDSP" NUM=":P_STRUCT_NUM"
               APPL_SHORT_NAME="INV" DATA=":source1"
               VALUE=":C_source1" DISPLAY="ALL"');
  RETURN(C_source1);
EXCEPTION when srw.user_exit_failure
          then return('Flexidval Error');
END;*/
else
 return(source1);
end if;
exception
  when NO_DATA_FOUND then return('');
end;
RETURN NULL; end;
function C_Source2Formula(Source2 in varchar2, Type_id2 in number) return VARCHAR2 is
begin
declare
        txn_source_id      VARCHAR2(480);
        txn_source         VARCHAR2(480);
        org_id             number;
begin
        txn_source_id  :=  Source2;
        org_id         :=  P_org_id;
if Type_id2 = 1 then select segment1 into txn_source
                          from po_headers_all
                          where  po_header_id = to_number(txn_source_id);
                          return(txn_source);
elsif Type_id2 = 4 then 	--For Bug#3919355
			select request_number into txn_source
			from mtl_txn_request_headers
			where header_id = to_number(txn_source_id);
		return(txn_source);
elsif Type_id2 = 5 then
                          select wip_entity_name into txn_source
                          from wip_entities
                          where wip_entity_id = to_number(txn_source_id);
                          return(txn_source);
elsif Type_id2 = 7 then select segment1 into txn_source
                                    from po_requisition_headers_all
                                    where requisition_header_id =
                                          txn_source_id;
                                    return(txn_source);
elsif Type_id2 = 9 then
                   select CYCLE_COUNT_HEADER_NAME into txn_source
                   from mtl_cycle_count_headers
                   where cycle_count_header_id = to_number(txn_source_id)
                   and   organization_id = org_id;
                   return(txn_source);
elsif Type_id2 = 10 then
                   select physical_inventory_name into txn_source
                   from  mtl_physical_inventories
                   where physical_inventory_id = to_number(txn_source_id)
                   and   organization_id = org_id;
                   return(txn_source);
elsif Type_id2 = 11 then
                      select description into txn_source
                      from  cst_cost_updates
                      where cost_update_id = to_number(txn_source_id);
                      return(txn_source);
/*elsif Type_id2 in (2,8,12) then
BEGIN
SRW.USER_EXIT('FND FLEXIDVAL CODE="MKTS" NUM=":P_STRUCT_NUM"
               APPL_SHORT_NAME="INV" DATA=":source2"
               VALUE=":C_source2" DISPLAY="ALL"');
  RETURN(C_source2);
EXCEPTION when srw.user_exit_failure
          then return('Flexidval Error');
END;
elsif Type_id2 = 3 then
BEGIN
SRW.USER_EXIT('FND FLEXIDVAL CODE="GL#" NUM=":P_ACCT_STRUCT_NUM"
               APPL_SHORT_NAME="SQLGL" DATA=":source2"
               VALUE=":C_source2" DISPLAY="ALL"');
  RETURN(C_source2);
EXCEPTION when srw.user_exit_failure
          then return('Flexidval Error');
END;
elsif Type_id2 = 6 then
BEGIN
SRW.USER_EXIT('FND FLEXIDVAL CODE="MDSP" NUM=":P_STRUCT_NUM"
               APPL_SHORT_NAME="INV" DATA=":source2"
               VALUE=":C_source2" DISPLAY="ALL"');
  RETURN(C_source2);
EXCEPTION when srw.user_exit_failure
          then return('Flexidval Error');
END;*/
else
 return(source2);
end if;
exception
  when NO_DATA_FOUND then return('');
end;
RETURN NULL; end;
function C_Source3Formula(Source3 in varchar2, Type_id3 in number) return VARCHAR2 is
begin
declare
        txn_source_id      VARCHAR2(480);
        txn_source         VARCHAR2(480);
        org_id             number;
begin
        txn_source_id  :=  Source3;
        org_id         :=  P_org_id;
if Type_id3 = 1 then select segment1 into txn_source
                          from po_headers_all
                          where  po_header_id = to_number(txn_source_id);
                          return(txn_source);
elsif Type_id3 = 4 then 	--For Bug#3919355
			select request_number into txn_source
			from mtl_txn_request_headers
			where header_id = to_number(txn_source_id);
		return(txn_source);
elsif Type_id3 = 5 then
                          select wip_entity_name into txn_source
                          from wip_entities
                          where wip_entity_id = to_number(txn_source_id);
                          return(txn_source);
elsif Type_id3 = 7 then select segment1 into txn_source
                                    from po_requisition_headers_all
                                    where requisition_header_id =
                                          txn_source_id;
                                    return(txn_source);
elsif Type_id3 = 9 then
                   select CYCLE_COUNT_HEADER_NAME into txn_source
                   from mtl_cycle_count_headers
                   where cycle_count_header_id = to_number(txn_source_id)
                   and   organization_id = org_id;
                   return(txn_source);
elsif Type_id3 = 10 then
                   select physical_inventory_name into txn_source
                   from  mtl_physical_inventories
                   where physical_inventory_id = to_number(txn_source_id)
                   and   organization_id = org_id;
                   return(txn_source);
elsif Type_id3 = 11 then
                      select description into txn_source
                      from  cst_cost_updates
                      where cost_update_id = to_number(txn_source_id);
                      return(txn_source);
/*elsif Type_id3 in (2,8,12) then
BEGIN
SRW.USER_EXIT('FND FLEXIDVAL CODE="MKTS" NUM=":P_STRUCT_NUM"
               APPL_SHORT_NAME="INV" DATA=":source3"
               VALUE=":C_source3" DISPLAY="ALL"');
  RETURN(C_source3);
EXCEPTION when srw.user_exit_failure
          then return('Flexidval Error');
END;
elsif Type_id3 = 3 then
BEGIN
SRW.USER_EXIT('FND FLEXIDVAL CODE="GL#" NUM=":P_ACCT_STRUCT_NUM"
               APPL_SHORT_NAME="SQLGL" DATA=":source3"
               VALUE=":C_source3" DISPLAY="ALL"');
  RETURN(C_source3);
EXCEPTION when srw.user_exit_failure
          then return('Flexidval Error');
END;
elsif Type_id3 = 6 then
BEGIN
SRW.USER_EXIT('FND FLEXIDVAL CODE="MDSP" NUM=":P_STRUCT_NUM"
               APPL_SHORT_NAME="INV" DATA=":source3"
               VALUE=":C_source3" DISPLAY="ALL"');
  RETURN(C_source3);
EXCEPTION when srw.user_exit_failure
          then return('Flexidval Error');
END;*/
else
 return(source3);
end if;
exception
  when NO_DATA_FOUND then return('');
end;
RETURN NULL; end;
function C_Source4Formula(Source4 in varchar2, Type_id4 in number) return VARCHAR2 is
begin
declare
        txn_source_id      VARCHAR2(480);
        txn_source         VARCHAR2(480);
        org_id             number;
begin
        txn_source_id  :=  Source4;
        org_id         :=  P_org_id;
if Type_id4 = 1 then select segment1 into txn_source
                          from po_headers_all
                          where  po_header_id = to_number(txn_source_id);
                          return(txn_source);
elsif Type_id4 = 4 then 	--For Bug#3919355
			select request_number into txn_source
			from mtl_txn_request_headers
			where header_id = to_number(txn_source_id);
		return(txn_source);
elsif Type_id4 = 5 then
                          select wip_entity_name into txn_source
                          from wip_entities
                          where wip_entity_id = to_number(txn_source_id);
                          return(txn_source);
elsif Type_id4 = 7 then select segment1 into txn_source
                                    from po_requisition_headers_all
                                    where requisition_header_id =
                                          txn_source_id;
                                    return(txn_source);
elsif Type_id4 = 9 then
                   select CYCLE_COUNT_HEADER_NAME into txn_source
                   from mtl_cycle_count_headers
                   where cycle_count_header_id = to_number(txn_source_id)
                   and   organization_id = org_id;
                   return(txn_source);
elsif Type_id4 = 10 then
                   select physical_inventory_name into txn_source
                   from  mtl_physical_inventories
                   where physical_inventory_id = to_number(txn_source_id)
                   and   organization_id = org_id;
                   return(txn_source);
elsif Type_id4 = 11 then
                      select description into txn_source
                      from  cst_cost_updates
                      where cost_update_id = to_number(txn_source_id);
                      return(txn_source);
/*elsif Type_id4 in (2,8,12) then
BEGIN
SRW.USER_EXIT('FND FLEXIDVAL CODE="MKTS" NUM=":P_STRUCT_NUM"
               APPL_SHORT_NAME="INV" DATA=":source4"
               VALUE=":C_source4" DISPLAY="ALL"');
  RETURN(C_source4);
EXCEPTION when srw.user_exit_failure
          then return('Flexidval Error');
END;
elsif Type_id4 = 3 then
BEGIN
SRW.USER_EXIT('FND FLEXIDVAL CODE="GL#" NUM=":P_ACCT_STRUCT_NUM"
               APPL_SHORT_NAME="SQLGL" DATA=":source4"
               VALUE=":C_source4" DISPLAY="ALL"');
  RETURN(C_source4);
EXCEPTION when srw.user_exit_failure
          then return('Flexidval Error');
END;
elsif Type_id4 = 6 then
BEGIN
SRW.USER_EXIT('FND FLEXIDVAL CODE="MDSP" NUM=":P_STRUCT_NUM"
               APPL_SHORT_NAME="INV" DATA=":source4"
               VALUE=":C_source4" DISPLAY="ALL"');
  RETURN(C_source4);
EXCEPTION when srw.user_exit_failure
          then return('Flexidval Error');
END;*/
else
 return(source4);
end if;
exception
  when NO_DATA_FOUND then return('');
end;
RETURN NULL; end;
END INV_INVTRDST_XMLP_PKG;



/
