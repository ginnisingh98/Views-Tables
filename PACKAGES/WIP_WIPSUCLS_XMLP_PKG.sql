--------------------------------------------------------
--  DDL for Package WIP_WIPSUCLS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WIPSUCLS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: WIPSUCLSS.pls 120.0 2007/12/24 10:13:43 npannamp noship $ */
  P_ORGANIZATION_ID NUMBER := 3;

  P_CONC_REQUEST_ID NUMBER := 0;

  P_FLEXDATA VARCHAR2(800);

  P_STRUCT_NUM VARCHAR2(15) := '101';

  P_DEBUG NUMBER := 2;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

END WIP_WIPSUCLS_XMLP_PKG;


/
