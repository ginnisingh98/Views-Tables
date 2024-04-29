--------------------------------------------------------
--  DDL for Package OKS_ENT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_ENT_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSREUTS.pls 120.0 2005/05/25 17:45:45 appldev noship $ */

  FUNCTION get_duration_period(
		 p_start_date IN Date
		,p_end_date IN Date
		,inp_type Varchar2) RETURN Varchar2;

  FUNCTION get_contract_amount(p_hdr_id IN Number) RETURN Number;

  FUNCTION get_party(p_hdr_id IN Number) RETURN Varchar2;

  FUNCTION get_billtoshipto(p_hdr_id	IN Number --DEFAULT NULL
				   ,p_line_id	IN Number --DEFAULT NULL
				   ,p_inp_type	IN Varchar2) RETURN Varchar2;

  FUNCTION get_pricelist(p_hdr_id	IN Number --DEFAULT NULL
				,p_line_id	IN Number --DEFAULT NULL
				,p_inp_type	IN Varchar2) RETURN Varchar2;

  FUNCTION get_discount( p_hdr_id	IN Number --DEFAULT NULL
				,p_line_id	IN Number --DEFAULT NULL
                ) RETURN Varchar2;

  FUNCTION	get_acc_rule(p_hdr_id	IN Number
				,p_line_id	IN Number) RETURN Varchar2;

  FUNCTION	get_inv_rule(p_hdr_id	IN Number
				,p_line_id	IN Number) RETURN Varchar2;

  FUNCTION	get_billingprofile(p_hdr_id	IN Number
					,p_line_id	IN Number) RETURN Varchar2;

  FUNCTION	get_billingschedule(p_hdr_id	 IN Number
					 ,p_line_id	 IN Number
					 ,p_inp_type IN Varchar2) RETURN Varchar2;

  FUNCTION	get_renternotes(p_hdr_id	 IN Number
				   ,p_inp_type	 IN Varchar2) RETURN CLOB;

  FUNCTION	get_terms(p_hdr_id	 IN Number
			   ,p_line_id	 IN Number) RETURN Varchar2;


  TYPE l_pdt_rec IS RECORD
	( product_id	Number,
	  product_qty	Number);

  FUNCTION get_product(p_line_id IN Number) RETURN l_pdt_rec;

  FUNCTION get_product(p_line_id IN Number, p_inp_type IN Varchar2) RETURN Varchar2;

  TYPE l_sys_rec IS RECORD
	( system_id		Number,
	  system_name	Varchar2(240));

  FUNCTION	get_system(p_line_id IN Number, p_org_id IN Number) RETURN l_sys_rec;

  FUNCTION	get_system(p_line_id IN Number, p_inp_type IN Varchar2, p_org_id IN Number) RETURN Varchar2;

  TYPE l_inv_rec IS RECORD
	( inv_item_id	Number,
	  item_name		Varchar2(240));

  FUNCTION	get_invitem(p_line_id IN Number, p_organization_id IN Number) RETURN l_inv_rec;

  FUNCTION	get_invitem(p_line_id IN Number, p_inp_type IN Varchar2, p_organization_id IN Number) RETURN Varchar2;

  TYPE l_qtyrate_rec IS RECORD
	(default_amcv_flag	Varchar2(1),
	 default_qty		Number,
	 default_uom		Varchar2(25),
	 default_duration		Number,
	 default_period		Varchar2(25),
	 minimum_qty		Number,
	 minimum_uom		Varchar2(25),
	 minimum_duration		Number,
	 minimum_period		Varchar2(25),
	 fixed_qty			Number,
	 fixed_uom			Varchar2(25),
	 fixed_duration		Number,
	 fixed_period		Varchar2(25),
	 level_flag			Varchar2(1));

  FUNCTION get_qtyrate_rule(p_line_id IN Number) RETURN l_qtyrate_rec;

  FUNCTION get_taxrule(p_hdr_id IN Number, p_inp_type IN Varchar2) RETURN Varchar2;

  FUNCTION get_convrule(p_hdr_id IN Number) RETURN Varchar2;

  FUNCTION get_agreement(p_hdr_id IN Number) RETURN Number;

  TYPE l_party_rec IS RECORD (party_id Number, party_name Varchar2(500));
  FUNCTION get_clvl_party(p_line_id IN Number) RETURN l_party_rec;

  TYPE l_cust_rec IS RECORD (customer_id Number, customer_name Varchar2(500));
  FUNCTION get_clvl_customer(p_line_id IN Number) RETURN l_cust_rec;

  TYPE l_site_rec IS RECORD (site_id Number, site_name Varchar2(500));
  FUNCTION get_clvl_site(p_line_id IN Number, p_org_id IN Number) RETURN l_site_rec;

  FUNCTION get_coverage_type(p_line_id IN Number) Return Varchar2;

  FUNCTION get_billrate(p_rate_code IN VARCHAR2) Return Varchar2;

END OKS_ENT_UTIL_PVT;

 

/
