--------------------------------------------------------
--  DDL for Package GL_GLXRLRFL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXRLRFL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXRLRFLS.pls 120.0 2007/12/27 15:17:25 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_STRUCT_NUM	number;
	P_RECURRING_BATCH_ID	number;
	P_PERIOD_SET	varchar2(15);
	P_PERIOD_TYPE	varchar2(15);
	FLEX_1_SELECT_ALL	varchar2(1000) := '(gcc1.SEGMENT1 || ''\n'' || SEGMENT2 || ''\n'' || SEGMENT3 || ''\n'' || SEGMENT4 || ''\n'' || SEGMENT5 || ''\n'' || SEGMENT6 || ''\n'' || SEGMENT7 || ''\n'' || SEGMENT8 || ''\n'' || SEGMENT9 || ''\n'' ||
	SEGMENT10 || ''\n'' || SEGMENT11 || ''\n'' || SEGMENT12 || ''\n'' || SEGMENT13 || ''\n'' || SEGMENT14 || ''\n'' || SEGMENT15 || ''\n'' || SEGMENT16 || ''\n'' || SEGMENT17 || ''\n'' || SEGMENT18 || ''\n'' || SEGMENT19 || ''\n'' || SEGMENT20
	|| ''\n'' || SEGMENT21 || ''\n'' || SEGMENT22 || ''\n'' || SEGMENT23 || ''\n'' || SEGMENT24 || ''\n'' || SEGMENT25 || ''\n'' || SEGMENT26 || ''\n'' || SEGMENT27 || ''\n'' || SEGMENT28 || ''\n'' || SEGMENT29 || ''\n'' || SEGMENT30)';

	FLEX_2_SELECT_ALL	varchar2(1000) := '(SEGMENT1 || ''\n'' || SEGMENT2 || ''\n'' || SEGMENT3 || ''\n'' || SEGMENT4 || ''\n'' || SEGMENT5 || ''\n'' || SEGMENT6 || ''\n'' || SEGMENT7 || ''\n'' || SEGMENT8 || ''\n'' || SEGMENT9
	|| ''\n'' || SEGMENT10 || ''\n'' || SEGMENT11 || ''\n'' || SEGMENT12 || ''\n'' || SEGMENT13 || ''\n'' || SEGMENT14 || ''\n'' || SEGMENT15 || ''\n'' || SEGMENT16 || ''\n'' || SEGMENT17 || ''\n'' || SEGMENT18 || ''\n'' || SEGMENT19 || ''\n'' ||
	SEGMENT20 || ''\n'' || SEGMENT21 || ''\n'' || SEGMENT22 || ''\n'' || SEGMENT23 || ''\n'' || SEGMENT24 || ''\n'' || SEGMENT25 || ''\n'' || SEGMENT26 || ''\n'' || SEGMENT27 || ''\n'' || SEGMENT28 || ''\n'' || SEGMENT29 || ''\n'' || SEGMENT30)';

	FLEX_2_SELECT_ALL_GLLE	varchar2(1000) := '(SEGMENT1 || ''\n'' || SEGMENT2 || ''\n'' || SEGMENT3 || ''\n'' || SEGMENT4 || ''\n'' || SEGMENT5 || ''\n'' || SEGMENT6 || ''\n'' || SEGMENT7 || ''\n'' || SEGMENT8 || ''\n'' || SEGMENT9 || ''\n'' ||
	SEGMENT10 || ''\n'' || SEGMENT11 || ''\n'' || SEGMENT12 || ''\n'' || SEGMENT13 || ''\n'' || SEGMENT14 || ''\n'' || SEGMENT15 || ''\n'' || SEGMENT16 || ''\n'' || SEGMENT17 || ''\n'' || SEGMENT18 || ''\n'' || SEGMENT19 || ''\n'' || SEGMENT20
	|| ''\n'' || SEGMENT21 || ''\n'' || SEGMENT22 || ''\n'' || SEGMENT23 || ''\n'' || SEGMENT24 || ''\n'' || SEGMENT25 || ''\n'' || SEGMENT26 || ''\n'' || SEGMENT27 || ''\n'' || SEGMENT28 || ''\n'' || SEGMENT29 || ''\n'' || SEGMENT30)';

	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function FLEX_1_SELECT_ALL_p return varchar2;
	Function FLEX_2_SELECT_ALL_p return varchar2;
	Function FLEX_2_SELECT_ALL_GLLE_p return varchar2;
END GL_GLXRLRFL_XMLP_PKG;



/
