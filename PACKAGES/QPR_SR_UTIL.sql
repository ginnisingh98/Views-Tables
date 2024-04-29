--------------------------------------------------------
--  DDL for Package QPR_SR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_SR_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPRUTILS.pls 120.3 2008/03/12 12:56:56 amjha ship $ */

/* Public Variables */

g_datamart_tmpl_id number := 1;
g_priceplan_tmpl_id number := 2;

/* Public Functions */

function get_null_pk return    number;
function get_null_desc return  varchar2;
function get_all_scs_pk return number;
function get_all_scs_desc return varchar2;
function get_all_cus_pk return number;
function get_all_cus_desc return varchar2;
function get_all_geo_pk return number;
function get_all_geo_desc return varchar2;
function get_all_org_pk return number;
function get_all_org_desc return varchar2;
function get_all_prd_pk return number;
function get_all_prd_desc return varchar2;
function get_all_rep_pk return number;
function get_all_rep_desc return varchar2;
function get_all_ord_pk return number;
function get_all_ord_desc return VARCHAR2;
function get_all_adj_pk return number;
function get_all_adj_desc return VARCHAR2;
function get_all_dsb_pk return number;
function get_all_dsb_desc return VARCHAR2;
function get_all_vlb_pk return number;
function get_all_vlb_desc return VARCHAR2;
function get_all_mgb_pk return number;
function get_all_mgb_desc return VARCHAR2;
function get_all_oad_pk return number;
function get_all_oad_desc return VARCHAR2;
function get_all_cos_pk return number;
function get_all_cos_desc return VARCHAR2;
function get_cost_type_desc return VARCHAR2;
function get_all_psg_pk return number;
function get_all_psg_desc return varchar2;
function get_all_year_pk return number;
function get_all_year_desc return VARCHAR2;

function dm_parameters_ok return boolean;

FUNCTION get_dimension_desc(p_type varchar2,
                            p_code varchar2) return VARCHAR2;



function set_customer_attr(	p_profile_name IN VARCHAR2,
				p_profile_value IN VARCHAR2,
				p_profile_Level IN VARCHAR2)  return number;

FUNCTION get_customer_id( p_party_id IN NUMBER) return NUMBER ;
function get_internal_customers_desc return VARCHAR2;
function uom_conv(p_uom_code in varchar2,
                  p_item_id  in number, p_master_uom in varchar2
		) return number;

function convert_global_amt(p_curr_code in varchar2,
			    p_date in date,
			  from_ind_flag in varchar2 default 'Y',
                          p_global_curr_code in varchar2 default null)
                          return number;

function get_customer_attribute return varchar2;

function get_dblink(p_instance_id in number) return varchar2;

FUNCTION ods_uom_conv(p_item_id in NUMBER, p_from_uom_code in VARCHAR2,
                      p_to_uom_code in varchar2,
                      p_instance_id in number default null,
                      p_precision in number default null) RETURN NUMBER ;

function get_base_uom(p_item_id in number,
                      p_instance_id in number default null) return varchar2;

function read_parameter(p_para_name in varchar2) return varchar2;

function qpr_convert_amount(p_instance_id in number,
                            p_from_currency in varchar2,
                            p_to_currency in varchar2,
                            p_conversion_date in date,
                            p_conversion_type in varchar2 default null,
                            p_amount in number) return number;

function ods_curr_conversion(p_from_curr_code in varchar2 default null,
                               p_to_curr_code in varchar2,
                               p_conv_type in varchar2 default null,
                               p_date in date,
                               p_instance_id in number)
                               return number;

function get_oad_om_group_pk return varchar2;
function get_oad_om_group_desc return varchar2;

function get_oad_ar_group_pk return varchar2;
function get_oad_ar_group_desc return varchar2;

function get_oad_om_type_pk return varchar2;
function get_oad_om_type_desc return varchar2;

function get_oad_ar_cm_type_pk return varchar2;
function get_oad_ar_cm_type_desc return varchar2;

function get_oad_ar_cd_type_pk return varchar2;
function get_oad_ar_cd_type_desc return varchar2;

function get_oad_group_desc(p_code varchar2) return varchar2;
function get_oad_type_desc(p_code varchar2) return varchar2;

function get_max_date(p_date1 in date, p_date2 in date) return date;

procedure purge_base_tables_data(p_price_plan_id in number);

END QPR_SR_UTIL;

/
