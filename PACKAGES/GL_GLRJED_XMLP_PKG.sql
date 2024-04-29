--------------------------------------------------------
--  DDL for Package GL_GLRJED_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLRJED_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLRJEDS.pls 120.0 2007/12/27 14:39:14 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_LEDGER_ID	varchar2(15);
	P_KIND	varchar2(1);
	P_LEDGER_CURRENCY	varchar2(15);
	P_ACTUAL_FLAG	varchar2(1);
	P_BUD_ENC_TYPE_ID	number;
	P_START_PERIOD	varchar2(15);
	P_END_PERIOD	varchar2(15);
	P_MIN_FLEX	varchar2(1000);
	P_MAX_FLEX	varchar2(1000);
	P_ORDER_TYPE	varchar2(1);
	P_PAGE_SIZE	number;
	P_ACCESS_SET_ID	number;
	P_CURRENCY_TYPE	varchar2(1);
	P_ENTERED_CURRENCY	varchar2(15);
	STRUCT_NUM	varchar2(15):= '101' ;
	ACCESS_SET_NAME	varchar2(30);
	SELECT_ALL	varchar2(1000) := '(CC.SEGMENT1 || ''\n'' || SEGMENT2 || ''\n'' ||
	SEGMENT3 || ''\n'' || SEGMENT4 || ''\n'' || SEGMENT5 || ''\n'' || SEGMENT6 || ''\n'' ||
	SEGMENT7 || ''\n'' || SEGMENT8 || ''\n'' || SEGMENT9 || ''\n'' || SEGMENT10 || ''\n'' ||
	SEGMENT11 || ''\n'' || SEGMENT12 || ''\n'' || SEGMENT13 || ''\n'' || SEGMENT14 || ''\n'' ||
	SEGMENT15 || ''\n'' || SEGMENT16 || ''\n'' || SEGMENT17 || ''\n'' || SEGMENT18 || ''\n'' ||
	SEGMENT19 || ''\n'' || SEGMENT20 || ''\n'' || SEGMENT21 || ''\n'' || SEGMENT22 || ''\n'' ||
	SEGMENT23 || ''\n'' || SEGMENT24 || ''\n'' || SEGMENT25 || ''\n'' || SEGMENT26 || ''\n'' ||
	SEGMENT27 || ''\n'' || SEGMENT28 || ''\n'' || SEGMENT29 || ''\n'' || SEGMENT30)' ;
	WHERE_FLEX	varchar2(4000) := 'CC.SEGMENT11 BETWEEN  ''00'' and ''11''' ;
	ORDERBY_BAL	varchar2(50) := 'CC.SEGMENT10' ;
	ORDERBY_ACCT	varchar2(30) := 'CC.SEGMENT10' ;
	ORDERBY_ALL	varchar2(800) := 'CC.SEGMENT1, CC.SEGMENT2, CC.SEGMENT3, CC.SEGMENT4, CC.SEGMENT5, CC.SEGMENT6,
	CC.SEGMENT7, CC.SEGMENT8, CC.SEGMENT9, CC.SEGMENT10, CC.SEGMENT11, CC.SEGMENT12, CC.SEGMENT13, CC.SEGMENT14,
	CC.SEGMENT15, CC.SEGMENT16, CC.SEGMENT17, CC.SEGMENT18, CC.SEGMENT19, CC.SEGMENT20, CC.SEGMENT21, CC.SEGMENT22,
	CC.SEGMENT23, CC.SEGMENT24, CC.SEGMENT25, CC.SEGMENT26, CC.SEGMENT27, CC.SEGMENT28, CC.SEGMENT29, CC.SEGMENT30' ;
	WHERE_ACTUAL_TYPE	varchar2(100) := 'budget_version_id = 1000' ;
	WHERE_CURRENCY_CODE	varchar2(200) := 'jeh.currency_code <> ''STAT''' ;
	SELECT_REFERENCE	varchar2(50) := 'jeh.external_reference' ;
	SELECT_CR	varchar2(500) := 'jel.accounted_cr' ;
	SELECT_DR	varchar2(500) := 'jel.accounted_dr' ;
	ORDER_BY	varchar2(5000) := 'cc.segment11, cc.segment12, cc.segment13, cc.segment14,
	cc.segment1, cc.segment2, cc.segment3, cc.segment4, cc.segment5, cc.segment6, cc.segment7,
	cc.segment8, cc.segment9, cc.segment10, cc.segment11, cc.segment12, cc.segment13, cc.segment14,
	cc.segment15, cc.segment16, cc.segment17, cc.segment18, cc.segment19, cc.segment20, cc.segment21,
	cc.segment22, cc.segment23, cc.segment24, cc.segment25, cc.segment26, cc.segment27, cc.segment28,
	cc.segment29, cc.segment30, src.user_je_source_name, cat.user_je_category_name, jeb.name, jeh.name' ;
	ORDERBY_BAL2	varchar2(800) := 'cc.segment1, cc.segment2, cc.segment3, cc.segment4, cc.segment5,
	cc.segment6, cc.segment7, cc.segment8, cc.segment9, cc.segment10, cc.segment11, cc.segment12,
	cc.segment13, cc.segment14, cc.segment15, cc.segment16, cc.segment17, cc.segment18, cc.segment19,
	cc.segment20, cc.segment21, cc.segment22, cc.segment23, cc.segment24, cc.segment25, cc.segment26,
	cc.segment27, cc.segment28, cc.segment29, cc.segment30' ;
	ORDERBY_ACCT2	varchar2(800) := 'cc.segment1, cc.segment2, cc.segment3, cc.segment4, cc.segment5,
	cc.segment6, cc.segment7, cc.segment8, cc.segment9, cc.segment10, cc.segment11, cc.segment12,
	cc.segment13, cc.segment14, cc.segment15, cc.segment16, cc.segment17, cc.segment18, cc.segment19,
	cc.segment20, cc.segment21, cc.segment22, cc.segment23, cc.segment24, cc.segment25, cc.segment26,
	cc.segment27, cc.segment28, cc.segment29, cc.segment30' ;
	WHERE_CURRENCY_BAL	varchar2(100) := '1 = 1' ;
	SECURITY_FILTER_STR	varchar2(150) := ' ';
	RESULTING_CURRENCY	varchar2(15);
	WHERE_DAS_BAL	varchar2(600);
	WHERE_DAS_JE	varchar2(600);
	SELECT_BEGIN_DR	varchar2(100) := 'sum(nvl(bal.begin_balance_dr,0))' ;
	SELECT_BEGIN_CR	varchar2(100) := 'sum(nvl(bal.begin_balance_cr,0))' ;
	SELECT_END_DR	varchar2(200) := 'sum(nvl(bal.begin_balance_dr,0) + nvl(bal.period_net_dr,0))' ;
	SELECT_END_CR	varchar2(200) := 'sum(nvl(bal.begin_balance_cr,0) + nvl(bal.period_net_cr,0))' ;
	PARAM_ACCT_FROM	varchar2(1000);
	PARAM_ACCT_TO	varchar2(1000);
	PARAM_PERIOD_FROM	varchar2(15);
	PARAM_PERIOD_TO	varchar2(15);
	PARAM_REFERENCE_TYPE	varchar2(80);
	DR_MEANING	varchar2(80);
	CR_MEANING	varchar2(80);
	PARAM_CURRENCY_TYPE	varchar2(1);
	function AfterReport return boolean  ;
	function begin_balformula(BEGIN_DR in number, BEGIN_CR in number) return number  ;
	function end_balformula(END_DR in number, END_CR in number) return number  ;
	function BUD_ENC_TYPE_NAMEFormula return VARCHAR2  ;
	function DISP_ACTUAL_FLAGFormula return VARCHAR2  ;
	function START_EFFECTIVE_PERIOD_NUMForm return Number ;
	function END_EFFECTIVE_PERIOD_NUMFormul return Number ;
	function BeforeReport return boolean  ;
	procedure gl_get_effective_num (tledger_id       IN NUMBER,
                                tperiod_name     IN VARCHAR2,
                                teffnum          OUT NOCOPY NUMBER,
                                errbuf           OUT NOCOPY VARCHAR2)
 ;
	function g_maingroupfilter(FLEX_SECURE in varchar2) return boolean  ;
	function begin_bal_dr_crformula(BEGIN_DR in number, BEGIN_CR in number) return char  ;
	function end_bal_dr_crformula(END_DR in number, END_CR in number) return char  ;
	Function STRUCT_NUM_p return varchar2;
	Function ACCESS_SET_NAME_p return varchar2;
	Function SELECT_ALL_p return varchar2;
	Function WHERE_FLEX_p return varchar2;
	Function ORDERBY_BAL_p return varchar2;
	Function ORDERBY_ACCT_p return varchar2;
	Function ORDERBY_ALL_p return varchar2;
	Function WHERE_ACTUAL_TYPE_p return varchar2;
	Function WHERE_CURRENCY_CODE_p return varchar2;
	Function SELECT_REFERENCE_p return varchar2;
	Function SELECT_CR_p return varchar2;
	Function SELECT_DR_p return varchar2;
	Function ORDER_BY_p return varchar2;
	Function ORDERBY_BAL2_p return varchar2;
	Function ORDERBY_ACCT2_p return varchar2;
	Function WHERE_CURRENCY_BAL_p return varchar2;
	Function SECURITY_FILTER_STR_p return varchar2;
	Function RESULTING_CURRENCY_p return varchar2;
	Function WHERE_DAS_BAL_p return varchar2;
	Function WHERE_DAS_JE_p return varchar2;
	Function SELECT_BEGIN_DR_p return varchar2;
	Function SELECT_BEGIN_CR_p return varchar2;
	Function SELECT_END_DR_p return varchar2;
	Function SELECT_END_CR_p return varchar2;
	Function PARAM_ACCT_FROM_p return varchar2;
	Function PARAM_ACCT_TO_p return varchar2;
	Function PARAM_PERIOD_FROM_p return varchar2;
	Function PARAM_PERIOD_TO_p return varchar2;
	Function PARAM_REFERENCE_TYPE_p return varchar2;
	Function DR_MEANING_p return varchar2;
	Function CR_MEANING_p return varchar2;
	Function PARAM_CURRENCY_TYPE_p return varchar2;
END GL_GLRJED_XMLP_PKG;



/
