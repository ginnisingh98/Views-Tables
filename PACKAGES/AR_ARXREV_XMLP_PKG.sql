--------------------------------------------------------
--  DDL for Package AR_ARXREV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXREV_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXREVS.pls 120.0 2007/12/27 14:05:47 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_REV_GL_START_DATE	date;
	P_REV_GL_END_DATE	date;
	P_REV_GL_START_DATE1	varchar2(10);
	P_REV_GL_END_DATE1	varchar2(10);
	P_CURR_LOW	varchar2(32767);
	P_CURR_HIGH	varchar2(32767);
	P_BANK_ACCOUNT_LOW	varchar2(100);
	P_BANK_ACCOUNT_HIGH	varchar2(100);
	lp_curr_high	varchar2(600) := ' ';
	lp_curr_low	varchar2(500) := ' ';
	lp_bank_account_low	varchar2(500) := ' ';
	lp_rev_gl_start_date_dm	varchar2(500) := ' ';
	lp_rev_gl_start_date	varchar2(600) := ' ';
	lp_rev_gl_end_date	varchar2(500) := ' ';
	P_ORDER_BY	varchar2(50);
	lp_rev_gl_end_date_dm	varchar2(600) :=  ' ';
	CURRENCY1	varchar2(40);
	CURRENCY2	varchar2(40);
	l_order_rpt_by	varchar2(10);
	P_CUST_LOW	varchar2(32767);
	P_CUST_HIGH	varchar2(32767);
	lp_customer_low	varchar2(300) := ' ';
	lp_customer_high	varchar2(300) := ' ';
	lp_reason	varchar2(300) := ' ';
	P_REASON	varchar2(30);
	lp_bank_account_high	varchar2(500) := ' ';
	c_cash_amt_func	number := 0 ;
	c_cash_amt	number := 0 ;
	c_misc_amt_func	number := 0 ;
	c_misc_amt	number := 0 ;
	c_nsf_amt_func	number := 0 ;
	c_nsf_amt	number := 0 ;
	c_rev_amt_func	number;
	c_rev_amt	number := 0 ;
	c_stop_amt_func	number := 0 ;
	c_stop_amt	number := 0 ;
	c_cash_dm_amt_func	number;
	c_misc_dm_amt_func	number;
	c_nsf_dm_amt_func	number;
	c_rev_dm_amt_func	number;
	c_stop_dm_amt_func	number;
	c_cash_dm_amt	number;
	c_misc_dm_amt	number;
	c_nsf_dm_amt	number;
	c_rev_dm_amt	number := 0 ;
	c_stop_dm_amt	number := 0 ;
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(300);
	RP_DATE_RANGE	varchar2(2100);
	RP_SUB_TITLE	varchar2(100);
	RP_DATA_FOUND_DM	varchar2(100);
	RP_CUST_DATA_FOUND	varchar2(32767);
	RP_CUST_DATA_FOUND_DM	varchar2(32767);
	RPD_FUNC_AMT	varchar2(16);
	RPD_CASH_AMT_FUNC	varchar2(16);
	RPD_MISC_AMT_FUNC	varchar2(16);
	RPD_NSF_AMT_FUNC	varchar2(16);
	RPD_REV_AMT_FUNC	varchar2(16);
	RPD_STOP_AMT_FUNC	varchar2(16);
	RPD_FUNC_DM_AMT	varchar2(16);
	RPD_CASH_DM_AMT_FUNC	varchar2(16);
	RPD_MISC_DM_AMT_FUNC	varchar2(16);
	RPD_NSF_DM_AMT_FUNC	varchar2(16);
	RPD_REV_DM_AMT_FUNC	varchar2(16);
	RPD_STOP_DM_AMT_FUNC	varchar2(16);
	RPD_CUST_FUNC	varchar2(16);
	RPD_DM_CUST_FUNC	varchar2(16);
	rp_none	varchar2(2100);
	rp_sum_for	varchar2(2100);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function AfterPForm return boolean  ;
	function c_calc_amountformula(r_type in varchar2, amount in number, functional_amount in number, reversal_category in varchar2) return number  ;
	function c_summary_label_bankformula(bank_name in varchar2) return varchar2  ;
	function c_dm_calc_amountformula(rev_type in varchar2, Amount_B in number, functional_Amount_B in number, Reversal_category_B in varchar2) return number  ;
	function c_summary_label_bank_dmformula(Bank_name_b in varchar2) return varchar2  ;
	function c_qcd_summary_label_custformul(QCD_DUMMY_NAME in varchar2) return varchar2  ;
	function c_qcr_summary_label_custformul(QCR_DUMMY_NAME in varchar2) return varchar2  ;
	Function c_cash_amt_func_p return number;
	Function c_cash_amt_p return number;
	Function c_misc_amt_func_p return number;
	Function c_misc_amt_p return number;
	Function c_nsf_amt_func_p return number;
	Function c_nsf_amt_p return number;
	Function c_rev_amt_func_p return number;
	Function c_rev_amt_p return number;
	Function c_stop_amt_func_p return number;
	Function c_stop_amt_p return number;
	Function c_cash_dm_amt_func_p return number;
	Function c_misc_dm_amt_func_p return number;
	Function c_nsf_dm_amt_func_p return number;
	Function c_rev_dm_amt_func_p return number;
	Function c_stop_dm_amt_func_p return number;
	Function c_cash_dm_amt_p return number;
	Function c_misc_dm_amt_p return number;
	Function c_nsf_dm_amt_p return number;
	Function c_rev_dm_amt_p return number;
	Function c_stop_dm_amt_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_DATE_RANGE_p return varchar2;
	Function RP_SUB_TITLE_p return varchar2;
	Function RP_DATA_FOUND_DM_p return varchar2;
	Function RP_CUST_DATA_FOUND_p return varchar2;
	Function RP_CUST_DATA_FOUND_DM_p return varchar2;
	Function RPD_FUNC_AMT_p return varchar2;
	Function RPD_CASH_AMT_FUNC_p return varchar2;
	Function RPD_MISC_AMT_FUNC_p return varchar2;
	Function RPD_NSF_AMT_FUNC_p return varchar2;
	Function RPD_REV_AMT_FUNC_p return varchar2;
	Function RPD_STOP_AMT_FUNC_p return varchar2;
	Function RPD_FUNC_DM_AMT_p return varchar2;
	Function RPD_CASH_DM_AMT_FUNC_p return varchar2;
	Function RPD_MISC_DM_AMT_FUNC_p return varchar2;
	Function RPD_NSF_DM_AMT_FUNC_p return varchar2;
	Function RPD_REV_DM_AMT_FUNC_p return varchar2;
	Function RPD_STOP_DM_AMT_FUNC_p return varchar2;
	Function RPD_CUST_FUNC_p return varchar2;
	Function RPD_DM_CUST_FUNC_p return varchar2;
	Function rp_none_p return varchar2;
	Function rp_sum_for_p return varchar2;
END AR_ARXREV_XMLP_PKG;


/