--------------------------------------------------------
--  DDL for Package GL_GLXACDAL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXACDAL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXACDALS.pls 120.0 2007/12/27 14:42:44 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_STRUCT_NUM	varchar2(15);
	P_DATE	date;
	P_FLEX_LOW	varchar2(1000);
	P_FLEX_HIGH	varchar2(1000);
    FLEX_SELECT_ALL	varchar2(1000) := '(SEGMENT1 || ''\n'' || SEGMENT2 || ''\n'' || SEGMENT3 || ''\n'' ||
    SEGMENT4 || ''\n'' || SEGMENT5 || ''\n'' || SEGMENT6 || ''\n'' || SEGMENT7 || ''\n'' || SEGMENT8 || ''\n'' ||
    SEGMENT9 || ''\n'' || SEGMENT10 || ''\n'' || SEGMENT11 || ''\n'' || SEGMENT12 || ''\n'' || SEGMENT13 ||
    ''\n'' || SEGMENT14 || ''\n'' || SEGMENT15 || ''\n'' || SEGMENT16 || ''\n'' || SEGMENT17 || ''\n'' ||
    SEGMENT18 || ''\n'' || SEGMENT19 || ''\n'' || SEGMENT20 || ''\n'' || SEGMENT21 || ''\n'' || SEGMENT22 || ''\n'' ||
    SEGMENT23 || ''\n'' || SEGMENT24 || ''\n'' || SEGMENT25 || ''\n'' || SEGMENT26 || ''\n'' || SEGMENT27 ||
    ''\n'' || SEGMENT28 || ''\n'' || SEGMENT29 || ''\n'' || SEGMENT30)' ;
	FLEX_WHERE_ALL	varchar2(4000) := 'SEGMENT1 between ''00'' and ''11''' ;
	FLEX_ORDERBY_ALL	varchar2(1000) := 'SEGMENT1,  SEGMENT2, SEGMENT3,  SEGMENT4, SEGMENT5, SEGMENT6,
	SEGMENT7, SEGMENT8, SEGMENT9, SEGMENT10, SEGMENT11, SEGMENT12, SEGMENT13, SEGMENT14, SEGMENT15, SEGMENT16,
	SEGMENT17, SEGMENT18, SEGMENT19, SEGMENT20, SEGMENT21, SEGMENT22, SEGMENT23, SEGMENT24, SEGMENT25,
	SEGMENT26, SEGMENT27, SEGMENT28, SEGMENT29, SEGMENT30' ;
	FLEX_NODATA_SELECT_BAL	varchar2(600) := '(SEGMENT10 || ''\n'' || SEGMENT11)' ;
	COA_NAME	varchar2(30);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function FLEX_SELECT_ALL_p return varchar2;
	Function FLEX_WHERE_ALL_p return varchar2;
	Function FLEX_ORDERBY_ALL_p return varchar2;
	Function FLEX_NODATA_SELECT_BAL_p return varchar2;
	Function COA_NAME_p return varchar2;
END GL_GLXACDAL_XMLP_PKG;



/
