--------------------------------------------------------
--  DDL for Package INV_INVMSWHU_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INVMSWHU_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: INVMSWHUS.pls 120.1 2007/12/25 10:42:08 dwkrishn noship $ */
  P_ORG NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  P_MS_LO VARCHAR2(40);

  P_MS_HI VARCHAR2(40);

  P_ITEM_FLEX_ALL VARCHAR2(1000);

  P_LOC_FLEX_ALL VARCHAR2(1000);

  P_SEARCH_SUB NUMBER;

  P_SEARCH_LOC NUMBER;

  P_SEARCH_SER NUMBER;

  P_SEARCH_LOT NUMBER;

  P_DOCK_DOOR_TXT VARCHAR2(80);

  P_STG_LANE_TXT VARCHAR2(80);

  P_STR_LOC_TXT VARCHAR2(80);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

END INV_INVMSWHU_XMLP_PKG;


/