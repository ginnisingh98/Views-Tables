--------------------------------------------------------
--  DDL for Package AR_ARXDPR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXDPR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXDPRS.pls 120.0 2007/12/27 13:49:23 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_as_of_date	date;
	P_currency_low	varchar2(15);
	P_currency_high	varchar2(15);
	P_bal_seg_low	varchar2(25);
	P_bal_seg_high	varchar2(25);
	P_cust_num_low	varchar2(30);
	P_cust_num_high	varchar2(30);
	P_cust_name_low	varchar2(50);
	P_cust_name_high	varchar2(50);
	ACCT_BAL_APROMPT	varchar2(80);
	out_discount_date	varchar2(9);
	out_amt_to_apply	number;
	earned_disc_pct	number := 0.00 ;
	out_earned_disc	number;
	out_unearned_disc	number;
	best_disc_pct	number;
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(240);
	CP_ACC_MESSAGE	varchar2(2000);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function abs_discFormula return Number  ;
	function unearnd_disc_pctformula(unearned_discount in varchar2) return number  ;
	function cf_acc_messageformula(gl_date in date) return number  ;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function out_discount_date_p return varchar2;
	Function out_amt_to_apply_p return number;
	Function earned_disc_pct_p return number;
	Function out_earned_disc_p return number;
	Function out_unearned_disc_p return number;
	Function best_disc_pct_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function CP_ACC_MESSAGE_p return varchar2;
END AR_ARXDPR_XMLP_PKG;


/
