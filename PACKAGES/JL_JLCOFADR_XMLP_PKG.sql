--------------------------------------------------------
--  DDL for Package JL_JLCOFADR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_JLCOFADR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JLCOFADRS.pls 120.1 2007/12/25 16:44:46 dwkrishn noship $ */
  P_BOOK VARCHAR2(15);
  P_PERIOD1 VARCHAR2(15);
  P_CONC_REQUEST_ID NUMBER := 0;
  P_MIN_PRECISION NUMBER := 2;
  P_LINE_NUM VARCHAR2(40);
  P_ACCT_CCID VARCHAR2(40);
  P_BATCH_ID VARCHAR2(40);
  ACCOUNTING_FLEX_STRUCTURE NUMBER;
  ACCT_BAL_APROMPT VARCHAR2(50);
  ACCT_CC_APROMPT VARCHAR2(4000);
  CAT_MAJ_APROMPT VARCHAR2(4000);
  CURRENCY_CODE VARCHAR2(15);
  BOOK_CLASS VARCHAR2(15);
  DISTRIBUTION_SOURCE_BOOK VARCHAR2(15);
  PERIOD1_PC NUMBER;
  PERIOD1_PCD DATE;
  PERIOD1_POD DATE;
  PERIOD1_FY NUMBER;
  RP_COMPANY_NAME VARCHAR2(25);
  CP_OPTIONAL_PARAMETERS VARCHAR2(2000);
  FUNCTION BOOKFORMULA RETURN VARCHAR2;
  FUNCTION PERIOD1FORMULA(COMPANY_NAME IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION F_COMP_NAMEFORMULA(COMPANY_NAME IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION ACCOUNTING_FLEX_STRUCTURE_P RETURN NUMBER;
  FUNCTION ACCT_BAL_APROMPT_P RETURN VARCHAR2;
  FUNCTION ACCT_CC_APROMPT_P RETURN VARCHAR2;
  FUNCTION CAT_MAJ_APROMPT_P RETURN VARCHAR2;
  FUNCTION CURRENCY_CODE_P RETURN VARCHAR2;
  FUNCTION BOOK_CLASS_P RETURN VARCHAR2;
  FUNCTION DISTRIBUTION_SOURCE_BOOK_P RETURN VARCHAR2;
  FUNCTION PERIOD1_PC_P RETURN NUMBER;
  FUNCTION PERIOD1_PCD_P RETURN DATE;
  FUNCTION PERIOD1_POD_P RETURN DATE;
  FUNCTION PERIOD1_FY_P RETURN NUMBER;
  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2;
  FUNCTION CP_OPTIONAL_PARAMETERS_P RETURN VARCHAR2;
END JL_JLCOFADR_XMLP_PKG;




/