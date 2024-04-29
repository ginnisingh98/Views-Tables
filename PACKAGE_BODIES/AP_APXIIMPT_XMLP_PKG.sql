--------------------------------------------------------
--  DDL for Package Body AP_APXIIMPT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXIIMPT_XMLP_PKG" AS
/* $Header: APXIIMPTB.pls 120.1 2008/01/06 11:51:59 vjaganat noship $ */
  FUNCTION GET_BASE_CURR_DATA RETURN BOOLEAN IS
    BASE_CURR AP_SYSTEM_PARAMETERS.BASE_CURRENCY_CODE%TYPE;
    PREC FND_CURRENCIES_VL.PRECISION%TYPE;
    MIN_AU FND_CURRENCIES_VL.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
    DESCR FND_CURRENCIES_VL.DESCRIPTION%TYPE;
    DEBUG_INFO VARCHAR2(500);
  BEGIN
    BASE_CURR := '';
    PREC := 0;
    MIN_AU := 0;
    DESCR := '';
    DEBUG_INFO := '(Get Base Curr data 1) Get the Base Currency Information';
    IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
      /*SRW.MESSAGE('1'
                 ,DEBUG_INFO)*/NULL;
    END IF;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('999'
                 ,DEBUG_INFO)*/NULL;
      RETURN (FALSE);
  END GET_BASE_CURR_DATA;

  FUNCTION CUSTOM_INIT RETURN BOOLEAN IS
    DEBUG_INFO VARCHAR2(500);
  BEGIN
    DEBUG_INFO := '(Custom Init 1) Custom Init';
    IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
      /*SRW.MESSAGE('1'
                 ,DEBUG_INFO)*/NULL;
    END IF;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('999'
                 ,DEBUG_INFO)*/NULL;
      IF (SQLCODE < 0) THEN
        /*SRW.MESSAGE('999'
                   ,SQLERRM)*/NULL;
      END IF;
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
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_ALL_END_OF_REPORT');
    C_NLS_NO_DATA_EXISTS := '*** ' || C_NLS_NO_DATA_EXISTS || ' ***';
    C_NLS_END_OF_REPORT := '*** ' || C_NLS_END_OF_REPORT || ' ***';
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_NLS_STRINGS;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      INIT_FAILURE EXCEPTION;
      L_BATCH_ERROR_FLAG VARCHAR2(1) := 'N';
      L_INVOICES_FETCHED NUMBER := 0;
      L_INVOICES_CREATED NUMBER := 0;
      L_TOTAL_INVOICE_AMOUNT NUMBER := 0;
      CURRENT_CALLING_SEQUENCE VARCHAR2(2000);
      DEBUG_INFO VARCHAR2(500);
    BEGIN
      CURRENT_CALLING_SEQUENCE := 'Before Report Trigger<-Build Program';
      C_REPORT_START_DATE := SYSDATE;
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      --added as fix
      select SUBSTR(argument1,INSTR(argument1,'=',1)+1,LENGTH(argument1)),
      SUBSTR(argument2,INSTR(argument2,'=',1)+1,LENGTH(argument2)),
      SUBSTR(argument3,INSTR(argument3,'=',1)+1,LENGTH(argument3)),
      SUBSTR(argument4,INSTR(argument4,'=',1)+1,LENGTH(argument4)),
      SUBSTR(argument5,INSTR(argument5,'=',1)+1,LENGTH(argument5)),
      SUBSTR(argument6,INSTR(argument6,'=',1)+1,LENGTH(argument6)),
      to_date(SUBSTR(argument7,INSTR(argument7,'=',1)+1,LENGTH(argument7)),'YYYY/MM/DD HH24:MI:SS'),
      SUBSTR(argument8,INSTR(argument8,'=',1)+1,LENGTH(argument8)),
      SUBSTR(argument9,INSTR(argument9,'=',1)+1,LENGTH(argument9)),
      SUBSTR(argument10,INSTR(argument10,'=',1)+1,LENGTH(argument10)),
      SUBSTR(argument11,INSTR(argument11,'=',1)+1,LENGTH(argument11))
      into
      p_org_id_t,p_source_t,p_group_id_t,p_batch_name_t,p_hold_code_t,p_hold_reason_t,p_gl_date_t,
      p_purge_flag_t,p_trace_switch_t,p_debug_switch_t,p_summary_flag_t
      from FND_CONCURRENT_REQUESTS
      where request_id=P_CONC_REQUEST_ID;
