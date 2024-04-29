--------------------------------------------------------
--  DDL for Package Body RLM_RLMDMSIQ_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_RLMDMSIQ_XMLP_PKG" AS
/* $Header: RLMDMSIQB.pls 120.0 2008/01/25 09:37:40 krreddy noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_CURRENT_ORG_ID NUMBER;
    L_OU_NAME VARCHAR2(240);
    L_SHIP_TO VARCHAR2(30);
    L_STATUS VARCHAR2(1);
    CURSOR CUR_P_SHIP_TO(NU_SHIP_TO IN NUMBER) IS
      SELECT
        ACCT_SITE.ECE_TP_LOCATION_CODE
      FROM
        HZ_CUST_SITE_USES_ALL CUST_SITE,
        HZ_CUST_ACCT_SITES ACCT_SITE
      WHERE CUST_SITE.SITE_USE_CODE = L_SHIP_TO
        AND ACCT_SITE.STATUS = L_STATUS
        AND CUST_SITE.SITE_USE_ID = NU_SHIP_TO
        AND ACCT_SITE.CUST_ACCT_SITE_ID = CUST_SITE.CUST_ACCT_SITE_ID
        AND CUST_SITE.ORG_ID = ACCT_SITE.ORG_ID;
    CURSOR CUR_CUST_NAME(V_CUSTOMER_ID IN NUMBER) IS
      SELECT
        PARTY.PARTY_NAME
      FROM
        HZ_PARTIES PARTY,
        HZ_CUST_ACCOUNTS CUST_ACCT
      WHERE PARTY.PARTY_ID = CUST_ACCT.PARTY_ID
        AND CUST_ACCT.CUST_ACCOUNT_ID = V_CUSTOMER_ID;
    CURSOR CUR_SHIP_FROM(V_SHIP_FROM IN NUMBER) IS
      SELECT
        ORGANIZATION_CODE
      FROM
        ORG_ORGANIZATION_DEFINITIONS
      WHERE ORGANIZATION_ID = V_SHIP_FROM;
  BEGIN
    L_SHIP_TO := 'SHIP_TO';
    L_STATUS := 'A';
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1000
                   ,'Failed in BEFORE REPORT trigger')*/NULL;
        RETURN (FALSE);
    END;
    L_CURRENT_ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID;
    IF (L_CURRENT_ORG_ID IS NULL AND P_ORG_ID IS NOT NULL) THEN
      MO_GLOBAL.SET_POLICY_CONTEXT(P_ACCESS_MODE => 'S'
                                  ,P_ORG_ID => P_ORG_ID);
      L_CURRENT_ORG_ID := P_ORG_ID;
    END IF;
    L_OU_NAME := FND_ACCESS_CONTROL_UTIL.GET_ORG_NAME(L_CURRENT_ORG_ID);
    CP_DEFAULT_OU := L_OU_NAME;
    IF (P_SHIP_FROM_ORG_ID IS NOT NULL) THEN
      OPEN CUR_SHIP_FROM(P_SHIP_FROM_ORG_ID);
      FETCH CUR_SHIP_FROM
       INTO CP_P_SHIP_FROM;
      CLOSE CUR_SHIP_FROM;
    END IF;
    IF (P_CUSTOMER_ID IS NOT NULL) THEN
      OPEN CUR_CUST_NAME(P_CUSTOMER_ID);
      FETCH CUR_CUST_NAME
       INTO CP_P_CUSTOMER_NAME;
      CLOSE CUR_CUST_NAME;
    END IF;
    IF (P_SHIP_TO_ORG_ID IS NOT NULL) THEN
      OPEN CUR_P_SHIP_TO(P_SHIP_TO_ORG_ID);
      FETCH CUR_P_SHIP_TO
       INTO CP_P_SHIP_TO;
      CLOSE CUR_P_SHIP_TO;
    END IF;
    IF (P_DELIVER_TO_ORG_ID IS NOT NULL) THEN
      OPEN CUR_P_SHIP_TO(P_DELIVER_TO_ORG_ID);
      FETCH CUR_P_SHIP_TO
       INTO CP_P_DELIVER_TO;
      CLOSE CUR_P_SHIP_TO;
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CUSTOMER_NUMBERFORMULA(SOLD_TO_ORG_ID IN NUMBER) RETURN CHAR IS
    V_CUST_NUMBER VARCHAR2(30);
  BEGIN
    SELECT
      CUST_ACCT.ACCOUNT_NUMBER
    INTO V_CUST_NUMBER
    FROM
      HZ_CUST_ACCOUNTS CUST_ACCT
    WHERE CUST_ACCT.CUST_ACCOUNT_ID = SOLD_TO_ORG_ID;
    RETURN (V_CUST_NUMBER);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END CUSTOMER_NUMBERFORMULA;

  FUNCTION CUSTOMER_NAMEFORMULA(SOLD_TO_ORG_ID IN NUMBER) RETURN CHAR IS
    V_CUST_NAME VARCHAR2(50);
  BEGIN
    SELECT
      SUBSTRB(PARTY.PARTY_NAME
             ,1
             ,50) CUSTOMER_NAME
    INTO V_CUST_NAME
    FROM
      HZ_CUST_ACCOUNTS CUST_ACCT,
      HZ_PARTIES PARTY
    WHERE CUST_ACCT.CUST_ACCOUNT_ID = SOLD_TO_ORG_ID
      AND CUST_ACCT.PARTY_ID = PARTY.PARTY_ID;
    RETURN (V_CUST_NAME);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('UNKNOWN');
  END CUSTOMER_NAMEFORMULA;

  FUNCTION SHIP_FROM_CODEFORMULA(SHIP_FROM_ORG_ID IN NUMBER) RETURN CHAR IS
    V_SHIP_FROM VARCHAR2(3);
  BEGIN
    SELECT
      ORGANIZATION_CODE
    INTO V_SHIP_FROM
    FROM
      ORG_ORGANIZATION_DEFINITIONS HRORGS
    WHERE SHIP_FROM_ORG_ID = HRORGS.ORGANIZATION_ID;
    RETURN (V_SHIP_FROM);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END SHIP_FROM_CODEFORMULA;

  FUNCTION SHIP_FROM_NAMEFORMULA(SHIP_FROM_ORG_ID IN NUMBER) RETURN CHAR IS
    V_SHIP_FROM ORG_ORGANIZATION_DEFINITIONS.ORGANIZATION_NAME%TYPE;
  BEGIN
    SELECT
      ORGANIZATION_NAME
    INTO V_SHIP_FROM
    FROM
      ORG_ORGANIZATION_DEFINITIONS HRORGS
    WHERE SHIP_FROM_ORG_ID = HRORGS.ORGANIZATION_ID;
    RETURN (V_SHIP_FROM);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END SHIP_FROM_NAMEFORMULA;

  FUNCTION CUSTOMER_ITEM_NUMBERFORMULA(ORDERED_ITEM_ID IN NUMBER) RETURN CHAR IS
    V_VALUE VARCHAR2(50);
  BEGIN
    SELECT
      CUSTOMER_ITEM_NUMBER
    INTO V_VALUE
    FROM
      MTL_CUSTOMER_ITEMS MCI
    WHERE ORDERED_ITEM_ID = MCI.CUSTOMER_ITEM_ID;
    RETURN (V_VALUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END CUSTOMER_ITEM_NUMBERFORMULA;

  FUNCTION CUSTOMER_ITEM_DESCFORMULA(ORDERED_ITEM_ID IN NUMBER) RETURN CHAR IS
    V_VALUE VARCHAR2(240);
  BEGIN
    SELECT
      CUSTOMER_ITEM_DESC
    INTO V_VALUE
    FROM
      MTL_CUSTOMER_ITEMS MCI
    WHERE ORDERED_ITEM_ID = MCI.CUSTOMER_ITEM_ID;
    RETURN (V_VALUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END CUSTOMER_ITEM_DESCFORMULA;

  FUNCTION CONCATENATED_SEGMENTSFORMULA(INVENTORY_ITEM_ID IN NUMBER
                                       ,SHIP_FROM_ORG_ID IN NUMBER) RETURN CHAR IS
    V_VALUE VARCHAR2(40);
  BEGIN
    SELECT
      CONCATENATED_SEGMENTS
    INTO V_VALUE
    FROM
      MTL_SYSTEM_ITEMS_KFV MSI
    WHERE CONCATENATED_SEGMENTSFORMULA.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
      AND MSI.ORGANIZATION_ID = SHIP_FROM_ORG_ID;
    RETURN (V_VALUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END CONCATENATED_SEGMENTSFORMULA;

  FUNCTION DESCRIPTIONFORMULA(INVENTORY_ITEM_ID IN NUMBER
                             ,SHIP_FROM_ORG_ID IN NUMBER) RETURN CHAR IS
    V_VALUE VARCHAR2(240);
  BEGIN
    SELECT
      DESCRIPTION
    INTO V_VALUE
    FROM
      MTL_SYSTEM_ITEMS_KFV MSI
    WHERE  MSI.INVENTORY_ITEM_ID =DESCRIPTIONFORMULA.INVENTORY_ITEM_ID
      AND MSI.ORGANIZATION_ID = SHIP_FROM_ORG_ID;
    RETURN (V_VALUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END DESCRIPTIONFORMULA;

  FUNCTION BUCKET_TYPE_CODEFORMULA(DEMAND_BUCKET_TYPE_CODE IN VARCHAR2) RETURN CHAR IS
    V_VALUE VARCHAR2(80);
  BEGIN
    SELECT
      MEANING
    INTO V_VALUE
    FROM
      FND_LOOKUPS FND
    WHERE FND.LOOKUP_TYPE = 'RLM_DETAIL_SUBTYPE_CODE'
      AND DEMAND_BUCKET_TYPE_CODE = FND.LOOKUP_CODE;
    RETURN (V_VALUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END BUCKET_TYPE_CODEFORMULA;

  FUNCTION SHIP_TO_LOCATIONFORMULA(SHIP_TO_ORG_ID3 IN NUMBER) RETURN CHAR IS
    V_VALUE VARCHAR2(40);
  BEGIN
    SELECT
      LOCATION
    INTO V_VALUE
    FROM
      HZ_CUST_SITE_USES
    WHERE SITE_USE_CODE = 'SHIP_TO'
      AND SITE_USE_ID = SHIP_TO_ORG_ID3;
    RETURN (V_VALUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END SHIP_TO_LOCATIONFORMULA;

  FUNCTION INTMED_SHIP_TO_LOCATIONFORMUL(INTMED_SHIP_TO_ORG_ID IN NUMBER) RETURN CHAR IS
    V_VALUE VARCHAR2(40);
  BEGIN
    IF INTMED_SHIP_TO_ORG_ID IS NOT NULL THEN
      SELECT
        LOCATION
      INTO V_VALUE
      FROM
        HZ_CUST_SITE_USES
      WHERE SITE_USE_CODE = 'SHIP_TO'
        AND SITE_USE_ID = INTMED_SHIP_TO_ORG_ID;
      RETURN (V_VALUE);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END INTMED_SHIP_TO_LOCATIONFORMUL;

  FUNCTION SHIP_TO_NAMEFORMULA(SHIP_TO_ORG_ID3 IN NUMBER) RETURN CHAR IS
    V_VALUE VARCHAR2(240);
  BEGIN
    IF SHIP_TO_ORG_ID3 IS NOT NULL THEN
      SELECT
        LOC.ADDRESS1
      INTO V_VALUE
      FROM
        HZ_CUST_SITE_USES_ALL CUST_SITE,
        HZ_PARTY_SITES PARTY_SITE,
        HZ_LOCATIONS LOC,
        HZ_CUST_ACCT_SITES ACCT_SITE
      WHERE CUST_SITE.SITE_USE_CODE = 'SHIP_TO'
        AND CUST_SITE.SITE_USE_ID = SHIP_TO_ORG_ID3
        AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
        AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
        AND ACCT_SITE.ORG_ID = CUST_SITE.ORG_ID
        AND ACCT_SITE.CUST_ACCT_SITE_ID = CUST_SITE.CUST_ACCT_SITE_ID;
      RETURN (V_VALUE);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END SHIP_TO_NAMEFORMULA;

  FUNCTION INTMED_SHIP_TO_NAMEFORMULA(INTMED_SHIP_TO_ORG_ID IN NUMBER) RETURN CHAR IS
    V_VALUE VARCHAR2(240);
  BEGIN
    IF (INTMED_SHIP_TO_ORG_ID IS NOT NULL) THEN
      SELECT
        LOC.ADDRESS1
      INTO V_VALUE
      FROM
        HZ_CUST_SITE_USES_ALL CUST_SITE,
        HZ_PARTY_SITES PARTY_SITE,
        HZ_LOCATIONS LOC,
        HZ_CUST_ACCT_SITES ACCT_SITE
      WHERE CUST_SITE.SITE_USE_CODE = 'SHIP_TO'
        AND CUST_SITE.SITE_USE_ID = INTMED_SHIP_TO_ORG_ID
        AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
        AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
        AND ACCT_SITE.ORG_ID = CUST_SITE.ORG_ID
        AND ACCT_SITE.CUST_ACCT_SITE_ID = CUST_SITE.CUST_ACCT_SITE_ID;
      RETURN (V_VALUE);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END INTMED_SHIP_TO_NAMEFORMULA;

  FUNCTION FCST_BUCKET_TYPE_CODEFORMULA(DEMAND_BUCKET_TYPE_CODE1 IN VARCHAR2) RETURN CHAR IS
    V_VALUE VARCHAR2(80);
  BEGIN
    SELECT
      MEANING
    INTO V_VALUE
    FROM
      FND_LOOKUPS FND
    WHERE FND.LOOKUP_TYPE = 'RLM_DETAIL_SUBTYPE_CODE'
      AND DEMAND_BUCKET_TYPE_CODE1 = FND.LOOKUP_CODE;
    RETURN (V_VALUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END FCST_BUCKET_TYPE_CODEFORMULA;

  FUNCTION CUM_START_DATEFORMULA(VEH_CUS_ITEM_CUM_KEY_ID IN NUMBER) RETURN DATE IS
    V_CUM_START DATE;
  BEGIN
    SELECT
      CUM_START_DATE
    INTO V_CUM_START
    FROM
      RLM_CUST_ITEM_CUM_KEYS CMKEYS
    WHERE VEH_CUS_ITEM_CUM_KEY_ID = CMKEYS.CUM_KEY_ID;
    RETURN (V_CUM_START);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END CUM_START_DATEFORMULA;

  FUNCTION CUM_QTYFORMULA(VEH_CUS_ITEM_CUM_KEY_ID IN NUMBER) RETURN NUMBER IS
    V_CUM_QTY NUMBER;
  BEGIN
    SELECT
      CUM_QTY
    INTO V_CUM_QTY
    FROM
      RLM_CUST_ITEM_CUM_KEYS CMKEYS
    WHERE VEH_CUS_ITEM_CUM_KEY_ID = CMKEYS.CUM_KEY_ID;
    RETURN (V_CUM_QTY);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END CUM_QTYFORMULA;

  FUNCTION LAST_CUM_QTY_UPDATE_DATEFORMU(VEH_CUS_ITEM_CUM_KEY_ID IN NUMBER) RETURN DATE IS
    V_CUM_START DATE;
  BEGIN
    SELECT
      LAST_CUM_QTY_UPDATE_DATE
    INTO V_CUM_START
    FROM
      RLM_CUST_ITEM_CUM_KEYS CMKEYS
    WHERE VEH_CUS_ITEM_CUM_KEY_ID = CMKEYS.CUM_KEY_ID;
    RETURN (V_CUM_START);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END LAST_CUM_QTY_UPDATE_DATEFORMU;

  FUNCTION CF_SCHED_TYPE(SCHEDULE_TYPE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      X_SCHEDULE_TYPE VARCHAR2(80);
    BEGIN
      IF (SCHEDULE_TYPE IS NULL) THEN
        RETURN NULL;
      ELSE
        SELECT
          MEANING
        INTO X_SCHEDULE_TYPE
        FROM
          FND_LOOKUPS
        WHERE LOOKUP_TYPE = 'RLM_SCHEDULE_TYPE'
          AND LOOKUP_CODE = SCHEDULE_TYPE;
        RETURN X_SCHEDULE_TYPE;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN '-1';
    END;
    RETURN NULL;
  END CF_SCHED_TYPE;

  FUNCTION CF_SCHED_TYPE_2(SCHEDULE_TYPE2 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      X_SCHEDULE_TYPE VARCHAR2(80);
    BEGIN
      IF (SCHEDULE_TYPE2 IS NULL) THEN
        RETURN NULL;
      ELSE
        SELECT
          MEANING
        INTO X_SCHEDULE_TYPE
        FROM
          FND_LOOKUPS
        WHERE LOOKUP_TYPE = 'RLM_SCHEDULE_TYPE'
          AND LOOKUP_CODE = SCHEDULE_TYPE2;
        RETURN X_SCHEDULE_TYPE;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN '-1';
    END;
    RETURN NULL;
  END CF_SCHED_TYPE_2;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF UPPER(P_SUM_DATE_AND_BUCKET) = 'Y' THEN
      LP_Q1_COL1 := 'to_char(oelines.schedule_ship_date, ''DD-MON-YY HH24:MI:SS'')';
      LP_Q1_COL2 := 'NULL';
      LP_Q1_COL3 := '0';
      LP_Q1_COL4 := '0';
      LP_Q1_COL5 := 'NULL';
      LP_Q1_COL6 := 'sum(oelines.ordered_quantity)';
      LP_Q1_COL7 := 'NULL';
      LP_Q1_COL8 := 'sum(oelines.shipped_quantity)';
      LP_Q1_COL9 := 'NULL';
      LP_Q1_COL10 := 'sum(oelines.fulfilled_quantity)';
      LP_Q1_COL11 := 'NULL';
      LP_Q1_COL12 := 'NULL';
      LP_Q1_COL13 := 'NULL';
      LP_Q1_COL14 := 'NULL';
      LP_Q1_COL15 := 'NULL';
      LP_Q1_COL16 := 'NULL';
      LP_Q1_COL17 := 'NULL';
      LP_Q2_COL1 := 'nvl(oelines.intmed_ship_to_org_id, -1)';
      LP_Q2_COL2 := 'oelines.ship_from_org_id';
      LP_Q2_COL3 := 'oelines.ordered_item_id';
      LP_Q2_COL4 := 'oelines.inventory_item_id';
      LP_Q2_COL5 := 'NULL';
      LP_Q2_COL6 := 'NULL';
      LP_Q2_COL7 := '0';
      LP_Q2_COL8 := '0';
      LP_Q2_COL9 := 'NULL';
      LP_Q2_COL10 := 'sum(oelines.ordered_quantity)';
      LP_Q2_COL11 := 'NULL';
      LP_Q1_GROUP_BY := ' group by oelines.sold_to_org_id,
                        oelines.ship_to_org_id,
                        nvl(oelines.intmed_ship_to_org_id, -1),
                        oelines.ship_from_org_id,
                        oelines.inventory_item_id,
                        oelines.ordered_item_id,' || LP_Q1_COL1 || ',oelines.demand_bucket_type_code ';
      LP_Q2_GROUP_BY := ' group by oelines.sold_to_org_id,
                        oelines.ship_to_org_id,
                        nvl(oelines.intmed_ship_to_org_id, -1),
                        oelines.ship_from_org_id,
                        oelines.ordered_item_id,
                        oelines.inventory_item_id,
                        oelines.schedule_ship_date,
                        oelines.demand_bucket_type_code ';
    ELSIF UPPER(P_SUM_DATE_AND_BUCKET) = 'N' THEN
      LP_Q1_COL1 := 'to_char(oelines.schedule_ship_date, ''DD-MON-YY HH24:MI:SS'')';
      LP_Q1_COL2 := 'RLM_EXTINTERFACE_SV.GetLineStatus(schlines.line_id,oelines.line_id)';
      LP_Q1_COL3 := 'oeheaders.order_number';
      LP_Q1_COL4 := 'oelines.line_number';
      LP_Q1_COL5 := 'schlines.cust_po_number';
      LP_Q1_COL6 := 'oelines.ordered_quantity';
      LP_Q1_COL7 := 'oelines.order_quantity_uom';
      LP_Q1_COL8 := 'oelines.shipped_quantity';
      LP_Q1_COL9 := 'oelines.shipping_quantity_uom';
      LP_Q1_COL10 := 'oelines.fulfilled_quantity';
      LP_Q1_COL11 := '''EA''';
      LP_Q1_COL12 := 'schheaders.schedule_reference_num';
      LP_Q1_COL13 := 'schlines.customer_job';
      LP_Q1_COL14 := 'oelines.cust_production_seq_num';
      LP_Q1_COL15 := 'oelines.cust_model_serial_number';
      LP_Q1_COL16 := 'schlines.industry_attribute1';
      LP_Q1_COL17 := 'schheaders.schedule_type';
      LP_Q2_COL1 := 'nvl(oelines.intmed_ship_to_org_id, -1)';
      LP_Q2_COL2 := 'oelines.ship_from_org_id';
      LP_Q2_COL3 := 'oelines.ordered_item_id';
      LP_Q2_COL4 := 'oelines.inventory_item_id';
      LP_Q2_COL5 := 'RLM_EXTINTERFACE_SV.GetLineStatus(schlines.line_id,oelines.line_id)';
      LP_Q2_COL6 := 'schheaders.schedule_type';
      LP_Q2_COL7 := 'oeheaders.order_number';
      LP_Q2_COL8 := 'oelines.line_number';
      LP_Q2_COL9 := 'schlines.cust_po_number';
      LP_Q2_COL10 := 'oelines.ordered_quantity';
      LP_Q2_COL11 := 'oelines.order_quantity_uom';
    END IF;
    IF UPPER(P_SHIP_UNSHIP_BOTH) = 'S' THEN
      LP_Q1_LINES := ' and nvl(oelines.shipped_quantity,0) > 0 ' || ' and nvl(oelines.cancelled_flag,''N'') = ''N'' ';
    ELSIF UPPER(P_SHIP_UNSHIP_BOTH) = 'U' THEN
      LP_Q1_LINES := ' and nvl(oelines.shipped_quantity,0) = 0 ';
      IF UPPER(P_INCL_CANCEL_LINES) = 'N' THEN
        LP_Q1_LINES := LP_Q1_LINES || ' and nvl(oelines.cancelled_flag,''N'') = ''N'' ';
      ELSIF UPPER(P_INCL_CANCEL_LINES) = 'Y' THEN
        LP_Q1_LINES := LP_Q1_LINES || ' and nvl(oelines.cancelled_flag,''N'') in (''Y'',''N'') ';
      END IF;
    ELSIF UPPER(P_SHIP_UNSHIP_BOTH) = 'B' THEN
      IF UPPER(P_INCL_CANCEL_LINES) = 'N' THEN
        LP_Q1_LINES := LP_Q1_LINES || ' and nvl(oelines.cancelled_flag,''N'') = ''N'' ';
      ELSIF UPPER(P_INCL_CANCEL_LINES) = 'Y' THEN
        LP_Q1_LINES := LP_Q1_LINES || ' and nvl(oelines.cancelled_flag,''N'') in (''Y'',''N'') ';
      END IF;
    END IF;
    DECLARE
      STATEMENT0 VARCHAR2(100);
      STATEMENT1 VARCHAR2(100);
      STATEMENT2 VARCHAR2(100);
      STATEMENT3 VARCHAR2(100);
      STATEMENT4 VARCHAR2(100);
      STATEMENT5 VARCHAR2(100);
      STATEMENT6 VARCHAR2(100);
      STATEMENT7 VARCHAR2(100);
    BEGIN
      IF (P_SHIP_FROM_ORG_ID IS NOT NULL) THEN
        STATEMENT0 := '  And oelines.ship_from_org_id = :P_SHIP_FROM_ORG_ID';
      ELSE
        STATEMENT0 := ' ';
      END IF;
      IF (P_CUSTOMER_ID IS NOT NULL) THEN
        STATEMENT1 := '  And oelines.sold_to_org_id = :P_CUSTOMER_ID';
      ELSE
        STATEMENT1 := ' ';
      END IF;
      IF (P_DELIVER_TO_ORG_ID IS NOT NULL) THEN
        STATEMENT2 := '  And  oelines.intmed_ship_to_org_id = :P_DELIVER_TO_ORG_ID';
      ELSE
        STATEMENT2 := ' ';
      END IF;
      IF (P_SHIP_TO_ORG_ID IS NOT NULL) THEN
        STATEMENT3 := '  And oelines.ship_to_org_id = :P_SHIP_TO_ORG_ID';
      ELSE
        STATEMENT3 := ' ';
      END IF;
      IF (UPPER(P_CUST_OR_INV_ITEM) = 'C') THEN
        IF (P_FROM_ITEM_ID IS NOT NULL) THEN
          STATEMENT6 := '  And oelines.ordered_item_id >= :P_FROM_ITEM_ID';
        ELSE
          STATEMENT6 := ' ';
        END IF;
        IF (P_TO_ITEM_ID IS NOT NULL) THEN
          STATEMENT7 := '  And oelines.ordered_item_id <= :P_TO_ITEM_ID';
        ELSE
          STATEMENT7 := ' ';
        END IF;
      ELSIF (UPPER(P_CUST_OR_INV_ITEM) = 'I') THEN
        IF (P_FROM_ITEM_ID IS NOT NULL) THEN
          STATEMENT6 := '  And oelines.inventory_item_id >= :P_FROM_ITEM_ID';
        ELSE
          STATEMENT6 := ' ';
        END IF;
        IF (P_TO_ITEM_ID IS NOT NULL) THEN
          STATEMENT7 := '  And oelines.inventory_item_id <= :P_TO_ITEM_ID';
        ELSE
          STATEMENT7 := ' ';
        END IF;
      END IF;
      P_WHERE_CLAUSE1 := STATEMENT0 || STATEMENT1 || STATEMENT2 || STATEMENT3 || STATEMENT6 || STATEMENT7;
    END;
    DECLARE
      STATEMENT1 VARCHAR2(100);
      STATEMENT2 VARCHAR2(100);
      STATEMENT3 VARCHAR2(100);
      STATEMENT4 VARCHAR2(100);
    BEGIN
      IF (P_FROM_SHIP_DATE IS NOT NULL) THEN
        STATEMENT1 := '  And oelines.SCHEDULE_SHIP_DATE >= :P_FROM_SHIP_DATE';
      ELSE
        STATEMENT1 := ' ';
      END IF;
      IF (P_TO_SHIP_DATE IS NOT NULL) THEN
        STATEMENT2 := '  And oelines.SCHEDULE_SHIP_DATE <= :P_TO_SHIP_DATE';
      ELSE
        STATEMENT2 := ' ';
      END IF;
      IF (P_FROM_ORDER IS NOT NULL) THEN
        STATEMENT3 := '  And oeheaders.order_number >= :p_from_order';
      ELSE
        STATEMENT3 := ' ';
      END IF;
      IF (P_TO_ORDER IS NOT NULL) THEN
        STATEMENT4 := '  And oeheaders.order_number <= :p_to_order';
      ELSE
        STATEMENT4 := ' ';
      END IF;
      P_WHERE_CLAUSE2 := STATEMENT1 || STATEMENT2 || STATEMENT3 || STATEMENT4;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in AFTER REPORT TRIGGER')*/NULL;
        RETURN (FALSE);
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CP_DEFAULT_OU_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_DEFAULT_OU;
  END CP_DEFAULT_OU_P;

  FUNCTION CP_P_CUSTOMER_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_P_CUSTOMER_NAME;
  END CP_P_CUSTOMER_NAME_P;

  FUNCTION CP_P_SHIP_TO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_P_SHIP_TO;
  END CP_P_SHIP_TO_P;

  FUNCTION CP_P_SHIP_FROM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_P_SHIP_FROM;
  END CP_P_SHIP_FROM_P;

  FUNCTION CP_P_DELIVER_TO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_P_DELIVER_TO;
  END CP_P_DELIVER_TO_P;

END RLM_RLMDMSIQ_XMLP_PKG;

/
