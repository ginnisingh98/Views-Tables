--------------------------------------------------------
--  DDL for Package GL_GLXRLFBL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXRLFBL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXRLFBLS.pls 120.0 2007/12/27 15:13:44 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_LEDGER_ID	number;
	P_ACCESS_SET_ID	number;
	STRUCT_NUM	varchar2(15);
	LEDGER_NAME	varchar2(30);
	FLEX_SELECT_ALL_LOW	varchar2(1000) := '(gbfr.SEGMENT1_LOW || ''\n'' || gbfr.SEGMENT2_LOW || ''\n'' || gbfr.SEGMENT3_LOW || ''\n'' || gbfr.SEGMENT4_LOW || ''\n'' || gbfr.SEGMENT5_LOW || ''\n'' || gbfr.SEGMENT6_LOW || ''\n'' ||
	gbfr.SEGMENT7_LOW || ''\n'' || gbfr.SEGMENT8_LOW || ''\n'' || gbfr.SEGMENT9_LOW || ''\n'' || gbfr.SEGMENT10_LOW || ''\n'' || gbfr.SEGMENT11_LOW || ''\n'' || gbfr.SEGMENT12_LOW || ''\n'' || gbfr.SEGMENT13_LOW || ''\n'' || gbfr.SEGMENT14_LOW ||
	''\n'' || gbfr.SEGMENT15_LOW || ''\n'' || gbfr.SEGMENT16_LOW || ''\n'' || gbfr.SEGMENT17_LOW || ''\n'' || gbfr.SEGMENT18_LOW || ''\n'' || gbfr.SEGMENT19_LOW || ''\n'' || gbfr.SEGMENT20_LOW || ''\n'' || gbfr.SEGMENT21_LOW || ''\n'' ||
	gbfr.SEGMENT22_LOW || ''\n'' || gbfr.SEGMENT23_LOW || ''\n'' || gbfr.SEGMENT24_LOW || ''\n'' || gbfr.SEGMENT25_LOW || ''\n'' || gbfr.SEGMENT26_LOW || ''\n'' || gbfr.SEGMENT27_LOW || ''\n'' || gbfr.SEGMENT28_LOW || ''\n'' ||
	gbfr.SEGMENT29_LOW || ''\n'' || gbfr.SEGMENT30_LOW)' ;

	FLEX_SELECT_ALL_HIGH	varchar2(1000) := '(gbfr.SEGMENT1_HIGH || ''\n'' || gbfr.SEGMENT2_HIGH || ''\n'' || gbfr.SEGMENT3_HIGH || ''\n'' || gbfr.SEGMENT4_HIGH || ''\n'' || gbfr.SEGMENT5_HIGH || ''\n'' || gbfr.SEGMENT6_HIGH ||
	''\n'' || gbfr.SEGMENT7_HIGH || ''\n'' || gbfr.SEGMENT8_HIGH || ''\n'' || gbfr.SEGMENT9_HIGH || ''\n'' || gbfr.SEGMENT10_HIGH || ''\n'' || gbfr.SEGMENT11_HIGH || ''\n'' || gbfr.SEGMENT12_HIGH || ''\n'' || gbfr.SEGMENT13_HIGH
	|| ''\n'' || gbfr.SEGMENT14_HIGH || ''\n'' || gbfr.SEGMENT15_HIGH || ''\n'' || gbfr.SEGMENT16_HIGH || ''\n'' || gbfr.SEGMENT17_HIGH || ''\n'' || gbfr.SEGMENT18_HIGH || ''\n'' || gbfr.SEGMENT19_HIGH || ''\n'' ||
	gbfr.SEGMENT20_HIGH || ''\n'' || gbfr.SEGMENT21_HIGH || ''\n'' || gbfr.SEGMENT22_HIGH || ''\n'' || gbfr.SEGMENT23_HIGH || ''\n'' || gbfr.SEGMENT24_HIGH || ''\n'' || gbfr.SEGMENT25_HIGH || ''\n'' ||
	gbfr.SEGMENT26_HIGH || ''\n'' || gbfr.SEGMENT27_HIGH || ''\n'' || gbfr.SEGMENT28_HIGH || ''\n'' || gbfr.SEGMENT29_HIGH || ''\n'' || gbfr.SEGMENT30_HIGH)' ;

	ACCESS_SET_NAME	varchar2(30);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function flex_field_all_lowformula(FLEX_FIELD_ALL_LOW in varchar2) return varchar2  ;
	function flex_field_all_highformula(FLEX_FIELD_ALL_HIGH in varchar2) return varchar2  ;
	Function STRUCT_NUM_p return varchar2;
	Function LEDGER_NAME_p return varchar2;
	Function FLEX_SELECT_ALL_LOW_p return varchar2;
	Function FLEX_SELECT_ALL_HIGH_p return varchar2;
	Function ACCESS_SET_NAME_p return varchar2;
END GL_GLXRLFBL_XMLP_PKG;



/
