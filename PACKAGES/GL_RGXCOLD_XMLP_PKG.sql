--------------------------------------------------------
--  DDL for Package GL_RGXCOLD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_RGXCOLD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RGXCOLDS.pls 120.0 2007/12/27 15:29:25 vijranga noship $ */
	P_ACCESS_SET_ID	number;
	P_COLUMN_SET_ID	number;
	P_FLEXDATA_LOW	varchar2(2500):='SEGMENT_ATTRIBUTE1_LOW||''\n''||SEGMENT_ATTRIBUTE2_LOW||''\n''||SEGMENT_ATTRIBUTE3_LOW||''\n''||SEGMENT1_LOW||''\n''||SEGMENT2_LOW||''\n''||SEGMENT3_LOW||''\n''||SEGMENT4_LOW||''\n''|| SEGMENT5_LOW||''\n''||
		SEGMENT6_LOW||''\n''||SEGMENT7_LOW||''\n''||SEGMENT8_LOW||''\n''|| SEGMENT9_LOW||''\n''||SEGMENT10_LOW||''\n''||SEGMENT11_LOW||''\n''||SEGMENT12_LOW||''\n''|| SEGMENT13_LOW||''\n''||SEGMENT14_LOW||''\n''||SEGMENT15_LOW||''\n''||
		SEGMENT16_LOW||''\n''|| SEGMENT17_LOW||''\n''||SEGMENT18_LOW||''\n''||SEGMENT19_LOW||''\n''||SEGMENT20_LOW||''\n''|| SEGMENT21_LOW||''\n''||SEGMENT22_LOW||''\n''||SEGMENT23_LOW||''\n''||SEGMENT24_LOW||''\n''|| SEGMENT25_LOW||''\n''||
		SEGMENT26_LOW||''\n''||SEGMENT27_LOW||''\n''||SEGMENT28_LOW||''\n''||SEGMENT29_LOW||''\n''||SEGMENT30_LOW';
	P_FLEXDATA_HIGH	varchar2(2500):='SEGMENT_ATTRIBUTE1_HIGH||''\n''||SEGMENT_ATTRIBUTE2_HIGH||''\n''||SEGMENT_ATTRIBUTE3_HIGH||''\n''||SEGMENT1_HIGH||''\n''||SEGMENT2_HIGH||''\n''||SEGMENT3_HIGH||''\n''||SEGMENT4_HIGH||''\n''||SEGMENT5_HIGH||''
		\n''||SEGMENT6_HIGH||''\n''||SEGMENT7_HIGH||''\n''||SEGMENT8_HIGH||''\n''||SEGMENT9_HIGH||''\n''||SEGMENT10_HIGH||''\n''||SEGMENT11_HIGH||''\n''||SEGMENT12_HIGH||''\n''||SEGMENT13_HIGH||''\n''||SEGMENT14_HIGH||''\n''||SEGMENT15_HIGH||
		''\n''||SEGMENT16_HIGH||''\n''||SEGMENT17_HIGH||''\n''||SEGMENT18_HIGH||''\n''||SEGMENT19_HIGH||''\n''||SEGMENT20_HIGH||''\n''||SEGMENT21_HIGH||''\n''||SEGMENT22_HIGH||''\n''||SEGMENT23_HIGH||''\n''||SEGMENT24_HIGH||''\n''||
		SEGMENT25_HIGH||''\n''||SEGMENT26_HIGH||''\n''||SEGMENT27_HIGH||''\n''||SEGMENT28_HIGH||''\n''||SEGMENT29_HIGH||''\n''||SEGMENT30_HIGH';
	P_FLEX_LPROMPT	varchar2(2500);
	P_CONC_REQUEST_ID	number;
	P_FLEXDATA_TYPE	varchar2(2500):='SEGMENT1_LOW||''\n''||SEGMENT2_LOW||''\n''||SEGMENT1_TYPE||''\n''||SEGMENT2_TYPE||''\n''||SEGMENT3_TYPE||''\n''||SEGMENT4_TYPE||''\n''||SEGMENT5_TYPE||''\n''||SEGMENT6_TYPE||''\n''||SEGMENT7_TYPE||''\n''||
		SEGMENT8_TYPE||''\n''||SEGMENT9_TYPE||''\n''||SEGMENT10_TYPE||''\n''||SEGMENT11_TYPE||''\n''||SEGMENT12_TYPE||''\n''||SEGMENT13_TYPE||''\n''||SEGMENT14_TYPE||''\n''||SEGMENT15_TYPE||''\n''||SEGMENT16_TYPE||''\n''||SEGMENT17_TYPE||
		''\n''||SEGMENT18_TYPE||''\n''||SEGMENT19_TYPE||''\n''||SEGMENT20_TYPE||''\n''||SEGMENT21_TYPE||''\n''||SEGMENT22_TYPE||''\n''||SEGMENT23_TYPE||''\n''||SEGMENT24_TYPE||''\n''||SEGMENT25_TYPE||''\n''||SEGMENT26_TYPE||''\n''
		||SEGMENT27_TYPE||''\n''||SEGMENT28_TYPE||''\n''||SEGMENT29_TYPE||''\n''||SEGMENT30_TYPE';
	P_FLEXDATA_LOW2	varchar2(980);
	P_FLEXDATA_LOW3	varchar2(980);
	P_FLEXDATA_HIGH2	varchar2(980);
	P_FLEXDATA_HIGH3	varchar2(980);
	P_FLEXDATA_TYPE2	varchar2(980);
	P_FLEXDATA_TYPE3	varchar2(980);
	P_FLEX_LPROMPT2	varchar2(988);
	P_FLEX_LPROMPT3	varchar2(988);
	C_STRUCT_NUM	number;
	C_ID_FLEX_CODE	varchar2(4) := 'GLLE' ;
	C_INDUSTRY_TYPE	varchar2(1) := 'C' ;
	C_ATTRIBUTE_FLAG	varchar2(1) := 'N' ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function c_flex_lowformula(C_FLEX_LOW in varchar2) return varchar2  ;
	function c_flex_highformula(C_FLEX_HIGH in varchar2) return varchar2  ;
	function c_flex_typeformula(C_FLEX_TYPE in varchar2) return varchar2  ;
	function display_format_dspformula(display_format in varchar2, display_precision in number, format_mask_width in number, format_before_text in varchar2, format_after_text in varchar2) return char  ;
	Function C_STRUCT_NUM_p return number;
	Function C_ID_FLEX_CODE_p return varchar2;
	Function C_INDUSTRY_TYPE_p return varchar2;
	Function C_ATTRIBUTE_FLAG_p return varchar2;
END GL_RGXCOLD_XMLP_PKG;


/
