--------------------------------------------------------
--  DDL for Package GL_GLXRLVAT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXRLVAT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXRLVATS.pls 120.0 2007/12/27 15:23:35 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_LEDGER_ID	number;
	P_PERIOD_NAME	varchar2(15);
	P_CURRENCY_CODE	varchar2(15);
	P_TAX_CODE	varchar2(15);
	P_ACCESS_SET_ID	number;
	STRUCT_NUM	varchar2(15);
	LEDGER_NAME	varchar2(30);
	/*FLEX_SELECT_ALL	varchar2(1000) := '(gcc.SEGMENT1 || '\n' || gcc.SEGMENT2 || '\n' || gcc.SEGMENT3 || '\n' || gcc.SEGMENT4 || '\n' ||
	gcc.SEGMENT5 || '\n' || gcc.SEGMENT6 || '\n' || gcc.SEGMENT7 || '\n' || gcc.SEGMENT8 || '\n' || gcc.SEGMENT9 || '\n' || gcc.SEGMENT10 || '\n'
	|| gcc.SEGMENT11 || '\n' || gcc.SEGMENT12 || '\n' || gcc.SEGMENT13 || '\n' || gcc.SEGMENT14 || '\n' || gcc.SEGMENT15 || '\n' || gcc.SEGMENT16
	|| '\n' || gcc.SEGMENT17 || '\n' || gcc.SEGMENT18 || '\n' || gcc.SEGMENT19 || '\n' || gcc.SEGMENT20 || '\n' || gcc.SEGMENT21 || '\n'
	|| gcc.SEGMENT22 || '\n' || gcc.SEGMENT23 || '\n' || gcc.SEGMENT24 || '\n' || gcc.SEGMENT25 || '\n' || gcc.SEGMENT26 || '\n' || gcc.SEGMENT27
	|| '\n' || gcc.SEGMENT28 || '\n' || gcc.SEGMENT29 || '\n' || gcc.SEGMENT30)' ;
	FLEX_ORDERBY_ALL	varchar2(1000) := '(gcc.SEGMENT1 || '\n' || gcc.SEGMENT2 || '\n' || gcc.SEGMENT3 || '\n' || gcc.SEGMENT4 || '\n'
	|| gcc.SEGMENT5 || '\n' || gcc.SEGMENT6 || '\n' || gcc.SEGMENT7 || '\n' || gcc.SEGMENT8 || '\n' || gcc.SEGMENT9 || '\n' || gcc.SEGMENT10
	|| '\n' || gcc.SEGMENT11 || '\n' || gcc.SEGMENT12 || '\n' || gcc.SEGMENT13 || '\n' || gcc.SEGMENT14 || '\n' || gcc.SEGMENT15 || '\n' ||
	gcc.SEGMENT16 || '\n' || gcc.SEGMENT17 || '\n' || gcc.SEGMENT18 || '\n' || gcc.SEGMENT19 || '\n' || gcc.SEGMENT20 || '\n' || gcc.SEGMENT21
	|| '\n' || gcc.SEGMENT22 || '\n' || gcc.SEGMENT23 || '\n' || gcc.SEGMENT24 || '\n' || gcc.SEGMENT25 || '\n' || gcc.SEGMENT26 || '\n' ||
	gcc.SEGMENT27 || '\n' || gcc.SEGMENT28 || '\n' || gcc.SEGMENT29 || '\n' || gcc.SEGMENT30)' ;
	*/
	FLEX_SELECT_ALL	varchar2(1000) := '(gcc.SEGMENT1 || ''\n'' || gcc.SEGMENT2 || ''\n'' || gcc.SEGMENT3 || ''\n'' || gcc.SEGMENT4 || ''\n''
	|| gcc.SEGMENT5 || ''\n'' || gcc.SEGMENT6 || ''\n'' || gcc.SEGMENT7 || ''\n'' || gcc.SEGMENT8 || ''\n'' || gcc.SEGMENT9 || ''\n'' ||
	gcc.SEGMENT10 || ''\n'' || gcc.SEGMENT11 || ''\n'' || gcc.SEGMENT12 || ''\n'' || gcc.SEGMENT13 || ''\n'' || gcc.SEGMENT14 || ''\n'' ||
	gcc.SEGMENT15 || ''\n'' || gcc.SEGMENT16 || ''\n'' || gcc.SEGMENT17 || ''\n'' || gcc.SEGMENT18 || ''\n'' || gcc.SEGMENT19 || ''\n'' ||
	gcc.SEGMENT20 || ''\n'' || gcc.SEGMENT21 || ''\n'' || gcc.SEGMENT22 || ''\n'' || gcc.SEGMENT23 || ''\n'' || gcc.SEGMENT24 || ''\n'' ||
	gcc.SEGMENT25 || ''\n'' || gcc.SEGMENT26 || ''\n'' || gcc.SEGMENT27 || ''\n'' || gcc.SEGMENT28 || ''\n'' || gcc.SEGMENT29 || ''\n'' ||
	gcc.SEGMENT30)' ;
	FLEX_ORDERBY_ALL	varchar2(1000) := '(gcc.SEGMENT1 || ''\n'' || gcc.SEGMENT2 || ''\n'' || gcc.SEGMENT3 || ''\n'' || gcc.SEGMENT4 ||
	''\n'' || gcc.SEGMENT5 || ''\n'' || gcc.SEGMENT6 || ''\n'' || gcc.SEGMENT7 || ''\n'' || gcc.SEGMENT8 || ''\n'' || gcc.SEGMENT9 || ''\n'' ||
	gcc.SEGMENT10 || ''\n'' || gcc.SEGMENT11 || ''\n'' || gcc.SEGMENT12 || ''\n'' || gcc.SEGMENT13 || ''\n'' || gcc.SEGMENT14 || ''\n'' ||
	gcc.SEGMENT15 || ''\n'' || gcc.SEGMENT16 || ''\n'' || gcc.SEGMENT17 || ''\n'' || gcc.SEGMENT18 || ''\n'' || gcc.SEGMENT19 || ''\n'' ||
	gcc.SEGMENT20 || ''\n'' || gcc.SEGMENT21 || ''\n'' || gcc.SEGMENT22 || ''\n'' || gcc.SEGMENT23 || ''\n'' || gcc.SEGMENT24 || ''\n'' ||
	gcc.SEGMENT25 || ''\n'' || gcc.SEGMENT26 || ''\n'' || gcc.SEGMENT27 || ''\n'' || gcc.SEGMENT28 || ''\n'' || gcc.SEGMENT29 || ''\n'' ||
	gcc.SEGMENT30)' ;
	ACCESS_SET_NAME	varchar2(30);
	WHERE_DAS	varchar2(800);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function STRUCT_NUM_p return varchar2;
	Function LEDGER_NAME_p return varchar2;
	Function FLEX_SELECT_ALL_p return varchar2;
	Function FLEX_ORDERBY_ALL_p return varchar2;
	Function ACCESS_SET_NAME_p return varchar2;
	Function WHERE_DAS_p return varchar2;
END GL_GLXRLVAT_XMLP_PKG;



/
