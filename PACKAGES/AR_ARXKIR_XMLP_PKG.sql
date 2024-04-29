--------------------------------------------------------
--  DDL for Package AR_ARXKIR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXKIR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXKIRS.pls 120.0 2007/12/27 13:55:31 abraghun noship $ */
  P_SET_OF_BOOKS_ID VARCHAR2(40);

  P_CURRENT_PERIOD VARCHAR2(40);

  P_PRIOR_PERIOD VARCHAR2(40);

  P_CONC_REQUEST_ID NUMBER;

  P_PRIOR_PAST_DUE_AMOUNT NUMBER;

  P_PRIOR_PAST_DUE_COUNT NUMBER;

  CURRENT_GL_DATE VARCHAR2(40);

  P_CURRENT_CUSTOMER_COUNT NUMBER;

  P_PRIOR_CUSTOMER_COUNT NUMBER;

  P_CURRENT_YEAR_CUSTOMER_COUNT NUMBER;

  P_CURRENT_LOCATION_COUNT NUMBER;

  P_PRIOR_LOCATION_COUNT NUMBER;

  P_PRIOR_YEAR_COUNT NUMBER;

  P_CURRENT_ON_HOLD_Y_COUNT NUMBER;

  P_PRIOR_ON_HOLD_Y_COUNT NUMBER;

  P_YEAR_ON_HOLD_Y_COUNT NUMBER;

  P_CURRENT_ON_HOLD_N_COUNT NUMBER;

  P_PRIOR_ON_HOLD_N_COUNT NUMBER;

  P_YEAR_ON_HOLD_N_COUNT NUMBER;

  P_CURRENT_PAY_PER_DAY NUMBER;

  P_PRIOR_PAY_PER_DAY NUMBER;

  P_PRIOR_BATCH_PER_DAY NUMBER;

  P_CURRENT_BATCH_PER_DAY NUMBER;

  P_CURRENT_PAY_PER_BATCH NUMBER;

  P_PRIOR_PAY_PER_BATCH NUMBER;

  PC_LOCATION_COUNT VARCHAR2(240);

  PC_BATCH_PER_DAY_COUNT VARCHAR2(240);

  PC_PAY_PER_BATCH VARCHAR2(240);

  PC_PAY_PER_DAY VARCHAR2(240);

  PC_CUSTOMER_COUNT VARCHAR2(240);

  C_PRIOR_PAST_DUE_COUNT NUMBER;

  C_PRIOR_PAST_DUE_AMOUNT NUMBER;

  FUNCTION C_1FORMULA(CURRENT_PERIOD IN VARCHAR2
                     ,PRIOR_PERIOD IN VARCHAR2
                     ,CURRENT_YEAR IN NUMBER
                     ,SET_OF_BOOKS_ID_LP IN VARCHAR2
                     ,CURRENT_END_DATE IN DATE
                     ,CURRENT_START_DATE IN DATE
                     ,PRIOR_END_DATE IN DATE
                     ,PRIOR_START_DATE IN DATE) RETURN NUMBER;

  FUNCTION PC_ON_HOLD_N_COUNTFORMULA RETURN VARCHAR2;

  FUNCTION PC_ON_HOLD_Y_COUNTFORMULA RETURN VARCHAR2;

  FUNCTION PC_NEW_INVOICES_COUNTFORMULA(PRIOR_NEW_INVOICES_COUNT IN NUMBER
                                       ,CURRENT_NEW_INVOICES_COUN IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_NEW_INVOICES_AMOUNTFORMULA(PRIOR_NEW_INVOICES_AMOUNT IN NUMBER
                                        ,CURRENT_NEW_INVOICES_AMOU IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_NEW_CREDIT_COUNTFORMULA(PRIOR_NEW_CREDIT_COUNT IN NUMBER
                                     ,CURRENT_NEW_CREDIT_COUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_NEW_CREDIT_AMOUNTFORMULA(PRIOR_NEW_CREDIT_AMOUNT IN NUMBER
                                      ,CURRENT_NEW_CREDIT_AMOUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_DUE_COUNTFORMULA(PRIOR_DUE_COUNT IN NUMBER
                              ,CURRENT_DUE_COUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_DUE_AMOUNTFORMULA(PRIOR_DUE_AMOUNT IN NUMBER
                               ,CURRENT_DUE_AMOUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_PAST_DUE_AMOUNTFORMULA(CURRENT_PAST_DUE_AMOUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_PAST_DUE_COUNTFORMULA(CURRENT_PAST_DUE_COUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_QC_COUNTFORMULA(PRIOR_QC_COUNT IN NUMBER
                             ,CURRENT_QC_COUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_QC_AMOUNTFORMULA(PRIOR_QC_AMOUNT IN NUMBER
                              ,CURRENT_QC_AMOUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_C_COUNTFORMULA(PRIOR_C_COUNT IN NUMBER
                            ,CURRENT_C_COUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_C_AMOUNTFORMULA(PRIOR_C_AMOUNT IN NUMBER
                             ,CURRENT_C_AMOUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_CR_COUNTFORMULA(PRIOR_CR_COUNT IN NUMBER
                             ,CURRENT_CR_COUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_CR_AMOUNTFORMULA(PRIOR_CR_AMOUNT IN NUMBER
                              ,CURRENT_CR_AMOUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_ADJUST_COUNTFORMULA(PRIOR_ADJUST_COUNT IN NUMBER
                                 ,CURRENT_ADJUST_COUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_ADJUST_AMOUNTFORMULA(PRIOR_ADJUST_AMOUNT IN NUMBER
                                  ,CURRENT_ADJUST_AMOUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_TYPE_AMOUNTFORMULA(PRIOR_TYPE_AMOUNT IN NUMBER
                                ,CURRENT_TYPE_AMOUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_PT_COUNTFORMULA(PRIOR_PT_COUNT IN NUMBER
                             ,CURRENT_PT_COUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_NSF_COUNTFORMULA(PRIOR_NSF_COUNT IN NUMBER
                              ,CURRENT_NSF_COUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_NSF_AMOUNTFORMULA(PRIOR_NSF_AMOUNT IN NUMBER
                               ,CURRENT_NSF_AMOUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_OR_AMOUNTFORMULA(PRIOR_OR_AMOUNT IN NUMBER
                              ,CURRENT_OR_AMOUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_OR_COUNTFORMULA(PRIOR_OR_COUNT IN NUMBER
                             ,CURRENT_OR_COUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_EDT_COUNTFORMULA(PRIOR_EDT_COUNT IN NUMBER
                              ,CURRENT_EDT_COUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_EDT_AMOUNTFORMULA(PRIOR_EDT_AMOUNT IN NUMBER
                               ,CURRENT_EDT_AMOUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_UDT_COUNTFORMULA(PRIOR_UDT_COUNT IN NUMBER
                              ,CURRENT_UDT_COUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC_UDT_AMOUNTFORMULA(PRIOR_UDT_AMOUNT IN NUMBER
                               ,CURRENT_UDT_AMOUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION PC1_CUSTOMER_COUNTFORMULA RETURN VARCHAR2;

  FUNCTION PC1_LOCATION_COUNTFORMULA RETURN VARCHAR2;

  FUNCTION PC1_PAY_PER_BATCHFORMULA RETURN VARCHAR2;

  FUNCTION PC1_PAY_PER_DAYFORMULA RETURN VARCHAR2;

  FUNCTION PC1_BATCH_PER_DAY_COUNTFORMULA RETURN VARCHAR2;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION PC_PRIOR_PAST_DUE_COUNTFORMULA RETURN NUMBER;

  FUNCTION C_COPY_VALUEFORMULA(PRIOR_PAST_DUE_COUNT IN NUMBER
                              ,PRIOR_PAST_DUE_AMOUNT IN NUMBER) RETURN NUMBER;

  FUNCTION P_CURRENT_CUSTOMER_COUNT_P RETURN NUMBER;

  FUNCTION P_PRIOR_CUSTOMER_COUNT_P RETURN NUMBER;

  FUNCTION P_CURRENT_YEAR_CUSTOMER_COUNTF RETURN NUMBER;

  FUNCTION P_CURRENT_LOCATION_COUNT_P RETURN NUMBER;

  FUNCTION P_PRIOR_LOCATION_COUNT_P RETURN NUMBER;

  FUNCTION P_PRIOR_YEAR_COUNT_P RETURN NUMBER;

  FUNCTION P_CURRENT_ON_HOLD_Y_COUNT_P RETURN NUMBER;

  FUNCTION P_PRIOR_ON_HOLD_Y_COUNT_P RETURN NUMBER;

  FUNCTION P_YEAR_ON_HOLD_Y_COUNT_P RETURN NUMBER;

  FUNCTION P_CURRENT_ON_HOLD_N_COUNT_P RETURN NUMBER;

  FUNCTION P_PRIOR_ON_HOLD_N_COUNT_P RETURN NUMBER;

  FUNCTION P_YEAR_ON_HOLD_N_COUNT_P RETURN NUMBER;

  FUNCTION P_CURRENT_PAY_PER_DAY_P RETURN NUMBER;

  FUNCTION P_PRIOR_PAY_PER_DAY_P RETURN NUMBER;

  FUNCTION P_PRIOR_BATCH_PER_DAY_P RETURN NUMBER;

  FUNCTION P_CURRENT_BATCH_PER_DAY_P RETURN NUMBER;

  FUNCTION P_CURRENT_PAY_PER_BATCH_P RETURN NUMBER;

  FUNCTION P_PRIOR_PAY_PER_BATCH_P RETURN NUMBER;

  FUNCTION PC_LOCATION_COUNT_P RETURN VARCHAR2;

  FUNCTION PC_BATCH_PER_DAY_COUNT_P RETURN VARCHAR2;

  FUNCTION PC_PAY_PER_BATCH_P RETURN VARCHAR2;

  FUNCTION PC_PAY_PER_DAY_P RETURN VARCHAR2;

  FUNCTION PC_CUSTOMER_COUNT_P RETURN VARCHAR2;

  FUNCTION C_PRIOR_PAST_DUE_COUNT_P RETURN NUMBER;

  FUNCTION C_PRIOR_PAST_DUE_AMOUNT_P RETURN NUMBER;

END AR_ARXKIR_XMLP_PKG;


/
