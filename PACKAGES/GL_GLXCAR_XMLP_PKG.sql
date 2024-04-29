--------------------------------------------------------
--  DDL for Package GL_GLXCAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXCAR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXCARS.pls 120.0 2007/12/27 14:49:24 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_CONSOLIDATION_ID	number;
	P_PERIOD_NAME	varchar2(15);
	P_USAGE	varchar2(30);
	P_BALANCE_TYPE	varchar2(15);
	TO_CHART_OF_ACCOUNTS_ID	varchar2(15) := '50105' ;
	TO_LEDGER_NAME	varchar2(30);
	SELECT_TO_FLEX	varchar2(1000) := '(ca.segment1||''\n''||ca.segment2||''\n''||ca.segment3||''\n''||ca.segment4||''\n''||ca.segment5||''\n''||ca.segment6||''\n''||ca.segment7||''\n''||ca.segment8||''\n''||ca.segment9||''\n''||ca.segment10||
		''\n''||ca.segment11||''\n''||ca.segment12||''\n''||ca.segment13||''\n''||ca.segment14||''\n''||ca.segment15||''\n''||ca.segment16||''\n''||ca.segment17||''\n''||ca.segment18||''\n''||ca.segment19||''\n''||ca.segment20||''\n''||
		ca.segment21||''\n''||ca.segment22||''\n''||ca.segment23||''\n''||ca.segment24||''\n''||ca.segment25||''\n''||ca.segment26||''\n''||ca.segment27||''\n''||ca.segment28||''\n''||ca.segment29||''\n''||ca.segment30)' ;
	ORDERBY_FROM_FLEX	varchar2(1000) := 'cc.segment1, cc.segment2, cc.segment3, cc.segment4, cc.segment5, cc.segment6, cc.segment7, cc.segment8, cc.segment9, cc.segment10, cc.segment11, cc.segment12, cc.segment13, cc.segment14,
		cc.segment15, cc.segment16, cc.segment17, cc.segment18, cc.segment19, cc.segment20, cc.segment21, cc.segment22, cc.segment23, cc.segment24, cc.segment25, cc.segment26, cc.segment27, cc.segment28, cc.segment29, cc.segment30' ;
	SELECT_FROM_FLEX	varchar2(1000) := '(CC.SEGMENT1 || ''\n'' || CC.SEGMENT2 || ''\n'' || CC.SEGMENT3 || ''\n'' || CC.SEGMENT4 || ''\n'' || CC.SEGMENT5 || ''\n'' || CC.SEGMENT6 || ''\n'' || CC.SEGMENT7 || ''\n'' || CC.SEGMENT8 ||
		''\n'' || CC.SEGMENT9 || ''\n'' || CC.SEGMENT10 || ''\n'' || CC.SEGMENT11 || ''\n'' || CC.SEGMENT12 || ''\n'' || CC.SEGMENT13 || ''\n'' || CC.SEGMENT14 || ''\n'' || CC.SEGMENT15 || ''\n'' || CC.SEGMENT16 || ''\n'' || CC.SEGMENT17 ||
		''\n'' || CC.SEGMENT18 || ''\n'' || CC.SEGMENT19 || ''\n'' || CC.SEGMENT20 || ''\n'' || CC.SEGMENT21 || ''\n'' || CC.SEGMENT22 || ''\n'' || CC.SEGMENT23 || ''\n'' || CC.SEGMENT24 || ''\n'' || CC.SEGMENT25 || ''\n'' || CC.SEGMENT26 ||
		''\n'' || CC.SEGMENT27 || ''\n'' || CC.SEGMENT28 || ''\n'' || CC.SEGMENT29 || ''\n'' || CC.SEGMENT30)' ;
	ORDERBY_TO_FLEX	varchar2(1000) := 'ca.segment1, ca.segment2, ca.segment3, ca.segment4, ca.segment5, ca.segment6, ca.segment7, ca.segment8, ca.segment9, ca.segment10, ca.segment11, ca.segment12, ca.segment13, ca.segment14, ca.segment15,
		ca.segment16, ca.segment17, ca.segment18, ca.segment19, ca.segment20, ca.segment21, ca.segment22, ca.segment23, ca.segment24, ca.segment25, ca.segment26, ca.segment27, ca.segment28, ca.segment29, ca.segment30' ;
	TO_LEDGER_ID	number;
	FROM_LEDGER_ID	number;
	FROM_CHART_OF_ACCOUNTS_ID	varchar2(25);
	FROM_LEDGER_NAME	varchar2(30);
	CONSOLIDATION_NAME	varchar2(33);
	CURRENCY_CODE	varchar2(15);
	WHERE_DR_CR_NOT_ZERO	varchar2(300) := '((nvl(ca.entered_dr,0) <> 0) or (nvl(ca.entered_cr,0) <> 0))' ;
	FROM_CURRENCY_CODE	varchar2(16);
	WHERE_BALANCE	varchar2(500) := '1 = 1' ;
	function BeforeReport return boolean ;
	function SUBTITLE1Formula return VARCHAR2  ;
	function AfterReport return boolean  ;
	procedure gl_get_consolidation_info(
                           cons_id NUMBER, cons_name OUT NOCOPY VARCHAR2,
                           method OUT NOCOPY VARCHAR2, curr_code OUT NOCOPY VARCHAR2,
                           from_ledgerid OUT NOCOPY NUMBER, to_ledgerid OUT NOCOPY NUMBER,
                           description OUT NOCOPY VARCHAR2,
                           errbuf OUT NOCOPY VARCHAR2)  ;
	function USAGE_DISPLAYFormula return VARCHAR2  ;
	Function TO_CHART_OF_ACCOUNTS_ID_p return varchar2;
	Function TO_LEDGER_NAME_p return varchar2;
	Function SELECT_TO_FLEX_p return varchar2;
	Function ORDERBY_FROM_FLEX_p return varchar2;
	Function SELECT_FROM_FLEX_p return varchar2;
	Function ORDERBY_TO_FLEX_p return varchar2;
	Function TO_LEDGER_ID_p return number;
	Function FROM_LEDGER_ID_p return number;
	Function FROM_CHART_OF_ACCOUNTS_ID_p return varchar2;
	Function FROM_LEDGER_NAME_p return varchar2;
	Function CONSOLIDATION_NAME_p return varchar2;
	Function CURRENCY_CODE_p return varchar2;
	Function WHERE_DR_CR_NOT_ZERO_p return varchar2;
	Function FROM_CURRENCY_CODE_p return varchar2;
	Function WHERE_BALANCE_p return varchar2;
END GL_GLXCAR_XMLP_PKG;



/
