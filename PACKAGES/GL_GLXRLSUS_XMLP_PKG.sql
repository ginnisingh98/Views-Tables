--------------------------------------------------------
--  DDL for Package GL_GLXRLSUS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXRLSUS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXRLSUSS.pls 120.1 2008/01/07 20:09:32 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_LEDGER_ID	number;
	STRUCT_NUM	varchar2(15);
	LEDGER_NAME	varchar2(30);
/*	--FLEX_SELECT_ALL	varchar2(1000) := := '(SEGMENT1 || '\n' || SEGMENT2 || '\n' || SEGMENT3 || '\n' || SEGMENT4 || '\n' || SEGMENT5 || '\n'
	|| SEGMENT6 || '\n' || SEGMENT7 || '\n' || SEGMENT8 || '\n' || SEGMENT9 || '\n' || SEGMENT10 || '\n' || SEGMENT11 || '\n' || SEGMENT12 || '\n'
	|| SEGMENT13 || '\n' || SEGMENT14 || '\n' || SEGMENT15 || '\n' || SEGMENT16 || '\n' || SEGMENT17 || '\n' || SEGMENT18 || '\n' || SEGMENT19 ||
	'\n' || SEGMENT20 || '\n' || SEGMENT21 || '\n' || SEGMENT22 || '\n' || SEGMENT23 || '\n' || SEGMENT24 || '\n' || SEGMENT25 || '\n' || SEGMENT26
	|| '\n' || SEGMENT27 || '\n' || SEGMENT28 || '\n' || SEGMENT29 || '\n' || SEGMENT30)' ;
*/
	FLEX_SELECT_ALL	varchar2(1000) := '(SEGMENT1 || ''\n'' || SEGMENT2 || ''\n'' || SEGMENT3 || ''\n'' || SEGMENT4 || ''\n'' || SEGMENT5 || ''\n''
	|| SEGMENT6 || ''\n'' || SEGMENT7 || ''\n'' || SEGMENT8 || ''\n'' || SEGMENT9 || ''\n'' || SEGMENT10 || ''\n'' || SEGMENT11 || ''\n'' ||
	SEGMENT12 || ''\n'' || SEGMENT13 || ''\n'' || SEGMENT14 || ''\n'' || SEGMENT15 || ''\n'' || SEGMENT16 || ''\n'' || SEGMENT17 || ''\n'' ||
	SEGMENT18 || ''\n'' || SEGMENT19 || ''\n'' || SEGMENT20 || ''\n'' || SEGMENT21 || ''\n'' || SEGMENT22 || ''\n'' || SEGMENT23 || ''\n'' ||
	SEGMENT24 || ''\n'' || SEGMENT25 || ''\n'' || SEGMENT26 || ''\n'' || SEGMENT27 || ''\n'' || SEGMENT28 || ''\n'' || SEGMENT29 || ''\n'' ||
	SEGMENT30)';
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function STRUCT_NUM_p return varchar2;
	Function LEDGER_NAME_p return varchar2;
	Function FLEX_SELECT_ALL_p return varchar2;
END GL_GLXRLSUS_XMLP_PKG;

/
