--------------------------------------------------------
--  DDL for Package JERX_TO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JERX_TO" AUTHID CURRENT_USER AS
/* $Header: jegrtos.pls 120.2 2006/04/07 11:02:09 samalhot ship $ */

--
-- Main Core Report Specification for AR Turnover Extract Procedure.
--

PROCEDURE JE_AR_TURNOVER_EXTRACT(
	errbuf             OUT NOCOPY  VARCHAR2,
  	retcode            OUT NOCOPY  NUMBER,
	p_app_short_name	in varchar2,
	p_set_of_books_id	in varchar2,
        p_period_start_date	in varchar2,
        p_period_end_date	in varchar2,
	p_range_type		in varchar2,
	p_cs_name_from		in varchar2,
	p_cs_name_to		in varchar2,
	p_cs_number_from	in varchar2,
	p_cs_number_to		in varchar2,
	p_currency_code		in varchar2,
        p_rule_id		in varchar2,
	p_inv_amount_limit	in varchar2,
	p_balance_type		in varchar2,
	p_request_id	        in number,
        p_legal_entity_id       in number);

--
-- Main Core Report Specification for AP Turnover Extract Procedure.
--
PROCEDURE JE_AP_TURNOVER_EXTRACT(
	errbuf             OUT NOCOPY  VARCHAR2,
  	retcode            OUT NOCOPY  NUMBER,
	p_app_short_name	in varchar2,
	p_set_of_books_id	in varchar2,
        p_period_start_date	in varchar2,
        p_period_end_date	in varchar2,
	p_range_type		in varchar2,
	p_cs_name_from		in varchar2,
	p_cs_name_to		in varchar2,
	p_cs_number_from	in varchar2,
	p_cs_number_to		in varchar2,
	p_currency_code		in varchar2,
        p_rule_id		in varchar2,
	p_inv_amount_limit	in varchar2,
	p_balance_type		in varchar2,
	p_request_id	        in number,
        p_legal_entity_id       in number);

--
-- Main Core Report Specification for Generic Insert Into the Interface Table Procedure.
--
PROCEDURE GENERIC_INSERT_TO_ITF(
	errbuf             OUT NOCOPY  VARCHAR2,
        retcode            OUT NOCOPY  NUMBER,
	p_request_id  		in number,
        p_cust_sup_name		in varchar2,
        p_cust_sup_number	in varchar2,
        p_tax_payer_id		in varchar2,
        p_vat_registration_number in varchar2,
        p_supplier_site_code	in varchar2,
        p_profession		in varchar2,
        p_address_line1		in varchar2,
        p_address_line2		in varchar2,
	p_address_line3		in varchar2,
        p_city			in varchar2,
        p_state			in varchar2,
        p_zip			in varchar2,
        p_province		in varchar2,
        p_country		in varchar2,
        p_inv_trx_number	in varchar2,
	p_inv_trx_id		in number,
        p_inv_trx_date		in date,
        p_inv_trx_currency_code in varchar2,
        p_inv_trx_amount	in number,
        p_inv_trx_type		in varchar2,
        p_acctd_inv_trx_amount	in number,
        p_cust_sup_type_code	in varchar2,
        p_created_by 		in number,
        p_creation_date		in date,
        p_last_update_date	in date,
        p_last_updated_by	in number,
        p_last_update_login	in number);

END JERX_TO;

 

/
