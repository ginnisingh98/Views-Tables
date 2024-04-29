--------------------------------------------------------
--  DDL for Package Body BOM_CSTREIVW_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTREIVW_XMLP_PKG" AS
/* $Header: CSTREIVWB.pls 120.0 2007/12/24 09:57:44 dwkrishn noship $ */
  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF (P_ZERO_QTY = 1 AND P_NEG_QTY = 1) THEN
        P_QTY_WHERE := 'HAVING SUM(MOH.TRANSACTION_QUANTITY) <= 0';
      ELSIF (P_ZERO_QTY = 1 AND P_NEG_QTY = 2) THEN
        P_QTY_WHERE := 'HAVING SUM(MOH.TRANSACTION_QUANTITY) >= 0';
      ELSIF (P_ZERO_QTY = 2 AND P_NEG_QTY = 1) THEN
        P_QTY_WHERE := 'HAVING SUM(MOH.TRANSACTION_QUANTITY) < 0';
      ELSE
        P_QTY_WHERE := 'HAVING SUM(MOH.TRANSACTION_QUANTITY) <> 0';
      END IF;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      L_FCN_CURRENCY VARCHAR2(15);
      L_RETURN_STATUS VARCHAR2(1);
      L_MSG_COUNT NUMBER;
      L_MSG_DATA VARCHAR2(2000);
      SQL_STMT_NUM VARCHAR2(5);
      L_AS_OF_DATE VARCHAR2(30);
      L_CST_INV_VAL EXCEPTION;
    BEGIN
      SQL_STMT_NUM := '0: ';
      P_EXCHANGE_RATE := FND_NUMBER.CANONICAL_TO_NUMBER(P_EXCHANGE_RATE_CHAR);

      --added as alternative fix for get_precision

      qty_precision:=bom_common_xmlp_pkg.get_precision(P_qty_precision);
      SQL_STMT_NUM := '4: ';
      IF P_VIEW_COST <> 1 THEN
        FND_MESSAGE.SET_NAME('null'
                            ,'null');
        /*SRW.USER_EXIT('FND MESSAGE_DISPLAY')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      END IF;
      SQL_STMT_NUM := '6: ';
      SELECT
        O.ORGANIZATION_NAME,
        MP.COST_ORGANIZATION_ID,
        NVL(MINIMUM_ACCOUNTABLE_UNIT
           ,POWER(10
                ,NVL(-PRECISION
                   ,0))),
        MCS.CATEGORY_SET_NAME,
        LU1.MEANING,
        LU2.MEANING,
        USERENV('SESSIONID')
      --INTO P_ORGANIZATION,P_COST_ORG_ID,ROUND_UNIT,P_CAT_SET_NAME,P_SORT_BY,P_DETAIL_LEVEL,P_SESSIONID
      INTO P_ORGANIZATION,P_COST_ORG_ID,ROUND_UNIT,P_CAT_SET_NAME,P_SORT_BY,P_DETAIL_LEVEL,P_SESSIONID
      FROM
        ORG_ORGANIZATION_DEFINITIONS O,
        MTL_PARAMETERS MP,
        FND_CURRENCIES FC,
        MTL_CATEGORY_SETS MCS,
        MFG_LOOKUPS LU1,
        MFG_LOOKUPS LU2
      WHERE FC.CURRENCY_CODE = P_CURRENCY_CODE
        AND O.ORGANIZATION_ID = P_ORG_ID
        AND MP.ORGANIZATION_ID = P_ORG_ID
        AND MCS.CATEGORY_SET_ID = P_CATEGORY_SET
        AND LU1.LOOKUP_TYPE = 'CST_ITEM_REPORT_SORT'
        AND LU1.LOOKUP_CODE = P_SORT_OPTION
        AND LU2.LOOKUP_TYPE = 'CST_BICR_DETAIL_OPTION'
        AND LU2.LOOKUP_CODE = P_RPT_OPTION;
      SQL_STMT_NUM := '7: ';
      SELECT
        SOB.CURRENCY_CODE
      INTO L_FCN_CURRENCY
      FROM
        GL_SETS_OF_BOOKS SOB,
        ORG_ORGANIZATION_DEFINITIONS OOD
      WHERE OOD.ORGANIZATION_ID = P_ORG_ID
        AND SOB.SET_OF_BOOKS_ID = OOD.SET_OF_BOOKS_ID;
      SQL_STMT_NUM := '8: ';
      SELECT
        DEFAULT_COST_TYPE_ID,
        COST_TYPE
      INTO P_DEF_COST_TYPE,P_COST_TYPE
      FROM
        CST_COST_TYPES
      WHERE COST_TYPE_ID = P_COST_TYPE_ID;
      IF L_FCN_CURRENCY = P_CURRENCY_CODE THEN
        P_CURRENCY_DSP := P_CURRENCY_CODE;
      ELSE
        P_CURRENCY_DSP := P_CURRENCY_CODE || ' @ ' || TO_CHAR(ROUND(1 / P_EXCHANGE_RATE
                                       ,5)) || L_FCN_CURRENCY;
      END IF;
      SQL_STMT_NUM := '11: ';
      IF P_SORT_OPTION = 8 THEN
        /*SRW.SET_MAXROW('Q_IC_MAIN'
                      ,0)*/NULL;
      ELSE
        /*SRW.SET_MAXROW('Q_CG_MAIN'
                      ,0)*/NULL;
      END IF;
      BEGIN
        P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
        /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      EXCEPTION
        WHEN OTHERS THEN
          /*SRW.MESSAGE(999
                     ,'FND SRWINIT >X')*/NULL;
          RAISE;
      END;
      BEGIN
        NULL;
      EXCEPTION
        WHEN OTHERS THEN
          /*SRW.MESSAGE(999
                     ,'FND FLEXSQL(MCAT) >X')*/NULL;
          RAISE;
      END;
      BEGIN
        NULL;
      EXCEPTION
        WHEN OTHERS THEN
          /*SRW.MESSAGE(999
                     ,'FND FLEXSQL(MSTK) >X')*/NULL;
          RAISE;
      END;
      SQL_STMT_NUM := '12: ';
      CST_INVENTORY_PUB.CALCULATE_INVENTORYVALUE(P_API_VERSION => 1.0
                                                ,P_INIT_MSG_LIST => CST_UTILITY_PUB.GET_TRUE
                                                ,P_ORGANIZATION_ID => P_ORG_ID
                                                ,P_ONHAND_VALUE => 1
                                                ,P_INTRANSIT_VALUE => P_INTRANSIT
                                                ,P_RECEIVING_VALUE => 0
                                                ,P_VALUATION_DATE => TO_DATE(P_AS_OF_DATE
                                                       ,'YYYY/MM/DD HH24:MI:SS')
                                                ,P_COST_TYPE_ID => P_COST_TYPE_ID
                                                ,P_ITEM_FROM => P_ITEM_FROM
                                                ,P_ITEM_TO => P_ITEM_TO
                                                ,P_CATEGORY_SET_ID => P_CATEGORY_SET
                                                ,P_CATEGORY_FROM => P_CAT_FROM
                                                ,P_CATEGORY_TO => P_CAT_TO
                                                ,P_COST_GROUP_FROM => P_CG_FROM
                                                ,P_COST_GROUP_TO => P_CG_TO
                                                ,P_SUBINVENTORY_FROM => NULL
                                                ,P_SUBINVENTORY_TO => NULL
                                                ,P_QTY_BY_REVISION => 2
                                                ,P_ZERO_COST_ONLY => P_ZERO_COST
                                                ,P_ZERO_QTY => P_ZERO_QTY
                                                ,P_EXPENSE_ITEM => P_EXP_ITEM
                                                ,P_EXPENSE_SUB => P_EXP_SUB
                                                ,P_UNVALUED_TXNS => P_UNCOSTED_TXN
                                                ,P_RECEIPT => P_INTRANSIT
                                                ,P_SHIPMENT => P_INTRANSIT
                                                ,X_RETURN_STATUS => L_RETURN_STATUS
                                                ,X_MSG_COUNT => L_MSG_COUNT
                                                ,X_MSG_DATA => L_MSG_DATA);
      IF L_RETURN_STATUS <> CST_UTILITY_PUB.GET_RET_STS_SUCCESS THEN
        RAISE L_CST_INV_VAL;
      END IF;
      FND_MSG_PUB.COUNT_AND_GET(P_ENCODED => CST_UTILITY_PUB.GET_FALSE
                               ,P_COUNT => L_MSG_COUNT
                               ,P_DATA => L_MSG_DATA);
      IF (L_MSG_COUNT > 0) THEN
        FOR i IN 1 .. L_MSG_COUNT LOOP
          L_MSG_DATA := FND_MSG_PUB.GET(I
                                       ,CST_UTILITY_PUB.GET_FALSE);
          FND_FILE.PUT_LINE(CST_UTILITY_PUB.GET_LOG
                           ,I || '-' || L_MSG_DATA);
        END LOOP;
      END IF;
      SELECT
        TO_CHAR(TO_DATE(P_AS_OF_DATE
                       ,'YYYY/MM/DD HH24:MI:SS')
               ,'DD-MON-YYYY HH24:MI:SS')
      INTO L_AS_OF_DATE
      FROM
        DUAL;
      --P_AS_OF_DATE := L_AS_OF_DATE;
      P_AS_OF_DATE1 := L_AS_OF_DATE;
      /*SRW.MESSAGE(0
                 ,'BOM_CSTREIVW_XMLP_PKG  <<     ' || TO_CHAR(SYSDATE
                        ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(999
                   ,SQL_STMT_NUM || SQLERRM)*/NULL;
        /*SRW.MESSAGE(999
                   ,'BOM_CSTREIVW_XMLP_PKG >X     ' || TO_CHAR(SYSDATE
                          ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
        FND_MSG_PUB.COUNT_AND_GET(P_ENCODED => CST_UTILITY_PUB.GET_FALSE
                                 ,P_COUNT => L_MSG_COUNT
                                 ,P_DATA => L_MSG_DATA);
        IF (L_MSG_COUNT > 0) THEN
          FOR i IN 1 .. L_MSG_COUNT LOOP
            L_MSG_DATA := FND_MSG_PUB.GET(I
                                         ,CST_UTILITY_PUB.GET_FALSE);
            /*SRW.MESSAGE(999
                       ,I || ': ' || L_MSG_DATA)*/NULL;
          END LOOP;
        END IF;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXECUTE IMMEDIATE
      'ROLLBACK';
    /*SRW.MESSAGE(0
               ,'BOM_CSTREIVW_XMLP_PKG >>     ' || TO_CHAR(SYSDATE
                      ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CG_ITEM_PSEGFORMULA(CG_ITEM_NUMBER IN VARCHAR2
                              ,CG_ITEM_SEGMENT IN VARCHAR2
                              ,CG_ITEM_PSEG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(CG_ITEM_NUMBER)*/NULL;
    /*SRW.REFERENCE(CG_ITEM_SEGMENT)*/NULL;
    RETURN (CG_ITEM_PSEG);
  END CG_ITEM_PSEGFORMULA;

  FUNCTION CG_MATL1FORMULA(CG_QUANTITY IN NUMBER
                          ,CG_MATL IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND CG_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (CG_MATL);
    END IF;
    RETURN NULL;
  END CG_MATL1FORMULA;

  FUNCTION CG_MOVH1FORMULA(CG_QUANTITY IN NUMBER
                          ,CG_MOVH IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND CG_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (CG_MOVH);
    END IF;
    RETURN NULL;
  END CG_MOVH1FORMULA;

  FUNCTION CG_OSP1FORMULA(CG_QUANTITY IN NUMBER
                         ,CG_OSP IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND CG_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (CG_OSP);
    END IF;
    RETURN NULL;
  END CG_OSP1FORMULA;

  FUNCTION CG_OVHD1FORMULA(CG_QUANTITY IN NUMBER
                          ,CG_OVHD IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND CG_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (CG_OVHD);
    END IF;
    RETURN NULL;
  END CG_OVHD1FORMULA;

  FUNCTION CG_RES1FORMULA(CG_QUANTITY IN NUMBER
                         ,CG_RES IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND CG_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (CG_RES);
    END IF;
    RETURN NULL;
  END CG_RES1FORMULA;

  FUNCTION CG_ROWCOUNTFORMULA(CG_QUANTITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_ZERO_QTY = 1 AND P_NEG_QTY = 1 AND CG_QUANTITY <= 0 THEN
      RETURN (1);
    ELSIF P_ZERO_QTY = 1 AND P_NEG_QTY = 2 THEN
      RETURN (1);
    ELSIF P_ZERO_QTY = 2 AND P_NEG_QTY = 1 AND CG_QUANTITY < 0 THEN
      RETURN (1);
    ELSIF P_ZERO_QTY = 2 AND P_NEG_QTY = 2 AND CG_QUANTITY <> 0 THEN
      RETURN (1);
    ELSE
      RETURN (0);
    END IF;
    RETURN NULL;
  END CG_ROWCOUNTFORMULA;

  FUNCTION CG_TOTAL1FORMULA(CG_QUANTITY IN NUMBER
                           ,CG_TOTAL IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND CG_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (CG_TOTAL);
    END IF;
    RETURN NULL;
  END CG_TOTAL1FORMULA;

  FUNCTION IC_MATL1FORMULA(IC_QUANTITY IN NUMBER
                          ,IC_MATL IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND IC_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (IC_MATL);
    END IF;
    RETURN NULL;
  END IC_MATL1FORMULA;

  FUNCTION IC_MOVH1FORMULA(IC_QUANTITY IN NUMBER
                          ,IC_MOVH IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND IC_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (IC_MOVH);
    END IF;
    RETURN NULL;
  END IC_MOVH1FORMULA;

  FUNCTION IC_OSP1FORMULA(IC_QUANTITY IN NUMBER
                         ,IC_OSP IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND IC_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (IC_OSP);
    END IF;
    RETURN NULL;
  END IC_OSP1FORMULA;

  FUNCTION IC_OVHD1FORMULA(IC_QUANTITY IN NUMBER
                          ,IC_OVHD IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND IC_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (IC_OVHD);
    END IF;
    RETURN NULL;
  END IC_OVHD1FORMULA;

  FUNCTION IC_QUANTITY1FORMULA(IC_QUANTITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND IC_QUANTITY > 0 THEN
      RETURN (NULL);
    ELSE
      RETURN (IC_QUANTITY);
    END IF;
    RETURN NULL;
  END IC_QUANTITY1FORMULA;

  FUNCTION IC_RES1FORMULA(IC_QUANTITY IN NUMBER
                         ,IC_RES IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND IC_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (IC_RES);
    END IF;
    RETURN NULL;
  END IC_RES1FORMULA;

  FUNCTION IC_ROWCOUNTFORMULA(IC_QUANTITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_ZERO_QTY = 1 AND P_NEG_QTY = 1 AND IC_QUANTITY <= 0 THEN
      RETURN (1);
    ELSIF P_ZERO_QTY = 1 AND P_NEG_QTY = 2 THEN
      RETURN (2);
    ELSIF P_ZERO_QTY = 2 AND P_NEG_QTY = 1 AND IC_QUANTITY < 0 THEN
      RETURN (3);
    ELSIF P_ZERO_QTY = 2 AND P_NEG_QTY = 2 AND IC_QUANTITY <> 0 THEN
      RETURN (4);
    ELSE
      RETURN (0);
    END IF;
    RETURN NULL;
  END IC_ROWCOUNTFORMULA;

  FUNCTION IC_TOTAL1FORMULA(IC_QUANTITY IN NUMBER
                           ,IC_TOTAL IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND IC_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (IC_TOTAL);
    END IF;
    RETURN NULL;
  END IC_TOTAL1FORMULA;

  FUNCTION IC_CAT_PSEGFORMULA(IC_CATEGORY_SEGMENT IN VARCHAR2
                             ,IC_CATEGORY IN VARCHAR2
                             ,IC_CAT_PSEG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(IC_CATEGORY_SEGMENT)*/NULL;
    /*SRW.REFERENCE(IC_CATEGORY)*/NULL;
    RETURN (IC_CAT_PSEG);
  END IC_CAT_PSEGFORMULA;

  FUNCTION IC_ITEM_PSEGFORMULA(IC_ITEM_SEGMENT IN VARCHAR2
                              ,IC_ITEM_NUMBER IN VARCHAR2
                              ,IC_ITEM_PSEG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(IC_ITEM_SEGMENT)*/NULL;
    /*SRW.REFERENCE(IC_ITEM_NUMBER)*/NULL;
    RETURN (IC_ITEM_PSEG);
  END IC_ITEM_PSEGFORMULA;

  FUNCTION IC_ORDERFORMULA(IC_ITEM_NUMBER IN VARCHAR2
                          ,IC_CATEGORY IN VARCHAR2
                          ,IC_ITEM_SEGMENT IN VARCHAR2
                          ,IC_CATEGORY_SEGMENT IN VARCHAR2
                          ,IC_ITEM_PSEG IN VARCHAR2
                          ,IC_CAT_PSEG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(IC_ITEM_NUMBER)*/NULL;
    /*SRW.REFERENCE(IC_CATEGORY)*/NULL;
    /*SRW.REFERENCE(IC_ITEM_SEGMENT)*/NULL;
    /*SRW.REFERENCE(IC_CATEGORY_SEGMENT)*/NULL;
    /*SRW.REFERENCE(IC_ITEM_PSEG)*/NULL;
    /*SRW.REFERENCE(IC_CAT_PSEG)*/NULL;
    IF P_SORT_OPTION = 1 THEN
      RETURN (IC_ITEM_PSEG);
    ELSE
      RETURN (IC_CAT_PSEG);
    END IF;
    RETURN NULL;
  END IC_ORDERFORMULA;

END BOM_CSTREIVW_XMLP_PKG;


/
