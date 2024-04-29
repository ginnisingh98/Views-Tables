--------------------------------------------------------
--  DDL for Package Body BOM_CSTRUSJA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTRUSJA_XMLP_PKG" AS
/* $Header: CSTRUSJAB.pls 120.1 2008/01/02 15:06:30 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
    qty_precision:=bom_common_xmlp_pkg.get_precision(P_qty_precision);
      IF P_RPT_ONLY = 1 THEN
        SELECT
          FC.CURRENCY_CODE,
          NVL(FC.EXTENDED_PRECISION
             ,FC.PRECISION),
          NVL(FC.MINIMUM_ACCOUNTABLE_UNIT
             ,POWER(10
                  ,NVL(-PRECISION
                     ,0))),
          SOB.CHART_OF_ACCOUNTS_ID,
          O.ORGANIZATION_NAME ORGANIZATION,
          CAT.CATEGORY_SET_NAME,
          CAT.STRUCTURE_ID,
          LU2.MEANING,
          CCT.COST_TYPE
        INTO P_CURRENCY_CODE,EXT_PREC,ROUND_UNIT,P_GL_NUM,P_ORGANIZATION,P_CAT_SET_NAME,P_CAT_NUM,P_ITEM_RANGE,P_COST_TYPE
        FROM
          FND_CURRENCIES FC,
          GL_SETS_OF_BOOKS SOB,
          ORG_ORGANIZATION_DEFINITIONS O,
          MTL_CATEGORY_SETS CAT,
          MTL_DEFAULT_CATEGORY_SETS DCAT,
          MFG_LOOKUPS LU2,
          CST_COST_TYPES CCT
        WHERE O.ORGANIZATION_ID = P_ORG_ID
          AND O.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
          AND SOB.CURRENCY_CODE = FC.CURRENCY_CODE
          AND FC.ENABLED_FLAG = 'Y'
          AND DCAT.FUNCTIONAL_AREA_ID = 5
          AND CAT.CATEGORY_SET_ID = DECODE(P_RANGE_OPTION
              ,5
              ,P_CATEGORY_SET
              ,DCAT.CATEGORY_SET_ID)
          AND CCT.COST_TYPE_ID = P_COST_TYPE_ID
          AND LU2.LOOKUP_TYPE = 'CST_ITEM_RANGE'
          AND LU2.LOOKUP_CODE = P_RANGE_OPTION;
      ELSE
        SELECT
          FC.CURRENCY_CODE,
          NVL(FC.EXTENDED_PRECISION
             ,FC.PRECISION),
          NVL(FC.MINIMUM_ACCOUNTABLE_UNIT
             ,POWER(10
                  ,NVL(-PRECISION
                     ,0))),
          SOB.CHART_OF_ACCOUNTS_ID,
          O.ORGANIZATION_NAME,
          C.RANGE_OPTION,
          LU2.MEANING,
          C.ITEM_RANGE_LOW,
          C.ITEM_RANGE_HIGH,
          C.SINGLE_ITEM,
          C.CATEGORY_ID,
          C.CATEGORY_SET_ID,
          CAT.CATEGORY_SET_NAME,
          CAT.STRUCTURE_ID,
          CCT.COST_TYPE,
          C.UPDATE_DATE,
          C.DESCRIPTION
        INTO P_CURRENCY_CODE,EXT_PREC,ROUND_UNIT,P_GL_NUM,P_ORGANIZATION,P_RANGE_OPTION,P_ITEM_RANGE,P_ITEM_FROM,P_ITEM_TO,P_ITEM,P_CAT,P_CATEGORY_SET,P_CAT_SET_NAME,P_CAT_NUM,P_COST_TYPE,P_UPDATE_DATE,P_UPDATE_DESC
        FROM
          FND_CURRENCIES FC,
          GL_SETS_OF_BOOKS SOB,
          ORG_ORGANIZATION_DEFINITIONS O,
          MTL_CATEGORY_SETS CAT,
          MTL_DEFAULT_CATEGORY_SETS DCAT,
          MFG_LOOKUPS LU2,
          CST_COST_UPDATES C,
          CST_COST_TYPES CCT
        WHERE C.COST_UPDATE_ID = P_UPDATE_ID
          AND O.ORGANIZATION_ID = C.ORGANIZATION_ID
          AND O.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
          AND SOB.CURRENCY_CODE = FC.CURRENCY_CODE
          AND FC.ENABLED_FLAG = 'Y'
          AND DCAT.FUNCTIONAL_AREA_ID = 5
          AND CAT.CATEGORY_SET_ID = NVL(C.CATEGORY_SET_ID
           ,DCAT.CATEGORY_SET_ID)
          AND CCT.COST_TYPE_ID = C.COST_TYPE_ID
          AND LU2.LOOKUP_TYPE = 'CST_ITEM_RANGE'
          AND LU2.LOOKUP_CODE = C.RANGE_OPTION;
      END IF;
      IF P_RANGE_OPTION <> 2 THEN
        /*SRW.SET_MAXROW('Q_ITEM'
                      ,0)*/NULL;
      END IF;
      IF P_RANGE_OPTION <> 5 THEN
        /*SRW.SET_MAXROW('Q_CAT'
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
      BEGIN
        NULL;
      EXCEPTION
        WHEN OTHERS THEN
          /*SRW.MESSAGE(999
                     ,'FND FLEXSQL(GL#) >X')*/NULL;
          RAISE;
      END;
      /*SRW.MESSAGE(0
                 ,'BOM_CSTRUSJA_XMLP_PKG <<     ' || TO_CHAR(SYSDATE
                        ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(999
                   ,SQLERRM)*/NULL;
        /*SRW.MESSAGE(999
                   ,'BOM_CSTRUSJA_XMLP_PKG >X     ' || TO_CHAR(SYSDATE
                          ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF P_DEL_SNAPSHOT = 1 THEN
        ROLLBACK;
        DELETE FROM CST_STD_COST_ADJ_VALUES
         WHERE COST_UPDATE_ID = P_UPDATE_ID
           AND TRANSACTION_TYPE > 2;
        COMMIT;
      END IF;
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
      /*SRW.MESSAGE(0
                 ,'BOM_CSTRUSJA_XMLP_PKG >>     ' || TO_CHAR(SYSDATE
                        ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(999
                   ,SQLERRM)*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION JOB_ADJFORMULA(JOB_MTL IN NUMBER
                         ,JOB_MOH IN NUMBER
                         ,JOB_RES IN NUMBER
                         ,JOB_OSP IN NUMBER
                         ,JOB_OVH IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN -ROUND((JOB_MTL + JOB_MOH + JOB_RES + JOB_OSP + JOB_OVH) / ROUND_UNIT) * ROUND_UNIT;
  END JOB_ADJFORMULA;

  FUNCTION CLASS_ADJFORMULA(CLASS_MTL IN NUMBER
                           ,CLASS_MOH IN NUMBER
                           ,CLASS_RES IN NUMBER
                           ,CLASS_OSP IN NUMBER
                           ,CLASS_OVH IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN -ROUND((CLASS_MTL + CLASS_MOH + CLASS_RES + CLASS_OSP + CLASS_OVH) / ROUND_UNIT) * ROUND_UNIT;
  END CLASS_ADJFORMULA;

  FUNCTION REP_ADJFORMULA(REP_MTL IN NUMBER
                         ,REP_MOH IN NUMBER
                         ,REP_RES IN NUMBER
                         ,REP_OSP IN NUMBER
                         ,REP_OVH IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN -ROUND((REP_MTL + REP_MOH + REP_RES + REP_OSP + REP_OVH) / ROUND_UNIT) * ROUND_UNIT;
  END REP_ADJFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION OLD_COST2FORMULA(TRANS_TYPE IN NUMBER
                           ,OUC IN NUMBER
                           ,COUNT_QTY IN NUMBER
                           ,SUM_LEVEL IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF (TRANS_TYPE in (5,8,9)) THEN
      RETURN (OUC);
    ELSE
      BEGIN
        IF COUNT_QTY = 0 THEN
          RETURN (OUC);
        END IF;
        IF (SUM_LEVEL / COUNT_QTY) = 1 OR (SUM_LEVEL / COUNT_QTY) = 2 THEN
          RETURN (ROUND((OUC / COUNT_QTY)
                      ,EXT_PREC));
        ELSE
          RETURN (ROUND((OUC * 2 / COUNT_QTY)
                      ,EXT_PREC));
        END IF;
      END;
      RETURN (OUC);
    END IF;
    RETURN NULL;
  END OLD_COST2FORMULA;

  FUNCTION NEW_COST2FORMULA(TRANS_TYPE IN NUMBER
                           ,NUC IN NUMBER
                           ,COUNT_QTY IN NUMBER
                           ,SUM_LEVEL IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF (TRANS_TYPE in (5,8,9)) THEN
      RETURN (NUC);
    ELSE
      BEGIN
        IF COUNT_QTY = 0 THEN
          RETURN (NUC);
        END IF;
        IF (SUM_LEVEL / COUNT_QTY) = 1 OR (SUM_LEVEL / COUNT_QTY) = 2 THEN
          RETURN (ROUND((NUC / COUNT_QTY)
                      ,EXT_PREC));
        ELSE
          RETURN (ROUND((NUC * 2 / COUNT_QTY)
                      ,EXT_PREC));
        END IF;
      END;
      RETURN (NUC);
    END IF;
    RETURN NULL;
  END NEW_COST2FORMULA;

  FUNCTION ADJ_QTY_DISPLAYFORMULA(COUNT_QTY IN NUMBER
                                 ,ADJ_QTY_DSP IN NUMBER
                                 ,TRANSACTION_CODE IN NUMBER
                                 ,SUM_LEVEL IN NUMBER) RETURN NUMBER IS
    L_QTY NUMBER;
  BEGIN
    IF COUNT_QTY = 0 THEN
      RETURN ADJ_QTY_DSP;
    END IF;
    SELECT
      DECODE(TRANSACTION_CODE
            ,4
            ,DECODE(SUM_LEVEL / COUNT_QTY
                  ,1
                  ,ADJ_QTY_DSP
                  ,2
                  ,ADJ_QTY_DSP
                  ,ADJ_QTY_DSP / 2)
            ,ADJ_QTY_DSP)
    INTO L_QTY
    FROM
      DUAL;
    RETURN (L_QTY);
  END ADJ_QTY_DISPLAYFORMULA;

END BOM_CSTRUSJA_XMLP_PKG;


/
