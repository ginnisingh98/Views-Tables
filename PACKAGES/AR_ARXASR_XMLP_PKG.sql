--------------------------------------------------------
--  DDL for Package AR_ARXASR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXASR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXASRS.pls 120.0 2007/12/27 13:33:46 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_CUSTOMER_NUMBER_LOW	varchar2(30);
	P_CUSTOMER_NUMBER_HIGH	varchar2(30);
	P_CUSTOMER_NAME_LOW	varchar2(50);
	P_CUSTOMER_NAME_HIGH	varchar2(50);
	P_ORDER_BY	varchar2(50);
	P_SET_OF_BOOKS_ID	number;
	P_COLLECTOR_NAME_LOW	varchar2(30);
	P_COLLECTOR_NAME_HIGH	varchar2(30);
	P_START_ACCOUNT_STATUS	varchar2(30);
	P_END_ACCOUNT_STATUS	varchar2(30);
	lp_order_by	varchar2(200):=' ';
	lp_customer_name_low	varchar2(500):=' ';
	lp_customer_name_high	varchar2(500):=' ';
	lp_customer_number_low	varchar2(500):=' ';
	lp_customer_number_high	varchar2(500):=' ';
	lp_collector_name_low	varchar2(500):=' ';
	lp_collector_name_high	varchar2(500):=' ';
	lp_start_account_status1	varchar2(500):=' ';
	lp_end_account_status1	varchar2(500):=' ';
	P_CONS_PROFILE_VALUE	varchar2(10);
	LP_QUERY_SHOW_BILL	varchar2(1000):=' ';
	LP_TABLE_SHOW_BILL	varchar2(1000):=' ';
	LP_WHERE_SHOW_BILL	varchar2(1000):=' ';
	p_ca_set_of_books_id	number;
	p_ca_org_id	number;
	p_mrcsobtype	varchar2(10);
	lp_ar_system_parameters	varchar2(50):=' ';
	lp_ar_system_parameters_all	varchar2(50):=' ';
	lp_ar_payment_schedules	varchar2(50):=' ';
	lp_ar_payment_schedules_all	varchar2(50):=' ';
	lp_ar_adjustments	varchar2(50):=' ';
	lp_ar_adjustments_all	varchar2(50):=' ';
	lp_ar_batches	varchar2(50):=' ';
	lp_ar_batches_all	varchar2(50):=' ';
	lp_ar_cash_receipt_history_all	varchar2(50):=' ';
	lp_ar_cash_receipt_history	varchar2(50):=' ';
	lp_ar_cash_receipts	varchar2(50):=' ';
	lp_ar_cash_receipts_all	varchar2(50):=' ';
	lp_ar_distributions	varchar2(50):=' ';
	lp_ar_distributions_all	varchar2(50):=' ';
	lp_ra_customer_trx	varchar2(50):=' ';
	lp_ra_customer_trx_all	varchar2(50):=' ';
	lp_ra_cust_trx_gl_dist	varchar2(50):=' ';
	lp_ra_cust_trx_gl_dist_all	varchar2(50):=' ';
	lp_ra_batches	varchar2(50):=' ';
	lp_ra_batches_all	varchar2(50):=' ';
	lp_ar_misc_cash_dists	varchar2(50):=' ';
	lp_ar_misc_cash_dists_all	varchar2(50):=' ';
	lp_ar_rate_adjustments	varchar2(50):=' ';
	lp_ar_rate_adjustments_all	varchar2(50):=' ';
	lp_ar_receivable_apps	varchar2(50):=' ';
	lp_ar_receivable_apps_all	varchar2(50):=' ';
	LP_START_ACCOUNT_STATUS2	varchar2(500):=' ';
	LP_END_ACCOUNT_STATUS2	varchar2(500):=' ';
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(240);
	RP_DATA_FOUND	varchar2(100);
	RPD_REPORT_SUMMARY	varchar2(17);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function AfterPForm return boolean  ;
	function c_status_summary_labelformula(status in varchar2) return varchar2  ;
	function c_data_not_foundformula(status in varchar2) return number  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RPD_REPORT_SUMMARY_p return varchar2;
END AR_ARXASR_XMLP_PKG;


/
