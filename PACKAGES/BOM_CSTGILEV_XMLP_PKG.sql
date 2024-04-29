--------------------------------------------------------
--  DDL for Package BOM_CSTGILEV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_CSTGILEV_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: CSTGILEVS.pls 120.0 2007/12/24 09:48:23 dwkrishn noship $ */
  P_LEGAL_ENTITY_ID NUMBER;

  P_COST_GROUP_ID NUMBER;

  P_COST_TYPE_ID NUMBER;

  P_PAC_PERIOD_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  P_ITEM_CODE_FROM VARCHAR2(32767);

  P_ITEM_CODE_TO VARCHAR2(32767);

  P_QUANTITY_PRECISION NUMBER;

  P_QUANTITY_PRECISION_1 NUMBER;

  P_DETAILED_REPORT VARCHAR2(1);

  P_DETAILED_REPORT_SUBTITLE VARCHAR2(48);

  P_SUMMARIZED_REPORT_SUBTITLE VARCHAR2(48);

  P_COST_PRECISION NUMBER;
  P_COST_PRECISION_1 NUMBER;

  P_VALUE_PRECISION NUMBER;
  P_VALUE_PRECISION_1 NUMBER;
  H_LEGAL_ENTITY VARCHAR2(240);

  H_COST_GROUP VARCHAR2(32767);

  H_COST_TYPE VARCHAR2(32767);

  H_PERIOD VARCHAR2(15);

  H_CURRENCY VARCHAR2(15);

  H_REPORT_SUBTITLE VARCHAR2(132);

  H_COST_GROUP_DESC VARCHAR2(240);

  H_COST_TYPE_DESC VARCHAR2(240);

  H_FISCAL_YEAR NUMBER;

  H_UPTO_DATE VARCHAR2(32767);

  qty_precision1 varchar2(100);
  qty_precision2 varchar2(100);
  qty_precision3 varchar2(100);

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

--  PROCEDURE FORMAT_QUANTITY(P_PRECISION IN NUMBER);

  FUNCTION H_LEGAL_ENTITY_P RETURN VARCHAR2;

  FUNCTION H_COST_GROUP_P RETURN VARCHAR2;

  FUNCTION H_COST_TYPE_P RETURN VARCHAR2;

  FUNCTION H_PERIOD_P RETURN VARCHAR2;

  FUNCTION H_CURRENCY_P RETURN VARCHAR2;

  FUNCTION H_REPORT_SUBTITLE_P RETURN VARCHAR2;

  FUNCTION H_COST_GROUP_DESC_P RETURN VARCHAR2;

  FUNCTION H_COST_TYPE_DESC_P RETURN VARCHAR2;

  FUNCTION H_FISCAL_YEAR_P RETURN NUMBER;

  FUNCTION H_UPTO_DATE_P RETURN VARCHAR2;

END BOM_CSTGILEV_XMLP_PKG;


/
