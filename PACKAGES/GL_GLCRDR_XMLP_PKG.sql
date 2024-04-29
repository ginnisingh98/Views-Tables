--------------------------------------------------------
--  DDL for Package GL_GLCRDR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLCRDR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLCRDRS.pls 120.0 2007/12/27 14:34:49 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_TO_BATCH_ID	number;
	P_ACCESS_SET_ID	number;
	TO_CHART_OF_ACCOUNTS_ID	varchar2(15) := '50105' ;
	TO_LEDGER_NAME	varchar2(30);
	SELECT_TO_FLEX	varchar2(1000) := '(to_cc.segment1||''\n''||to_cc.segment2||''\n''||to_cc.segment3||''\n''||
	to_cc.segment4||''\n''||to_cc.segment5||''\n''||to_cc.segment6||''\n''||to_cc.segment7||''\n''||
	to_cc.segment8||''\n''||to_cc.segment9||''\n''||to_cc.segment10||''\n''||to_cc.segment11||''\n''||
	to_cc.segment12||''\n''||to_cc.segment13||''\n''||to_cc.segment14||''\n''||to_cc.segment15||''\n''||
	to_cc.segment16||''\n''||to_cc.segment17||''\n''||to_cc.segment18||''\n''||to_cc.segment19||''\n''||
	to_cc.segment20||''\n''||to_cc.segment21||''\n''||to_cc.segment22||''\n''||to_cc.segment23||''\n''||
	to_cc.segment24||''\n''||to_cc.segment25||''\n''||to_cc.segment26||''\n''||to_cc.segment27||''\n''||
	to_cc.segment28||''\n''||to_cc.segment29||''\n''||to_cc.segment30)' ;
	ORDERBY_FROM_FLEX	varchar2(1000) := 'from_cc.segment1, from_cc.segment2, from_cc.segment3, from_cc.segment4,
	from_cc.segment5, from_cc.segment6, from_cc.segment7, from_cc.segment8, from_cc.segment9, from_cc.segment10,
	from_cc.segment11, from_cc.segment12, from_cc.segment13, from_cc.segment14, from_cc.segment15, from_cc.segment16,
	from_cc.segment17, from_cc.segment18, from_cc.segment19, from_cc.segment20, from_cc.segment21, from_cc.segment22,
	from_cc.segment23, from_cc.segment24, from_cc.segment25, from_cc.segment26, from_cc.segment27, from_cc.segment28,
	from_cc.segment29, from_cc.segment30' ;
	SELECT_FROM_FLEX	varchar2(1000) := '(FROM_CC.SEGMENT1 || ''\n'' || FROM_CC.SEGMENT2 || ''\n'' ||
	FROM_CC.SEGMENT3 || ''\n'' || FROM_CC.SEGMENT4 || ''\n'' || FROM_CC.SEGMENT5 || ''\n'' || FROM_CC.SEGMENT6 ||
	''\n'' || FROM_CC.SEGMENT7 || ''\n'' || FROM_CC.SEGMENT8 || ''\n'' || FROM_CC.SEGMENT9 || ''\n'' ||
	FROM_CC.SEGMENT10 || ''\n'' || FROM_CC.SEGMENT11 || ''\n'' || FROM_CC.SEGMENT12 || ''\n'' || FROM_CC.SEGMENT13 ||
	''\n'' || FROM_CC.SEGMENT14 || ''\n'' || FROM_CC.SEGMENT15 || ''\n'' || FROM_CC.SEGMENT16 || ''\n'' ||
	FROM_CC.SEGMENT17 || ''\n'' || FROM_CC.SEGMENT18 || ''\n'' || FROM_CC.SEGMENT19 || ''\n'' || FROM_CC.SEGMENT20
	|| ''\n'' || FROM_CC.SEGMENT21 || ''\n'' || FROM_CC.SEGMENT22 || ''\n'' || FROM_CC.SEGMENT23 || ''\n'' ||
	FROM_CC.SEGMENT24 || ''\n'' || FROM_CC.SEGMENT25 || ''\n'' || FROM_CC.SEGMENT26 || ''\n'' || FROM_CC.SEGMENT27 ||
	''\n'' || FROM_CC.SEGMENT28 || ''\n'' || FROM_CC.SEGMENT29 || ''\n'' || FROM_CC.SEGMENT30)' ;
	ORDERBY_TO_FLEX	varchar2(1000) := 'to_cc.segment1, to_cc.segment2, to_cc.segment3,
	to_cc.segment4, to_cc.segment5, to_cc.segment6, to_cc.segment7, to_cc.segment8, to_cc.segment9,
	to_cc.segment10, to_cc.segment11, to_cc.segment12, to_cc.segment13, to_cc.segment14, to_cc.segment15,
	to_cc.segment16, to_cc.segment17, to_cc.segment18, to_cc.segment19, to_cc.segment20, to_cc.segment21,
	to_cc.segment22, to_cc.segment23, to_cc.segment24, to_cc.segment25, to_cc.segment26, to_cc.segment27,
	to_cc.segment28, to_cc.segment29, to_cc.segment30' ;
	TO_BATCH_NAME	varchar2(100);
	TO_LEDGER_ID	number;
	TO_PERIOD	varchar2(15);
	FROM_LEDGER_ID	number;
	FROM_CHART_OF_ACCOUNTS_ID	varchar2(25);
	FROM_LEDGER_NAME	varchar2(30);
	CONSOLIDATION_NAME	varchar2(33);
	CURRENCY_CODE	varchar2(15);
	WHERE_DAS_CLAUSE	varchar2(10000) := 'AND 1 = 1' ;
	DAS_NAME	varchar2(30);
	procedure gl_consolidation_name(cons_id number, cons_name out NOCOPY varchar2,
                                curr_code out NOCOPY varchar2,
                                errbuf out NOCOPY varchar2)  ;
	procedure gl_get_batch_info(batch_id number, batch_name out  NOCOPY varchar2,
                            to_ledid out NOCOPY number, to_period out NOCOPY varchar2,
                            from_ledid out NOCOPY number, cons_id out NOCOPY number,
                            errbuf out NOCOPY varchar2)  ;
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	Function TO_CHART_OF_ACCOUNTS_ID_p return varchar2;
	Function TO_LEDGER_NAME_p return varchar2;
	Function SELECT_TO_FLEX_p return varchar2;
	Function ORDERBY_FROM_FLEX_p return varchar2;
	Function SELECT_FROM_FLEX_p return varchar2;
	Function ORDERBY_TO_FLEX_p return varchar2;
	Function TO_BATCH_NAME_p return varchar2;
	Function TO_LEDGER_ID_p return number;
	Function TO_PERIOD_p return varchar2;
	Function FROM_LEDGER_ID_p return number;
	Function FROM_CHART_OF_ACCOUNTS_ID_p return varchar2;
	Function FROM_LEDGER_NAME_p return varchar2;
	Function CONSOLIDATION_NAME_p return varchar2;
	Function CURRENCY_CODE_p return varchar2;
	Function WHERE_DAS_CLAUSE_p return varchar2;
	Function DAS_NAME_p return varchar2;
END GL_GLCRDR_XMLP_PKG;



/
