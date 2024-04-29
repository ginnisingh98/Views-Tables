--------------------------------------------------------
--  DDL for Package PSB_PSBRPCON_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_PSBRPCON_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PSBRPCONS.pls 120.0 2008/01/07 10:37:31 vijranga noship $ */
  P_SOB_ID NUMBER;

  P_BGP_ID NUMBER;

  P_SET_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  CP_NLS_NO_DATA_EXISTS VARCHAR2(80);

  CP_NLS_END_OF_REPORT VARCHAR2(80);

  CP_SOB VARCHAR2(30);

  CP_BGP VARCHAR2(30);

  CP_SET VARCHAR2(30);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION M_SET_GRPFRFORMATTRIGGER(CS_REC_COUNT IN NUMBER) RETURN BOOLEAN;

  FUNCTION M_1FORMATTRIGGER(CS_REC_COUNT IN NUMBER) RETURN BOOLEAN;

  FUNCTION F_2FORMATTRIGGER(CS_REC_COUNT IN NUMBER) RETURN BOOLEAN;

  FUNCTION F_1FORMATTRIGGER(CS_REC_COUNT IN NUMBER) RETURN BOOLEAN;

  FUNCTION BEFOREPFORM RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION BETWEENPAGE RETURN BOOLEAN;

  FUNCTION P_CONC_REQUEST_ID_P RETURN NUMBER;

  FUNCTION CP_NLS_NO_DATA_EXISTS_P RETURN VARCHAR2;

  FUNCTION CP_NLS_END_OF_REPORT_P RETURN VARCHAR2;

  FUNCTION CP_SOB_P RETURN VARCHAR2;

  FUNCTION CP_BGP_P RETURN VARCHAR2;

  FUNCTION CP_SET_P RETURN VARCHAR2;

END PSB_PSBRPCON_XMLP_PKG;






/
