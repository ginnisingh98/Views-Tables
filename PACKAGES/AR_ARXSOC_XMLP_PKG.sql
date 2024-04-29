--------------------------------------------------------
--  DDL for Package AR_ARXSOC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXSOC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXSOCS.pls 120.0 2007/12/27 14:09:44 abraghun noship $ */
  P_CONC_REQUEST_ID NUMBER := 0;
  P_DATE_LOW DATE;
  P_DATE_HIGH DATE;
  P_DATE_LOW1 varchar2(10);
  P_DATE_HIGH1 varchar2(10);
  P_BANK_ACCOUNT_NAME_LOW VARCHAR2(80);
  P_BANK_ACCOUNT_NAME_HIGH VARCHAR2(80);
  P_ORDER_BY VARCHAR2(32767);
  P_ORDER_BY_1 VARCHAR2(32767);
  P_SET_OF_BOOKS_ID NUMBER;
  LP_BANK_ACCOUNT_NAME_LOW VARCHAR2(800):=' ';
  LP_BANK_ACCOUNT_NAME_HIGH VARCHAR2(800):=' ';
  LP_DATE_LOW VARCHAR2(200):=' ';
  LP_DATE_HIGH VARCHAR2(200):=' ';
  P_BANK_COUNT NUMBER := 0;
  PH_ORDER_BY VARCHAR2(32767);
  P_ACTUAL_AMOUNT NUMBER;
  P_UNIDENTIFIED_AMOUNT NUMBER;
  P_MISC_AMOUNT NUMBER;
  P_NSF_AMOUNT NUMBER;
  P_APPLIED_COUNT NUMBER := 0;
  P_UNAPPLIED_COUNT NUMBER;
  P_UNIDENTIFIED_COUNT NUMBER;
  P_MISC_COUNT NUMBER;
  PA_ACTUAL_AMOUNT NUMBER;
  PA_UNIDENTIFIED_AMOUNT NUMBER;
  PA_MISC_AMOUNT NUMBER;
  PA_NSF_AMOUNT NUMBER;
  PA_APPLIED_COUNT NUMBER := 0;
  PA_UNAPPLIED_COUNT NUMBER;
  PA_UNIDENTIFIED_COUNT NUMBER;
  PA_MISC_COUNT NUMBER;
  RP_COMPANY_NAME VARCHAR2(50);
  RP_REPORT_NAME VARCHAR2(80);
  RP_DATA_FOUND3 VARCHAR2(300);
  RP_DATE_RANGE VARCHAR2(200);
  RP_DATA_FOUND1 VARCHAR2(300);
  RP_DATA_FOUND2 VARCHAR2(300);
  RP_ORDER_BY VARCHAR2(80);
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION REPORT_NAMEFORMULA(COMPANY_NAME IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION C_DIFFERENCE_AMOUNTFORMULA(C_RCPT_CONTROL_AMOUNT IN NUMBER
                                     ,C_ACTUAL_AMOUNT IN NUMBER) RETURN NUMBER;
  FUNCTION C_SUMMARY_LABELFORMULA(CURRENCY_A IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION CA_DIFFERENCE_AMOUNTFORMULA(C_RCPT_CONTROL_AMOUNT_B IN NUMBER
                                      ,CA_ACTUAL_AMOUNT IN NUMBER) RETURN NUMBER;
  FUNCTION CA_SUMMARY_LABELFORMULA(CURRENCY_B IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION CF_DATA_NOT_FOUNDFORMULA(BANK_ACCOUNT_NAME_C IN VARCHAR2) RETURN NUMBER;
  FUNCTION CR_DATA_FOUNDFORMULA(CURRENCY_B IN VARCHAR2) RETURN NUMBER;
  FUNCTION CM_DATA_NOT_FOUNDFORMULA(CURRENCY_A IN VARCHAR2) RETURN NUMBER;
  FUNCTION AFTERPFORM RETURN BOOLEAN;
  FUNCTION F_AMOUNTSFORMULA(AMOUNT IN NUMBER
                           ,CR_STATUS IN VARCHAR2
                           ,CR_TYPE IN VARCHAR2
                           ,REVERSAL_CATEGORY IN VARCHAR2
                           ,CASH_RECEIPT_ID IN NUMBER) RETURN NUMBER;
  FUNCTION F_ALL_AMOUNTSFORMULA(AMOUNT_B IN NUMBER
                               ,CR_STATUS_BB IN VARCHAR2
                               ,CR_TYPE_B IN VARCHAR2
                               ,REVERSAL_CATEGORY_B IN VARCHAR2
                               ,CASH_RECEIPT_ID_B IN NUMBER) RETURN NUMBER;
  FUNCTION C_APPLIED_AMOUNTFORMULA(C_APPLIED_AMOUNT_A IN NUMBER
                                  ,C_MISC_AMOUNT IN NUMBER) RETURN NUMBER;
  FUNCTION CA_APPLIED_AMOUNTFORMULA(CA_APPLIED_AMOUNT_B IN NUMBER
                                   ,CA_MISC_AMOUNT IN NUMBER) RETURN NUMBER;
  FUNCTION ORDER_BY_MEANINGFORMULA RETURN VARCHAR2;
  FUNCTION P_ACTUAL_AMOUNT_P RETURN NUMBER;
  FUNCTION P_UNIDENTIFIED_AMOUNT_P RETURN NUMBER;
  FUNCTION P_MISC_AMOUNT_P RETURN NUMBER;
  FUNCTION P_NSF_AMOUNT_P RETURN NUMBER;
  FUNCTION P_APPLIED_COUNT_P RETURN NUMBER;
  FUNCTION P_UNAPPLIED_COUNT_P RETURN NUMBER;
  FUNCTION P_UNIDENTIFIED_COUNT_P RETURN NUMBER;
  FUNCTION P_MISC_COUNT_P RETURN NUMBER;
  FUNCTION PA_ACTUAL_AMOUNT_P RETURN NUMBER;
  FUNCTION PA_UNIDENTIFIED_AMOUNT_P RETURN NUMBER;
  FUNCTION PA_MISC_AMOUNT_P RETURN NUMBER;
  FUNCTION PA_NSF_AMOUNT_P RETURN NUMBER;
  FUNCTION PA_APPLIED_COUNT_P RETURN NUMBER;
  FUNCTION PA_UNAPPLIED_COUNT_P RETURN NUMBER;
  FUNCTION PA_UNIDENTIFIED_COUNT_P RETURN NUMBER;
  FUNCTION PA_MISC_COUNT_P RETURN NUMBER;
  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2;
  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2;
  FUNCTION RP_DATA_FOUND3_P RETURN VARCHAR2;
  FUNCTION RP_DATE_RANGE_P RETURN VARCHAR2;
  FUNCTION RP_DATA_FOUND1_P RETURN VARCHAR2;
  FUNCTION RP_DATA_FOUND2_P RETURN VARCHAR2;
  FUNCTION RP_ORDER_BY_P RETURN VARCHAR2;
END AR_ARXSOC_XMLP_PKG;


/
