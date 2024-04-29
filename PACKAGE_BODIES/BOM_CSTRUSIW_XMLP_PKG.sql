--------------------------------------------------------
--  DDL for Package Body BOM_CSTRUSIW_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTRUSIW_XMLP_PKG" AS
/* $Header: CSTRUSIWB.pls 120.0 2007/12/24 10:21:36 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      WMS_ORG_COUNT NUMBER;
      PJM_ORG_COUNT NUMBER;
    BEGIN
      SELECT
        count(*)
      INTO WMS_ORG_COUNT
      FROM
        MTL_PARAMETERS
      WHERE WMS_ENABLED_FLAG = 'Y'
        AND ORGANIZATION_ID = P_ORG_ID;
      SELECT
        count(*)
      INTO PJM_ORG_COUNT
      FROM
        MTL_PARAMETERS
      WHERE COST_GROUP_ACCOUNTING = 1
        AND PROJECT_REFERENCE_ENABLED = 1
        AND ORGANIZATION_ID = P_ORG_ID;
      IF WMS_ORG_COUNT < 1 AND PJM_ORG_COUNT < 1 THEN
        FND_MESSAGE.SET_NAME('BOM'
                            ,'CST_WMS_ORG_REPORT_ONLY');
        /*SRW.MESSAGE(24200
                   ,FND_MESSAGE.GET)*/NULL;
        RETURN FALSE;
      END IF;
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
          CAT.CATEGORY_SET_NAME,
          CAT.CATEGORY_SET_ID,
          CAT.STRUCTURE_ID,
          O.ORGANIZATION_NAME ORGANIZATION,
          LU1.MEANING,
          LU2.MEANING,
          CCT.COST_TYPE
        INTO P_CURRENCY_CODE,EXT_PREC,ROUND_UNIT,P_GL_NUM,P_CAT_SET_NAME,P_CATEGORY_SET,P_CAT_NUM,P_ORGANIZATION,P_SORT_BY,P_ITEM_RANGE,P_COST_TYPE
        FROM
          FND_CURRENCIES FC,
          GL_SETS_OF_BOOKS SOB,
          ORG_ORGANIZATION_DEFINITIONS O,
          MTL_CATEGORY_SETS CAT,
          MTL_DEFAULT_CATEGORY_SETS DCAT,
          CST_COST_TYPES CCT,
          MFG_LOOKUPS LU1,
          MFG_LOOKUPS LU2
        WHERE O.ORGANIZATION_ID = P_ORG_ID
          AND O.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
          AND SOB.CURRENCY_CODE = FC.CURRENCY_CODE
          AND FC.ENABLED_FLAG = 'Y'
          AND DCAT.FUNCTIONAL_AREA_ID = 5
          AND CAT.CATEGORY_SET_ID = DECODE(P_RANGE_OPTION
              ,5
              ,P_CATEGORY_SET
              ,DECODE(P_SORT_OPTION
                    ,2
                    ,P_CATEGORY_SET
                    ,DCAT.CATEGORY_SET_ID))
          AND LU1.LOOKUP_TYPE = 'CST_ITEM_REPORT_SORT'
          AND LU1.LOOKUP_CODE = P_SORT_OPTION
          AND LU2.LOOKUP_TYPE = 'CST_ITEM_RANGE'
          AND LU2.LOOKUP_CODE = P_RANGE_OPTION
          AND CCT.COST_TYPE_ID = P_COST_TYPE_ID;
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
          CAT.CATEGORY_SET_NAME,
          CAT.CATEGORY_SET_ID,
          CAT.STRUCTURE_ID,
          O.ORGANIZATION_NAME,
          C.RANGE_OPTION,
          LU1.MEANING,
          LU2.MEANING,
          C.ITEM_RANGE_LOW,
          C.ITEM_RANGE_HIGH,
          C.SINGLE_ITEM,
          C.CATEGORY_ID,
          C.INV_ADJUSTMENT_ACCOUNT,
          C.UPDATE_DATE,
          C.DESCRIPTION,
          CCT.COST_TYPE
        INTO P_CURRENCY_CODE,EXT_PREC,ROUND_UNIT,P_GL_NUM,P_CAT_SET_NAME,P_CATEGORY_SET,P_CAT_NUM,P_ORGANIZATION,P_RANGE_OPTION,P_SORT_BY,P_ITEM_RANGE,P_ITEM_FROM,P_ITEM_TO,P_ITEM,P_CAT,P_ADJ_ACCOUNT,P_UPDATE_DATE,P_UPDATE_DESC,P_COST_TYPE
        FROM
          FND_CURRENCIES FC,
          GL_SETS_OF_BOOKS SOB,
          ORG_ORGANIZATION_DEFINITIONS O,
          MTL_CATEGORY_SETS CAT,
          MTL_DEFAULT_CATEGORY_SETS DCAT,
          MFG_LOOKUPS LU1,
          MFG_LOOKUPS LU2,
          CST_COST_TYPES CCT,
          CST_COST_UPDATES C
        WHERE C.COST_UPDATE_ID = P_UPDATE_ID
          AND O.ORGANIZATION_ID = C.ORGANIZATION_ID
          AND O.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
          AND SOB.CURRENCY_CODE = FC.CURRENCY_CODE
          AND FC.ENABLED_FLAG = 'Y'
          AND DCAT.FUNCTIONAL_AREA_ID = 5
          AND CAT.CATEGORY_SET_ID = NVL(C.CATEGORY_SET_ID
           ,DCAT.CATEGORY_SET_ID)
          AND LU1.LOOKUP_TYPE = 'CST_ITEM_REPORT_SORT'
          AND LU1.LOOKUP_CODE = P_SORT_OPTION
          AND LU2.LOOKUP_TYPE = 'CST_ITEM_RANGE'
          AND LU2.LOOKUP_CODE = C.RANGE_OPTION
          AND CCT.COST_TYPE_ID = C.COST_TYPE_ID;
      END IF;
      IF P_SORT_OPTION = 8 THEN
        /*SRW.SET_MAXROW('Q_IC_MAIN'
                      ,0)*/NULL;
      ELSE
        /*SRW.SET_MAXROW('Q_CG_MAIN'
                      ,0)*/NULL;
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
                 ,'BOM_CSTRUSIW_XMLP_PKG <<     ' || TO_CHAR(SYSDATE
                        ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(999
                   ,SQLERRM)*/NULL;
        /*SRW.MESSAGE(999
                   ,'BOM_CSTRUSIW_XMLP_PKG >X     ' || TO_CHAR(SYSDATE
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
           AND TRANSACTION_TYPE = 1;
        COMMIT;
      END IF;
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
      /*SRW.MESSAGE(0
                 ,'CSTRUSIA >>     ' || TO_CHAR(SYSDATE
                        ,'Dy Mon FmDD HH24:MI:SS YYYY'))*/NULL;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(999
                   ,SQLERRM)*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CG_CG_ADJFORMULA(CG_CG_MTL IN NUMBER
                           ,CG_CG_MOH IN NUMBER
                           ,CG_CG_RES IN NUMBER
                           ,CG_CG_OSP IN NUMBER
                           ,CG_CG_OVH IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (-(CG_CG_MTL + CG_CG_MOH + CG_CG_RES + CG_CG_OSP + CG_CG_OVH));
  END CG_CG_ADJFORMULA;

  FUNCTION ORG_ADJFORMULA(CG_ORG_MTL IN NUMBER
                         ,CG_ORG_MOH IN NUMBER
                         ,CG_ORG_RES IN NUMBER
                         ,CG_ORG_OSP IN NUMBER
                         ,CG_ORG_OVH IN NUMBER
                         ,IC_ORG_MTL IN NUMBER
                         ,IC_ORG_MOH IN NUMBER
                         ,IC_ORG_RES IN NUMBER
                         ,IC_ORG_OSP IN NUMBER
                         ,IC_ORG_OVH IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_SORT_OPTION = 8 THEN
      RETURN (-(CG_ORG_MTL + CG_ORG_MOH + CG_ORG_RES + CG_ORG_OSP + CG_ORG_OVH));
    ELSE
      RETURN (-(IC_ORG_MTL + IC_ORG_MOH + IC_ORG_RES + IC_ORG_OSP + IC_ORG_OVH));
    END IF;
    RETURN NULL;
  END ORG_ADJFORMULA;

  FUNCTION REP_ADJFORMULA(CG_REP_MTL IN NUMBER
                         ,CG_REP_MOH IN NUMBER
                         ,CG_REP_RES IN NUMBER
                         ,CG_REP_OSP IN NUMBER
                         ,CG_REP_OVH IN NUMBER
                         ,IC_REP_MTL IN NUMBER
                         ,IC_REP_MOH IN NUMBER
                         ,IC_REP_RES IN NUMBER
                         ,IC_REP_OSP IN NUMBER
                         ,IC_REP_OVH IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_SORT_OPTION = 8 THEN
      RETURN (-(CG_REP_MTL + CG_REP_MOH + CG_REP_RES + CG_REP_OSP + CG_REP_OVH));
    ELSE
      RETURN (-(IC_REP_MTL + IC_REP_MOH + IC_REP_RES + IC_REP_OSP + IC_REP_OVH));
    END IF;
    RETURN NULL;
  END REP_ADJFORMULA;

  FUNCTION IC_ORDERFORMULA(IC_ITEM_NUMBER IN VARCHAR2
                          ,IC_CATEGORY IN VARCHAR2
                          ,IC_ITEM_SEG IN VARCHAR2
                          ,IC_CAT_SEG IN VARCHAR2
                          ,IC_ITEM_PSEG IN VARCHAR2
                          ,IC_CAT_PSEG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(IC_ITEM_NUMBER)*/NULL;
    /*SRW.REFERENCE(IC_CATEGORY)*/NULL;
    /*SRW.REFERENCE(IC_ITEM_SEG)*/NULL;
    /*SRW.REFERENCE(IC_CAT_SEG)*/NULL;
    /*SRW.REFERENCE(IC_ITEM_PSEG)*/NULL;
    /*SRW.REFERENCE(IC_CAT_PSEG)*/NULL;
    IF P_SORT_OPTION = 1 THEN
      RETURN (IC_ITEM_PSEG);
    ELSE
      RETURN (IC_CAT_PSEG);
    END IF;
    RETURN NULL;
  END IC_ORDERFORMULA;

  FUNCTION IC_CAT_PSEGFORMULA(IC_CATEGORY IN VARCHAR2
                             ,IC_CAT_SEG IN VARCHAR2
                             ,IC_CAT_PSEG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(IC_CATEGORY)*/NULL;
    /*SRW.REFERENCE(IC_CAT_SEG)*/NULL;
    RETURN (IC_CAT_PSEG);
  END IC_CAT_PSEGFORMULA;

  FUNCTION IC_ITEM_PSEGFORMULA(IC_ITEM_NUMBER IN VARCHAR2
                              ,IC_ITEM_SEG IN VARCHAR2
                              ,IC_ITEM_PSEG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(IC_ITEM_NUMBER)*/NULL;
    /*SRW.REFERENCE(IC_ITEM_SEG)*/NULL;
    /*SRW.REFERENCE(IC_ITEM_PSEG)*/NULL;
    RETURN (IC_ITEM_PSEG);
  END IC_ITEM_PSEGFORMULA;

  FUNCTION CG_ITEM_PSEGFORMULA(CG_ITEM_NUMBER IN VARCHAR2
                              ,CG_ITEM_SEG IN VARCHAR2
                              ,CG_ITEM_PSEG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(CG_ITEM_NUMBER)*/NULL;
    /*SRW.REFERENCE(CG_ITEM_SEG)*/NULL;
    /*SRW.REFERENCE(CG_ITEM_PSEG)*/NULL;
    RETURN (CG_ITEM_PSEG);
  END CG_ITEM_PSEGFORMULA;
FUNCTION dummy1 return boolean is
begin
IF P_SORT_OPTION = 8 THEN
 return(false);
 end if;
END dummy1;

FUNCTION dummy2 return boolean is
begin
IF P_SORT_OPTION <> 8 THEN
 return(false);
 end if;
END dummy2;

FUNCTION dummy3 return boolean is
begin
IF P_RANGE_OPTION <> 2 THEN
 return(false);
 end if;
END dummy3;

FUNCTION dummy4 return boolean is
begin
IF P_RANGE_OPTION <> 5 THEN
 return(false);
 end if;
END dummy4;

END BOM_CSTRUSIW_XMLP_PKG;


/
