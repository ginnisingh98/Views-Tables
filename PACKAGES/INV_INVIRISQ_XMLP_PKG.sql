--------------------------------------------------------
--  DDL for Package INV_INVIRISQ_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INVIRISQ_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: INVIRISQS.pls 120.1 2007/12/25 10:26:51 dwkrishn noship $ */
  P_CONC_REQUEST_ID NUMBER := 0;

  P_STRUCT_NUM VARCHAR2(15);

  P_ITEM_FLEXDATA VARCHAR2(3000);

  P_ITEM_WHERE VARCHAR2(600);

  P_ITEM_ORDER_BY VARCHAR2(800);

  P_ITEM_LO VARCHAR2(820);

  P_ITEM_HI VARCHAR2(820);

  P_QTY_PRECISION NUMBER;

  P_TRACE_FLAG NUMBER;

  P_OPTIMIZER_CODE NUMBER;

  P_ORGANIZATION_ID VARCHAR2(40);

  P_NEGATIVE_ONLY NUMBER;

  FUNCTION P_STRUCT_NUMVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

END INV_INVIRISQ_XMLP_PKG;


/
