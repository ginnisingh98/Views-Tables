--------------------------------------------------------
--  DDL for Package GL_GLXRBJRN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXRBJRN_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXRBJRNS.pls 120.0 2007/12/27 15:04:31 vijranga noship $ */
	P_CONC_REQUEST_ID	number;
	P_LEDGER_ID	number;
	P_BUDGET_VERSION_ID	number;
	P_CODE_COMBINATION_ID	number;
	P_CURRENCY_CODE	varchar2(15);
	P_PERIOD_YEAR	number;
	P_DAS_ID	number;
	STRUCT_NUM	number;
	LEDGER_NAME	varchar2(30);
	FLEXDATA	varchar2(1000) := '(segment1||''\n''||segment2||''\n''||segment3||''\n''||segment4||''\n''||segment5||''\n''||segment6||''\n''||segment7||''\n''||segment8||''\n''||segment9||''\n''||segment10||''\n''||segment11||''\n''||
		segment12||''\n''||segment13||''\n''||segment14||''\n''||segment15||''\n''||segment16||''\n''||segment17||''\n''||segment18||''\n''||segment19||''\n''||segment20||''\n''||segment21||''\n''||segment22||''\n''||segment23||''\n''||
		segment24||''\n''||segment25||''\n''||segment26||''\n''||segment27||''\n''||segment28||''\n''||segment29||''\n''||segment30)' ;
	BUDGET_NAME	varchar2(15);
	DAS_NAME	varchar2(30);
	WHERE_DAS	varchar2(600):=' ';
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function STRUCT_NUM_p return number;
	Function LEDGER_NAME_p return varchar2;
	Function FLEXDATA_p return varchar2;
	Function BUDGET_NAME_p return varchar2;
	Function DAS_NAME_p return varchar2;
	Function WHERE_DAS_p return varchar2;
END GL_GLXRBJRN_XMLP_PKG;



/
