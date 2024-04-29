--------------------------------------------------------
--  DDL for Package INV_INVIRDIS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INVIRDIS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: INVIRDISS.pls 120.1 2007/12/25 10:23:18 dwkrishn noship $ */
  /* $Header: INVIRDISS.pls 120.1 2007/12/25 10:23:18 dwkrishn noship $ */
  P_ITEM_WHERE VARCHAR2(2000);

  P_STAT_EFF DATE;

  P_STATUS VARCHAR2(10);

  P_ITEM_LO VARCHAR2(900);

  P_ITEM_HI VARCHAR2(900);

  P_CAT_LO VARCHAR2(900);

  P_CAT_HI VARCHAR2(900);

  P_CAT_WHERE VARCHAR2(2000);

  P_ITEM_FLEX VARCHAR2(900);

  P_CAT_FLEX VARCHAR2(900) := '(MC.SEGMENT1||''\n''||MC.SEGMENT2||''\n''
				||MC.SEGMENT3||''\n''||MC.SEGMENT4||''\n''||MC.SEGMENT5
				||''\n''||MC.SEGMENT6||''\n''||MC.SEGMENT7
				||''\n''||MC.SEGMENT8||''\n''||MC.SEGMENT9||''\n''||MC.SEGMENT10
				||''\n''||MC.SEGMENT11||''\n''||MC.SEGMENT12||''\n''
				||MC.SEGMENT13||''\n''||MC.SEGMENT14||''\n''||MC.SEGMENT15
				||''\n''||MC.SEGMENT16||''\n''||MC.SEGMENT17||''\n''||MC.SEGMENT18
				||''\n''||MC.SEGMENT19||''\n''||MC.SEGMENT20)';

  P_CAT_STRUCT_NUM NUMBER;

  P_CONC_REQUEST_ID NUMBER := 0;

  P_ITEM_ORDER VARCHAR2(900);

  P_BREAK_ID NUMBER;

  P_CAT_SET_ID NUMBER;

  P_ORG_ID NUMBER;

  P_STRUCT_NUM NUMBER;

  P_ORDER_BY VARCHAR2(40);

  FUNCTION WHERE_STAT_EFF RETURN VARCHAR2;

  FUNCTION WHERE_STATUS RETURN VARCHAR2;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION C_CAT_FROMFORMULA RETURN VARCHAR2;

  FUNCTION C_CAT_WHEREFORMULA RETURN VARCHAR2;

  FUNCTION C_CAT_PADFORMULA(C_CAT_FIELD IN VARCHAR2
                           ,C_CAT_PAD IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION C_CAT_SET_NAMEFORMULA RETURN VARCHAR2;

  FUNCTION C_ITEM_PADFORMULA(C_ITEM_FIELD IN VARCHAR2
                            ,C_ITEM_PAD IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION C_MORG_IDFORMULA RETURN VARCHAR2;

END INV_INVIRDIS_XMLP_PKG;



/