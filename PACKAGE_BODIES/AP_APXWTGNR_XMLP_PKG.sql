--------------------------------------------------------
--  DDL for Package Body AP_APXWTGNR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXWTGNR_XMLP_PKG" AS
/* $Header: APXWTGNRB.pls 120.0 2007/12/27 08:52:13 vjaganat noship $ */
  FUNCTION GET_BASE_CURR_DATA RETURN BOOLEAN IS
    BASE_CURR AP_SYSTEM_PARAMETERS.BASE_CURRENCY_CODE%TYPE;
    PREC FND_CURRENCIES_VL.PRECISION%TYPE;
    MIN_AU FND_CURRENCIES_VL.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
    DESCR FND_CURRENCIES_VL.DESCRIPTION%TYPE;
  BEGIN
    BASE_CURR := '';
    PREC := 0;
    MIN_AU := 0;
    DESCR := '';
    SELECT
      P.BASE_CURRENCY_CODE,
      C.PRECISION,
      C.MINIMUM_ACCOUNTABLE_UNIT,
      C.DESCRIPTION
    INTO BASE_CURR,PREC,MIN_AU,DESCR
    FROM
      AP_SYSTEM_PARAMETERS P,
      FND_CURRENCIES_VL C
    WHERE P.BASE_CURRENCY_CODE = C.CURRENCY_CODE;
    C_BASE_CURRENCY_CODE := BASE_CURR;
    C_BASE_PRECISION := PREC;
    C_BASE_MIN_ACCT_UNIT := MIN_AU;
    C_BASE_DESCRIPTION := DESCR;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_BASE_CURR_DATA;

  FUNCTION CUSTOM_INIT RETURN BOOLEAN IS
  BEGIN
    SAVEPOINT BEFORE_AWT_REPORT;
    P_TAX_AUTHORITY_TABLES := FTAXAUTHORITYTABLES;
    P_TAX_AUTHORITY_JOINS := FTAXAUTHORITYJOINS;
    P_SELECT_TAX_AUTHORITY := FSELECTTAXAUTHORITY;
    P_RESTRICT_TO_CHECKRUN_NAME := FRESTRICTTOCHECKRUNNAME;
    P_RESTRICT_TO_PAID_DISTS := FRESTRICTTOPAIDDISTS;
    P_SELECTED_SUPPLIERS := FSELECTEDSUPPLIERS;
    P_GL_POSTED_STATUS := FGLPOSTEDSTATUS;
    P_CERT_EXPIRATION_RANGE := FCERTEXPIRATIONRANGE;
    P_RESTRICT_CERTIFICATES := FRESTRICTCERTIFICATES;
    P_ORDER_BY := FORDERBY;
    IF (P_AWT_REPORT in ('AWT4','AWT5')) THEN
      P_TAX_AUTHORITY_NAME := 'tax_auth.vendor_name';
      P_TAX_AUTHORITY_SITE_CODE := 'tax_auth_site.vendor_site_code';
      P_TA_ADDRESS_LINE1 := 'tax_auth_site.address_line1';
      P_TA_ADDRESS_LINE2 := 'tax_auth_site.address_line2';
      P_TA_ADDRESS_LINE3 := 'tax_auth_site.address_line3';
      P_TA_CITY := 'tax_auth_site.city';
      P_TA_STATE := 'tax_auth_site.state';
      P_TA_ZIP := 'tax_auth_site.zip';
      P_TA_PROVINCE := 'tax_auth_site.province';
      P_TA_COUNTRY := 'tax_auth_site.country';
      IF (P_AWT_REPORT in ('AWT5','AWT6')) THEN
        P_REPORT_CURRENCY_V := 'FUNCTIONAL';
      END IF;
    END IF;
    IF (P_AWT_REPORT = 'AWT-I') THEN
      P_AWT_REPORT := 'AWT3';
      <<ITALIAN_CUSTOMIZATIONS>>DECLARE
        DATE_FROM VARCHAR2(10) := TO_CHAR(P_DATE_FROM
               ,'dd/mm/yyyy');
        DATE_TO VARCHAR2(10) := '31/12/' || TO_CHAR(P_DATE_FROM
               ,'yyyy');
      BEGIN
        P_GL_POSTED_STATUS := P_GL_POSTED_STATUS || '
                                             ' || 'and    exists (select ''Invoice Posting Date Ok''' || '
                                             ' || '               from   ap_invoice_distributions sub ' || '
                                             ' || '               where  sub.invoice_id = d.invoice_id' || '
                                             ' || '               and    sub.awt_group_id is not null' || '
                                             ' || '               and    sub.line_type_lookup_code = ' || '''ITEM''' || '
                                             ' || '               and    sub.accounting_date <= ' || '
                                             ' || '                      to_date(''' || DATE_TO || '''' || ',''dd/mm/yyyy'')' || '
                                             ' || '              )';
        DECLARE
          CURSOR C_INVOICES_POSTED_UNPAID IS
            SELECT
              DISTINCT
              I.INVOICE_ID INVOICE_ID,
              I.INVOICE_AMOUNT - NVL(I.AMOUNT_PAID
                 ,0) AMOUNT
            FROM
              AP_INVOICES I,
              AP_INVOICE_DISTRIBUTIONS D
            WHERE I.INVOICE_ID = D.INVOICE_ID
              AND I.INVOICE_AMOUNT - NVL(I.AMOUNT_PAID
               ,0) > 0
              AND I.VENDOR_ID = NVL(P_SUPPLIER_ID
               ,I.VENDOR_ID)
              AND D.LINE_TYPE_LOOKUP_CODE = 'ITEM'
              AND D.AWT_GROUP_ID is not null
              AND D.ACCOUNTING_DATE <= TO_DATE(DATE_TO
                   ,'dd/mm/yyyy')
              AND D.ACCRUAL_POSTED_FLAG = DECODE(P_SYSTEM_ACCT_METHOD
                  ,'ACCRUAL'
                  ,'Y'
                  ,'BOTH'
                  ,'Y'
                  ,D.ACCRUAL_POSTED_FLAG)
              AND D.CASH_POSTED_FLAG = DECODE(P_SYSTEM_ACCT_METHOD
                  ,'CASH'
                  ,'Y'
                  ,'BOTH'
                  ,'Y'
                  ,D.CASH_POSTED_FLAG);
          REC_INVOICES_POSTED_UNPAID C_INVOICES_POSTED_UNPAID%ROWTYPE;
          DO_WITHHOLDING_SUCCESS VARCHAR2(2000);
        BEGIN
          OPEN C_INVOICES_POSTED_UNPAID;
          LOOP
            FETCH C_INVOICES_POSTED_UNPAID
             INTO REC_INVOICES_POSTED_UNPAID;
            EXIT WHEN C_INVOICES_POSTED_UNPAID%NOTFOUND;
            SAVEPOINT BEFORE_INVOICE_PROCESSED;
            IF (P_LOG_TO_PIPE in ('y','Y')) THEN
              AP_BEGIN_LOG('AWT Report'      ,P_PIPE_SIZE);
            END IF;
            BEGIN
              AP_DO_WITHHOLDING(P_INVOICE_ID => REC_INVOICES_POSTED_UNPAID.INVOICE_ID
                               ,P_AWT_DATE => P_DATE_TO
                               ,P_CALLING_MODULE => 'AWT REPORT'
                               ,P_AMOUNT => REC_INVOICES_POSTED_UNPAID.AMOUNT
                               ,P_PAYMENT_NUM => NULL
                               ,P_CHECKRUN_NAME => NULL
                               ,P_LAST_UPDATED_BY => -1
                               ,P_LAST_UPDATE_LOGIN => -1
                               ,P_PROGRAM_APPLICATION_ID => NULL
                               ,P_PROGRAM_ID => NULL
                               ,P_REQUEST_ID => NULL
                               ,P_AWT_SUCCESS => DO_WITHHOLDING_SUCCESS
                               ,P_INVOICE_PAYMENT_ID => NULL);
            EXCEPTION
              WHEN OTHERS THEN
                /*SRW.MESSAGE(10
                           ,SQLERRM)*/NULL;
            END;
            IF (P_LOG_TO_PIPE in ('y','Y')) THEN
              AP_END_LOG;
              <<LOG_FROM_PIPE>>DECLARE
                ID NUMBER;
                TEXT_LINE VARCHAR2(5000);
                INVALID_PIPE_NAME EXCEPTION;
              BEGIN
                IF (AP_PIPE_NAME IS NULL) THEN
                  RAISE INVALID_PIPE_NAME;
                END IF;
              EXCEPTION
                WHEN INVALID_PIPE_NAME THEN
                  /*SRW.MESSAGE(10
                             ,'Null pipe name -- cannot proceed')*/NULL;
              END;
            END IF;
            IF (DO_WITHHOLDING_SUCCESS <> 'SUCCESS') THEN
              IF (P_DEBUG_SWITCH = 'Y') THEN
                /*SRW.MESSAGE(10
                           ,'Projected Withholding not performed [Id' || TO_CHAR(REC_INVOICES_POSTED_UNPAID.INVOICE_ID) || ']: ' || DO_WITHHOLDING_SUCCESS)*/NULL;
              END IF;
              ROLLBACK TO BEFORE_INVOICE_PROCESSED;
            END IF;
          END LOOP;
          CLOSE C_INVOICES_POSTED_UNPAID;
        END;
      END;
    END IF;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END CUSTOM_INIT;

  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COVER_PAGE_VALUES;

  FUNCTION GET_NLS_STRINGS RETURN BOOLEAN IS
    NLS_VOID AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_NA AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_ALL AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_YES FND_LOOKUPS.MEANING%TYPE;
    NLS_NO FND_LOOKUPS.MEANING%TYPE;
  BEGIN
    SELECT
      LY.MEANING,
      LN.MEANING,
      L1.DISPLAYED_FIELD,
      L2.DISPLAYED_FIELD,
      L3.DISPLAYED_FIELD
    INTO NLS_YES,NLS_NO,NLS_ALL,NLS_VOID,NLS_NA
    FROM
      FND_LOOKUPS LY,
      FND_LOOKUPS LN,
      AP_LOOKUP_CODES L1,
      AP_LOOKUP_CODES L2,
      AP_LOOKUP_CODES L3
    WHERE LY.LOOKUP_TYPE = 'YES_NO'
      AND LY.LOOKUP_CODE = 'Y'
      AND LN.LOOKUP_TYPE = 'YES_NO'
      AND LN.LOOKUP_CODE = 'N'
      AND L1.LOOKUP_TYPE = 'NLS REPORT PARAMETER'
      AND L1.LOOKUP_CODE = 'ALL'
      AND L2.LOOKUP_TYPE = 'NLS TRANSLATION'
      AND L2.LOOKUP_CODE = 'VOID'
      AND L3.LOOKUP_TYPE = 'NLS REPORT PARAMETER'
      AND L3.LOOKUP_CODE = 'NA';
    C_NLS_YES := NLS_YES;
    C_NLS_NO := NLS_NO;
    C_NLS_ALL := NLS_ALL;
    C_NLS_VOID := NLS_VOID;
    C_NLS_NA := NLS_NA;
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_APPRVL_NO_DATA');
    C_NLS_NO_DATA_EXISTS := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_ALL_END_OF_REPORT');
    C_NLS_END_OF_REPORT := FND_MESSAGE.GET;
  --  C_NLS_NO_DATA_EXISTS := '*** ' || C_NLS_NO_DATA_EXISTS || ' ***';
  --  C_NLS_END_OF_REPORT := '*** ' || C_NLS_END_OF_REPORT || ' ***';
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_NLS_STRINGS;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      L_VENDOR_REALNAME_LOW PO_VENDORS.VENDOR_NAME%TYPE;
      L_VENDOR_REALNAME_HIGH PO_VENDORS.VENDOR_NAME%TYPE;
      INIT_FAILURE EXCEPTION;
    BEGIN
    p_debug_switch:='Y';

    P_SUPPLIER_FROM_V:=P_SUPPLIER_FROM;
    P_SUPPLIER_TO_V:=P_SUPPLIER_TO;
    P_SUPP_NUM_FROM_V:=P_SUPP_NUM_FROM;
    P_SUPP_NUM_TO_V:=P_SUPP_NUM_TO;
      IF (P_SUPPLIER_FROM_V IS NOT NULL) THEN
        SELECT
          V.VENDOR_NAME
        INTO L_VENDOR_REALNAME_LOW
        FROM
          PO_VENDORS V
        WHERE V.VENDOR_ID = TO_NUMBER(P_SUPPLIER_FROM_V);
      END IF;
      IF (P_SUPPLIER_TO_V IS NOT NULL) THEN
        SELECT
          V.VENDOR_NAME
        INTO L_VENDOR_REALNAME_HIGH
        FROM
          PO_VENDORS V
        WHERE V.VENDOR_ID = TO_NUMBER(P_SUPPLIER_TO_V);
      END IF;
      P_SUPPLIER_FROM_V := L_VENDOR_REALNAME_LOW;
      P_SUPPLIER_TO_V := L_VENDOR_REALNAME_HIGH;
      C_REPORT_START_DATE := SYSDATE;
      IF (GET_COMPANY_NAME <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        /*SRW.MESSAGE('2'
                   ,'After Get_Company_Name')*/NULL;
      END IF;
      IF (GET_NLS_STRINGS <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        /*SRW.MESSAGE('3'
                   ,'After Get_NLS_Strings')*/NULL;
      END IF;
      IF (GET_BASE_CURR_DATA <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        /*SRW.MESSAGE('4'
                   ,'After Get_Base_Curr_Data')*/NULL;
      END IF;
      IF (P_DATE_FROM IS NOT NULL AND P_DATE_TO IS NOT NULL) THEN
        IF P_DATE_FROM = P_DATE_TO THEN
          P_DATE_FILTER := ' and d.accounting_date = to_date(''' || FND_DATE.DATE_TO_CANONICAL(P_DATE_FROM) || ''', ''YYYY/MM/DD HH24:MI:SS'')';
        ELSE
          P_DATE_FILTER := ' and d.accounting_date between to_date(''' || FND_DATE.DATE_TO_CANONICAL(P_DATE_FROM) || ''', ''YYYY/MM/DD HH24:MI:SS'') and to_date(''' || FND_DATE.DATE_TO_CANONICAL(P_DATE_TO) || ''', ''YYYY/MM/DD HH24:MI:SS'')';
        END IF;
      ELSIF (P_DATE_FROM IS NOT NULL AND P_DATE_TO IS NULL) THEN
        P_DATE_FILTER := ' and d.accounting_date >= to_date(''' || FND_DATE.DATE_TO_CANONICAL(P_DATE_FROM) || ''', ''YYYY/MM/DD HH24:MI:SS'')';
      ELSIF (P_DATE_FROM IS NULL AND P_DATE_TO IS NOT NULL) THEN
        P_DATE_FILTER := ' and d.accounting_date <= to_date(''' || FND_DATE.DATE_TO_CANONICAL(P_DATE_TO) || ''', ''YYYY/MM/DD HH24:MI:SS'')';
      ELSE
        P_DATE_FILTER := ' and 1 = 1 ';
      END IF;
      IF (P_TAX_NAME IS NOT NULL AND P_TAX_NAME <> '%') THEN
        P_TAX_NAME_FILTER := ' and n.name = ' || '''' || P_TAX_NAME || '''';
      ELSE
        P_TAX_NAME_FILTER := ' and 1 = 1 ';
      END IF;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        /*SRW.BREAK*/NULL;
      END IF;
      RETURN (TRUE);
    EXCEPTION
      WHEN OTHERS THEN
--        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
	null;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      ROLLBACK TO BEFORE_AWT_REPORT;
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('20'
                   ,'After SRWEXIT')*/NULL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        --/*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
        null;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN IS
    L_CHART_OF_ACCOUNTS_ID GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE;
    L_NAME GL_SETS_OF_BOOKS.NAME%TYPE;
    L_SOB_ID NUMBER;
  BEGIN
    IF P_SET_OF_BOOKS_ID IS NOT NULL THEN
      L_SOB_ID := P_SET_OF_BOOKS_ID;
      SELECT
        NAME,
        CHART_OF_ACCOUNTS_ID
      INTO L_NAME,L_CHART_OF_ACCOUNTS_ID
      FROM
        GL_SETS_OF_BOOKS
      WHERE SET_OF_BOOKS_ID = L_SOB_ID;
      C_COMPANY_NAME_HEADER := L_NAME;
      C_CHART_OF_ACCOUNTS_ID := L_CHART_OF_ACCOUNTS_ID;
    END IF;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COMPANY_NAME;

  FUNCTION CBASECURRENCYNAME RETURN VARCHAR2 IS
    CURSOR C_NAME IS
      SELECT
        NAME
      FROM
        FND_CURRENCIES_VL
      WHERE ( CURRENCY_CODE = C_BASE_CURRENCY_CODE );
    CURR_NAME FND_CURRENCIES_VL.NAME%TYPE;
  BEGIN
    OPEN C_NAME;
    FETCH C_NAME
     INTO CURR_NAME;
    CLOSE C_NAME;
    RETURN (CURR_NAME);
  END CBASECURRENCYNAME;

  FUNCTION CREPORTTITLE RETURN VARCHAR2 IS
  BEGIN
    IF (P_AWT_REPORT = 'AWT1') THEN
      RETURN ('Withholding Tax by Invoice Report');
    ELSIF (P_AWT_REPORT = 'AWT2') THEN
      RETURN ('Withholding Tax by Payment Report');
    ELSIF (P_AWT_REPORT = 'AWT3') THEN
      RETURN ('Withholding Tax by Vendor Report');
    ELSIF (P_AWT_REPORT = 'AWT4') THEN
      RETURN ('Withholding Tax Authority Remittance Advice');
    ELSIF (P_AWT_REPORT = 'AWT5') THEN
      RETURN ('Withholding Tax by Tax Authority Report');
    ELSIF (P_AWT_REPORT = 'AWT6') THEN
      RETURN ('Withholding Tax Certificate Listing');
    ELSE
      RETURN ('Withholding Tax General Report');
    END IF;
    RETURN NULL;
  END CREPORTTITLE;

  FUNCTION ACCEPT_PARAMETER(PARAMETER_NAME IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    IF (PARAMETER_NAME = 'P_AWT_Report') THEN
      IF (P_AWT_REPORT not in ('AWT1','AWT2','AWT3','AWT4','AWT5','AWT6','AWT-I')) THEN
        /*SRW.MESSAGE(999
                   ,'AWT: Invalid Report Type [' || P_AWT_REPORT || ']')*/NULL;
        RETURN (FALSE);
      END IF;
    ELSIF (PARAMETER_NAME = 'P_Date_To') THEN
      IF (P_DATE_TO < P_DATE_FROM) THEN
        /*SRW.MESSAGE(999
                   ,'AWT: Invalid Date Range [' || TO_CHAR(P_DATE_FROM
                          ,'dd-Mon-yyyy') || ' > ' || TO_CHAR(P_DATE_TO
                          ,'dd-Mon-yyyy') || ']')*/NULL;
        RETURN (FALSE);
      END IF;
      DECLARE
        CURSOR C_ROW_EXISTS IS
          SELECT
            'One Withholding Tax Distribution Exists'
          FROM
            AP_INVOICE_DISTRIBUTIONS
          WHERE ACCOUNTING_DATE between NVL(P_DATE_FROM
             ,ACCOUNTING_DATE)
            AND NVL(P_DATE_TO
             ,ACCOUNTING_DATE);
        REC_ROW_EXISTS C_ROW_EXISTS%ROWTYPE;
        ROW_FOUND BOOLEAN;
      BEGIN
        OPEN C_ROW_EXISTS;
        FETCH C_ROW_EXISTS
         INTO REC_ROW_EXISTS;
        ROW_FOUND := C_ROW_EXISTS%FOUND;
        CLOSE C_ROW_EXISTS;
        IF NOT ROW_FOUND THEN
          /*SRW.MESSAGE(999
                     ,'AWT: Date Range [' || NVL(TO_CHAR(P_DATE_FROM
                                ,'dd-Mon-yyyy')
                        ,'No Lower Limit') || ' / ' || NVL(TO_CHAR(P_DATE_TO
                                ,'dd-Mon-yyyy')
                        ,'No Upper Limit') || '] will retrieve no withholding rows')*/NULL;
          RETURN (TRUE);
        END IF;
      END;
    ELSIF (PARAMETER_NAME = 'P_Tax_Authority_Id') THEN
      IF (P_TAX_AUTHORITY_ID IS NOT NULL) THEN
        IF (P_AWT_REPORT not in ('AWT4','AWT5')) THEN
          /*SRW.MESSAGE(999
                     ,'AWT: Invalid Report Type [' || P_AWT_REPORT || '] in association with a Tax Authority')*/NULL;
          RETURN (FALSE);
        END IF;
      END IF;
    ELSIF (PARAMETER_NAME = 'P_Checkrun_Name') THEN
      IF (P_CHECKRUN_NAME IS NOT NULL) THEN
        DECLARE
          CURSOR C_CHECKRUN_OK IS
            SELECT
              'Checkrun_Name exists'
            FROM
              AP_CHECKS
            WHERE ( CHECKRUN_NAME = P_CHECKRUN_NAME );
          REC_CHECKRUN_OK C_CHECKRUN_OK%ROWTYPE;
          ROW_FOUND BOOLEAN;
        BEGIN
          OPEN C_CHECKRUN_OK;
          FETCH C_CHECKRUN_OK
           INTO REC_CHECKRUN_OK;
          ROW_FOUND := C_CHECKRUN_OK%FOUND;
          CLOSE C_CHECKRUN_OK;
          IF NOT ROW_FOUND THEN
            /*SRW.MESSAGE(999
                       ,'AWT: Invalid Checkrun Name [' || P_CHECKRUN_NAME || ']')*/NULL;
            RETURN (FALSE);
          END IF;
        END;
      END IF;
    ELSIF (PARAMETER_NAME = 'P_Supplier_Id') THEN
      IF (P_SUPPLIER_ID IS NOT NULL) THEN
        P_SUPPLIER_FROM_V := NULL;
        P_SUPPLIER_TO_V := NULL;
        P_SUPP_NUM_FROM := NULL;
        P_SUPP_NUM_TO := NULL;
      END IF;
    ELSIF (PARAMETER_NAME = 'P_Report_Currency') THEN
      IF (P_REPORT_CURRENCY_V not in ('ORIGINAL','FUNCTIONAL')) THEN
        /*SRW.MESSAGE(999
                   ,'AWT: Invalid Currency Classification [' || P_REPORT_CURRENCY || ']')*/NULL;
        RETURN (FALSE);
      END IF;
    ELSIF (PARAMETER_NAME = 'P_Invoice_Classes') THEN
      IF (P_INVOICE_CLASSES IS NULL) THEN
        /*SRW.MESSAGE(999
                   ,'AWT: Invalid Null Invoice Classes Setting')*/NULL;
        RETURN (FALSE);
      END IF;
    ELSIF (PARAMETER_NAME = 'P_Posted_Status') THEN
      IF (NVL(P_POSTED_STATUS
         ,'ITEMS_POSTED') not in ('ITEMS_POSTED','ITEMS_PARTIALLY_POSTED','ITEMS_UNPOSTED')) THEN
        /*SRW.MESSAGE(999
                   ,'AWT: Invalid Posted Status [' || P_POSTED_STATUS || ']')*/NULL;
        RETURN (FALSE);
      END IF;
    ELSIF (PARAMETER_NAME = 'P_Cert_Expire_To') THEN
      IF ((P_CERT_EXPIRE_FROM IS NOT NULL) AND (P_CERT_EXPIRE_TO IS NOT NULL) AND (P_CERT_EXPIRE_TO < P_CERT_EXPIRE_FROM)) THEN
        /*SRW.MESSAGE(999
                   ,'AWT: Invalid Certificates Expire Date Range [' || TO_CHAR(P_CERT_EXPIRE_FROM
                          ,'dd-Mon-yyyy') || ' > ' || TO_CHAR(P_CERT_EXPIRE_TO
                          ,'dd-Mon-yyyy') || ']')*/NULL;
        RETURN (FALSE);
      END IF;
    END IF;
    RETURN (TRUE);
  END ACCEPT_PARAMETER;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        /*SRW.MESSAGE('1'
                   ,'After SRWINIT')*/NULL;
      END IF;
      IF (P_SET_OF_BOOKS_ID IS NULL) THEN
        DECLARE
          CURSOR C_SOB IS
            SELECT
              SET_OF_BOOKS_ID
            FROM
              AP_SYSTEM_PARAMETERS;
        BEGIN
          OPEN C_SOB;
          FETCH C_SOB
           INTO P_SET_OF_BOOKS_ID;
          CLOSE C_SOB;
        END;
      END IF;
    END;
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION CTAADDRESS(TA_CITY IN VARCHAR2
                     ,TA_STATE IN VARCHAR2
                     ,TA_ZIP IN VARCHAR2
                     ,TA_ADDRESS_LINE1 IN VARCHAR2
                     ,TA_ADDRESS_LINE2 IN VARCHAR2
                     ,TA_ADDRESS_LINE3 IN VARCHAR2) RETURN VARCHAR2 IS
    PREV_NOT_NULL BOOLEAN;
    ADDRESS_TEXT VARCHAR2(2000);
    LAST_LINE VARCHAR2(2000) := TA_CITY || ' ' || TA_STATE || ', ' || TA_ZIP;
  BEGIN
    ADDRESS_TEXT := TA_ADDRESS_LINE1;
    PREV_NOT_NULL := (TA_ADDRESS_LINE1 IS NOT NULL);
    IF (TA_ADDRESS_LINE2 IS NOT NULL) THEN
      IF PREV_NOT_NULL THEN
        ADDRESS_TEXT := ADDRESS_TEXT;
      END IF;
      ADDRESS_TEXT := ADDRESS_TEXT || TA_ADDRESS_LINE2;
      PREV_NOT_NULL := TRUE;
    END IF;
    IF (TA_ADDRESS_LINE3 IS NOT NULL) THEN
      IF PREV_NOT_NULL THEN
        ADDRESS_TEXT := ADDRESS_TEXT;
      END IF;
      ADDRESS_TEXT := ADDRESS_TEXT || TA_ADDRESS_LINE3;
      PREV_NOT_NULL := TRUE;
    END IF;
    IF PREV_NOT_NULL THEN
      ADDRESS_TEXT := ADDRESS_TEXT;
    END IF;
    ADDRESS_TEXT := ADDRESS_TEXT || LAST_LINE;
    RETURN (SUBSTR(ADDRESS_TEXT
                 ,1
                 ,240));
  END CTAADDRESS;

  FUNCTION CSITEADDRESS(SITE_CITY IN VARCHAR2
                       ,SITE_STATE IN VARCHAR2
                       ,SITE_ZIP IN VARCHAR2
                       ,SITE_ADDRESS_LINE1 IN VARCHAR2
                       ,SITE_ADDRESS_LINE2 IN VARCHAR2
                       ,SITE_ADDRESS_LINE3 IN VARCHAR2) RETURN VARCHAR2 IS
    PREV_NOT_NULL BOOLEAN;
    ADDRESS_TEXT VARCHAR2(2000);
    LAST_LINE VARCHAR2(2000) := SITE_CITY || ' ' || SITE_STATE || ', ' || SITE_ZIP;
  BEGIN
    ADDRESS_TEXT := SITE_ADDRESS_LINE1;
    PREV_NOT_NULL := (SITE_ADDRESS_LINE1 IS NOT NULL);
    IF (SITE_ADDRESS_LINE2 IS NOT NULL) THEN
      IF PREV_NOT_NULL THEN
        ADDRESS_TEXT := ADDRESS_TEXT;
      END IF;
      ADDRESS_TEXT := ADDRESS_TEXT || SITE_ADDRESS_LINE2;
      PREV_NOT_NULL := TRUE;
    END IF;
    IF (SITE_ADDRESS_LINE3 IS NOT NULL) THEN
      IF PREV_NOT_NULL THEN
        ADDRESS_TEXT := ADDRESS_TEXT;
      END IF;
      ADDRESS_TEXT := ADDRESS_TEXT || SITE_ADDRESS_LINE3;
      PREV_NOT_NULL := TRUE;
    END IF;
    IF PREV_NOT_NULL THEN
      ADDRESS_TEXT := ADDRESS_TEXT;
    END IF;
    ADDRESS_TEXT := ADDRESS_TEXT || LAST_LINE;
    RETURN (SUBSTR(ADDRESS_TEXT
                 ,1
                 ,240));
  END CSITEADDRESS;

  FUNCTION CINVOICECLASS(AWT_FLAG IN VARCHAR2
                        ,INVOICE_DATE IN DATE) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(AWT_FLAG)*/NULL;
    /*SRW.REFERENCE(INVOICE_DATE)*/NULL;
    IF (P_INVOICE_CLASSES = 'DISABLED') THEN
      RETURN ('No Invoice Classes Defined');
    ELSE
      IF (AWT_FLAG = 'P') THEN
        RETURN ('CURRENT_UNPAID');
      ELSIF (INVOICE_DATE < P_DATE_FROM) THEN
        RETURN ('PREVIOUS_PAID');
      ELSE
        RETURN ('CURRENT_PAID');
      END IF;
    END IF;
    RETURN NULL;
  END CINVOICECLASS;

  FUNCTION CACTUALCURRENCYNAME(INVOICE_CURRENCY_NAME IN VARCHAR2
                              ,C_BASE_CURRENCY_NAME IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(INVOICE_CURRENCY_NAME)*/NULL;
    IF (P_REPORT_CURRENCY_V = 'ORIGINAL') THEN
      RETURN (INVOICE_CURRENCY_NAME);
    ELSIF (P_REPORT_CURRENCY_V = 'FUNCTIONAL') THEN
      RETURN (C_BASE_CURRENCY_NAME);
    END IF;
    RETURN NULL;
  END CACTUALCURRENCYNAME;

  FUNCTION CINVOICEACTUALAMOUNT(INVOICE_AMOUNT IN NUMBER
                               ,INVOICE_CURRENCY_CODE IN VARCHAR2
                               ,INVOICE_BASE_AMOUNT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF (P_REPORT_CURRENCY_V = 'ORIGINAL') THEN
      RETURN (INVOICE_AMOUNT);
    ELSIF (P_REPORT_CURRENCY_V = 'FUNCTIONAL') THEN
      IF (INVOICE_CURRENCY_CODE = C_BASE_CURRENCY_CODE) THEN
        RETURN (INVOICE_AMOUNT);
      ELSE
        RETURN (INVOICE_BASE_AMOUNT);
      END IF;
    END IF;
    RETURN NULL;
  END CINVOICEACTUALAMOUNT;

  FUNCTION CINVOICEAMOUNTEXEMPT(INVOICE_ID IN NUMBER
                               ,INVOICE_CURRENCY_CODE IN VARCHAR2) RETURN NUMBER IS
    CURSOR C_AMOUNTS IS
      SELECT
        SUM(AMOUNT) AMOUNT,
        SUM(BASE_AMOUNT) BASE_AMOUNT
      FROM
        AP_INVOICE_DISTRIBUTIONS
      WHERE ( INVOICE_ID = CINVOICEAMOUNTEXEMPT.INVOICE_ID )
        AND ( LINE_TYPE_LOOKUP_CODE <> 'AWT' )
        AND ( AWT_GROUP_ID is null );
    AMOUNT NUMBER;
    BASE_AMOUNT NUMBER;
  BEGIN
    OPEN C_AMOUNTS;
    FETCH C_AMOUNTS
     INTO AMOUNT,BASE_AMOUNT;
    CLOSE C_AMOUNTS;
    IF (P_REPORT_CURRENCY_V = 'ORIGINAL') THEN
      RETURN (AMOUNT);
    ELSIF (P_REPORT_CURRENCY_V = 'FUNCTIONAL') THEN
      IF (INVOICE_CURRENCY_CODE = C_BASE_CURRENCY_CODE) THEN
        RETURN (AMOUNT);
      ELSE
        RETURN (BASE_AMOUNT);
      END IF;
    END IF;
    RETURN NULL;
  END CINVOICEAMOUNTEXEMPT;

  FUNCTION CGLDISTPOSTEDSTATUS(ACCRUAL_POSTED_FLAG IN VARCHAR2
                              ,CASH_POSTED_FLAG IN VARCHAR2) RETURN VARCHAR2 IS
    LINE_STATUS VARCHAR2(8);
  BEGIN
    IF (P_SYSTEM_ACCT_METHOD = 'ACCRUAL') THEN
      IF (ACCRUAL_POSTED_FLAG = 'Y') THEN
        LINE_STATUS := 'POSTED';
      ELSE
        LINE_STATUS := 'UNPOSTED';
      END IF;
    ELSIF (P_SYSTEM_ACCT_METHOD = 'CASH') THEN
      IF (CASH_POSTED_FLAG = 'Y') THEN
        LINE_STATUS := 'POSTED';
      ELSIF (CASH_POSTED_FLAG = 'P') THEN
        LINE_STATUS := 'PARTIAL';
      ELSE
        LINE_STATUS := 'UNPOSTED';
      END IF;
    ELSIF (P_SYSTEM_ACCT_METHOD = 'BOTH') THEN
      DECLARE
        MIXED_CASE VARCHAR2(2) := NVL(ACCRUAL_POSTED_FLAG
           ,'N') || NVL(CASH_POSTED_FLAG
           ,'N');
      BEGIN
        IF (MIXED_CASE = 'NN') THEN
          LINE_STATUS := 'UNPOSTED';
        ELSIF (MIXED_CASE = 'YY') THEN
          LINE_STATUS := 'POSTED';
        ELSE
          LINE_STATUS := 'PARTIAL';
        END IF;
      END;
    END IF;
    RETURN (LINE_STATUS);
  END CGLDISTPOSTEDSTATUS;

  FUNCTION CACTUALAMOUNTSUBJECT(AMOUNT_SUBJECT_TO_TAX IN NUMBER
                               ,ACTUAL_CURRENCY_CODE IN VARCHAR2
                               ,INVOICE_CURRENCY_CODE IN VARCHAR2
                               ,INVOICE_EXCHANGE_RATE IN NUMBER) RETURN NUMBER IS
    AMOUNT NUMBER;
  BEGIN
    IF (P_REPORT_CURRENCY_V = 'ORIGINAL') THEN
      AMOUNT := AP_ROUND_CURRENCY(AMOUNT_SUBJECT_TO_TAX
                                 ,ACTUAL_CURRENCY_CODE);
      RETURN (AMOUNT);
    ELSIF (P_REPORT_CURRENCY_V = 'FUNCTIONAL') THEN
      IF (INVOICE_CURRENCY_CODE = C_BASE_CURRENCY_CODE) THEN
        RETURN (AMOUNT_SUBJECT_TO_TAX);
      ELSE
        DECLARE
          BASE_AMOUNT_SUBJECT NUMBER := AMOUNT_SUBJECT_TO_TAX * INVOICE_EXCHANGE_RATE;
        BEGIN
          IF (C_BASE_MIN_ACCT_UNIT IS NULL) THEN
            BASE_AMOUNT_SUBJECT := ROUND(BASE_AMOUNT_SUBJECT
                                        ,C_BASE_PRECISION);
          ELSE
            BASE_AMOUNT_SUBJECT := ROUND(BASE_AMOUNT_SUBJECT / C_BASE_MIN_ACCT_UNIT) * C_BASE_MIN_ACCT_UNIT;
          END IF;
          RETURN (BASE_AMOUNT_SUBJECT);
        END;
      END IF;
    END IF;
    RETURN NULL;
  END CACTUALAMOUNTSUBJECT;

  FUNCTION CACTUALTAXAMOUNT(TAX_AMOUNT IN NUMBER
                           ,ACTUAL_CURRENCY_CODE IN VARCHAR2
                           ,INVOICE_CURRENCY_CODE IN VARCHAR2
                           ,TAX_BASE_AMOUNT IN NUMBER) RETURN NUMBER IS
    AMOUNT NUMBER;
  BEGIN
    IF (P_REPORT_CURRENCY_V = 'ORIGINAL') THEN
      AMOUNT := AP_ROUND_CURRENCY(TAX_AMOUNT
                                 ,ACTUAL_CURRENCY_CODE);
      RETURN (-AMOUNT);
    ELSIF (P_REPORT_CURRENCY_V = 'FUNCTIONAL') THEN
      IF (INVOICE_CURRENCY_CODE = C_BASE_CURRENCY_CODE) THEN
        RETURN (-TAX_AMOUNT);
      ELSE
        AMOUNT := AP_ROUND_CURRENCY(TAX_BASE_AMOUNT
                                   ,ACTUAL_CURRENCY_CODE);
        RETURN (-AMOUNT);
      END IF;
    END IF;
    RETURN NULL;
  END CACTUALTAXAMOUNT;

  FUNCTION CPAYMENTAMOUNT(INVOICE_ID_V IN NUMBER
                         ,BREAK_AWT_PAYMENT_ID IN NUMBER
                         ,ACTUAL_CURRENCY_CODE IN VARCHAR2
                         ,INVOICE_CURRENCY_CODE IN VARCHAR2) RETURN NUMBER IS
    CURSOR C_PAYMENT IS
      SELECT
        SUM(AIP.AMOUNT / AI.PAYMENT_CROSS_RATE) AMOUNT,
        SUM(AIP.PAYMENT_BASE_AMOUNT) BASE_AMOUNT
      FROM
        AP_INVOICE_PAYMENTS AIP,
        AP_INVOICES AI
      WHERE ( AI.INVOICE_ID = INVOICE_ID_V )
        AND ( AI.INVOICE_ID = AIP.INVOICE_ID )
        AND ( AIP.INVOICE_PAYMENT_ID = NVL(BREAK_AWT_PAYMENT_ID
         ,AIP.INVOICE_PAYMENT_ID) );
    AMOUNT NUMBER;
    BASE_AMOUNT NUMBER;
  BEGIN
    OPEN C_PAYMENT;
    FETCH C_PAYMENT
     INTO AMOUNT,BASE_AMOUNT;
    CLOSE C_PAYMENT;
    IF (P_REPORT_CURRENCY_V = 'ORIGINAL') THEN
      AMOUNT := AP_ROUND_CURRENCY(AMOUNT
                                 ,ACTUAL_CURRENCY_CODE);
      RETURN (AMOUNT);
    ELSIF (P_REPORT_CURRENCY_V = 'FUNCTIONAL') THEN
      IF (INVOICE_CURRENCY_CODE = C_BASE_CURRENCY_CODE) THEN
        RETURN (AMOUNT);
      ELSE
        RETURN (BASE_AMOUNT);
      END IF;
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('999'
                 ,'Error Occured at CPaymentAmount Function')*/NULL;
      /*SRW.MESSAGE('999'
                 ,SQLERRM)*/NULL;
      RETURN NULL;
  END CPAYMENTAMOUNT;

  FUNCTION CDISCOUNTAMOUNT(INVOICE_ID_V IN NUMBER
                          ,BREAK_AWT_PAYMENT_ID IN NUMBER
                          ,INVOICE_CURRENCY_CODE IN VARCHAR2
                          ,INVOICE_EXCHANGE_RATE IN NUMBER) RETURN NUMBER IS
    CURSOR C_DISCOUNT IS
      SELECT
        SUM(AIP.DISCOUNT_TAKEN / AI.PAYMENT_CROSS_RATE) DISCOUNT
      FROM
        AP_INVOICE_PAYMENTS AIP,
        AP_INVOICES AI
      WHERE ( AI.INVOICE_ID = INVOICE_ID_V )
        AND ( AI.INVOICE_ID = AIP.INVOICE_ID )
        AND ( AIP.INVOICE_PAYMENT_ID = NVL(BREAK_AWT_PAYMENT_ID
         ,AIP.INVOICE_PAYMENT_ID) );
    DISCOUNT_TAKEN NUMBER;
  BEGIN
    OPEN C_DISCOUNT;
    FETCH C_DISCOUNT
     INTO DISCOUNT_TAKEN;
    CLOSE C_DISCOUNT;
    IF (P_REPORT_CURRENCY_V = 'ORIGINAL') THEN
      RETURN (DISCOUNT_TAKEN);
    ELSIF (P_REPORT_CURRENCY_V = 'FUNCTIONAL') THEN
      IF (INVOICE_CURRENCY_CODE = C_BASE_CURRENCY_CODE) THEN
        RETURN (DISCOUNT_TAKEN);
      ELSE
        DECLARE
          BASE_DISCOUNT NUMBER := DISCOUNT_TAKEN * INVOICE_EXCHANGE_RATE;
        BEGIN
          IF (C_BASE_MIN_ACCT_UNIT IS NULL) THEN
            BASE_DISCOUNT := ROUND(BASE_DISCOUNT
                                  ,C_BASE_PRECISION);
          ELSE
            BASE_DISCOUNT := ROUND(BASE_DISCOUNT / C_BASE_MIN_ACCT_UNIT) * C_BASE_MIN_ACCT_UNIT;
          END IF;
          RETURN (BASE_DISCOUNT);
        END;
      END IF;
    END IF;
    RETURN NULL;
  END CDISCOUNTAMOUNT;

  FUNCTION CLASTPAYMENTDATE(INVOICE_ID IN NUMBER
                           ,BREAK_AWT_PAYMENT_ID IN NUMBER) RETURN DATE IS
    CURSOR C_PAYMENT_DATE IS
      SELECT
        C.CHECK_DATE PAYMENT_DATE
      FROM
        AP_CHECKS C,
        AP_INVOICE_PAYMENTS P
      WHERE ( C.CHECK_ID = P.CHECK_ID )
        AND ( P.INVOICE_ID = CLASTPAYMENTDATE.INVOICE_ID )
        AND ( P.INVOICE_PAYMENT_ID = NVL(BREAK_AWT_PAYMENT_ID
         ,P.INVOICE_PAYMENT_ID) )
      ORDER BY
        C.CHECK_DATE;
    PAYMENT_DATE DATE;
  BEGIN
    OPEN C_PAYMENT_DATE;
    FETCH C_PAYMENT_DATE
     INTO PAYMENT_DATE;
    IF (C_PAYMENT_DATE%NOTFOUND) THEN
      PAYMENT_DATE := NULL;
    END IF;
    CLOSE C_PAYMENT_DATE;
    RETURN (PAYMENT_DATE);
  END CLASTPAYMENTDATE;

  FUNCTION CHECKINVOICECLASSES(C_INVOICE_CLASS IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN (P_INVOICE_CLASSES in ('ENABLED','DISABLED',C_INVOICE_CLASS));
  END CHECKINVOICECLASSES;

  FUNCTION P_AWT_REPORTVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (ACCEPT_PARAMETER('P_AWT_Report'));
    RETURN (TRUE);
  END P_AWT_REPORTVALIDTRIGGER;

  FUNCTION P_FISCAL_YEARVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (ACCEPT_PARAMETER('P_Fiscal_Year'));
    RETURN (TRUE);
  END P_FISCAL_YEARVALIDTRIGGER;

  FUNCTION P_DATE_FROMVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (ACCEPT_PARAMETER('P_Date_From'));
    RETURN (TRUE);
  END P_DATE_FROMVALIDTRIGGER;

  FUNCTION P_DATE_TOVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (ACCEPT_PARAMETER('P_Date_To'));
    RETURN (TRUE);
  END P_DATE_TOVALIDTRIGGER;

  FUNCTION P_TAX_AUTH_SITE_IDVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (ACCEPT_PARAMETER('P_Tax_Auth_Site_Id'));
    RETURN (TRUE);
  END P_TAX_AUTH_SITE_IDVALIDTRIGGER;

  FUNCTION P_CHECKRUN_NAMEVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (ACCEPT_PARAMETER('P_Checkrun_Name'));
    RETURN (TRUE);
  END P_CHECKRUN_NAMEVALIDTRIGGER;

  FUNCTION P_TAX_NAMEVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (ACCEPT_PARAMETER('P_Tax_Name'));
    RETURN (TRUE);
  END P_TAX_NAMEVALIDTRIGGER;

  FUNCTION P_SUPPLIER_IDVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (ACCEPT_PARAMETER('P_Supplier_Id'));
    RETURN (TRUE);
  END P_SUPPLIER_IDVALIDTRIGGER;

  FUNCTION P_SUPPLIER_FROMVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (ACCEPT_PARAMETER('P_Supplier_From'));
    RETURN (TRUE);
  END P_SUPPLIER_FROMVALIDTRIGGER;

  FUNCTION P_SUPPLIER_TOVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (ACCEPT_PARAMETER('P_Supp_Num_To'));
    RETURN (TRUE);
  END P_SUPPLIER_TOVALIDTRIGGER;

  FUNCTION P_SUPP_NUM_FROMVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (ACCEPT_PARAMETER('P_Supp_Num_From'));
    RETURN (TRUE);
  END P_SUPP_NUM_FROMVALIDTRIGGER;

  FUNCTION P_SUPP_NUM_TOVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (ACCEPT_PARAMETER('P_Supp_Num_To'));
    RETURN (TRUE);
  END P_SUPP_NUM_TOVALIDTRIGGER;

  FUNCTION P_REPORT_CURRENCYVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (ACCEPT_PARAMETER('P_Report_Currency'));
    RETURN (TRUE);
  END P_REPORT_CURRENCYVALIDTRIGGER;

  FUNCTION P_INVOICE_CLASSESVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (ACCEPT_PARAMETER('P_Invoice_Classes'));
    RETURN (TRUE);
  END P_INVOICE_CLASSESVALIDTRIGGER;

  FUNCTION P_POSTED_STATUSVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (ACCEPT_PARAMETER('P_Posted_Status'));
    RETURN (TRUE);
  END P_POSTED_STATUSVALIDTRIGGER;

  FUNCTION P_CERT_EXPIRE_FROMVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (ACCEPT_PARAMETER('P_Cert_Expire_From'));
    RETURN (TRUE);
  END P_CERT_EXPIRE_FROMVALIDTRIGGER;

  FUNCTION P_CERT_EXPIRE_TOVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (ACCEPT_PARAMETER('P_Cert_Expire_To'));
    RETURN (TRUE);
  END P_CERT_EXPIRE_TOVALIDTRIGGER;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
  SET_P_AWT_REPORT;
    DECLARE
      INIT_FAILURE EXCEPTION;
      temp boolean;
    BEGIN

    temp:=beforepform;
    P_REPORT_CURRENCY_V:=P_REPORT_CURRENCY;

      IF (CUSTOM_INIT <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('0'
                   ,'After Custom_Init placed in AFTER FORM')*/NULL;
      END IF;
      temp:=P_AWT_REPORTVALIDTRIGGER;
      temp:=P_FISCAL_YEARVALIDTRIGGER;
      temp:=P_DATE_FROMVALIDTRIGGER;
      temp:=P_DATE_TOVALIDTRIGGER;
      temp:=P_TAX_AUTH_SITE_IDVALIDTRIGGER;
      temp:=P_CHECKRUN_NAMEVALIDTRIGGER;
      temp:=P_TAX_NAMEVALIDTRIGGER;
      temp:=P_SUPPLIER_IDVALIDTRIGGER;
      temp:=P_SUPPLIER_FROMVALIDTRIGGER;
      temp:=P_SUPPLIER_TOVALIDTRIGGER;
      temp:=P_SUPP_NUM_FROMVALIDTRIGGER;
      temp:=P_SUPP_NUM_TOVALIDTRIGGER;
      temp:=P_REPORT_CURRENCYVALIDTRIGGER;
      temp:=P_INVOICE_CLASSESVALIDTRIGGER;
      temp:=P_POSTED_STATUSVALIDTRIGGER;
      temp:=P_CERT_EXPIRE_FROMVALIDTRIGGER;
      temp:=P_CERT_EXPIRE_TOVALIDTRIGGER;

    EXCEPTION
      WHEN OTHERS THEN
	null;
      --  /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;

    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION FORDERBY RETURN VARCHAR2 IS
    RET_TEXT VARCHAR2(1000);
  BEGIN
    RET_TEXT := 'order' || '
                           ' || 'by     :P_Tax_Authority_Name' || '
                           ' || ',      :P_Tax_Authority_Site_Code' || '
                           ' || ',      supplier.vendor_name' || '
                           ' || ',      decode(:P_AWT_Report' || '
                           ' || '             ,''AWT4''' || '
                           ' || '             ,t.tax_name' || '
                           ' || '             ,null' || '
                           ' || '             )' || '
                           ' || ',      i.invoice_date' || '
                           ' || ',      d.accounting_date';
    RETURN (RET_TEXT);
  END FORDERBY;

  FUNCTION FRESTRICTCERTIFICATES RETURN VARCHAR2 IS
    RET_TEXT VARCHAR2(1000);
  BEGIN
  RET_TEXT:=' ';
    IF ((P_AWT_REPORT = 'AWT6') OR ((P_CERT_EXPIRE_FROM IS NOT NULL) AND (P_CERT_EXPIRE_TO IS NOT NULL))) THEN
      RET_TEXT := 'and    t.rate_type             = ''CERTIFICATE''';
    END IF;
    RETURN (RET_TEXT);
  END FRESTRICTCERTIFICATES;

  FUNCTION FCERTEXPIRATIONRANGE RETURN VARCHAR2 IS
    RET_TEXT VARCHAR2(1000);
  BEGIN
  RET_TEXT:=' ';
    IF ((P_CERT_EXPIRE_FROM IS NOT NULL) AND (P_CERT_EXPIRE_TO IS NOT NULL)) THEN
      RET_TEXT := 'and    t.end_date              between ' || ':P_Cert_Expire_From' || '
                               ' || '                                   and :P_Cert_Expire_To';
    END IF;
    RETURN (RET_TEXT);
  END FCERTEXPIRATIONRANGE;

  FUNCTION FGLPOSTEDSTATUS RETURN VARCHAR2 IS
    RET_TEXT VARCHAR2(2000);
    IN_CLAUSE VARCHAR2(240);
    CURSOR C_CASH_BASIS_FLAG IS
      SELECT
        NVL(SLA_LEDGER_CASH_BASIS_FLAG
           ,'N')
      FROM
        AP_SYSTEM_PARAMETERS ASP,
        GL_SETS_OF_BOOKS GLSOB
      WHERE ASP.SET_OF_BOOKS_ID = GLSOB.SET_OF_BOOKS_ID;
    L_CASH_BASIS_FLAG VARCHAR2(1);
  BEGIN
  RET_TEXT:=' ';
    OPEN C_CASH_BASIS_FLAG;
    FETCH C_CASH_BASIS_FLAG
     INTO L_CASH_BASIS_FLAG;
    CLOSE C_CASH_BASIS_FLAG;
    IF (L_CASH_BASIS_FLAG = 'Y') THEN
      P_SYSTEM_ACCT_METHOD := 'CASH';
    ELSE
      P_SYSTEM_ACCT_METHOD := 'ACCRUAL';
    END IF;
    IF (P_POSTED_STATUS = 'ITEMS_POSTED') THEN
      IF (P_SYSTEM_ACCT_METHOD = 'ACCRUAL') THEN
        RET_TEXT := 'and    not exists (select ''Unposted Item''' || '
                                 ' || '                   from   ap_invoice_distributions sub ' || '
                                 ' || '                   where  sub.invoice_id = d.invoice_id' || '
                                 ' || '                   and    sub.line_type_lookup_code = ''ITEM''
                                 ' || '                   and    sub.posted_flag <>''Y'')';
      ELSE
        RET_TEXT := 'and    not exists (select ''Unposted Item''' || '
                                 ' || '                   from   ap_invoice_payments aip, ' || '
                                 ' || '                          ap_payment_history  aph ' || '
                                 ' || '                   where  aip.invoice_id = d.invoice_id' || '
                                 ' || '                   and    aip.check_id = aph.check_id' || '
                                 ' || '                   and    (aip.posted_flag <> ''Y''' || '
                                 ' || '                           or aph.posted_flag <> ''Y'')' || '
                                 ' || '                   union                   ' || '
                                 ' || '                   select ''Unposted Item''' || '
                                 ' || '                   from   ap_prepay_history apph
                                 ' || '                   where  apph.invoice_id = d.invoice_id' || '
                                 ' || '                   and    apph.posted_flag <> ''Y'')';
      END IF;
    ELSIF (P_POSTED_STATUS = 'ITEMS_PARTIALLY_POSTED') THEN
      IF (P_SYSTEM_ACCT_METHOD = 'ACCRUAL') THEN
        RET_TEXT := 'and    exists (select ''Posted Item''' || '
                                 ' || '                 from   ap_invoice_distributions sub ' || '
                                 ' || '                 where  sub.invoice_id = d.invoice_id' || '
                                 ' || '                 and    sub.line_type_lookup_code = ''ITEM''' || '
                                 ' || '                 and    sub.posted_flag =''Y''' || '
                                 ' || '                )' || '
                                 ' || '   and   exists (select ''Unposted Item''' || '
                                 ' || '                 from   ap_invoice_distributions sub ' || '
                                 ' || '                 where  sub.invoice_id = d.invoice_id' || '
                                 ' || '                 and    sub.line_type_lookup_code = ''ITEM''' || '
                                 ' || '                 and    sub.posted_flag <>''Y''' || '
                                 ' || '                )';
      ELSE
        RET_TEXT := 'and    exists (select ''Posted Payment''' || '
                                 ' || '                  from   ap_invoice_payments aip,' || '
                                 ' || '                         ap_payment_history  aph' || '
                                 ' || '                  where  aip.invoice_id = d.invoice_id' || '
                                 ' || '                  and    aip.check_id = aph.check_id' || '
                                 ' || '                  and    aip.posted_flag = ''Y''' || '
                                 ' || '                  and    aph.posted_flag = ''Y''' || '
                                 ' || '                  union                      ' || '
                                 ' || '                  select ''Posted Item''' || '
                                 ' || '                  from   ap_prepay_history aph' || '
                                 ' || '                  where  aph.invoice_id = d.invoice_id' || '
                                 ' || '                  and    aph.posted_flag = ''Y'')' || '
                                 ' || '   and    exists (select ''Unposted Payment''' || '
                                 ' || '                  from   ap_invoice_payments aip,' || '
                                 ' || '                         ap_payment_history  aph' || '
                                 ' || '                  where aip.invoice_id = d.invoice_id' || '
                                 ' || '                  and   aip.check_id = aph.check_id' || '
                                 ' || '                  and   (aip.posted_flag<>''Y''' || '
                                 ' || '                         or aph.posted_flag<>''Y'')' || '
                                 ' || '                  union                         ' || '
                                 ' || '                  select ''Unposted Prepayment''' || '
                                 ' || '                  from   ap_prepay_history aph' || '
                                 ' || '                  where  aph.invoice_id = d.invoice_id' || '
                                 ' || '                  and    aph.posted_flag <>''Y'')';
      END IF;
    ELSIF (P_POSTED_STATUS = 'ITEMS_UNPOSTED') THEN
      IF (P_SYSTEM_ACCT_METHOD = 'ACCRUAL') THEN
        RET_TEXT := 'and    not exists (select ''Posted Item''' || '
                                 ' || '                   from   ap_invoice_distributions sub ' || '
                                 ' || '                   where  sub.invoice_id = d.invoice_id' || '
                                 ' || '                   and    sub.line_type_lookup_code = ''ITEM''' || '
                                 ' || '                   and    sub.posted_flag = ''Y''' || '
                                 ' || '              )';
      ELSE
        RET_TEXT := 'and    not exists (select ''Posted Payment''' || '
                                 ' || '                  from   ap_invoice_payments aip,' || '
                                 ' || '                         ap_payment_history  aph' || '
                                 ' || '                  where aip.invoice_id = d.invoice_id' || '
                                 ' || '                  and   aip.check_id = aph.check_id' || '
                                 ' || '                  and   (aip.posted_flag=''Y''' || '
                                 ' || '                         or aph.posted_flag=''Y'')' || '
                                 ' || '                  union
                                 ' || '                  select ''posted Prepayment''' || '
                                 ' || '                  from   ap_prepay_history aph' || '
                                 ' || '                  where  aph.invoice_id = d.invoice_id' || '
                                 ' || '                  and    aph.posted_flag =''Y'')';
      END IF;
    ELSE
      RET_TEXT := ' ';
    END IF;
    RETURN (RET_TEXT);
  END FGLPOSTEDSTATUS;

  FUNCTION FSELECTEDSUPPLIERS RETURN VARCHAR2 IS
    RET_TEXT VARCHAR2(1000);
  BEGIN
  RET_TEXT:=' ';
    IF (P_SUPPLIER_ID IS NOT NULL) THEN
      RET_TEXT := 'and    supplier.vendor_id      =       :P_Supplier_Id';
    ELSE
      IF ((P_SUPPLIER_FROM_V IS NOT NULL) OR (P_SUPPLIER_TO_V IS NOT NULL)) THEN
        RET_TEXT := 'and    supplier.vendor_name    between nvl(:P_SUPPLIER_FROM_V' || '
                                 ' || '                                          ,supplier.vendor_name)' || '
                                 ' || '                                   and nvl(:P_SUPPLIER_TO_V' || '
                                 ' || '                                          ,supplier.vendor_name)';
      END IF;
      IF ((P_SUPP_NUM_FROM IS NOT NULL) OR (P_SUPP_NUM_TO IS NOT NULL)) THEN
        DECLARE
          CURSOR C_MANUAL_VENDOR_NUMBER_TYPE IS
            SELECT
              SUPPLIER_NUM_TYPE
            FROM
              AP_PRODUCT_SETUP;
          MAN_VEND_NUM_TYPE AP_PRODUCT_SETUP.SUPPLIER_NUM_TYPE%TYPE;
          SUP_NUM VARCHAR2(2000) := 'supplier.segment1';
          NUM_FROM VARCHAR2(2000) := 'nvl(:P_Supp_Num_From, supplier.segment1)';
          NUM_TO VARCHAR2(2000) := 'nvl(:P_Supp_Num_To, supplier.segment1)';
        BEGIN
          OPEN C_MANUAL_VENDOR_NUMBER_TYPE;
          FETCH C_MANUAL_VENDOR_NUMBER_TYPE
           INTO MAN_VEND_NUM_TYPE;
          CLOSE C_MANUAL_VENDOR_NUMBER_TYPE;
          IF (MAN_VEND_NUM_TYPE = 'NUMERIC') THEN
            SUP_NUM := 'to_number(' || SUP_NUM || ')';
            NUM_FROM := 'to_number(' || NUM_FROM || ')';
            NUM_TO := 'to_number(' || NUM_TO || ')';
          END IF;
          RET_TEXT := 'and  ' || SUP_NUM || ' between ' || NUM_FROM || ' and ' || NUM_TO;
        END;
      END IF;
    END IF;
    RETURN (RET_TEXT);
  END FSELECTEDSUPPLIERS;

  FUNCTION FRESTRICTTOPAIDDISTS RETURN VARCHAR2 IS
    RET_TEXT VARCHAR2(1000);
  BEGIN
  RET_TEXT:='AND 2=2 ';
    IF (P_AWT_REPORT = 'AWT2') THEN
      RET_TEXT := 'and    d.awt_invoice_payment_id           is not null';
    END IF;
    RETURN (RET_TEXT);
  END FRESTRICTTOPAIDDISTS;

  FUNCTION FRESTRICTTOCHECKRUNNAME RETURN VARCHAR2 IS
    RET_TEXT VARCHAR2(1000);
  BEGIN
  RET_TEXT:=' ';
    IF ((P_CHECKRUN_NAME IS NOT NULL) AND (P_AWT_REPORT in ('AWT4','AWT5'))) THEN
      RET_TEXT := 'and    exists' || '
                               ' || '       (' || '
                               ' || '       select ''Distribution already paid to ' || 'the tax authority''' || '
                               ' || '       from   ap_invoice_payments' || '           t_auth_payments' || '
                               ' || '       ,      ap_checks          ' || '           t_auth_checks' || '
                               ' || '       where  t_auth_checks.checkrun_name = ' || ':P_Checkrun_Name' || '
                               ' || '       and    t_auth_checks.check_id      = ' || 't_auth_payments.check_id' || '
                               ' || '       and    d.awt_invoice_id            = ' || 't_auth_payments.invoice_id' || '
                               ' || '       )';
    END IF;
    RETURN (RET_TEXT);
  END FRESTRICTTOCHECKRUNNAME;

  FUNCTION FSELECTTAXAUTHORITY RETURN VARCHAR2 IS
    RET_TEXT VARCHAR2(1000);
  BEGIN
  RET_TEXT:=' ';
    IF (P_AWT_REPORT in ('AWT4','AWT5')) THEN
      IF P_TAX_AUTHORITY_ID IS NOT NULL AND P_TAX_AUTH_SITE_ID IS NOT NULL THEN
        RET_TEXT := ' and n.awt_vendor_id = :P_Tax_Authority_Id ' || ' and n.awt_vendor_site_id = :P_Tax_Auth_Site_Id ';
      ELSIF P_TAX_AUTHORITY_ID IS NOT NULL AND P_TAX_AUTH_SITE_ID IS NULL THEN
        RET_TEXT := ' and n.awt_vendor_id = :P_Tax_Authority_Id ';
      ELSIF P_TAX_AUTHORITY_ID IS NULL AND P_TAX_AUTH_SITE_ID IS NOT NULL THEN
        RET_TEXT := ' and n.awt_vendor_site_id = :P_Tax_Auth_Site_Id ';
      ELSIF P_TAX_AUTHORITY_ID IS NULL AND P_TAX_AUTH_SITE_ID IS NULL THEN
        RET_TEXT := ' and 1 = 1 ';
      END IF;
    END IF;
    RETURN (RET_TEXT);
  END FSELECTTAXAUTHORITY;

  FUNCTION FTAXAUTHORITYJOINS RETURN VARCHAR2 IS
    RET_TEXT VARCHAR2(1000);
  BEGIN
  RET_TEXT:=' ';
    IF (P_AWT_REPORT in ('AWT4','AWT5')) THEN
      RET_TEXT := 'and    n.awt_vendor_id         = ' || 'tax_auth_site.vendor_id' || '
                               ' || 'and    n.awt_vendor_site_id    = ' || 'tax_auth_site.vendor_site_id' || '
                               ' || 'and    n.awt_vendor_id         = tax_auth.vendor_id';
    END IF;
    RETURN (RET_TEXT);
  END FTAXAUTHORITYJOINS;

  FUNCTION FTAXAUTHORITYTABLES RETURN VARCHAR2 IS
    RET_TEXT VARCHAR2(1000);
  BEGIN
  RET_TEXT:=' ';
    IF (P_AWT_REPORT in ('AWT4','AWT5')) THEN
      RET_TEXT := ',      po_vendors               tax_auth' || '
                               ' || ',      po_vendor_sites          tax_auth_site';
    END IF;
    RETURN (RET_TEXT);
  END FTAXAUTHORITYTABLES;

  FUNCTION CAWTSETUP RETURN VARCHAR2 IS
    CURSOR C_SYSTEM_OPTIONS IS
      SELECT
        CREATE_AWT_DISTS_TYPE
      FROM
        AP_SYSTEM_PARAMETERS;
    RET VARCHAR2(25);
  BEGIN
    OPEN C_SYSTEM_OPTIONS;
    FETCH C_SYSTEM_OPTIONS
     INTO RET;
    CLOSE C_SYSTEM_OPTIONS;
    RETURN (RET);
  END CAWTSETUP;

  FUNCTION CINVOICEFIRSTACCTDATE(INVOICE_ID IN NUMBER) RETURN DATE IS
    CURSOR C_ITEM_DATE IS
      SELECT
        MIN(ACCOUNTING_DATE)
      FROM
        AP_INVOICE_DISTRIBUTIONS
      WHERE INVOICE_ID = INVOICE_ID
        AND LINE_TYPE_LOOKUP_CODE = 'ITEM';
    FIRST_ACCOUNTING_DATE AP_INVOICE_DISTRIBUTIONS.ACCOUNTING_DATE%TYPE;
  BEGIN
    OPEN C_ITEM_DATE;
    FETCH C_ITEM_DATE
     INTO FIRST_ACCOUNTING_DATE;
    CLOSE C_ITEM_DATE;
    RETURN (FIRST_ACCOUNTING_DATE);
  END CINVOICEFIRSTACCTDATE;

  FUNCTION CLASTPAYMENTDOC(INVOICE_ID IN NUMBER
                          ,BREAK_AWT_PAYMENT_ID IN NUMBER) RETURN NUMBER IS
    CURSOR C_PAYMENT_DOC IS
      SELECT
        C.CHECK_NUMBER PAYMENT_DOC
      FROM
        AP_CHECKS C,
        AP_INVOICE_PAYMENTS P
      WHERE ( C.CHECK_ID = P.CHECK_ID )
        AND ( P.INVOICE_ID = INVOICE_ID )
        AND ( P.INVOICE_PAYMENT_ID = NVL(BREAK_AWT_PAYMENT_ID
         ,P.INVOICE_PAYMENT_ID) )
      ORDER BY
        C.CHECK_DATE;
    PAYMENT_DOC NUMBER;
  BEGIN
    OPEN C_PAYMENT_DOC;
    FETCH C_PAYMENT_DOC
     INTO PAYMENT_DOC;
    IF (C_PAYMENT_DOC%NOTFOUND) THEN
      PAYMENT_DOC := NULL;
    END IF;
    CLOSE C_PAYMENT_DOC;
    RETURN (PAYMENT_DOC);
  END CLASTPAYMENTDOC;

  FUNCTION LISTCERTTYPEF(LIST_CERT_TYPE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(LIST_CERT_TYPE)*/NULL;
    RETURN (AP_GET_DISPLAYED_FIELD('AWT CERTIFICATE TYPES'
                                 ,LIST_CERT_TYPE));
  END LISTCERTTYPEF;

  --FUNCTION CMINDATEF(C_MIN_DATE IN NUMBER) RETURN DATE IS
  FUNCTION CMINDATEF(C_MIN_DATE IN date) RETURN DATE IS
  BEGIN
    IF (P_DATE_FROM IS NOT NULL) THEN
      RETURN (P_DATE_FROM);
    ELSE
      RETURN (C_MIN_DATE);
    END IF;
    RETURN NULL;
  END CMINDATEF;

  --FUNCTION CMAXDATEF(C_MAX_DATE IN NUMBER) RETURN DATE IS
  FUNCTION CMAXDATEF(C_MAX_DATE IN date) RETURN DATE IS
  BEGIN
    IF (P_DATE_TO IS NOT NULL) THEN
      RETURN (P_DATE_TO);
    ELSE
      RETURN (C_MAX_DATE);
    END IF;
    RETURN NULL;
  END CMAXDATEF;

  FUNCTION CFISCALYEARF(C_MIN_DATE IN date
                       ,C_MAX_DATE IN date) RETURN NUMBER IS
  BEGIN
    IF ((P_FISCAL_YEAR IS NULL) AND (TO_CHAR(C_MIN_DATE
           ,'yyyy') = TO_CHAR(C_MAX_DATE
           ,'yyyy'))) THEN
      RETURN (TO_NUMBER(TO_CHAR(C_MAX_DATE
                              ,'yyyy')));
    ELSE
      RETURN (P_FISCAL_YEAR);
    END IF;
    RETURN NULL;
  END CFISCALYEARF;

  FUNCTION CORIGINALINVTOTAL(S1_PAYMENT_AMOUNT IN NUMBER
                            ,S1_DISCOUNT_AMOUNT IN NUMBER
                            ,S0_ACTUAL_TAX_AMOUNT IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(S1_PAYMENT_AMOUNT
              ,0) + NVL(S1_DISCOUNT_AMOUNT
              ,0) + NVL(S0_ACTUAL_TAX_AMOUNT
              ,0));
  END CORIGINALINVTOTAL;

  FUNCTION AP_WITHHOLDING_TEMPLATE_REPOR RETURN VARCHAR2 IS
  BEGIN
    RETURN AP_WITHHOLDING_TEMPLATE_REPORT;
  END AP_WITHHOLDING_TEMPLATE_REPOR;

  FUNCTION C_NLS_YES_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_YES;
  END C_NLS_YES_P;

  FUNCTION C_NLS_NO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NO;
  END C_NLS_NO_P;

  FUNCTION C_NLS_ALL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_ALL;
  END C_NLS_ALL_P;

  FUNCTION C_NLS_NO_DATA_EXISTS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NO_DATA_EXISTS;
  END C_NLS_NO_DATA_EXISTS_P;

  FUNCTION C_NLS_VOID_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_VOID;
  END C_NLS_VOID_P;

  FUNCTION C_NLS_NA_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NA;
  END C_NLS_NA_P;

  FUNCTION C_NLS_END_OF_REPORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_END_OF_REPORT;
  END C_NLS_END_OF_REPORT_P;

  FUNCTION C_REPORT_START_DATE_P RETURN DATE IS
  BEGIN
    RETURN C_REPORT_START_DATE;
  END C_REPORT_START_DATE_P;

  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMPANY_NAME_HEADER;
  END C_COMPANY_NAME_HEADER_P;

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

  FUNCTION C_BASE_DESCRIPTION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BASE_DESCRIPTION;
  END C_BASE_DESCRIPTION_P;

  FUNCTION C_CHART_OF_ACCOUNTS_ID_P RETURN NUMBER IS
  BEGIN
    RETURN C_CHART_OF_ACCOUNTS_ID;
  END C_CHART_OF_ACCOUNTS_ID_P;

  FUNCTION SANDRO_1995_P RETURN NUMBER IS
  BEGIN
    RETURN SANDRO_1995;
  END SANDRO_1995_P;

  PROCEDURE AP_BEGIN_LOG(P_CALLING_MODULE IN VARCHAR2
                        ,P_MAX_SIZE IN NUMBER) IS
  BEGIN
/*    STPROC.INIT('begin AP_LOGGING_PKG.AP_BEGIN_LOG(:P_CALLING_MODULE, :P_MAX_SIZE); end;');
    STPROC.BIND_I(P_CALLING_MODULE);
    STPROC.BIND_I(P_MAX_SIZE);
    STPROC.EXECUTE;*/
    null;
  END AP_BEGIN_LOG;

  FUNCTION AP_PIPE_NAME RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    /*STPROC.INIT('begin :X0 := AP_LOGGING_PKG.AP_PIPE_NAME; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN X0;
  END AP_PIPE_NAME;

  PROCEDURE AP_PIPE_NAME_23(P_PIPE_NAME OUT NOCOPY VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin AP_LOGGING_PKG.AP_PIPE_NAME_23(:P_PIPE_NAME); end;');
    STPROC.BIND_O(P_PIPE_NAME);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,P_PIPE_NAME);*/null;
  END AP_PIPE_NAME_23;

  FUNCTION AP_LOG_RETURN_CODE RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
    /*STPROC.INIT('begin :X0 := AP_LOGGING_PKG.AP_LOG_RETURN_CODE; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/null;
    RETURN X0;
  END AP_LOG_RETURN_CODE;

  PROCEDURE AP_BEGIN_BLOCK(P_MESSAGE_LOCATION IN VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin AP_LOGGING_PKG.AP_BEGIN_BLOCK(:P_MESSAGE_LOCATION); end;');
    STPROC.BIND_I(P_MESSAGE_LOCATION);
    STPROC.EXECUTE;*/null;
  END AP_BEGIN_BLOCK;

  PROCEDURE AP_END_BLOCK(P_MESSAGE_LOCATION IN VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin AP_LOGGING_PKG.AP_END_BLOCK(:P_MESSAGE_LOCATION); end;');
    STPROC.BIND_I(P_MESSAGE_LOCATION);
    STPROC.EXECUTE;*/null;
  END AP_END_BLOCK;

  PROCEDURE AP_INDENT IS
  BEGIN
   /* STPROC.INIT('begin AP_LOGGING_PKG.AP_INDENT; end;');
    STPROC.EXECUTE;*/null;
  END AP_INDENT;

  PROCEDURE AP_OUTDENT IS
  BEGIN
    /*STPROC.INIT('begin AP_LOGGING_PKG.AP_OUTDENT; end;');
    STPROC.EXECUTE;*/null;
  END AP_OUTDENT;

  PROCEDURE AP_LOG(P_MESSAGE IN VARCHAR2
                  ,P_MESSAGE_LOCATION IN VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin AP_LOGGING_PKG.AP_LOG(:P_MESSAGE, :P_MESSAGE_LOCATION); end;');
    STPROC.BIND_I(P_MESSAGE);
    STPROC.BIND_I(P_MESSAGE_LOCATION);
    STPROC.EXECUTE;*/null;
  END AP_LOG;

  PROCEDURE AP_END_LOG IS
  BEGIN
    /*STPROC.INIT('begin AP_LOGGING_PKG.AP_END_LOG; end;');
    STPROC.EXECUTE;*/null;
  END AP_END_LOG;

  PROCEDURE AP_DO_WITHHOLDING(P_INVOICE_ID IN NUMBER
                             ,P_AWT_DATE IN DATE
                             ,P_CALLING_MODULE IN VARCHAR2
                             ,P_AMOUNT IN NUMBER
                             ,P_PAYMENT_NUM IN NUMBER
                             ,P_CHECKRUN_NAME IN VARCHAR2
                             ,P_LAST_UPDATED_BY IN NUMBER
                             ,P_LAST_UPDATE_LOGIN IN NUMBER
                             ,P_PROGRAM_APPLICATION_ID IN NUMBER
                             ,P_PROGRAM_ID IN NUMBER
                             ,P_REQUEST_ID IN NUMBER
                             ,P_AWT_SUCCESS OUT NOCOPY VARCHAR2
                             ,P_INVOICE_PAYMENT_ID IN NUMBER) IS
  BEGIN
    /*STPROC.INIT('begin AP_WITHHOLDING_PKG.AP_DO_WITHHOLDING(:P_INVOICE_ID, :P_AWT_DATE, :P_CALLING_MODULE, :P_AMOUNT, :P_PAYMENT_NUM,
    :P_CHECKRUN_NAME, :P_LAST_UPDATED_BY, :P_LAST_UPDATE_LOGIN, :P_PROGRAM_APPLICATION_ID, :P_PROGRAM_ID, :P_REQUEST_ID, :P_AWT_SUCCESS,
    :P_INVOICE_PAYMENT_ID); end;');
    STPROC.BIND_I(P_INVOICE_ID);
    STPROC.BIND_I(P_AWT_DATE);
    STPROC.BIND_I(P_CALLING_MODULE);
    STPROC.BIND_I(P_AMOUNT);
    STPROC.BIND_I(P_PAYMENT_NUM);
    STPROC.BIND_I(P_CHECKRUN_NAME);
    STPROC.BIND_I(P_LAST_UPDATED_BY);
    STPROC.BIND_I(P_LAST_UPDATE_LOGIN);
    STPROC.BIND_I(P_PROGRAM_APPLICATION_ID);
    STPROC.BIND_I(P_PROGRAM_ID);
    STPROC.BIND_I(P_REQUEST_ID);
    STPROC.BIND_O(P_AWT_SUCCESS);
    STPROC.BIND_I(P_INVOICE_PAYMENT_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(12
                   ,P_AWT_SUCCESS);*/null;
  END AP_DO_WITHHOLDING;

  PROCEDURE AP_WITHHOLD_AUTOSELECT(P_CHECKRUN_NAME IN VARCHAR2
                                  ,P_LAST_UPDATED_BY IN NUMBER
                                  ,P_LAST_UPDATE_LOGIN IN NUMBER
                                  ,P_PROGRAM_APPLICATION_ID IN NUMBER
                                  ,P_PROGRAM_ID IN NUMBER
                                  ,P_REQUEST_ID IN NUMBER) IS
  BEGIN
    /*STPROC.INIT('begin AP_WITHHOLDING_PKG.AP_WITHHOLD_AUTOSELECT(:P_CHECKRUN_NAME, :P_LAST_UPDATED_BY, :P_LAST_UPDATE_LOGIN,
    :P_PROGRAM_APPLICATION_ID, :P_PROGRAM_ID, :P_REQUEST_ID); end;');
    STPROC.BIND_I(P_CHECKRUN_NAME);
    STPROC.BIND_I(P_LAST_UPDATED_BY);
    STPROC.BIND_I(P_LAST_UPDATE_LOGIN);
    STPROC.BIND_I(P_PROGRAM_APPLICATION_ID);
    STPROC.BIND_I(P_PROGRAM_ID);
    STPROC.BIND_I(P_REQUEST_ID);
    STPROC.EXECUTE;*/null;
  END AP_WITHHOLD_AUTOSELECT;

  PROCEDURE AP_WITHHOLD_CONFIRM(P_CHECKRUN_NAME IN VARCHAR2
                               ,P_LAST_UPDATED_BY IN NUMBER
                               ,P_LAST_UPDATE_LOGIN IN NUMBER
                               ,P_PROGRAM_APPLICATION_ID IN NUMBER
                               ,P_PROGRAM_ID IN NUMBER
                               ,P_REQUEST_ID IN NUMBER) IS
  BEGIN
   /* STPROC.INIT('begin AP_WITHHOLDING_PKG.AP_WITHHOLD_CONFIRM(:P_CHECKRUN_NAME, :P_LAST_UPDATED_BY, :P_LAST_UPDATE_LOGIN,
   :P_PROGRAM_APPLICATION_ID, :P_PROGRAM_ID, :P_REQUEST_ID); end;');
    STPROC.BIND_I(P_CHECKRUN_NAME);
    STPROC.BIND_I(P_LAST_UPDATED_BY);
    STPROC.BIND_I(P_LAST_UPDATE_LOGIN);
    STPROC.BIND_I(P_PROGRAM_APPLICATION_ID);
    STPROC.BIND_I(P_PROGRAM_ID);
    STPROC.BIND_I(P_REQUEST_ID);
    STPROC.EXECUTE;*/null;
  END AP_WITHHOLD_CONFIRM;

  PROCEDURE AP_WITHHOLD_CANCEL(P_CHECKRUN_NAME IN VARCHAR2
                              ,P_LAST_UPDATED_BY IN NUMBER
                              ,P_LAST_UPDATE_LOGIN IN NUMBER
                              ,P_PROGRAM_APPLICATION_ID IN NUMBER
                              ,P_PROGRAM_ID IN NUMBER
                              ,P_REQUEST_ID IN NUMBER) IS
  BEGIN
    /*STPROC.INIT('begin AP_WITHHOLDING_PKG.AP_WITHHOLD_CANCEL(:P_CHECKRUN_NAME, :P_LAST_UPDATED_BY, :P_LAST_UPDATE_LOGIN,
    :P_PROGRAM_APPLICATION_ID, :P_PROGRAM_ID, :P_REQUEST_ID); end;');
    STPROC.BIND_I(P_CHECKRUN_NAME);
    STPROC.BIND_I(P_LAST_UPDATED_BY);
    STPROC.BIND_I(P_LAST_UPDATE_LOGIN);
    STPROC.BIND_I(P_PROGRAM_APPLICATION_ID);
    STPROC.BIND_I(P_PROGRAM_ID);
    STPROC.BIND_I(P_REQUEST_ID);
    STPROC.EXECUTE;*/null;
  END AP_WITHHOLD_CANCEL;

  PROCEDURE AP_UNDO_TEMP_WITHHOLDING(P_INVOICE_ID IN NUMBER
                                    ,P_VENDOR_ID IN NUMBER
                                    ,P_PAYMENT_NUM IN NUMBER
                                    ,P_CHECKRUN_NAME IN VARCHAR2
                                    ,P_UNDO_AWT_DATE IN DATE
                                    ,P_CALLING_MODULE IN VARCHAR2
                                    ,P_LAST_UPDATED_BY IN NUMBER
                                    ,P_LAST_UPDATE_LOGIN IN NUMBER
                                    ,P_PROGRAM_APPLICATION_ID IN NUMBER
                                    ,P_PROGRAM_ID IN NUMBER
                                    ,P_REQUEST_ID IN NUMBER
                                    ,P_AWT_SUCCESS OUT NOCOPY VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin AP_WITHHOLDING_PKG.AP_UNDO_TEMP_WITHHOLDING(:P_INVOICE_ID, :P_VENDOR_ID, :P_PAYMENT_NUM, :P_CHECKRUN_NAME,
    :P_UNDO_AWT_DATE, :P_CALLING_MODULE, :P_LAST_UPDATED_BY, :P_LAST_UPDATE_LOGIN, :P_PROGRAM_APPLICATION_ID, :P_PROGRAM_ID, :P_REQUEST_ID,
    :P_AWT_SUCCESS); end;');
    STPROC.BIND_I(P_INVOICE_ID);
    STPROC.BIND_I(P_VENDOR_ID);
    STPROC.BIND_I(P_PAYMENT_NUM);
    STPROC.BIND_I(P_CHECKRUN_NAME);
    STPROC.BIND_I(P_UNDO_AWT_DATE);
    STPROC.BIND_I(P_CALLING_MODULE);
    STPROC.BIND_I(P_LAST_UPDATED_BY);
    STPROC.BIND_I(P_LAST_UPDATE_LOGIN);
    STPROC.BIND_I(P_PROGRAM_APPLICATION_ID);
    STPROC.BIND_I(P_PROGRAM_ID);
    STPROC.BIND_I(P_REQUEST_ID);
    STPROC.BIND_O(P_AWT_SUCCESS);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(12
                   ,P_AWT_SUCCESS);*/null;
  END AP_UNDO_TEMP_WITHHOLDING;

  PROCEDURE AP_UNDO_WITHHOLDING(P_PARENT_ID IN NUMBER
                               ,P_CALLING_MODULE IN VARCHAR2
                               ,P_AWT_DATE IN DATE
                               ,P_NEW_INVOICE_PAYMENT_ID IN NUMBER
                               ,P_LAST_UPDATED_BY IN NUMBER
                               ,P_LAST_UPDATE_LOGIN IN NUMBER
                               ,P_PROGRAM_APPLICATION_ID IN NUMBER
                               ,P_PROGRAM_ID IN NUMBER
                               ,P_REQUEST_ID IN NUMBER
                               ,P_AWT_SUCCESS OUT NOCOPY VARCHAR2
                               ,P_DIST_LINE_NO IN NUMBER
                               ,P_NEW_INVOICE_ID IN NUMBER
                               ,P_NEW_DIST_LINE_NO IN NUMBER) IS
  BEGIN
    /*STPROC.INIT('begin AP_WITHHOLDING_PKG.AP_UNDO_WITHHOLDING(:P_PARENT_ID, :P_CALLING_MODULE, :P_AWT_DATE, :P_NEW_INVOICE_PAYMENT_ID,
    :P_LAST_UPDATED_BY, :P_LAST_UPDATE_LOGIN, :P_PROGRAM_APPLICATION_ID, :P_PROGRAM_ID, :P_REQUEST_ID, :P_AWT_SUCCESS, :P_DIST_LINE_NO,
    :P_NEW_INVOICE_ID, :P_NEW_DIST_LINE_NO); end;');
    STPROC.BIND_I(P_PARENT_ID);
    STPROC.BIND_I(P_CALLING_MODULE);
    STPROC.BIND_I(P_AWT_DATE);
    STPROC.BIND_I(P_NEW_INVOICE_PAYMENT_ID);
    STPROC.BIND_I(P_LAST_UPDATED_BY);
    STPROC.BIND_I(P_LAST_UPDATE_LOGIN);
    STPROC.BIND_I(P_PROGRAM_APPLICATION_ID);
    STPROC.BIND_I(P_PROGRAM_ID);
    STPROC.BIND_I(P_REQUEST_ID);
    STPROC.BIND_O(P_AWT_SUCCESS);
    STPROC.BIND_I(P_DIST_LINE_NO);
    STPROC.BIND_I(P_NEW_INVOICE_ID);
    STPROC.BIND_I(P_NEW_DIST_LINE_NO);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(10
                   ,P_AWT_SUCCESS);*/null;
  END AP_UNDO_WITHHOLDING;

  FUNCTION AP_GET_DISPLAYED_FIELD(LOOKUPTYPE IN VARCHAR2
                                 ,LOOKUPCODE IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    /*STPROC.INIT('begin :X0 := AP_UTILITIES_PKG.AP_GET_DISPLAYED_FIELD(:LOOKUPTYPE, :LOOKUPCODE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(LOOKUPTYPE);
    STPROC.BIND_I(LOOKUPCODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/null;
    RETURN X0;
  END AP_GET_DISPLAYED_FIELD;

  FUNCTION AP_ROUND_CURRENCY(P_AMOUNT IN NUMBER
                            ,P_CURRENCY_CODE IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
   /* STPROC.INIT('begin :X0 := AP_UTILITIES_PKG.AP_ROUND_CURRENCY(:P_AMOUNT, :P_CURRENCY_CODE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_AMOUNT);
    STPROC.BIND_I(P_CURRENCY_CODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/null;
    RETURN X0;
  END AP_ROUND_CURRENCY;

  FUNCTION AP_ROUND_TAX(P_AMOUNT IN NUMBER
                       ,P_CURRENCY_CODE IN VARCHAR2
                       ,P_ROUND_RULE IN VARCHAR2
                       ,P_CALLING_SEQUENCE IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
    /*STPROC.INIT('begin :X0 := AP_UTILITIES_PKG.AP_ROUND_TAX(:P_AMOUNT, :P_CURRENCY_CODE, :P_ROUND_RULE, :P_CALLING_SEQUENCE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_AMOUNT);
    STPROC.BIND_I(P_CURRENCY_CODE);
    STPROC.BIND_I(P_ROUND_RULE);
    STPROC.BIND_I(P_CALLING_SEQUENCE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/null;
    RETURN X0;
  END AP_ROUND_TAX;

  FUNCTION AP_ROUND_PRECISION(P_AMOUNT IN NUMBER
                             ,P_MIN_UNIT IN NUMBER
                             ,P_PRECISION IN NUMBER) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
   /* STPROC.INIT('begin :X0 := AP_UTILITIES_PKG.AP_ROUND_PRECISION(:P_AMOUNT, :P_MIN_UNIT, :P_PRECISION); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_AMOUNT);
    STPROC.BIND_I(P_MIN_UNIT);
    STPROC.BIND_I(P_PRECISION);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/null;
    RETURN X0;
  END AP_ROUND_PRECISION;

  FUNCTION GET_CURRENT_GL_DATE(P_DATE IN DATE) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
   /* STPROC.INIT('begin :X0 := AP_UTILITIES_PKG.GET_CURRENT_GL_DATE(:P_DATE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/null;
    RETURN X0;
  END GET_CURRENT_GL_DATE;

  PROCEDURE GET_OPEN_GL_DATE(P_DATE IN DATE
                            ,P_PERIOD_NAME OUT NOCOPY VARCHAR2
                            ,P_GL_DATE OUT NOCOPY DATE) IS
  BEGIN
    /*STPROC.INIT('begin AP_UTILITIES_PKG.GET_OPEN_GL_DATE(:P_DATE, :P_PERIOD_NAME, :P_GL_DATE); end;');
    STPROC.BIND_I(P_DATE);
    STPROC.BIND_O(P_PERIOD_NAME);
    STPROC.BIND_O(P_GL_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,P_PERIOD_NAME);
    STPROC.RETRIEVE(3
                   ,P_GL_DATE);*/null;
  END GET_OPEN_GL_DATE;

  PROCEDURE GET_ONLY_OPEN_GL_DATE(P_DATE IN DATE
                                 ,P_PERIOD_NAME OUT NOCOPY VARCHAR2
                                 ,P_GL_DATE OUT NOCOPY DATE) IS
  BEGIN
    /*STPROC.INIT('begin AP_UTILITIES_PKG.GET_ONLY_OPEN_GL_DATE(:P_DATE, :P_PERIOD_NAME, :P_GL_DATE); end;');
    STPROC.BIND_I(P_DATE);
    STPROC.BIND_O(P_PERIOD_NAME);
    STPROC.BIND_O(P_GL_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,P_PERIOD_NAME);
    STPROC.RETRIEVE(3
                   ,P_GL_DATE);*/null;
  END GET_ONLY_OPEN_GL_DATE;

  FUNCTION GET_EXCHANGE_RATE(P_FROM_CURRENCY_CODE IN VARCHAR2
                            ,P_TO_CURRENCY_CODE IN VARCHAR2
                            ,P_EXCHANGE_RATE_TYPE IN VARCHAR2
                            ,P_EXCHANGE_DATE IN DATE
                            ,P_CALLING_SEQUENCE IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
    /*STPROC.INIT('begin :X0 := AP_UTILITIES_PKG.GET_EXCHANGE_RATE(:P_FROM_CURRENCY_CODE, :P_TO_CURRENCY_CODE, :P_EXCHANGE_RATE_TYPE,
    :P_EXCHANGE_DATE, :P_CALLING_SEQUENCE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_FROM_CURRENCY_CODE);
    STPROC.BIND_I(P_TO_CURRENCY_CODE);
    STPROC.BIND_I(P_EXCHANGE_RATE_TYPE);
    STPROC.BIND_I(P_EXCHANGE_DATE);
    STPROC.BIND_I(P_CALLING_SEQUENCE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/null;
    RETURN X0;
  END GET_EXCHANGE_RATE;

  PROCEDURE SET_PROFILE(P_PROFILE_OPTION IN VARCHAR2
                       ,P_PROFILE_VALUE IN VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin AP_UTILITIES_PKG.SET_PROFILE(:P_PROFILE_OPTION, :P_PROFILE_VALUE); end;');
    STPROC.BIND_I(P_PROFILE_OPTION);
    STPROC.BIND_I(P_PROFILE_VALUE);
    STPROC.EXECUTE;*/null;
  END SET_PROFILE;

  PROCEDURE AP_GET_MESSAGE(P_ERR_TXT OUT NOCOPY VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin AP_UTILITIES_PKG.AP_GET_MESSAGE(:P_ERR_TXT); end;');
    STPROC.BIND_O(P_ERR_TXT);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,P_ERR_TXT);*/null;
  END AP_GET_MESSAGE;

PROCEDURE SET_P_AWT_REPORT IS
CONC_PRO_ID NUMBER(15);
CONC_PRO_NAME varchar(30);
BEGIN
CONC_PRO_ID:=fnd_global.CONC_PROGRAM_ID();

Select CONCURRENT_PROGRAM_NAME into CONC_PRO_NAME from fnd_concurrent_programs fn
where fn.CONCURRENT_PROGRAM_ID = CONC_PRO_ID;

IF (CONC_PRO_NAME = 'APXWTINV_XML') THEN
     P_AWT_REPORT := 'AWT1';
    ELSIF (CONC_PRO_NAME = 'APXWTPAY_XML') THEN
      P_AWT_REPORT := 'AWT2';
    ELSIF (CONC_PRO_NAME = 'APXWTVND_XML') THEN
      P_AWT_REPORT := 'AWT3';
    ELSIF (CONC_PRO_NAME = 'APXWTSRA_XML') THEN
      P_AWT_REPORT := 'AWT4';
    ELSIF (CONC_PRO_NAME = 'APXWTTXA_XML') THEN
      P_AWT_REPORT := 'AWT5';
    ELSIF (CONC_PRO_NAME = 'APXWTCER_XML') THEN
      P_AWT_REPORT := 'AWT6';
    ELSE
      P_AWT_REPORT := 'AWT-I';
    END IF;

END SET_P_AWT_REPORT;

END AP_APXWTGNR_XMLP_PKG;


/
