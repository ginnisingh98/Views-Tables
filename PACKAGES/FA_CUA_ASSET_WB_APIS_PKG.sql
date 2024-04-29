--------------------------------------------------------
--  DDL for Package FA_CUA_ASSET_WB_APIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_ASSET_WB_APIS_PKG" AUTHID CURRENT_USER AS
/* $Header: FACHRAWMS.pls 120.1.12010000.2 2009/07/19 12:31:39 glchen ship $*/

-- Used as a global variable to show info in the Life Derivation Form
g_life_asset_id         number;
g_transaction_id        number;
g_book_type_code        varchar2(30);

FUNCTION Is_CRLFA_Enabled RETURN  Boolean;

Procedure put_book_type_code (v_book_type_code in VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

Procedure put_transaction_id (v_transaction_id in NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

Procedure put_asset_id (v_asset_id in NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

FUNCTION Get_transaction_id RETURN NUMBER;
pragma restrict_references (get_transaction_id,WNPS,WNDS);

Function check_batch_details_exists(x_batch_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
return boolean;

FUNCTION Get_asset_id RETURN NUMBER;

FUNCTION Get_book_type_code RETURN VARCHAR2;

PROCEDURE create_node( x_asset_hierarchy_purpose_id in out nocopy number
	                   , x_asset_hierarchy_id       in out nocopy number
	                   , x_name                     in varchar2
	                   , x_hierarchy_rule_set_id    in out nocopy number
                       , x_parent_hierarchy_id      in out nocopy number
                       , x_asset_id                 in out nocopy number
                       ,x_err_code                  in out nocopy varchar2
		               ,x_err_stage                 in out nocopy varchar2
                        ,x_err_stack                 in out nocopy varchar2  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

Procedure get_asset_parent (x_asset_id in number,
                            x_parent_hierarchy_id in out nocopy number,
                            x_parent_hierarchy_name in out nocopy varchar2,
                            x_asset_purpose_id in out nocopy number,
                            x_asset_purpose_name in out nocopy varchar2,
                            x_purpose_book_type_code in out nocopy varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) ;

Function get_category_name (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2;
pragma restrict_references (get_category_name,WNPS,WNDS);

Function get_lease_number (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2;
pragma restrict_references (get_lease_number,WNPS,WNDS);

Function get_asset_key_name (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2;
pragma restrict_references (get_asset_key_name,WNPS,WNDS);

Function get_location_name (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2;
pragma restrict_references (get_location_name,WNPS,WNDS);

Function get_account_code_name (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2;
pragma restrict_references (get_account_code_name,WNPS,WNDS);

Function get_employee_name (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2;
pragma restrict_references (get_employee_name,WNPS,WNDS);

Function get_employee_number (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2;
pragma restrict_references (get_employee_number,WNPS,WNDS);

Function derive_override_flag(x_rule_set_id in number,
                              x_attribute_name in varchar2,
                              x_book_type_code in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2 ;

Function get_lease_id (x_lease_number in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return number ;

Function get_category_id(x_concatenated_segments in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return number ;

Function get_node_name (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2;
pragma restrict_references (get_node_name,WNPS,WNDS);

Function get_node_level(x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2;
pragma restrict_references (get_node_level,WNPS,WNDS);

Function get_rule_set_name (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2;
pragma restrict_references (get_rule_set_name,WNPS,WNDS);

Function get_asset_number (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2;
pragma restrict_references (get_asset_number,WNPS,WNDS);

FUNCTION GET_PERIOD_END_DATE(X_book_type_code  VARCHAR2,
		             x_date             DATE, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return date ;
pragma restrict_references (GET_PERIOD_END_DATE,WNPS,WNDS);

Procedure get_prorate_date ( x_category_id in number,
                             x_book        in varchar2,
                             x_deprn_start_date in date,
                             x_prorate_date out nocopy date
			     ,x_err_code    in out nocopy varchar2
                             ,x_err_stage   in out nocopy varchar2
                             ,x_err_stack   in out nocopy varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

Procedure get_life_derivation_info(x_asset_id in number,
                                   x_book_type_code varchar2,
                                   x_transaction_id number,
                                   x_derived_from_entity in out nocopy varchar2 ,
                                   x_derived_from_entity_name in out nocopy varchar2,
                                   x_level_number in out nocopy varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) ;

Function check_distribution_match(x_Asset_id in number,
                                  x_book_type_code in varchar2,
                                   x_mode in varchar2 default 'SHOWERR', p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return boolean ;

Procedure remove_adjustments (x_asset_id in number,
                              x_book_type_code in varchar2,
                              x_thid in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

END FA_CUA_ASSET_WB_APIS_PKG;

/
