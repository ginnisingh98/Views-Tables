--------------------------------------------------------
--  DDL for Package Body IGC_IGCCAPRR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_IGCCAPRR_XMLP_PKG" AS
/* $Header: IGCCAPRRB.pls 120.0.12010000.1 2008/07/28 06:28:29 appldev ship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    COAID NUMBER;
    SOBNAME VARCHAR2(30);
    FUNCTCURR VARCHAR2(15);
    ERRBUF VARCHAR2(132);
    ERRBUF2 VARCHAR2(132);
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    P_ACTIVITY_DATE1 := to_Char(P_ACTIVITY_DATE,'DD MON YYYY');
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    GL_INFO.GL_GET_LEDGER_INFO(P_SET_OF_BOOKS_ID
                              ,COAID
                              ,SOBNAME
                              ,FUNCTCURR
                              ,ERRBUF);
    IF (ERRBUF IS NOT NULL) THEN
      ERRBUF2 := GL_MESSAGE.GET_MESSAGE('GL_PLL_ROUTINE_ERROR'
                                       ,'N'
                                       ,'ROUTINE'
                                       ,'gl_get_set_of_books_info');
      /*SRW.MESSAGE('00'
                 ,ERRBUF2)*/NULL;
      /*SRW.MESSAGE('00'
                 ,ERRBUF)*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END IF;
    SET_OF_BOOKS_NAME := SOBNAME;
    CURRENCY_CODE := FUNCTCURR;
    SELECT
      NAME
    INTO ORG_NAME
    FROM
      HR_OPERATING_UNITS
    WHERE ORGANIZATION_ID = P_ORG_ID;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION SET_OF_BOOKS_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SET_OF_BOOKS_NAME;
  END SET_OF_BOOKS_NAME_P;

  FUNCTION CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CURRENCY_CODE;
  END CURRENCY_CODE_P;

  FUNCTION ORG_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ORG_NAME;
  END ORG_NAME_P;

END IGC_IGCCAPRR_XMLP_PKG;

/
