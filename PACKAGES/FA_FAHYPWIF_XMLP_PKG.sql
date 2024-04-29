--------------------------------------------------------
--  DDL for Package FA_FAHYPWIF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAHYPWIF_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAHYPWIFS.pls 120.1.12010000.1 2008/07/28 13:12:06 appldev ship $ */

  P_CONC_REQUEST_ID NUMBER := 0;

  P_CONC_REQUEST_ID_RX NUMBER := 0;

  P_MIN_PRECISION NUMBER := 2;

  P_REQUEST_ID VARCHAR2(40);

  P_BOOK VARCHAR2(15);

  P_BOOK1 VARCHAR2(15);

  P_CURRENCY VARCHAR2(15);

  P_CURRENCY1 VARCHAR2(15);

  RP_COMPANY_NAME VARCHAR2(100);

  RP_REPORT_NAME VARCHAR2(80);

  C_CURRENCY_CODE VARCHAR2(15);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2;

  FUNCTION C_CURRENCY_CODE_P RETURN VARCHAR2;

END FA_FAHYPWIF_XMLP_PKG;

/