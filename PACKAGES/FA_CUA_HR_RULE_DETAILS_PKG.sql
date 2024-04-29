--------------------------------------------------------
--  DDL for Package FA_CUA_HR_RULE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_HR_RULE_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: FACHRRDMS.pls 120.1.12010000.3 2009/08/20 14:17:32 bridgway ship $ */

Procedure Insert_row (     x_rowid          		in out nocopy varchar2
                         , x_hierarchy_rule_set_id    	in number
                         , x_attribute_name           	in varchar2
			 , x_book_type_code		in varchar2
                         , x_include_hierarchy_flag   	in varchar2
                         , x_include_level            	in varchar2
                         , x_include_asset_catg_life_flag   in varchar2
                         , x_include_catg_end_date_flag in varchar2
                         , x_include_asset_end_date_flag 	in varchar2
                         , x_include_lease_end_date_flag 	in varchar2
                         , x_basis_code			 in varchar2
                         , x_precedence_level		in varchar2
                         , x_override_allowed_flag	in varchar2
                         , x_target_flag		in varchar2
                         , X_CREATION_DATE      	in date
                         , X_CREATED_BY         	in number
                         , X_LAST_UPDATE_DATE   	in date
                         , X_LAST_UPDATED_BY    	in number
                         , X_LAST_UPDATE_LOGIN  	in number
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);

procedure LOCK_ROW (	   x_rowid          		in varchar2
                         , x_hierarchy_rule_set_id    	in number
                         , x_attribute_name           	in varchar2
			 , x_book_type_code		in varchar2
                         , x_include_hierarchy_flag   	in varchar2
                         , x_include_level            	in varchar2
                         , x_include_asset_catg_life_flag   in varchar2
                         , x_include_catg_end_date_flag in varchar2
                         , x_include_asset_end_date_flag in varchar2
                         , x_include_lease_end_date_flag in varchar2
                         , x_basis_code			 in varchar2
                         , x_precedence_level		in varchar2
                         , x_override_allowed_flag	in varchar2
                         , x_target_flag		in varchar2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);



procedure UPDATE_ROW (
   			   x_rowid          		in varchar2
                         , x_hierarchy_rule_set_id    	in number
                         , x_attribute_name           	in varchar2
			 , x_book_type_code		in varchar2
                         , x_include_hierarchy_flag   	in varchar2
                         , x_include_level            	in varchar2
                         , x_include_asset_catg_life_flag   in varchar2
                         , x_include_catg_end_date_flag in varchar2
                         , x_include_asset_end_date_flag in varchar2
                         , x_include_lease_end_date_flag in varchar2
                         , x_basis_code			 in varchar2
                         , x_precedence_level		in varchar2
                         , x_override_allowed_flag	in varchar2
                         , x_target_flag		in varchar2
                         , X_LAST_UPDATE_DATE   	in date
                         , X_LAST_UPDATED_BY    	in number
                         , X_LAST_UPDATE_LOGIN  	in number
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null);


procedure DELETE_ROW (
  x_rowid          			in varchar2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null);

end FA_CUA_HR_RULE_DETAILS_PKG;

/
