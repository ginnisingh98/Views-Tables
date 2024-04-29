--------------------------------------------------------
--  DDL for Package JA_JAINBOER_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_JAINBOER_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JAINBOERS.pls 120.1 2007/12/25 16:14:30 dwkrishn noship $ */
  P_BOE_TYPE VARCHAR2(25);
  P_BOE_NO NUMBER;
  P_START_DATE DATE;
  P_END_DATE DATE;
   P_START_DATE1 VARCHAR2(30);
  P_END_DATE1 VARCHAR2(30);
  P_FLEX_ACC VARCHAR2(31000);
  P_CHART_OF_ACCOUNTS_ID NUMBER;
  P_TEMP_AMT NUMBER := 0;
  P_TEMP_ID NUMBER := -1;
  P_TEMP_AMT1 NUMBER := 0;
  P_CONC_REQUEST_ID NUMBER;
  P_LEGAL_ENTITY NUMBER;
  FUNCTION CF_BOE_CLOSINGFORMULA(BOE_AMOUNT IN NUMBER
                                ,AMOUNT_APPLIED IN NUMBER
                                ,WRITE_OFF_AMOUNT IN NUMBER) RETURN VARCHAR2;
  FUNCTION CF_ACCOUNTFORMULA(CHART_OF_ACCOUNTS_ID IN NUMBER
                            ,CUSTOMS_WRITE_OFF_ACCOUNT IN NUMBER) RETURN VARCHAR2;
  FUNCTION CF_TEMP_CALFORMULA(BOE_ID IN NUMBER
                             ,WRITE_OFF_AMOUNT IN NUMBER) RETURN NUMBER;
  FUNCTION BALANCE(V_BOE_ID IN NUMBER) RETURN NUMBER;
  FUNCTION CF_SOB_NAMEFORMULA RETURN VARCHAR2;
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
END JA_JAINBOER_XMLP_PKG;



/