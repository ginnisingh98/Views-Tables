--------------------------------------------------------
--  DDL for Package GL_GLXETB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXETB_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXETBS.pls 120.0 2007/12/27 14:58:33 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_LEDGER_ID	number;
	P_ENCUMBRANCE_TYPE_ID	number;
	P_PERIOD_NAME	varchar2(15);
	P_ACCESS_SET_ID	number;
	STRUCT_NUM	varchar2(15) := '50105' ;
	SELECT_BAL	varchar2(600) := '(cc.segment11 || ''\n'' || cc.segment12)' ;
	SELECT_ALL	varchar2(600) := '(cc.segment1||''\n''||cc.segment2||''\n''||cc.segment3||''\n''||cc.segment4||
	''\n''||cc.segment5||''\n''||cc.segment6||''\n''||cc.segment7||''\n''||cc.segment8||''\n''||cc.segment9||''\n''||
	cc.segment10||''\n''||cc.segment11||''\n''||cc.segment12||''\n''||cc.segment13||''\n''||cc.segment14||''\n''||cc.segment15||''\n''||cc.segment16||''\n''||cc.segment17||''\n''||cc.segment18||''\n''||cc.segment19||''\n''||cc.segment20||''\n''||
	cc.segment21||''\n''||cc.segment22||''\n''||cc.segment23||''\n''||cc.segment24||''\n''||cc.segment25||
	''\n''||cc.segment26||''\n''||cc.segment27||''\n''||cc.segment28||''\n''||cc.segment29||''\n''||cc.segment30)' ;
	ORDERBY_BAL	varchar2(50) := 'cc.segment11' ;
	ORDERBY_ACCT	varchar2(50) := 'cc.segment11' ;
	ORDERBY_ALL	varchar2(600) := 'segment1, segment2, segment3, segment4, segment5, segment6, segment7, segment8, segment9, segment10, segment11, segment12,
	segment13, segment14, segment15, segment16, segment17, segment18, segment19, segment20, segment21, segment22, segment23, segment24, segment25, segment26, segment27, segment28, segment29, segment30' ;
	SELECT_ACCT	varchar2(600) := '(cc.segment11 || ''\n'' || cc.segment12)' ;
	ORDERBY_BAL2	varchar2(600) := 'cc.segment1, cc.segment2, cc.segment3, cc.segment4, cc.segment5, cc.segment6, cc.segment7, cc.segment8, cc.segment9, cc.segment10,
	cc.segment11, cc.segment12, cc.segment13, cc.segment14, cc.segment15, cc.segment16, cc.segment17, cc.segment18, cc.segment19, cc.segment20, cc.segment21, cc.segment22,
	cc.segment23, cc.segment24, cc.segment25, cc.segment26, cc.segment27, cc.segment28, cc.segment29, cc.segment30' ;
	ORDERBY_ACCT2	varchar2(600) := 'cc.segment1, cc.segment2, cc.segment3, cc.segment4, cc.segment5, cc.segment6, cc.segment7, cc.segment8, cc.segment9, cc.segment10,
	cc.segment11, cc.segment12, cc.segment13, cc.segment14, cc.segment15, cc.segment16, cc.segment17, cc.segment18, cc.segment19, cc.segment20, cc.segment21, cc.segment22,
	cc.segment23, cc.segment24, cc.segment25, cc.segment26, cc.segment27, cc.segment28, cc.segment29, cc.segment30' ;
	ACCESS_SET_NAME	varchar2(30);
	WHERE_DAS	varchar2(800):=' ';
	PARAM_LEDGER_CURR	varchar2(15);
	PARAM_LEDGER_TYPE	varchar2(1);
	MIXED_PRECISION	number;
	THOUSANDS_SEPARATOR	varchar2(20);
	CURR_FORMAT_MASK	varchar2(100);
	FROM_LEDGER	varchar2(40):=' ';
	WHERE_LEDGER	varchar2(100):=' ';
	function ENCUMBRANCE_TYPEFormula return VARCHAR2  ;
	function AfterReport return boolean  ;
	function end_balformula(BEGIN_BAL in number, DEBITS in number, CREDITS in number) return number  ;
	function BeforeReport return boolean  ;
	function g_page_breakgroupfilter(BAL_SECURE in varchar2) return boolean  ;
	function g_acct_datagroupfilter(ACCT_SECURE in varchar2) return boolean  ;
	function g_balancesgroupfilter(FLEX_SECURE in varchar2) return boolean  ;
	function gl_format_currency(Amount  NUMBER) return varchar2  ;
	Function STRUCT_NUM_p return varchar2;
	Function SELECT_BAL_p return varchar2;
	Function SELECT_ALL_p return varchar2;
	Function ORDERBY_BAL_p return varchar2;
	Function ORDERBY_ACCT_p return varchar2;
	Function ORDERBY_ALL_p return varchar2;
	Function SELECT_ACCT_p return varchar2;
	Function ORDERBY_BAL2_p return varchar2;
	Function ORDERBY_ACCT2_p return varchar2;
	Function ACCESS_SET_NAME_p return varchar2;
	Function WHERE_DAS_p return varchar2;
	Function PARAM_LEDGER_CURR_p return varchar2;
	Function PARAM_LEDGER_TYPE_p return varchar2;
	Function MIXED_PRECISION_p return number;
	Function THOUSANDS_SEPARATOR_p return varchar2;
	Function CURR_FORMAT_MASK_p return varchar2;
	Function FROM_LEDGER_p return varchar2;
	Function WHERE_LEDGER_p return varchar2;
END GL_GLXETB_XMLP_PKG;



/
