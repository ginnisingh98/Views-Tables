--------------------------------------------------------
--  DDL for Package Body INV_INVIRSLO_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVIRSLO_XMLP_PKG" AS
/* $Header: INVIRSLOB.pls 120.2 2008/01/08 06:17:53 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
       C_DATE_FORMAT varchar2(20);
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
            C_DATE_FORMAT := 'DD-MON-YY';
        CP_CUTOFF_DATE := to_char(P_CUTOFF_DATE,C_DATE_FORMAT);
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in before report trigger:SRWINIT')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in before report trigger:MSTK')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in before report trigger:MCAT')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'SRWEXIT failed')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_CAT_SET_NAMEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      CAT_SET_ID VARCHAR2(40);
      CAT_SET_NAME VARCHAR2(30);
    BEGIN
      CAT_SET_ID := P_CAT_SET_ID;
      SELECT
        CATEGORY_SET_NAME
      INTO CAT_SET_NAME
      FROM
        MTL_CATEGORY_SETS
      WHERE CATEGORY_SET_ID = CAT_SET_ID;
      RETURN (CAT_SET_NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        /*SRW.MESSAGE(10
                   ,'No category set selected')*/NULL;
    END;
    RETURN NULL;
  END C_CAT_SET_NAMEFORMULA;

  FUNCTION C_SUBINV_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SUBINV_LO IS NOT NULL AND P_SUBINV_HI IS NOT NULL THEN
      RETURN ('and mmt.subinventory_code between ''' || P_SUBINV_LO || ''' and
                        ''' || P_SUBINV_HI || '''');
    ELSE
      IF P_SUBINV_LO IS NOT NULL AND P_SUBINV_HI IS NULL THEN
        RETURN ('and mmt.subinventory_code >= ''' || P_SUBINV_LO || '''');
      ELSE
        IF P_SUBINV_LO IS NULL AND P_SUBINV_HI IS NOT NULL THEN
          RETURN ('and mmt.subinventory_code <= ''' || P_SUBINV_HI || '''');
        ELSE
          RETURN (' ');
        END IF;
      END IF;
    END IF;
    RETURN (' ');
  END C_SUBINV_WHEREFORMULA;

  FUNCTION C_ITEM_PADFORMULA(C_ITEM_PAD IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_ITEM_PAD);
  END C_ITEM_PADFORMULA;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    BEGIN
      SELECT
        STRUCTURE_ID
      INTO P_CAT_STRUCT_NUM
      FROM
        MTL_CATEGORY_SETS
      WHERE CATEGORY_SET_ID = P_CAT_SET_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        /*SRW.MESSAGE(1
                   ,'Failed in before form trigger: Invalid category set id.')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
  END BEFOREPFORM;

END INV_INVIRSLO_XMLP_PKG;


/
