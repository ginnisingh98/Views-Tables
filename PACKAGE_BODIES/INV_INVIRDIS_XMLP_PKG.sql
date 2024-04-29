--------------------------------------------------------
--  DDL for Package Body INV_INVIRDIS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVIRDIS_XMLP_PKG" AS
/* $Header: INVIRDISB.pls 120.1 2007/12/25 10:22:50 dwkrishn noship $ */
  FUNCTION WHERE_STAT_EFF RETURN VARCHAR2 IS
  BEGIN
    IF P_STAT_EFF IS NOT NULL THEN
      RETURN ('and to_date(to_char(mpis.EFFECTIVE_DATE,''DD-MON-RR''), ''DD-MON-RR'') >= ''' || TO_CHAR(P_STAT_EFF) || ''' ');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END WHERE_STAT_EFF;

  FUNCTION WHERE_STATUS RETURN VARCHAR2 IS
  BEGIN
    IF P_STATUS IS NOT NULL THEN
      RETURN ('and MPIS.STATUS_CODE = ''' || P_STATUS || ''' ');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END WHERE_STATUS;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed srwinit in before rpt trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      IF P_BREAK_ID = 1 OR P_BREAK_ID = 2 THEN
        NULL;
      ELSE
        P_CAT_FLEX := '''MC''';
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(2
                   ,'Failed Flexsql MCAT select in before rpt trig')*/NULL;
        RAISE;
    END;
    BEGIN
      IF P_CAT_LO IS NOT NULL OR P_CAT_HI IS NOT NULL THEN
        NULL;
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(3
                   ,'Failed Flexsql MCAT Where in before rpt trig')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(6
                   ,'Failed Flexsql Item Select in before rpt trig')*/NULL;
        RAISE;
    END;
    BEGIN
      IF P_ITEM_LO IS NOT NULL OR P_ITEM_HI IS NOT NULL THEN
        NULL;
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(7
                   ,'Failed Flexsql MSTK Where in before rpt trig')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(8
                   ,'Failed Flexsql Item Order by in before rpt trig')*/NULL;
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

  FUNCTION C_CAT_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_BREAK_ID = 1 OR (P_CAT_LO IS NOT NULL OR P_CAT_HI IS NOT NULL) OR (P_CAT_SET_ID IS NOT NULL AND P_CAT_LO IS NULL AND P_CAT_HI IS NULL) THEN
      RETURN (',mtl_item_categories mic, mtl_categories mc');
    ELSE
      RETURN ('/* Do not select mic or mc */');
    END IF;
    RETURN NULL;
  END C_CAT_FROMFORMULA;

  FUNCTION C_CAT_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_BREAK_ID = 1 OR (P_CAT_LO IS NOT NULL OR P_CAT_HI IS NOT NULL) OR P_BREAK_ID = 2 THEN
      RETURN ('and msi.inventory_item_id = mic.inventory_item_id
                     and mic.category_id = mc.category_id
                     and mic.category_set_id = ' || TO_CHAR(P_CAT_SET_ID) || '
                     and mic.organization_id = ' || TO_CHAR(P_ORG_ID));
    ELSE
      RETURN ('');
    END IF;
    RETURN NULL;
  END C_CAT_WHEREFORMULA;

  FUNCTION C_CAT_PADFORMULA(C_CAT_FIELD IN VARCHAR2
                           ,C_CAT_PAD IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(C_CAT_FIELD)*/NULL;
    RETURN (C_CAT_PAD);
  END C_CAT_PADFORMULA;

  FUNCTION C_CAT_SET_NAMEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      NAME VARCHAR2(30);
      SET_ID NUMBER;
    BEGIN
      IF P_CAT_SET_ID IS NULL THEN
        RETURN ('');
      ELSE
        SET_ID := P_CAT_SET_ID;
        SELECT
          CATEGORY_SET_NAME
        INTO NAME
        FROM
          MTL_CATEGORY_SETS
        WHERE CATEGORY_SET_ID = SET_ID;
        RETURN (NAME);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('');
    END;
    RETURN NULL;
  END C_CAT_SET_NAMEFORMULA;

  FUNCTION C_ITEM_PADFORMULA(C_ITEM_FIELD IN VARCHAR2
                            ,C_ITEM_PAD IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(C_ITEM_FIELD)*/NULL;
    RETURN (C_ITEM_PAD);
  END C_ITEM_PADFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_MORG_IDFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      T_STATUS INTEGER;
      T_MORG_ID INTEGER;
    BEGIN
      SELECT
        CONTROL_LEVEL
      INTO T_STATUS
      FROM
        MTL_ITEM_ATTRIBUTES
      WHERE ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE';
      IF (T_STATUS = 1) THEN
        BEGIN
          SELECT
            MASTER_ORGANIZATION_ID
          INTO T_MORG_ID
          FROM
            MTL_PARAMETERS P
          WHERE P.ORGANIZATION_ID = P_ORG_ID;
          RETURN (T_MORG_ID);
        END;
      ELSE
        RETURN (P_ORG_ID);
      END IF;
    END;
    RETURN NULL;
  END C_MORG_IDFORMULA;

END INV_INVIRDIS_XMLP_PKG;


/
