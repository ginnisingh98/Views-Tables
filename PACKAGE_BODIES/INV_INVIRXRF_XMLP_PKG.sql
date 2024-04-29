--------------------------------------------------------
--  DDL for Package Body INV_INVIRXRF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVIRXRF_XMLP_PKG" AS
/* $Header: INVIRXRFB.pls 120.1 2007/12/25 10:36:51 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    IF P_REPORT_TYPE = '1' THEN
      /*SRW.SET_MAXROW('Q_XREF_BY_ITEM'
                    ,0)*/NULL;
    ELSE
      /*SRW.SET_MAXROW('Q_ITEM_BY_XREF'
                    ,0)*/NULL;
    END IF;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Srwinit failed in before report trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(2
                   ,'Item Flex Select failed in before report trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(2
                   ,'Item flex select sort failed in before report trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(13
                   ,'CATG Flex Select Failed in before report trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(8
                   ,'CATG2 FLEX WHERE FAILED IN BEFORE REPORT TRIGGER')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(4
                   ,'Item Flex Where failed in before report trigger')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION C_XREF_TYPE_MARG_FORMULAFORMUL RETURN VARCHAR2 IS
  BEGIN
    RETURN ('Cross Reference Type:  ' || P_XREF_TYPE);
  END C_XREF_TYPE_MARG_FORMULAFORMUL;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_ORG_INDPFORMULA(ORG_INDP IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(ORG_INDP)*/NULL;
    IF ORG_INDP = 'Y' THEN
      RETURN ('Yes');
    ELSE
      RETURN ('No');
    END IF;
    RETURN NULL;
  END C_ORG_INDPFORMULA;

  FUNCTION C_ORG_INDP1FORMULA(ORG_INDP1 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(ORG_INDP1)*/NULL;
    IF ORG_INDP1 = 'Y' THEN
      RETURN ('Yes');
    ELSE
      RETURN ('No');
    END IF;
    RETURN NULL;
  END C_ORG_INDP1FORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

END INV_INVIRXRF_XMLP_PKG;


/
