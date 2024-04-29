--------------------------------------------------------
--  DDL for Package GL_GLXCOCRR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXCOCRR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXCOCRRS.pls 120.0 2007/12/27 14:52:08 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_COA_MAPPING_ID	number;
	TO_CHART_OF_ACCOUNTS_ID	varchar2(15) := '50105' ;
	SELECT_FROM_FLEX_LOW	varchar2(1000) := '(cfm.segment1_low||''\n''||cfm.segment2_low||''\n''||cfm.segment3_low||''\n''||cfm.segment4_low||''\n''||cfm.segment5_low||''\n''||cfm.segment6_low||''\n''||cfm.segment7_low||''\n''||cfm.segment8_low||
		''\n''||cfm.segment9_low||''\n''||cfm.segment10_low||''\n''||cfm.segment11_low||''\n''||cfm.segment12_low||''\n''||cfm.segment13_low||''\n''||cfm.segment14_low||''\n''||cfm.segment15_low||''\n''||cfm.segment16_low||''\n''||
		cfm.segment17_low||''\n''||cfm.segment18_low||''\n''||cfm.segment19_low||''\n''||cfm.segment20_low||''\n''||cfm.segment21_low||''\n''||cfm.segment22_low||''\n''||cfm.segment23_low||''\n''||cfm.segment24_low||''\n''||cfm.segment25_low||
		''\n''||cfm.segment26_low||''\n''||cfm.segment27_low||''\n''||cfm.segment28_low||''\n''||cfm.segment29_low||''\n''||cfm.segment30_low)' ;
	ORDERBY_FROM_FLEX_LOW	varchar2(1000) := '(cfm.segment1_low||''\n''||cfm.segment2_low||''\n''||cfm.segment3_low||''\n''||cfm.segment4_low||''\n''||cfm.segment5_low||''\n''||cfm.segment6_low||''\n''||cfm.segment7_low||''\n''||cfm.segment8_low||
		''\n''||cfm.segment9_low||''\n''||cfm.segment10_low||''\n''||cfm.segment11_low||''\n''||cfm.segment12_low||''\n''||cfm.segment13_low||''\n''||cfm.segment14_low||''\n''||cfm.segment15_low||''\n''||cfm.segment16_low||''\n''||
		cfm.segment17_low||''\n''||cfm.segment18_low||''\n''||cfm.segment19_low||''\n''||cfm.segment20_low||''\n''||cfm.segment21_low||''\n''||cfm.segment22_low||''\n''||cfm.segment23_low||''\n''||cfm.segment24_low||''\n''||cfm.segment25_low||
		''\n''||cfm.segment26_low||''\n''||cfm.segment27_low||''\n''||cfm.segment28_low||''\n''||cfm.segment29_low||''\n''||cfm.segment30_low)' ;
	SELECT_TO_FLEX	varchar2(1000) := '(CC.SEGMENT1 || ''\n'' || CC.SEGMENT2 || ''\n'' || CC.SEGMENT3 || ''\n'' || CC.SEGMENT4 || ''\n'' || CC.SEGMENT5 || ''\n'' || CC.SEGMENT6 || ''\n'' || CC.SEGMENT7 || ''\n'' || CC.SEGMENT8 || ''\n'' ||
		CC.SEGMENT9 || ''\n'' || CC.SEGMENT10 || ''\n'' || CC.SEGMENT11 || ''\n'' || CC.SEGMENT12 || ''\n'' || CC.SEGMENT13 || ''\n'' || CC.SEGMENT14 || ''\n'' || CC.SEGMENT15 || ''\n'' || CC.SEGMENT16 || ''\n'' || CC.SEGMENT17 || ''\n'' ||
		CC.SEGMENT18 || ''\n'' || CC.SEGMENT19 || ''\n'' || CC.SEGMENT20 || ''\n'' || CC.SEGMENT21 || ''\n'' || CC.SEGMENT22 || ''\n'' || CC.SEGMENT23 || ''\n'' || CC.SEGMENT24 || ''\n'' || CC.SEGMENT25 || ''\n'' || CC.SEGMENT26 || ''\n'' ||
		CC.SEGMENT27 || ''\n'' || CC.SEGMENT28 || ''\n'' || CC.SEGMENT29 || ''\n'' || CC.SEGMENT30)';
	ORDERBY_TO_FLEX	varchar2(1000) := 'cc.segment1, cc.segment2, cc.segment3, cc.segment4, cc.segment5, cc.segment6, cc.segment7, cc.segment8, cc.segment9, cc.segment10, cc.segment11, cc.segment12, cc.segment13, cc.segment14, cc.segment15,
		cc.segment16, cc.segment17, cc.segment18, cc.segment19, cc.segment20, cc.segment21, cc.segment22, cc.segment23, cc.segment24, cc.segment25, cc.segment26, cc.segment27, cc.segment28, cc.segment29, cc.segment30' ;
	FROM_CHART_OF_ACCOUNTS_ID	varchar2(25);
	COA_MAP_NAME	varchar2(33);
	COA_MAP_DESCRIPTION	varchar2(240);
	START_DATE	date;
	END_DATE	date;
	SELECT_FROM_FLEX_HIGH	varchar2(1000) := '(cfm.segment1_high||''\n''||cfm.segment2_high||''\n''||cfm.segment3_high||''\n''||cfm.segment4_high||''\n''||cfm.segment5_high||''\n''||cfm.segment6_high||''\n''||cfm.segment7_high||''\n''||
		cfm.segment8_high||''\n''||cfm.segment9_high||''\n''||cfm.segment10_high||''\n''||cfm.segment11_high||''\n''||cfm.segment12_high||''\n''||cfm.segment13_high||''\n''||cfm.segment14_high||''\n''||cfm.segment15_high||''\n''||
		cfm.segment16_high||''\n''||cfm.segment17_high||''\n''||cfm.segment18_high||''\n''||cfm.segment19_high||''\n''||cfm.segment20_high||''\n''||cfm.segment21_high||''\n''||cfm.segment22_high||''\n''||cfm.segment23_high||''\n''||
		cfm.segment24_high||''\n''||cfm.segment25_high||''\n''||cfm.segment26_high||''\n''||cfm.segment27_high||''\n''||cfm.segment28_high||''\n''||cfm.segment29_high||''\n''||cfm.segment30_high)' ;
	ORDERBY_FROM_FLEX_HIGH	varchar2(1000) := '(cfm.segment1_high||''\n''||cfm.segment2_high||''\n''||cfm.segment3_high||''\n''||cfm.segment4_high||''\n''||cfm.segment5_high||''\n''||cfm.segment6_high||''\n''||cfm.segment7_high||''\n''||
		cfm.segment8_high||''\n''||cfm.segment9_high||''\n''||cfm.segment10_high||''\n''||cfm.segment11_high||''\n''||cfm.segment12_high||''\n''||cfm.segment13_high||''\n''||cfm.segment14_high||''\n''||cfm.segment15_high||''\n''||
		cfm.segment16_high||''\n''||cfm.segment17_high||''\n''||cfm.segment18_high||''\n''||cfm.segment19_high||''\n''||cfm.segment20_high||''\n''||cfm.segment21_high||''\n''||cfm.segment22_high||''\n''||cfm.segment23_high||''\n''||
		cfm.segment24_high||''\n''||cfm.segment25_high||''\n''||cfm.segment26_high||''\n''||cfm.segment27_high||''\n''||cfm.segment28_high||''\n''||cfm.segment29_high||''\n''||cfm.segment30_high)';
	ADB_USED	varchar2(1);
	TO_COA_NAME	varchar2(30);
	FROM_COA_NAME	varchar2(30);
	function from_flexfield_lowformula(FROM_FLEXFIELD_LOW in varchar2) return varchar2  ;
	function AfterReport return boolean  ;
	function from_flexfield_highformula(FROM_FLEXFIELD_HIGH in varchar2) return varchar2  ;
	function BeforeReport return boolean ;
	procedure gl_get_mapping_info(
                           map_id NUMBER, map_name OUT NOCOPY VARCHAR2,
                           from_coa_id OUT NOCOPY NUMBER, to_coa_id OUT NOCOPY NUMBER,
                           description OUT NOCOPY VARCHAR2,start_date_active OUT NOCOPY DATE,
			   end_date_active OUT NOCOPY DATE,
			   errbuf OUT NOCOPY VARCHAR2)  ;
	FUNCTION B_COA_NAME(x_segment NUMBER) RETURN VARCHAR  ;
	Function TO_CHART_OF_ACCOUNTS_ID_p return varchar2;
	Function SELECT_FROM_FLEX_LOW_p return varchar2;
	Function ORDERBY_FROM_FLEX_LOW_p return varchar2;
	Function SELECT_TO_FLEX_p return varchar2;
	Function ORDERBY_TO_FLEX_p return varchar2;
	Function FROM_CHART_OF_ACCOUNTS_ID_p return varchar2;
	Function COA_MAP_NAME_p return varchar2;
	Function COA_MAP_DESCRIPTION_p return varchar2;
	Function START_DATE_p return date;
	Function END_DATE_p return date;
	Function SELECT_FROM_FLEX_HIGH_p return varchar2;
	Function ORDERBY_FROM_FLEX_HIGH_p return varchar2;
	Function ADB_USED_p return varchar2;
	Function TO_COA_NAME_p return varchar2;
	Function FROM_COA_NAME_p return varchar2;
END GL_GLXCOCRR_XMLP_PKG;



/
