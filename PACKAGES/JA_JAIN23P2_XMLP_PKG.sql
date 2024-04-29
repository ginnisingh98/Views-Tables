--------------------------------------------------------
--  DDL for Package JA_JAIN23P2_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_JAIN23P2_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JAIN23P2S.pls 120.1 2007/12/25 16:08:19 dwkrishn noship $ */
  P_ORGANIZATION_ID NUMBER;
  P_LOCATION_ID NUMBER;
  P_TRN_FROM_DATE DATE;
  P_OPEN_BAL NUMBER;
  P_OPEN_BAL_OTH NUMBER;
  P_TRN_TO_DATE DATE;
  P_CLOSE_BAL NUMBER;
  P_PREV_CLOSE_BAL NUMBER;
  P_FIRST_REC VARCHAR2(1);
  P_START_PAGE_NO NUMBER;
  P_CONC_REQUEST_ID NUMBER;
  P_QUERY_CONCAT VARCHAR2(1000);
  P_REGISTER_TYPE VARCHAR2(1);
  P_SELECTED_REGISTER_TYPE VARCHAR2(1000);
  P_REPORT_SEQ_NO NUMBER := 0;
  P_CVD_EDU_CESS_OP_BAL NUMBER;
  P_EXC_EDU_CESS_OP_BAL NUMBER;
  P_CVD_EDU_SH_CESS_OP_BAL NUMBER;
  P_EXC_EDU_SH_CESS_OP_BAL NUMBER;
  CP_ADDITIONAL_ROUNDING NUMBER := 0;
  CP_ADDITIONALCVD_ROUNDING NUMBER := 0;
  CP_OTHER_ROUNDING NUMBER := 0;
  CP_ROUNDED_EXCISE_CESS NUMBER;
  CP_ROUNDED_SH_EXCISE_CESS NUMBER;
  CP_ROUNDED_CVD_CESS NUMBER;
  CP_ROUNDED_SH_CVD_CESS NUMBER;
  CP_RND_DR_BASIC_ED NUMBER;
  CP_RND_DR_ADDL_ED NUMBER;
  CP_RND_DR_ADDL_CVD NUMBER;
  CP_RND_DR_OTHER_ED NUMBER;
  CP_RND_DR_EXC_EDU_CESS NUMBER;
  CP_RND_DR_SH_CVD_EDU_CESS NUMBER;
  CP_RND_DR_CVD_EDU_CESS NUMBER;
  CP_RND_DR_SH_EXC_EDU_CESS NUMBER;
  CP_1 NUMBER;
  C_NAME VARCHAR2(240);
  C_DESCRIPTION VARCHAR2(240);
  C_ADDRESS_LINE_1 VARCHAR2(240);
  C_ADDRESS_LINE_2 VARCHAR2(240);
  C_ADDRESS_LINE_3 VARCHAR2(240);
  C_EC_CODE VARCHAR2(50);
  C_EXCISECOMM VARCHAR2(50);
  C_EXCISEDIVISION VARCHAR2(50);
  C_EXCISECIRCLE VARCHAR2(50);
  C_EXCISERANGE VARCHAR2(50);
  CP_REPORT_TITLE VARCHAR2(50);
  FUNCTION AFTERPFORM RETURN BOOLEAN;
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION CF_DIVISION_NOFORMULA(VENDOR_ID IN NUMBER
                                ,VENDOR_SITE_ID IN NUMBER
                                ,RECEIPT_ID IN VARCHAR2
                                ,DIVISION_NO IN VARCHAR2) RETURN CHAR;
  FUNCTION CF_RANGE_NOFORMULA(VENDOR_ID IN NUMBER
                             ,VENDOR_SITE_ID IN NUMBER
                             ,RECEIPT_ID IN VARCHAR2
                             ,RANGE_NO IN VARCHAR2) RETURN CHAR;
  FUNCTION CF_EC_CODE_SUPPFORMULA(VENDOR_ID IN NUMBER
                                 ,VENDOR_SITE_ID IN NUMBER
                                 ,CR_BASIC_ED IN NUMBER
                                 ,CR_ADDITIONAL_ED IN NUMBER
                                 ,CR_ADDITIONAL_CVD IN NUMBER
                                 ,CR_OTHER_ED IN NUMBER
                                 ,RECEIPT_ID IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION CF_EC_CODE_CUSTFORMULA(CUSTOMER_ID_1 IN NUMBER
                                 ,CUSTOMER_SITE_ID IN NUMBER
                                 ,DR_BASIC_ED IN NUMBER
                                 ,DR_ADDITIONAL_ED IN NUMBER
                                 ,DR_OTHER_ED IN NUMBER) RETURN VARCHAR2;
  FUNCTION CF_SEQUENCE_NOFORMULA RETURN NUMBER;
  FUNCTION CF_ROUNDING_AMOUNTFORMULA(TRANSACTION_ID IN NUMBER
                                    ,EXCISE_INVOICE_NO IN VARCHAR2
                                    ,EXCISE_INVOICE_DATE IN DATE
                                    ,RECEIPT_ID IN VARCHAR2) RETURN NUMBER;
  FUNCTION CF_CR_BASIC_EDFORMULA(CR_BASIC_ED IN NUMBER
                                ,CF_ROUNDING_AMOUNT IN NUMBER) RETURN NUMBER;
  FUNCTION CF_RECEIPT_NUMFORMULA(EXCISE_INVOICE_NO_1 IN VARCHAR2
                                ,EXCISE_INVOICE_DATE_1 IN DATE
                                ,RECEIPT_ID IN VARCHAR2
                                ,TRANSACTION_ID IN NUMBER) RETURN VARCHAR2;
  FUNCTION CF_FOLIO_PART_IFORMULA(P_EXCISE_INVOICE_NO IN VARCHAR2
                                 ,P_EXCISE_INVOICE_DATE IN DATE) RETURN VARCHAR2;
  FUNCTION CF_CLOSING_BALFORMULA(CS_CR_BASIC_ED IN NUMBER
                                ,CS_CR_ADDL_ED IN NUMBER
                                ,CS_CR_OTHER_ED IN NUMBER
                                ,CS_CR_ADDL_CVD IN NUMBER
                                ,CS_DR_BASIC_ED IN NUMBER
                                ,CS_DR_ADDL_N_OTH IN NUMBER
                                ,CS_DR_ADDL_CVD IN NUMBER) RETURN NUMBER;
  FUNCTION CF_EXC_CLOSING_BALANCEFORMULA(CS_CR_EXCISE IN NUMBER
                                        ,CS_DR_EXCISE IN NUMBER) RETURN NUMBER;
  FUNCTION CF_CR_CVDFORMULA(EXCISE_INVOICE_NO_1 IN VARCHAR2
                           ,EXCISE_INVOICE_DATE_1 IN DATE
                           ,VENDOR_ID_1 IN NUMBER
                           ,VENDOR_SITE_ID_1 IN NUMBER
                           ,CUSTOMER_ID_1 IN NUMBER
                           ,CUSTOMER_SITE_ID_1 IN NUMBER) RETURN NUMBER;
  FUNCTION CF_CR_EXCISEFORMULA(EXCISE_INVOICE_NO_1 IN VARCHAR2
                              ,EXCISE_INVOICE_DATE_1 IN DATE
                              ,VENDOR_ID_1 IN NUMBER
                              ,VENDOR_SITE_ID_1 IN NUMBER
                              ,CUSTOMER_ID_1 IN NUMBER
                              ,CUSTOMER_SITE_ID_1 IN NUMBER) RETURN NUMBER;
  FUNCTION CF_DR_EXCISEFORMULA(OTHER_TAX_DEBIT IN NUMBER) RETURN NUMBER;
  FUNCTION CF_DR_CVDFORMULA RETURN NUMBER;
  FUNCTION CF_REGISTER_IDFORMULA(RECEIPT_ID IN VARCHAR2) RETURN NUMBER;
  FUNCTION CF_CVD_CLOSING_BALFORMULA(CS_CR_CVD IN NUMBER
                                    ,CS_DR_CVD IN NUMBER) RETURN NUMBER;
  FUNCTION CF_OTHER_AMOUNTFORMULA(CR_OTHER_ED IN NUMBER) RETURN NUMBER;
  FUNCTION CF_ADDITIONAL_AMOUNTFORMULA(CR_ADDITIONAL_ED IN NUMBER) RETURN NUMBER;
  FUNCTION CF_DR_BASIC_EDFORMULA(DR_BASIC_ED IN NUMBER) RETURN NUMBER;
  FUNCTION CF_DR_ADDL_N_OTH_EDFORMULA(DR_ADDL_N_OTH_ED IN NUMBER) RETURN NUMBER;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION CF_ADDITIONALCVD_AMOUNTFORMULA(CR_ADDITIONAL_CVD IN NUMBER) RETURN NUMBER;
  FUNCTION CF_DR_ADDL_CVDFORMULA(DR_ADDITIONAL_CVD IN NUMBER) RETURN NUMBER;
  FUNCTION CF_CR_SH_CVDFORMULA(EXCISE_INVOICE_NO_1 IN VARCHAR2
                              ,EXCISE_INVOICE_DATE_1 IN DATE
                              ,VENDOR_ID_1 IN NUMBER
                              ,VENDOR_SITE_ID_1 IN NUMBER
                              ,CUSTOMER_ID_1 IN NUMBER
                              ,CUSTOMER_SITE_ID_1 IN NUMBER
                              ,TRANSACTION_ID IN NUMBER) RETURN NUMBER;
  FUNCTION CF_CR_SH_EXCISEFORMULA(EXCISE_INVOICE_NO_1 IN VARCHAR2
                                 ,EXCISE_INVOICE_DATE_1 IN DATE
                                 ,VENDOR_ID_1 IN NUMBER
                                 ,VENDOR_SITE_ID_1 IN NUMBER
                                 ,CUSTOMER_ID_1 IN NUMBER
                                 ,CUSTOMER_SITE_ID_1 IN NUMBER
                                 ,TRANSACTION_ID IN NUMBER) RETURN NUMBER;
  FUNCTION CF_DR_SH_EXCISEFORMULA(EXCISE_INVOICE_NO_1 IN VARCHAR2
                                 ,EXCISE_INVOICE_DATE_1 IN DATE
                                 ,VENDOR_ID_1 IN NUMBER
                                 ,VENDOR_SITE_ID_1 IN NUMBER
                                 ,CUSTOMER_ID_1 IN NUMBER
                                 ,CUSTOMER_SITE_ID_1 IN NUMBER
                                 ,TRANSACTION_ID IN NUMBER) RETURN NUMBER;
  FUNCTION CF_DR_SH_CVDFORMULA(EXCISE_INVOICE_NO_1 IN VARCHAR2
                              ,EXCISE_INVOICE_DATE_1 IN DATE
                              ,VENDOR_ID_1 IN NUMBER
                              ,VENDOR_SITE_ID_1 IN NUMBER
                              ,CUSTOMER_ID_1 IN NUMBER
                              ,CUSTOMER_SITE_ID_1 IN NUMBER
                              ,TRANSACTION_ID IN NUMBER) RETURN NUMBER;
  FUNCTION CF_SH_CVD_CLOSING_BALANCEFORMU(CS_CR_SH_CVD IN NUMBER
                                         ,CS_DR_SH_CVD IN NUMBER) RETURN NUMBER;
  FUNCTION CF_SH_EXC_CLOSING_BALANCEFORMU(CS_CR_SH_EXCISE IN NUMBER
                                         ,CS_DR_SH_EXCISE IN NUMBER) RETURN NUMBER;
  FUNCTION CP_ADDITIONAL_ROUNDING_P RETURN NUMBER;
  FUNCTION CP_ADDITIONALCVD_ROUNDING_P RETURN NUMBER;
  FUNCTION CP_OTHER_ROUNDING_P RETURN NUMBER;
  FUNCTION CP_ROUNDED_EXCISE_CESS_P RETURN NUMBER;
  FUNCTION CP_ROUNDED_SH_EXCISE_CESS_P RETURN NUMBER;
  FUNCTION CP_ROUNDED_CVD_CESS_P RETURN NUMBER;
  FUNCTION CP_ROUNDED_SH_CVD_CESS_P RETURN NUMBER;
  FUNCTION CP_RND_DR_BASIC_ED_P RETURN NUMBER;
  FUNCTION CP_RND_DR_ADDL_ED_P RETURN NUMBER;
  FUNCTION CP_RND_DR_ADDL_CVD_P RETURN NUMBER;
  FUNCTION CP_RND_DR_OTHER_ED_P RETURN NUMBER;
  FUNCTION CP_RND_DR_EXC_EDU_CESS_P RETURN NUMBER;
  FUNCTION CP_RND_DR_SH_CVD_EDU_CESS_P RETURN NUMBER;
  FUNCTION CP_RND_DR_CVD_EDU_CESS_P RETURN NUMBER;
  FUNCTION CP_RND_DR_SH_EXC_EDU_CESS_P RETURN NUMBER;
  FUNCTION CP_1_P RETURN NUMBER;
  FUNCTION C_NAME_P RETURN VARCHAR2;
  FUNCTION C_DESCRIPTION_P RETURN VARCHAR2;
  FUNCTION C_ADDRESS_LINE_1_P RETURN VARCHAR2;
  FUNCTION C_ADDRESS_LINE_2_P RETURN VARCHAR2;
  FUNCTION C_ADDRESS_LINE_3_P RETURN VARCHAR2;
  FUNCTION C_EC_CODE_P RETURN VARCHAR2;
  FUNCTION C_EXCISECOMM_P RETURN VARCHAR2;
  FUNCTION C_EXCISEDIVISION_P RETURN VARCHAR2;
  FUNCTION C_EXCISECIRCLE_P RETURN VARCHAR2;
  FUNCTION C_EXCISERANGE_P RETURN VARCHAR2;
  FUNCTION CP_REPORT_TITLE_P RETURN VARCHAR2;
  V_LAST_PAGE VARCHAR2(1) := 'F';
END JA_JAIN23P2_XMLP_PKG;


/