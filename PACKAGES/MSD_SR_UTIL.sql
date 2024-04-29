--------------------------------------------------------
--  DDL for Package MSD_SR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_SR_UTIL" AUTHID CURRENT_USER AS
/* $Header: msdutils.pls 120.6 2006/07/04 12:05:32 sjagathe noship $ */


/* Public Functions */

--function org(p_org_id in NUMBER) return VARCHAR2;
function item(p_item_id in NUMBER, p_org_id in NUMBER) return VARCHAR2;
function cust(p_cust_id in NUMBER) return VARCHAR2;
function schn(p_schn_id in VARCHAR2) return VARCHAR2;
function srep(p_srep_id in NUMBER, p_org_id in NUMBER) return VARCHAR2;
function uom_conv(uom_code varchar2, item_id number) return number;
function get_item_cost(p_item_id in number, p_org_id in number) return number;
function convert_global_amt(p_curr_code in varchar2, p_date in date) return number;
function shipped_date(p_departure_id in number) return date;
function booked_date(p_header_id in number) return date;
function location(p_loc_id in number) return varchar2;
function Master_Organization return number;
function item_organization return varchar2; /* Bug# 4157588 */
function get_category_set_id return number;
function get_eol_category_set_id return number;
function get_conversion_type return varchar2;
function get_customer_attr return varchar2;



function get_null_pk return    number;
function get_null_desc return  varchar2;
function get_all_scs_pk return number;
function get_all_scs_desc return varchar2;
function get_all_geo_pk return number;
function get_all_geo_desc return varchar2;
function get_all_org_pk return number;
function get_all_org_desc return varchar2;
function get_all_prd_pk return number;
function get_all_prd_desc return varchar2;
function get_all_rep_pk return number;
function get_all_rep_desc return varchar2;

function get_all_dcs_pk return number;
function get_all_dcs_desc return VARCHAR2;


FUNCTION get_dimension_desc(p_type varchar2,
                            p_code varchar2) return VARCHAR2;



function on_hold(p_header_id in number, p_line_id in number) return varchar2;

FUNCTION IS_ITEM_OPTIONAL_FOR_LVL(p_component_item_id  in  NUMBER) RETURN NUMBER;

/* Bug# 4157588 */
FUNCTION IS_ITEM_OPTIONAL_FOR_LVL(p_component_item_id  in  NUMBER, p_org_id in NUMBER) RETURN NUMBER;

FUNCTION IS_ITEM_OPTIONAL_FOR_FACT(p_component_item_id  in  NUMBER,
                                   p_component_sequence_id in NUMBER,
                                   p_parent_line_id        in NUMBER) RETURN NUMBER;

FUNCTION FIND_PARENT_ITEM (p_link_to_line_id  in  NUMBER,
                           p_include_class    in  varchar2) RETURN NUMBER;


/*
FUNCTION FIND_PARENT_FOR_PTO(  p_comp_seq_id     IN NUMBER,
                               p_link_to_line_id IN NUMBER,
                               p_include_class   IN VARCHAR2) RETURN NUMBER;
*/

FUNCTION IS_PRODUCT_FAMILY_FORECASTABLE (p_org_id  in  NUMBER,
                                         p_inventory_item_id in  NUMBER,
                                         p_check_optional in NUMBER) RETURN NUMBER;

FUNCTION CONFIG_ITEM_EXISTS ( p_header_id IN NUMBER,
                              p_org_id IN NUMBER,
                              p_ato_line_id IN NUMBER) RETURN NUMBER;

FUNCTION get_zone_attr return varchar2;

function set_customer_attr(	p_profile_name IN VARCHAR2,
				p_profile_value IN VARCHAR2,
				p_profile_Level IN VARCHAR2)  return number;

FUNCTION get_sr_zone_pk ( p_location_id IN NUMBER,
			  p_zone_attr IN VARCHAR2) RETURN NUMBER;

FUNCTION get_service_req_org_id (p_txn_source_id IN NUMBER) return NUMBER;

FUNCTION get_service_req_acct_id (p_txn_source_id IN NUMBER,
                                  p_cust_filter in VARCHAR2) return NUMBER;

FUNCTION get_service_req_zone_id (p_txn_source_id IN NUMBER,
                                  p_zone_filter in VARCHAR2) return NUMBER;

FUNCTION is_txn_depot_repair(p_txn_source_id IN NUMBER) return VARCHAR2;


FUNCTION get_customer_id( p_party_id IN NUMBER) return NUMBER ;

FUNCTION dp_enabled_item (p_inventory_item_id in NUMBER,
                          p_organization_id in NUMBER) return NUMBER; --jarorad

 /*vinekuma */
/*Is used in Liability Analysis Views  */
function get_all_sup_pk return number;
function get_all_sup_desc return varchar2;
function get_all_auth_pk return number;
function get_all_auth_desc return varchar2;
/*vinekuma */

function get_suppliers_pk return number;      --jarorad
function get_suppliers_desc return VARCHAR2;  --jarorad
function get_internal_customers_desc return VARCHAR2;

FUNCTION get_onhand_quantity(
                             p_organization_id in number,
                             p_inventory_item_id in number,
                             p_transaction_date in date
                           ) return number;

/* Bug# 5367784 */

FUNCTION get_sr_custzone_pk ( p_location_id IN NUMBER,
                              p_customer_id IN NUMBER,
                 	      p_zone_attr   IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_sr_custzone_desc ( p_location_id   IN NUMBER,
                                p_customer_name IN VARCHAR2,
			        p_zone_attr     IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_sr_zone_pk1 ( p_location_id IN NUMBER,
			  p_zone_attr   IN VARCHAR2) RETURN NUMBER;

FUNCTION get_sr_zone_desc ( p_location_id IN NUMBER,
			    p_zone_attr   IN VARCHAR2) RETURN VARCHAR2;

END MSD_SR_UTIL;

 

/
