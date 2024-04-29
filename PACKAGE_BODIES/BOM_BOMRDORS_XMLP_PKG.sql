--------------------------------------------------------
--  DDL for Package Body BOM_BOMRDORS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BOMRDORS_XMLP_PKG" AS
/* $Header: BOMRDORSB.pls 120.0 2007/12/24 09:43:33 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    IF P_REPORT_TYPE = 1 THEN
      /*SRW.SET_MAXROW('Q_Res_Only'
                    ,0)*/NULL;
    ELSE
      /*SRW.SET_MAXROW('Q_Res_Costs'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_Ovrhds'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_Res'
                    ,0)*/NULL;
    END IF;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.USER_EXIT('FND FLEXSQL CODE="MSTK" NUM=":P_STRUCT_NUM"
                                 APPL_SHORT_NAME="INV" OUTPUT=":P_FLEXDATA"
                                 MODE="SELECT" DISPLAY="ALL" TABLEALIAS="msi"')*/NULL;
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
      IF P_REPORT_TYPE = 1 THEN
        RETURN ('Detail (' || CURRENCY_CODE || ')');
      ELSE
        RETURN ('Summary');
      END IF;
    END;
    RETURN NULL;
  END SUBTITLEFORMULA;

END BOM_BOMRDORS_XMLP_PKG;


/
