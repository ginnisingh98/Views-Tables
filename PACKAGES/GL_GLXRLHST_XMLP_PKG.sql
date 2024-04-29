--------------------------------------------------------
--  DDL for Package GL_GLXRLHST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXRLHST_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXRLHSTS.pls 120.0 2007/12/27 15:14:35 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_LEDGER_ID	number;
	P_MIN_PRECISION	number;
	P_FROM_PERIOD	varchar2(15);
	P_TO_PERIOD	varchar2(15);
	P_ACCESS_SET_ID	number;
	STRUCT_NUM	varchar2(15);
	LEDGER_NAME	varchar2(30);

	FLEX_SELECT_ALL	varchar2(1000) := '(gcc.SEGMENT1 || ''\n'' || SEGMENT2 || ''\n'' || SEGMENT3 || ''\n'' || SEGMENT4 || ''\n'' || SEGMENT5 || ''\n'' || SEGMENT6 || ''\n'' || SEGMENT7 || ''\n'' || SEGMENT8 || ''\n'' || SEGMENT9 || ''\n'' || SEGMENT10
	|| ''\n'' || SEGMENT11 || ''\n'' || SEGMENT12 || ''\n'' || SEGMENT13 || ''\n'' || SEGMENT14 || ''\n'' || SEGMENT15 || ''\n'' || SEGMENT16 || ''\n'' || SEGMENT17 || ''\n'' || SEGMENT18 || ''\n'' || SEGMENT19 || ''\n'' || SEGMENT20 || ''\n'' ||
	SEGMENT21 || ''\n'' || SEGMENT22 || ''\n'' || SEGMENT23 || ''\n'' || SEGMENT24 || ''\n'' || SEGMENT25 || ''\n'' || SEGMENT26 || ''\n'' || SEGMENT27 || ''\n'' || SEGMENT28 || ''\n'' || SEGMENT29 || ''\n'' || SEGMENT30)';

	FLEX_ORDERBY_ALL	varchar2(1000) := '(gcc.SEGMENT1 || ''\n'' || SEGMENT2 || ''\n'' || SEGMENT3 || ''\n'' || SEGMENT4 || ''\n'' || SEGMENT5 || ''\n'' || SEGMENT6 || ''\n'' || SEGMENT7 || ''\n'' || SEGMENT8 || ''\n'' || SEGMENT9 || ''\n''
	|| SEGMENT10 || ''\n'' || SEGMENT11 || ''\n'' || SEGMENT12 || ''\n'' || SEGMENT13 || ''\n'' || SEGMENT14 || ''\n'' || SEGMENT15 || ''\n'' || SEGMENT16 || ''\n'' || SEGMENT17 || ''\n'' || SEGMENT18 || ''\n'' || SEGMENT19 || ''\n'' || SEGMENT20
	|| ''\n'' || SEGMENT21 || ''\n'' || SEGMENT22 || ''\n'' || SEGMENT23 || ''\n'' || SEGMENT24 || ''\n'' || SEGMENT25 || ''\n'' || SEGMENT26 || ''\n'' || SEGMENT27 || ''\n'' || SEGMENT28 || ''\n'' || SEGMENT29 || ''\n'' || SEGMENT30)';

	--FLEX_SELECT_BAL	varchar2(600) := := '(gcc.SEGMENT11 ||'\n' || SEGMENT12)' ;
	FLEX_SELECT_BAL	varchar2(600) := '(gcc.SEGMENT11 ||''\n'' || SEGMENT12)' ;
	FLEX_ORDERBY_BAL_D	varchar2(600) := 'gcc.SEGMENT10' ;
	--FLEX_SELECT_ACCT	varchar2(600) := := '(gcc.SEGMENT11 ||'\n' || SEGMENT12)' ;
	FLEX_SELECT_ACCT	varchar2(600) := '(gcc.SEGMENT11 ||''\n'' || SEGMENT12)' ;
	FLEX_ORDERBY_ACCT_D	varchar2(600) := 'gcc.SEGMENT10' ;
	FLEX_ORDERBY_BAL_I	varchar2(600) := 'gcc.SEGMENT10' ;
	FLEX_ORDERBY_ACCT_I	varchar2(600) := 'gcc.SEGMENT10' ;
	AVERAGE_BALANCES_FLAG	varchar2(30);
	WHERE_DAS	varchar2(800);
	FROM_EFF_PERIOD_NUM	number;
	TO_EFF_PERIOD_NUM	number;
	FUNCTIONAL_CURRENCY	varchar2(15);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function STRUCT_NUM_p return varchar2;
	Function LEDGER_NAME_p return varchar2;
	Function FLEX_SELECT_ALL_p return varchar2;
	Function FLEX_ORDERBY_ALL_p return varchar2;
	Function FLEX_SELECT_BAL_p return varchar2;
	Function FLEX_ORDERBY_BAL_D_p return varchar2;
	Function FLEX_SELECT_ACCT_p return varchar2;
	Function FLEX_ORDERBY_ACCT_D_p return varchar2;
	Function FLEX_ORDERBY_BAL_I_p return varchar2;
	Function FLEX_ORDERBY_ACCT_I_p return varchar2;
	Function AVERAGE_BALANCES_FLAG_p return varchar2;
	Function WHERE_DAS_p return varchar2;
	Function FROM_EFF_PERIOD_NUM_p return number;
	Function TO_EFF_PERIOD_NUM_p return number;
	Function FUNCTIONAL_CURRENCY_p return varchar2;
END GL_GLXRLHST_XMLP_PKG;



/
