--------------------------------------------------------
--  DDL for Package GL_GLXBCSD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXBCSD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXBCSDS.pls 120.2 2008/01/07 20:11:07 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_LEDGER_ID	number;
	P_BUDGET_VERSION_ID	number;
	P_SEGMENT_VALUES	varchar2(1000);
	P_CURRENCY_CODE	varchar2(15);
	P_PERIOD_NAME	varchar2(15);
	P_ACCESS_SET_ID	number;
	STRUCT_NUM	number := 50105 ;
	LEDGER_NAME	varchar2(30);
	BUDGET_NAME	varchar2(15);
	FLEXDATA	varchar2(1000) := '(segment1||''\n''||segment2||''\n''||segment3||
	''\n''||segment4||''\n''||segment5||''\n''||segment6||''\n''||segment7||''\n''||segment8||
	''\n''||segment9||''\n''||segment10||''\n''||segment11||''\n''||segment12||''\n''||segment13||
	''\n''||segment14||''\n''||segment15||''\n''||segment16||''\n''||segment17||''\n''||segment18||
	''\n''||segment19||''\n''||segment20||''\n''||segment21||''\n''||segment22||''\n''||segment23||
	''\n''||segment24||''\n''||segment25||''\n''||segment26||''\n''||segment27||''\n''||segment28||
	''\n''||segment29||''\n''||segment30)' ;
	FLEX_ORDERBY	varchar2(1000) := '1' ;
	FLEX_WHERE	varchar2(9000) := 'segment1 = segment1' ;
	ACCESS_SET_NAME	varchar2(30);
	FUNCT_CURR_CODE	varchar2(15);
	DAS_WHERE	varchar2(800);
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	Function STRUCT_NUM_p return number;
	Function LEDGER_NAME_p return varchar2;
	Function BUDGET_NAME_p return varchar2;
	Function FLEXDATA_p return varchar2;
	Function FLEX_ORDERBY_p return varchar2;
	Function FLEX_WHERE_p return varchar2;
	Function ACCESS_SET_NAME_p return varchar2;
	Function FUNCT_CURR_CODE_p return varchar2;
	Function DAS_WHERE_p return varchar2;
END GL_GLXBCSD_XMLP_PKG;


/
