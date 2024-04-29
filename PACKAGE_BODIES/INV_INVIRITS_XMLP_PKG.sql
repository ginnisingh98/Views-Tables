--------------------------------------------------------
--  DDL for Package Body INV_INVIRITS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVIRITS_XMLP_PKG" AS
/* $Header: INVIRITSB.pls 120.1 2007/12/25 10:28:17 dwkrishn noship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in SRWEXIT')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;
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
      IF P_CATG_HI IS NOT NULL OR P_CATG_LO IS NOT NULL THEN
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
      IF P_ICG_LO IS NOT NULL OR P_ICG_HI IS NOT NULL THEN
        NULL;
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(3
                   ,'Failed Flexsql MICG Where in before rpt trig')*/NULL;
        RAISE;
    END;
    BEGIN
      IF P_SORT_ID = 2 THEN
        BEGIN
          NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(3
                       ,'Failed Flexsql MCAT Select in before rpt trig')*/NULL;
            RAISE;
        END;
      ELSE
        P_CATG_FLEXDATA := '''MCAT''';
      END IF;
      IF P_SORT_ID = 3 THEN
        BEGIN
          NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(2
                       ,'Failed Flexsql MICG Select in before rpt trig')*/NULL;
            RAISE;
        END;
      ELSE
        P_ICG_FLEXDATA := '''ICG''';
      END IF;
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
    BEGIN
      IF P_CURRENCY_CODE IS NULL THEN
        SELECT
          CURRENCY_CODE
        INTO P_CURRENCY_CODE1
        FROM
          GL_SETS_OF_BOOKS GSOB,
          ORG_ORGANIZATION_DEFINITIONS OOD
        WHERE GSOB.SET_OF_BOOKS_ID = OOD.SET_OF_BOOKS_ID
          AND OOD.ORGANIZATION_ID = P_ORG;
        P_EXCHANGE_RATE := 1;
      END IF;
   IF P_CURRENCY_CODE IS not  NULL THEN
