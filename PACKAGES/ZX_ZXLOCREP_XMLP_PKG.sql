--------------------------------------------------------
--  DDL for Package ZX_ZXLOCREP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_ZXLOCREP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ZXLOCREPS.pls 120.1.12010000.1 2008/07/28 13:27:55 appldev ship $ */
  P_CONC_REQUEST_ID NUMBER;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

END ZX_ZXLOCREP_XMLP_PKG;


/
