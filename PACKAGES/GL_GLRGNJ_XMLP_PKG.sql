--------------------------------------------------------
--  DDL for Package GL_GLRGNJ_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLRGNJ_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLRGNJS.pls 120.0 2007/12/27 14:37:18 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_JE_SOURCE_NAME	varchar2(25);
	STAT varchar2(120);
	P_PERIOD_NAME	varchar2(15);
	P_BATCH_NAME	varchar2(100);
	P_POSTING_STATUS	varchar2(1);
	P_CURRENCY_CODE	varchar2(15);
	P_START_DATE	date;
	P_END_DATE	date;
	P_PAGESIZE	number;
	P_KIND	varchar2(1);
	P_LEDGER_ID	number;
	P_ACCESS_SET_ID	number;
		FLEXDATA	varchar2(5000) := '(segment1||''\n''||segment2||''\n''||
		segment3||''\n''||segment4||''\n''||segment5||''\n''||segment6||''\n''||
		segment7||''\n''||segment8||''\n''||segment9||''\n''||segment10||''\n''||
		segment11||''\n''||segment12||''\n''||segment13||''\n''||segment14||''\n''||
		segment15||''\n''||segment16||''\n''||segment17||''\n''||segment18||''\n''||
		segment19||''\n''||segment20||''\n''||segment21||''\n''||segment22||''\n''||
		segment23||''\n''||segment24||''\n''||segment25||''\n''||segment26||''\n''||
		segment27||''\n''||segment28||''\n''||segment29||''\n''||segment30)' ;
	POSTING_STATUS_SELECT	varchar2(1000) := 'reference_1' ;
	POSTING_STATUS_WHERE	varchar2(1000) := '1 = 1' ;
	PERIOD_WHERE	varchar2(1000) := '1 = 1' ;
	CURRENCY_WHERE	varchar2(100) := '1 = 1' ;
	STRUCT_NUM	varchar2(15) := '50105' ;
	PARAM_LEDGER_NAME	varchar2(30);
	INV_FLEX_MSG	varchar2(100);
	WIDTH	number := 19 ;
	JE_USER_SOURCE_DSP	varchar2(25);
	ACCESS_SET_NAME	varchar2(30);
	DAS_WHERE	varchar2(600);
	LEDGER_FROM	varchar2(50);
	LEDGER_WHERE	varchar2(150):=' ';
	PARAM_LEDGER_TYPE	varchar2(1) := 'S' ;
	CONSOLIDATION_LEDGER_FLAG	varchar2(1);
	PARAM_CURRENCY	varchar2(15);
	PARAM_PERIOD_NAME	varchar2(15);
	PARAM_START_DATE	date;
	PARAM_END_DATE	date;
	PARAM_REFERENCE_TYPE	varchar2(80);
	PARAM_POSTING_STATUS	varchar2(80);
	PERIOD_FROM	varchar2(15);
	PERIOD_TO	varchar2(15);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function g_linesgroupfilter(FLEXDATA_SECURE in varchar2) return boolean  ;
	Function FLEXDATA_p return varchar2;
	Function POSTING_STATUS_SELECT_p return varchar2;
	Function POSTING_STATUS_WHERE_p return varchar2;
	Function PERIOD_WHERE_p return varchar2;
	Function CURRENCY_WHERE_p return varchar2;
	Function STRUCT_NUM_p return varchar2;
	Function PARAM_LEDGER_NAME_p return varchar2;
	Function INV_FLEX_MSG_p return varchar2;
	Function WIDTH_p return number;
	Function JE_USER_SOURCE_DSP_p return varchar2;
	Function ACCESS_SET_NAME_p return varchar2;
	Function DAS_WHERE_p return varchar2;
	Function LEDGER_FROM_p return varchar2;
	Function LEDGER_WHERE_p return varchar2;
	Function PARAM_LEDGER_TYPE_p return varchar2;
	Function CONSOLIDATION_LEDGER_FLAG_p return varchar2;
	Function PARAM_CURRENCY_p return varchar2;
	Function PARAM_PERIOD_NAME_p return varchar2;
	Function PARAM_START_DATE_p return date;
	Function PARAM_END_DATE_p return date;
	Function PARAM_REFERENCE_TYPE_p return varchar2;
	Function PARAM_POSTING_STATUS_p return varchar2;
	Function PERIOD_FROM_p return varchar2;
	Function PERIOD_TO_p return varchar2;
END GL_GLRGNJ_XMLP_PKG;


/
