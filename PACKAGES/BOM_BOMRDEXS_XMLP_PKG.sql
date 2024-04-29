--------------------------------------------------------
--  DDL for Package BOM_BOMRDEXS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_BOMRDEXS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: BOMRDEXSS.pls 120.0 2007/12/24 09:41:45 dwkrishn noship $ */
  P_CONC_REQUEST_ID NUMBER := 0;

  P_ORG_ID NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

END BOM_BOMRDEXS_XMLP_PKG;


/
