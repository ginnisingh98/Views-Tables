--------------------------------------------------------
--  DDL for Package GL_GLXBTB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXBTB_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXBTBS.pls 120.0 2007/12/27 14:48:21 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_BUDGET_VERSION_ID	number;
	P_FROM_PERIOD_NAME	varchar2(15);
	P_TO_PERIOD_NAME	varchar2(15);
	P_CURRENCY_TYPE	varchar2(1);
	P_LEDGER_ID	number;
	P_ACCESS_SET_ID	number;
	P_LEDGER_CURRENCY	varchar2(32767);
	P_ENTERED_CURRENCY	varchar2(32767);
	STRUCT_NUM	varchar2(15) := '50105' ;
	ACCESS_SET_NAME	varchar2(30);
	SELECT_BAL	varchar2(600) := '(cc.segment11 || ''\n'' || cc.segment12)' ;
	SELECT_ALL	varchar2(600) := '(cc.segment1||''\n''||cc.segment2||''\n''||cc.segment3||''\n''||cc.segment4||''\n''||cc.segment5||''\n''||cc.segment6||''\n''||cc.segment7||''\n''||cc.segment8||''\n''||cc.segment9||''\n''||cc.segment10||
		''\n''||cc.segment11||''\n''||cc.segment12||''\n''||cc.segment13||''\n''||cc.segment14||''\n''||cc.segment15||''\n''||cc.segment16||''\n''||cc.segment17||''\n''||cc.segment18||''\n''||cc.segment19||''\n''||cc.segment20||''\n''||
		cc.segment21||''\n''||cc.segment22||''\n''||cc.segment23||''\n''||cc.segment24||''\n''||cc.segment25||''\n''||cc.segment26||''\n''||cc.segment27||''\n''||cc.segment28||''\n''||cc.segment29||''\n''||cc.segment30)' ;
	ORDERBY_BAL	varchar2(50) := 'cc.segment11' ;
	ORDERBY_ACCT	varchar2(50) := 'cc.segment11' ;
	ORDERBY_ALL	varchar2(600) := 'segment1, segment2, segment3, segment4, segment5, segment6, segment7, segment8, segment9, segment10, segment11, segment12, segment13, segment14, segment15, segment16, segment17, segment18, segment19, segment20,
		segment21, segment22, segment23, segment24, segment25, segment26, segment27, segment28, segment29, segment30' ;
	SELECT_ACCT	varchar2(600) := '(cc.segment11 || ''\n'' || cc.segment12)' ;
	TRANS_CHECK_BB	varchar2(300) := '(nvl(bb.translated_flag(+),''R'') = ''R'')' ;
	TRANS_CHECK_BE	varchar2(300) := '(be.translated_flag is null OR be.translated_flag <> ''R'')' ;
	WHERE_DAS	varchar2(600);
	RESULTING_CURRENCY	varchar2(20);
	function period_act_balformula(END_BAL in number, BEGIN_BAL in number) return number  ;
	function BUDGET_NAMEFormula return VARCHAR2  ;
	function disp_bal_lprompt_w_colonformul(DISP_BAL_LPROMPT in varchar2) return varchar2  ;
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	function g_balancesgroupfilter(FLEX_SECURE in varchar2, BEGIN_BAL in number, END_BAL in number) return boolean  ;
	function g_page_breakgroupfilter(BAL_SECURE in varchar2) return boolean  ;
	function g_acct_datagroupfilter(ACCT_SECURE in varchar2) return boolean  ;
	function LEDGER_NAMEFormula return VARCHAR2  ;
	Function STRUCT_NUM_p return varchar2;
	Function ACCESS_SET_NAME_p return varchar2;
	Function SELECT_BAL_p return varchar2;
	Function SELECT_ALL_p return varchar2;
	Function ORDERBY_BAL_p return varchar2;
	Function ORDERBY_ACCT_p return varchar2;
	Function ORDERBY_ALL_p return varchar2;
	Function SELECT_ACCT_p return varchar2;
	Function TRANS_CHECK_BB_p return varchar2;
	Function TRANS_CHECK_BE_p return varchar2;
	Function WHERE_DAS_p return varchar2;
	Function RESULTING_CURRENCY_p return varchar2;
END GL_GLXBTB_XMLP_PKG;



/
