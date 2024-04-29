--------------------------------------------------------
--  DDL for Package AR_ARXBPH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXBPH_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXBPHS.pls 120.0 2007/12/27 13:36:24 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_IN_CUSTOMER_NUM_LOW	varchar2(30);
	P_IN_CUSTOMER_NUM_HIGH	varchar2(30);
	LP_CUSTOMER_NAME_LOW	varchar2(200);
	P_IN_CUSTOMER_LOW	varchar2(50);
	P_IN_CUSTOMER_HIGH	varchar2(50);
	P_IN_INVOICE_NUMBER_LOW	varchar2(30);
	P_IN_INVOICE_NUMBER_HIGH	varchar2(30);
	LP_TRX_DATE_LOW	varchar2(200) := ' ';
	LP_TRX_DATE_HIGH	varchar2(200) := ' ';
	P_IN_TRX_DATE_LOW	date;
	P_IN_TRX_DATE_HIGH	date;
	LP_INVOICE_AMOUNT_LOW	varchar2(200) := ' ';
	LP_INVOICE_AMOUNT_HIGH	varchar2(200) := ' ';
	LP_ACCOUNT_STATUS_LOW	varchar2(200);
	LP_ACCOUNT_STATUS_HIGH	varchar2(200);
	LP_INVOICE_NUMBER_HIGH	varchar2(200) := ' ';
	LP_INVOICE_NUMBER_LOW	varchar2(200) := ' ';
	P_WHERE_11	varchar2(400) := ' ';
	P_IN_INVOICE_AMOUNT_LOW	number;
	P_IN_INVOICE_AMOUNT_HIGH	number;
	P_IN_BALANCE_DUE_LOW	number;
	P_IN_BALANCE_DUE_HIGH	number;
	P_IN_ACCOUNT_STATUS_LOW	varchar2(200);
	P_IN_ACCOUNT_STATUS_HIGH	varchar2(200);
	P_IN_ACCOUNT_STATUS_LOW_1	varchar2(200);
	P_IN_ACCOUNT_STATUS_HIGH_1	varchar2(200);
	LP_BALANCE_DUE_LOW	varchar2(200) := ' ';
	LP_BALANCE_DUE_HIGH	varchar2(200) := ' ';
	LP_CUSTOMER_NAME_HIGH	varchar2(200);
	P_sob	number;
	LP_CUSTOMER_NUM_LOW	varchar2(200) := ' ';
	LP_CUSTOMER_NUM_HIGH	varchar2(200) := ' ';
	P_WHERE_12	varchar2(200) := ' ';
	P_WHERE_1	varchar2(200) := ' ';
	P_WHERE_2	varchar2(200) := ' ';
	lp_r_trx_date_low	varchar2(200) := ' ';
	lp_r_trx_date_high	varchar2(200) := ' ';
	P_CONS_PROFILE_VALUE	varchar2(10) := 'N';
	LP_QUERY_SHOW_BILL	varchar2(1000);
	LP_TABLE_SHOW_BILL	varchar2(1000) := ' ';
	LP_WHERE_SHOW_BILL	varchar2(1000) := ' ';
	lp_currency_show_bill	varchar2(32767);
	P_MAX_ID	number;
	Credits_Dummy	varchar2(14);
	Adjusts_Dummy	varchar2(14);
	Payment_no_dummy_cr	varchar2(32767);
	Payments_Dummy	varchar2(14);
	Adjusts_Dummy_Cr	varchar2(14);
	payment_no_dummy_adj	varchar2(32767);
	Payments_Dummy_adj	varchar2(14);
	Credits_Dummy_Adj	varchar2(14);
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(100);
	Status_Low	varchar2(200);
	Status_high	varchar2(200);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function D_INVOICE_AMOUNTFormula(customer_name in varchar2) return VARCHAR2;

	function Set_StatusFormula return VARCHAR2  ;
	function AfterPForm return boolean  ;
	Function Credits_Dummy_p return varchar2;
	Function Adjusts_Dummy_p return varchar2;
	Function Payment_no_dummy_cr_p return varchar2;
	Function Payments_Dummy_p return varchar2;
	Function Adjusts_Dummy_Cr_p return varchar2;
	Function payment_no_dummy_adj_p return varchar2;
	Function Payments_Dummy_adj_p return varchar2;
	Function Credits_Dummy_Adj_p return varchar2;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function Status_Low_p return varchar2;
	Function Status_high_p return varchar2;
END AR_ARXBPH_XMLP_PKG;


/
