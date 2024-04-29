--------------------------------------------------------
--  DDL for Package PA_PAXFRADR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXFRADR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXFRADRS.pls 120.0 2008/01/02 11:33:22 krreddy noship $ */
  P_DEBUG_MODE VARCHAR2(3);

  P_CONC_REQUEST_ID NUMBER;

  P_FROM_PROJECT_NUMBER VARCHAR2(30);

  LP_FROM_PROJECT_NUMBER VARCHAR2(30);

  P_TO_PROJECT_NUMBER VARCHAR2(30);

  LP_TO_PROJECT_NUMBER VARCHAR2(30);

  P_MODE VARCHAR2(32767) := 'D';

  P_PROJ_TYPE VARCHAR2(80);

  P_REPORT_MODE VARCHAR2(30);

  P_REVAL_FROM_DATE DATE;

  LP_REVAL_FROM_DATE varchar2(20);

  P_REVAL_TO_DATE DATE;

  LP_REVAL_TO_DATE varchar2(20);

  P_FROM_CLAUSE VARCHAR2(30);

  L_WHERE_CLAUSE VARCHAR2(200);

  C_COMPANY_NAME_HEADER VARCHAR2(50);

  C_NO_DATA_FOUND VARCHAR2(80);

  C_DUMMY_DATA NUMBER;

  C_RETCODE VARCHAR2(32767);

  CURR_CODE VARCHAR2(15);

  C_ERROR_BUF VARCHAR2(80);

  C_NO_REPORT_DATA VARCHAR2(80);

  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION P_MODEVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2;

  FUNCTION C_NO_DATA_FOUND_P RETURN VARCHAR2;

  FUNCTION C_DUMMY_DATA_P RETURN NUMBER;

  FUNCTION C_RETCODE_P RETURN VARCHAR2;

  FUNCTION CURR_CODE_P RETURN VARCHAR2;

  FUNCTION C_ERROR_BUF_P RETURN VARCHAR2;

  FUNCTION C_NO_REPORT_DATA_P RETURN VARCHAR2;

END PA_PAXFRADR_XMLP_PKG;

/