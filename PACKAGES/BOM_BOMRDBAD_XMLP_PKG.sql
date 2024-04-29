--------------------------------------------------------
--  DDL for Package BOM_BOMRDBAD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_BOMRDBAD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: BOMRDBADS.pls 120.0 2007/12/24 09:38:35 dwkrishn noship $ */
  P_ORG_ID VARCHAR2(40);

  P_CONC_REQUEST_ID NUMBER := 0;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

END BOM_BOMRDBAD_XMLP_PKG;


/
