--------------------------------------------------------
--  DDL for Package Body INV_INVPRFDH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVPRFDH_XMLP_PKG" AS
/* $Header: INVPRFDHB.pls 120.1 2007/12/25 10:46:50 dwkrishn noship $ */
  /* $Header: INVPRFDHB.pls 120.1 2007/12/25 10:46:50 dwkrishn noship $ */
  FUNCTION WHERE_CAT(P_CAT_WHERE varchar2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      CAT_SET VARCHAR2(15);
      CAT_WHERE VARCHAR2(960);
      ORG VARCHAR2(15);
    BEGIN
      CAT_SET := P_CAT_SET;
      CAT_WHERE := P_CAT_WHERE;
      ORG := P_ORG;
      IF P_CAT_SET IS NOT NULL THEN
        RETURN (' and mdh.INVENTORY_ITEM_ID  in
	(select  MIC.INVENTORY_ITEM_ID from MTL_ITEM_CATEGORIES  MIC, MTL_CATEGORIES MC
	where  MIC.CATEGORY_SET_ID =''' || CAT_SET || ''' and ' || CAT_WHERE || '
	and MIC.organization_id = ''' || ORG || ''' and MC.CATEGORY_ID =MIC.CATEGORY_ID)');
      ELSE
        RETURN ('  ');
      END IF;
    END;
    RETURN NULL;
  END WHERE_CAT;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
    LP_START_DATE:=to_char(P_START_DATE,'DD-MON-YY');
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
        /*SRW.MESSAGE(3
                   ,'Item Flex ORDER failed in before report trigger')*/NULL;
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
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(6
                   ,'Catg Flex Where failed in before report trigger')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_ITEM_LO_NICEFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_ITEM_LO = ':' THEN
        RETURN ('  ');
      ELSE
        RETURN (P_ITEM_LO);
      END IF;
    END;
    RETURN NULL;
  END C_ITEM_LO_NICEFORMULA;

  FUNCTION C_ITEM_HI_NICEFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_ITEM_HI = ':' THEN
        RETURN ('  ');
      ELSE
        RETURN (P_ITEM_HI);
      END IF;
    END;
    RETURN NULL;
  END C_ITEM_HI_NICEFORMULA;

  FUNCTION C_CAT_LO_NICEFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_CAT_LO = '-' THEN
        RETURN ('  ');
      ELSE
        RETURN (P_CAT_LO);
      END IF;
    END;
    RETURN NULL;
  END C_CAT_LO_NICEFORMULA;

  FUNCTION C_CAT_HI_NICEFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_CAT_HI = '-' THEN
        RETURN ('  ');
      ELSE
        RETURN (P_CAT_HI);
      END IF;
    END;
    RETURN NULL;
  END C_CAT_HI_NICEFORMULA;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION F_TOTALFORMULA(SALES_ORDERS IN NUMBER
                         ,INTERORG_ISSUES IN NUMBER
                         ,WIP_ISSUES IN NUMBER
                         ,MISCELLANEOUS_ISSUES IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      RETURN (SALES_ORDERS + INTERORG_ISSUES + WIP_ISSUES + MISCELLANEOUS_ISSUES);
    END;
    RETURN NULL;
  END F_TOTALFORMULA;

END INV_INVPRFDH_XMLP_PKG;



/
