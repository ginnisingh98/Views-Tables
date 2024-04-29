--------------------------------------------------------
--  DDL for Package GL_GLYRLBGE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLYRLBGE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLYRLBGES.pls 120.0 2007/12/27 15:26:37 vijranga noship $ */
	P_LEDGER_ID	varchar2(40);
	P_PERIOD_NAME	varchar2(40);
	P_START_ACCOUNT	varchar2(40);
	P_END_ACCOUNT	varchar2(40);
	P_COMPANY	varchar2(40);
	P_CURRENCY_CODE	varchar2(40);
	P_CONC_REQUEST_ID	number;

	P_MINPRECISION	number;
	P_PRECISION	number;
	P_LEDGER_NAME	varchar2(30);
	P_CURRENCY_TYPE	varchar2(32767);
	P_LEDGER_CURRENCY	varchar2(32767);
	P_ENTERED_CURRENCY	varchar2(32767);
	P_CHART_OF_ACCOUNTS_ID	number;
	P_ACCESS_SET_ID	number;
	BEGIN_CR_SELECT	varchar2(1000) := '1' ;
	CURRENCY_NAME	varchar2(80) := 'US Dollars' ;
	ACCOUNTING_SEGMENT_WHERE	varchar2(1000) := '1 = 1' ;
	BEGIN_DR_SELECT	varchar2(1000) := '1' ;
	END_DR_SELECT	varchar2(1000) := '1' ;
	FIRST_PERIOD_NAME	varchar2(40);
	ACCOUNTING_ORDERBY	varchar2(1000) := '1' ;
	BALANCING_ORDERBY	varchar2(1000) := '1' ;
	BALANCING_SEGMENT_WHERE	varchar2(1000) := '1 = 1' ;
	STRUCT_NUM	varchar2(40) := '50104' ;
	BALANCING_SEGMENT	varchar2(5000) := 'cc.segment1' ;
	PER_DR_SELECT	varchar2(1000) := '1' ;
	ACCOUNTING_SEGMENT	varchar2(5000) := 'cc.segment2' ;
	END_CR_SELECT	varchar2(1000) := '1' ;
	PER_CR_SELECT	varchar2(1000) := '1' ;
	TRANSLATE_WHERE	varchar2(200);
	C_industry_code	varchar2(20);
	CURRENCY_WHERE	varchar2(1000) := '1 = 1' ;
	ACCESS_WHERE	varchar2(2000) := '1 = 1' ;
	ACTUAL_CURRENCY	varchar2(20);
	ACCESS_NAME	varchar2(30);
	function BeforeReport return boolean  ;
	function net_crformula(NET in number) return number  ;
	function comp_net_crformula(COMP_NET in number) return number  ;
	function cl_net_crformula(CL_NET in number) return number  ;
	function sc_net_crformula(SC_NET in number) return number  ;
	function gr_net_crformula(GR_NET in number) return number  ;
	procedure gl_get_ledger_info ( ledgerid in number,
                                coaid out NOCOPY number,
                                ledgername out NOCOPY varchar2,
                                func_curr out NOCOPY varchar2,
                                errbuf out NOCOPY varchar2)
   ;
	procedure gl_get_first_period(tledger_id      in number,
                                tperiod_name   in varchar2,
                                tfirst_period  out NOCOPY varchar2,
                                errbuf         out NOCOPY varchar2)

   ;
	function grand_net_crformula(GRAND_NET in number) return number  ;
	function c_bal_lpromptformula(C_BAL_LPROMPT in varchar2) return varchar2  ;
	procedure get_industry_code  ;
	function set_display_for_gov return boolean  ;
	function set_display_for_core return boolean  ;
	function g_maingroupfilter(ACCT_SECURE in varchar2, BEGIN_CR in number, BEGIN_DR in number, PER_DR in number, PER_CR in number) return boolean  ;
	function g_companygroupfilter(BAL_SECURE in varchar2) return boolean  ;
	function G_ClassGroupFilter return boolean  ;
	function zero_indicatorformula(BEGIN_CR in number, BEGIN_DR in number, PER_DR in number, PER_CR in number) return number  ;
	function g_sub_classgroupfilter(BEGIN_CR in number, BEGIN_DR in number, PER_DR in number, PER_CR in number) return boolean  ;
	function g_groupsgroupfilter(BEGIN_CR in number, BEGIN_DR in number, PER_DR in number, PER_CR in number) return boolean  ;
	function company_lprompt_ndformula(COMPANY_LPROMPT_ND in varchar2) return char  ;
	function AfterReport return boolean  ;
	Function BEGIN_CR_SELECT_p return varchar2;
	Function CURRENCY_NAME_p return varchar2;
	Function ACCOUNTING_SEGMENT_WHERE_p return varchar2;
	Function BEGIN_DR_SELECT_p return varchar2;
	Function END_DR_SELECT_p return varchar2;
	Function FIRST_PERIOD_NAME_p return varchar2;
	Function ACCOUNTING_ORDERBY_p return varchar2;
	Function BALANCING_ORDERBY_p return varchar2;
	Function BALANCING_SEGMENT_WHERE_p return varchar2;
	Function STRUCT_NUM_p return varchar2;
	Function BALANCING_SEGMENT_p return varchar2;
	Function PER_DR_SELECT_p return varchar2;
	Function ACCOUNTING_SEGMENT_p return varchar2;
	Function END_CR_SELECT_p return varchar2;
	Function PER_CR_SELECT_p return varchar2;
	Function TRANSLATE_WHERE_p return varchar2;
	Function C_industry_code_p return varchar2;
	Function CURRENCY_WHERE_p return varchar2;
	Function ACCESS_WHERE_p return varchar2;
	Function ACTUAL_CURRENCY_p return varchar2;
	Function ACCESS_NAME_p return varchar2;
END GL_GLYRLBGE_XMLP_PKG;



/
