--------------------------------------------------------
--  DDL for Package AR_RAXCBR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RAXCBR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RAXCBRS.pls 120.1 2008/01/08 15:18:15 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_SORT_BY	varchar2(50);
	P_COMMITMENT_LOW	varchar2(32767);
	P_COMMITMENT_HIGH	varchar2(32767);
	P_AGREEMENT_NAME_LOW	varchar2(50);
	P_AGREEMENT_NAME_HIGH	varchar2(50);
	P_CUSTOMER_NUMBER_LOW	varchar2(50);
	P_CUSTOMER_NUMBER_HIGH	varchar2(50);
	P_CUSTOMER_NAME_LOW	varchar2(50);
	P_CUSTOMER_NAME_HIGH	varchar2(50);
	P_COMMITMENT_TYPE_LOW	varchar2(50);
	P_COMMITMENT_TYPE_HIGH	varchar2(50);
	P_END_DATE_LOW	varchar2(50);
	P_END_DATE_HIGH	varchar2(50);
	P_END_DATE_LOW_1	varchar2(50);
	P_END_DATE_HIGH_1	varchar2(50);
	P_CURRENCY_CODE_LOW	varchar2(50);
	P_CURRENCY_CODE_HIGH	varchar2(50);
	P_MIN_PRECISION	number;
	/*LP_CUSTOMER_NAME_LOW	varchar2(200);
	LP_CUSTOMER_NAME_HIGH	varchar2(200);
	LP_CUSTOMER_NUMBER_LOW	varchar2(200);
	LP_CUSTOMER_NUMBER_HIGH	varchar2(200);
	LP_COMMITMENT_LOW	varchar2(200);
	LP_COMMITMENT_HIGH	varchar2(200);
	LP_COMMITMENT_TYPE_LOW	varchar2(200);
	LP_COMMITMENT_TYPE_HIGH	varchar2(200);
	LP_AGREEMENT_NAME_LOW	varchar2(200);
	LP_AGREEMENT_NAME_HIGH	varchar2(200);
	LP_CURRENCY_CODE_LOW	varchar2(200);
	LP_CURRENCY_CODE_HIGH	varchar2(200);
	LP_END_DATE_LOW	varchar2(200);
	LP_END_DATE_HIGH	varchar2(200);*/
		LP_CUSTOMER_NAME_LOW	varchar2(200) := ' ';
		LP_CUSTOMER_NAME_HIGH	varchar2(200) := ' ';
		LP_CUSTOMER_NUMBER_LOW	varchar2(200) := ' ';
		LP_CUSTOMER_NUMBER_HIGH	varchar2(200) := ' ';
		LP_COMMITMENT_LOW	varchar2(200) := ' ';
		LP_COMMITMENT_HIGH	varchar2(200) := ' ';
		LP_COMMITMENT_TYPE_LOW	varchar2(200) := ' ';
		LP_COMMITMENT_TYPE_HIGH	varchar2(200) := ' ';
		LP_AGREEMENT_NAME_LOW	varchar2(200) := ' ';
		LP_AGREEMENT_NAME_HIGH	varchar2(200) := ' ';
		LP_CURRENCY_CODE_LOW	varchar2(200) := ' ';
		LP_CURRENCY_CODE_HIGH	varchar2(200) := ' ';
		LP_END_DATE_LOW	varchar2(200) := ' ';
		LP_END_DATE_HIGH	varchar2(200) := ' ';
	P_GL_DATE_LOW	date;
	P_GL_DATE_HIGH	date;
	P_TRX_DATE_LOW	date;
	P_TRX_DATE_HIGH	date;
	/*LP_GL_DATE_LOW	varchar2(200);
	LP_GL_DATE_HIGH	varchar2(200);
	LP_TRX_DATE_HIGH	varchar2(200);
	LP_TRX_DATE_LOW	varchar2(200);*/
		LP_GL_DATE_LOW	varchar2(200):= ' ';
		LP_GL_DATE_HIGH	varchar2(200):= ' ';
		LP_TRX_DATE_HIGH	varchar2(200):= ' ';
		LP_TRX_DATE_LOW	varchar2(200):= ' ';
	P_SO_SOURCE_CODE	varchar2(240);
	P_LEVEL	varchar2(30);
	--LP_UNBOOKED	varchar2(200);
	LP_UNBOOKED	varchar2(200):= ' ';
	P_UNBOOKED	varchar2(1);
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(100);
	c_industry_code	varchar2(20);
	c_salesrep_title	varchar2(20);
	c_salesorder_title	varchar2(20);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function c_adjusted_amount_childformula(source in varchar2, trx_class in varchar2, child_customer_trx_id in number, commit_type in varchar2, customer_trx_id1 in number) return number  ;
	function c_oe_amountformula(customer_trx_id1 in number) return number  ;
	function c_commitment_balanceformula(commitment_amount in number, customer_trx_id in number, commit_type in varchar2) return varchar2  ;
	function AfterPForm return boolean  ;
	procedure get_lookup_meaning(p_lookup_type	in VARCHAR2,
			     p_lookup_code	in VARCHAR2,
			     p_lookup_meaning  	in out NOCOPY VARCHAR2)
			     ;
	procedure get_boiler_plates  ;
	function set_display_for_core(p_field_name in VARCHAR2)
         return boolean  ;
	function set_display_for_gov(p_field_name in VARCHAR2)
         return boolean  ;
	function C_Order_ByFormula return Char  ;
	function c_commitment_remformula(commitment_amount in number, c_commitment_balance in varchar2, c_oe_amount in number) return number  ;
	function c_adj_amt_cmformula(source1 in varchar2, commit_type in varchar2, child_customer_trx_id in number, child_cm_customer_trx_id in number, customer_trx_id1 in number) return number  ;
	function c_sum_invoiced_amount_arformul(sum_invoiced_amount_inv in number, sum_invoiced_amount_cm in number) return number  ;
	function c_sum_tax_amount_arformula(sum_tax_amount_inv in number, sum_tax_amount_cm in number) return number  ;
	function c_sum_freight_amount_arformula(sum_freight_amount_inv in number, sum_freight_amount_cm in number) return number  ;
	function c_sum_line_amount_arformula(sum_line_amount_inv in number, sum_line_amount_cm in number) return number  ;
	function c_sum_adjusted_amount_arformul(sum_adjusted_amount_inv in number, sum_adjusted_amount_cm in number) return number  ;
	function c_sum_bal_amount_arformula(sum_bal_amount_inv in number, sum_bal_amount_cm in number) return number  ;
	function C_FORMAT_LEVELFormula return Char  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function c_industry_code_p return varchar2;
	Function c_salesrep_title_p return varchar2;
	Function c_salesorder_title_p return varchar2;
END AR_RAXCBR_XMLP_PKG;


/
