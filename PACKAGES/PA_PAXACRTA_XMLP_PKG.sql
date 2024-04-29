--------------------------------------------------------
--  DDL for Package PA_PAXACRTA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXACRTA_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXACRTAS.pls 120.0 2008/01/02 11:12:58 krreddy noship $ */
  P_RULE_OPTIMIZER VARCHAR2(3);
  P_DEBUG_MODE VARCHAR2(3);
  P_CONC_REQUEST_ID NUMBER;
  P_PROJECT_NUM_FROM VARCHAR2(25);
  P_PROJECT_NUM_TO VARCHAR2(25);
  P_START_PA_PERIOD VARCHAR2(30);
  P_END_PA_PERIOD VARCHAR2(30);
  P_SYSTEM_LINKAGE_FUNCTION VARCHAR2(30);
  C_CONC_REQUEST_ID VARCHAR2(40);
  P_BILLABLE VARCHAR2(8);
  P_CAPITAL VARCHAR2(13);
  P_NONBILLABLE VARCHAR2(32767);
  P_NONCAPITAL VARCHAR2(32767);
  C_COMPANY_NAME_HEADER VARCHAR2(50);
  C_NO_DATA_FOUND VARCHAR2(80);
  C_DUMMY_DATA NUMBER;
  C_RETCODE NUMBER;
  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN;
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION FMT(NUMBER_IN IN NUMBER) RETURN VARCHAR2;
  FUNCTION CF_CORBFORMULA(PROJECT_TYPE_CLASS_CODE IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION CF_NOTCORBFORMULA(PROJECT_TYPE_CLASS_CODE IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION C_FMT_MASKFORMULA RETURN VARCHAR2;
  FUNCTION CF_CMT_EXCEPTIONSFORMULA(SUM_EXCEPTION_CODE IN VARCHAR2) RETURN CHAR;
  FUNCTION CF_CMT_LINE_EXCEPTFORMULA(CMT_REJECTION_CODE IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2;
  FUNCTION C_NO_DATA_FOUND_P RETURN VARCHAR2;
  FUNCTION C_DUMMY_DATA_P RETURN NUMBER;
  FUNCTION C_RETCODE_P RETURN NUMBER;
END PA_PAXACRTA_XMLP_PKG;

/