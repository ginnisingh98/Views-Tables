--------------------------------------------------------
--  DDL for Package JG_ZZ_PTCE_DT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_PTCE_DT_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzztoapntrls.pls 120.5.12010000.2 2009/03/19 13:58:09 vkejriwa ship $*/

	p_reporting_entity_id	number;
	p_dec_type varchar2(1);
	p_fiscal_year	number;
	gd_period_start_date	date;
	gd_period_end_date	date;
	gv_repent_id_number	varchar2(30);
	gv_repent_name	varchar2(240);
	gv_repent_address_line_1	varchar2(240);
	gv_repent_address_line_2	varchar2(240);
	gv_repent_address_line_3	varchar2(240);
	gv_repent_town_or_city	varchar2(30);
	gv_repent_postal_code	varchar2(30);
	gv_repent_phone_number	varchar2(60);
	gv_currency_code	varchar2(60);
	gv_tax_reg_num	number;
	gv_name	varchar2(30);
	P_conc_request_id	number;
	P_called_from	varchar2(32767);
	gn_thousands	number;
	gv_vat_country_code	varchar2(15);
	p_min_inv_amt	number;
	gv_repent_country	varchar2(60);
	gv_vat_reg_num	varchar2(32767);
	gn_legal_entity_id	varchar2(240);
	gv_country	varchar2(32767);
	gv_tax_office_location	varchar2(240);
	gv_tax_office_number	varchar2(240);
	gv_tax_office_code	varchar2(240);
	gv_repent_trn	varchar2(50);
	gv_entity_identifier varchar2(600);
	gv_chart_of_accounts_id number(15);
	gv_ledger_id number(15);
	gv_balancing_segment_value varchar2(25);
	function BeforeReport return boolean  ;
	function get_bsv(ccid number) return varchar2;
	function get_gd_period_end_date return date;
	function get_gn_thousands return number;
	function get_gv_vat_country_code return varchar2;
	function get_gv_currency_code return  varchar2;
	function get_gv_repent_country return  varchar2;
	function get_gv_vat_reg_num return varchar2;
	function get_gv_repent_trn return varchar2;
	function get_gv_repent_name return varchar2;
	function get_gv_repent_address_line_1 return varchar2;
	function get_gv_repent_address_line_2 return varchar2;
	function get_gv_repent_address_line_3 return varchar2;
	function get_gv_repent_town_or_city return varchar2;
	function get_gv_repent_postal_code return varchar2;
	function get_gv_country return varchar2;
	function get_gv_repent_id_number return varchar2;
	function get_gv_tax_office_location return varchar2;
	function get_gv_tax_office_number return varchar2;
	function get_gv_tax_office_code return varchar2;
	function get_gv_repent_phone_number return varchar2;
	function get_gv_entity_identifier return varchar2;
	function get_item_tax_code_id(inv_id number,inv_dist_id number,tax_rate_id number) return number;
	END JG_ZZ_PTCE_DT_PKG;

/
