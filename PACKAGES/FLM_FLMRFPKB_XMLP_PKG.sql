--------------------------------------------------------
--  DDL for Package FLM_FLMRFPKB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_FLMRFPKB_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FLMRFPKBS.pls 120.0 2007/12/31 09:20:37 dwkrishn noship $ */
  P_ORG_ID NUMBER;

  P_ITEM_FROM VARCHAR2(850);

  P_ITEM_TO VARCHAR2(850);

  P_SUBINV_FROM VARCHAR2(10);

  P_SUBINV_TO VARCHAR2(10);

  P_DELETE_CARD NUMBER;

  P_SOURCE_ORG_ID NUMBER;

  P_SOURCE_SUBINV VARCHAR2(32767);

  P_SUPPLIER_ID NUMBER;

  P_LINE_ID NUMBER;

  P_SOURCE_TYPE NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  P_ASSY_FLEX VARCHAR2(850);

  P_LOC_FLEX VARCHAR2(850);

  P_REPORT_OPTION NUMBER;

  P_ORG_NAME VARCHAR2(32767);

  P_RETCODE NUMBER;

  P_LINE_CODE VARCHAR2(10);

  P_SUPPLIER_NAME VARCHAR2(240);

  P_SOURCE_ORG_NAME VARCHAR2(32767);

  P_DELETE_CARD_OPT VARCHAR2(30);

  P_REPORT_OPT VARCHAR2(32767);

  P_SOURCE_TYPE_CODE VARCHAR2(10);

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  function BeforeReport return boolean;

END FLM_FLMRFPKB_XMLP_PKG;


/