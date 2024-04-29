--------------------------------------------------------
--  DDL for Package XLA_XLAABASR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_XLAABASR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: XLAABASRS.pls 120.0 2007/12/27 11:31:42 vjaganat noship $ */
  P_APPLICATION_ID NUMBER;

  P_PROCESSING_MODE VARCHAR2(30);

  P_EVENT_CLASS_CODE VARCHAR2(30);

  P_CONC_REQUEST_ID NUMBER;

  P_ENTITY_CODE VARCHAR2(30);

  P_REPORT_ONLY_MODE VARCHAR2(1);

  CP_EXTRACT_RET_CODE NUMBER := 0;

  CP_QUERY VARCHAR2(200);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  PROCEDURE SET_REPORT_CONSTANTS;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CP_EXTRACT_RET_CODE_P RETURN NUMBER;

  FUNCTION CP_QUERY_P RETURN VARCHAR2;

END XLA_XLAABASR_XMLP_PKG;

/