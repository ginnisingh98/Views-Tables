--------------------------------------------------------
--  DDL for Package INV_INVTRVLT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INVTRVLT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: INVTRVLTS.pls 120.2 2008/02/21 10:58:52 dwkrishn noship $ */
  P_ITEM_NUM VARCHAR2(15);
  P_GL_NUM VARCHAR2(15);
  P_MDSP_NUM VARCHAR2(15);
  P_MKTS_NUM VARCHAR2(15);
  P_ITEM_FLEXDATA VARCHAR2(800);
  P_GL_FLEXDATA VARCHAR2(480);
  P_MDSP_FLEXDATA VARCHAR2(480);
  P_MKTS_FLEXDATA VARCHAR2(480):='(MKTS.SEGMENT1||MKTS.SEGMENT2||MKTS.SEGMENT3||MKTS.SEGMENT4||MKTS.SEGMENT5||MKTS.SEGMENT6||MKTS.SEGMENT7||MKTS.SEGMENT8||MKTS.SEGMENT9||MKTS.SEGMENT10)';
  P_ORG VARCHAR2(22);
  P_ITEM_WHERE VARCHAR2(400):= '1=1';
  P_START_DATE DATE;
  P_START_DATE_1 VARCHAR2(20);
  P_END_DATE DATE;
  P_END_DATE_1 varchar2(50);
  CP_END_DATE VARCHAR2(20);
  P_CONC_REQUEST_ID NUMBER := 0;
  P_SORT_ID NUMBER;
  P_VEND_LOT_NUMBER VARCHAR2(30);
  P_ITEM_LO VARCHAR2(300);
  P_ITEM_HI VARCHAR2(300);
  P_LOT_NUMBER_LO VARCHAR2(80);
  P_LOT_NUMBER_HI VARCHAR2(80);
  P_QTY_PRECISION NUMBER;
  P_ITEM_ORDER_BY VARCHAR2(820):= 'character" defaultValue="msi.segment1, msi.segment2, msi.segment3';
  P_TRACE_FLAG NUMBER;
  P_OPTIMIZER_CODE NUMBER;
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION P_ITEM_WHEREVALIDTRIGGER RETURN BOOLEAN;
  FUNCTION WHERE_LOT RETURN VARCHAR2;
  FUNCTION P_TRACE_FLAGVALIDTRIGGER RETURN BOOLEAN;
  FUNCTION AFTERPFORM RETURN BOOLEAN;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
END INV_INVTRVLT_XMLP_PKG;


/
