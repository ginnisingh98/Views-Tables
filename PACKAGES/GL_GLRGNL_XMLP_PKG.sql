--------------------------------------------------------
--  DDL for Package GL_GLRGNL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLRGNL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLRGNLS.pls 120.0 2007/12/27 14:38:21 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_PAGE_SIZE	number;
	P_CURRENCY_TYPE	varchar2(15);
	P_ACTUAL_FLAG	varchar2(1);
	P_BUD_ENC_TYPE_ID	number;
	P_START_PERIOD	varchar2(15);
	P_END_PERIOD	varchar2(15);
	P_MIN_FLEX	varchar2(1000);
	P_MAX_FLEX	varchar2(1000);
	P_KIND	varchar2(1);
	P_LEDGER_ID	number;
	P_ACCESS_SET_ID	number;
	P_LEDGER_CURRENCY	varchar2(32767);
	P_ENTERED_CURRENCY	varchar2(40);
	P_CURRENCY_CODE	varchar2(40);
	CP_1	number;
	OLD_CCID	number;
	OLD_END_DR	number;
	OLD_END_CR	number;
	LAST_PERIOD_YEAR	number := 0 ;
	--STRUCT_NUM	varchar2(15) := := '101' ;
	STRUCT_NUM	varchar2(15) := '101' ;

	SELECT_ALL	varchar2(1000) := '(CC.SEGMENT1 || ''\n'' || SEGMENT2 || ''\n'' || SEGMENT3 || ''\n'' || SEGMENT4 || ''\n'' || SEGMENT5 || ''\n'' || SEGMENT6 || ''\n'' || SEGMENT7 || ''\n'' || SEGMENT8 || ''\n'' ||
	SEGMENT9 || ''\n'' || SEGMENT10 || ''\n'' || SEGMENT11 || ''\n'' || SEGMENT12 || ''\n'' || SEGMENT13 || ''\n'' || SEGMENT14 || ''\n'' || SEGMENT15 || ''\n'' || SEGMENT16 || ''\n'' || SEGMENT17 || ''\n'' || SEGMENT18 || ''\n'' || SEGMENT19 ||
	''\n'' || SEGMENT20 || ''\n'' || SEGMENT21 || ''\n'' || SEGMENT22 || ''\n'' || SEGMENT23 || ''\n'' || SEGMENT24 || ''\n'' || SEGMENT25 || ''\n'' || SEGMENT26 || ''\n'' || SEGMENT27 || ''\n'' || SEGMENT28 ||
	''\n'' || SEGMENT29 || ''\n'' || SEGMENT30)' ;
	--WHERE	varchar2(4000) := := 'CC.SEGMENT11 BETWEEN  '00' and '11'' ;
	--l_WHERE	varchar2(4000) := 'CC.SEGMENT11 BETWEEN  '00' and '11'' ;
	l_WHERE	varchar2(4000) := 'CC.SEGMENT11 BETWEEN  ''00'' and ''11''' ;
	--ORDERBY_BAL	varchar2(50) := := 'CC.SEGMENT10' ;
	ORDERBY_BAL	varchar2(50) := 'CC.SEGMENT10' ;
	--ORDERBY_ACCT	varchar2(50) := := 'CC.SEGMENT10' ;
	ORDERBY_ACCT	varchar2(50) := 'CC.SEGMENT10' ;

	ORDERBY_ALL	varchar2(800) := 'CC.SEGMENT1, CC.SEGMENT2, CC.SEGMENT3,
	CC.SEGMENT4, CC.SEGMENT5, CC.SEGMENT6,
	CC.SEGMENT7, CC.SEGMENT8, CC.SEGMENT9, CC.SEGMENT10, CC.SEGMENT11, CC.SEGMENT12, CC.SEGMENT13,
	CC.SEGMENT14, CC.SEGMENT15, CC.SEGMENT16, CC.SEGMENT17, CC.SEGMENT18, CC.SEGMENT19,
	CC.SEGMENT20, CC.SEGMENT21, CC.SEGMENT22, CC.SEGMENT23, CC.SEGMENT24, CC.SEGMENT25, CC.SEGMENT26,
	CC.SEGMENT27, CC.SEGMENT28, CC.SEGMENT29, CC.SEGMENT30' ;

	SELECT_BAL	varchar2(1000) := '(CC.SEGMENT1 || ''\n'' || SEGMENT2 || ''\n'' || SEGMENT3 || ''\n'' || SEGMENT4 || ''\n'' || SEGMENT5 ||
	''\n'' || SEGMENT6 || ''\n'' || SEGMENT7 || ''\n'' || SEGMENT8 || ''\n'' || SEGMENT9 || ''\n'' || SEGMENT10 || ''\n'' || SEGMENT11 || ''\n'' ||
	SEGMENT12 || ''\n'' || SEGMENT13 || ''\n'' || SEGMENT14 || ''\n'' || SEGMENT15 || ''\n'' || SEGMENT16 || ''\n'' || SEGMENT17 || ''\n'' ||
	SEGMENT18 || ''\n'' || SEGMENT19 || ''\n'' || SEGMENT20 || ''\n'' || SEGMENT21 || ''\n'' || SEGMENT22 || ''\n'' || SEGMENT23 || ''\n'' || SEGMENT24 || ''\n'' ||
	SEGMENT25 || ''\n'' || SEGMENT26 || ''\n'' || SEGMENT27 || ''\n'' || SEGMENT28 || ''\n'' || SEGMENT29 || ''\n'' || SEGMENT30)' ;

	EXCLAIMATION_POINT	varchar2(1);
	--STAR	varchar2(1) := := '*' ;
	STAR	varchar2(1) := '*' ;
	--WHERE_ACTUAL_TYPE	varchar2(100) := := 'budget_version_id = 1000' ;
	WHERE_ACTUAL_TYPE	varchar2(100) := 'budget_version_id = 1000' ;
	--WHERE_CURRENCY_CODE	varchar2(100) := := 'jeh.currency_code <> 'STAT'' ;
	--WHERE_CURRENCY_CODE	varchar2(100) := 'jeh.currency_code <> 'STAT'' ;
	WHERE_CURRENCY_CODE	varchar2(100) := 'jeh.currency_code <> ''STAT''' ;
	--SELECT_REFERENCE	varchar2(50) := := 'jeh.external_reference' ;
	SELECT_REFERENCE	varchar2(50) := 'jeh.external_reference' ;
	--WHERE_INDEX	varchar2(100) := := 'cc.segment11 between '0123456789012345' and '0123456789012345'' ;
	WHERE_INDEX	varchar2(100) := 'cc.segment11 between ''0123456789012345'' and ''0123456789012345''' ;
	--SELECT_CR	varchar2(500) := := 'nvl(jel.accounted_cr, 0)' ;
	SELECT_CR	varchar2(500) := 'nvl(jel.accounted_cr, 0)' ;
	--SELECT_DR	varchar2(500) := := 'nvl(jel.accounted_dr, 0)' ;
	SELECT_DR	varchar2(500) := 'nvl(jel.accounted_dr, 0)' ;

	ORDERBY_BAL2	varchar2(600) := 'cc.segment1, cc.segment2, cc.segment3, cc.segment4, cc.segment5, cc.segment6, cc.segment7,
	cc.segment8, cc.segment9, cc.segment10, cc.segment11, cc.segment12, cc.segment13, cc.segment14, cc.segment15, cc.segment16, cc.segment17, cc.segment18, cc.segment19, cc.segment20, cc.segment21, cc.segment22, cc.segment23
	, cc.segment24, cc.segment25, cc.segment26, cc.segment27, cc.segment28, cc.segment29, cc.segment30' ;

	ORDERBY_ACCT2	varchar2(800) := 'cc.segment1, cc.segment2, cc.segment3, cc.segment4, cc.segment5, cc.segment6, cc.segment7, cc.segment8, cc.segment9, cc.segment10, cc.segment11, cc.segment12, cc.segment13, cc.segment14,
	cc.segment15, cc.segment16, cc.segment17, cc.segment18, cc.segment19, cc.segment20, cc.segment21, cc.segment22, cc.segment23, cc.segment24, cc.segment25, cc.segment26, cc.segment27, cc.segment28, cc.segment29, cc.segment30' ;
	WHERE_DAS	varchar2(600);
	ACCESS_SET_NAME	varchar2(30);
	RESULTING_CURRENCY	varchar2(15);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function OLD_CCIDFormula return Number  ;
	function OLD_END_DRFormula return Number  ;
	function OLD_END_CRFormula return Number  ;
	function new_recordformula(ccid in number) return varchar2  ;
	function bad_startformula(new_record in varchar2, period_num in number, period_year in number, begin_dr in number, begin_cr in number, period_dr in number, period_cr in number) return varchar2  ;
	function bad_endformula(period_dr in number, total_dr in number, period_cr in number, total_cr in number, template_id in number) return varchar2  ;
	function BUD_ENC_TYPE_NAMEFormula return VARCHAR2  ;
	function DISP_ACTUAL_FLAGFormula return VARCHAR2  ;
	function START_DATEFormula return Date ;
	function END_DATEFormula return Date ;
	function DISP_CRFormula return VARCHAR2  ;
	function begin_balformula(BEGIN_CR in number, BEGIN_DR in number) return number  ;
	function end_balformula(BEGIN_CR in number, PERIOD_CR in number, BEGIN_DR in number, PERIOD_DR in number) return number  ;
	function accounted_balformula(ACCOUNTED_CR in number, ACCOUNTED_DR in number) return number  ;
	function LAST_PERIOD_YEARFormula return Number  ;
	procedure gl_get_period_dates (tledger_id IN NUMBER,
                                 tperiod_name     IN VARCHAR2,
                                 tstart_date      OUT NOCOPY DATE,
                                 tend_date        OUT NOCOPY DATE,
                                 errbuf           OUT NOCOPY VARCHAR2)
   ;
	procedure gl_get_eff_period_num (tledger_id       IN NUMBER,
                                tperiod_name     IN VARCHAR2,
                                teffnum          OUT NOCOPY NUMBER,
                                errbuf           OUT NOCOPY VARCHAR2)
 ;
	function START_EFF_PERIOD_NUMFormula return Number ;
	function END_EFF_PERIOD_NUMFormula return Number ;
	function g_balancing_segmentgroupfilter(BAL_SECURE in varchar2) return boolean  ;
	function g_accounting_flexfieldgroupfil(FLEX_SECURE in varchar2) return boolean  ;
	function BeforePForm return boolean  ;
	function AfterPForm return boolean  ;
	function BetweenPage return boolean  ;
	Function CP_1_p return number;
	Function OLD_CCID_p return number;
	Function OLD_END_DR_p return number;
	Function OLD_END_CR_p return number;
	Function LAST_PERIOD_YEAR_p return number;
	Function STRUCT_NUM_p return varchar2;
	Function SELECT_ALL_p return varchar2;
	Function WHERE_p return varchar2;
	Function ORDERBY_BAL_p return varchar2;
	Function ORDERBY_ACCT_p return varchar2;
	Function ORDERBY_ALL_p return varchar2;
	Function SELECT_BAL_p return varchar2;
	Function EXCLAIMATION_POINT_p return varchar2;
	Function STAR_p return varchar2;
	Function WHERE_ACTUAL_TYPE_p return varchar2;
	Function WHERE_CURRENCY_CODE_p return varchar2;
	Function SELECT_REFERENCE_p return varchar2;
	Function WHERE_INDEX_p return varchar2;
	Function SELECT_CR_p return varchar2;
	Function SELECT_DR_p return varchar2;
	Function ORDERBY_BAL2_p return varchar2;
	Function ORDERBY_ACCT2_p return varchar2;
	Function WHERE_DAS_p return varchar2;
	Function ACCESS_SET_NAME_p return varchar2;
	Function RESULTING_CURRENCY_p return varchar2;
END GL_GLRGNL_XMLP_PKG;



/
