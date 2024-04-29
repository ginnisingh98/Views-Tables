--------------------------------------------------------
--  DDL for Package ARRX_SALES_TAX_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARRX_SALES_TAX_REP" AUTHID CURRENT_USER as
/* $Header: ARRXSTS.pls 115.1 2002/11/15 03:13:19 anukumar ship $ */
-- Intended as a private function

PROCEDURE INSERT_SALES_TAX_REPORT   (
	chart_of_accounts_id	in	number,
	trx_date_low		in	date,
	trx_date_high		in	date,
	gl_date_low		in	date,
	gl_date_high		in	date,
	state_low 		in	varchar2,
	state_high		in	varchar2,
	currency_low		in	varchar2,
	currency_high		in	varchar2,
	exemption_status	in 	varchar2,
	lp_gltax_where		in	varchar2,
	where_gl_flex 		in	varchar2,
	show_deposit_children	in	varchar2,
	detail_level 		in	varchar2,
	posted_status 		in	varchar2,
	show_cms_adjs_outside_date in	varchar2,
        request_id 		in	number,
    	user_id 		in	number,
    	mesg 			out NOCOPY	varchar2,
    	success 		out NOCOPY	boolean);

PROCEDURE FETCH_TRX_ABS_TOTALS  (
	fc_cust_trx_id			in	number,
	fc_type_flag			in	varchar2,
	fc_inv_line_amount_abs		out NOCOPY	number,
	fc_inv_freight_amount_abs 	out NOCOPY	number,
	fc_inv_tax_amount_abs		out NOCOPY	number,
	fc_inv_line_lines_count		out NOCOPY	number,
	fc_inv_tax_lines_count		out NOCOPY	number,
	fc_inv_freight_lines_count	out NOCOPY	number);

FUNCTION LINE_AMOUNT_CALC (
	c_type_flag 			IN 	VARCHAR2,
	c_line_amount 			IN 	NUMBER,
	c_inv_line_lines_count 		IN 	NUMBER,
	c_inv_line_amount_abs 		IN 	NUMBER,
	c_adj_line_amount 		IN 	NUMBER)
RETURN NUMBER;

PROCEDURE WRITE_LOG(
	fc_which		IN	NUMBER,
	fc_text			IN	VARCHAR2,
	fc_buffer		OUT NOCOPY	VARCHAR2);


FUNCTION GET_ITEM_DESCRIPTION(
	fc_organization_id	IN	NUMBER,
	fc_inventory_item_id	IN	NUMBER)
RETURN VARCHAR2;

FUNCTION GET_ITEM(
	fc_organization_id	IN	NUMBER,
	fc_inventory_item_id	IN	NUMBER)
RETURN VARCHAR2;

PROCEDURE SUM_ITEM_LINE_AMOUNT(
	fc_cust_trx_id		IN	NUMBER,
	fc_type_flag 		IN      VARCHAR2,
	fc_adj_line_amount 	IN 	NUMBER,
	fc_adj_tax_amount	IN	NUMBER,
	fc_exemption_status	IN	VARCHAR2,
	fc_line_total		OUT NOCOPY	NUMBER,
	fc_tax_total		OUT NOCOPY	NUMBER);

FUNCTION EXEMPTION_AMOUNT_CALC_LINE(
	fc_precision		IN	NUMBER,
	fc_mau			IN	NUMBER,
	fc_exempt_percent	IN	NUMBER,
	fc_line_amount		IN	NUMBER,
	fc_cnt_tax_lines	IN	NUMBER)
RETURN NUMBER;

FUNCTION TAXABLE_AMOUNT_CALC_LINE(
	fc_precision		IN	NUMBER,
	fc_mau			IN	NUMBER,
	fc_exemption_amount	IN	NUMBER,
	fc_line_amount		IN	NUMBER,
	fc_cnt_tax_lines	IN	NUMBER)
RETURN NUMBER;

FUNCTION TAX_AMOUNT_CALC (
	c_type_flag 		IN 	VARCHAR2,
	c_tax_amount		IN	NUMBER,
	c_inv_tax_lines_count 	IN 	NUMBER,
	c_inv_tax_amount_abs 	IN 	NUMBER,
	c_adj_line_amount 	IN 	NUMBER,
	c_inv_line_lines_count	IN	NUMBER,
	c_adj_tax_amount	IN	NUMBER)
