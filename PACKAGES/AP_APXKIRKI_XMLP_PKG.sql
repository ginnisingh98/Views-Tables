--------------------------------------------------------
--  DDL for Package AP_APXKIRKI_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXKIRKI_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXKIRKIS.pls 120.0 2007/12/27 08:09:41 vjaganat noship $ */
  P_DEBUG_SWITCH VARCHAR2(1);

  P_CONC_REQUEST_ID NUMBER := 0;

  P_MIN_PRECISION NUMBER := 0;

  P_FLEXDATA VARCHAR2(600);

  P_SET_OF_BOOKS_ID NUMBER;

  P_PERIOD_NAME VARCHAR2(25);

  P_INCLUDE_INVOICE_DETAIL VARCHAR2(1);

  P_ENTERED_BY NUMBER;

  P_PERIOD_ROWID VARCHAR2(32767);

  P_WHERE_CREATED_BY VARCHAR2(2000);

  P_WHERE_CREATED_BY_AERH VARCHAR2(2000);

  C_BASE_CURRENCY_CODE VARCHAR2(15);

  C_BASE_PRECISION NUMBER;

  C_BASE_MIN_ACCT_UNIT NUMBER;

  C_BASE_DESCRIPTION VARCHAR2(240);

  C_COMPANY_NAME_HEADER VARCHAR2(50);

  C_REPORT_START_DATE DATE;

  C_NLS_YES VARCHAR2(80);

  C_NLS_NO VARCHAR2(80);

  C_NLS_ALL VARCHAR2(80);

  C_NLS_NO_DATA_EXISTS VARCHAR2(240);

  C_REPORT_RUN_TIME VARCHAR2(8);

  C_CHART_OF_ACCOUNTS_ID NUMBER;

  C_MODULE VARCHAR2(25) := 'KEY INDICATORS';

  C_PERIOD_YEAR NUMBER;

  C_PRIOR_PERIOD_YEAR NUMBER;

  C_PERIOD_NUM NUMBER;

  C_PRIOR_PERIOD_NUM NUMBER;

  C_PRIOR_PERIOD_NAME VARCHAR2(25);

  C_PERIOD_TYPE VARCHAR2(25);

  C_START_DATE VARCHAR2(32767);

  C_PRIOR_START_DATE DATE;

  C_END_DATE VARCHAR2(32767);

  C_PRIOR_END_DATE DATE;

  C_STATUS VARCHAR2(32767);

  C_TOTAL_VENDORS NUMBER;

  C_TOTAL_INACTIVE NUMBER;

  C_TOTAL_ONE_TIME NUMBER;

  C_TOTAL_1099 NUMBER;

  C_TOTAL_VOIDED NUMBER;

  C_TOTAL_DISTS NUMBER;

  C_TOTAL_BATCHES NUMBER;

  C_TOTAL_INVOICES NUMBER;

  C_TOTAL_INVOICES_DLR NUMBER;

  C_TOTAL_INVOICE_HOLDS NUMBER;

  C_TOTAL_INVOICE_HOLDS_DLR NUMBER;

  C_TOTAL_CLEARED NUMBER;

  C_TOTAL_CLEARED_DLR NUMBER;

  C_STOPPED NUMBER;

  C_TOTAL_MAN_CHECKS NUMBER;

  C_TOTAL_MAN_CHECKS_DLR NUMBER;

  C_TOTAL_AUTO_CHECKS NUMBER;

  C_TOTAL_AUTO_CHECKS_DLR NUMBER;

  C_TOTAL_SPOILED NUMBER;

  C_TOTAL_OUTSTANDING NUMBER;

  C_TOTAL_PAID_INV NUMBER;

  C_TOTAL_DISCS_DLR NUMBER;

  C_TOTAL_DISCS NUMBER;

  C_TOTAL_SCHEDULED NUMBER;

  C_TOTAL_SITES NUMBER;

  C_TOTAL_MH NUMBER;

  C_TOTAL_MH_DLR NUMBER;

  C_MH_COUNT NUMBER;

  C_MH_AMOUNT NUMBER;

  C_TOTAL_MATCHED NUMBER;

  C_TOTAL_MATCHED_DLR NUMBER;

  C_NEW_COUNT NUMBER;

  C_NEW_AMOUNT NUMBER;

  C_VOID NUMBER;

  C_CLEARED NUMBER;

  C_CLEARED_DLR NUMBER;

  C_MANUAL_CHECKS NUMBER;

  C_TOTAL_STOPPED NUMBER;

  C_MANUAL_CHECKS_DLR NUMBER;

  C_AUTO_CHECKS NUMBER;

  C_AUTO_CHECKS_DLR NUMBER;

  C_NEW_SPOILED NUMBER;

  C_NEW_OUTSTANDING NUMBER;

  C_MANUAL_PAYMENTS NUMBER;

  C_MANUAL_PAYMENTS_DLR NUMBER;

  C_AUTO_PAYMENTS NUMBER;

  C_AUTO_PAYMENTS_DLR NUMBER;

  C_INVOICES NUMBER;

  C_DISCOUNT_DLR NUMBER;

  C_DISCOUNTS NUMBER;

  C_NEW_INVOICES NUMBER;

  C_TOTAL_DLR NUMBER;

  C_BATCHES NUMBER;

  C_NEW_ON_HOLD NUMBER;

  C_NEW_HOLD_DLR NUMBER;

  C_PAYMENT_SCHEDULES NUMBER;

  C_NEW_DISTS NUMBER;

  C_NEW_VENDORS NUMBER;

  C_NEW_INACTIVE NUMBER;

  C_NEW_ONE_TIME NUMBER;

  C_NEW_TYPE_1099_VENDORS NUMBER;

  C_OLD_VENDOR_SITES NUMBER;

  C_TOTAL_VENDORS_HELD NUMBER;

  C_NEW_VENDOR_SITES NUMBER;

  C_UPDATED_VENDORS NUMBER;

  C_UPDATED_SITES NUMBER;

  C_NEW_VENDORS_HELD NUMBER;

  C_OLD_INVOICES NUMBER;

  C_OLD_TOTAL_DLR NUMBER;

  C_OLD_DISTS NUMBER;

  C_OLD_BATCHES NUMBER;

  C_OLD_PAYMENT_SCHEDULES NUMBER;

  C_OLD_ON_HOLD NUMBER;

  C_OLD_HOLD_DLR NUMBER;

  C_OLD_COUNT NUMBER;

  C_OLD_AMOUNT NUMBER;

  C_OLD_MH_COUNT NUMBER;

  C_OLD_MH_AMOUNT NUMBER;

  C_OLD_VENDORS NUMBER;

  C_OLD_SITES NUMBER;

  C_INACTIVE NUMBER;

  C_ONE_TIME NUMBER;

  C_TYPE_1099_VENDORS NUMBER;

  C_VENDORS_HELD NUMBER;

  C_OLD_INVOICES_PAID NUMBER;

  C_OLD_AUTO_CHECKS NUMBER;

  C_OLD_MANUAL_CHECKS NUMBER;

  C_OLD_DISCOUNTS NUMBER;

  C_OLD_DISCOUNT_DLR NUMBER;

  C_OLD_VOID NUMBER;

  C_OLD_STOPPED NUMBER;

  C_OLD_SPOILED NUMBER;

  C_OLD_OUTSTANDING NUMBER;

  C_OLD_CLEARED NUMBER;

  C_OLD_CLEARED_DLR NUMBER;

  C_OLD_AUTO_CHECKS_DLR NUMBER;

  C_OLD_MANUAL_CHECKS_DLR NUMBER;

  C_AVERAGE_SITES NUMBER;

  C_AVERAGE_LINES NUMBER;

  C_AVERAGE_PAY_INV NUMBER;

  C_AVERAGE_PAY_CHK NUMBER;

  C_AVERAGE_MH NUMBER;

  C_TOTAL_SITE NUMBER;

  C_TOTAL_NEW_EXCEPTIONS NUMBER;

  C_TOTAL_OLD_EXCEPTIONS NUMBER;

  C_TOTAL_TOTAL_EXCEPTIONS NUMBER;

  C_TOTAL_NEW_EXCEPTIONS_DLR NUMBER;

  C_TOTAL_OLD_EXCEPTIONS_DLR NUMBER;

  C_TOTAL_TOTAL_EXCEPTIONS_DLR NUMBER;

  C_TOTAL_NEW_CHECKS NUMBER;

  C_TOTAL_OLD_CHECKS NUMBER;

  C_TOTAL_TOTAL_CHECKS NUMBER;

  C_TOTAL_NEW_CHECKS_DLR NUMBER;

  C_TOTAL_OLD_CHECKS_DLR NUMBER;

  C_TOTAL_TOTAL_CHECKS_DLR NUMBER;

  C_PERCENT_VENDORS NUMBER;

  C_PERCENT_SITES NUMBER;

  C_PERCENT_ONE_TIME NUMBER;

  C_PERCENT_1099 NUMBER;

  C_PERCENT_VENDORS_HELD NUMBER;

  C_PERCENT_INACTIVE NUMBER;

  C_PERCENT_INVOICES NUMBER;

  C_PERCENT_INVOICES_DLR NUMBER;

  C_PERCENT_MATCHED NUMBER;

  C_PERCENT_MATCHED_DLR NUMBER;

  C_PERCENT_DISTS NUMBER;

  C_PERCENT_SCHEDULED NUMBER;

  C_PERCENT_BATCHES NUMBER;

  C_PERCENT_INVOICE_HOLDS NUMBER;

  C_PERCENT_INVOICE_HOLDS_DLR NUMBER;

  C_PERCENT_MH NUMBER;

  C_PERCENT_MH_DLR NUMBER;

  C_PERCENT_MAN_CHECKS NUMBER;

  C_PERCENT_MAN_CHECKS_DLR NUMBER;

  C_PERCENT_AUTO_CHECKS NUMBER;

  C_PERCENT_AUTO_CHECKS_DLR NUMBER;

  C_PERCENT_PAID_INV NUMBER;

  C_PERCENT_DISCS NUMBER;

  C_PERCENT_DISCS_DLR NUMBER;

  C_PERCENT_VOIDED NUMBER;

  C_PERCENT_STOPPED NUMBER;

  C_PERCENT_SPOILED NUMBER;

  C_PERCENT_OUTSTANDING NUMBER;

  C_PERCENT_CLEARED NUMBER;

  C_PERCENT_CLEARED_DLR NUMBER;

  C_PERCENT_TOTAL_EXCEPTIONS NUMBER;

  C_PERCENT_TOTAL_EXCEPTIONS_DLR NUMBER;

  C_PERCENT_TOTAL_CHECKS NUMBER;

  C_PERCENT_TOTAL_CHECKS_DLR NUMBER;

  C_NLS_NA VARCHAR2(80);

  C_PRIOR_PERIOD_EXISTS VARCHAR2(1);

  C_NLS_END_OF_REPORT VARCHAR2(100);

  C_PRIOR_OLD_VENDOR_SITES NUMBER;

  C_PERCENT_ADDITIONAL_SITES NUMBER;

  C_TOTAL_ADDITIONAL_SITES NUMBER;

  C_PRIOR_VENDORS_UPDATED NUMBER;

  C_PRIOR_SITES_UPDATED NUMBER;

  C_PERCENT_VENDORS_UPDATED NUMBER;

  C_PERCENT_SITES_UPDATED NUMBER;

  C_TOTAL_VENDORS_UPDATED NUMBER;

  C_TOTAL_SITES_UPDATED NUMBER;

  C_SYSTEM_USER_NAME VARCHAR2(1000);

  C_TOTAL_REFUND_CHECKS NUMBER;

  C_TOTAL_REFUND_CHECKS_DLR NUMBER;

  C_TOTAL_OUTSTANDING_DLR NUMBER;

  C_NEW_OUTSTANDING_DLR NUMBER;

  C_NEW_REFUND_PAYMENTS NUMBER;

  C_NEW_REFUND_PAYMENTS_DLR NUMBER;

  C_OLD_OUTSTANDING_DLR NUMBER;

  C_OLD_REFUND_PAYMENTS NUMBER;

  C_OLD_REFUND_PAYMENTS_DLR NUMBER;

  C_PERCENT_OUTSTANDING_DLR NUMBER;

  C_PERCENT_REFUND_CHECKS NUMBER;

  C_PERCENT_REFUND_CHECKS_DLR NUMBER;

  C_NEW_LINES NUMBER;

  C_OLD_LINES NUMBER;

  C_PERCENT_LINES NUMBER;

  C_TOTAL_LINES NUMBER;

  C_OLD_LINES_VAR_COUNT NUMBER;

  C_OLD_LINES_VAR_AMOUNT NUMBER;

  C_LINE_TOTAL_VARS NUMBER;

  C_LINE_TOTAL_VARS_DLR NUMBER;

  C_LINE_VAR_COUNT NUMBER;

  C_LINE_VAR_AMOUNT NUMBER;

  C_OLD_DISTS_VAR_COUNT NUMBER;

  C_OLD_DISTS_VAR_AMOUNT NUMBER;

  C_DIST_TOTAL_VARS NUMBER;

  C_DIST_TOTAL_VARS_DLR NUMBER;

  C_DIST_VAR_COUNT NUMBER;

  C_DIST_VAR_AMOUNT NUMBER;

  C_PERCENT_LINE_VARS NUMBER;

  C_PERCENT_DIST_VARS NUMBER;

  C_PERCENT_LINE_VARS_DLR NUMBER;

  C_PERCENT_DIST_VARS_DLR NUMBER;

  C_AVERAGE_DISTS NUMBER;

  C_ORG_ID NUMBER;

  FUNCTION GET_BASE_CURR_DATA RETURN BOOLEAN;

  FUNCTION CUSTOM_INIT RETURN BOOLEAN;

  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN;

  FUNCTION GET_NLS_STRINGS RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN;

  FUNCTION CALCULATE_RUN_TIME RETURN BOOLEAN;

  FUNCTION PERIOD_DATA RETURN BOOLEAN;

  FUNCTION ALL_PERIOD RETURN BOOLEAN;

  FUNCTION MATCHING_HOLDS RETURN BOOLEAN;

  FUNCTION INVOICE_DATA RETURN BOOLEAN;

  FUNCTION VARIANCE_DATA RETURN BOOLEAN;

  FUNCTION CURRENT_PERIOD RETURN BOOLEAN;

  FUNCTION INSERT_KEY_IND RETURN BOOLEAN;

  FUNCTION UPDATE_KEY_IND RETURN BOOLEAN;

  FUNCTION PRIOR_PERIOD RETURN BOOLEAN;

  FUNCTION CALCULATE_STATISTICS RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION CF_PER_CHANGE_AT_CURFORMULA(CS_CURR_INV_NUM IN NUMBER
                                      ,CS_PRIOR_INV_NUM IN NUMBER) RETURN NUMBER;

  FUNCTION CF_PER_CHANGE_AT_CUR_AMTFORMUL(CS_CURR_INV_AMT IN NUMBER
                                         ,CS_PRIOR_INV_AMT IN NUMBER) RETURN NUMBER;

  FUNCTION CF_PERCENT_CHANGE_NUMFORMULA(C_PRIOR_NUM_OF_INVOICES IN NUMBER
                                       ,C_CURRENT_NUM_OF_INVOICES IN NUMBER) RETURN NUMBER;

  FUNCTION CF_PERCENT_CHANGE_AMOUNTFORMUL(C_PRIOR_INVOICE_AMOUNT IN NUMBER
                                         ,C_CURRENT_INVOICE_AMOUNT IN NUMBER) RETURN NUMBER;

  FUNCTION CF_PERCENT_INV_USERFORMULA(CS_SUM_PRIOR_INV_NUM IN NUMBER
                                     ,CS_SUM_CURR_INV_NUM IN NUMBER) RETURN NUMBER;

  FUNCTION CF_PERCENT_FUNC_AMT_USERFORMUL(CS_SUM_PRIOR_FUNC_AMT IN NUMBER
                                         ,CS_SUM_CURR_FUNC_AMT IN NUMBER) RETURN NUMBER;

  FUNCTION CF_PERCENT_DISTFORMULA0006(CS_PRIOR_DIST IN NUMBER
                                     ,CS_CURR_DIST IN NUMBER) RETURN CHAR;

  FUNCTION GET_SYSTEM_USER_NAME RETURN BOOLEAN;

  FUNCTION CF_DISPLAY_SOURCEFORMULA(C_INVOICE_SOURCE IN VARCHAR2) RETURN CHAR;

  FUNCTION GET_PERIOD_NAME_FROM_ROWID RETURN BOOLEAN;

  FUNCTION GET_WHERE_CONDITIONS RETURN BOOLEAN;

  FUNCTION C_BASE_CURRENCY_CODE_P RETURN VARCHAR2;

  FUNCTION C_BASE_PRECISION_P RETURN NUMBER;

  FUNCTION C_BASE_MIN_ACCT_UNIT_P RETURN NUMBER;

  FUNCTION C_BASE_DESCRIPTION_P RETURN VARCHAR2;

  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2;

  FUNCTION C_REPORT_START_DATE_P RETURN DATE;

  FUNCTION C_NLS_YES_P RETURN VARCHAR2;

  FUNCTION C_NLS_NO_P RETURN VARCHAR2;

  FUNCTION C_NLS_ALL_P RETURN VARCHAR2;

  FUNCTION C_NLS_NO_DATA_EXISTS_P RETURN VARCHAR2;

  FUNCTION C_REPORT_RUN_TIME_P RETURN VARCHAR2;

  FUNCTION C_CHART_OF_ACCOUNTS_ID_P RETURN NUMBER;

  FUNCTION C_MODULE_P RETURN VARCHAR2;

  FUNCTION C_PERIOD_YEAR_P RETURN NUMBER;

  FUNCTION C_PRIOR_PERIOD_YEAR_P RETURN NUMBER;

  FUNCTION C_PERIOD_NUM_P RETURN NUMBER;

  FUNCTION C_PRIOR_PERIOD_NUM_P RETURN NUMBER;

  FUNCTION C_PRIOR_PERIOD_NAME_P RETURN VARCHAR2;

  FUNCTION C_PERIOD_TYPE_P RETURN VARCHAR2;

  FUNCTION C_START_DATE_P RETURN VARCHAR2;

  FUNCTION C_PRIOR_START_DATE_P RETURN DATE;

  FUNCTION C_END_DATE_P RETURN VARCHAR2;

  FUNCTION C_PRIOR_END_DATE_P RETURN DATE;

  FUNCTION C_STATUS_P RETURN VARCHAR2;

  FUNCTION C_TOTAL_VENDORS_P RETURN NUMBER;

  FUNCTION C_TOTAL_INACTIVE_P RETURN NUMBER;

  FUNCTION C_TOTAL_ONE_TIME_P RETURN NUMBER;

  FUNCTION C_TOTAL_1099_P RETURN NUMBER;

  FUNCTION C_TOTAL_VOIDED_P RETURN NUMBER;

  FUNCTION C_TOTAL_DISTS_P RETURN NUMBER;

  FUNCTION C_TOTAL_BATCHES_P RETURN NUMBER;

  FUNCTION C_TOTAL_INVOICES_P RETURN NUMBER;

  FUNCTION C_TOTAL_INVOICES_DLR_P RETURN NUMBER;

  FUNCTION C_TOTAL_INVOICE_HOLDS_P RETURN NUMBER;

  FUNCTION C_TOTAL_INVOICE_HOLDS_DLR_P RETURN NUMBER;

  FUNCTION C_TOTAL_CLEARED_P RETURN NUMBER;

  FUNCTION C_TOTAL_CLEARED_DLR_P RETURN NUMBER;

  FUNCTION C_STOPPED_P RETURN NUMBER;

  FUNCTION C_TOTAL_MAN_CHECKS_P RETURN NUMBER;

  FUNCTION C_TOTAL_MAN_CHECKS_DLR_P RETURN NUMBER;

  FUNCTION C_TOTAL_AUTO_CHECKS_P RETURN NUMBER;

  FUNCTION C_TOTAL_AUTO_CHECKS_DLR_P RETURN NUMBER;

  FUNCTION C_TOTAL_SPOILED_P RETURN NUMBER;

  FUNCTION C_TOTAL_OUTSTANDING_P RETURN NUMBER;

  FUNCTION C_TOTAL_PAID_INV_P RETURN NUMBER;

  FUNCTION C_TOTAL_DISCS_DLR_P RETURN NUMBER;

  FUNCTION C_TOTAL_DISCS_P RETURN NUMBER;

  FUNCTION C_TOTAL_SCHEDULED_P RETURN NUMBER;

  FUNCTION C_TOTAL_SITES_P RETURN NUMBER;

  FUNCTION C_TOTAL_MH_P RETURN NUMBER;

  FUNCTION C_TOTAL_MH_DLR_P RETURN NUMBER;

  FUNCTION C_MH_COUNT_P RETURN NUMBER;

  FUNCTION C_MH_AMOUNT_P RETURN NUMBER;

  FUNCTION C_TOTAL_MATCHED_P RETURN NUMBER;

  FUNCTION C_TOTAL_MATCHED_DLR_P RETURN NUMBER;

  FUNCTION C_NEW_COUNT_P RETURN NUMBER;

  FUNCTION C_NEW_AMOUNT_P RETURN NUMBER;

  FUNCTION C_VOID_P RETURN NUMBER;

  FUNCTION C_CLEARED_P RETURN NUMBER;

  FUNCTION C_CLEARED_DLR_P RETURN NUMBER;

  FUNCTION C_MANUAL_CHECKS_P RETURN NUMBER;

  FUNCTION C_TOTAL_STOPPED_P RETURN NUMBER;

  FUNCTION C_MANUAL_CHECKS_DLR_P RETURN NUMBER;

  FUNCTION C_AUTO_CHECKS_P RETURN NUMBER;

  FUNCTION C_AUTO_CHECKS_DLR_P RETURN NUMBER;

  FUNCTION C_NEW_SPOILED_P RETURN NUMBER;

  FUNCTION C_NEW_OUTSTANDING_P RETURN NUMBER;

  FUNCTION C_MANUAL_PAYMENTS_P RETURN NUMBER;

  FUNCTION C_MANUAL_PAYMENTS_DLR_P RETURN NUMBER;

  FUNCTION C_AUTO_PAYMENTS_P RETURN NUMBER;

  FUNCTION C_AUTO_PAYMENTS_DLR_P RETURN NUMBER;

  FUNCTION C_INVOICES_P RETURN NUMBER;

  FUNCTION C_DISCOUNT_DLR_P RETURN NUMBER;

  FUNCTION C_DISCOUNTS_P RETURN NUMBER;

  FUNCTION C_NEW_INVOICES_P RETURN NUMBER;

  FUNCTION C_TOTAL_DLR_P RETURN NUMBER;

  FUNCTION C_BATCHES_P RETURN NUMBER;

  FUNCTION C_NEW_ON_HOLD_P RETURN NUMBER;

  FUNCTION C_NEW_HOLD_DLR_P RETURN NUMBER;

  FUNCTION C_PAYMENT_SCHEDULES_P RETURN NUMBER;

  FUNCTION C_NEW_DISTS_P RETURN NUMBER;

  FUNCTION C_NEW_VENDORS_P RETURN NUMBER;

  FUNCTION C_NEW_INACTIVE_P RETURN NUMBER;

  FUNCTION C_NEW_ONE_TIME_P RETURN NUMBER;

  FUNCTION C_NEW_TYPE_1099_VENDORS_P RETURN NUMBER;

  FUNCTION C_OLD_VENDOR_SITES_P RETURN NUMBER;

  FUNCTION C_TOTAL_VENDORS_HELD_P RETURN NUMBER;

  FUNCTION C_NEW_VENDOR_SITES_P RETURN NUMBER;

  FUNCTION C_UPDATED_VENDORS_P RETURN NUMBER;

  FUNCTION C_UPDATED_SITES_P RETURN NUMBER;

  FUNCTION C_NEW_VENDORS_HELD_P RETURN NUMBER;

  FUNCTION C_OLD_INVOICES_P RETURN NUMBER;

  FUNCTION C_OLD_TOTAL_DLR_P RETURN NUMBER;

  FUNCTION C_OLD_DISTS_P RETURN NUMBER;

  FUNCTION C_OLD_BATCHES_P RETURN NUMBER;

  FUNCTION C_OLD_PAYMENT_SCHEDULES_P RETURN NUMBER;

  FUNCTION C_OLD_ON_HOLD_P RETURN NUMBER;

  FUNCTION C_OLD_HOLD_DLR_P RETURN NUMBER;

  FUNCTION C_OLD_COUNT_P RETURN NUMBER;

  FUNCTION C_OLD_AMOUNT_P RETURN NUMBER;

  FUNCTION C_OLD_MH_COUNT_P RETURN NUMBER;

  FUNCTION C_OLD_MH_AMOUNT_P RETURN NUMBER;

  FUNCTION C_OLD_VENDORS_P RETURN NUMBER;

  FUNCTION C_OLD_SITES_P RETURN NUMBER;

  FUNCTION C_INACTIVE_P RETURN NUMBER;

  FUNCTION C_ONE_TIME_P RETURN NUMBER;

  FUNCTION C_TYPE_1099_VENDORS_P RETURN NUMBER;

  FUNCTION C_VENDORS_HELD_P RETURN NUMBER;

  FUNCTION C_OLD_INVOICES_PAID_P RETURN NUMBER;

  FUNCTION C_OLD_AUTO_CHECKS_P RETURN NUMBER;

  FUNCTION C_OLD_MANUAL_CHECKS_P RETURN NUMBER;

  FUNCTION C_OLD_DISCOUNTS_P RETURN NUMBER;

  FUNCTION C_OLD_DISCOUNT_DLR_P RETURN NUMBER;

  FUNCTION C_OLD_VOID_P RETURN NUMBER;

  FUNCTION C_OLD_STOPPED_P RETURN NUMBER;

  FUNCTION C_OLD_SPOILED_P RETURN NUMBER;

  FUNCTION C_OLD_OUTSTANDING_P RETURN NUMBER;

  FUNCTION C_OLD_CLEARED_P RETURN NUMBER;

  FUNCTION C_OLD_CLEARED_DLR_P RETURN NUMBER;

  FUNCTION C_OLD_AUTO_CHECKS_DLR_P RETURN NUMBER;

  FUNCTION C_OLD_MANUAL_CHECKS_DLR_P RETURN NUMBER;

  FUNCTION C_AVERAGE_SITES_P RETURN NUMBER;

  FUNCTION C_AVERAGE_LINES_P RETURN NUMBER;

  FUNCTION C_AVERAGE_PAY_INV_P RETURN NUMBER;

  FUNCTION C_AVERAGE_PAY_CHK_P RETURN NUMBER;

  FUNCTION C_AVERAGE_MH_P RETURN NUMBER;

  FUNCTION C_TOTAL_SITE_P RETURN NUMBER;

  FUNCTION C_TOTAL_NEW_EXCEPTIONS_P RETURN NUMBER;

  FUNCTION C_TOTAL_OLD_EXCEPTIONS_P RETURN NUMBER;

  FUNCTION C_TOTAL_TOTAL_EXCEPTIONS_P RETURN NUMBER;

  FUNCTION C_TOTAL_NEW_EXCEPTIONS_DLR_P RETURN NUMBER;

  FUNCTION C_TOTAL_OLD_EXCEPTIONS_DLR_P RETURN NUMBER;

  FUNCTION C_TOTAL_TOTAL_EXCEPTIONS_DLR_P RETURN NUMBER;

  FUNCTION C_TOTAL_NEW_CHECKS_P RETURN NUMBER;

  FUNCTION C_TOTAL_OLD_CHECKS_P RETURN NUMBER;

  FUNCTION C_TOTAL_TOTAL_CHECKS_P RETURN NUMBER;

  FUNCTION C_TOTAL_NEW_CHECKS_DLR_P RETURN NUMBER;

  FUNCTION C_TOTAL_OLD_CHECKS_DLR_P RETURN NUMBER;

  FUNCTION C_TOTAL_TOTAL_CHECKS_DLR_P RETURN NUMBER;

  FUNCTION C_PERCENT_VENDORS_P RETURN NUMBER;

  FUNCTION C_PERCENT_SITES_P RETURN NUMBER;

  FUNCTION C_PERCENT_ONE_TIME_P RETURN NUMBER;

  FUNCTION C_PERCENT_1099_P RETURN NUMBER;

  FUNCTION C_PERCENT_VENDORS_HELD_P RETURN NUMBER;

  FUNCTION C_PERCENT_INACTIVE_P RETURN NUMBER;

  FUNCTION C_PERCENT_INVOICES_P RETURN NUMBER;

  FUNCTION C_PERCENT_INVOICES_DLR_P RETURN NUMBER;

  FUNCTION C_PERCENT_MATCHED_P RETURN NUMBER;

  FUNCTION C_PERCENT_MATCHED_DLR_P RETURN NUMBER;

  FUNCTION C_PERCENT_DISTS_P RETURN NUMBER;

  FUNCTION C_PERCENT_SCHEDULED_P RETURN NUMBER;

  FUNCTION C_PERCENT_BATCHES_P RETURN NUMBER;

  FUNCTION C_PERCENT_INVOICE_HOLDS_P RETURN NUMBER;

  FUNCTION C_PERCENT_INVOICE_HOLDS_DLR_P RETURN NUMBER;

  FUNCTION C_PERCENT_MH_P RETURN NUMBER;

  FUNCTION C_PERCENT_MH_DLR_P RETURN NUMBER;

  FUNCTION C_PERCENT_MAN_CHECKS_P RETURN NUMBER;

  FUNCTION C_PERCENT_MAN_CHECKS_DLR_P RETURN NUMBER;

  FUNCTION C_PERCENT_AUTO_CHECKS_P RETURN NUMBER;

  FUNCTION C_PERCENT_AUTO_CHECKS_DLR_P RETURN NUMBER;

  FUNCTION C_PERCENT_PAID_INV_P RETURN NUMBER;

  FUNCTION C_PERCENT_DISCS_P RETURN NUMBER;

  FUNCTION C_PERCENT_DISCS_DLR_P RETURN NUMBER;

  FUNCTION C_PERCENT_VOIDED_P RETURN NUMBER;

  FUNCTION C_PERCENT_STOPPED_P RETURN NUMBER;

  FUNCTION C_PERCENT_SPOILED_P RETURN NUMBER;

  FUNCTION C_PERCENT_OUTSTANDING_P RETURN NUMBER;

  FUNCTION C_PERCENT_CLEARED_P RETURN NUMBER;

  FUNCTION C_PERCENT_CLEARED_DLR_P RETURN NUMBER;

  FUNCTION C_PERCENT_TOTAL_EXCEPTIONS_P RETURN NUMBER;

  FUNCTION C_PERCENT_TOTAL_EXCEPTIONS_DL RETURN NUMBER;

  FUNCTION C_PERCENT_TOTAL_CHECKS_P RETURN NUMBER;

  FUNCTION C_PERCENT_TOTAL_CHECKS_DLR_P RETURN NUMBER;

  FUNCTION C_NLS_NA_P RETURN VARCHAR2;

  FUNCTION C_PRIOR_PERIOD_EXISTS_P RETURN VARCHAR2;

  FUNCTION C_NLS_END_OF_REPORT_P RETURN VARCHAR2;

  FUNCTION C_PRIOR_OLD_VENDOR_SITES_P RETURN NUMBER;

  FUNCTION C_PERCENT_ADDITIONAL_SITES_P RETURN NUMBER;

  FUNCTION C_TOTAL_ADDITIONAL_SITES_P RETURN NUMBER;

  FUNCTION C_PRIOR_VENDORS_UPDATED_P RETURN NUMBER;

  FUNCTION C_PRIOR_SITES_UPDATED_P RETURN NUMBER;

  FUNCTION C_PERCENT_VENDORS_UPDATED_P RETURN NUMBER;

  FUNCTION C_PERCENT_SITES_UPDATED_P RETURN NUMBER;

  FUNCTION C_TOTAL_VENDORS_UPDATED_P RETURN NUMBER;

  FUNCTION C_TOTAL_SITES_UPDATED_P RETURN NUMBER;

  FUNCTION C_SYSTEM_USER_NAME_P RETURN VARCHAR2;

  FUNCTION C_TOTAL_REFUND_CHECKS_P RETURN NUMBER;

  FUNCTION C_TOTAL_REFUND_CHECKS_DLR_P RETURN NUMBER;

  FUNCTION C_TOTAL_OUTSTANDING_DLR_P RETURN NUMBER;

  FUNCTION C_NEW_OUTSTANDING_DLR_P RETURN NUMBER;

  FUNCTION C_NEW_REFUND_PAYMENTS_P RETURN NUMBER;

  FUNCTION C_NEW_REFUND_PAYMENTS_DLR_P RETURN NUMBER;

  FUNCTION C_OLD_OUTSTANDING_DLR_P RETURN NUMBER;

  FUNCTION C_OLD_REFUND_PAYMENTS_P RETURN NUMBER;

  FUNCTION C_OLD_REFUND_PAYMENTS_DLR_P RETURN NUMBER;

  FUNCTION C_PERCENT_OUTSTANDING_DLR_P RETURN NUMBER;

  FUNCTION C_PERCENT_REFUND_CHECKS_P RETURN NUMBER;

  FUNCTION C_PERCENT_REFUND_CHECKS_DLR_P RETURN NUMBER;

  FUNCTION C_NEW_LINES_P RETURN NUMBER;

  FUNCTION C_OLD_LINES_P RETURN NUMBER;

  FUNCTION C_PERCENT_LINES_P RETURN NUMBER;

  FUNCTION C_TOTAL_LINES_P RETURN NUMBER;

  FUNCTION C_OLD_LINES_VAR_COUNT_P RETURN NUMBER;

  FUNCTION C_OLD_LINES_VAR_AMOUNT_P RETURN NUMBER;

  FUNCTION C_LINE_TOTAL_VARS_P RETURN NUMBER;

  FUNCTION C_LINE_TOTAL_VARS_DLR_P RETURN NUMBER;

  FUNCTION C_LINE_VAR_COUNT_P RETURN NUMBER;

  FUNCTION C_LINE_VAR_AMOUNT_P RETURN NUMBER;

  FUNCTION C_OLD_DISTS_VAR_COUNT_P RETURN NUMBER;

  FUNCTION C_OLD_DISTS_VAR_AMOUNT_P RETURN NUMBER;

  FUNCTION C_DIST_TOTAL_VARS_P RETURN NUMBER;

  FUNCTION C_DIST_TOTAL_VARS_DLR_P RETURN NUMBER;

  FUNCTION C_DIST_VAR_COUNT_P RETURN NUMBER;

  FUNCTION C_DIST_VAR_AMOUNT_P RETURN NUMBER;

  FUNCTION C_PERCENT_LINE_VARS_P RETURN NUMBER;

  FUNCTION C_PERCENT_DIST_VARS_P RETURN NUMBER;

  FUNCTION C_PERCENT_LINE_VARS_DLR_P RETURN NUMBER;

  FUNCTION C_PERCENT_DIST_VARS_DLR_P RETURN NUMBER;

  FUNCTION C_AVERAGE_DISTS_P RETURN NUMBER;

  FUNCTION C_ORG_ID_P RETURN NUMBER;

END AP_APXKIRKI_XMLP_PKG;


/
