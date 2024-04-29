--------------------------------------------------------
--  DDL for Package IGI_IGIIACAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IGIIACAR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGIIACARS.pls 120.0.12010000.1 2008/07/29 08:58:26 appldev ship $ */
  P_CATEGORY_ID NUMBER;

  P_BOOK_TYPE_CODE VARCHAR2(40);

  P_PERIOD_COUNTER_FROM NUMBER;

  P_PERIOD_COUNTER_TO NUMBER;

  P_TRANSACTION_TYPE VARCHAR2(40);

  P_CONC_REQUEST_ID NUMBER;

  P_CAT_STRUCT_ID NUMBER;

  CP_DR_AMOUNT NUMBER;

  CP_CR_AMOUNT NUMBER;

  CP_PERIOD_FROM VARCHAR2(42);

  CP_PERIOD_TO VARCHAR2(42);

  CP_CURR_CODE VARCHAR2(20);

  STRUCT_NUM VARCHAR2(20) := '50105';

  CP_FLEX_DATA_ITEM VARCHAR2(5000) := '(gl_item.segment1||''\n''||gl_item.segment2||''\n''
  ||gl_item.segment3||''\n''||gl_item.segment4||''\n''||gl_item.segment5||''\n''||gl_item.segment6||
  ''\n''||gl_item.segment7||''\n''||gl_item.segment8||''\n''||gl_item.segment9||''\n''||gl_item.segment10||
  ''\n''||gl_item.segment11||''\n''||gl_item.segment12||''\n''||gl_item.segment13||''\n''||gl_item.segment14||
  ''\n''||gl_item.segment15||''\n''||gl_item.segment16||''\n''||gl_item.segment17||''\n''||gl_item.segment18||
  ''\n''||gl_item.segment19||''\n''||gl_item.segment20||''\n''||gl_item.segment21||''\n''||gl_item.segment22||
  ''\n''||gl_item.segment23||''\n''||gl_item.segment24||''\n''||gl_item.segment25||''\n''||gl_item.segment26||
  ''\n''||gl_item.segment27||''\n''||gl_item.segment28||''\n''||gl_item.segment29||''\n''||gl_item.segment30)';

  RP_DATA_FOUND VARCHAR2(20);

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CF_DATA_FOUNDFORMULA(CATEGORY_ID IN NUMBER) RETURN NUMBER;

  FUNCTION CF_PERIOD_FROMFORMULA RETURN NUMBER;

  FUNCTION CF_PERIOD_TOFORMULA RETURN NUMBER;

  FUNCTION CF_CURR_CODEFORMULA RETURN NUMBER;

  FUNCTION CF_DR_AMOUNTFORMULA(DR_CR_FLAG IN VARCHAR2
                              ,AMOUNT IN NUMBER) RETURN NUMBER;

  FUNCTION CF_CR_AMOUNTFORMULA(DR_CR_FLAG IN VARCHAR2
                              ,AMOUNT IN NUMBER) RETURN NUMBER;

  FUNCTION CP_DR_AMOUNT_P RETURN NUMBER;

  FUNCTION CP_CR_AMOUNT_P RETURN NUMBER;

  FUNCTION CP_PERIOD_FROM_P RETURN VARCHAR2;

  FUNCTION CP_PERIOD_TO_P RETURN VARCHAR2;

  FUNCTION CP_CURR_CODE_P RETURN VARCHAR2;

  FUNCTION STRUCT_NUM_P RETURN VARCHAR2;

  FUNCTION CP_FLEX_DATA_ITEM_P RETURN VARCHAR2;

  FUNCTION RP_DATA_FOUND_P RETURN VARCHAR2;
  function BeforeReport return boolean;

END IGI_IGIIACAR_XMLP_PKG;

/
