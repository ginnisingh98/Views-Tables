--------------------------------------------------------
--  DDL for Package AR_ARXCPH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXCPH_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXCPHS.pls 120.0 2007/12/27 13:43:45 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	CP_IN_TRX_DATE_LOW VARCHAR2(20);
	CP_IN_TRX_DATE_HIGH VARCHAR2(20);
	P_in_sorting_order	varchar2(50);
	P_in_customer_low	varchar2(100);
	P_IN_CUSTOMER_HIGH	varchar2(200);
	P_IN_CUSTOMER_NUM_LOW	varchar2(30);
	P_IN_INV_NUM_LOW	varchar2(30);
	P_IN_INV_NUM_HIGH	varchar2(30);
	P_IN_TRX_DATE_LOW	date;
	P_IN_TRX_DATE_HIGH	date;
	P_IN_TERMS_LOW	varchar2(30);
	P_IN_TERMS_HIGH	varchar2(30);
	P_IN_COLLECTOR_LOW	varchar2(30);
	P_IN_COLLECTOR_HIGH	varchar2(200);
	P_MIN_PRECISION	number;
	lp_customer_name_low	varchar2(200):=' ';
	lp_customer_name_high	varchar2(200):=' ';
	lp_cust_num_low	varchar2(200):=' ';
	lp_cust_num_high	varchar2(200):=' ';
	lp_invoice_num_low	varchar2(200):=' ';
	lp_invoice_num_high	varchar2(200):=' ';
	P_IN_CUSTOMER_NUM_HIGH	varchar2(200);
	lp_trx_date_low	varchar2(200):=' ';
	lp_trx_date_high	varchar2(200):=' ';
	lp_terms_low	varchar2(200):=' ';
	lp_terms_high	varchar2(200):=' ';
	lp_collector_low	varchar2(200):=' ';
	lp_collector_high	varchar2(200):=' ';
	P_SET_OF_BOOKS_ID	varchar2(40);
	P_SYSDATE	date;
	SORT_BY_PHONETICS	varchar2(1);
	P_SORT	varchar2(40);
	Skip_Sum	number;
	Addr_Prn_Flag	varchar2(1);
	Prev_Addr_Id	number := 0 ;
	prev_customer_trx_id	varchar2(30);
	prev_currency_code	varchar2(32767);
	prev_customer_id	varchar2(50);
	prev_terms	varchar2(50);
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(240);
	RP_DATA_FOUND	varchar2(100);
	RP_SUB_TITLE	varchar2(80);
	RP_SORT_ORDER	varchar2(80);
	Actual_Invoice_Sum	number;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function AfterPForm return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function Report_SubtitleFormula return Char  ;
	function Sort_OrderFormula return VARCHAR2  ;
	function average_days_lateformula(rec_counter in number, sum_days_late in number) return number  ;
	function wt_avg_days_lateformula(sum_payment in number, sum_w_days_late in number) return number  ;
	function skip_inv_sumformula(invoice_amount in number, customer_id in number, currency_code in varchar2, customer_trx_id in number, terms_sequence_number in number) return number  ;
	function set_addr_flagformula(address_id in number) return number  ;
	Function Skip_Sum_p return number;
	Function Addr_Prn_Flag_p return varchar2;
	Function Prev_Addr_Id_p return number;
	Function prev_customer_trx_id_p return varchar2;
	Function prev_currency_code_p return varchar2;
	Function prev_customer_id_p return varchar2;
	Function prev_terms_p return varchar2;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_SUB_TITLE_p return varchar2;
	Function RP_SORT_ORDER_p return varchar2;
	Function Actual_Invoice_Sum_p return number;
    function D_invoice_amountFormula(customer varchar2) return VARCHAR2;
END AR_ARXCPH_XMLP_PKG;


/
