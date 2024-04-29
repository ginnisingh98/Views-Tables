--------------------------------------------------------
--  DDL for Package GL_GLXRLMAB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXRLMAB_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXRLMABS.pls 120.0 2007/12/27 15:15:53 vijranga noship $ */
	P_STRUCT_NUM	number;
	P_CONC_REQUEST_ID	number;
	P_ALLOC_BATCH_NAME	varchar2(40);
	SEL_FLEXDATA	varchar2(1000) := 'SEGMENT1||''.''||SEGMENT2||''.''||SEGMENT3||''.''||SEGMENT4||''.''||SEGMENT5||''.''||SEGMENT6||''.''||SEGMENT7||''.''||SEGMENT8||''.''||SEGMENT9||''.''||SEGMENT10||''.''||SEGMENT11||''.''||SEGMENT12
	||''.''||SEGMENT13||''.''||SEGMENT14||''.''||SEGMENT15||''.''||SEGMENT16||''.''||SEGMENT17||''.''||SEGMENT18||''.''||SEGMENT19||''.''||SEGMENT20||''.''||SEGMENT21||''.''||SEGMENT22||''.''||SEGMENT23||''.''||SEGMENT24||''.''||SEGMENT25
	||''.''||SEGMENT26||''.''||SEGMENT27||''.''||SEGMENT28||''.''||SEGMENT29||''.''||SEGMENT30';
	DELIMITER	varchar2(1);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function C_Standard_FormulaFormula return VARCHAR2  ;
	function account_action_codeformula(AMOUNT in number, LEDGER_ACTION_CODE in varchar2, SEGMENT_TYPES_KEY in varchar2) return char  ;
	Function SEL_FLEXDATA_p return varchar2;
	Function DELIMITER_p return varchar2;
END GL_GLXRLMAB_XMLP_PKG;



/
