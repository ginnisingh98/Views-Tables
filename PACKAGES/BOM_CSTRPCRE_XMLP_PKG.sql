--------------------------------------------------------
--  DDL for Package BOM_CSTRPCRE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_CSTRPCRE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: CSTRPCRES.pls 120.0 2007/12/24 10:11:46 dwkrishn noship $ */
  P_REPORT_TYPE NUMBER;

  P_ORG_ID NUMBER;

  P_GL_NUM NUMBER;

  P_SORT_OPTION NUMBER;

  P_PERIOD_ID NUMBER;

  P_TO_DATE VARCHAR2(32767);
  P_TO_DATE1 VARCHAR2(32767);
  P_CG_FROM VARCHAR2(32767);

  P_CG_TO VARCHAR2(32767);

  P_SUB_FROM VARCHAR2(32767);

  P_SUB_TO VARCHAR2(32767);

  P_ITEM_FROM VARCHAR2(820);

  P_ITEM_TO VARCHAR2(820);

  P_CURRENCY_CODE VARCHAR2(32767);

  P_RATE_TYPE NUMBER;

  P_EXCHANGE_RATE_CHAR VARCHAR2(32767);

  P_ORG_NAME VARCHAR2(240);

  P_EXCHANGE_RATE NUMBER;

  P_CURRENCY_DSP VARCHAR2(40);

  P_ROUND_UNIT NUMBER:=1;

  P_ITEM_SEG VARCHAR2(2400);

  P_SORT_TEXT VARCHAR2(50);

  P_FROM_DATE DATE;

  P_CPCS_WHERE VARCHAR2(200) := '1 = 1';

  P_SOURCE_TABLE VARCHAR2(30) := 'cst_period_close_summary';

  P_TRACE VARCHAR2(1);

  P_SIMULATION VARCHAR2(1) := 'N';

  P_CG_SORT_TEXT VARCHAR2(40):= ' ';

  P_SUB_SORT_TEXT VARCHAR2(40):= ' ';

  P_PERIOD_NAME VARCHAR2(15);

  P_CONC_REQUEST_ID NUMBER := 0;

  P_NULLSUB VARCHAR2(40);

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION BeforeReport RETURN BOOLEAN;

END BOM_CSTRPCRE_XMLP_PKG;


/