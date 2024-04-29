--------------------------------------------------------
--  DDL for Package Body BOM_CSTRAIVA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTRAIVA_XMLP_PKG" AS
/* $Header: CSTRAIVAB.pls 120.0 2007/12/24 09:51:53 dwkrishn noship $ */
  FUNCTION CF_ORDERFORMULA(CATEGORY IN VARCHAR2) RETURN CHAR IS
  BEGIN
    IF (P_SORT_OPTION = 1) THEN
      RETURN NULL;
    ELSE
      RETURN CATEGORY;
    END IF;
  END CF_ORDERFORMULA;
  FUNCTION CF_TOTQTYFORMULA(STKQTY IN NUMBER
                           ,RCVQTY IN NUMBER
                           ,INTQTY IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN STKQTY + RCVQTY + INTQTY;
  END CF_TOTQTYFORMULA;
  FUNCTION CF_TOTVALFORMULA(STKVAL IN NUMBER
                           ,RCVVAL IN NUMBER
                           ,INTVAL IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN STKVAL + RCVVAL + INTVAL;
  END CF_TOTVALFORMULA;
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
    PV_EXCHANGE_RATE := FND_NUMBER.CANONICAL_TO_NUMBER(P_EXCHANGE_RATE_CHAR);
    L_STMT_NUM := 1;
    IF P_VIEW_COST <> 1 THEN
      FND_MESSAGE.SET_NAME('null'
                          ,'null');
      /*SRW.USER_EXIT('FND MESSAGE_DISPLAY')*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END IF;
    L_STMT_NUM := 5;
    SELECT
      PRIMARY_COST_METHOD
    INTO P_COST_METHOD
    FROM
      MTL_PARAMETERS
    WHERE ORGANIZATION_ID = P_ORG_ID;
    L_STMT_NUM := 20;
    SELECT
      OOD.ORGANIZATION_NAME,
      SOB.CURRENCY_CODE,
      NVL(FC.MINIMUM_ACCOUNTABLE_UNIT
         ,POWER(10
              ,NVL(-FC.PRECISION
                 ,0))),
      MCS.CATEGORY_SET_NAME,
      LOOKUP1.MEANING,
      LOOKUP2.MEANING,
      LOOKUP3.MEANING,
      LOOKUP4.MEANING,
      LOOKUP5.MEANING,
      CCT.COST_TYPE
    INTO PV_ORGANIZATION_NAME,L_FCN_CURRENCY,PV_ROUND_UNIT,PV_CATEGORY_SET_NAME,PV_SORT_OPTION,PV_COST_GROUP_OPTION,PV_ZERO_COST,PV_EXP_ITEM,PV_EXP_SUBINV,P_COST_TYPE
    FROM
      ORG_ORGANIZATION_DEFINITIONS OOD,
      CST_COST_TYPES CCT,
      GL_SETS_OF_BOOKS SOB,
      FND_CURRENCIES FC,
      MTL_CATEGORY_SETS MCS,
      MFG_LOOKUPS LOOKUP1,
      MFG_LOOKUPS LOOKUP2,
      MFG_LOOKUPS LOOKUP3,
      MFG_LOOKUPS LOOKUP4,
      MFG_LOOKUPS LOOKUP5
    WHERE OOD.ORGANIZATION_ID = P_ORG_ID
      AND SOB.SET_OF_BOOKS_ID = OOD.SET_OF_BOOKS_ID
      AND FC.CURRENCY_CODE = P_CURRENCY_CODE
      AND MCS.CATEGORY_SET_ID = P_CATEGORY_SET
      AND CCT.COST_TYPE_ID = P_COST_TYPE_ID
      AND LOOKUP1.LOOKUP_TYPE = 'CST_ITEM_REPORT_SORT'
      AND LOOKUP1.LOOKUP_CODE = P_SORT_OPTION
      AND LOOKUP2.LOOKUP_TYPE = 'CST_SRS_COST_GROUP_OPTION'
      AND LOOKUP2.LOOKUP_CODE = P_COST_GROUP_OPTION_ID
      AND LOOKUP3.LOOKUP_TYPE = 'SYS_YES_NO'
      AND LOOKUP3.LOOKUP_CODE = P_ZERO_COST
      AND LOOKUP4.LOOKUP_TYPE = 'SYS_YES_NO'
      AND LOOKUP4.LOOKUP_CODE = P_EXP_ITEM
      AND LOOKUP5.LOOKUP_TYPE = 'SYS_YES_NO'
      AND LOOKUP5.LOOKUP_CODE = P_EXP_SUBINV;
    L_STMT_NUM := 50;
    IF L_FCN_CURRENCY = P_CURRENCY_CODE THEN
      PV_CURRENCY_CODE := P_CURRENCY_CODE;
    ELSE
      PV_CURRENCY_CODE := P_CURRENCY_CODE || ' @ ' || TO_CHAR(ROUND(1 / PV_EXCHANGE_RATE
                                       ,5)) || ' ' || L_FCN_CURRENCY;
    END IF;
    L_STMT_NUM := 60;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    L_STMT_NUM := 70;
    L_STMT_NUM := 80;
    L_STMT_NUM := 90;
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
                                              ,P_COST_GROUP_FROM => P_CG
                                              ,P_COST_GROUP_TO => P_CG
                                              ,P_SUBINVENTORY_FROM => NULL
                                              ,P_SUBINVENTORY_TO => NULL
                                              ,P_QTY_BY_REVISION => NULL
                                              ,P_ZERO_COST_ONLY => P_ZERO_COST
                                              ,P_ZERO_QTY => NULL
                                              ,P_EXPENSE_ITEM => P_EXP_ITEM
                                              ,P_EXPENSE_SUB => P_EXP_SUBINV
                                              ,P_UNVALUED_TXNS => 0
                                              ,P_RECEIPT => 1
                                              ,P_SHIPMENT => 1
                                              ,P_OWN => 1
                                              ,P_DETAIL => NULL
                                              ,X_RETURN_STATUS => L_RETURN_STATUS
                                              ,X_MSG_COUNT => L_MSG_COUNT
                                              ,X_MSG_DATA => L_MSG_DATA);
    L_STMT_NUM := 100;
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
    SELECT
      TO_CHAR(TO_DATE(P_AS_OF_DATE
                     ,'YYYY/MM/DD HH24:MI:SS')
             ,'DD-MON-YYYY HH24:MI:SS')
    INTO L_AS_OF_DATE
    FROM
      DUAL;
    P_AS_OF_DATE1 := L_AS_OF_DATE;
    /*SRW.MESSAGE(0
               ,'BOM_CSTRAIVA_XMLP_PKG <<     ' || TO_CHAR(SYSDATE
                      ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(999
                 ,L_STMT_NUM || ': ' || SQLERRM)*/NULL;
      /*SRW.MESSAGE(999
                 ,'BOM_CSTRAIVA_XMLP_PKG >X     ' || TO_CHAR(SYSDATE
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
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    /*SRW.MESSAGE(0
               ,'CSTRAIVR >>     ' || TO_CHAR(SYSDATE
                      ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;
END BOM_CSTRAIVA_XMLP_PKG;


/
