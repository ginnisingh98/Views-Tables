--------------------------------------------------------
--  DDL for Package AR_ARXDIR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXDIR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXDIRS.pls 120.0 2007/12/27 13:47:52 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_CUSTOMER_NAME_LOW	varchar2(50);
	P_CUSTOMER_NAME_HIGH	varchar2(50);
	P_ORDER_BY	varchar2(50);
	/*ADDED AS FIX*/
	P_ORDER_BY_T VARCHAR2(50);
	P_ITEM_NUMBER_LOW	varchar2(30);
	P_ITEM_NUMBER_HIGH	varchar2(30);
	P_SET_OF_BOOKS_ID	number;
	P_DUE_DATE_LOW	date;
	P_DUE_DATE_HIGH	date;
	P_COLLECTOR_LOW	varchar2(30);
	P_COLLECTOR_HIGH	varchar2(30);
	lp_customer_name_low	varchar2(100) :=' ';
	lp_customer_name_high	varchar2(100) :=' ';
	lp_item_number_low	varchar2(100) :=' ';
	lp_item_number_high	varchar2(100) :=' ';
	lp_due_date_low	varchar2(100) :=' ';
	lp_due_date_high	varchar2(100) :=' ';
	lp_collector_low	varchar2(100) :=' ';
	lp_collector_high	varchar2(200) :=' ';
	lp_order_by	varchar2(900) :=' ';
	--	lp_customer_name_low	varchar2(100);
	--	lp_customer_name_high	varchar2(100);
	--	lp_item_number_low	varchar2(100);
	--	lp_item_number_high	varchar2(100);
	--	lp_due_date_low	varchar2(100);
	--	lp_due_date_high	varchar2(100);
	--	lp_collector_low	varchar2(100);
	--	lp_collector_high	varchar2(200);
	--	lp_order_by	varchar2(900);

	P_CUSTOMER_NUMBER_LOW	varchar2(30);
	P_CUSTOMER_NUMBER_HIGH	varchar2(30);
	lp_customer_number_low	varchar2(100) :=' ';
	lp_customer_number_high	varchar2(200) :=' ';
	--	lp_customer_number_low	varchar2(100);
	--	lp_customer_number_high	varchar2(200);

	P_CONS_PROFILE_VALUE	varchar2(10);
	--P_CONS_PROFILE_VALUE	varchar2(10) :='N';
	--LP_QUERY_SHOW_BILL	varchar2(1000);
	LP_QUERY_SHOW_BILL	varchar2(1000):='ar_payment_schedules.trx_number';
	LP_TABLE_SHOW_BILL	varchar2(1000):=' ';
	LP_WHERE_SHOW_BILL	varchar2(1000):=' ';
	LP_STATUS	varchar2(100):=' ';
--	LP_TABLE_SHOW_BILL	varchar2(1000);
--	LP_WHERE_SHOW_BILL	varchar2(1000);
--	LP_STATUS	varchar2(100);

	P_INVOICE_STATUS	varchar2(50);
	P_INVOICE_STATUS_PARAM	varchar2(50);
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(300);
	RPD_REPORT_TOTAL_INV	varchar2(17);
	RPD_REPORT_TOTAL_BAL	varchar2(17);
	RPD_REPORT_TOTAL_DISP	varchar2(17);
	rp_sum_for	varchar2(2000);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function AfterPForm return boolean  ;
	function c_data_not_foundformula(Currency_Main in varchar2) return number  ;
	function c_cust_summary_labelformula(Dummy_Customer_Name in varchar2) return varchar2  ;
	function c_currency_summary_labelformul(Currency_Main in varchar2) return varchar2  ;
	function cons_numberformula(Number in varchar2, cons_bill_number in varchar2) return varchar2  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RPD_REPORT_TOTAL_INV_p return varchar2;
	Function RPD_REPORT_TOTAL_BAL_p return varchar2;
	Function RPD_REPORT_TOTAL_DISP_p return varchar2;
	Function rp_sum_for_p return varchar2;
END AR_ARXDIR_XMLP_PKG;


/
