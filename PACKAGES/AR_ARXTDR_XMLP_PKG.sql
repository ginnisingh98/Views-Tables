--------------------------------------------------------
--  DDL for Package AR_ARXTDR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXTDR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXTDRS.pls 120.0 2007/12/27 14:11:32 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_INVOICE_NUM_LOW	varchar2(32767);
	P_INVOICE_NUM_HIGH	varchar2(32767);
	P_TRANSACTION_TYPE	varchar2(32767);
	--P_CONS_PROFILE_VALUE	varchar2(10);
	P_CONS_PROFILE_VALUE	varchar2(10):= 'N';
	LP_QUERY_SHOW_BILL	varchar2(1000):='arps.trx_number';
	LP_TABLE_SHOW_BILL	varchar2(1000):= ' ';
	LP_WHERE_SHOW_BILL	varchar2(1000):= ' ';
	P_BASE_LANG	varchar2(4);
	RP_COMPANY_NAME	varchar2(30);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(3);
	RP_LINES	number;
	RP_FR_LINES	number;
	RP_TX_LINES	number;
	RP_SALESREPS	number;
	RP_REV_ACCTS	number;
	RP_TX_CUST_TRX_ID	number;
	CP_ACC_MESSAGE	varchar2(2000);
	P_TRANSACTION_TYPE_DUMMY varchar2(32767);
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function YES_MEANINGFormula return VARCHAR2  ;
	function NO_MEANINGFormula return VARCHAR2  ;
	function TRX_FLEX_DELIMFormula return VARCHAR2  ;
	function LOC_FLEX_ALL_SEGFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function ship_to_address5formula(ship_to_city in varchar2, ship_to_state in varchar2, ship_to_postal_code in varchar2, ship_to_country in varchar2) return varchar2  ;
	function bill_to_address5formula(bill_to_city in varchar2, bill_to_state in varchar2, bill_to_postal_code in varchar2, bill_to_country in varchar2) return varchar2  ;
	--function d_sold_toformula(sold_to_customer_number in varchar2) return varchar2  ;
	function d_sold_toformula(sold_to_customer_number in varchar2,sold_to_customer_name in varchar2) return varchar2 ;
	function d_remit_toformula(remit_to_address1 in varchar2, remit_to_address2 in varchar2, remit_to_address3 in varchar2,
	remit_to_address4 in varchar2, remit_to_city in varchar2, remit_to_state in varchar2, remit_to_postal_code in varchar2, remit_to_country in varchar2) return varchar2  ;
	function D_LOCATIONFormula return VARCHAR2  ;
	function ITEM_FLEX_STRUCTUREFormula return Number  ;
	function RP_INV_RANGEFormula return VARCHAR2  ;
	function tr_inv_amountformula(TR_LN_EXTD_AMOUNT in number, TR_TX_EXTD_AMOUNT in number, TR_FR_EXTD_AMOUNT in number) return number  ;
	function ln_additional_infoformula(LN_ORDER_NUMBER in varchar2, LN_ORDER_DATE in date, LN_ORDER_REVISION in number, LN_SALES_CHANNEL in varchar2,
	LN_DURATION in number, LN_ACCOUNTING_RULE in varchar2, LN_RULE_START_DATE in date) return varchar2  ;
	function trx_transaction_flexformula(customer_trx_id in number) return varchar2  ;
	function line_transaction_flexformula(tf_customer_trx_line_id in number) return varchar2  ;
	FUNCTION COMP_TX_CUST_TRX_ID (P_CUST_TRX_ID number) RETURN boolean  ;
	function cf_acc_messageformula(acc_gl_date in date) return number  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_LINES_p return number;
	Function RP_FR_LINES_p return number;
	Function RP_TX_LINES_p return number;
	Function RP_SALESREPS_p return number;
	Function RP_REV_ACCTS_p return number;
	Function RP_TX_CUST_TRX_ID_p return number;
	Function CP_ACC_MESSAGE_p return varchar2;
END AR_ARXTDR_XMLP_PKG;


/
