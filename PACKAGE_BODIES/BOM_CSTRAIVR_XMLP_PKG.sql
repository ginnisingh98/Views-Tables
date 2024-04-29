--------------------------------------------------------
--  DDL for Package Body BOM_CSTRAIVR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTRAIVR_XMLP_PKG" AS
/* $Header: CSTRAIVRB.pls 120.0 2007/12/24 09:52:34 dwkrishn noship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    /*SRW.MESSAGE(0
               ,'BOM_CSTRAIVR_XMLP_PKG >>     ' || TO_CHAR(SYSDATE
                      ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_FCN_CURRENCY VARCHAR2(15);
    L_STMT_NUM NUMBER;
    L_MSG_COUNT NUMBER;
    L_MSG_DATA VARCHAR2(8000);
    L_RETURN_STATUS VARCHAR2(1);
    L_AS_OF_DATE VARCHAR2(30);
    L_CST_INV_VAL EXCEPTION;
  BEGIN
    L_STMT_NUM := 0;
    P_EXCHANGE_RATE := FND_NUMBER.CANONICAL_TO_NUMBER(P_EXCHANGE_RATE_CHAR);
    L_STMT_NUM := 1;
    IF P_VIEW_COST <> 1 THEN
      FND_MESSAGE.SET_NAME('null'
                          ,'null');
      /*SRW.USER_EXIT('FND MESSAGE_DISPLAY')*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END IF;
    L_STMT_NUM := 3;
    SELECT
      O.ORGANIZATION_NAME,
      MP.COST_ORGANIZATION_ID,
      SOB.CURRENCY_CODE,
      NVL(EXTENDED_PRECISION
         ,PRECISION),
      NVL(MINIMUM_ACCOUNTABLE_UNIT
         ,POWER(10
              ,NVL(-PRECISION
                 ,0))),
      MCS.CATEGORY_SET_NAME,
      DEFAULT_COST_TYPE_ID,
      COST_TYPE,
      LU1.MEANING
    INTO P_ORGANIZATION,P_COST_ORG_ID,L_FCN_CURRENCY,P_EXT_PREC,ROUND_UNIT,P_CAT_SET_NAME,P_DEF_COST_TYPE,P_COST_TYPE,P_SORT_BY
    FROM
      ORG_ORGANIZATION_DEFINITIONS O,
      MTL_PARAMETERS MP,
      GL_SETS_OF_BOOKS SOB,
      FND_CURRENCIES FC,
      MTL_CATEGORY_SETS MCS,
      CST_COST_TYPES,
      MFG_LOOKUPS LU1
    WHERE FC.CURRENCY_CODE = P_CURRENCY_CODE
      AND O.ORGANIZATION_ID = P_ORG_ID
      AND MP.ORGANIZATION_ID = P_ORG_ID
      AND SOB.SET_OF_BOOKS_ID = O.SET_OF_BOOKS_ID
      AND MCS.CATEGORY_SET_ID = P_CATEGORY_SET
      AND COST_TYPE_ID = P_COST_TYPE_ID
      AND LU1.LOOKUP_TYPE (+) = 'CST_ITEM_REPORT_SORT'
      AND LU1.LOOKUP_CODE (+) = P_SORT_OPTION;
    L_STMT_NUM := 4;
    IF L_FCN_CURRENCY = P_CURRENCY_CODE THEN
      P_CURRENCY_DSP := P_CURRENCY_CODE;
    ELSE
      P_CURRENCY_DSP := P_CURRENCY_CODE || ' @ ' || TO_CHAR(ROUND(1 / P_EXCHANGE_RATE
                                     ,5)) || L_FCN_CURRENCY;
    END IF;
    L_STMT_NUM := 5;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    L_STMT_NUM := 6;
    L_STMT_NUM := 7;
    L_STMT_NUM := 8;
    CST_INVENTORY_PUB.CALCULATE_INVENTORYVALUE(P_API_VERSION => 1.0
                                              ,P_INIT_MSG_LIST => CST_UTILITY_PUB.GET_TRUE
                                              ,P_ORGANIZATION_ID => P_ORG_ID
                                              ,P_ONHAND_VALUE => 1
                                              ,P_INTRANSIT_VALUE => 1
                                              ,P_RECEIVING_VALUE => 1
                                              ,P_VALUATION_DATE => TO_DATE(P_AS_OF_DATE
                                                     ,'YYYY/MM/DD HH24:MI:SS')
                                              ,P_COST_TYPE_ID => P_COST_TYPE_ID
                                              ,P_ITEM_FROM => P_ITEM_FROM
                                              ,P_ITEM_TO => P_ITEM_TO
                                              ,P_CATEGORY_SET_ID => P_CATEGORY_SET
                                              ,P_CATEGORY_FROM => P_CAT_FROM
                                              ,P_CATEGORY_TO => P_CAT_TO
                                              ,P_COST_GROUP_FROM => NULL
                                              ,P_COST_GROUP_TO => NULL
                                              ,P_SUBINVENTORY_FROM => NULL
                                              ,P_SUBINVENTORY_TO => NULL
                                              ,P_QTY_BY_REVISION => NULL
                                              ,P_ZERO_COST_ONLY => P_ZERO_COST
                                              ,P_ZERO_QTY => NULL
                                              ,P_EXPENSE_ITEM => P_EXP_ITEM
                                              ,P_EXPENSE_SUB => P_EXP_SUBINV
                                              ,P_UNVALUED_TXNS => NULL
                                              ,P_RECEIPT => 1
                                              ,P_SHIPMENT => 1
                                              ,P_OWN => 1
                                              ,P_DETAIL => NULL
                                              ,X_RETURN_STATUS => L_RETURN_STATUS
                                              ,X_MSG_COUNT => L_MSG_COUNT
                                              ,X_MSG_DATA => L_MSG_DATA);
    L_STMT_NUM := 9;
    IF L_RETURN_STATUS <> CST_UTILITY_PUB.GET_RET_STS_SUCCESS THEN
      RAISE L_CST_INV_VAL;
    END IF;
    L_STMT_NUM := 10;
    FND_MSG_PUB.COUNT_AND_GET(P_ENCODED => CST_UTILITY_PUB.GET_FALSE
                             ,P_COUNT => L_MSG_COUNT
                             ,P_DATA => L_MSG_DATA);
    L_STMT_NUM := 11;
    IF L_MSG_COUNT > 0 THEN
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
    P_AS_OF_DATE1 := L_AS_OF_DATE;
    /*SRW.MESSAGE(0
               ,'BOM_CSTRAIVR_XMLP_PKG <<     ' || TO_CHAR(SYSDATE
                      ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(999
                 ,L_STMT_NUM || ': ' || SQLERRM)*/NULL;
      /*SRW.MESSAGE(999
                 ,'BOM_CSTRAIVR_XMLP_PKG >X     ' || TO_CHAR(SYSDATE
                        ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
      FND_MSG_PUB.COUNT_AND_GET(P_ENCODED => CST_UTILITY_PUB.GET_FALSE
                               ,P_COUNT => L_MSG_COUNT
                               ,P_DATA => L_MSG_DATA);
      IF L_MSG_COUNT > 0 THEN
        FOR i IN 1 .. L_MSG_COUNT LOOP
          L_MSG_DATA := FND_MSG_PUB.GET(I
                                       ,CST_UTILITY_PUB.GET_FALSE);
          FND_FILE.PUT_LINE(CST_UTILITY_PUB.GET_LOG
                           ,I || '-' || L_MSG_DATA);
        END LOOP;
      END IF;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
  END BEFOREREPORT;

  FUNCTION CATEGORY_PSEGFORMULA(CATEGORY IN VARCHAR2
                               ,CATEGORY_SEGMENT IN VARCHAR2
                               ,CATEGORY_PSEG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(CATEGORY)*/NULL;
    /*SRW.REFERENCE(CATEGORY_SEGMENT)*/NULL;
    RETURN (CATEGORY_PSEG);
  END CATEGORY_PSEGFORMULA;

  FUNCTION ITEM_PSEGFORMULA(ITEM_NUMBER IN VARCHAR2
                           ,ITEM_SEGMENT IN VARCHAR2
                           ,ITEM_PSEG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(ITEM_NUMBER)*/NULL;
    /*SRW.REFERENCE(ITEM_SEGMENT)*/NULL;
    RETURN (ITEM_PSEG);
  END ITEM_PSEGFORMULA;

  FUNCTION ITEM_TOTAL_QUANTITYFORMULA(STK_QUANTITY IN NUMBER
                                     ,INT_QUANTITY IN NUMBER
                                     ,RCV_QUANTITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (STK_QUANTITY + INT_QUANTITY + RCV_QUANTITY);
  END ITEM_TOTAL_QUANTITYFORMULA;

  FUNCTION ITEM_TOTAL_VALUEFORMULA(ITEM_STK_VALUE IN NUMBER
                                  ,ITEM_INT_VALUE IN NUMBER
                                  ,ITEM_RCV_VALUE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ITEM_STK_VALUE + ITEM_INT_VALUE + ITEM_RCV_VALUE);
  END ITEM_TOTAL_VALUEFORMULA;

  FUNCTION CAT_TOTAL_VALUEFORMULA(CAT_STK_VALUE IN NUMBER
                                 ,CAT_INT_VALUE IN NUMBER
                                 ,CAT_RCV_VALUE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (CAT_STK_VALUE + CAT_INT_VALUE + CAT_RCV_VALUE);
  END CAT_TOTAL_VALUEFORMULA;

  FUNCTION C_ORDERFORMULA(ITEM_NUMBER IN VARCHAR2
                         ,ITEM_SEGMENT IN VARCHAR2
                         ,ITEM_PSEG IN VARCHAR2
                         ,CATEGORY IN VARCHAR2
                         ,CATEGORY_SEGMENT IN VARCHAR2
                         ,CATEGORY_PSEG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(ITEM_NUMBER)*/NULL;
    /*SRW.REFERENCE(ITEM_SEGMENT)*/NULL;
    /*SRW.REFERENCE(ITEM_PSEG)*/NULL;
    /*SRW.REFERENCE(CATEGORY)*/NULL;
    /*SRW.REFERENCE(CATEGORY_SEGMENT)*/NULL;
    /*SRW.REFERENCE(CATEGORY_PSEG)*/NULL;
    IF P_SORT_OPTION = 1 THEN
      RETURN (NULL);
    ELSE
      RETURN (CATEGORY_PSEG);
    END IF;
    RETURN NULL;
  END C_ORDERFORMULA;

  FUNCTION REP_TOTAL_VALUEFORMULA(REP_STK_VALUE IN NUMBER
                                 ,REP_INT_VALUE IN NUMBER
                                 ,REP_RCV_VALUE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (REP_STK_VALUE + REP_INT_VALUE + REP_RCV_VALUE);
  END REP_TOTAL_VALUEFORMULA;

  FUNCTION P_TITLEVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_TITLEVALIDTRIGGER;

END BOM_CSTRAIVR_XMLP_PKG;


/
