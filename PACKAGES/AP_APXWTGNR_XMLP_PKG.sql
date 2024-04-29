--------------------------------------------------------
--  DDL for Package AP_APXWTGNR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXWTGNR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXWTGNRS.pls 120.0 2007/12/27 08:52:39 vjaganat noship $ */
  P_DEBUG_SWITCH VARCHAR2(1);

  P_CONC_REQUEST_ID NUMBER := 0;

  P_MIN_PRECISION NUMBER;

  P_FLEXDATA VARCHAR2(600);

  P_SET_OF_BOOKS_ID NUMBER;

  P_AWT_REPORT VARCHAR2(5):='AWT2' ;

  P_FISCAL_YEAR NUMBER;

  P_DATE_FROM DATE;

  P_DATE_TO DATE;

  P_TAX_AUTHORITY_ID NUMBER;

  P_TAX_AUTH_SITE_ID NUMBER;

  P_CHECKRUN_NAME VARCHAR2(50);

  P_TAX_NAME VARCHAR2(15);

  P_SUPPLIER_ID NUMBER;

  P_SUPPLIER_FROM VARCHAR2(240);
  P_SUPPLIER_FROM_V VARCHAR2(240);

  P_SUPPLIER_TO VARCHAR2(240);
  P_SUPPLIER_TO_V VARCHAR2(240);

  P_SUPP_NUM_FROM VARCHAR2(30);
  P_SUPP_NUM_FROM_V VARCHAR2(30);

  P_SUPP_NUM_TO VARCHAR2(30);
  P_SUPP_NUM_TO_V VARCHAR2(30);

  P_REPORT_CURRENCY VARCHAR2(10) := 'FUNCTIONAL';
  P_REPORT_CURRENCY_V VARCHAR2(30) ;

  P_INVOICE_CLASSES VARCHAR2(32767);

  P_POSTED_STATUS VARCHAR2(25);

  P_CERT_EXPIRE_FROM DATE;

  P_CERT_EXPIRE_TO DATE;

  P_SUPPLIER_SURNAME VARCHAR2(100);

  P_SUPPLIER_FIRST_NAME VARCHAR2(100);

  P_SUPPLIER_BIRTHDATE VARCHAR2(100);

  P_SUPPLIER_TOB VARCHAR2(100);

  P_SUPPLIER_DOB VARCHAR2(100);

  P_SUPPLIER_SEX VARCHAR2(100);

  P_SUPPLIER_FCC VARCHAR2(100);

  P_SUPPLIER_FCR VARCHAR2(100);

  P_SUPPLIER_FIFC VARCHAR2(100);

  P_TAX_AUTHORITY_NAME VARCHAR2(240) := '''No Tax Authority Info                                                                             ''';

  P_TAX_AUTHORITY_SITE_CODE VARCHAR2(100) := '''No Tax Authority Info                                                                             ''';

  P_TA_ADDRESS_LINE1 VARCHAR2(240) := '''No Tax Authority Info                                                                             ''';

  P_TA_ADDRESS_LINE2 VARCHAR2(240) := '''No Tax Authority Info                                                                             ''';

  P_TA_ADDRESS_LINE3 VARCHAR2(240) := '''No Tax Authority Info                                                                             ''';

  P_TA_CITY VARCHAR2(100) := '''No Tax Authority Info                                                                             ''';

  P_TA_STATE VARCHAR2(150) := '''No Tax Authority Info                                                                             ''';

  P_TA_ZIP VARCHAR2(100) := '''No Tax Authority Info                                                                             ''';

  P_TA_PROVINCE VARCHAR2(150) := '''No Tax Authority Info                                                                             ''';

  P_TA_COUNTRY VARCHAR2(100) := '''No Tax Authority Info                                                                             ''';

  P_TAX_AUTHORITY_TABLES VARCHAR2(1000);

  P_TAX_AUTHORITY_JOINS VARCHAR2(1000);

  P_SELECT_TAX_AUTHORITY VARCHAR2(1000);

  P_RESTRICT_TO_CHECKRUN_NAME VARCHAR2(1000);

  P_RESTRICT_TO_PAID_DISTS VARCHAR2(1000);

  P_SELECTED_SUPPLIERS VARCHAR2(1000);

  P_SYSTEM_ACCT_METHOD VARCHAR2(240);

  P_GL_POSTED_STATUS VARCHAR2(1000);

  P_CERT_EXPIRATION_RANGE VARCHAR2(1000);

  P_RESTRICT_CERTIFICATES VARCHAR2(1000);

  P_ORDER_BY VARCHAR2(1000);

  P_TRACE_SWITCH VARCHAR2(1);

  P_LOG_TO_PIPE VARCHAR2(1);

  P_PIPE_SIZE NUMBER;

  --P_DATE_FILTER NUMBER:= ' ';
  P_DATE_FILTER VARCHAR2(500):= ' ';

  P_TAX_NAME_FILTER VARCHAR2(100);

  AP_WITHHOLDING_TEMPLATE_REPORT VARCHAR2(1);

  C_NLS_YES VARCHAR2(80);

  C_NLS_NO VARCHAR2(80);

  C_NLS_ALL VARCHAR2(80);

  C_NLS_NO_DATA_EXISTS VARCHAR2(240);

  C_NLS_VOID VARCHAR2(80);

  C_NLS_NA VARCHAR2(80);

  C_NLS_END_OF_REPORT VARCHAR2(100);

  C_REPORT_START_DATE DATE;

  C_COMPANY_NAME_HEADER VARCHAR2(50);

  C_BASE_CURRENCY_CODE VARCHAR2(15);

  C_BASE_PRECISION NUMBER;

  C_BASE_MIN_ACCT_UNIT NUMBER;

  C_BASE_DESCRIPTION VARCHAR2(240);

  C_CHART_OF_ACCOUNTS_ID NUMBER;

  SANDRO_1995 NUMBER;

  FUNCTION GET_BASE_CURR_DATA RETURN BOOLEAN;

  FUNCTION CUSTOM_INIT RETURN BOOLEAN;

  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN;

  FUNCTION GET_NLS_STRINGS RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN;

  FUNCTION CBASECURRENCYNAME RETURN VARCHAR2;

  FUNCTION CREPORTTITLE RETURN VARCHAR2;

  FUNCTION ACCEPT_PARAMETER(PARAMETER_NAME IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION BEFOREPFORM RETURN BOOLEAN;

  FUNCTION CTAADDRESS(TA_CITY IN VARCHAR2
                     ,TA_STATE IN VARCHAR2
                     ,TA_ZIP IN VARCHAR2
                     ,TA_ADDRESS_LINE1 IN VARCHAR2
                     ,TA_ADDRESS_LINE2 IN VARCHAR2
                     ,TA_ADDRESS_LINE3 IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CSITEADDRESS(SITE_CITY IN VARCHAR2
                       ,SITE_STATE IN VARCHAR2
                       ,SITE_ZIP IN VARCHAR2
                       ,SITE_ADDRESS_LINE1 IN VARCHAR2
                       ,SITE_ADDRESS_LINE2 IN VARCHAR2
                       ,SITE_ADDRESS_LINE3 IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CINVOICECLASS(AWT_FLAG IN VARCHAR2
                        ,INVOICE_DATE IN DATE) RETURN VARCHAR2;

  FUNCTION CACTUALCURRENCYNAME(INVOICE_CURRENCY_NAME IN VARCHAR2
                              ,C_BASE_CURRENCY_NAME IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CINVOICEACTUALAMOUNT(INVOICE_AMOUNT IN NUMBER
                               ,INVOICE_CURRENCY_CODE IN VARCHAR2
                               ,INVOICE_BASE_AMOUNT IN NUMBER) RETURN NUMBER;

  FUNCTION CINVOICEAMOUNTEXEMPT(INVOICE_ID IN NUMBER
                               ,INVOICE_CURRENCY_CODE IN VARCHAR2) RETURN NUMBER;

  FUNCTION CGLDISTPOSTEDSTATUS(ACCRUAL_POSTED_FLAG IN VARCHAR2
                              ,CASH_POSTED_FLAG IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CACTUALAMOUNTSUBJECT(AMOUNT_SUBJECT_TO_TAX IN NUMBER
                               ,ACTUAL_CURRENCY_CODE IN VARCHAR2
                               ,INVOICE_CURRENCY_CODE IN VARCHAR2
                               ,INVOICE_EXCHANGE_RATE IN NUMBER) RETURN NUMBER;

  FUNCTION CACTUALTAXAMOUNT(TAX_AMOUNT IN NUMBER
                           ,ACTUAL_CURRENCY_CODE IN VARCHAR2
                           ,INVOICE_CURRENCY_CODE IN VARCHAR2
                           ,TAX_BASE_AMOUNT IN NUMBER) RETURN NUMBER;

  FUNCTION CPAYMENTAMOUNT(INVOICE_ID_V IN NUMBER
                         ,BREAK_AWT_PAYMENT_ID IN NUMBER
                         ,ACTUAL_CURRENCY_CODE IN VARCHAR2
                         ,INVOICE_CURRENCY_CODE IN VARCHAR2) RETURN NUMBER;

  FUNCTION CDISCOUNTAMOUNT(INVOICE_ID_V IN NUMBER
                          ,BREAK_AWT_PAYMENT_ID IN NUMBER
                          ,INVOICE_CURRENCY_CODE IN VARCHAR2
                          ,INVOICE_EXCHANGE_RATE IN NUMBER) RETURN NUMBER;

  FUNCTION CLASTPAYMENTDATE(INVOICE_ID IN NUMBER
                           ,BREAK_AWT_PAYMENT_ID IN NUMBER) RETURN DATE;

  FUNCTION CHECKINVOICECLASSES(C_INVOICE_CLASS IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION P_AWT_REPORTVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_FISCAL_YEARVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_DATE_FROMVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_DATE_TOVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_TAX_AUTH_SITE_IDVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_CHECKRUN_NAMEVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_TAX_NAMEVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_SUPPLIER_IDVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_SUPPLIER_FROMVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_SUPPLIER_TOVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_SUPP_NUM_FROMVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_SUPP_NUM_TOVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_REPORT_CURRENCYVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_INVOICE_CLASSESVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_POSTED_STATUSVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_CERT_EXPIRE_FROMVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_CERT_EXPIRE_TOVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION FORDERBY RETURN VARCHAR2;

  FUNCTION FRESTRICTCERTIFICATES RETURN VARCHAR2;

  FUNCTION FCERTEXPIRATIONRANGE RETURN VARCHAR2;

  FUNCTION FGLPOSTEDSTATUS RETURN VARCHAR2;

  FUNCTION FSELECTEDSUPPLIERS RETURN VARCHAR2;

  FUNCTION FRESTRICTTOPAIDDISTS RETURN VARCHAR2;

  FUNCTION FRESTRICTTOCHECKRUNNAME RETURN VARCHAR2;

  FUNCTION FSELECTTAXAUTHORITY RETURN VARCHAR2;

  FUNCTION FTAXAUTHORITYJOINS RETURN VARCHAR2;

  FUNCTION FTAXAUTHORITYTABLES RETURN VARCHAR2;

  FUNCTION CAWTSETUP RETURN VARCHAR2;

  FUNCTION CINVOICEFIRSTACCTDATE(INVOICE_ID IN NUMBER) RETURN DATE;

  FUNCTION CLASTPAYMENTDOC(INVOICE_ID IN NUMBER
                          ,BREAK_AWT_PAYMENT_ID IN NUMBER) RETURN NUMBER;

  FUNCTION LISTCERTTYPEF(LIST_CERT_TYPE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CMINDATEF(C_MIN_DATE IN date) RETURN DATE;

  FUNCTION CMAXDATEF(C_MAX_DATE IN date) RETURN DATE;

  FUNCTION CFISCALYEARF(C_MIN_DATE IN date
                       ,C_MAX_DATE IN date) RETURN NUMBER;

  FUNCTION CORIGINALINVTOTAL(S1_PAYMENT_AMOUNT IN NUMBER
                            ,S1_DISCOUNT_AMOUNT IN NUMBER
                            ,S0_ACTUAL_TAX_AMOUNT IN NUMBER) RETURN NUMBER;

  FUNCTION AP_WITHHOLDING_TEMPLATE_REPOR RETURN VARCHAR2;

  FUNCTION C_NLS_YES_P RETURN VARCHAR2;

  FUNCTION C_NLS_NO_P RETURN VARCHAR2;

  FUNCTION C_NLS_ALL_P RETURN VARCHAR2;

  FUNCTION C_NLS_NO_DATA_EXISTS_P RETURN VARCHAR2;

  FUNCTION C_NLS_VOID_P RETURN VARCHAR2;

  FUNCTION C_NLS_NA_P RETURN VARCHAR2;

  FUNCTION C_NLS_END_OF_REPORT_P RETURN VARCHAR2;

  FUNCTION C_REPORT_START_DATE_P RETURN DATE;

  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2;

  FUNCTION C_BASE_CURRENCY_CODE_P RETURN VARCHAR2;

  FUNCTION C_BASE_PRECISION_P RETURN NUMBER;

  FUNCTION C_BASE_MIN_ACCT_UNIT_P RETURN NUMBER;

  FUNCTION C_BASE_DESCRIPTION_P RETURN VARCHAR2;

  FUNCTION C_CHART_OF_ACCOUNTS_ID_P RETURN NUMBER;

  FUNCTION SANDRO_1995_P RETURN NUMBER;

  PROCEDURE AP_BEGIN_LOG(P_CALLING_MODULE IN VARCHAR2
                        ,P_MAX_SIZE IN NUMBER);

  FUNCTION AP_PIPE_NAME RETURN VARCHAR2;

  PROCEDURE AP_PIPE_NAME_23(P_PIPE_NAME OUT NOCOPY VARCHAR2);

  FUNCTION AP_LOG_RETURN_CODE RETURN NUMBER;

  PROCEDURE AP_BEGIN_BLOCK(P_MESSAGE_LOCATION IN VARCHAR2);

  PROCEDURE AP_END_BLOCK(P_MESSAGE_LOCATION IN VARCHAR2);

  PROCEDURE AP_INDENT;

  PROCEDURE AP_OUTDENT;

  PROCEDURE AP_LOG(P_MESSAGE IN VARCHAR2
                  ,P_MESSAGE_LOCATION IN VARCHAR2);

  PROCEDURE AP_END_LOG;

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
                             ,P_INVOICE_PAYMENT_ID IN NUMBER);

  PROCEDURE AP_WITHHOLD_AUTOSELECT(P_CHECKRUN_NAME IN VARCHAR2
                                  ,P_LAST_UPDATED_BY IN NUMBER
                                  ,P_LAST_UPDATE_LOGIN IN NUMBER
                                  ,P_PROGRAM_APPLICATION_ID IN NUMBER
                                  ,P_PROGRAM_ID IN NUMBER
                                  ,P_REQUEST_ID IN NUMBER);

  PROCEDURE AP_WITHHOLD_CONFIRM(P_CHECKRUN_NAME IN VARCHAR2
                               ,P_LAST_UPDATED_BY IN NUMBER
                               ,P_LAST_UPDATE_LOGIN IN NUMBER
                               ,P_PROGRAM_APPLICATION_ID IN NUMBER
                               ,P_PROGRAM_ID IN NUMBER
                               ,P_REQUEST_ID IN NUMBER);

  PROCEDURE AP_WITHHOLD_CANCEL(P_CHECKRUN_NAME IN VARCHAR2
                              ,P_LAST_UPDATED_BY IN NUMBER
                              ,P_LAST_UPDATE_LOGIN IN NUMBER
                              ,P_PROGRAM_APPLICATION_ID IN NUMBER
                              ,P_PROGRAM_ID IN NUMBER
                              ,P_REQUEST_ID IN NUMBER);

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
                                    ,P_AWT_SUCCESS OUT NOCOPY VARCHAR2);

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
                               ,P_NEW_DIST_LINE_NO IN NUMBER);

  FUNCTION AP_GET_DISPLAYED_FIELD(LOOKUPTYPE IN VARCHAR2
                                 ,LOOKUPCODE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION AP_ROUND_CURRENCY(P_AMOUNT IN NUMBER
                            ,P_CURRENCY_CODE IN VARCHAR2) RETURN NUMBER;

  FUNCTION AP_ROUND_TAX(P_AMOUNT IN NUMBER
                       ,P_CURRENCY_CODE IN VARCHAR2
                       ,P_ROUND_RULE IN VARCHAR2
                       ,P_CALLING_SEQUENCE IN VARCHAR2) RETURN NUMBER;

  FUNCTION AP_ROUND_PRECISION(P_AMOUNT IN NUMBER
                             ,P_MIN_UNIT IN NUMBER
                             ,P_PRECISION IN NUMBER) RETURN NUMBER;

  FUNCTION GET_CURRENT_GL_DATE(P_DATE IN DATE) RETURN VARCHAR2;

  PROCEDURE GET_OPEN_GL_DATE(P_DATE IN DATE
                            ,P_PERIOD_NAME OUT NOCOPY VARCHAR2
                            ,P_GL_DATE OUT NOCOPY DATE);

  PROCEDURE GET_ONLY_OPEN_GL_DATE(P_DATE IN DATE
                                 ,P_PERIOD_NAME OUT NOCOPY VARCHAR2
                                 ,P_GL_DATE OUT NOCOPY DATE);

  FUNCTION GET_EXCHANGE_RATE(P_FROM_CURRENCY_CODE IN VARCHAR2
                            ,P_TO_CURRENCY_CODE IN VARCHAR2
                            ,P_EXCHANGE_RATE_TYPE IN VARCHAR2
                            ,P_EXCHANGE_DATE IN DATE
                            ,P_CALLING_SEQUENCE IN VARCHAR2) RETURN NUMBER;

  PROCEDURE SET_PROFILE(P_PROFILE_OPTION IN VARCHAR2
                       ,P_PROFILE_VALUE IN VARCHAR2);

  PROCEDURE AP_GET_MESSAGE(P_ERR_TXT OUT NOCOPY VARCHAR2);
  PROCEDURE SET_P_AWT_REPORT;

END AP_APXWTGNR_XMLP_PKG;


/