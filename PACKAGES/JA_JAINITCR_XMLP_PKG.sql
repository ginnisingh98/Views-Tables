--------------------------------------------------------
--  DDL for Package JA_JAINITCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_JAINITCR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JAINITCRS.pls 120.1 2007/12/25 16:21:53 dwkrishn noship $ */
  P_VENDOR_ID NUMBER;

  P_FROM_DATE DATE;

  P_TO_DATE DATE;

  P_CERTIFICATE_START_NO NUMBER;

  P_CERTIFICATE_END_NO NUMBER;

  P_PLACE VARCHAR2(40);

  P_NAME VARCHAR2(60);

  P_DESIGNATION VARCHAR2(40);

  P_ORGANIZATION_ID NUMBER;

  P_FIN_YEAR NUMBER;

  P_ORG_TAN_NUM VARCHAR2(50);

  P_CONC_REQUEST_ID NUMBER;

  P_SELECTED_CERT_DATE VARCHAR2(1000);

  P_SELECTED_CERT_ID VARCHAR2(1000);

  P_SELECTED_VENDOR VARCHAR2(1000);

  P_ACK_NUM_FOR_QUART_ONE VARCHAR2(70);

  P_ACK_NUM_FOR_QUART_TWO VARCHAR2(70);

  P_ACK_NUM_FOR_QUART_THREE VARCHAR2(70);

  P_ACK_NUM_FOR_QUART_FOUR VARCHAR2(70);

  CP_CESS_AMT NUMBER;

  CP_SURCHARGE_AMT NUMBER;

  CP_SH_CESS_AMT NUMBER;

  CP_1 VARCHAR2(32767);

  FUNCTION CONVERT_NUMBER(IN_NUMERAL IN INTEGER := 0) RETURN VARCHAR2;

  FUNCTION CF_3FORMULA(CS_TDS_AMOUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION BANK_BRANCHFORMULA(C_CHQ IN VARCHAR2
                             ,TDS_INVOICE_ID IN NUMBER
                             ,TDS_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_1FORMULA RETURN VARCHAR2;

  FUNCTION CF_2FORMULA RETURN VARCHAR2;

  FUNCTION CP_1FORMULA RETURN CHAR;

  FUNCTION CF_VEN_PAN_NOFORMULA(VEN_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_CHECK_DEP_DATEFORMULA(CHQ IN NUMBER) RETURN DATE;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION F_SELECTED_CERT_DATE RETURN VARCHAR2;

  FUNCTION F_SELECTED_CERT_ID RETURN VARCHAR2;

  FUNCTION F_SELECTED_VENDOR RETURN VARCHAR2;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION CF_TDS_AMTFORMULA(TDS_INVOICE_ID IN NUMBER
                            ,TDS_INVOICE_AMT IN NUMBER) RETURN NUMBER;

  FUNCTION CF_BSR_CODEFORMULA(BANK_ACCOUNT_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION CP_CESS_AMT_P RETURN NUMBER;

  FUNCTION CP_SURCHARGE_AMT_P RETURN NUMBER;

  FUNCTION CP_SH_CESS_AMT_P RETURN NUMBER;

  FUNCTION CP_1_P RETURN VARCHAR2;

END JA_JAINITCR_XMLP_PKG;




/
