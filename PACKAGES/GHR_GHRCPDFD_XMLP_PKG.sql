--------------------------------------------------------
--  DDL for Package GHR_GHRCPDFD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_GHRCPDFD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GHRCPDFDS.pls 120.0 2007/12/04 07:57:43 srikrish noship $ */
  FILENAME VARCHAR2(32767);

  P_REPORT_DATE_FROM DATE;

  P_REPORT_DATE_TO DATE;

  P_AGENCY_SUBELEMENT VARCHAR2(2);

  P_AGENCY_CODE VARCHAR2(2);

  P_CONC_REQUEST_ID NUMBER;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CF_SUPER_DIFFFORMULA(FIRST_NOA_CODE IN VARCHAR2
                               ,FIRST_ACTION_LA_CODE1 IN VARCHAR2
                               ,FIRST_ACTION_LA_CODE2 IN VARCHAR2
                               ,TO_SUPERVISORY_DIFFERENTIAL IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_RETN_ALLOWFORMULA(FIRST_NOA_CODE IN VARCHAR2
                               ,FIRST_ACTION_LA_CODE1 IN VARCHAR2
                               ,FIRST_ACTION_LA_CODE2 IN VARCHAR2
                               ,TO_RETENTION_ALLOWANCE IN VARCHAR2) RETURN CHAR;

END GHR_GHRCPDFD_XMLP_PKG;

/