--------------------------------------------------------
--  DDL for Package JA_JAINRACT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_JAINRACT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JAINRACTS.pls 120.1 2007/12/25 16:26:52 dwkrishn noship $ */
  P_RECEIPT_NUM VARCHAR2(40);

  P_ORGANIZATION_CODE VARCHAR2(40);

  P_TRANSACTION_TYPE VARCHAR2(40);

  P_TRANSACTION_DATE_FROM DATE;

  P_TRANSACTION_DATE_TO DATE;

  P_LINE_NUM NUMBER;

  P_ACCT_NATURE VARCHAR2(40);

  P_CENVAT VARCHAR2(30);

  P_EXPENSE VARCHAR2(30);

  P_CONC_REQUEST_ID NUMBER;

  FUNCTION P_ACCT_NATUREVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

END JA_JAINRACT_XMLP_PKG;



/