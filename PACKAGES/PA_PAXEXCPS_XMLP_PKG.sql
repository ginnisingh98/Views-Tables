--------------------------------------------------------
--  DDL for Package PA_PAXEXCPS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXEXCPS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXEXCPSS.pls 120.0 2008/01/02 11:29:40 krreddy noship $ */
  P_RULE_OPTIMIZER VARCHAR2(3);
  P_DEBUG_MODE VARCHAR2(3);
  P_CONC_REQUEST_ID NUMBER;
  START_DATE DATE;
  END_DATE DATE;
  P_MIN_PRECISION NUMBER;
  CALLING_MODE VARCHAR2(40);
  ACROSS_OUS VARCHAR2(1);
  START_PERIOD VARCHAR2(32767);
  END_PERIOD VARCHAR2(30);
  ORG_ID1 NUMBER;
  C_COMPANY_NAME_HEADER VARCHAR2(50);
  C_NO_DATA_FOUND VARCHAR2(80);
  C_DUMMY_DATA NUMBER;
  CP_OU_NAME VARCHAR2(60);
  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN;
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN;
  FUNCTION CF_ACCT_CURR_CODEFORMULA RETURN VARCHAR2;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION GET_OU_NAME RETURN BOOLEAN;
  FUNCTION CF_COST_OU_NAMEFORMULA(ORG_ID IN NUMBER) RETURN CHAR;
  FUNCTION CF_INV_OU_NAMEFORMULA(INV_ORG_ID IN NUMBER) RETURN CHAR;
  FUNCTION CF_REV_OU_NAMEFORMULA(REV_ORG_ID IN NUMBER) RETURN CHAR;
  FUNCTION CF_CC_OU_NAMEFORMULA(CC_ORG_ID IN NUMBER) RETURN CHAR;
  FUNCTION CF_MFG_OU_NAMEFORMULA(MFG_ORG_ID IN NUMBER) RETURN CHAR;
  FUNCTION CF_UNCST_OU_NAMEFORMULA(UNCST_ORG_ID IN NUMBER) RETURN CHAR;
  FUNCTION CF_UNCST_SOB_NAMEFORMULA(UNCST_SOB IN NUMBER) RETURN CHAR;
  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2;
  FUNCTION C_NO_DATA_FOUND_P RETURN VARCHAR2;
  FUNCTION C_DUMMY_DATA_P RETURN NUMBER;
  FUNCTION CP_OU_NAME_P RETURN VARCHAR2;
END PA_PAXEXCPS_XMLP_PKG;

/
