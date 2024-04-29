--------------------------------------------------------
--  DDL for Package INV_INVSRFRT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INVSRFRT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: INVSRFRTS.pls 120.1 2007/12/25 10:52:01 dwkrishn noship $ */
  P_ORG_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  P_ACCT_STRUCT_NUM NUMBER;

  P_CONDITION VARCHAR2(40);

  P_ACCT_FLEX VARCHAR2(900);

  FUNCTION AFTERREPORT RETURN BOOLEAN;
  function beforereport return boolean;

END INV_INVSRFRT_XMLP_PKG;


/
