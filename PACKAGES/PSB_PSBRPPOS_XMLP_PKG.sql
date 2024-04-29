--------------------------------------------------------
--  DDL for Package PSB_PSBRPPOS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_PSBRPPOS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PSBRPPOSS.pls 120.0 2008/01/07 10:42:47 vijranga noship $ */
  P_DATA_EXTRACT_ID VARCHAR2(50);

  P_ACCOUNT_POSITION_SET_ID VARCHAR2(50);

  P_CONC_REQUEST_ID NUMBER := 0;

  C_NLS_END_OF_REPORT VARCHAR2(80);

  C_NLS_NO_DATA_EXISTS VARCHAR2(80);

  CP_DATA_EXTRACT_NAME VARCHAR2(80);

  CP_POSITION_SETS VARCHAR2(100);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION BEFOREPFORM RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION BETWEENPAGE RETURN BOOLEAN;

  FUNCTION P_CONC_REQUEST_ID_P RETURN NUMBER;

  FUNCTION C_NLS_END_OF_REPORT_P RETURN VARCHAR2;

  FUNCTION C_NLS_NO_DATA_EXISTS_P RETURN VARCHAR2;

  FUNCTION CP_DATA_EXTRACT_NAME_P RETURN VARCHAR2;

  FUNCTION CP_POSITION_SETS_P RETURN VARCHAR2;

END PSB_PSBRPPOS_XMLP_PKG;






/