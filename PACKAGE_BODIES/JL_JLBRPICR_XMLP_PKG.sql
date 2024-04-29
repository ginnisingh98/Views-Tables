--------------------------------------------------------
--  DDL for Package Body JL_JLBRPICR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_JLBRPICR_XMLP_PKG" AS
/* $Header: JLBRPICRB.pls 120.1 2007/12/25 16:40:11 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    DECLARE
      L_NAME VARCHAR2(30);
      CURR VARCHAR2(15);
    BEGIN
      SELECT
        SUBSTR(NAME
              ,1
              ,30),
        CURRENCY_CODE
      INTO L_NAME,CURR
      FROM
        GL_SETS_OF_BOOKS
      WHERE SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID;
      CURRENCY_CODE := CURR;
      C_COMPANY_NAME_HEADER := L_NAME;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    BEGIN
      DELETE FROM JL_BR_AP_INT_COLLECTION_TMP
       WHERE FILE_CONTROL = P_FILE_CONTROL;
    EXCEPTION
      WHEN /*SRW.DO_SQL_FAILURE*/OTHERS THEN
        NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMPANY_NAME_HEADER;
  END C_COMPANY_NAME_HEADER_P;

  FUNCTION CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CURRENCY_CODE;
  END CURRENCY_CODE_P;

END JL_JLBRPICR_XMLP_PKG;



/
