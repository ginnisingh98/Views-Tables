--------------------------------------------------------
--  DDL for Package Body BOM_CSTRLIVR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTRLIVR_XMLP_PKG" AS
/* $Header: CSTRLIVRB.pls 120.0 2007/12/24 10:06:25 dwkrishn noship $ */
  FUNCTION CF_ORDERFORMULA(CATEGORY IN VARCHAR2) RETURN CHAR IS
  BEGIN
    IF (P_SORT_OPTION = 1) THEN
      RETURN NULL;
    ELSE
      RETURN CATEGORY;
    END IF;
  END CF_ORDERFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_FCN_CURRENCY VARCHAR2(15);
    SQL_STMT_NUM VARCHAR2(5);
    FIFO_ORG_COUNT NUMBER;
  BEGIN
    SQL_STMT_NUM := '-10: ';
    PV_EXCHANGE_RATE := FND_NUMBER.CANONICAL_TO_NUMBER(P_EXCHANGE_RATE_CHAR);
    SQL_STMT_NUM := '0: ';
    SELECT
      COUNT(*)
    INTO FIFO_ORG_COUNT
    FROM
      MTL_PARAMETERS
    WHERE ORGANIZATION_ID = P_ORG_ID
      AND PRIMARY_COST_METHOD IN ( 5 , 6 );
    IF FIFO_ORG_COUNT < 1 THEN
      FND_MESSAGE.SET_NAME('BOM'
                          ,'CST_FIFO_LIFO_ORG_REPORT_ONLY');
      /*SRW.MESSAGE(24200
                 ,FND_MESSAGE.GET)*/NULL;
      RETURN FALSE;
    END IF;
    SQL_STMT_NUM := '10: ';
    IF P_VIEW_COST <> 1 THEN
      FND_MESSAGE.SET_NAME('null'
                          ,'null');
      /*SRW.USER_EXIT('FND MESSAGE_DISPLAY')*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END IF;
    SQL_STMT_NUM := '15: ';
    IF P_ZERO_COST_LAYERS = 2 THEN
      P_ZERO_COST_WHERE := 'CIL.LAYER_COST <>0';
    END IF;
    IF P_ZERO_QTY_LAYERS = 2 THEN
      P_ZERO_QTY_WHERE := 'CIL.LAYER_QUANTITY <>0';
    END IF;
    SQL_STMT_NUM := '20: ';
    SQL_STMT_NUM := '30: ';
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
      NVL(EXTENDED_PRECISION
         ,PRECISION)
    INTO PV_ORGANIZATION_NAME,L_FCN_CURRENCY,PV_ROUND_UNIT,PV_CATEGORY_SET_NAME,PV_SORT_OPTION,PV_COST_GROUP_OPTION,PV_ZERO_COST_LAYER,PV_REPORT_OPTION,PV_ZERO_QTY_LAYER,P_EXT_PREC
    FROM
      ORG_ORGANIZATION_DEFINITIONS OOD,
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
      AND LOOKUP1.LOOKUP_TYPE = 'CST_ITEM_REPORT_SORT'
      AND LOOKUP1.LOOKUP_CODE = P_SORT_OPTION
      AND LOOKUP2.LOOKUP_TYPE = 'CST_SRS_COST_GROUP_OPTION'
      AND LOOKUP2.LOOKUP_CODE = P_COST_GROUP_OPTION_ID
      AND LOOKUP3.LOOKUP_TYPE = 'SYS_YES_NO'
      AND LOOKUP3.LOOKUP_CODE = P_ZERO_COST_LAYERS
      AND LOOKUP4.LOOKUP_TYPE = 'CST_BICR_DETAIL_OPTION'
      AND LOOKUP4.LOOKUP_CODE = P_RPT_OPTION
      AND LOOKUP5.LOOKUP_TYPE = 'SYS_YES_NO'
      AND LOOKUP5.LOOKUP_CODE = P_ZERO_QTY_LAYERS;
    SQL_STMT_NUM := '40: ';
    IF P_COST_GROUP_OPTION_ID = 2 THEN
      SELECT
        COST_GROUP
      INTO PV_SPECIFIC_COST_GROUP
      FROM
        CST_COST_GROUPS
      WHERE COST_GROUP_ID = P_COST_GROUP_ID;
    END IF;
    SQL_STMT_NUM := '50: ';
    IF L_FCN_CURRENCY = P_CURRENCY_CODE THEN
      PV_CURRENCY_CODE := P_CURRENCY_CODE;
    ELSE
      PV_CURRENCY_CODE := P_CURRENCY_CODE || ' @ ' || TO_CHAR(ROUND(1 / PV_EXCHANGE_RATE
                                       ,5)) || ' ' || L_FCN_CURRENCY;
    END IF;
    SQL_STMT_NUM := '60: ';
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(999
                   ,'FND SRWINIT >X')*/NULL;
        RAISE;
    END;
    SQL_STMT_NUM := '70: ';
    BEGIN
      SQL_STMT_NUM := '71: ';
      SQL_STMT_NUM := '72: ';
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(999
                   ,'FND FLEXSQL(MCAT) >X')*/NULL;
        RAISE;
    END;
    SQL_STMT_NUM := '80: ';
    BEGIN
      SQL_STMT_NUM := '81: ';
      SQL_STMT_NUM := '82: ';
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(999
                   ,'FND FLEXSQL(MSTK) >X')*/NULL;
        RAISE;
    END;
    SQL_STMT_NUM := '90: ';
    /*SRW.MESSAGE(0
               ,'CSTRAIVR <<     ' || TO_CHAR(SYSDATE
                      ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(999
                 ,SQL_STMT_NUM || SQLERRM)*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION BETWEENPAGE RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BETWEENPAGE;

  FUNCTION P_ITEM_WHEREVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_ITEM_WHEREVALIDTRIGGER;

END BOM_CSTRLIVR_XMLP_PKG;


/