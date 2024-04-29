--------------------------------------------------------
--  DDL for Package GL_GLXBOR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXBOR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXBORS.pls 120.0 2007/12/27 14:47:17 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_LEDGER_ID	number;
	P_BUDGET_ENTITY_ID	varchar2(25);
	P_BUDGET_ENTITY_ID1	varchar2(25);
	P_FUNDS_CHECK_ON	varchar2(1);
	P_DAS_ID	number;
	STRUCT_NUM	varchar2(15);
	LEDGER_NAME	varchar2(30);

	SELECT_FLEX_LOW	varchar2(1000) := '(bar.segment1_low||''\n''||bar.segment2_low||''\n''||bar.segment3_low||
	''\n''||bar.segment4_low||''\n''||bar.segment5_low||''\n''||bar.segment6_low||''\n''||bar.segment7_low||
	''\n''||bar.segment8_low||''\n''||bar.segment9_low||''\n''||bar.segment10_low||''\n''||bar.segment11_low||
	''\n''||bar.segment12_low||''\n''||bar.segment13_low||''\n''||bar.segment14_low||''\n''||
	bar.segment15_low||''\n''||bar.segment16_low||''\n''||bar.segment17_low||''\n''||bar.segment18_low||
	''\n''||bar.segment19_low||''\n''||bar.segment20_low||''\n''||bar.segment21_low||''\n''||bar.segment22_low
	||''\n''||bar.segment23_low||''\n''||bar.segment24_low||''\n''||bar.segment25_low||''\n''||
	bar.segment26_low||''\n''||bar.segment27_low||''\n''||bar.segment28_low||''\n''||bar.segment29_low||''\n''||bar.segment30_low)';

	SELECT_FLEX_HIGH	varchar2(1000) := '(bar.segment1_high||''\n''||bar.segment2_high||''\n''||
	bar.segment3_high||''\n''||bar.segment4_high||''\n''||bar.segment5_high||''\n''||bar.segment6_high||
	''\n''||bar.segment7_high||''\n''||bar.segment8_high||''\n''||bar.segment9_high||''\n''||bar.segment10_high
	||''\n''||bar.segment11_high||''\n''||bar.segment12_high||''\n''||bar.segment13_high||''\n''||
	bar.segment14_high||''\n''||bar.segment15_high||''\n''||bar.segment16_high||''\n''||bar.segment17_high||
	''\n''||bar.segment18_high||''\n''||bar.segment19_high||''\n''||bar.segment20_high||''\n''||
	bar.segment21_high||''\n''||bar.segment22_high||''\n''||bar.segment23_high||''\n''||bar.segment24_high||
	''\n''||bar.segment25_high||''\n''||bar.segment26_high||''\n''||bar.segment27_high||''\n''||
	bar.segment28_high||''\n''||bar.segment29_high||''\n''||bar.segment30_high)';
	DAS_NAME	varchar2(30);
	C_DELIMITER	varchar2(30);
	function flexfield_lowformula(FLEXDATA_LOW in varchar2) return varchar2  ;
	FUNCTION gl_get_all_org_id RETURN NUMBER  ;
	function AfterReport return boolean  ;
	function flexfield_highformula(FLEXDATA_HIGH in varchar2) return varchar2  ;
	function BeforeReport return boolean ;
	Function STRUCT_NUM_p return varchar2;
	Function LEDGER_NAME_p return varchar2;
	Function SELECT_FLEX_LOW_p return varchar2;
	Function SELECT_FLEX_HIGH_p return varchar2;
	Function DAS_NAME_p return varchar2;
END GL_GLXBOR_XMLP_PKG;



/
