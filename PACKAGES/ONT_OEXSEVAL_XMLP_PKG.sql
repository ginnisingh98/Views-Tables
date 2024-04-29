--------------------------------------------------------
--  DDL for Package ONT_OEXSEVAL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_OEXSEVAL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: OEXSEVALS.pls 120.1 2007/12/25 07:34:01 npannamp noship $ */
  P_CONC_REQUEST_ID NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

END ONT_OEXSEVAL_XMLP_PKG;


/
