--------------------------------------------------------
--  DDL for Package PO_RCVIERR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RCVIERR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RCVIERRS.pls 120.1 2007/12/25 12:46:17 krreddy noship $ */
  P_START_DATE DATE;

  P_END_DATE DATE;

  P_PURGE_DATA VARCHAR2(32767);

  P_CONC_REQUEST_ID NUMBER := 0;

  FUNCTION AFTERREPORT(C_1 IN NUMBER
                      ,C_2 IN NUMBER) RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

END PO_RCVIERR_XMLP_PKG;


/
