--------------------------------------------------------
--  DDL for Package IGI_IGIIABLD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IGIIABLD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGIIABLDS.pls 120.0.12010000.1 2008/07/29 08:58:20 appldev ship $ */
  P_CONC_REQUEST_ID NUMBER;

  P_BOOK VARCHAR2(15);

  DO_INSERT number;

  P_PERIOD1 VARCHAR2(32767);

  P_PERIOD2 VARCHAR2(32767);

  P_REPORT_TYPE VARCHAR2(32767);

  P_COMPANY1 VARCHAR2(30);

  P_COMPANY2 VARCHAR2(30);

  P_COST_CENTER1 VARCHAR2(32767);

  P_COST_CENTER2 VARCHAR2(30);

  P_ACCOUNT1 VARCHAR2(30);

  P_ACCOUNT2 VARCHAR2(30);

  ACCT_BAL_APROMPT VARCHAR2(222);

  ACCT_CC_APROMPT VARCHAR2(222);

  ACCT_AC_APROMPT VARCHAR2(222);

  RP_REPORT_NAME VARCHAR2(80);

  RP_COMPANY_NAME VARCHAR2(80);

  RP_BAL_LPROMPT VARCHAR2(222);

  RP_CTR_APROMPT VARCHAR2(222);

  RP_AC_LPROMPT VARCHAR2(222);

  RP_CC_LPROMPT VARCHAR2(222);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION DO_INSERTFORMULA RETURN NUMBER;

  FUNCTION REPORT_NAMEFORMULA(COMPANY_NAME IN VARCHAR2
                             ,CURRENCY_CODE IN VARCHAR2) RETURN CHAR;

  FUNCTION ACCT_BAL_APROMPT_P RETURN VARCHAR2;

  FUNCTION ACCT_CC_APROMPT_P RETURN VARCHAR2;

  FUNCTION ACCT_AC_APROMPT_P RETURN VARCHAR2;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2;

  FUNCTION RP_BAL_LPROMPT_P RETURN VARCHAR2;

  FUNCTION RP_CTR_APROMPT_P RETURN VARCHAR2;

  FUNCTION RP_AC_LPROMPT_P RETURN VARCHAR2;

  FUNCTION RP_CC_LPROMPT_P RETURN VARCHAR2;

END IGI_IGIIABLD_XMLP_PKG;

/
