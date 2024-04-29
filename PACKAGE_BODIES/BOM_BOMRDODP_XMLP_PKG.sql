--------------------------------------------------------
--  DDL for Package Body BOM_BOMRDODP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BOMRDODP_XMLP_PKG" AS
/* $Header: BOMRDODPB.pls 120.0 2007/12/24 09:42:54 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    IF P_OVERHEAD_FLAG = 2 AND P_RESOURCE_FLAG = 2 THEN
      /*SRW.SET_MAXROW('Q_ovrhd'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_res'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_shift'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_changes'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_dept'
                    ,0)*/NULL;
    ELSE
      IF P_OVERHEAD_FLAG = 1 AND P_RESOURCE_FLAG = 2 THEN
        /*SRW.SET_MAXROW('Q_res'
                      ,0)*/NULL;
        /*SRW.SET_MAXROW('Q_shift'
                      ,0)*/NULL;
        /*SRW.SET_MAXROW('Q_changes'
                      ,0)*/NULL;
        /*SRW.SET_MAXROW('Q_dept_only'
                      ,0)*/NULL;
      ELSE
        IF P_OVERHEAD_FLAG = 2 AND P_RESOURCE_FLAG = 1 THEN
          /*SRW.SET_MAXROW('Q_ovrhd'
                        ,0)*/NULL;
          /*SRW.SET_MAXROW('Q_dept_only'
                        ,0)*/NULL;
        ELSE
          /*SRW.SET_MAXROW('Q_dept_only'
                        ,0)*/NULL;
        END IF;
      END IF;
    END IF;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    DECLARE
      L_EXT_PRECISION NUMBER;
      L_STD_PRECISION NUMBER;
    BEGIN
      SELECT
        NVL(FC.EXTENDED_PRECISION
           ,FC.PRECISION),
        NVL(FC.PRECISION
           ,0)
      INTO L_EXT_PRECISION,L_STD_PRECISION
      FROM
        GL_SETS_OF_BOOKS GL,
        FND_CURRENCIES FC,
        ORG_ORGANIZATION_DEFINITIONS O
      WHERE O.ORGANIZATION_ID = P_ORG_ID
        AND O.SET_OF_BOOKS_ID = GL.SET_OF_BOOKS_ID
        AND FC.CURRENCY_CODE = GL.CURRENCY_CODE;
      P_EXT_PRECISION := L_EXT_PRECISION;
      P_STD_PRECISION := L_STD_PRECISION;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION SUBTITLEFORMULA(CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_OVERHEAD_FLAG = 2 AND P_RESOURCE_FLAG = 2 THEN
        RETURN ('Departments Only');
      ELSE
        IF P_OVERHEAD_FLAG = 1 AND P_RESOURCE_FLAG = 2 THEN
          RETURN ('Overhead Data (' || CURRENCY_CODE || ')');
        ELSE
          IF P_OVERHEAD_FLAG = 2 AND P_RESOURCE_FLAG = 1 THEN
            RETURN ('Resource Data');
          ELSE
            IF P_OVERHEAD_FLAG = 1 AND P_RESOURCE_FLAG = 1 THEN
              RETURN ('Resource and Overhead Data (' || CURRENCY_CODE || ')');
            END IF;
          END IF;
        END IF;
      END IF;
    END;
    RETURN NULL;
  END SUBTITLEFORMULA;

  FUNCTION ROUND_AMOUNTFORMULA(RATE_OR_AMOUNT IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(RATE_OR_AMOUNT
                ,P_QTY_PRECISION));
  END ROUND_AMOUNTFORMULA;

END BOM_BOMRDODP_XMLP_PKG;


/
