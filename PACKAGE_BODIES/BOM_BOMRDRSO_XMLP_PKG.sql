--------------------------------------------------------
--  DDL for Package Body BOM_BOMRDRSO_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BOMRDRSO_XMLP_PKG" AS
/* $Header: BOMRDRSOB.pls 120.0 2007/12/24 09:44:16 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      L_CURRENCY_CODE GL_SETS_OF_BOOKS.CURRENCY_CODE%TYPE;
      L_ORG_NAME ORG_ORGANIZATION_DEFINITIONS.ORGANIZATION_NAME%TYPE;
      L_DTL_SUM_CHAR MFG_LOOKUPS.MEANING%TYPE;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      SELECT
        BOOKS.CURRENCY_CODE,
        ORG.ORGANIZATION_NAME,
        LU.MEANING
      INTO L_CURRENCY_CODE,L_ORG_NAME,L_DTL_SUM_CHAR
      FROM
        GL_SETS_OF_BOOKS BOOKS,
        ORG_ORGANIZATION_DEFINITIONS ORG,
        MFG_LOOKUPS LU
      WHERE ORG.ORGANIZATION_ID = P_ORG_ID
        AND BOOKS.SET_OF_BOOKS_ID = ORG.SET_OF_BOOKS_ID
        AND LU.LOOKUP_CODE = P_DETAIL_OR_SUMMARY
        AND LU.LOOKUP_TYPE = 'CST_RPT_DETAIL_OPTION';
      P_ORG_NAME := L_ORG_NAME;
      P_CURRENCY_CODE := L_CURRENCY_CODE;
      P_DTL_SUM_CHAR := L_DTL_SUM_CHAR;
      IF P_DETAIL_OR_SUMMARY = 1 THEN
        /*SRW.SET_MAXROW('Q_std_op_sum'
                      ,0)*/NULL;
      ELSE
        /*SRW.SET_MAXROW('Q_std_op_dtl'
                      ,0)*/NULL;
        /*SRW.SET_MAXROW('Q_std_op_rsc'
                      ,0)*/NULL;
      END IF;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

END BOM_BOMRDRSO_XMLP_PKG;


/