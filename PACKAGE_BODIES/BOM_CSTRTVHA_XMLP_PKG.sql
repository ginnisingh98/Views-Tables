--------------------------------------------------------
--  DDL for Package Body BOM_CSTRTVHA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTRTVHA_XMLP_PKG" AS
/* $Header: CSTRTVHAB.pls 120.0 2007/12/24 10:18:57 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_FCN_CURRENCY VARCHAR2(15);
    L_STMT_NUM NUMBER;
    L_AVG_ORG_COUNT NUMBER;
    L_MSG_COUNT NUMBER;
    L_MSG_DATA VARCHAR2(8000);
    L_RETURN_STATUS VARCHAR2(1);
    L_CST_INV_VAL EXCEPTION;
    L_VALUATION_DATE DATE;
  BEGIN
    L_STMT_NUM := 10;
    SELECT  COUNT(*)
    INTO L_AVG_ORG_COUNT
    FROM MTL_PARAMETERS
    WHERE ORGANIZATION_ID = P_ORG_ID
      AND PRIMARY_COST_METHOD IN ( 2 , 5 , 6 );
--      raise_application_error(-20001,'L_AVG_ORG_COUNT :'||L_AVG_ORG_COUNT);
    L_STMT_NUM := 15;
    IF L_AVG_ORG_COUNT < 1 THEN
      FND_MESSAGE.SET_NAME('BOM'
                          ,'CST_AVG_ORG_REPORT_ONLY');
      /*SRW.MESSAGE(24200
                 ,FND_MESSAGE.GET)*/NULL;
      RETURN FALSE;
    END IF;
    L_STMT_NUM := 20;
    PV_HIST_DATE := TRUNC(TO_DATE(P_HIST_DATE
                                 ,'YYYY/MM/DD HH24:MI:SS'));
    /*SRW.MESSAGE(2
               ,'PV_HIST_DATE : ' || TO_CHAR(PV_HIST_DATE
                      ,'YYYY/MM/DD HH24:MI:SS'))*/NULL;
    L_VALUATION_DATE := TRUNC(TO_DATE(P_HIST_DATE
                                     ,'YYYY/MM/DD HH24:MI:SS')) + .99999;
    /*SRW.MESSAGE(2
               ,'l_valuation_DATE : ' || TO_CHAR(L_VALUATION_DATE
                      ,'YYYY/MM/DD HH24:MI:SS'))*/NULL;
    L_STMT_NUM := 30;
    SELECT
      OOD.ORGANIZATION_NAME,
      SOB.CURRENCY_CODE,
      FC.PRECISION,
      MCS.CATEGORY_SET_NAME,
      LOOKUP1.MEANING,
      STYPE1.TRANSACTION_SOURCE_TYPE_NAME,
      STYPE2.TRANSACTION_SOURCE_TYPE_NAME,
      STYPE3.TRANSACTION_SOURCE_TYPE_NAME,
      STYPE4.TRANSACTION_SOURCE_TYPE_NAME
    INTO PV_ORGANIZATION_NAME,PV_CURRENCY_CODE,PV_STD_PREC,PV_CATEGORY_SET_NAME,PV_SORT_OPTION,PV_STYPE1,PV_STYPE2,PV_STYPE3,PV_STYPE4
    FROM
      ORG_ORGANIZATION_DEFINITIONS OOD,
      GL_SETS_OF_BOOKS SOB,
      FND_CURRENCIES FC,
      MTL_CATEGORY_SETS MCS,
      MFG_LOOKUPS LOOKUP1,
      MTL_TXN_SOURCE_TYPES STYPE1,
      MTL_TXN_SOURCE_TYPES STYPE2,
      MTL_TXN_SOURCE_TYPES STYPE3,
      MTL_TXN_SOURCE_TYPES STYPE4
    WHERE OOD.ORGANIZATION_ID = P_ORG_ID
      AND SOB.SET_OF_BOOKS_ID = OOD.SET_OF_BOOKS_ID
      AND FC.CURRENCY_CODE = SOB.CURRENCY_CODE
      AND MCS.CATEGORY_SET_ID = P_CAT_SET_ID
      AND LOOKUP1.LOOKUP_TYPE = 'CST_ITEM_REPORT_SORT'
      AND LOOKUP1.LOOKUP_CODE = P_SORT_OPTION
      AND STYPE1.TRANSACTION_SOURCE_TYPE_ID = P_STYPE1
      AND STYPE2.TRANSACTION_SOURCE_TYPE_ID = P_STYPE2
      AND STYPE3.TRANSACTION_SOURCE_TYPE_ID = P_STYPE3
      AND STYPE4.TRANSACTION_SOURCE_TYPE_ID = P_STYPE4;
    L_STMT_NUM := 60;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    L_STMT_NUM := 70;
    L_STMT_NUM := 80;
    L_STMT_NUM := 85;
    IF P_INTRANSIT IS NULL OR P_INTRANSIT <> 1 THEN
      P_INTRANSIT := 0;
    END IF;
    L_STMT_NUM := 90;
    CST_INVENTORY_PUB.CALCULATE_INVENTORYVALUE(P_API_VERSION => 1.0
                                              ,P_INIT_MSG_LIST => CST_UTILITY_PUB.GET_TRUE
                                              ,P_ORGANIZATION_ID => P_ORG_ID
                                              ,P_ONHAND_VALUE => 1
                                              ,P_INTRANSIT_VALUE => P_INTRANSIT
                                              ,P_RECEIVING_VALUE => 0
                                              ,P_VALUATION_DATE => L_VALUATION_DATE
                                              ,P_COST_TYPE_ID => NULL
                                              ,P_ITEM_FROM => P_ITEM_LO
                                              ,P_ITEM_TO => P_ITEM_HI
                                              ,P_CATEGORY_SET_ID => P_CAT_SET_ID
                                              ,P_CATEGORY_FROM => P_CAT_LO
                                              ,P_CATEGORY_TO => P_CAT_HI
                                              ,P_COST_GROUP_FROM => P_CG
                                              ,P_COST_GROUP_TO => P_CG
                                              ,P_SUBINVENTORY_FROM => NULL
                                              ,P_SUBINVENTORY_TO => NULL
                                              ,P_QTY_BY_REVISION => NULL
                                              ,P_ZERO_COST_ONLY => NULL
                                              ,P_ZERO_QTY => NULL
                                              ,P_EXPENSE_ITEM => NULL
                                              ,P_EXPENSE_SUB => NULL
                                              ,P_UNVALUED_TXNS => 0
                                              ,P_RECEIPT => P_INTRANSIT
                                              ,P_SHIPMENT => P_INTRANSIT
                                              ,X_RETURN_STATUS => L_RETURN_STATUS
                                              ,X_MSG_COUNT => L_MSG_COUNT
                                              ,X_MSG_DATA => L_MSG_DATA);
    L_STMT_NUM := 102;
    IF L_RETURN_STATUS <> CST_UTILITY_PUB.GET_RET_STS_SUCCESS THEN
      RAISE L_CST_INV_VAL;
    END IF;
    L_STMT_NUM := 105;
    CST_INVENTORY_PVT.CALCULATE_INVENTORYCOST(P_API_VERSION => 1.0
                                             ,P_VALUATION_DATE => NULL
                                             ,P_ORGANIZATION_ID => P_ORG_ID
                                             ,X_RETURN_STATUS => L_RETURN_STATUS);
    L_STMT_NUM := 108;
    IF L_RETURN_STATUS <> CST_UTILITY_PUB.GET_RET_STS_SUCCESS THEN
      RAISE L_CST_INV_VAL;
    END IF;
    L_STMT_NUM := 110;
    FND_MSG_PUB.COUNT_AND_GET(P_ENCODED => CST_UTILITY_PUB.GET_FALSE
                             ,P_COUNT => L_MSG_COUNT
                             ,P_DATA => L_MSG_DATA);
    L_STMT_NUM := 120;
    IF L_MSG_COUNT > 0 THEN
      FOR i IN 1 .. L_MSG_COUNT LOOP
        L_MSG_DATA := FND_MSG_PUB.GET(I
                                     ,CST_UTILITY_PUB.GET_FALSE);
        FND_FILE.PUT_LINE(CST_UTILITY_PUB.GET_LOG
                         ,I || '-' || L_MSG_DATA);
      END LOOP;
    END IF;
    /*SRW.MESSAGE(0
               ,'BOM_CSTRTVHA_XMLP_PKG <<     ' || TO_CHAR(SYSDATE
                      ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(999
                 ,L_STMT_NUM || ': ' || SQLERRM)*/NULL;
      /*SRW.MESSAGE(999
                 ,'BOM_CSTRTVHA_XMLP_PKG >X     ' || TO_CHAR(SYSDATE
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
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,SQLERRM);
  END BEFOREREPORT;

  FUNCTION CF_ORDERFORMULA(CATEGORY IN VARCHAR2) RETURN CHAR IS
  BEGIN
    IF (P_SORT_OPTION = 1) THEN
      RETURN NULL;
    ELSE
      RETURN CATEGORY;
    END IF;
  END CF_ORDERFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    /*SRW.MESSAGE(0
               ,'BOM_CSTRTVHA_XMLP_PKG >>     ' || TO_CHAR(SYSDATE
                      ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_1FORMULA(NEWVAL IN NUMBER
                      ,OLDVAL IN NUMBER
                      ,S1VAL IN NUMBER
                      ,S2VAL IN NUMBER
                      ,S3VAL IN NUMBER
                      ,S4VAL IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN NEWVAL - OLDVAL - S1VAL - S2VAL - S3VAL - S4VAL;
  END CF_1FORMULA;

END BOM_CSTRTVHA_XMLP_PKG;



/
