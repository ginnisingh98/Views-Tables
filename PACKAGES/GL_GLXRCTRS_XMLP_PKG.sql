--------------------------------------------------------
--  DDL for Package GL_GLXRCTRS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXRCTRS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXRCTRSS.pls 120.0 2007/12/27 15:08:11 vijranga noship $ */
	C_BASE_CURR	varchar2(15);
	C_STRUCT_NUM	varchar2(15);
	C_WHERE_FLEX	varchar2(10000);
	C_WHERE_ACCT	varchar2(300);
	C_SELECT_COMP	varchar2(600);
	C_SELECT_ACCT	varchar2(600);
	C_SELECT_DET_COMP	varchar2(600);
	C_SELECT_DET_ACCT	varchar2(600);
	P_CONC_REQUEST_ID	number;
	C_ORDERBY_COMP	varchar2(240);
	C_ORDERBY_ACCT	varchar2(240);
	P_START_DATE	date;
	P_END_DATE	date;
	P_AMOUNT_TYPE	varchar2(10);
	P_FLEX_FROM	varchar2(900);
	P_FLEX_TO	varchar2(900);
	P_LEDGER_CURRENCY	varchar2(15);
	P_PERIOD_TO	varchar2(15);
	P_PERIOD_FROM	varchar2(15);
	P_LEDGER_ID	number;
	CP_EFF_PERIOD_START	number;
	C_LEDGER_NAME	varchar2(50);
	P_ACCESS_SET_ID	number;
	C_ACCESS_SET_NAME	varchar2(40);
	P_LEDGER_NAME	varchar2(40);
	C_WHERE_REC_STATUS	varchar2(100);
	P_REC_UNREC	varchar2(1);
	C_ACC_FLEX	varchar2(600):='(c.SEGMENT1||''\n''||c.SEGMENT2||''\n''||c.SEGMENT3||''\n''||c.SEGMENT4||''\n''||c.SEGMENT5||''\n''||c.SEGMENT6||''\n''||c.SEGMENT7||''\n''||c.SEGMENT8||''\n''||c.SEGMENT9||''\n''||c.SEGMENT10||''\n''
		||c.SEGMENT11||''\n''||c.SEGMENT12||''\n''||c.SEGMENT13||''\n''||c.SEGMENT14||''\n''||c.SEGMENT15||''\n''||c.SEGMENT16||''\n''||c.SEGMENT17||''\n''||c.SEGMENT18||''\n''||c.SEGMENT19||''\n''||c.SEGMENT20||''\n''||c.SEGMENT21||
		''\n''||c.SEGMENT22||''\n''||c.SEGMENT23||''\n''||c.SEGMENT24||''\n''||c.SEGMENT25||''\n''||c.SEGMENT26||''\n''||c.SEGMENT27||''\n''||c.SEGMENT28||''\n''||c.SEGMENT29||''\n''||c.SEGMENT30)';
	CP_COUNT_REC	number := 0 ;
	C_WHERE_DATE	varchar2(240);
	--C_WHERE_CURRENCY	varchar2(240);
        C_WHERE_CURRENCY	varchar2(240):=' ';
	C_WHERE_REF	varchar2(240);
	C_RECON_ID	number;
	C_LOGIN_ID	number;
	CP_period_start	date;
	CP_period_end	date;
	CP_start_date	varchar2(20);
	CP_end_date	varchar2(20);
	CP_EFF_PERIOD_END	number;
	COUNT_ROWS	number;
	--C_WHERE_DAS	varchar2(600);
	C_WHERE_DAS	varchar2(600):=' ';
	C_JGZZ_RECON_FLAG	varchar2(50);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function P_AMOUNT_TYPEValidTrigger return boolean  ;
	function CF_sysdate_dateFormula return Char  ;
	Function CP_COUNT_REC_p return number;
	Function C_WHERE_DATE_p return varchar2;
	Function C_WHERE_CURRENCY_p return varchar2;
	Function C_WHERE_REF_p return varchar2;
	Function C_RECON_ID_p return number;
	Function C_LOGIN_ID_p return number;
	Function CP_period_start_p return date;
	Function CP_period_end_p return date;
	Function CP_start_date_p return varchar2;
	Function CP_end_date_p return varchar2;
	Function CP_EFF_PERIOD_END_p return number;
	Function COUNT_ROWS_p return number;
	Function C_WHERE_DAS_p return varchar2;
	Function C_JGZZ_RECON_FLAG_p return varchar2;
END GL_GLXRCTRS_XMLP_PKG;


/
