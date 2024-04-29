--------------------------------------------------------
--  DDL for Package AR_ARXCBH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXCBH_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXCBHS.pls 120.0 2007/12/27 13:37:31 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_IN_CUSTOMER_NUM_LOW	varchar2(30);
	P_IN_CUSTOMER_NUM_HIGH	varchar2(30);
	P_IN_CUSTOMER_LOW	varchar2(50);
	P_IN_CUSTOMER_HIGH	varchar2(50);
	P_IN_INVOICE_NUMBER_LOW	varchar2(30);
	P_IN_INVOICE_NUMBER_HIGH	varchar2(30);
	P_TRX_DATE_LOW	date;
	P_TRX_DATE_HIGH	date;
	P_IN_TRX_DATE_LOW	date;
	P_IN_TRX_DATE_HIGH	date;
	P_IN_COLLECTOR_LOW	varchar2(30);
	P_IN_COLLECTOR_HIGH	varchar2(30);
	P_IN_TERMS_LOW	varchar2(30);
	P_IN_TERMS_HIGH	varchar2(30);
	P_TERMS_NAME_HIGH	varchar2(40):=' ';
	P_TERMS_NAME_LOW	varchar2(40):=' ';
	P_WHERE_11	varchar2(200):=' ';
	lp_in_customer_num_low	varchar2(200):=' ';
	lp_in_customer_num_high	varchar2(200):=' ';
	Lp_in_invoice_number_low	varchar2(200):=' ';
	lp_in_invoice_number_high	varchar2(200):=' ';
	lp_in_collector_high	varchar2(200):=' ';
	lp_in_collector_low	varchar2(200):=' ';
	lp_in_trx_date_low	varchar2(200):=' ';
	lp_in_trx_date_high	varchar2(200):=' ';
	lp_terms_low	varchar2(200):=' ';
	lp_terms_high	varchar2(200):=' ';
	P_WHERE_12	varchar2(200):=' ';
	P_TERMS_NAME	varchar2(200):=' ';
	P_Set_of_books_id	number;
	P_MIN_PRECISION	number;
	P_TERMS_NAME1	varchar2(200):=' ';
	P_FROM_1	varchar2(200):=' ';
	P_WHERE_2	varchar2(400):=' ';
	Addr_Prn_Flag	varchar2(1);
	Previous_Addr_Id	number := 0 ;
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(100);
	/*ADDED AS FIX*/
	P_IN_TRX_DATE_LOW_T  VARCHAR2(50);
 	P_IN_TRX_DATE_HIGH_T VARCHAR2(50);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function AfterPForm return boolean  ;
	function set_prn_flagformula(address_id in number) return number  ;
	function cf_currency_flagformula(p_payment_schedule_id in number) return char  ;
	Function Addr_Prn_Flag_p return varchar2;
	Function Previous_Addr_Id_p return number;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	function D_INVOICE_AMOUNTFormula(customer_name in varchar2) return VARCHAR2;
END AR_ARXCBH_XMLP_PKG;


/
