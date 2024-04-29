--------------------------------------------------------
--  DDL for Package Body INV_INVIRTMP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVIRTMP_XMLP_PKG" AS
/* $Header: INVIRTMPB.pls 120.2 2008/01/08 06:34:26 dwkrishn noship $ */
  FUNCTION R_CURRENCY_CODEFORMULA(C_CURRENCY IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN ('(' || C_CURRENCY || ')');
  END R_CURRENCY_CODEFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF ((P_RESP_APPL_ID = -1) AND (P_RESP_ID = -1)) THEN
        P_ATTRIBUTE_NAME := 'IA.USER_ATTRIBUTE_NAME';
      ELSE
        SELECT
          DECODE(FR.VERSION
                ,NULL
                ,'IA.USER_ATTRIBUTE_NAME'
                ,'4'
                ,'IA.USER_ATTRIBUTE_NAME_GUI'
                ,'IA.USER_ATTRIBUTE_NAME_GUI')
        INTO P_ATTRIBUTE_NAME
        FROM
          FND_RESPONSIBILITY FR
        WHERE FR.APPLICATION_ID = P_RESP_APPL_ID
          AND FR.RESPONSIBILITY_ID = P_RESP_ID;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_ATTRIBUTE_NAME := 'IA.USER_ATTRIBUTE_NAME';
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

END INV_INVIRTMP_XMLP_PKG;


/
