--------------------------------------------------------
--  DDL for Package IGC_IGCCLDER_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_IGCCLDER_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCCLDERS.pls 120.0.12010000.1 2008/07/28 06:29:30 appldev ship $ */
  P_SET_OF_BOOKS_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  P_BATCH_ID NUMBER;

  P_PROCESS_PHASE VARCHAR2(32767);

  P_ORG_ID NUMBER;

  SET_OF_BOOKS_NAME VARCHAR2(30);

  CURRENCY_CODE VARCHAR2(30);

  ORG_NAME VARCHAR2(240);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION DSP_STATUSFORMULA RETURN CHAR;

  FUNCTION DSP_TOT_HEADERSFORMULA RETURN NUMBER;

  FUNCTION DSP_TOT_ERRORSFORMULA RETURN NUMBER;

  FUNCTION SET_OF_BOOKS_NAME_P RETURN VARCHAR2;

  FUNCTION CURRENCY_CODE_P RETURN VARCHAR2;

  FUNCTION ORG_NAME_P RETURN VARCHAR2;

END IGC_IGCCLDER_XMLP_PKG;

/