--------------------------------------------------------
--  DDL for Package AR_ARXCTA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXCTA_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXCTAS.pls 120.0 2007/12/27 13:44:48 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_ORDER_BY	varchar2(50);
	lp_order_by	varchar2(500):=' ';
	P_ADJUSTMENT_NAME_HIGH	varchar2(50);
	P_ADJUSTMENT_NAME_LOW	varchar2(50);
	P_CREATED_BY_LOW	varchar2(100);
	P_CREATED_BY_HIGH	varchar2(100);
	P_CUSTOMER_NAME_LOW	varchar2(50);
	P_CUSTOMER_NAME_HIGH	varchar2(50);
	P_GL_DATE_HIGH	date;
	P_GL_DATE_LOW	date;
	P_INVOICE_LOW	varchar2(32767);
	P_INVOICE_HIGH	varchar2(32767);
	P_INVOICE_TYPE_LOW	varchar2(32767);
	P_INVOICE_TYPE_HIGH	varchar2(32767);
	P_STATUS_LOW	varchar2(80);
	P_STATUS_HIGH	varchar2(80);
	P_CURR_CODE	varchar2(30);
	P_CUSTOMER_NUMBER_LOW	varchar2(100);
	P_CUSTOMER_NUMBER_HIGH	varchar2(100);
	lp_customer_name_low	varchar2(300):=' ';
	lp_customer_name_high	varchar2(300):=' ';
	lp_customer_number_low	varchar2(300):=' ';
	lp_customer_number_high	varchar2(300):=' ';
	lp_adjustment_name_low	varchar2(300):=' ';
	lp_adjustment_name_high	varchar2(300):=' ';
	lp_invoice_low	varchar2(300):=' ';
	lp_invoice_high	varchar2(300):=' ';
	lp_invoice_type_low	varchar2(300):=' ';
	lp_invoice_type_high	varchar2(300):=' ';
	lp_gl_date_low	varchar2(300):=' ';
	lp_gl_date_high	varchar2(300):=' ';
	lp_status_low	varchar2(300):=' ';
	lp_status_high	varchar2(300):=' ';
	lp_created_by_low	varchar2(300):=' ';
	lp_created_by_high	varchar2(300):=' ';
	ACCT_BAL_APROMPT	varchar2(80);
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(300);
	RP_GL_DATE	varchar2(2100);
	RP_ORDER_BY	varchar2(240);
	RP_FUNC_CURRENCY	varchar2(20) := 'USD' ;
	P_MEANING	varchar2(80);
	RP_TOTAL	varchar2(80);
	RP_SUM	varchar2(80);
	RP_FUNC	varchar2(80);
	RP_SUMFOR	varchar2(80);
	RP_GRAND	varchar2(80);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function AfterPForm return boolean  ;
	function c_status_summary_labelformula(Currency_Code in varchar2, Status_1 in varchar2) return varchar2  ;
	function c_name_summary_labelformula(Currency_Code in varchar2, Name_1 in varchar2) return varchar2  ;
	function c_creator_labelformula(Currency_Code in varchar2, Created_by in varchar2) return varchar2  ;
	function c_currency_summary_labelformul(currency_Code in varchar2) return varchar2  ;
	function C_ORDER_BYFormula return VARCHAR2  ;
	function c_data_not_foundformula(Currency_Code in varchar2) return varchar2  ;
	function C_GRAND_TOTAL_LABELFormula return VARCHAR2  ;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_GL_DATE_p return varchar2;
	Function RP_ORDER_BY_p return varchar2;
	Function RP_FUNC_CURRENCY_p return varchar2;
	Function P_MEANING_p return varchar2;
	Function RP_TOTAL_p return varchar2;
	Function RP_SUM_p return varchar2;
	Function RP_FUNC_p return varchar2;
	Function RP_SUMFOR_p return varchar2;
	Function RP_GRAND_p return varchar2;
END AR_ARXCTA_XMLP_PKG;


/
