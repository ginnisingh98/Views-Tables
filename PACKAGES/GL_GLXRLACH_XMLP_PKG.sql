--------------------------------------------------------
--  DDL for Package GL_GLXRLACH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXRLACH_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXRLACHS.pls 120.0 2007/12/27 15:10:13 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_LEDGER_ID	number;
	P_TEMPLATE_ID	number;
	P_ACCESS_SET_ID	number;
	OLD_DESC	varchar2(240);
	LEDGER_NAME	varchar2(30);

	P_FLEXDATA_SUM	varchar2(1000) := '(cs1.SEGMENT1||''\n''||cs1.SEGMENT2||''\n''||cs1.SEGMENT3||''\n'' || cs1.SEGMENT4||''\n''||cs1.SEGMENT5||''\n''||cs1.SEGMENT6||''\n''
	|| cs1.SEGMENT7||''\n''||cs1.SEGMENT8||''\n''
	||cs1.SEGMENT9||''\n'' || cs1.SEGMENT10||''\n''||cs1.SEGMENT11||''\n''||cs1.SEGMENT12||''\n'' || cs1.SEGMENT13||''\n''||cs1.SEGMENT14||''\n''||cs1.SEGMENT15||''\n''
	|| cs1.SEGMENT16||''\n''||cs1.SEGMENT17||''\n''||cs1.SEGMENT18||''\n'' || cs1.SEGMENT19||''\n''||cs1.SEGMENT20||''\n''||cs1.SEGMENT21||''\n'' || cs1.SEGMENT22||''\n''
	||cs1.SEGMENT23||''\n''||cs1.SEGMENT24||''\n''
	|| cs1.SEGMENT25||''\n''||cs1.SEGMENT26||''\n''||cs1.SEGMENT27||''\n'' || cs1.SEGMENT28||''\n''||cs1.SEGMENT29||''\n''||cs1.SEGMENT30)' ;

	/*P_FLEXDATA_DET	varchar2(1000) := := '(cd.SEGMENT1||'\n'||cd.SEGMENT2||'\n'||cd.SEGMENT3||'\n' || cd.SEGMENT4||'\n'||cd.SEGMENT5||'\n'||
	cd.SEGMENT6||'\n' || cd.SEGMENT7||'\n'||cd.SEGMENT8||'\n'||cd.SEGMENT9||'\n' || cd.SEGMENT10||'\n'||cd.SEGMENT11||'\n'||cd.SEGMENT12||'\n' ||
	cd.SEGMENT13||'\n'||cd.SEGMENT14||'\n'||cd.SEGMENT15||'\n' || cd.SEGMENT16||'\n'||cd.SEGMENT17||'\n'||cd.SEGMENT18||'\n' || cd.SEGMENT19||'\n'||
	cd.SEGMENT20||'\n'||cd.SEGMENT21||'\n' || cd.SEGMENT22||'\n'||cd.SEGMENT23||'\n'||cd.SEGMENT24||'\n' || cd.SEGMENT25||'\n'||cd.SEGMENT26||'\n'||
	cd.SEGMENT27||'\n' || cd.SEGMENT28||'\n'||cd.SEGMENT29||'\n'||cd.SEGMENT30)' ; */
	P_FLEXDATA_DET	varchar2(1000) := '(cd.SEGMENT1||''\n''||cd.SEGMENT2||''\n''||cd.SEGMENT3||''\n'' || cd.SEGMENT4||''\n''||cd.SEGMENT5||''\n''
	||cd.SEGMENT6||''\n'' || cd.SEGMENT7||''\n''||cd.SEGMENT8||''\n''||cd.SEGMENT9||''\n'' || cd.SEGMENT10||''\n''||cd.SEGMENT11||''\n''||
	cd.SEGMENT12||''\n'' || cd.SEGMENT13||''\n''||cd.SEGMENT14||''\n''||cd.SEGMENT15||''\n'' || cd.SEGMENT16||''\n''||cd.SEGMENT17||''\n''||cd.SEGMENT18||
	''\n'' || cd.SEGMENT19||''\n''||cd.SEGMENT20||''\n''||cd.SEGMENT21||''\n'' || cd.SEGMENT22||''\n''||cd.SEGMENT23||''\n''||cd.SEGMENT24||''\n'' ||
	cd.SEGMENT25||''\n''||cd.SEGMENT26||''\n''||cd.SEGMENT27||''\n'' || cd.SEGMENT28||''\n''||cd.SEGMENT29||''\n''||cd.SEGMENT30)';
	P_ORDER_BY_SUM	varchar2(500) := 'cs1.SEGMENT1' ;
	P_ORDER_BY_DET	varchar2(500) := 'cd.SEGMENT1' ;
	STRUCT_NUM	number;
	WHERE_DAS	varchar2(800);
	WHERE_TEMPLATE	varchar2(50);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function new_descformula(C_DESC_ACCT_DET in varchar2) return varchar2  ;
	Function OLD_DESC_p return varchar2;
	Function LEDGER_NAME_p return varchar2;
	Function P_FLEXDATA_SUM_p return varchar2;
	Function P_FLEXDATA_DET_p return varchar2;
	Function P_ORDER_BY_SUM_p return varchar2;
	Function P_ORDER_BY_DET_p return varchar2;
	Function STRUCT_NUM_p return number;
	Function WHERE_DAS_p return varchar2;
	Function WHERE_TEMPLATE_p return varchar2;
END GL_GLXRLACH_XMLP_PKG;


/
