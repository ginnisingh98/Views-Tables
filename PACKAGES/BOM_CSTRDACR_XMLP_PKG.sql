--------------------------------------------------------
--  DDL for Package BOM_CSTRDACR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_CSTRDACR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: CSTRDACRS.pls 120.0 2007/12/24 09:54:14 dwkrishn noship $ */
  P_PERIOD_WEPB_WHERE VARCHAR2(100) := ' and 1 = 1';

  P_ORG_ID NUMBER;

  P_CURRENCY_DSP VARCHAR2(40) := 'USD';

  P_PERIOD_ID_TO NUMBER;

  P_ORG_NAME VARCHAR2(60);

  P_CURRENCY_CODE VARCHAR2(32767);

  P_EXCHANGE_RATE NUMBER := 1;

  P_EXCHANGE_RATE_CHAR VARCHAR2(32767);

  P_PERIOD_DATE_FROM DATE;

  P_PERIOD_DATE_TO DATE;

  P_PERIOD_ID_FROM NUMBER;

  P_DEPT_FROM VARCHAR2(32767);

  P_DEPT_TO VARCHAR2(32767);

  P_ROUND_UNIT NUMBER;

  P_PERIOD_WPB_WHERE VARCHAR2(100):= ' and 1 = 1';

  P_RPT_TYPE NUMBER;

  P_INCLUDE_OSP NUMBER;

  P_DEPT_WHERE VARCHAR2(100):= ' and 1 = 1';

  P_CONC_REQUEST_ID NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

END BOM_CSTRDACR_XMLP_PKG;


/