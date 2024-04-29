--------------------------------------------------------
--  DDL for Package AR_ARXSOC2_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXSOC2_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXSOC2S.pls 120.0 2007/12/27 14:08:46 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_DATE_LOW	date;
	P_DATE_HIGH	date;
	P_DATE_LOW1	varchar2(10);
	P_DATE_HIGH1	varchar2(10);
	P_BANK_ACCOUNT_NAME_LOW	varchar2(80);
	P_BANK_ACCOUNT_NAME_HIGH	varchar2(80);
	P_ORDER_BY	varchar2(32767);
	P_ORDER_BY_1    varchar2(32767);
	P_SET_OF_BOOKS_ID	number;
	lp_bank_account_name_low	varchar2(800):=' ';
	lp_bank_account_name_high	varchar2(800):=' ';
	lp_date_low	varchar2(200):=' ';
	lp_date_high	varchar2(200):=' ';
	P_BANK_COUNT	number:=0;
	PH_ORDER_BY	varchar2(32767);
	p_actual_amount	number;
	p_unidentified_amount	number;
	p_misc_amount	number;
	p_nsf_amount	number;
	p_applied_count	number;
	p_unapplied_count	number;
	p_misc_count	number;
	pa_actual_amount	number;
	pa_unidentified_amount	number;
	pa_misc_amount	number;
	pa_nsf_amount	number;
	pa_applied_count	number;
	pa_unapplied_count	number;
	pa_misc_count	number;
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND3	varchar2(300);
	RP_DATE_RANGE	varchar2(150);
	RP_DATA_FOUND1	varchar2(300);
	RP_DATA_FOUND2	varchar2(300);
	RP_ORDER_BY	varchar2(80);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function c_difference_amountformula(c_rcpt_control_amount in number, c_actual_amount in number) return number  ;
	function c_summary_labelformula(Currency_A in varchar2) return varchar2  ;
	function ca_difference_amountformula(c_rcpt_control_amount_B in number, ca_actual_amount in number) return number  ;
	function ca_summary_labelformula(Currency_B in varchar2) return varchar2  ;
	function cf_data_not_foundformula(bank_account_name_C in varchar2) return number  ;
	function cr_data_foundformula(Currency_B in varchar2) return number  ;
	function cm_data_not_foundformula(Currency_A in varchar2) return number  ;
	function AfterPForm return boolean  ;
	function f_amountsformula(cr_status in varchar2, amount in number, cr_type in varchar2, reversal_category in varchar2, cash_receipt_id in number) return number  ;
	function c_unapplied_amountformula(c_unapplied_amount_A in number, c_on_account_amount in number, c_unidentified_amount in number) return number  ;
	function f_all_amountsformula(cr_status_BB in varchar2, amount_B in number, cr_type_B in varchar2, reversal_category_B in varchar2, cash_receipt_id_B in number) return number  ;
	function ca_unapplied_amountformula(ca_unapplied_amount_B in number, ca_on_account_amount in number, ca_unidentified_amount in number) return number  ;
	function Order_By_MeaningFormula return VARCHAR2  ;
	Function p_actual_amount_p return number;
	Function p_unidentified_amount_p return number;
	Function p_misc_amount_p return number;
	Function p_nsf_amount_p return number;
	Function p_applied_count_p return number;
	Function p_unapplied_count_p return number;
	Function p_misc_count_p return number;
	Function pa_actual_amount_p return number;
	Function pa_unidentified_amount_p return number;
	Function pa_misc_amount_p return number;
	Function pa_nsf_amount_p return number;
	Function pa_applied_count_p return number;
	Function pa_unapplied_count_p return number;
	Function pa_misc_count_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND3_p return varchar2;
	Function RP_DATE_RANGE_p return varchar2;
	Function RP_DATA_FOUND1_p return varchar2;
	Function RP_DATA_FOUND2_p return varchar2;
	Function RP_ORDER_BY_p return varchar2;
END AR_ARXSOC2_XMLP_PKG;


/