P_CURRENCY_CODE1:=P_CURRENCY_CODE;
end if;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(9
                   ,'Failed defaulting currency code')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION C_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_ID = 2 THEN
      RETURN (', mtl_item_categories mic,
                         mtl_categories mcat');
    ELSE
      IF P_SORT_ID = 3 THEN
        IF P_CATG_SET_ID IS NOT NULL THEN
          RETURN (', mtl_item_catalog_groups icg,
                 	     mtl_item_categories mic');
        ELSE
          RETURN (', mtl_item_catalog_groups icg');
        END IF;
      ELSE
        IF P_SORT_ID = 1 THEN
          RETURN (', mtl_item_categories mic');
        ELSE
          RETURN ('/* Do not return mcat or icg tables */');
        END IF;
      END IF;
    END IF;
    RETURN (' ');
  END C_FROMFORMULA;
  FUNCTION C_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_ID = 2 THEN
      RETURN ('and msi.inventory_item_id = mic.inventory_item_id
                     and mic.organization_id = msi.organization_id
                and mic.category_set_id = ' || TO_CHAR(P_CATG_SET_ID) || '
                     and mic.category_id = mcat.category_id');
    ELSE
      IF P_SORT_ID = 3 THEN
        IF P_CATG_SET_ID IS NOT NULL THEN
          RETURN ('and msi.item_catalog_group_id =
                             icg.item_catalog_group_id(+)
                 	and msi.inventory_item_id = mic.inventory_item_id
                 	and msi.organization_id = mic.organization_id
                    and mic.category_set_id=' || TO_CHAR(P_CATG_SET_ID) || '');
        ELSE
          RETURN ('and msi.item_catalog_group_id =
                             icg.item_catalog_group_id(+)');
        END IF;
      ELSE
        IF P_SORT_ID = 1 THEN
          RETURN ('and msi.inventory_item_id = mic.inventory_item_id
                          and msi.organization_id = mic.organization_id
                    and mic.category_set_id=' || TO_CHAR(P_CATG_SET_ID) || ' ');
        ELSE
          RETURN (' ');
        END IF;
      END IF;
    END IF;
    RETURN (' ');
  END C_WHEREFORMULA;
  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;
  FUNCTION C_CAT_SET_NAMEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      NAME VARCHAR2(30);
      SET_ID NUMBER;
    BEGIN
      IF P_CATG_SET_ID IS NULL THEN
        RETURN (NULL);
      ELSE
        SET_ID := P_CATG_SET_ID;
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
        RETURN (NULL);
    END;
    RETURN NULL;
  END C_CAT_SET_NAMEFORMULA;
  FUNCTION C_BREAK_OPTION_PADFORMULA(C_BREAK_OPTION_PAD IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_BREAK_OPTION_PAD);
  END C_BREAK_OPTION_PADFORMULA;
  FUNCTION C_CURRENCY_CODEFORMULA(R_CURRENCY_CODE IN VARCHAR2
                                 ,EXT_PRECISION_SAVED IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF P_EXCHANGE_RATE <> 1 THEN
      RETURN ('(' || R_CURRENCY_CODE || ' @ ' || TO_CHAR(ROUND(P_EXCHANGE_RATE
                          ,NVL(EXT_PRECISION_SAVED
                             ,0))) || ')');
    ELSE
      RETURN ('(' || R_CURRENCY_CODE || ')');
    END IF;
  END C_CURRENCY_CODEFORMULA;
  FUNCTION C_CATG_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_ID = 1 OR P_SORT_ID = 3 THEN
      IF P_CATG_HI IS NOT NULL OR P_CATG_LO IS NOT NULL THEN
        RETURN (', mtl_categories mcat');
      ELSE
      RETURN (', mtl_categories mcat');
      END IF;
    END IF;
    RETURN (' ');
  END C_CATG_FROMFORMULA;
  FUNCTION C_CATG_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_ID = 1 OR P_SORT_ID = 3 THEN
      IF P_CATG_HI IS NOT NULL OR P_CATG_LO IS NOT NULL THEN
        RETURN (' and mic.category_set_id =
               		' || TO_CHAR(P_CATG_SET_ID) || '
                          and mic.category_id = mcat.category_id');
      ELSE
        RETURN (' ');
      END IF;
    END IF;
    RETURN (' ');
  END C_CATG_WHEREFORMULA;
  FUNCTION C_ICG_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_ID = 1 OR P_SORT_ID = 2 THEN
      IF P_ICG_HI IS NOT NULL OR P_ICG_LO IS NOT NULL THEN
        RETURN (', mtl_item_catalog_groups icg');
      ELSE
        RETURN (', mtl_item_catalog_groups icg');
      END IF;
    END IF;
    RETURN (' ');
  END C_ICG_FROMFORMULA;
  FUNCTION C_ICG_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_ID = 1 OR P_SORT_ID = 2 THEN
      IF P_ICG_HI IS NOT NULL OR P_ICG_LO IS NOT NULL THEN
        RETURN (' and icg.item_catalog_group_id(+)=
               	msi.item_catalog_group_id');
      ELSE
        RETURN (' ');
      END IF;
    END IF;
    RETURN (' ');
  END C_ICG_WHEREFORMULA;
  FUNCTION C_ICG_DESCFORMULA(ITEM_ID IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      AA VARCHAR2(240);
      PROFILE_VAL VARCHAR2(240);
    BEGIN
      AA := NULL;
      PROFILE_VAL := NULL;
      IF (P_DESC_OPTION = 2) THEN
        FND_PROFILE.GET('USE_NAME_ICG_DESC'
                       ,PROFILE_VAL);
        IF (PROFILE_VAL = 'Y' OR (PROFILE_VAL IS NULL)) THEN
          AA := INVICGDS.INV_FN_GET_ICG_DESC(ITEM_ID
                                            ,30
                                            ,'Y'
                                            ,P_SEPARATOR
                                            ,'Y'
                                            ,'Y');
        ELSE
          AA := INVICGDS.INV_FN_GET_ICG_DESC(ITEM_ID
                                            ,30
                                            ,'N'
                                            ,P_SEPARATOR
                                            ,'Y'
                                            ,'Y');
        END IF;
      END IF;
      RETURN (AA);
    END;
    RETURN NULL;
  END C_ICG_DESCFORMULA;
  FUNCTION C_break_option_pad_F(C_break_option_pad in varchar2) RETURN VARCHAR2 IS
  begin
  if P_sort_id=2 then
  return(C_break_option_pad);
  else
  return(NULL);
  end if;
  RETURN NULL;
  end  C_break_option_pad_F;
  FUNCTION C_break_option_value_F(C_break_option_value in varchar2) RETURN VARCHAR2 IS
  begin
  if P_sort_id=3 then
  return(C_break_option_value);
  else
  return(NULL);
  end if;
  RETURN NULL;
  end  C_break_option_value_F;
END INV_INVIRITS_XMLP_PKG;


/
