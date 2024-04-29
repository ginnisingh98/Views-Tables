--------------------------------------------------------
--  DDL for Package INV_INVIRCXR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INVIRCXR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: INVIRCXRS.pls 120.2 2007/12/25 10:22:22 dwkrishn noship $ */
  P_ORG_ID NUMBER;
  P_CUSTOMER_FROM VARCHAR2(50);
  P_CUSTOMER_ADDRESS_CATEGORY VARCHAR2(80);
  P_CUSTOMER_ADDRESS VARCHAR2(720);
  P_CUSTOMER_ITEM_NBR_FROM VARCHAR2(50);
  P_CUSTOMER_ITEM_NBR_TO VARCHAR2(50);
  P_LIST_LOWEST_RANK VARCHAR2(4);
  P_CONC_REQUEST_ID NUMBER;
  P_WHERE VARCHAR2(2000):='and 1=1';
  P_ITEM_LEVEL VARCHAR2(30);
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION G_BODYGROUPFILTER RETURN BOOLEAN;
END INV_INVIRCXR_XMLP_PKG;


/