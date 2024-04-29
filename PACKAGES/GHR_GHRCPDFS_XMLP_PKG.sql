--------------------------------------------------------
--  DDL for Package GHR_GHRCPDFS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_GHRCPDFS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GHRCPDFSS.pls 120.0 2007/12/04 08:07:06 srikrish noship $ */
  P_AGENCY_SUBELEMENT VARCHAR2(4);

  P_REPORT_DATE DATE;

  FILENAME VARCHAR2(30);

  P_AGENCY_CODE VARCHAR2(2);

  P_CONC_REQUEST_ID NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

END GHR_GHRCPDFS_XMLP_PKG;

/