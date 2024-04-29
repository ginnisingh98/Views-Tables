--------------------------------------------------------
--  DDL for Package INV_INVSRLOC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INVSRLOC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: INVSRLOCS.pls 120.1 2007/12/25 10:54:45 dwkrishn noship $ */
  P_ORG_ID VARCHAR2(40);
  P_CONC_REQUEST_ID NUMBER := 0;
  P_LOCATOR_FLEXNUM NUMBER;
  P_LOCATOR_FLEXSQL VARCHAR2(5000);
  P_QTY_PRECISION VARCHAR2(32767);
  P_TRACE_FLAG NUMBER;
  P_CBO_FLAG NUMBER;
  QTY_PRECISION VARCHAR2(32767);
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION AFTERPFORM RETURN BOOLEAN;
END INV_INVSRLOC_XMLP_PKG;


/
