--------------------------------------------------------
--  DDL for Package AR_ARXPDI_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXPDI_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXPDIS.pls 120.1 2008/01/11 10:36:39 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_CUSTOMER_NAME_LOW	varchar2(50);
	P_CUSTOMER_NAME_HIGH	varchar2(50);
	P_INVOICE_TYPE_LOW	varchar2(80);
	P_INVOICE_TYPE_HIGH	varchar2(80);
	P_ORDER_BY	varchar2(50);
	P_PAST_DAYS_DUE_LOW	varchar2(15);
	P_PAST_DAYS_DUE_HIGH	varchar2(15);
	P_AMOUNT_LOW	number;
	P_AMOUNT_HIGH	number;
	P_COLLECTOR_LOW	varchar2(30);
	P_COLLECTOR_HIGH	varchar2(30);
	P_SALESREP_LOW	varchar2(240);
	P_SALESREP_HIGH	varchar2(240);
	P_AS_OF_DATE	date;
	lp_order_by	varchar2(300):=' ';
	lp_amount_low	varchar2(200):=' ';
	lp_amount_high	varchar2(200):=' ';
	lp_collector_low	varchar2(100):=' ';
	lp_collector_high	varchar2(100):=' ';
	lp_customer_name_low	varchar2(100):=' ';
	lp_customer_name_high	varchar2(100):=' ';
	lp_invoice_type_low	varchar2(100):=' ';
	lp_invoice_type_high	varchar2(100):=' ';
	ph_customer_number_low	varchar2(50);
	ph_customer_number_high	varchar2(50);
	P_CUSTOMER_NUMBER_LOW	varchar2(50);
	P_CUSTOMER_NUMBER_HIGH	varchar2(50);
	lp_customer_number_low	varchar2(100):=' ';
	lp_customer_number_high	varchar2(100):=' ';
	lp_past_days_due_low	varchar2(100):=' ';
	lp_past_days_due_high	varchar2(100):=' ';
	lp_salesrep_low	varchar2(340):=' ';
	lp_salesrep_high	varchar2(340):=' ';
	P_CONS_PROFILE_VALUE	varchar2(10):='N';
	LP_QUERY_SHOW_BILL	varchar2(1000):=' ';
	LP_TABLE_SHOW_BILL	varchar2(1000):=' ';
	LP_WHERE_SHOW_BILL	varchar2(1000):=' ';
	P_DAYS_PAST_DUE_FROM	varchar2(100);
	P_BALANCE_DUE_FROM	varchar2(100);
	P_balance_due	varchar2(80);
	P_customer	varchar2(80);
	P_salesperson	varchar2(240);
	P_as_of	varchar2(2000);
	ACCT_BAL_APROMPT	varchar2(80);
	RP_OLD_CURR	varchar2(20);
	RP_CURR_CHECK	number;
	RP_OLD_CUSTOMER	varchar2(50);
	RP_CUST_CHECK	number;
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(300);
	RP_AS_OF_DATE	varchar2(30);
	RP_PAST_DAYS	varchar2(40);
	RP_BALANCE	varchar2(50);
	RP_SALE_CURR	varchar2(270);
	RP_CURR	varchar2(30);
	c_industry_code	varchar2(20);
	c_salesrep_title	varchar2(20);
	rp_balance_from	varchar2(40);
	rp_balance_to	varchar2(40);
	rp_past_days_from	varchar2(40);
	rp_past_days_to	varchar2(40);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function AfterPForm return boolean  ;
	function c_temp_salformula(Currency_Code in varchar2,Salesrep in varchar2) return varchar2  ;
	function c_data_foundformula(Currency_Code in varchar2) return varchar2  ;
	function c_custom_checkformula(Currency_Code in varchar2, Cust_ID in number) return varchar2  ;
	procedure get_boiler_plates  ;
	procedure get_lookup_meaning(p_lookup_type      in varchar2,
                             p_lookup_code      in varchar2,
                             p_lookup_meaning  in out NOCOPY varchar2)
                             ;
	function set_display_for_core return boolean  ;
	function set_display_for_gov return boolean  ;
	function invoice_number_consformula(invoice_number in varchar2, cons_bill_number in varchar2) return varchar2  ;
	function CF_ORDER_BYFormula return Char  ;
	function CF_salespersonFormula return Char  ;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function RP_OLD_CURR_p return varchar2;
	Function RP_CURR_CHECK_p return number;
	Function RP_OLD_CUSTOMER_p return varchar2;
	Function RP_CUST_CHECK_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_AS_OF_DATE_p return varchar2;
	Function RP_PAST_DAYS_p return varchar2;
	Function RP_BALANCE_p return varchar2;
	Function RP_SALE_CURR_p return varchar2;
	Function RP_CURR_p return varchar2;
	Function c_industry_code_p return varchar2;
	Function c_salesrep_title_p return varchar2;
	Function rp_balance_from_p return varchar2;
	Function rp_balance_to_p return varchar2;
	Function rp_past_days_from_p return varchar2;
	Function rp_past_days_to_p return varchar2;
END AR_ARXPDI_XMLP_PKG;



/
