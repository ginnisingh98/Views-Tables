--------------------------------------------------------
--  DDL for Package GL_GLXAVADT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXAVADT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXAVADTS.pls 120.2 2008/01/07 20:08:59 vijranga noship $ */
	P_REPORTING_DATE	date;
	P_BALANCE_TYPE	varchar2(5);
	P_LEDGER_ID	number;
	P_CONC_REQUEST_ID	number;
	P_MIN_FLEX	varchar2(1000);
	P_MAX_FLEX	varchar2(1000);
	P_ENTERED_CURRENCY	varchar2(15);
	P_ACCESS_SET_ID	number;
	P_CURRENCY_TYPE	varchar2(1);
	last_eod	number;
	STRUCT_NUM	number;
	LEDGER_NAME	varchar2(30);
	--PERIOD_SET_NAME	varchar2(15);
	PERIOD_SET_NAME_1	varchar2(15);
	--PERIOD_YEAR	number;
	PERIOD_YEAR_1	number;
	QUARTER_NUM	number;
	PERIOD_NUM	number;
	REPORTING_CURR	varchar2(15);
	START_DATE	date;
	START_PERIOD_NAME	varchar2(15);
	SELECT_BAL	varchar2(1000) := '(CC.SEGMENT1 || ''\n'' || SEGMENT2 || ''\n'' || SEGMENT3 || ''\n'' ||
	SEGMENT4 || ''\n'' || SEGMENT5 || ''\n'' || SEGMENT6 || ''\n'' || SEGMENT7 || ''\n'' || SEGMENT8
	|| ''\n'' || SEGMENT9 || ''\n'' || SEGMENT10 || ''\n'' || SEGMENT11 || ''\n'' || SEGMENT12
	|| ''\n'' || SEGMENT13 || ''\n'' || SEGMENT14 || ''\n'' || SEGMENT15 || ''\n'' || SEGMENT16
	|| ''\n'' || SEGMENT17 || ''\n'' || SEGMENT18 || ''\n'' || SEGMENT19 || ''\n'' || SEGMENT20
	|| ''\n'' || SEGMENT21 || ''\n'' || SEGMENT22 || ''\n'' || SEGMENT23 || ''\n'' || SEGMENT24
	|| ''\n'' || SEGMENT25 || ''\n'' || SEGMENT26 || ''\n'' || SEGMENT27 || ''\n'' || SEGMENT28
	|| ''\n'' || SEGMENT29 || ''\n'' || SEGMENT30)' ;
	WHERE_FLEX_RANGE	varchar2(4000) := 'CC.SEGMENT11 BETWEEN  ''00'' and ''11''' ;
	SELECT_ALL	varchar2(1000) := '(CC.SEGMENT1 || ''\n'' || SEGMENT2 || ''\n'' || SEGMENT3
	|| ''\n'' || SEGMENT4 || ''\n'' || SEGMENT5 || ''\n'' || SEGMENT6 || ''\n'' || SEGMENT7
	|| ''\n'' || SEGMENT8 || ''\n'' || SEGMENT9 || ''\n'' || SEGMENT10 || ''\n'' || SEGMENT11
	|| ''\n'' || SEGMENT12 || ''\n'' || SEGMENT13 || ''\n'' || SEGMENT14 || ''\n'' || SEGMENT15
	|| ''\n'' || SEGMENT16 || ''\n'' || SEGMENT17 || ''\n'' || SEGMENT18 || ''\n'' || SEGMENT19
	|| ''\n'' || SEGMENT20 || ''\n'' || SEGMENT21 || ''\n'' || SEGMENT22 || ''\n'' || SEGMENT23
	|| ''\n'' || SEGMENT24 || ''\n'' || SEGMENT25 || ''\n'' || SEGMENT26 || ''\n'' || SEGMENT27
	|| ''\n'' || SEGMENT28 || ''\n'' || SEGMENT29 || ''\n'' || SEGMENT30)' ;
	ORDERBY_BAL	varchar2(50) := 'CC.SEGMENT10' ;
	ORDERBY_ALL	varchar2(800) := 'CC.SEGMENT1, CC.SEGMENT2, CC.SEGMENT3, CC.SEGMENT4, CC.SEGMENT5,
	CC.SEGMENT6, CC.SEGMENT7, CC.SEGMENT8, CC.SEGMENT9, CC.SEGMENT10, CC.SEGMENT11, CC.SEGMENT12,
	CC.SEGMENT13, CC.SEGMENT14, CC.SEGMENT15, CC.SEGMENT16, CC.SEGMENT17, CC.SEGMENT18, CC.SEGMENT19,
	CC.SEGMENT20, CC.SEGMENT21, CC.SEGMENT22, CC.SEGMENT23, CC.SEGMENT24, CC.SEGMENT25, CC.SEGMENT26,
	CC.SEGMENT27, CC.SEGMENT28, CC.SEGMENT29, CC.SEGMENT30' ;
	ORDERBY_ACCT	varchar2(50) := 'CC.SEGMENT10' ;
	--PERIOD_TYPE	varchar2(15);
	PERIOD_TYPE_1	varchar2(15);
	ACCESS_SET_NAME	varchar2(30);
	--WHERE_DAS	varchar2(800);
        WHERE_DAS	varchar2(800):='';
	LEDGER_CURRENCY	varchar2(15);
	function BeforeReport return boolean  ;
	function opening_balformula(CCID in number) return number  ;
	function last_ccidformula(last_ccid in number, ccid in number, opening_bal in number) return number  ;
	function daily_activityformula(end_of_date_balance in number) return number  ;
	function AfterReport return boolean  ;
	procedure gl_get_period_info (ldgrid 		   in number,
                                reporting_date     in date,
                                calendar_name      in varchar2,
                                v_period_year      out NOCOPY number,
                                v_quarter_num      out NOCOPY number,
                                v_period_num       out NOCOPY number,
				errbuf	   	   out NOCOPY varchar2 )
   ;
	procedure gl_get_first_date(ldgrid            in number,
			      balance_type     in varchar2,
                              v_period_year    in number,
                              v_quarter_num    in number,
                              v_period_num     in number,
                              v_period_name    out NOCOPY varchar2,
                              v_start_date     out NOCOPY date,
			      errbuf           out NOCOPY varchar2)
   ;
	function g_balancing_seggroupfilter(BAL_SECURE in varchar2) return boolean  ;
	function g_opening_balgroupfilter(ACCT_SECURE in varchar2) return boolean  ;
	Function last_eod_p return number;
	Function STRUCT_NUM_p return number;
	Function LEDGER_NAME_p return varchar2;
	Function PERIOD_SET_NAME_p return varchar2;
	Function PERIOD_YEAR_p return number;
	Function QUARTER_NUM_p return number;
	Function PERIOD_NUM_p return number;
	Function REPORTING_CURR_p return varchar2;
	Function START_DATE_p return date;
	Function START_PERIOD_NAME_p return varchar2;
	Function SELECT_BAL_p return varchar2;
	Function WHERE_FLEX_RANGE_p return varchar2;
	Function SELECT_ALL_p return varchar2;
	Function ORDERBY_BAL_p return varchar2;
	Function ORDERBY_ALL_p return varchar2;
	Function ORDERBY_ACCT_p return varchar2;
	Function PERIOD_TYPE_p return varchar2;
	Function ACCESS_SET_NAME_p return varchar2;
	Function WHERE_DAS_p return varchar2;
	Function LEDGER_CURRENCY_p return varchar2;
END GL_GLXAVADT_XMLP_PKG;

/
