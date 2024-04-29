--------------------------------------------------------
--  DDL for Package AR_RAXINPS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RAXINPS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RAXINPSS.pls 120.0 2007/12/27 14:26:24 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_GL_START_DATE	date;
	P_GL_END_DATE	date;
	P_ORDER_BY	varchar2(50);
	P_SET_OF_BOOKS_ID	number;
	P_TRX_END_DATE	date;
	P_TRX_START_DATE	date;
	P_YES	varchar2(80);
	P_NO	varchar2(80);
	/*ADED AS FIX*/
	P_GL_START_DATE_T varchar2(30);
	P_GL_END_DATE_T varchar2(30);
	P_TRX_END_DATE_T  varchar2(30);
	P_TRX_START_DATE_T varchar2(30);

	lp_gl_start_date	varchar2(200) :=' ';
	lp_gl_end_date	varchar2(800) :=' ';
	lp_trx_start_date	varchar2(800) :=' ';
	lp_trx_end_date	varchar2(800) :=' ';
	lp_type_low	varchar2(800) :=' ';
	lp_type_high	varchar2(800) :=' ';
	lp_start_currency_code	varchar2(900) :=' ';
	lp_end_currency_code	varchar2(900) :=' ';
--	lp_gl_start_date	varchar2(200);
--	lp_gl_end_date	varchar2(800);
--	lp_trx_start_date	varchar2(800);
--	lp_trx_end_date	varchar2(800);
--	lp_type_low	varchar2(800);
--	lp_type_high	varchar2(800);
--	lp_start_currency_code	varchar2(900);
--	lp_end_currency_code	varchar2(900);
	P_TYPE_LOW	varchar2(50);
	P_TYPE_HIGH	varchar2(50);
	P_START_CURRENCY_CODE	varchar2(50);
	P_END_CURRENCY_CODE	varchar2(50);
	ACCT_BAL_APROMPT	varchar2(80);
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(300);
	RP_GL_DATE_RANGE	varchar2(2100);
	RP_TRX_DATE_RANGE	varchar2(2100);
	RPD_REPORT_SUMMARY	varchar2(17);
	RP_BAL_LPROMPT	varchar2(100);
	CP_ACC_MESSAGE	varchar2(2000);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function AfterPForm return boolean  ;
	function c_class_labelformula(class in varchar2) return varchar2  ;
	function c_company_labelformula(D_company in varchar2) return varchar2  ;
	function c_post_labelformula(postable in varchar2) return varchar2  ;
	function c_currency_labelformula(currency_A in varchar2) return varchar2  ;
	function c_data_not_foundformula(company in varchar2) return number  ;
	function cf_acc_messageformula(org_id in number) return number  ;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_GL_DATE_RANGE_p return varchar2;
	Function RP_TRX_DATE_RANGE_p return varchar2;
	Function RPD_REPORT_SUMMARY_p return varchar2;
	Function RP_BAL_LPROMPT_p return varchar2;
	Function CP_ACC_MESSAGE_p return varchar2;
	Function p_no_p return varchar2;
	Function p_yes_p return varchar2;

END AR_RAXINPS_XMLP_PKG;


/
