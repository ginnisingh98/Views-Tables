--------------------------------------------------------
--  DDL for Package Body ONT_OEXOHHSA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXOHHSA_XMLP_PKG" AS
/* $Header: OEXOHHSAB.pls 120.1 2007/12/25 07:29:20 npannamp noship $ */
  FUNCTION SOB_NAMEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      SOB_NAME VARCHAR2(30);
    BEGIN
      SELECT
        NAME
      INTO SOB_NAME
      FROM
        GL_SETS_OF_BOOKS
      WHERE SET_OF_BOOKS_ID = P_SOB_ID;
      RETURN (SOB_NAME);
    END;
    RETURN NULL;
  END SOB_NAMEFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    --ADDED AS FIX
    P_ACTIVITY_DATE_LO_V:=TO_CHAR(P_ACTIVITY_DATE_LO,'DD-MON-YY');
    P_ACTIVITY_DATE_HI_V:=TO_CHAR(P_ACTIVITY_DATE_HI,'DD-MON-YY');
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  EXCEPTION
    WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
      BEGIN
        /*SRW.MESSAGE(1
                   ,'FAILED IN BEFORE REPORT TRIGGER')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
        RETURN (FALSE);
      END;
      BEGIN
        --P_ORGANIZATION_ID := MO_GLOBAL.GET_CURRENT_ORG_ID;
        P_ORGANIZATION_ID_V := MO_GLOBAL.GET_CURRENT_ORG_ID;
      END;
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  EXCEPTION
    WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
      /*SRW.MESSAGE(1
                 ,'FAILED IN AFTER REPORT TRIGGER')*/NULL;
      RETURN (FALSE);
  END AFTERREPORT;

  FUNCTION C_ACTIVITY_MEANINGFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ACTIVITY_MEANING VARCHAR2(80);
    BEGIN
      SELECT
        MEANING
      INTO ACTIVITY_MEANING
      FROM
        OE_LOOKUPS
      WHERE LOOKUP_TYPE = 'AUTHORIZED_ACTION'
        AND LOOKUP_CODE = P_ACTIVITY;
      RETURN (ACTIVITY_MEANING);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('');
    END;
    RETURN NULL;
  END C_ACTIVITY_MEANINGFORMULA;

  FUNCTION C_HOLD_TYPE_WHERE RETURN VARCHAR2 IS
  BEGIN
    IF P_HOLD_TYPE_LO IS NOT NULL AND P_HOLD_TYPE_HI IS NOT NULL THEN
      RETURN ('and ht.lookup_code between ''' || P_HOLD_TYPE_LO || '''
                           and ''' || P_HOLD_TYPE_HI || ''' ');
    ELSE
      IF P_HOLD_TYPE_LO IS NULL AND P_HOLD_TYPE_HI IS NOT NULL THEN
        RETURN ('and ht.lookup_code <= ''' || P_HOLD_TYPE_HI || ''' ');
      ELSE
        IF P_HOLD_TYPE_LO IS NOT NULL AND P_HOLD_TYPE_HI IS NULL THEN
          RETURN ('and ht.lookup_code >= ''' || P_HOLD_TYPE_LO || ''' ');
        ELSE
          RETURN (NULL);
        END IF;
      END IF;
    END IF;
    RETURN NULL;
  END C_HOLD_TYPE_WHERE;

  FUNCTION C_HOLD_NAME_WHERE RETURN VARCHAR2 IS
  BEGIN
    IF P_HOLD_NAME_LO IS NOT NULL AND P_HOLD_NAME_HI IS NOT NULL THEN
      RETURN ('and h.name between ''' || P_HOLD_NAME_LO || ''' and
                            ''' || P_HOLD_NAME_HI || ''' ');
    ELSE
      IF P_HOLD_NAME_LO IS NULL AND P_HOLD_NAME_HI IS NOT NULL THEN
        RETURN ('and h.name <= ''' || P_HOLD_NAME_HI || ''' ');
      ELSE
        IF P_HOLD_NAME_LO IS NOT NULL AND P_HOLD_NAME_HI IS NULL THEN
          RETURN ('and h.name >= ''' || P_HOLD_NAME_LO || ''' ');
        ELSE
          RETURN (NULL);
        END IF;
      END IF;
    END IF;
    RETURN NULL;
  END C_HOLD_NAME_WHERE;

  FUNCTION C_ENTITY_VALUE(OBJECT_TYPE_CODE IN VARCHAR2
                         ,OBJECT_ID IN NUMBER) RETURN VARCHAR2 IS
    L_ENTITY_VALUE VARCHAR2(500);
  BEGIN
    IF OBJECT_TYPE_CODE = 'O' THEN
      SELECT
        ORDER_NUMBER
      INTO L_ENTITY_VALUE
      FROM
        OE_ORDER_HEADERS
      WHERE HEADER_ID = OBJECT_ID;
    ELSE
      IF OBJECT_TYPE_CODE = 'C' THEN
        SELECT
          SUBSTRB(PARTY.PARTY_NAME
                 ,1
                 ,50)
        INTO L_ENTITY_VALUE
        FROM
          HZ_PARTIES PARTY,
          HZ_CUST_ACCOUNTS CUST_ACCT
        WHERE CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
          AND CUST_ACCT.CUST_ACCOUNT_ID = OBJECT_ID;
      ELSE
        IF OBJECT_TYPE_CODE = 'I' THEN
          SELECT
            DESCRIPTION
          INTO L_ENTITY_VALUE
          FROM
            MTL_SYSTEM_ITEMS_VL
          WHERE INVENTORY_ITEM_ID = OBJECT_ID
            AND NVL(ORGANIZATION_ID
             ,0) = NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID'
                                     ,MO_GLOBAL.GET_CURRENT_ORG_ID)
             ,0);
        ELSE
          IF OBJECT_TYPE_CODE = 'S' THEN
            SELECT
              SUBSTR((LOC.ADDRESS1 || ', ' || LOC.CITY || ' ' || LOC.STATE)
                    ,1
                    ,30)
            INTO L_ENTITY_VALUE
            FROM
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE SU.SITE_USE_ID = OBJECT_ID
              AND SU.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
              AND SU.ORG_ID = MO_GLOBAL.GET_CURRENT_ORG_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99);
          ELSE
            L_ENTITY_VALUE := OBJECT_ID;
          END IF;
        END IF;
      END IF;
    END IF;
    RETURN (L_ENTITY_VALUE);
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN ('Can not retrieve Value');
  END C_ENTITY_VALUE;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF P_ACTIVITY_DATE_LO IS NOT NULL AND P_ACTIVITY_DATE_HI IS NOT NULL THEN
        IF P_ACTIVITY = 'REMOVE' THEN
          LP_ACTIVITY_DATE_WHERE := 'and trunc(hr1.creation_date) between trunc(:P_activity_date_lo) and trunc(:P_activity_date_hi)';
        ELSE
          IF P_ACTIVITY = 'APPLY' THEN
            LP_ACTIVITY_DATE_WHERE := 'and trunc(hs.creation_date) between trunc(:P_activity_date_lo) and trunc(:P_activity_date_hi)';
          ELSE
            LP_ACTIVITY_DATE_WHERE := 'and (trunc(hs.creation_date) between trunc(:P_activity_date_lo) and trunc(:P_activity_date_hi) OR trunc(hr1.creation_date) between trunc(:P_activity_date_lo) and trunc(:P_activity_date_hi)) ';
          END IF;
        END IF;
      ELSE
        IF P_ACTIVITY_DATE_LO IS NULL AND P_ACTIVITY_DATE_HI IS NOT NULL THEN
          IF P_ACTIVITY = 'REMOVE' THEN
            LP_ACTIVITY_DATE_WHERE := 'and trunc(hr1.creation_date) <= trunc(:P_activity_date_hi)';
          ELSE
            IF P_ACTIVITY = 'APPLY' THEN
              LP_ACTIVITY_DATE_WHERE := 'and trunc(hs.creation_date) <= trunc(:P_activity_date_hi)';
            ELSE
              LP_ACTIVITY_DATE_WHERE := 'and (trunc(hs.creation_date) <= trunc(:P_activity_date_hi) OR trunc(hr1.creation_date) <= trunc(:P_activity_date_hi)) ';
            END IF;
          END IF;
        ELSE
          IF P_ACTIVITY_DATE_LO IS NOT NULL AND P_ACTIVITY_DATE_HI IS NULL THEN
            IF P_ACTIVITY = 'REMOVE' THEN
              LP_ACTIVITY_DATE_WHERE := 'and trunc(hr1.creation_date) >= trunc(:P_activity_date_lo)';
            ELSE
              IF P_ACTIVITY = 'APPLY' THEN
                LP_ACTIVITY_DATE_WHERE := 'and trunc(hs.creation_date) >= trunc(:P_activity_date_lo)';
              ELSE
                LP_ACTIVITY_DATE_WHERE := 'and (trunc(hs.creation_date) >= trunc(:P_activity_date_lo) OR trunc(hr1.creation_date) >= trunc(:P_activity_date_lo)) ';
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
      IF P_ACTIVITY = 'REMOVE' THEN
        LP_ACTIVITY_TYPE_WHERE := 'and hs.released_flag = ''Y''';
      END IF;
      IF P_HOLD_NAME_LO IS NOT NULL AND P_HOLD_NAME_HI IS NOT NULL THEN
        LP_HOLD_WHERE := 'and h.name between :P_hold_name_lo and :P_hold_name_hi';
      ELSIF P_HOLD_NAME_LO IS NULL AND P_HOLD_NAME_HI IS NOT NULL THEN
        LP_HOLD_WHERE := 'and h.name <= :P_hold_name_hi';
      ELSIF P_HOLD_NAME_LO IS NOT NULL AND P_HOLD_NAME_HI IS NULL THEN
        LP_HOLD_WHERE := 'and h.name >= :P_hold_name_lo';
      ELSE
        --LP_HOLD_WHERE := NULL;
        LP_HOLD_WHERE := ' ';
      END IF;
      BEGIN
        IF (P_HOLD_TYPE_LO IS NOT NULL AND P_HOLD_TYPE_HI IS NOT NULL) THEN
          LP_HOLD_TYPE_WHERE := 'and ht.lookup_code between :P_hold_type_lo and :P_hold_type_hi ';
        ELSE
          IF (P_HOLD_TYPE_LO IS NULL AND P_HOLD_TYPE_HI IS NOT NULL) THEN
            LP_HOLD_TYPE_WHERE := 'and ht.lookup_code <= :P_hold_type_hi ';
          ELSE
            IF (P_HOLD_TYPE_LO IS NOT NULL AND P_HOLD_TYPE_HI IS NULL) THEN
              LP_HOLD_TYPE_WHERE := 'and ht.lookup_code >= :P_hold_type_lo ';
            ELSE
              --LP_HOLD_TYPE_WHERE := NULL;
              LP_HOLD_TYPE_WHERE := ' ';
            END IF;
          END IF;
        END IF;
      END;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_ENTITY_VALUE2(OBJECT_TYPE_CODE2 IN VARCHAR2
                          ,OBJECT_ID2 IN NUMBER) RETURN VARCHAR2 IS
    L_ENTITY_VALUE VARCHAR2(500);
  BEGIN
    IF OBJECT_TYPE_CODE2 = 'O' THEN
      SELECT
        ORDER_NUMBER
      INTO L_ENTITY_VALUE
      FROM
        OE_ORDER_HEADERS
      WHERE HEADER_ID = OBJECT_ID2;
    ELSE
      IF OBJECT_TYPE_CODE2 = 'C' THEN
        SELECT
          SUBSTRB(PARTY.PARTY_NAME
                 ,1
                 ,50)
        INTO L_ENTITY_VALUE
        FROM
          HZ_PARTIES PARTY,
          HZ_CUST_ACCOUNTS CUST_ACCT
        WHERE CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
          AND CUST_ACCT.CUST_ACCOUNT_ID = OBJECT_ID2;
      ELSE
        IF OBJECT_TYPE_CODE2 = 'I' THEN
          SELECT
            DESCRIPTION
          INTO L_ENTITY_VALUE
          FROM
            MTL_SYSTEM_ITEMS_VL
          WHERE INVENTORY_ITEM_ID = OBJECT_ID2
            AND NVL(ORGANIZATION_ID
             ,0) = NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID'
                                     ,MO_GLOBAL.GET_CURRENT_ORG_ID)
             ,0);
        ELSE
          IF OBJECT_TYPE_CODE2 = 'S' THEN
            SELECT
              SUBSTR((LOC.ADDRESS1 || ', ' || LOC.CITY || ' ' || LOC.STATE)
                    ,1
                    ,30)
            INTO L_ENTITY_VALUE
            FROM
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE SU.SITE_USE_ID = OBJECT_ID2
              AND SU.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
              AND SU.ORG_ID = MO_GLOBAL.GET_CURRENT_ORG_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99);
          ELSE
            L_ENTITY_VALUE := OBJECT_ID2;
          END IF;
        END IF;
      END IF;
    END IF;
    RETURN (L_ENTITY_VALUE);
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN ('Can not retrieve Value');
  END C_ENTITY_VALUE2;

END ONT_OEXOHHSA_XMLP_PKG;



/
