--------------------------------------------------------
--  DDL for Package GL_GLXRBCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXRBCR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXRBCRS.pls 120.0 2007/12/27 15:02:05 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_LEDGER_ID	number;
	P_BUDGET_VERSION_ID	number;
	P_PERIOD_TYPE	varchar2(30);
	P_CURRENCY_CODE	varchar2(15);
	P_PERIOD_NAME	varchar2(15);
	P_ACCESS_SET_ID	number;
	CHART_OF_ACCOUNTS_ID	varchar2(15) := '50105' ;
	ORDERBY_FLEX	varchar2(1000) := 'cc.segment1, cc.segment2, cc.segment3, cc.segment4, cc.segment5, cc.segment6, cc.segment7, cc.segment8, cc.segment9, cc.segment10, cc.segment11, cc.segment12, cc.segment13, cc.segment14, cc.segment15,
		cc.segment16, cc.segment17, cc.segment18, cc.segment19, cc.segment20, cc.segment21, cc.segment22, cc.segment23, cc.segment24, cc.segment25, cc.segment26, cc.segment27, cc.segment28, cc.segment29, cc.segment30' ;

	SELECT_FLEX	varchar2(1000) := '(CC.SEGMENT1 || ''\n'' || CC.SEGMENT2 || ''\n'' || CC.SEGMENT3 || ''\n'' || CC.SEGMENT4 || ''\n'' || CC.SEGMENT5 || ''\n'' || CC.SEGMENT6 || ''\n'' || CC.SEGMENT7 || ''\n'' || CC.SEGMENT8 || ''\n'' ||
		CC.SEGMENT9 || ''\n'' || CC.SEGMENT10 || ''\n'' || CC.SEGMENT11 || ''\n'' || CC.SEGMENT12 || ''\n'' || CC.SEGMENT13 || ''\n'' || CC.SEGMENT14 || ''\n'' || CC.SEGMENT15 || ''\n'' || CC.SEGMENT16 || ''\n'' || CC.SEGMENT17 || ''\n'' ||
		CC.SEGMENT18 || ''\n'' || CC.SEGMENT19 || ''\n'' || CC.SEGMENT20 || ''\n'' || CC.SEGMENT21 || ''\n'' || CC.SEGMENT22 || ''\n'' || CC.SEGMENT23 || ''\n'' || CC.SEGMENT24 || ''\n'' || CC.SEGMENT25 || ''\n'' || CC.SEGMENT26 || ''\n'' ||
		CC.SEGMENT27 || ''\n'' || CC.SEGMENT28 || ''\n'' || CC.SEGMENT29 || ''\n'' || CC.SEGMENT30)' ;

	LEDGER_NAME	varchar2(30);
	SELECT_MASTER_BUDGET	varchar2(300) := 'nvl(bm.period_net_dr, 0) - nvl(bm.period_net_cr, 0)' ;
	SELECT_DETAIL_BUDGET	varchar2(300) := 'nvl(bd.period_net_dr, 0) - nvl(bd.period_net_cr, 0)' ;
	ACCESS_SET_NAME	varchar2(30);
	--WHERE_DAS	varchar2(800);
	WHERE_DAS	varchar2(800) := 'AND 1=1';
	PTD_YTD_DSP	varchar2(240);
	function AfterReport return boolean  ;
	function available_budgetformula(MASTER_BUDGET_BAL in number, TOTAL_DETAIL_BAL in number) return number  ;
	function MASTER_BUDGET_NAMEFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	Function CHART_OF_ACCOUNTS_ID_p return varchar2;
	Function ORDERBY_FLEX_p return varchar2;
	Function SELECT_FLEX_p return varchar2;
	Function LEDGER_NAME_p return varchar2;
	Function SELECT_MASTER_BUDGET_p return varchar2;
	Function SELECT_DETAIL_BUDGET_p return varchar2;
	Function ACCESS_SET_NAME_p return varchar2;
	Function WHERE_DAS_p return varchar2;
	Function PTD_YTD_DSP_p return varchar2;
END GL_GLXRBCR_XMLP_PKG;



/
