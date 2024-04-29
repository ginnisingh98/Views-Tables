--------------------------------------------------------
--  DDL for Package AR_ARXRJR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXRJR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXRJRS.pls 120.0 2007/12/27 14:06:59 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	lp_company_low	varchar2(2000):=' ';
	lp_company_high	varchar2(2000):=' ';
	lp_account_low	varchar2(2500):=' ';
	lp_account_high	varchar2(2500):=' ';
	p_in_company_low	varchar2(25);
	p_in_company_high	varchar2(25);
	p_in_account_low	varchar2(2000);
	p_in_account_high	varchar2(2000);
	p_chart_of_accounts_id	number;
	p_report_mode	varchar2(30);
	p_status	varchar2(30);
	p_receipt_class	varchar2(30);
	p_payment_method	varchar2(30);
	p_gl_date_low	date;
	p_gl_date_high	date;
	p_currency	varchar2(15);
	p_order_by	varchar2(30);
	P_REPORT_MODE_T varchar2(30);
	P_ORDER_BY_T varchar2(30);
        FACCMSG varchar2(30);
	lp_accounting_flex	varchar2(2000):=' rpad(segment1,600) ';
	lp_company_seg	varchar2(1000):='segment1';
	p_company_name	varchar2(80);
	p_currency_disp	varchar2(15);
	LP_GROUP_BY	varchar2(1000):=' group by segment1, st.meaning, rc.name, rm.name, cr.cash_receipt_id, cr.receipt_number, party.party_name, cust_acct.account_number, site_uses.location,cr.doc_sequence_value ';
	LP_NAME	varchar2(200):='to_char(''AAAAAAAAAAAAAAAAAAAA'')';
	LP_TRXDATE	varchar2(200):='to_date(null)';
	LP_GLDATE	varchar2(200):='to_date(null)';
	lp_order_by	varchar2(100):=' ';
	LP_GL_DATE_LOW	varchar2(200):=' ';
	LP_GL_DATE_HIGH	varchar2(200):=' ';
	LP_SOURCE_TYPE	varchar2(200):=' ';
	LP_RECEIPT_CLASS	varchar2(200):=' ';
	LP_PAYMENT_METHOD	varchar2(200):=' ';
	LP_CURRENCY	varchar2(200):=' ';
	P_REPORTING_LEVEL	number;
	P_reporting_context	number;
	P_SET_OF_BOOKS_ID	number;
	P_POSTING_STATUS	varchar2(32767);
	P_IN_CUSTOMER_NAME_LOW	varchar2(200);
	P_IN_CUSTOMER_NAME_HIGH	varchar2(200);
	P_IN_CUSTOMER_NUM_LOW	varchar2(30);
	P_IN_CUSTOMER_NUM_HIGH	varchar2(30);
	P_FROM_WHERE	varchar2(2000);
	P_cr_where	varchar2(700):=' ';
	P_hist	varchar2(100):='ar_cash_receipt_history_all';
	P_dist	varchar2(100):= 'ar_xla_ard_lines_v';
	p_gl	varchar2(100):= 'gl_code_combinations';
	P_cust	varchar2(100):='hz_cust_accounts_all';
	P_cash	varchar2(100):='ar_cash_receipts';
	P_party	varchar2(100):='hz_parties';
	P_site	varchar2(100):='hz_cust_site_uses_All';
	P_rm	varchar2(100):='ar_receipt_methods';
	P_RC	varchar2(100):='ar_receipt_classes';
	P_look	varchar2(50):='ar_lookups';
	P_batch	varchar2(100):='ar_batches_all';
	P_reporting_entity_id	number;
	lp_customer_name_low	varchar2(200):=' ';
	lp_customer_name_high	varchar2(200):=' ';
	lp_customer_num_low	varchar2(2000):=' ';
	lp_customer_num_high	varchar2(2000):=' ';
	P_cust_where	varchar2(1000);
	P_site_where	varchar2(1000);
	lp_account_high1	varchar2(2000);
	lp_account_low1	varchar2(2000);
	RP_DATA_FOUND	varchar2(300);
	C_BAL_OR_TRANS_AMOUNT	varchar2(800) :=  'SUM (DECODE(d.amount_cr, null,DECODE(:p_currency, null,d.acctd_amount_dr, d.amount_dr), DECODE(:p_currency, null,-d.acctd_amount_cr, -d.amount_cr)))' ;
	C_HAVING	varchar2(800);
	reporting_level_name	varchar2(30);
	reporting_context_name	varchar2(80);
	Reporting_entity_level_name	varchar2(80);
	rp_message	varchar2(2000);
	CP_ACC_MESSAGE	varchar2(2000);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function AfterPForm return boolean  ;
	Function RP_DATA_FOUND_p return varchar2;
	Function C_BAL_OR_TRANS_AMOUNT_p return varchar2;
	Function C_HAVING_p return varchar2;
	Function reporting_level_name_p return varchar2;
	Function reporting_context_name_p return varchar2;
	Function Reporting_entity_level_name_p return varchar2;
	Function rp_message_p return varchar2;
	Function CP_ACC_MESSAGE_p return varchar2;
	function F_ACC_MESSAGEFormatTrigger return varchar2;

END AR_ARXRJR_XMLP_PKG;


/
