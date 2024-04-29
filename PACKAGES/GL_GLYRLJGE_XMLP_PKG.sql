--------------------------------------------------------
--  DDL for Package GL_GLYRLJGE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLYRLJGE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLYRLJGES.pls 120.1 2008/06/25 11:45:14 vijranga noship $ */
	P_LEDGER_ID	number;
	P_CURRENCY_CODE	varchar2(15);
	P_START_PERIOD	varchar2(32767);
	P_END_PERIOD	varchar2(32767);
	P_JOURNAL_CAT	varchar2(25);
	P_JOURNAL_CAT_1	varchar2(25);
	P_COMPANY	varchar2(30);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_FLEXDATA	varchar2(800);
	P_STRUCT_NUM	number;
	P_BALANCE_SEG	varchar2(800);
	P_ADJUSTMENT_PERIODS	varchar2(1);
	P_ORDERBY_ALL	varchar2(2000);
	P_ACCESS_SET_ID	number;
	C_WHERE	varchar2(300);
	C_CHART_OF_ACCTS_ID	varchar2(15);
	C_START_DATE	date;
	C_END_DATE	date;
	C_START_DATE1	varchar2(20);
	C_END_DATE1	varchar2(20);
	C_MESSAGE	varchar2(80);
	C_industry_code	varchar2(20);
	C_WHERE_PERIOD	varchar2(100);
	C_ACCESS_SET_NAME	varchar2(30);
	C_ACCESS_WHERE	varchar2(2000);
	C_LEDGER_FROM	varchar2(1000);
	C_LEDGER_WHERE	varchar2(1000);
	PARAM_LEDGER_TYPE	varchar2(1) := 'S' ;
	PARAM_LEDGER_NAME	varchar2(30);
	PARAM_LEDGER_CURR	varchar2(20);
	CONSOLIDATION_LEDGER_FLAG	varchar2(1) := 'S' ;
	CURR_FORMAT_MASK	varchar2(100);
	MIXED_PRECISION	number;
	THOUSANDS_SEPARATOR	varchar2(80);
	WIDTH	number := 19 ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function c_curr_nameformula(currency1 in varchar2) return varchar2  ;
	function c_bal_lpromptformula(C_Bal_lprompt in varchar2) return varchar2  ;
	function set_display_for_core return boolean  ;
	function set_display_for_gov return boolean  ;
	procedure get_industry_code  ;
	function c_entryformula(doc_sequence in number, entry_name in varchar2) return varchar2  ;
	function g_journalgroupfilter(FLEX_SECURE in varchar2, ACCOUNTED_CR in number, ACCOUNTED_DR in number, ENTERED_DR in number, ENTERED_CR in number) return boolean  ;
	function g_company_mastergroupfilter(BAL_SECURE in varchar2) return boolean  ;
	function BetweenPage return boolean  ;
	--function gl_format_currency(amount number)(Amount  NUMBER) return varchar2  ;
	function gl_format_currency(amount number) return varchar2  ;
	function company_lprompt_ndformula(COMPANY_LPROMPT_ND in varchar2) return char  ;
	function zero_indicatorformula(ACCOUNTED_CR in number, ACCOUNTED_DR in number, ENTERED_DR in number, ENTERED_CR in number) return number  ;
	function C_MESSAGEFormula return Char  ;
	function g_journal_entriesgroupfilter(ACCOUNTED_CR in number, ACCOUNTED_DR in number, ENTERED_DR in number, ENTERED_CR in number) return boolean  ;
	function g_batchesgroupfilter(ACCOUNTED_CR in number, ACCOUNTED_DR in number, ENTERED_DR in number, ENTERED_CR in number) return varchar2  ;
	Function C_WHERE_p return varchar2;
	Function C_CHART_OF_ACCTS_ID_p return varchar2;
	Function C_START_DATE_p return date;
	Function C_END_DATE_p return date;
	Function C_MESSAGE_p return varchar2;
	Function C_industry_code_p return varchar2;
	Function C_WHERE_PERIOD_p return varchar2;
	Function C_ACCESS_SET_NAME_p return varchar2;
	Function C_ACCESS_WHERE_p return varchar2;
	Function C_LEDGER_FROM_p return varchar2;
	Function C_LEDGER_WHERE_p return varchar2;
	Function PARAM_LEDGER_TYPE_p return varchar2;
	Function PARAM_LEDGER_NAME_p return varchar2;
	Function PARAM_LEDGER_CURR_p return varchar2;
	Function CONSOLIDATION_LEDGER_FLAG_p return varchar2;
	Function CURR_FORMAT_MASK_p return varchar2;
	Function MIXED_PRECISION_p return number;
	Function THOUSANDS_SEPARATOR_p return varchar2;
	Function WIDTH_p return number;
END GL_GLYRLJGE_XMLP_PKG;


/
