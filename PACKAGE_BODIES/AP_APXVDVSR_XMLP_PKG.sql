--------------------------------------------------------
--  DDL for Package Body AP_APXVDVSR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXVDVSR_XMLP_PKG" AS
/* $Header: APXVDVSRB.pls 120.1 2008/01/11 13:03:43 vjaganat noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      MANUAL_VEND_NUM_TYPE CHAR(20);
      INIT_FAILURE EXCEPTION;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      IF (GET_COMPANY_NAME <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('2'
                   ,'After Get_Company_Name')*/NULL;
      END IF;
      IF (GET_NLS_STRINGS <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('3'
                   ,'After Get_NLS_Strings')*/NULL;
      END IF;
      IF (GET_BASE_CURR_DATA <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('4'
                   ,'After Get_Base_Curr_Data')*/NULL;
      END IF;
      IF (GIVE_MESSAGES <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('4'
                   ,'After Giving messages')*/NULL;
      END IF;
      BEGIN
        SELECT
          SUPPLIER_NUM_TYPE
        INTO MANUAL_VEND_NUM_TYPE
        FROM
          AP_PRODUCT_SETUP;
        C_MANUAL_VENDOR_NUM_TYPE := MANUAL_VEND_NUM_TYPE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
      BEGIN
        SELECT
          SORT_BY_ALTERNATE_FIELD
        INTO SORT_BY_ALTERNATE
        FROM
          AP_SYSTEM_PARAMETERS;
      EXCEPTION
        WHEN OTHERS THEN
          SORT_BY_ALTERNATE := 'N';
      END;
      BEGIN
        /*SRW.REFERENCE(DEFAULT_COUNTRY_CODE)*/NULL;
        DEFAULT_COUNTRY_CODE := FND_PROFILE.VALUE('DEFAULT_COUNTRY');
      EXCEPTION
        WHEN OTHERS THEN
          DEFAULT_COUNTRY_CODE := 'US';
      END;
      IF DEFAULT_COUNTRY_CODE IS NULL THEN
        DEFAULT_COUNTRY_CODE := 'US';
      END IF;
      BEGIN
        SELECT
          TERRITORY_SHORT_NAME
        INTO DEFAULT_COUNTRY_NAME
        FROM
          FND_TERRITORIES_VL
        WHERE TERRITORY_CODE = DEFAULT_COUNTRY_CODE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          SELECT
            TERRITORY_SHORT_NAME
          INTO DEFAULT_COUNTRY_NAME
          FROM
            FND_TERRITORIES_VL
          WHERE TERRITORY_CODE = 'US';
      END;
      GET_PARAMETER_DESCRIPTION;
      IF (UPPER(P_ORDER_BY_PAR) = 'VENDOR NAME') THEN
        /*SRW.MESSAGE('10'
                   ,'Getting supplier information, order by name...')*/NULL;
        IF P_VENDOR_ID_PAR IS NULL THEN
          IF SORT_BY_ALTERNATE = 'Y' THEN
            P_ORDER_BY := 'order by upper(p.vendor_name_alt)';
          ELSE
            P_ORDER_BY := 'order by upper(p.vendor_name)';
          END IF;
        ELSE
          IF SORT_BY_ALTERNATE = 'Y' THEN
            P_ORDER_BY := 'order by p.vendor_name_alt';
          ELSE
            P_ORDER_BY := 'order by p.vendor_name';
          END IF;
        END IF;
      ELSIF (UPPER(P_ORDER_BY_PAR) = 'CREATED BY') THEN
        /*SRW.MESSAGE('12'
                   ,'Getting Supplier information, order by Created by...')*/NULL;
        P_ORDER_BY := 'order by upper(fu1.user_name)';
      ELSIF (UPPER(P_ORDER_BY_PAR) = 'LAST UPDATED BY') THEN
        /*SRW.MESSAGE('13'
                   ,'Getting Supplier information, order by Last Updated by...')*/NULL;
        P_ORDER_BY := 'order by upper(fu2.user_name)';
      ELSE
        /*SRW.MESSAGE('11'
                   ,'Getting Supplier information, order by number...')*/NULL;
        IF MANUAL_VEND_NUM_TYPE = 'ALPHANUMERIC' THEN
          P_SORT_VENDOR_NUM_ALPHA := 'p.segment1';
          P_SORT_VENDOR_NUM_NUMERIC := 0;
          P_ORDER_BY := 'order by upper(p.segment1)';
        ELSE
          DECLARE
            V_CNT_SUPP NUMBER;
          BEGIN
            SELECT
              COUNT(TO_NUMBER(SEGMENT1))
            INTO V_CNT_SUPP
            FROM
              PO_VENDORS;
            P_SORT_VENDOR_NUM_NUMERIC := 'to_number(p.segment1)';
            P_SORT_VENDOR_NUM_ALPHA := '''NO SORT''';
            P_ORDER_BY := 'order by to_number(p.segment1)';
          EXCEPTION
            WHEN INVALID_NUMBER THEN
              P_SORT_VENDOR_NUM_ALPHA := 'p.segment1';
              P_SORT_VENDOR_NUM_NUMERIC := 0;
              P_ORDER_BY := 'order by upper(p.segment1)';
          END;
        END IF;
      END IF;
      IF P_VENDOR_ID_PAR IS NOT NULL THEN
        P_VENDOR_ID_SQL := 'AND p.vendor_id = ' || TO_CHAR(P_VENDOR_ID_PAR);
      END IF;
      IF P_SUPPLIERS_THIS_ORG = 'Y' THEN
        P_SUPPLIERS_THIS_ORG_SQL := 'AND EXISTS (SELECT ps.vendor_site_id FROM po_vendor_sites ps ' || 'WHERE ps.vendor_id = p.vendor_id)';
      END IF;
      IF P_CREATION_DATE_FROM IS NOT NULL AND P_CREATION_DATE_TO IS NOT NULL THEN
        IF P_SITE_PAR = 'Y' THEN
          LP_S_CREATION_DATE_FROM := 'AND (to_date(to_char(ps.creation_date, ''' || 'DD/MM/YYYY' || '''), ''' || 'DD/MM/YYYY' || ''')
                                            BETWEEN to_date(''' || TO_CHAR(P_CREATION_DATE_FROM
                                            ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || ''')
                                            AND to_date(''' || TO_CHAR(P_CREATION_DATE_TO
                                            ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || '''))  ';
        ELSE
          LP_V_CREATION_DATE_FROM := 'AND (to_date(to_char(p.creation_date, ''' || 'DD/MM/YYYY' || '''), ''' || 'DD/MM/YYYY' || ''')
                                             BETWEEN to_date(''' || TO_CHAR(P_CREATION_DATE_FROM
                                            ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || ''')
                                             AND to_date(''' || TO_CHAR(P_CREATION_DATE_TO
                                            ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || '''))  ';
        END IF;
      ELSIF P_CREATION_DATE_FROM IS NOT NULL AND P_CREATION_DATE_TO IS NULL THEN
        IF P_SITE_PAR = 'Y' THEN
          LP_S_CREATION_DATE_FROM := 'AND (to_date(to_char(ps.creation_date, ''' || 'DD/MM/YYYY' || '''), ''' || 'DD/MM/YYYY' || ''')
                                            BETWEEN to_date(''' || TO_CHAR(P_CREATION_DATE_FROM
                                            ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || ''')
                                            AND to_date(''' || TO_CHAR(SYSDATE
                                            ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || '''))  ';
          /*SRW.MESSAGE('50'
                     ,'value for parameter if site par = Y for create date from' || LP_S_CREATION_DATE_FROM)*/NULL;
        ELSE
          LP_V_CREATION_DATE_FROM := 'AND (to_date(to_char(p.creation_date, ''' || 'DD/MM/YYYY' || '''), ''' || 'DD/MM/YYYY' || ''')
                                            BETWEEN to_date(''' || TO_CHAR(P_CREATION_DATE_FROM
                                            ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || ''')
                                            AND to_date(''' || TO_CHAR(SYSDATE
                                            ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || '''))  ';
        END IF;
      ELSIF P_CREATION_DATE_TO IS NOT NULL AND P_CREATION_DATE_FROM IS NULL THEN
        IF P_SITE_PAR = 'Y' THEN
          LP_S_CREATION_DATE_TO := 'AND (to_date(to_char(ps.creation_date, ''' || 'DD/MM/YYYY' || '''), ''' || 'DD/MM/YYYY' || ''')
                                                                    <= to_date(''' || TO_CHAR(P_CREATION_DATE_TO
                                          ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || ''')) ';
          /*SRW.MESSAGE('50'
                     ,'value for parameter if site par = Y for create date to' || LP_S_CREATION_DATE_TO)*/NULL;
        ELSE
          LP_V_CREATION_DATE_TO := 'AND (to_date(to_char(p.creation_date, ''' || 'DD/MM/YYYY' || '''), ''' || 'DD/MM/YYYY' || ''')
                                                                    <= to_date(''' || TO_CHAR(P_CREATION_DATE_TO
                                          ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || ''')) ';
        END IF;
      END IF;
      IF P_UPDATE_DATE_FROM IS NOT NULL AND P_UPDATE_DATE_TO IS NOT NULL THEN
        IF P_SITE_PAR = 'Y' THEN
          LP_S_UPDATE_DATE_FROM := 'AND (to_date(to_char(ps.last_update_date, ''' || 'DD/MM/YYYY' || '''), ''' || 'DD/MM/YYYY' || ''')
                                           BETWEEN to_date(''' || TO_CHAR(P_UPDATE_DATE_FROM
                                          ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || ''')
                                           AND to_date(''' || TO_CHAR(P_UPDATE_DATE_TO
                                          ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || '''))  ';
        ELSE
          LP_V_UPDATE_DATE_FROM := 'AND (to_date(to_char(p.last_update_date, ''' || 'DD/MM/YYYY' || '''), ''' || 'DD/MM/YYYY' || ''')
                                           BETWEEN to_date(''' || TO_CHAR(P_UPDATE_DATE_FROM
                                          ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || ''')
                                           AND to_date(''' || TO_CHAR(P_UPDATE_DATE_TO
                                          ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || '''))  ';
        END IF;
      ELSIF P_UPDATE_DATE_FROM IS NOT NULL AND P_UPDATE_DATE_TO IS NULL THEN
        IF P_SITE_PAR = 'Y' THEN
          LP_S_UPDATE_DATE_FROM := 'AND (to_date(to_char(ps.last_update_date, ''' || 'DD/MM/YYYY' || '''), ''' || 'DD/MM/YYYY' || ''')
                                          BETWEEN to_date(''' || TO_CHAR(P_UPDATE_DATE_FROM
                                          ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || ''')
                                          AND to_date(''' || TO_CHAR(SYSDATE
                                          ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || '''))  ';
        ELSE
          LP_V_UPDATE_DATE_FROM := 'AND (to_date(to_char(p.last_update_date, ''' || 'DD/MM/YYYY' || '''), ''' || 'DD/MM/YYYY' || ''')
                                          BETWEEN to_date(''' || TO_CHAR(P_UPDATE_DATE_FROM
                                          ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || ''')
                                          AND to_date(''' || TO_CHAR(SYSDATE
                                          ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || '''))  ';
        END IF;
      ELSIF P_UPDATE_DATE_TO IS NOT NULL AND P_UPDATE_DATE_FROM IS NULL THEN
        IF P_SITE_PAR = 'Y' THEN
          LP_S_UPDATE_DATE_TO := 'AND (to_date(to_char(ps.last_update_date, ''' || 'DD/MM/YYYY' || '''), ''' || 'DD/MM/YYYY' || ''')
                                                                  <= to_date(''' || TO_CHAR(P_UPDATE_DATE_TO
                                        ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || ''')) ';
        ELSE
          LP_V_UPDATE_DATE_TO := 'AND (to_date(to_char(p.last_update_date, ''' || 'DD/MM/YYYY' || '''), ''' || 'DD/MM/YYYY' || ''')
                                                                  <= to_date(''' || TO_CHAR(P_UPDATE_DATE_TO
                                        ,'DD/MM/YYYY') || ''', ''' || 'DD/MM/YYYY' || ''')) ';
        END IF;
      END IF;
      IF P_CREATED_BY IS NOT NULL THEN
        IF P_SITE_PAR = 'Y' THEN
          LP_S_CREATED_BY := 'AND ps.created_by = ' || TO_CHAR(P_CREATED_BY);
        ELSE
          LP_V_CREATED_BY := 'AND p.created_by = ' || TO_CHAR(P_CREATED_BY);
        END IF;
      END IF;
      IF P_UPDATED_BY IS NOT NULL THEN
        IF P_SITE_PAR = 'Y' THEN
          LP_S_UPDATED_BY := 'AND ps.last_updated_by = ' || TO_CHAR(P_UPDATED_BY);
        ELSE
          LP_V_UPDATED_BY := 'AND p.last_updated_by = ' || TO_CHAR(P_UPDATED_BY);
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN (FALSE);
    END;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION CUSTOM_INIT(C_PAY_GROUP IN NUMBER) RETURN BOOLEAN IS
    L_PAY_GROUP PO_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    L_VENDOR_TYPE PO_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
  BEGIN
    SELECT
      SUBSTR(PG.DISPLAYED_FIELD
            ,1
            ,10),
      SUBSTR(VT.DISPLAYED_FIELD
            ,1
            ,10)
    INTO L_PAY_GROUP,L_VENDOR_TYPE
    FROM
      PO_LOOKUP_CODES PG,
      PO_LOOKUP_CODES VT
    WHERE PG.LOOKUP_TYPE = 'PAY GROUP'
      AND PG.LOOKUP_CODE = C_PAY_GROUP;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END CUSTOM_INIT;
  FUNCTION GET_BASE_CURR_DATA RETURN BOOLEAN IS
    L_BASE_CURR VARCHAR2(15);
    L_PREC NUMBER;
    L_MIN_AU NUMBER;
    L_SOB_ID NUMBER;
  BEGIN
    SELECT
      P.BASE_CURRENCY_CODE,
      C.PRECISION,
      C.MINIMUM_ACCOUNTABLE_UNIT
    INTO L_BASE_CURR,L_PREC,L_MIN_AU
    FROM
      AP_SYSTEM_PARAMETERS P,
      FND_CURRENCIES_VL C
    WHERE P.BASE_CURRENCY_CODE = C.CURRENCY_CODE;
    C_BASE_CURRENCY_CODE := L_BASE_CURR;
    C_BASE_PRECISION := L_PREC;
    C_BASE_MIN_ACCT_UNIT := L_MIN_AU;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_BASE_CURR_DATA;
  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN IS
    L_CHART_OF_ACCOUNTS_ID NUMBER;
    L_NAME VARCHAR2(30);
    L_SOB_ID NUMBER;
  BEGIN
    L_SOB_ID := P_SOB_ID;
    SELECT
      SUBSTR(NAME
            ,1
            ,30),
      CHART_OF_ACCOUNTS_ID
    INTO L_NAME,L_CHART_OF_ACCOUNTS_ID
    FROM
      GL_SETS_OF_BOOKS
    WHERE SET_OF_BOOKS_ID = L_SOB_ID;
    C_COMPANY_NAME_HEADER := L_NAME;
    C_CHART_OF_ACCOUNTS_ID := L_CHART_OF_ACCOUNTS_ID;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COMPANY_NAME;
  FUNCTION GET_NLS_STRINGS RETURN BOOLEAN IS
    NLS_YES FND_LOOKUPS.MEANING%TYPE;
    NLS_NO FND_LOOKUPS.MEANING%TYPE;
    L_NLS_ACTIVE AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    L_NLS_INACTIVE AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_ACTIVE FND_LOOKUPS.MEANING%TYPE;
    NLS_ALL FND_LOOKUPS.MEANING%TYPE;
  BEGIN
    NLS_YES := '';
    NLS_NO := '';
    SELECT
      LY.MEANING,
      LN.MEANING,
      LA.DISPLAYED_FIELD,
      LI.DISPLAYED_FIELD,
      AP_UTILITIES_PKG.AP_GET_DISPLAYED_FIELD('ALL OR ACTIVE'
                                             ,'Active'),
      AP_UTILITIES_PKG.AP_GET_DISPLAYED_FIELD('ALL OR ACTIVE'
                                             ,'All')
    INTO NLS_YES,NLS_NO,L_NLS_ACTIVE,L_NLS_INACTIVE,NLS_ACTIVE,NLS_ALL
    FROM
      FND_LOOKUPS LY,
      FND_LOOKUPS LN,
      AP_LOOKUP_CODES LA,
      AP_LOOKUP_CODES LI
    WHERE LY.LOOKUP_TYPE = 'YES_NO'
      AND LY.LOOKUP_CODE = 'Y'
      AND LN.LOOKUP_TYPE = 'YES_NO'
      AND LN.LOOKUP_CODE = 'N'
      AND LA.LOOKUP_TYPE = 'CODE_STATUS'
      AND LA.LOOKUP_CODE = 'A'
      AND LI.LOOKUP_TYPE = 'CODE_STATUS'
      AND LI.LOOKUP_CODE = 'I';
    C_NLS_YES := NLS_YES;
    C_NLS_NO := NLS_NO;
    C_STATUS_NLS_ACTIVE := NLS_ACTIVE;
    C_STATUS_NLS_ALL := NLS_ALL;
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_APPRVL_NO_DATA');
    C_NLS_NO_DATA_EXISTS := FND_MESSAGE.GET;
    C_NLS_NO_DATA_EXISTS := '*** ' || C_NLS_NO_DATA_EXISTS || ' ***';
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_ALL_END_OF_REPORT');
    C_NLS_END_OF_REPORT := FND_MESSAGE.GET;
    C_NLS_END_OF_REPORT := '*** ' || C_NLS_END_OF_REPORT || ' ***';
    /*SRW.MESSAGE('50'
               ,'Value for nls_end_of_report :||:c_nls_end_of_report')*/NULL;
    C_NLS_ACTIVE := L_NLS_ACTIVE;
    C_NLS_INACTIVE := L_NLS_INACTIVE;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_NLS_STRINGS;
  FUNCTION C_PAY_GROUPFORMULA RETURN NUMBER IS
  BEGIN
    DECLARE
      PAY_GROUP VARCHAR2(20);
    BEGIN
      PAY_GROUP := NULL;
      RETURN (PAY_GROUP);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    RETURN NULL;
  END C_PAY_GROUPFORMULA;
  FUNCTION GIVE_MESSAGES RETURN BOOLEAN IS
  BEGIN
    IF (P_SITE_PAR = 'N' AND P_CONTACT_PAR = 'Y') THEN
      /*SRW.MESSAGE('1'
                 ,'Vendor Site information required to print contacts - resubmit report if contact information desired')*/NULL;
    END IF;
    RETURN (TRUE);
  END GIVE_MESSAGES;
  FUNCTION C_ADDRESS_CONCATENATEDFORMULA(C_ADDRESS1 IN VARCHAR2
                                        ,C_ADDRESS2 IN VARCHAR2
                                        ,ADDRESS3 IN VARCHAR2
                                        ,C_CITY IN VARCHAR2
                                        ,C_STATE IN VARCHAR2
                                        ,C_ZIP IN VARCHAR2
                                        ,C_COUNTRY_NAME IN VARCHAR2
                                        ,C_COUNTRY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (FORMAT_ADDRESS_LABEL(NULL
                               ,C_ADDRESS1
                               ,C_ADDRESS2
                               ,ADDRESS3
                               ,NULL
                               ,C_CITY
                               ,NULL
                               ,C_STATE
                               ,NULL
                               ,C_ZIP
                               ,C_COUNTRY_NAME
                               ,C_COUNTRY_CODE
                               ,NULL
                               ,NULL
                               ,NULL
                               ,NULL
                               ,NULL
                               ,DEFAULT_COUNTRY_CODE
                               ,DEFAULT_COUNTRY_NAME
                               ,P_PRINT_HOME_COUNTRY
                               ,35
                               ,5
                               ,5));
  END C_ADDRESS_CONCATENATEDFORMULA;
  PROCEDURE GET_PARAMETER_DESCRIPTION IS
  BEGIN
    IF P_VENDOR_ID_PAR IS NOT NULL THEN
      SELECT
        VENDOR_NAME
      INTO CP_VENDOR_NAME
      FROM
        PO_VENDORS
      WHERE VENDOR_ID = P_VENDOR_ID_PAR;
    END IF;
    IF P_CREATED_BY IS NOT NULL THEN
      SELECT
        USER_NAME
      INTO CP_CREATED_BY
      FROM
        FND_USER
      WHERE USER_ID = P_CREATED_BY;
    END IF;
    IF P_UPDATED_BY IS NOT NULL THEN
      SELECT
        USER_NAME
      INTO CP_UPDATED_BY
      FROM
        FND_USER
      WHERE USER_ID = P_UPDATED_BY;
    END IF;
    IF P_ORDER_BY_PAR IS NOT NULL THEN
      SELECT
        DISPLAYED_FIELD
      INTO CP_ORDER_BY
      FROM
        AP_LOOKUP_CODES
      WHERE LOOKUP_TYPE = 'ORDER BY'
        AND LOOKUP_CODE = P_ORDER_BY_PAR;
    END IF;
    IF P_PAY_GROUP_PAR IS NOT NULL THEN
      SELECT
        DISPLAYED_FIELD
      INTO CP_PAY_GROUP
      FROM
        PO_LOOKUP_CODES
      WHERE LOOKUP_TYPE = 'PAY GROUP'
        AND LOOKUP_CODE = P_PAY_GROUP_PAR;
    END IF;
    IF P_INCOME_TAX_REP_PAR = 'Y' THEN
      CP_INCOME_TAX := C_NLS_YES;
    ELSIF P_INCOME_TAX_REP_PAR = 'N' THEN
      CP_INCOME_TAX := C_NLS_NO;
    END IF;
    IF P_SITE_PAR = 'Y' THEN
      CP_SITE_INF := C_NLS_YES;
    ELSIF P_SITE_PAR = 'N' THEN
      CP_SITE_INF := C_NLS_NO;
    END IF;
    IF P_SUPPLIERS_THIS_ORG = 'Y' THEN
      CP_SUPPLIERS_THIS_ORG := C_NLS_YES;
    ELSIF P_SUPPLIERS_THIS_ORG = 'N' THEN
      CP_SUPPLIERS_THIS_ORG := C_NLS_NO;
    END IF;
    IF P_PRINT_HOME_COUNTRY = 'Y' THEN
      CP_HOME_COUNTRY := C_NLS_YES;
    ELSIF P_PRINT_HOME_COUNTRY = 'N' THEN
      CP_HOME_COUNTRY := C_NLS_NO;
    END IF;
    IF P_CONTACT_PAR = 'Y' THEN
      CP_CONTACT_INF := C_NLS_YES;
    ELSIF P_CONTACT_PAR = 'N' THEN
      CP_CONTACT_INF := C_NLS_NO;
    END IF;
    IF P_BANK_ACCOUNT_PAR = 'Y' THEN
      CP_BANK_ACCOUNT_INF := C_NLS_YES;
    ELSIF P_BANK_ACCOUNT_PAR = 'N' THEN
      CP_BANK_ACCOUNT_INF := C_NLS_NO;
    END IF;
    IF P_VENDOR_STATUS_PAR = 'Active' THEN
      CP_VENDOR_STATUS_INF := C_STATUS_NLS_ACTIVE;
    ELSIF P_VENDOR_STATUS_PAR = 'All' THEN
      CP_VENDOR_STATUS_INF := C_STATUS_NLS_ALL;
    END IF;
    IF P_SITE_STATUS_PAR = 'Active' THEN
      CP_SITE_STATUS_INF := C_STATUS_NLS_ACTIVE;
    ELSIF P_SITE_STATUS_PAR = 'All' THEN
      CP_SITE_STATUS_INF := C_STATUS_NLS_ALL;
    END IF;
    IF P_CONTACT_STATUS_PAR = 'Active' THEN
      CP_CONTACT_STATUS_INF := C_STATUS_NLS_ACTIVE;
    ELSIF P_CONTACT_STATUS_PAR = 'All' THEN
      CP_CONTACT_STATUS_INF := C_STATUS_NLS_ALL;
    END IF;
    IF P_BANK_ACCOUNT_STATUS_PAR = 'Active' THEN
      CP_BANK_ACT_STATUS_INF := C_STATUS_NLS_ACTIVE;
    ELSIF P_BANK_ACCOUNT_STATUS_PAR = 'All' THEN
      CP_BANK_ACT_STATUS_INF := C_STATUS_NLS_ALL;
    END IF;
  END GET_PARAMETER_DESCRIPTION;
  FUNCTION C_PAYMENT_METHODFORMULA RETURN CHAR IS
  BEGIN
    NULL;
  END C_PAYMENT_METHODFORMULA;
  FUNCTION C_IBY_INFOFORMULA(C_VENDOR_SITE_ID IN NUMBER
                            ,C_ORG_ID IN NUMBER
                            ,C_PARTY_ID IN NUMBER
                            ,C_PARTY_SITE_ID IN NUMBER
                            ,C_PAYMENT_CURRENCY_CODE IN VARCHAR2) RETURN CHAR IS
    L_DUMMY1 VARCHAR2(200);
    L_DUMMY2 VARCHAR2(200);
    L_DUMMY3 VARCHAR2(200);
    L_DUMMY4 VARCHAR2(200);
    L_DUMMY5 VARCHAR2(200);
    L_PAY_ALONE VARCHAR2(1);
    L_DUMMY7 NUMBER;
    L_DUMMY8 VARCHAR2(200);
    L_DUMMY9 VARCHAR2(200);
    L_DUMMY10 VARCHAR2(200);
    L_DUMMY11 VARCHAR2(200);
    L_DUMMY12 VARCHAR2(200);
    L_DUMMY13 VARCHAR2(200);
    L_DUMMY14 VARCHAR2(200);
    L_DUMMY15 VARCHAR2(200);
    L_DUMMY16 VARCHAR2(200);
    L_DUMMY17 VARCHAR2(200);
    L_DUMMY18 VARCHAR2(240);
    L_LE NUMBER;
  BEGIN
    AP_UTILITIES_PKG.GET_INVOICE_LE(C_VENDOR_SITE_ID
                                   ,NULL
                                   ,C_ORG_ID
                                   ,L_LE);
    AP_INVOICES_PKG.GET_PAYMENT_ATTRIBUTES(P_LE_ID => L_LE
                                          ,P_ORG_ID => C_ORG_ID
                                          ,P_PAYEE_PARTY_ID => C_PARTY_ID
                                          ,P_PAYEE_PARTY_SITE_ID => C_PARTY_SITE_ID
                                          ,P_SUPPLIER_SITE_ID => C_VENDOR_SITE_ID
                                          ,P_PAYMENT_CURRENCY => C_PAYMENT_CURRENCY_CODE
                                          ,P_PAYMENT_AMOUNT => 1
                                          ,P_PAYMENT_FUNCTION => 'PAYABLES_DISB'
                                          ,P_PAY_PROC_TRXN_TYPE_CODE => 'PAYABLES_DOC'
                                          ,P_PAYMENT_METHOD_CODE => L_DUMMY1
                                          ,P_PAYMENT_REASON_CODE => L_DUMMY2
                                          ,P_BANK_CHARGE_BEARER => L_DUMMY3
                                          ,P_DELIVERY_CHANNEL_CODE => L_DUMMY4
                                          ,P_SETTLEMENT_PRIORITY => L_DUMMY5
                                          ,P_PAY_ALONE => L_PAY_ALONE
                                          ,P_EXTERNAL_BANK_ACCOUNT_ID => L_DUMMY7
                                          ,P_IBY_PAYMENT_METHOD => C_PAYMENT_METHOD
                                          ,P_PAYMENT_REASON => L_DUMMY8
                                          ,P_BANK_CHARGE_BEARER_DSP => L_DUMMY9
                                          ,P_DELIVERY_CHANNEL => L_DUMMY10
                                          ,P_SETTLEMENT_PRIORITY_DSP => L_DUMMY11
                                          ,P_BANK_ACCOUNT_NUM => L_DUMMY12
                                          ,P_BANK_ACCOUNT_NAME => L_DUMMY13
                                          ,P_BANK_BRANCH_NAME => L_DUMMY14
                                          ,P_BANK_BRANCH_NUM => L_DUMMY15
                                          ,P_BANK_NAME => L_DUMMY16
                                          ,P_BANK_NUMBER => L_DUMMY17
                                          ,P_PAYMENT_REASON_COMMENTS => L_DUMMY18);
    IF L_PAY_ALONE = 'Y' THEN
      C_PAY_ALONE := C_NLS_YES;
    ELSE
      C_PAY_ALONE := C_NLS_NO;
    END IF;
    RETURN 'Y';
  END C_IBY_INFOFORMULA;
  FUNCTION C_PAY_ALONE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PAY_ALONE;
  END C_PAY_ALONE_P;
  FUNCTION C_PAYMENT_METHOD_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PAYMENT_METHOD;
  END C_PAYMENT_METHOD_P;
  FUNCTION C_BASE_CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BASE_CURRENCY_CODE;
  END C_BASE_CURRENCY_CODE_P;
  FUNCTION C_BASE_PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN C_BASE_PRECISION;
  END C_BASE_PRECISION_P;
  FUNCTION C_BASE_MIN_ACCT_UNIT_P RETURN NUMBER IS
  BEGIN
    RETURN C_BASE_MIN_ACCT_UNIT;
  END C_BASE_MIN_ACCT_UNIT_P;
  FUNCTION C_NLS_YES_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_YES;
  END C_NLS_YES_P;
  FUNCTION C_NLS_NO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NO;
  END C_NLS_NO_P;
  FUNCTION C_NLS_ACTIVE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_ACTIVE;
  END C_NLS_ACTIVE_P;
  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMPANY_NAME_HEADER;
  END C_COMPANY_NAME_HEADER_P;
  FUNCTION C_CHART_OF_ACCOUNTS_ID_P RETURN NUMBER IS
  BEGIN
    RETURN C_CHART_OF_ACCOUNTS_ID;
  END C_CHART_OF_ACCOUNTS_ID_P;
  FUNCTION C_NLS_INACTIVE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_INACTIVE;
  END C_NLS_INACTIVE_P;
  FUNCTION C_START_TIME_P RETURN DATE IS
  BEGIN
    RETURN C_START_TIME;
  END C_START_TIME_P;
  FUNCTION C_END_TIME_P RETURN DATE IS
  BEGIN
    RETURN C_END_TIME;
  END C_END_TIME_P;
  FUNCTION C_NLS_NO_DATA_EXISTS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NO_DATA_EXISTS;
  END C_NLS_NO_DATA_EXISTS_P;
  FUNCTION C_MANUAL_VENDOR_NUM_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_MANUAL_VENDOR_NUM_TYPE;
  END C_MANUAL_VENDOR_NUM_TYPE_P;
  FUNCTION C_NLS_END_OF_REPORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_END_OF_REPORT;
  END C_NLS_END_OF_REPORT_P;
  FUNCTION CP_VENDOR_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_VENDOR_NAME;
  END CP_VENDOR_NAME_P;
  FUNCTION CP_CREATED_BY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CREATED_BY;
  END CP_CREATED_BY_P;
  FUNCTION CP_UPDATED_BY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_UPDATED_BY;
  END CP_UPDATED_BY_P;
  FUNCTION CP_ORDER_BY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ORDER_BY;
  END CP_ORDER_BY_P;
  FUNCTION CP_INCOME_TAX_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_INCOME_TAX;
  END CP_INCOME_TAX_P;
  FUNCTION CP_SITE_INF_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SITE_INF;
  END CP_SITE_INF_P;
  FUNCTION CP_HOME_COUNTRY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_HOME_COUNTRY;
  END CP_HOME_COUNTRY_P;
  FUNCTION CP_PAY_GROUP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PAY_GROUP;
  END CP_PAY_GROUP_P;
  FUNCTION CP_CONTACT_INF_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CONTACT_INF;
  END CP_CONTACT_INF_P;
  FUNCTION CP_BANK_ACCOUNT_INF_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BANK_ACCOUNT_INF;
  END CP_BANK_ACCOUNT_INF_P;
  FUNCTION CP_VENDOR_STATUS_INF_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_VENDOR_STATUS_INF;
  END CP_VENDOR_STATUS_INF_P;
  FUNCTION CP_SITE_STATUS_INF_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SITE_STATUS_INF;
  END CP_SITE_STATUS_INF_P;
  FUNCTION CP_BANK_ACT_STATUS_INF_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BANK_ACT_STATUS_INF;
  END CP_BANK_ACT_STATUS_INF_P;
  FUNCTION CP_CONTACT_STATUS_INF_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CONTACT_STATUS_INF;
  END CP_CONTACT_STATUS_INF_P;
  FUNCTION C_STATUS_NLS_ACTIVE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_STATUS_NLS_ACTIVE;
  END C_STATUS_NLS_ACTIVE_P;
  FUNCTION C_STATUS_NLS_ALL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_STATUS_NLS_ALL;
  END C_STATUS_NLS_ALL_P;
  FUNCTION CP_SUPPLIERS_THIS_ORG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SUPPLIERS_THIS_ORG;
  END CP_SUPPLIERS_THIS_ORG_P;
  FUNCTION FORMAT_ADDRESS_LABEL(ADDRESS_STYLE IN VARCHAR2
                               ,ADDRESS1 IN VARCHAR2
                               ,ADDRESS2 IN VARCHAR2
                               ,ADDRESS3 IN VARCHAR2
                               ,ADDRESS4 IN VARCHAR2
                               ,CITY IN VARCHAR2
                               ,COUNTY IN VARCHAR2
                               ,STATE IN VARCHAR2
                               ,PROVINCE IN VARCHAR2
                               ,POSTAL_CODE IN VARCHAR2
                               ,TERRITORY_SHORT_NAME IN VARCHAR2
                               ,COUNTRY_CODE IN VARCHAR2
                               ,CUSTOMER_NAME IN VARCHAR2
                               ,BILL_TO_LOCATION IN VARCHAR2
                               ,FIRST_NAME IN VARCHAR2
                               ,LAST_NAME IN VARCHAR2
                               ,MAIL_STOP IN VARCHAR2
                               ,DEFAULT_COUNTRY_CODE IN VARCHAR2
                               ,DEFAULT_COUNTRY_DESC IN VARCHAR2
                               ,PRINT_HOME_COUNTRY_FLAG IN VARCHAR2
                               ,WIDTH IN NUMBER
                               ,HEIGHT_MIN IN NUMBER
                               ,HEIGHT_MAX IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
	begin
	X0 := ARP_ADDR_LABEL_PKG.FORMAT_ADDRESS_LABEL(
                ADDRESS_STYLE, ADDRESS1, ADDRESS2, ADDRESS3, ADDRESS4, CITY, COUNTY, STATE,
                PROVINCE, POSTAL_CODE, TERRITORY_SHORT_NAME, COUNTRY_CODE, CUSTOMER_NAME,
                BILL_TO_LOCATION, FIRST_NAME, LAST_NAME, MAIL_STOP, DEFAULT_COUNTRY_CODE,
                DEFAULT_COUNTRY_DESC, PRINT_HOME_COUNTRY_FLAG, WIDTH, HEIGHT_MIN, HEIGHT_MAX);
       end;
       RETURN X0;
  END FORMAT_ADDRESS_LABEL;
function R_vendorFormatTrigger(c_creation_date_vendor in DATE,c_update_date_vendor in DATE,c_created_by_v_num in NUMBER, c_updated_by_v_num in NUMBER ) return varchar2 is
c_control_pay_group        boolean;
c_control_creation_date    boolean;
c_control_update_date      boolean;
c_control_created_by       boolean;
c_control_updated_by       boolean;
begin
  if p_pay_group_par is not null then
     c_control_pay_group := false;
  end if;
  if p_creation_date_from is not null and
     p_creation_date_to is not null
   then
     if to_date(to_char(c_creation_date_vendor,'DD/MM/YYYY'), 'DD/MM/YYYY')
        BETWEEN to_date(to_char(p_creation_date_from,'DD/MM/YYYY'), 'DD/MM/YYYY')
        AND to_date(to_char(p_creation_date_to, 'DD/MM/YYYY'), 'DD/MM/YYYY') then
        c_control_creation_date := true;
     else
        c_control_creation_date := false;
     end if;
  elsif p_creation_date_from is not null and
        p_creation_date_to is null
        then
     if to_date(to_char(c_creation_date_vendor,'DD/MM/YYYY'), 'DD/MM/YYYY')
        BETWEEN to_date(to_char(p_creation_date_from,'DD/MM/YYYY'), 'DD/MM/YYYY')
        AND to_date(to_char(sysdate, 'DD/MM/YYYY'), 'DD/MM/YYYY') then
        c_control_creation_date := true;
     else
        c_control_creation_date := false;
     end if;
  elsif p_creation_date_to is not null and
        p_creation_date_from is null
        then
     if to_date(to_char(c_creation_date_vendor,'DD/MM/YYYY'), 'DD/MM/YYYY')
        <= to_date(to_char(p_creation_date_to,'DD/MM/YYYY'), 'DD/MM/YYYY') then
        c_control_creation_date := true;
     else
        c_control_creation_date := false;
     end if;
  end if;
  --  For update date parameters
  if p_update_date_from is not null and
     p_update_date_to is not null
     then
     if to_date(to_char(c_update_date_vendor,'DD/MM/YYYY'), 'DD/MM/YYYY')
        BETWEEN to_date(to_char(p_update_date_from,'DD/MM/YYYY'), 'DD/MM/YYYY')
        AND to_date(to_char(p_update_date_to, 'DD/MM/YYYY'), 'DD/MM/YYYY') then
        c_control_update_date := true;
     else
        c_control_update_date := false;
     end if;
  elsif p_update_date_from is not null and
        p_update_date_to is null
        then
     if to_date(to_char(c_update_date_vendor,'DD/MM/YYYY'), 'DD/MM/YYYY')
        BETWEEN to_date(to_char(p_update_date_from,'DD/MM/YYYY'), 'DD/MM/YYYY')
        AND to_date(to_char(sysdate, 'DD/MM/YYYY'), 'DD/MM/YYYY') then
        c_control_update_date := true;
     else
        c_control_update_date := false;
     end if;
  elsif p_update_date_to is not null and
        p_update_date_from is null
        then
     if to_date(to_char(c_update_date_vendor,'DD/MM/YYYY'), 'DD/MM/YYYY')
        <= to_date(to_char(p_update_date_to,'DD/MM/YYYY'), 'DD/MM/YYYY') then
        c_control_update_date := true;
     else
        c_control_update_date := false;
     end if;
  end if;
  if p_created_by is not null then
    if c_created_by_v_num = p_created_by then
      c_control_created_by := true;
    else
      c_control_created_by := false;
    end if;
  end if;
  if p_updated_by is not null then
    if c_updated_by_v_num = p_updated_by then
      c_control_updated_by := true;
    else
      c_control_updated_by := false;
    end if;
  end if;

  if ( c_control_update_date = false or c_control_creation_date = false or c_control_pay_group = false or
       c_control_created_by = false or c_control_updated_by = false) then
     return ('false');

  else
     return('true');
  end if;
end;
END AP_APXVDVSR_XMLP_PKG;


/