RETURN NUMBER;

FUNCTION GLTAX_IN_BALANCE (
	c_trx_id		IN	NUMBER,
	c_detail_level		IN	VARCHAR2)
RETURN VARCHAR2;

FUNCTION TRX_COMMENT_FLAG (
	fc_type_flag		IN	VARCHAR2,
	fc_trx_id		IN	NUMBER,
	fc_detail_level		IN	VARCHAR2,
	fc_sum_tax_line_amount	IN	NUMBER,
	fc_adj_line_amount	IN	NUMBER,
	fc_adj_freight_amount	IN 	NUMBER,
	fc_adj_type		IN	VARCHAR2,
	fc_gl_flex		IN      VARCHAR2 )
RETURN VARCHAR2;

FUNCTION GET_CONVERSION_RATE_TYPE
        (c_exchange_rate_type	IN	VARCHAR2)
RETURN VARCHAR2;

PROCEDURE GET_CUSTOMER_INFORMATION(
	fc_customer_id_in 	IN 	NUMBER,
	fc_site_use_id		IN	NUMBER,
	fc_customer_trx_id 	IN	NUMBER,
	fc_customer_name	OUT NOCOPY	VARCHAR2,
	fc_customer_number	OUT NOCOPY	VARCHAR2,
	fc_customer_type	OUT NOCOPY	VARCHAR2,
	fc_address1		OUT NOCOPY	VARCHAR2,
	fc_address2		OUT NOCOPY	VARCHAR2,
	fc_address3		OUT NOCOPY	VARCHAR2,
	fc_address4		OUT NOCOPY	VARCHAR2,
	fc_city			OUT NOCOPY	VARCHAR2,
	fc_zip_code		OUT NOCOPY	VARCHAR2,
	fc_state		OUT NOCOPY	VARCHAR2,
	fc_province		OUT NOCOPY	VARCHAR2,
	fc_county		OUT NOCOPY	VARCHAR2);

FUNCTION GET_MIN_TAX_LINE_ID(
	fc_trx_line_id 		IN	NUMBER)
RETURN NUMBER;

FUNCTION AOL_ROUND(
	fc_n			IN	NUMBER,
	fc_precision		IN	NUMBER,
	fc_mac			IN	NUMBER)
RETURN NUMBER;

FUNCTION CNT_TAX_LINES_FOR_INV_LINE(
	fc_trx_line_id		IN	NUMBER)
RETURN NUMBER;

FUNCTION CNT_INV_LINES_FOR_INV_HEADER(
	f_trx_id		IN	NUMBER)
RETURN NUMBER;

FUNCTION GET_CUSTOMER_TRX_LINE_ID(
	fn_trx_id		IN	NUMBER,
	fn_cnt_lines		IN	NUMBER)
RETURN NUMBER;

PROCEDURE GET_PRECISION_AND_MAU(
	fc_currency		IN	VARCHAR2,
	fc_precision		OUT NOCOPY	NUMBER,
	fc_mau			OUT NOCOPY	NUMBER);

FUNCTION GET_EXEMPTION_AMT(
	fg_trx_id		IN	NUMBER,
	fg_precision		IN	NUMBER,
	fg_mau			IN	NUMBER,
	fg_type_flag		IN	VARCHAR2)
RETURN NUMBER;

-- These are the procedures to be called by concurrent request wrappers.

PROCEDURE SALES_TAX_RPT   (
	chart_of_accounts_id	in	number,
	trx_date_low		in	date,
	trx_date_high		in	date,
	gl_date_low		in	date,
	gl_date_high		in	date,
	state_low 		in	varchar2,
	state_high		in	varchar2,
	currency_low		in	varchar2,
	currency_high		in	varchar2,
	exemption_status	in 	varchar2,
	lp_gltax_where		in	varchar2,
	where_gl_flex		in	varchar2,
	show_deposit_children	in	varchar2,
	detail_level 		in	varchar2,
	posted_status 		in	varchar2,
	show_cms_adjs_outside_date in	varchar2,
        request_id 		in	number,
    	user_id 		in	number,
    	retcode 		out NOCOPY	number,
	errbuf			out NOCOPY	varchar2);

end ARRX_SALES_TAX_REP;

 

/
