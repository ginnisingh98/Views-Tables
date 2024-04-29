--------------------------------------------------------
--  DDL for Package Body BOM_CSTRITVR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTRITVR_XMLP_PKG" AS
/* $Header: CSTRITVRB.pls 120.0 2007/12/24 10:02:52 dwkrishn noship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    /*SRW.MESSAGE(1
               ,'BOM_CSTRITVR_XMLP_PKG >>     ' || TO_CHAR(SYSDATE
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
    P_EXCHANGE_RATE1:=P_EXCHANGE_RATE;
    P_EXCHANGE_RATE1 := FND_NUMBER.CANONICAL_TO_NUMBER(P_EXCHANGE_RATE_CHAR);
    L_STMT_NUM := 1;
    P_EXP_ITEM:=nvl(P_EXP_ITEM,2);
    P_ZERO_COST:=nvl(P_ZERO_COST,2);
    IF P_VIEW_COST <> 1 THEN
      FND_MESSAGE.SET_NAME('null'
                          ,'null');
      /*SRW.USER_EXIT('FND MESSAGE_DISPLAY')*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END IF;
    L_STMT_NUM := 2;
    FND_PROFILE.GET('CURRENCY_CONVERSION_TYPE'
                   ,P_CURR_TYPE);
    L_STMT_NUM := 10;
    L_STMT_NUM := 20;
    IF P_COST_TYPE_DUMMY = 1 THEN
      P_COST_TYPE_DUMMY1 := 1;
    ELSE
      P_COST_TYPE_DUMMY1 := 0;
    END IF;
    L_STMT_NUM := 40;
    SELECT
      O.ORGANIZATION_NAME,
      NVL(EXTENDED_PRECISION
         ,PRECISION),
      NVL(MINIMUM_ACCOUNTABLE_UNIT
         ,POWER(10
              ,NVL(-PRECISION
                 ,0))),
      MCS.CATEGORY_SET_NAME,
      DEFAULT_COST_TYPE_ID,
      COST_TYPE,
      LU1.MEANING,
      LU2.MEANING
    INTO P_ORGANIZATION,P_EXT_PREC,ROUND_UNIT,P_CAT_SET_NAME,P_DEF_COST_TYPE,P_COST_TYPE,P_SORT_BY,P_DETAIL_LEVEL
    FROM
      ORG_ORGANIZATION_DEFINITIONS O,
      FND_CURRENCIES FC,
      MTL_CATEGORY_SETS MCS,
      CST_COST_TYPES,
      MTL_PARAMETERS MP,
      MFG_LOOKUPS LU1,
      MFG_LOOKUPS LU2
    WHERE FC.CURRENCY_CODE = P_CURRENCY_CODE
      AND O.ORGANIZATION_ID = P_ORG_ID
      AND MCS.CATEGORY_SET_ID = P_CATEGORY_SET
      AND COST_TYPE_ID = NVL(P_COST_TYPE_ID
       ,MP.PRIMARY_COST_METHOD)
      AND MP.ORGANIZATION_ID = P_ORG_ID
      AND LU1.LOOKUP_TYPE (+) = 'CST_ITEM_REPORT_SORT'
      AND LU1.LOOKUP_CODE (+) = P_SORT_OPTION
      AND LU2.LOOKUP_TYPE (+) = 'CST_BICR_DETAIL_OPTION'
      AND LU2.LOOKUP_CODE (+) = P_RPT_OPTION;
    L_STMT_NUM := 50;
    SELECT
      SOB.CURRENCY_CODE
    INTO L_FCN_CURRENCY
    FROM
      GL_SETS_OF_BOOKS SOB,
      ORG_ORGANIZATION_DEFINITIONS OOD
    WHERE OOD.ORGANIZATION_ID = P_ORG_ID
      AND SOB.SET_OF_BOOKS_ID = OOD.SET_OF_BOOKS_ID;
    L_STMT_NUM := 60;
    IF L_FCN_CURRENCY = P_CURRENCY_CODE THEN
      P_CURRENCY_DSP := P_CURRENCY_CODE;
    ELSE
      P_CURRENCY_DSP := P_CURRENCY_CODE || ' @ ' || TO_CHAR(ROUND(1 / P_EXCHANGE_RATE1
                                     ,5)) || L_FCN_CURRENCY;
    END IF;
    L_STMT_NUM := 70;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    L_STMT_NUM := 80;
    L_STMT_NUM := 90;
    L_STMT_NUM := 100;
    CST_INVENTORY_PUB.CALCULATE_INVENTORYVALUE(P_API_VERSION => 1.0
                                              ,P_INIT_MSG_LIST => CST_UTILITY_PUB.GET_TRUE
                                              ,P_ORGANIZATION_ID => P_ORG_ID
                                              ,P_ONHAND_VALUE => 0
                                              ,P_INTRANSIT_VALUE => 1
                                              ,P_RECEIVING_VALUE => 0
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
                                              ,P_QTY_BY_REVISION => P_ITEM_REVISION
                                              ,P_ZERO_COST_ONLY => P_ZERO_COST
                                              ,P_ZERO_QTY => NULL
                                              ,P_EXPENSE_ITEM => P_EXP_ITEM
                                              ,P_EXPENSE_SUB => NULL
                                              ,P_UNVALUED_TXNS => NULL
                                              ,P_RECEIPT => P_RECEIPT
                                              ,P_SHIPMENT => P_SHIPMENT
                                              ,P_OWN => P_OWN
                                              ,P_DETAIL => 1
                                              ,X_RETURN_STATUS => L_RETURN_STATUS
                                              ,X_MSG_COUNT => L_MSG_COUNT
                                              ,X_MSG_DATA => L_MSG_DATA);
    L_STMT_NUM := 110;
    IF L_RETURN_STATUS <> CST_UTILITY_PUB.GET_RET_STS_SUCCESS THEN
      RAISE L_CST_INV_VAL;
    END IF;
    L_STMT_NUM := 120;
    FND_MSG_PUB.COUNT_AND_GET(P_ENCODED => CST_UTILITY_PUB.GET_FALSE
                             ,P_COUNT => L_MSG_COUNT
                             ,P_DATA => L_MSG_DATA);
    L_STMT_NUM := 130;
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
               ,'BOM_CSTRITVR_XMLP_PKG <<     ' || TO_CHAR(SYSDATE
                      ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(999
                 ,L_STMT_NUM || ': ' || SQLERRM)*/NULL;
      /*SRW.MESSAGE(999
                 ,'CSTRAIVW >X     ' || TO_CHAR(SYSDATE
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
  FUNCTION ITEMCATFORMULA(CATEGORY IN VARCHAR2
                         ,CATEGORY_SEGMENT IN VARCHAR2
                         ,CATEGORY_PSEG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(CATEGORY)*/NULL;
    /*SRW.REFERENCE(CATEGORY_SEGMENT)*/NULL;
    /*SRW.REFERENCE(CATEGORY_PSEG)*/NULL;
    IF P_SORT_OPTION = 2 THEN
      RETURN (CATEGORY_PSEG);
    ELSE
      RETURN ('I have absolutely no idea why I am doing this');
    END IF;
    RETURN NULL;
  END ITEMCATFORMULA;
  FUNCTION XFER_COST_TOTALFORMULA(XFER_COST IN NUMBER
                                 ,QUANTITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (XFER_COST * QUANTITY);
  END XFER_COST_TOTALFORMULA;
  FUNCTION XPORT_COST_TOTALFORMULA(XPORT_COST IN NUMBER
                                  ,QUANTITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (XPORT_COST * QUANTITY);
  END XPORT_COST_TOTALFORMULA;
  FUNCTION ITEM_QTYFORMULA(UOM_CODE IN VARCHAR2
                          ,UOMCODE IN VARCHAR2
                          ,ITEM_ID IN NUMBER
                          ,QUANTITY IN NUMBER) RETURN NUMBER IS
    QTY NUMBER;
  BEGIN
    IF UOM_CODE <> UOMCODE THEN
      /*SRW.REFERENCE(ITEM_ID)*/NULL;
      /*SRW.REFERENCE(QUANTITY)*/NULL;
      QTY := INV_CONVERT.INV_UM_CONVERT(ITEM_ID
                                       ,P_QTY_PRECISION
                                       ,QUANTITY
                                       ,UOMCODE
                                       ,UOM_CODE
                                       ,NULL
                                       ,NULL);
      RETURN (QTY);
    ELSE
      RETURN QUANTITY;
    END IF;
    RETURN NULL;
  END ITEM_QTYFORMULA;
  FUNCTION TOT_COSTFORMULA(OWNING_ORG_ID IN NUMBER
                          ,FROM_ORG_ID IN NUMBER
                          ,OWNING_ORG_PUOM_CODE IN VARCHAR2
                          ,UOMCODE IN VARCHAR2
                          ,ITEM_ID IN NUMBER
                          ,QUANTITY IN NUMBER
                          ,UNIT_COST IN NUMBER
                          ,TOTAL_COST IN NUMBER) RETURN NUMBER IS
    QTY NUMBER;
  BEGIN
    IF OWNING_ORG_ID = FROM_ORG_ID THEN
      IF OWNING_ORG_PUOM_CODE <> UOMCODE THEN
        /*SRW.REFERENCE(ITEM_ID)*/NULL;
        /*SRW.REFERENCE(QUANTITY)*/NULL;
        QTY := INV_CONVERT.INV_UM_CONVERT(ITEM_ID
                                         ,P_QTY_PRECISION
                                         ,QUANTITY
                                         ,UOMCODE
                                         ,OWNING_ORG_PUOM_CODE
                                         ,NULL
                                         ,NULL);
      ELSE
        /*SRW.REFERENCE(QUANTITY)*/NULL;
        QTY := QUANTITY;
      END IF;
      RETURN (QTY * UNIT_COST);
    ELSE
      RETURN TOTAL_COST;
    END IF;
    RETURN NULL;
  END TOT_COSTFORMULA;
END BOM_CSTRITVR_XMLP_PKG;



/
