--------------------------------------------------------
--  DDL for Package WIP_WIPSUPMT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WIPSUPMT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: WIPSUPMTS.pls 120.1 2008/01/31 12:47:10 npannamp noship $ */
  P_ORGANIZATION_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER := 0;

  P_FLEXDATA VARCHAR2(498);

  P_DEBUG NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

END WIP_WIPSUPMT_XMLP_PKG;


/