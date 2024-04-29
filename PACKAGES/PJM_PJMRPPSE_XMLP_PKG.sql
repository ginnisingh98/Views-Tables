--------------------------------------------------------
--  DDL for Package PJM_PJMRPPSE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_PJMRPPSE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PJMRPPSES.pls 120.1 2007/12/24 12:27:27 nchinnam noship $ */
  P_ORDER_BY NUMBER;

  P_PROJECT_NUMBER_FROM VARCHAR2(40);

  P_PROJECT_NUMBER_TO VARCHAR2(40);

  P_ORDER_BY_DISP VARCHAR2(80);

  P_CONC_REQUEST_ID NUMBER;

  P_ITEM_FROM VARCHAR2(40);

  P_ITEM_TO VARCHAR2(40);

  P_DATE_FROM VARCHAR2(40);

  P_DATE_TO VARCHAR2(40);

  P_PRT_PO VARCHAR2(32767);

  P_PRT_REL VARCHAR2(32767);

  P_PRT_PR VARCHAR2(32767);

  P_PRT_RFQ VARCHAR2(32767);

  P_PRT_QTN VARCHAR2(32767);

  D_DATE_FROM DATE;

  D_DATE_FROM_DISP VARCHAR2(40);

  D_DATE_TO DATE;

  D_DATE_TO_DISP VARCHAR2(40);

  P_ITEM_WHERE VARCHAR2(1000);

  P_PROJECT_WHERE VARCHAR2(240);

  P_DATE_WHERE VARCHAR2(240);

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION G_POFILTER RETURN BOOLEAN;

  FUNCTION G_RELFILTER RETURN BOOLEAN;

  FUNCTION G_PRFILTER RETURN BOOLEAN;

  FUNCTION G_RFQFILTER RETURN BOOLEAN;

  FUNCTION G_QTNFILTER RETURN BOOLEAN;

END PJM_PJMRPPSE_XMLP_PKG;


/
