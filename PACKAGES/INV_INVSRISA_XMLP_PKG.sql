--------------------------------------------------------
--  DDL for Package INV_INVSRISA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INVSRISA_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: INVSRISAS.pls 120.1 2007/12/25 10:53:49 dwkrishn noship $ */
  P_ORG_ID VARCHAR2(40);
  P_CONC_REQUEST_ID NUMBER;
  P_ITEM_FLEXSQL VARCHAR2(1600):='msi.segment1||''\n''||msi.segment2||''\n''||msi.segment3
  ||''\n''||msi.segment4||''\n''||msi.segment5||''\n''||msi.segment6||''\n''||msi.segment7||''\n''||msi.segment8
  ||''\n''||msi.segment9||''\n''||msi.segment10||''\n''||msi.segment11||''\n''||msi.segment12||''\n''||msi.segment13
  ||''\n''||msi.segment14||''\n''||msi.segment15||''\n''||msi.segment16||''\n''||msi.segment17||''\n''||msi.segment18||''\n''||msi.segment19||''\n''||msi.segment20';
  P_ITEM_STRUCTNUM NUMBER;
P_ACCT_FLEXSQL VARCHAR2(2400):='gcc.segment1||''\n''||gcc.segment2||''\n''||
gcc.segment3||''\n''||gcc.segment5||''\n''||gcc.segment6||''\n''||gcc.segment7||''\n''||
gcc.segment8||''\n''||gcc.segment9||''\n''||gcc.segment10||''\n''||gcc.segment11||''\n''||gcc.segment12||''\n''||gcc.segment13||''\n''||gcc.segment14||''\n''||gcc.segment15||''\n''||
gcc.segment16||''\n''||gcc.segment17||''\n''||gcc.segment18||''\n''||gcc.segment19||''\n''||gcc.segment20||''\n''||gcc.segment21||''\n''||gcc.segment22||''\n''||gcc.segment23||''\n''||gcc.segment24||''\n''||
gcc.segment25||''\n''||gcc.segment26||''\n''||gcc.segment27||''\n''||gcc.segment28||''\n''||gcc.segment29||''\n''||gcc.segment30';
  P_ACCT_STRUCTNUM NUMBER;
  CHART_OF_ACCTS_ID NUMBER;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION CHART_OF_ACCTS_ID_P RETURN NUMBER;
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
END INV_INVSRISA_XMLP_PKG;



/
