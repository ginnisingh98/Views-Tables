--------------------------------------------------------
--  DDL for Package GL_GLXAVTRB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXAVTRB_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXAVTRBS.pls 120.0 2007/12/27 14:44:49 vijranga noship $ */
	P_REPORTING_DATE	date;
	P_ENTERED_CURRENCY	varchar2(15);
	P_CURRENCY_TYPE	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_MAX_FLEX	varchar2(2000);
	P_MIN_FLEX	varchar2(2000);
	P_LEDGER_CURRENCY	varchar2(15);
	P_ACCESS_SET_ID	number;
	P_LEDGER_ID	number;
	WHERE_lexical	varchar2(4000) := 'cc.segment11 between ''00'' and ''11''' ;
	CURR_TYPE	varchar2(100) := 'dbs.currency_type = ''E''' ;
	WHERE_DAS	varchar2(600);
	ACCESS_SET_NAME	varchar2(30);
	STRUCT_NUM	varchar2(15);
	RESULTING_CURRENCY	varchar2(15);
	SELECT_BAL	varchar2(4000) := '(segment1||''\n''||segment2 || ''\n'' ||segment3||''\n''||
	segment4||''\n''||segment5||''\n''||segment6||''\n''||segment7||''\n''||segment8||''\n''||segment9||
	''\n''||segment10||''\n''|| segment11||''\n''||segment12||''\n''||segment13||''\n''||segment14||''\n''||
	segment15||''\n''||segment16||''\n''||segment17||''\n''||segment18||''\n''||segment19||''\n''||
	segment20||''\n''|| segment21||''\n''||segment22||''\n''||segment23||''\n''||segment24||''\n''||
	segment25||''\n''||segment26||''\n''||segment27||''\n''||segment28||''\n''||segment29||''\n''||segment30)' ;
	SELECT_FLEXDATA	varchar2(4000) := '(segment1||''\n''||segment2 || ''\n'' ||segment3||''\n''||
	segment4||''\n''||segment5||''\n''||segment6||''\n''||segment7||''\n''||segment8||''\n''||segment9||
	''\n''||segment10||''\n''|| segment11||''\n''||segment12||''\n''||segment13||''\n''||segment14||
	''\n''||segment15||''\n''||segment16||''\n''||segment17||''\n''||segment18||''\n''||segment19||''\n''||
	segment20||''\n''|| segment21||''\n''||segment22||''\n''||segment23||''\n''||segment24||''\n''||
	segment25||''\n''||segment26||''\n''||segment27||''\n''||segment28||''\n''||segment29||''\n''||segment30)' ;
	ORDERBY	varchar2(2000) := 'cc.segment1' ;
	PERIOD_NAME	varchar2(20);
	PERIOD_START_DATE	date;
	QUARTER_START_DATE	date;
	YEAR_START_DATE	date;
	PTD_POSITION	number := 1 ;
	QTD_POSITION	number := 1 ;
	YTD_POSITION	number := 1 ;
	MAU	number;
	PRECISION	number := 1 ;
	P_ENDING_BALANCE	varchar2(2000) := 'dbs.Period_Aggregate1' ;
	P_PATD	varchar2(2000) := 'dbs.Period_Aggregate1' ;
	P_QATD	varchar2(2000) := 'Period_Aggregate1' ;
	P_YATD	varchar2(2000) := 'Period_Aggregate1' ;
	P_PTD_AGGREGATE	varchar2(2000) := 'dbs.Period_Aggregate1' ;
	P_QTD_AGGREGATE	varchar2(2000) := 'dbs.Quarter_Aggregate1' ;
	P_YTD_AGGREGATE	varchar2(2000) := 'dbs.Year_Aggregate1' ;
	function BeforeReport return boolean  ;
	FUNCTION AfterReportTrigger return boolean  ;
	function patd(PTD_Aggregate_Total in number) return number  ;
	function qatd(QTD_Aggregate_Total in number) return number  ;
	function yatd(YTD_Aggregate_Total in number) return number  ;
	function end_bal(END_BAL_Total in number) return number  ;
	function g_headergroupfilter(BAL_SECURE in varchar2) return boolean  ;
	function g_detailgroupfilter(FLEX_SECURE in varchar2) return boolean  ;
	Function WHERE_p return varchar2;
	Function CURR_TYPE_p return varchar2;
	Function WHERE_DAS_p return varchar2;
	Function ACCESS_SET_NAME_p return varchar2;
	Function STRUCT_NUM_p return varchar2;
	Function RESULTING_CURRENCY_p return varchar2;
	Function SELECT_BAL_p return varchar2;
	Function SELECT_FLEXDATA_p return varchar2;
	Function ORDERBY_p return varchar2;
	Function PERIOD_NAME_p return varchar2;
	Function PERIOD_START_DATE_p return date;
	Function QUARTER_START_DATE_p return date;
	Function YEAR_START_DATE_p return date;
	Function PTD_POSITION_p return number;
	Function QTD_POSITION_p return number;
	Function YTD_POSITION_p return number;
	Function MAU_p return number;
	Function PRECISION_p return number;
	Function P_ENDING_BALANCE_p return varchar2;
	Function P_PATD_p return varchar2;
	Function P_QATD_p return varchar2;
	Function P_YATD_p return varchar2;
	Function P_PTD_AGGREGATE_p return varchar2;
	Function P_QTD_AGGREGATE_p return varchar2;
	Function P_YTD_AGGREGATE_p return varchar2;
END GL_GLXAVTRB_XMLP_PKG;



/
