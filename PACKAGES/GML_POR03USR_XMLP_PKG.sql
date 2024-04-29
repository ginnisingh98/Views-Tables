--------------------------------------------------------
--  DDL for Package GML_POR03USR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_POR03USR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POR03USRS.pls 120.0 2007/12/24 13:29:09 nchinnam noship $ */
  P_ORGN_CODE VARCHAR2(4);

  P_RETURN_NO_FROM VARCHAR2(32);

  P_RETURN_NO_TO VARCHAR2(32);

  P_RETURN_DATE_FROM DATE;

  P_RETURN_DATE_TO DATE;

  CP_RETURN_DATE_FROM VARCHAR2(20);

  CP_RETURN_DATE_TO VARCHAR2(20);

  P_VENDOR_NO_FROM VARCHAR2(32);

  P_VENDOR_NO_TO VARCHAR2(32);

  P_RETURN_CODE_FROM VARCHAR2(4);

  P_RETURN_CODE_TO VARCHAR2(4);

  P_ITEM_NO_FROM VARCHAR2(32);

  P_ITEM_NO_TO VARCHAR2(32);

  P_WHSE_CODE_FROM VARCHAR2(4);

  P_WHSE_CODE_TO VARCHAR2(4);

  P_LOT_NO_FROM VARCHAR2(32);

  P_LOT_NO_TO VARCHAR2(32);

  P_SUBLOT_NO_FROM VARCHAR2(32);

  P_SUBLOT_NO_TO VARCHAR2(32);

  P_PO_RETURNS VARCHAR2(3);

  P_STOCK_RETURNS VARCHAR2(3);

  PARAM_WHERE_CLAUSE VARCHAR2(1500);

  P_ORGN_CODE_1 VARCHAR2(4);

  P_USER_ID VARCHAR2(32);

  NONBLOCKSQK VARCHAR2(5);

  P_CONC_REQUEST_ID NUMBER;

  CP_ROWS NUMBER;

  CP_ORGN_NAME VARCHAR2(100);

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CP_ROWS_P RETURN NUMBER;

  FUNCTION CP_ORGN_NAME_P RETURN VARCHAR2;

  PRN_ROWS NUMBER;

END GML_POR03USR_XMLP_PKG;


/