--fix ends

      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
        /*SRW.MESSAGE('1'
                   ,'(Before Report) After SRWINIT')*/NULL;
      END IF;
      MO_GLOBAL.INIT('SQLAP');
      IF (GET_COMPANY_NAME <> TRUE) THEN
       RAISE INIT_FAILURE;

      END IF;
      IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
        /*SRW.MESSAGE('2'
                   ,'(Before Report) After Get_Company_Name')*/NULL;
      END IF;
      IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
        /*SRW.MESSAGE('3'
                   ,'(Before Report) After Get_NLS_Strings')*/NULL;
      END IF;
      IF (GET_BASE_CURR_DATA <> TRUE) THEN
        RAISE INIT_FAILURE;

      END IF;
      IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
        /*SRW.MESSAGE('4'
                   ,'(Before Report) After Get_Base_Curr_Data')*/NULL;
      END IF;
      IF (GET_OPERATING_UNIT <> TRUE) THEN
        RAISE INIT_FAILURE;

      END IF;
      IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
        /*SRW.MESSAGE('1.1'
                   ,'After Get Operating Unit')*/NULL;
      END IF;
      IF (GET_PURGE_FLAG <> TRUE) THEN
        RAISE INIT_FAILURE;

      END IF;
      IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
        /*SRW.MESSAGE('1.2'
                   ,'After Get Purge Flag')*/NULL;
      END IF;
      DEBUG_INFO := '(Before Report Trigger 1) Import Invoices.';
      IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
        /*SRW.MESSAGE('2'
                   ,DEBUG_INFO)*/NULL;
      END IF;
      IF (AP_IMPORT_INVOICES_PKG.IMPORT_INVOICES(p_batch_name_t
                                            ,p_gl_date_t
                                            ,p_hold_code_t
                                            ,p_hold_reason_t
                                            ,P_COMMIT_CYCLES
                                            ,p_source_t
                                            ,p_group_id_t
                                            ,P_CONC_REQUEST_ID
                                            ,P_DEBUG_SWITCH_T
                                            ,p_org_id_t
                                            ,L_BATCH_ERROR_FLAG
                                            ,L_INVOICES_FETCHED
                                            ,L_INVOICES_CREATED
                                            ,L_TOTAL_INVOICE_AMOUNT
                                            ,C_PRINT_BATCH
                                            ,'Before Report Trigger') <> TRUE) THEN
        RAISE INIT_FAILURE;

      END IF;
      IF (L_BATCH_ERROR_FLAG = 'Y') THEN
        /*SRW.MESSAGE('0'
                   ,'------------------> l_batch_error_flag = ' || L_BATCH_ERROR_FLAG)*/NULL;
        /*SRW.MESSAGE('999'
                   ,'(Before report Trigger :After Import Invoices) Fatal Error: No batch information and batch control is turned on!!!')*/NULL;
      END IF;
      IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
        /*SRW.MESSAGE('0'
                   ,'------------------> l_batch_error_flag = ' || L_BATCH_ERROR_FLAG)*/NULL;
      END IF;
      DEBUG_INFO := '(Before Report Trigger 4) Commit.';
      IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
        /*SRW.MESSAGE('13'
                   ,DEBUG_INFO)*/NULL;
      END IF;
      COMMIT;
      IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
        /*SRW.BREAK*/NULL;
      END IF;
      /*SRW.MESSAGE('0'
                 ,TO_CHAR(L_INVOICES_CREATED) || ' invoice(s) were created during the process run')*/NULL;
      /*SRW.MESSAGE('0'
                 ,TO_CHAR(L_INVOICES_FETCHED) || ' invoice(s) were fetched during the process run')*/NULL;
      /*SRW.MESSAGE('0'
                 ,' summarize flag' || p_summary_flag_t)*/NULL;
      FND_MESSAGE.SET_NAME('SQLAP'
                          ,'AP_IG_INVOICES_FETCHED');

      FND_MESSAGE.SET_NAME('SQLAP'
                          ,'AP_IG_INVOICES_CREATED');
      C_INVOICES_FETCHED := TO_CHAR(L_INVOICES_FETCHED);
      C_INVOICES_CREATED := TO_CHAR(L_INVOICES_CREATED);
      C_TOTAL_INVOICES_CREATED := L_INVOICES_CREATED;
      C_TOTAL_INVOICE_AMOUNT := NVL(L_TOTAL_INVOICE_AMOUNT
                                   ,0);
      C_TOTAL_INVOICES_REJECTED := L_INVOICES_FETCHED - L_INVOICES_CREATED;
      RETURN (TRUE);
        EXCEPTION
      WHEN OTHERS THEN
        DEBUG_INFO := '(Before Report Trigger 3) Exception: When Others.';
        IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
          /*SRW.MESSAGE('3'
                     ,DEBUG_INFO)*/NULL;
        END IF;
        IF (SQLCODE < 0) THEN
          /*SRW.MESSAGE('999'
                     ,SQLERRM)*/NULL;
        END IF;
        C_ERROR_FLAG := 'Y';
        C_ERROR_MESSAGE := SQLERRM;
        ROLLBACK;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      INIT_FAILURE EXCEPTION;
      DEBUG_INFO VARCHAR2(500);
      CURRENT_CALLING_SEQUENCE VARCHAR2(2000);
    BEGIN
      /*SRW.MESSAGE('883'
                 ,'After Repport Trigger: Setting the Org Context to Multiple')*/NULL;
      MO_GLOBAL.SET_POLICY_CONTEXT('M'
                                  ,NULL);
      CURRENT_CALLING_SEQUENCE := 'After Report Trigger <- Inovice Open Interface Import';
      IF (C_ERROR_FLAG = 'Y') THEN
        DEBUG_INFO := '(After report trigger 1) Rollback';
        IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
          /*SRW.MESSAGE('1'
                     ,DEBUG_INFO)*/NULL;
        END IF;
        ROLLBACK;
      END IF;
      IF (p_source_t = 'XML GATEWAY') THEN
        AP_XML_INVOICE_INBOUND_PKG.NOTIFY_SUPPLIER(P_CONC_REQUEST_ID
                                                  ,CURRENT_CALLING_SEQUENCE);
        IF (AP_IMPORT_INVOICES_PKG.XML_IMPORT_PURGE(p_group_id_t
                                               ,CURRENT_CALLING_SEQUENCE) <> TRUE) THEN
          /*SRW.MESSAGE('2'
                     ,'XML_IMPORT_PURGE FAILED')*/NULL;
        END IF;
      END IF;
      IF (NVL(p_purge_flag_t
         ,'N') in ('Y','y')) THEN
        DEBUG_INFO := '(After report trigger 2) Delete records in ap_invoices_interface';
        IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
          /*SRW.MESSAGE('2'
                     ,DEBUG_INFO)*/NULL;
        END IF;
        IF (AP_IMPORT_INVOICES_PKG.IMPORT_PURGE(p_source_t
                                           ,p_group_id_t
                                           ,p_org_id_t
                                           ,P_COMMIT_CYCLES
                                           ,'Before Report Trigger') <> TRUE) THEN
          RAISE INIT_FAILURE;
        END IF;
      END IF;
      DEBUG_INFO := '(After report 3) Delete record in ap_interface_controls';
      IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
        /*SRW.MESSAGE('3'
                   ,DEBUG_INFO)*/NULL;
      END IF;
      DELETE FROM AP_INTERFACE_CONTROLS
       WHERE SOURCE = p_source_t
         AND ( ( p_group_id_t IS NULL )
       OR ( GROUP_ID = p_group_id_t ) )
         AND REQUEST_ID = P_CONC_REQUEST_ID;
      DEBUG_INFO := '(After Report Trigger 4) Commit.';
      IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
        /*SRW.MESSAGE('4'
                   ,DEBUG_INFO)*/NULL;
      END IF;
      COMMIT;
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
      IF (P_DEBUG_SWITCH_T = 'Y') THEN
        /*SRW.MESSAGE('5'
                   ,'(After Report Trigger 5) After SRWEXIT')*/NULL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN IS
    L_CHART_OF_ACCOUNTS_ID GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE;
    L_NAME GL_SETS_OF_BOOKS.NAME%TYPE;
    L_SOB_ID NUMBER;
    DEBUG_INFO VARCHAR2(500);
  BEGIN
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('999'
                 ,DEBUG_INFO)*/NULL;
      RETURN (FALSE);
  END GET_COMPANY_NAME;

  FUNCTION GET_FLEXDATA RETURN BOOLEAN IS
  BEGIN
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_FLEXDATA;

  FUNCTION GET_BATCH_ID(p_batch_name_t IN VARCHAR2
                       ,P_BATCH_ID OUT NOCOPY NUMBER
                       ,P_BATCH_TYPE OUT NOCOPY VARCHAR2
                       ,P_CALLING_SEQUENCE IN VARCHAR2) RETURN BOOLEAN IS
    L_BATCH_ID NUMBER;
    CURRENT_CALLING_SEQUENCE VARCHAR2(2000);
    DEBUG_INFO VARCHAR2(500);
  BEGIN
    CURRENT_CALLING_SEQUENCE := 'get_batch_id<-' || P_CALLING_SEQUENCE;
    DEBUG_INFO := 'Check batch_name existance';
    BEGIN
      DEBUG_INFO := '(Get_batch_id 1) Get old batch id';
      IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
        /*SRW.MESSAGE('1'
                   ,DEBUG_INFO)*/NULL;
      END IF;
      SELECT
        'OLD BATCH',
        BATCH_ID
      INTO P_BATCH_TYPE,L_BATCH_ID
      FROM
        AP_BATCHES
      WHERE BATCH_NAME = p_batch_name_t;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_BATCH_TYPE := 'NEW BATCH';
    END;
    IF (P_BATCH_TYPE = 'NEW BATCH') THEN
      DEBUG_INFO := '(Get_batch_id 2) Get New batch_id';
      IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
        /*SRW.MESSAGE('1'
                   ,DEBUG_INFO)*/NULL;
      END IF;
      SELECT
        AP_BATCHES_S.NEXTVAL
      INTO L_BATCH_ID
      FROM
        SYS.DUAL;
    END IF;
    P_BATCH_ID := L_BATCH_ID;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('999'
                 ,DEBUG_INFO)*/NULL;
      IF (SQLCODE < 0) THEN
        /*SRW.MESSAGE('999'
                   ,SQLERRM)*/NULL;
      END IF;
      RETURN (FALSE);
  END GET_BATCH_ID;

  FUNCTION GET_CURRENT_DIST_LINE_NUM(P_INVOICE_ID IN NUMBER
                                    ,P_CURRENT_DIST_NUM OUT NOCOPY NUMBER
                                    ,P_CALLING_SEQUENCE IN VARCHAR2) RETURN BOOLEAN IS
    CURRENT_CALLING_SEQUENCE VARCHAR2(2000);
    DEBUG_INFO VARCHAR2(500);
  BEGIN
    CURRENT_CALLING_SEQUENCE := 'get_current_dist_line_num<-' || P_CALLING_SEQUENCE;
    DEBUG_INFO := '(Get Current Dist Line Num 1) Get the next available distribution line number';
    IF (P_DEBUG_SWITCH_T in ('y','Y')) THEN
      /*SRW.MESSAGE('1'
                 ,DEBUG_INFO)*/NULL;
    END IF;
    SELECT
      NVL(MAX(DISTRIBUTION_LINE_NUMBER)
         ,0)
    INTO P_CURRENT_DIST_NUM
    FROM
      AP_INVOICE_DISTRIBUTIONS
    WHERE INVOICE_ID = P_INVOICE_ID;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('999'
                 ,DEBUG_INFO)*/NULL;
      IF (SQLCODE < 0) THEN
        /*SRW.MESSAGE('999'
                   ,SQLERRM)*/NULL;
      END IF;
      RETURN (FALSE);
  END GET_CURRENT_DIST_LINE_NUM;

  FUNCTION C_LINE_LEVELFORMULA(LINE_NUMBER IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF (LINE_NUMBER = 0) THEN
        RETURN (' ');
      ELSIF (LINE_NUMBER = 999) THEN
        RETURN ('Line');
      ELSE
        RETURN (LINE_NUMBER);
      END IF;
    END;
    RETURN NULL;
  END C_LINE_LEVELFORMULA;

  FUNCTION CF_SOURCE_NAMEFORMULA RETURN CHAR IS
    L_SOURCES VARCHAR2(80);
  BEGIN
    BEGIN
      SELECT
        DISPLAYED_FIELD
      INTO L_SOURCES
      FROM
        AP_LOOKUP_CODES
      WHERE LOOKUP_TYPE = 'SOURCE'
        AND LOOKUP_CODE = p_source_t;
      RETURN L_SOURCES;
    END;
    RETURN NULL;
  END CF_SOURCE_NAMEFORMULA;

  FUNCTION GET_OPERATING_UNIT RETURN BOOLEAN IS
    L_OPERATING_UNIT VARCHAR2(240);
  BEGIN
    IF p_org_id_t IS NOT NULL THEN
      L_OPERATING_UNIT := SUBSTRB(MO_GLOBAL.GET_OU_NAME(p_org_id_t)
                                 ,1
                                 ,240);
      CP_OPERATING_UNIT := L_OPERATING_UNIT;
    ELSE
      NULL;
    END IF;
    RETURN (TRUE);
    RETURN (NULL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_OPERATING_UNIT;

  FUNCTION GET_PURGE_FLAG RETURN BOOLEAN IS
    L_PURGE_FLAG VARCHAR2(240);
  BEGIN
    IF p_purge_flag_t IS NOT NULL THEN
      SELECT
        MEANING
      INTO L_PURGE_FLAG
      FROM
        FND_LOOKUPS
      WHERE LOOKUP_CODE = p_purge_flag_t
        AND LOOKUP_TYPE = 'YES_NO';
      CP_PURGE_FLAG := L_PURGE_FLAG;
    ELSE
      NULL;
    END IF;
    RETURN (TRUE);
    RETURN (NULL);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_PURGE_FLAG;

  FUNCTION CF_AUDIT_OUFORMULA(AUDIT_ORG_ID IN NUMBER) RETURN CHAR IS
  BEGIN
    DECLARE
      L_OPERATING_UNIT VARCHAR2(240);
    BEGIN
      /*SRW.REFERENCE(AUDIT_ORG_ID)*/NULL;
      L_OPERATING_UNIT := SUBSTRB(MO_GLOBAL.GET_OU_NAME(AUDIT_ORG_ID)
                                 ,1
                                 ,240);
      RETURN (L_OPERATING_UNIT);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
    RETURN NULL;
  END CF_AUDIT_OUFORMULA;

  FUNCTION CF_REJECT_OUFORMULA(REJECT_ORG_ID IN NUMBER) RETURN CHAR IS
  BEGIN
    DECLARE
      L_OPERATING_UNIT VARCHAR2(240);
    BEGIN
      /*SRW.REFERENCE(REJECT_ORG_ID)*/NULL;
      IF REJECT_ORG_ID IS NOT NULL THEN
        L_OPERATING_UNIT := SUBSTRB(MO_GLOBAL.GET_OU_NAME(REJECT_ORG_ID)
                                   ,1
                                   ,240);
      END IF;
      RETURN (L_OPERATING_UNIT);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
    RETURN NULL;
  END CF_REJECT_OUFORMULA;

  FUNCTION CF_INVOICE_AMOUNT2FORMULA(CF_INVOICE_AMOUNT2 IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (CF_INVOICE_AMOUNT2);
  END CF_INVOICE_AMOUNT2FORMULA;

  FUNCTION CF_INVOICE_AMOUNT3FORMULA(CF_INVOICE_AMOUNT3 IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (CF_INVOICE_AMOUNT3);
  END CF_INVOICE_AMOUNT3FORMULA;

  FUNCTION CF_IPV_ADJ_AMOUNTFORMULA(CF_IPV_ADJ_AMOUNT IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (CF_IPV_ADJ_AMOUNT);
  END CF_IPV_ADJ_AMOUNTFORMULA;

  FUNCTION CF_TIPV_ADJ_AMOUNTFORMULA(CF_TIPV_ADJ_AMOUNT IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (CF_TIPV_ADJ_AMOUNT);
  END CF_TIPV_ADJ_AMOUNTFORMULA;

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

  FUNCTION PAYABLES_OPEN_INTERFACE_IMPOR RETURN VARCHAR2 IS
  BEGIN
    RETURN PAYABLES_OPEN_INTERFACE_IMPORT;
  END PAYABLES_OPEN_INTERFACE_IMPOR;

  FUNCTION C_ERROR_FLAG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ERROR_FLAG;
  END C_ERROR_FLAG_P;

  FUNCTION C_ERROR_MESSAGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ERROR_MESSAGE;
  END C_ERROR_MESSAGE_P;

  FUNCTION C_PRINT_BATCH_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PRINT_BATCH;
  END C_PRINT_BATCH_P;

  FUNCTION C_INVOICES_FETCHED_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_INVOICES_FETCHED;
  END C_INVOICES_FETCHED_P;

  FUNCTION C_INVOICES_CREATED_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_INVOICES_CREATED;
  END C_INVOICES_CREATED_P;

  FUNCTION C_TOTAL_INVOICE_AMOUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_INVOICE_AMOUNT;
  END C_TOTAL_INVOICE_AMOUNT_P;

  FUNCTION C_TOTAL_INVOICES_CREATED_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TOTAL_INVOICES_CREATED;
  END C_TOTAL_INVOICES_CREATED_P;

  FUNCTION C_TOTAL_INVOICES_REJECTED_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_INVOICES_REJECTED;
  END C_TOTAL_INVOICES_REJECTED_P;

  FUNCTION C_MSG_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_MSG_TYPE;
  END C_MSG_TYPE_P;

  FUNCTION C_MSG_TOKEN1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_MSG_TOKEN1;
  END C_MSG_TOKEN1_P;

  FUNCTION C_MSG_TOKEN2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_MSG_TOKEN2;
  END C_MSG_TOKEN2_P;

  FUNCTION C_MSG_TOKEN3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_MSG_TOKEN3;
  END C_MSG_TOKEN3_P;

  FUNCTION C_MSG_COUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_MSG_COUNT;
  END C_MSG_COUNT_P;

  FUNCTION C_MSG_DATA_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_MSG_DATA;
  END C_MSG_DATA_P;

  FUNCTION C_PA_MESSAGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PA_MESSAGE;
  END C_PA_MESSAGE_P;

  FUNCTION CP_OPERATING_UNIT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_OPERATING_UNIT;
  END CP_OPERATING_UNIT_P;

  FUNCTION CP_PURGE_FLAG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PURGE_FLAG;
  END CP_PURGE_FLAG_P;

  FUNCTION FCREATE_RETROPRICE_ADJUSTMENTS RETURN NUMBER IS
  BEGIN
    RETURN CREATE_RETROPRICE_ADJUSTMENTS;
  END FCREATE_RETROPRICE_ADJUSTMENTS;

  FUNCTION IMPORT_INVOICES_P RETURN NUMBER IS
  BEGIN
    RETURN IMPORT_INVOICES;
  END IMPORT_INVOICES_P;

END AP_APXIIMPT_XMLP_PKG;


/
