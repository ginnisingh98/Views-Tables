--------------------------------------------------------
--  DDL for Package Body BOM_CSTRINVR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTRINVR_XMLP_PKG" AS
/* $Header: CSTRINVRB.pls 120.1 2008/01/06 05:42:29 nchinnam noship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXECUTE IMMEDIATE
      'ROLLBACK';
    /*SRW.MESSAGE(0
               ,'BOM_CSTRINVR_XMLP_PKG >>     ' || TO_CHAR(SYSDATE
                      ,'Dy Mon DD HH24:MI:SS YYYY'))*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      L_FCN_CURRENCY VARCHAR2(15);
      L_REPORT_NAME VARCHAR2(80);
      SQL_STMT_NUM VARCHAR2(5);
      L_EXP_SUB NUMBER := P_EXP_SUB;
      L_MSG_COUNT NUMBER;
      L_MSG_DATA VARCHAR2(8000);
      L_RETURN_STATUS VARCHAR2(1);
      L_AS_OF_DATE VARCHAR2(30);
      L_COST NUMBER;
      WMS_ORG_COUNT NUMBER;
      PJM_ORG_COUNT NUMBER;
      L_CALCULATE_INTRANSIT NUMBER;
      L_CST_INV_VAL EXCEPTION;
    BEGIN
      SQL_STMT_NUM := '0: ';
      P_EXCHANGE_RATE := FND_NUMBER.CANONICAL_TO_NUMBER(P_EXCHANGE_RATE_CHAR);
      SQL_STMT_NUM := '1: ';
      IF P_VIEW_COST <> 1 THEN
        FND_MESSAGE.SET_NAME('null'
                            ,'null');
        /*SRW.USER_EXIT('FND MESSAGE_DISPLAY')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      END IF;
      SQL_STMT_NUM := '3: ';
      SELECT
        O.ORGANIZATION_NAME,
        MP.COST_ORGANIZATION_ID,
        SOB.CURRENCY_CODE,
        NVL(EXTENDED_PRECISION
           ,PRECISION),
        NVL(FC.PRECISION
           ,0),
        NVL(MINIMUM_ACCOUNTABLE_UNIT
           ,POWER(10
                ,NVL(-PRECISION
                   ,0))),
        MCS.CATEGORY_SET_NAME,
        DEFAULT_COST_TYPE_ID,
        COST_TYPE,
        LU2.MEANING,
        USERENV('SESSIONID')
      INTO P_ORGANIZATION,P_COST_ORG_ID,L_FCN_CURRENCY,P_EXT_PREC,P_PRECISION,ROUND_UNIT,P_CAT_SET_NAME,P_DEF_COST_TYPE,P_COST_TYPE,P_DETAIL_LEVEL,P_SESSIONID
      FROM
        ORG_ORGANIZATION_DEFINITIONS O,
        MTL_PARAMETERS MP,
        GL_SETS_OF_BOOKS SOB,
        FND_CURRENCIES FC,
        MTL_CATEGORY_SETS MCS,
        CST_COST_TYPES,
        MFG_LOOKUPS LU2
      WHERE FC.CURRENCY_CODE = P_CURRENCY_CODE
        AND O.ORGANIZATION_ID = P_ORG_ID
        AND MP.ORGANIZATION_ID = P_ORG_ID
        AND SOB.SET_OF_BOOKS_ID = O.SET_OF_BOOKS_ID
        AND MCS.CATEGORY_SET_ID = P_CATEGORY_SET
        AND COST_TYPE_ID = P_COST_TYPE_ID
        AND LU2.LOOKUP_TYPE = 'CST_BICR_DETAIL_OPTION'
        AND LU2.LOOKUP_CODE = P_RPT_OPTION;
      BEGIN
        SELECT
          MEANING
        INTO P_SORT_BY
        FROM
          MFG_LOOKUPS
        WHERE LOOKUP_TYPE = 'CST_ITEM_REPORT_SORT'
          AND LOOKUP_CODE = P_SORT_OPTION;
	  P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
        IF P_CONC_REQUEST_ID > 0 THEN
          SELECT
            USER_CONCURRENT_PROGRAM_NAME
          INTO P_REPORT_NAME
          FROM
            FND_CONCURRENT_PROGRAMS_VL P,
            FND_CONCURRENT_REQUESTS R
          WHERE R.REQUEST_ID = P_CONC_REQUEST_ID
            AND P.APPLICATION_ID = R.PROGRAM_APPLICATION_ID
            AND P.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID;
        ELSE
          SELECT
            USER_CONCURRENT_PROGRAM_NAME
          INTO P_REPORT_NAME
          FROM
            FND_CONCURRENT_PROGRAMS_VL P
          WHERE P.APPLICATION_ID = 702
            AND P.CONCURRENT_PROGRAM_NAME = DECODE(P_SORT_OPTION
                ,4
                ,'CSTRSAVR'
                ,'BOM_CSTRINVR_XMLP_PKG');
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          RAISE;
      END;
      SQL_STMT_NUM := '4: ';
      IF L_FCN_CURRENCY = P_CURRENCY_CODE THEN
        P_CURRENCY_DSP := P_CURRENCY_CODE;
      ELSE
        P_CURRENCY_DSP := P_CURRENCY_CODE || ' @ ' || TO_CHAR(ROUND(1 / P_EXCHANGE_RATE
                                       ,5)) || L_FCN_CURRENCY;
      END IF;
      SQL_STMT_NUM := '5: ';
      IF P_SORT_OPTION = 3 THEN
        /*SRW.SET_MAXROW('Q_IC_MAIN'
                      ,0)*/NULL;
      ELSE
        /*SRW.SET_MAXROW('Q_SI_SUBINV'
                      ,0)*/NULL;
        /*SRW.SET_MAXROW('Q_SI_MAIN'
                      ,0)*/NULL;
      END IF;
      BEGIN

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
      SQL_STMT_NUM := '6: ';
      CST_INVENTORY_PUB.CALCULATE_INVENTORYVALUE(P_API_VERSION => 1.0
                                                ,P_INIT_MSG_LIST => CST_UTILITY_PUB.GET_TRUE
                                                ,P_ORGANIZATION_ID => P_ORG_ID
                                                ,P_ONHAND_VALUE => 1
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
                                                ,P_SUBINVENTORY_FROM => P_SUBINV_FROM
                                                ,P_SUBINVENTORY_TO => P_SUBINV_TO
                                                ,P_QTY_BY_REVISION => P_ITEM_REVISION
                                                ,P_ZERO_COST_ONLY => P_ZERO_COST
                                                ,P_ZERO_QTY => P_ZERO_QTY
                                                ,P_EXPENSE_ITEM => P_EXP_ITEM
                                                ,P_EXPENSE_SUB => L_EXP_SUB
                                                ,P_UNVALUED_TXNS => P_UNCOSTED_TXN
                                                ,P_RECEIPT => 1
                                                ,P_SHIPMENT => 1
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
      P_AS_OF_DATE1 := L_AS_OF_DATE;
      /*SRW.MESSAGE(0
                 ,'BOM_CSTRINVR_XMLP_PKG <<     ' || TO_CHAR(SYSDATE
                        ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(999
                   ,SQL_STMT_NUM || SQLERRM)*/NULL;
        /*SRW.MESSAGE(999
                   ,'BOM_CSTRINVR_XMLP_PKG >X     ' || TO_CHAR(SYSDATE
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
  FUNCTION IC_ROWCOUNTFORMULA(IC_QUANTITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_ZERO_QTY = 1 AND P_NEG_QTY = 1 AND IC_QUANTITY <= 0 THEN
      RETURN (1);
    ELSIF P_ZERO_QTY = 2 AND P_NEG_QTY = 1 AND IC_QUANTITY < 0 THEN
      RETURN (1);
    ELSIF P_ZERO_QTY = 2 AND P_NEG_QTY = 2 AND IC_QUANTITY <> 0 THEN
      RETURN (1);
    ELSIF P_ZERO_QTY = 1 AND P_NEG_QTY = 2 THEN
      RETURN (1);
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
  FUNCTION SI_TOTAL1FORMULA(SI_QUANTITY IN NUMBER
                           ,SI_TOTAL IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND SI_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (SI_TOTAL);
    END IF;
    RETURN NULL;
  END SI_TOTAL1FORMULA;
  FUNCTION SI_ROWCOUNTFORMULA(SI_QUANTITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_ZERO_QTY = 1 AND P_NEG_QTY = 1 AND SI_QUANTITY <= 0 THEN
      RETURN (1);
    ELSIF P_ZERO_QTY = 1 AND P_NEG_QTY = 2 THEN
      RETURN (1);
    ELSIF P_ZERO_QTY = 2 AND P_NEG_QTY = 1 AND SI_QUANTITY < 0 THEN
      RETURN (1);
    ELSIF P_ZERO_QTY = 2 AND P_NEG_QTY = 2 AND SI_QUANTITY <> 0 THEN
      RETURN (1);
    ELSE
      RETURN (0);
    END IF;
    RETURN NULL;
  END SI_ROWCOUNTFORMULA;
  FUNCTION SI_MATL1FORMULA(SI_QUANTITY IN NUMBER
                          ,SI_MATL IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND SI_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (SI_MATL);
    END IF;
    RETURN NULL;
  END SI_MATL1FORMULA;
  FUNCTION SI_MOVH1FORMULA(SI_QUANTITY IN NUMBER
                          ,SI_MOVH IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND SI_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (SI_MOVH);
    END IF;
    RETURN NULL;
  END SI_MOVH1FORMULA;
  FUNCTION SI_RES1FORMULA(SI_QUANTITY IN NUMBER
                         ,SI_RES IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND SI_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (SI_RES);
    END IF;
    RETURN NULL;
  END SI_RES1FORMULA;
  FUNCTION SI_OSP1FORMULA(SI_QUANTITY IN NUMBER
                         ,SI_OSP IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND SI_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (SI_OSP);
    END IF;
    RETURN NULL;
  END SI_OSP1FORMULA;
  FUNCTION SI_OVHD1FORMULA(SI_QUANTITY IN NUMBER
                          ,SI_OVHD IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND SI_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (SI_OVHD);
    END IF;
    RETURN NULL;
  END SI_OVHD1FORMULA;
  FUNCTION IC_ORDERFORMULA(IC_CATEGORY IN VARCHAR2
                          ,IC_CATEGORY_SEGMENT IN VARCHAR2
                          ,IC_CAT_PSEG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(IC_CATEGORY)*/NULL;
    /*SRW.REFERENCE(IC_CATEGORY_SEGMENT)*/NULL;
    /*SRW.REFERENCE(IC_CAT_PSEG)*/NULL;
    IF P_SORT_OPTION = 2 THEN
      RETURN (IC_CAT_PSEG);
    ELSE
      RETURN ('Item Sort');
    END IF;
    RETURN NULL;
  END IC_ORDERFORMULA;
  FUNCTION IC_ITEM_PSEGFORMULA(IC_ITEM_NUMBER IN VARCHAR2
                              ,IC_ITEM_SEGMENT IN VARCHAR2
                              ,IC_ITEM_PSEG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(IC_ITEM_NUMBER)*/NULL;
    /*SRW.REFERENCE(IC_ITEM_SEGMENT)*/NULL;
    RETURN (IC_ITEM_PSEG);
  END IC_ITEM_PSEGFORMULA;
  FUNCTION IC_CAT_PSEGFORMULA(IC_CATEGORY IN VARCHAR2
                             ,IC_CATEGORY_SEGMENT IN VARCHAR2
                             ,IC_CAT_PSEG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(IC_CATEGORY)*/NULL;
    /*SRW.REFERENCE(IC_CATEGORY_SEGMENT)*/NULL;
    RETURN (IC_CAT_PSEG);
  END IC_CAT_PSEGFORMULA;
  FUNCTION SI_ITEM_PSEGFORMULA(SI_ITEM_NUMBER IN VARCHAR2
                              ,SI_ITEM_SEGMENT IN VARCHAR2
                              ,SI_ITEM_PSEG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(SI_ITEM_NUMBER)*/NULL;
    /*SRW.REFERENCE(SI_ITEM_SEGMENT)*/NULL;
    RETURN (SI_ITEM_PSEG);
  END SI_ITEM_PSEGFORMULA;
  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;
  FUNCTION IC_QUANTITY1FORMULA(IC_QUANTITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_NEG_QTY = 1 AND IC_QUANTITY > 0 THEN
      RETURN (0);
    ELSE
      RETURN (IC_QUANTITY);
    END IF;
    RETURN NULL;
  END IC_QUANTITY1FORMULA;
  FUNCTION SI_SI_TOTALFORMULA(SI_SI_MATL IN NUMBER
                             ,SI_SI_MOVH IN NUMBER
                             ,SI_SI_RES IN NUMBER
                             ,SI_SI_OSP IN NUMBER
                             ,SI_SI_OVHD IN NUMBER) RETURN NUMBER IS
    SI_SI_TOTAL NUMBER;
  BEGIN
    SI_SI_TOTAL := (SI_SI_MATL + SI_SI_MOVH + SI_SI_RES + SI_SI_OSP + SI_SI_OVHD);
    SI_SI_TOTAL := STANDARD.ROUND(SI_SI_TOTAL / ROUND_UNIT) * ROUND_UNIT;
    RETURN SI_SI_TOTAL;
  END SI_SI_TOTALFORMULA;
  FUNCTION SI_REP_TOTALFORMULA(SI_REP_MATL IN NUMBER
                              ,SI_REP_MOVH IN NUMBER
                              ,SI_REP_RES IN NUMBER
                              ,SI_REP_OSP IN NUMBER
                              ,SI_REP_OVHD IN NUMBER) RETURN NUMBER IS
    SI_REP_TOTAL NUMBER;
  BEGIN
    SI_REP_TOTAL := (SI_REP_MATL + SI_REP_MOVH + SI_REP_RES + SI_REP_OSP + SI_REP_OVHD);
    SI_REP_TOTAL := ROUND(SI_REP_TOTAL / ROUND_UNIT) * ROUND_UNIT;
    RETURN SI_REP_TOTAL;
  END SI_REP_TOTALFORMULA;
  FUNCTION IC_ITEM_TOTAL_RFORMULA(IC_ITEM_TOTAL IN NUMBER) RETURN NUMBER IS
    IC_ITEM_TOTAL_R NUMBER;
  BEGIN
    IC_ITEM_TOTAL_R := STANDARD.ROUND(IC_ITEM_TOTAL / ROUND_UNIT
                                     ,0) * ROUND_UNIT;
    RETURN IC_ITEM_TOTAL_R;
  END IC_ITEM_TOTAL_RFORMULA;
  FUNCTION IC_TOTAL_RFORMULA(IC_TOTAL IN NUMBER) RETURN NUMBER IS
    IC_TOTAL_R NUMBER;
  BEGIN
    IC_TOTAL_R := STANDARD.ROUND(IC_TOTAL / ROUND_UNIT ,0) * ROUND_UNIT;
    RETURN IC_TOTAL_R;
  END IC_TOTAL_RFORMULA;
  FUNCTION IC_REP_TOTAL_RFORMULA(IC_REP_TOTAL IN NUMBER) RETURN NUMBER IS
    IC_REP_TOTAL_R NUMBER;
  BEGIN
    IC_REP_TOTAL_R := ROUND(IC_REP_TOTAL / ROUND_UNIT) * ROUND_UNIT;
    RETURN IC_REP_TOTAL_R;
  END IC_REP_TOTAL_RFORMULA;
  FUNCTION IC_CAT_TOTAL_RFORMULA(IC_CAT_TOTAL IN NUMBER) RETURN NUMBER IS
    IC_CAT_TOTAL_R NUMBER;
  BEGIN
    IC_CAT_TOTAL_R := ROUND(IC_CAT_TOTAL / ROUND_UNIT) * ROUND_UNIT;
    RETURN IC_CAT_TOTAL_R;
  END IC_CAT_TOTAL_RFORMULA;
  FUNCTION SI_TOTAL_RFORMULA(SI_TOTAL IN NUMBER) RETURN NUMBER IS
    SI_TOTAL_R NUMBER;
  BEGIN
    SI_TOTAL_R := ROUND(SI_TOTAL / ROUND_UNIT) * ROUND_UNIT;
    RETURN SI_TOTAL_R;
  END SI_TOTAL_RFORMULA;
  FUNCTION SI_SI_MATL_RFORMULA(SI_SI_MATL IN NUMBER) RETURN NUMBER IS
    SI_SI_MATL_R NUMBER;
  BEGIN
    SI_SI_MATL_R := STANDARD.ROUND(SI_SI_MATL / ROUND_UNIT) * ROUND_UNIT;
    RETURN SI_SI_MATL_R;
  END SI_SI_MATL_RFORMULA;
  FUNCTION SI_SI_MOVH_RFORMULA(SI_SI_MOVH IN NUMBER) RETURN NUMBER IS
    SI_SI_MOVH_R NUMBER;
  BEGIN
    SI_SI_MOVH_R := ROUND(SI_SI_MOVH / ROUND_UNIT) * ROUND_UNIT;
    RETURN SI_SI_MOVH_R;
  END SI_SI_MOVH_RFORMULA;
  FUNCTION SI_SI_OVHD_RFORMULA(SI_SI_OVHD IN NUMBER) RETURN NUMBER IS
    SI_SI_OVHD_R NUMBER;
  BEGIN
    SI_SI_OVHD_R := ROUND(SI_SI_OVHD / ROUND_UNIT) * ROUND_UNIT;
    RETURN SI_SI_OVHD_R;
  END SI_SI_OVHD_RFORMULA;
  FUNCTION SI_SI_RES_RFORMULA(SI_SI_RES IN NUMBER) RETURN NUMBER IS
    SI_SI_RES_R NUMBER;
  BEGIN
    SI_SI_RES_R := ROUND(SI_SI_RES / ROUND_UNIT) * ROUND_UNIT;
    RETURN SI_SI_RES_R;
  END SI_SI_RES_RFORMULA;
  FUNCTION SI_SI_OSP_RFORMULA(SI_SI_OSP IN NUMBER) RETURN NUMBER IS
    SI_SI_OSP_R NUMBER;
  BEGIN
    SI_SI_OSP_R := ROUND(SI_SI_OSP / ROUND_UNIT) * ROUND_UNIT;
    RETURN SI_SI_OSP_R;
  END SI_SI_OSP_RFORMULA;
  FUNCTION P_REPORT_NAMEVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_REPORT_NAMEVALIDTRIGGER;
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF (P_SUBINV_FROM IS NULL AND P_SUBINV_TO IS NULL) THEN
      P_SUB_INV_SEC := '(1=1)';
    ELSIF (P_SUBINV_FROM IS NOT NULL AND P_SUBINV_TO IS NULL) THEN
      P_SUB_INV_SEC := 'SEC.SECONDARY_INVENTORY_NAME >= :P_SUBINV_FROM';
    ELSIF (P_SUBINV_FROM IS NULL AND P_SUBINV_TO IS NOT NULL) THEN
      P_SUB_INV_SEC := 'SEC.SECONDARY_INVENTORY_NAME <= :P_SUBINV_TO';
    ELSE
      P_SUB_INV_SEC := 'SEC.SECONDARY_INVENTORY_NAME BETWEEN
                                               :P_SUBINV_FROM AND :P_SUBINV_TO';
    END IF;
    IF (P_ZERO_QTY = 1 AND P_SUBINV_FROM IS NULL AND P_SUBINV_TO IS NULL) THEN
      P_SUBINV_WHERE := 'SEC.ORGANIZATION_ID (+)  = CIQT.ORGANIZATION_ID
                                  AND     SEC.SECONDARY_INVENTORY_NAME(+)  = CIQT.SUBINVENTORY_CODE';
    ELSE
      P_SUBINV_WHERE := 'SEC.ORGANIZATION_ID(+) = CIQT.ORGANIZATION_ID
                                  AND     SEC.SECONDARY_INVENTORY_NAME(+) = CIQT.SUBINVENTORY_CODE';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;
  FUNCTION IC_UNIT_COST1FORMULA(IC_ITEM_QTY IN NUMBER
                               ,IC_ITEM_TOTAL IN NUMBER
                               ,IC_UNIT_COST IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF (IC_ITEM_QTY <> 0) THEN
      RETURN ROUND((IC_ITEM_TOTAL / IC_ITEM_QTY)
                  ,P_EXT_PREC);
    ELSE
      RETURN (IC_UNIT_COST);
    END IF;
  END IC_UNIT_COST1FORMULA;
END BOM_CSTRINVR_XMLP_PKG;


/