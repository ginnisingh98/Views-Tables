--------------------------------------------------------
--  DDL for Package FA_CUA_HIERARCHY_PURPOSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_HIERARCHY_PURPOSE_PKG" AUTHID CURRENT_USER AS
/* $Header: FACHRHPMS.pls 120.1.12010000.3 2009/08/20 14:18:00 bridgway ship $ */

Procedure Insert_row (     x_rowid          		in out nocopy varchar2
                         , x_asset_hierarchy_purpose_id in out nocopy number
                         , x_name               	in varchar2
			 , x_purpose_type		in varchar2
			 , x_book_type_code		in varchar2
                         , x_default_rule_set_id        in number
                         , X_CREATION_DATE      	in date
                         , X_CREATED_BY         	in number
                         , X_LAST_UPDATE_DATE   	in date
                         , X_LAST_UPDATED_BY    	in number
                         , X_LAST_UPDATE_LOGIN  	in number
                         , x_description          	in varchar2
                         , x_mandatory_asset_flag  	in varchar2
                         , x_rule_set_level    	        in varchar2
			 , x_permissible_levels		in number
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);

procedure LOCK_ROW (       x_asset_hierarchy_purpose_id in number
			 , x_name                       in varchar2
                         , x_purpose_type               in varchar2
                         , x_book_type_code             in varchar2
                         , x_default_rule_set_id        in number
                         , x_description                in varchar2
                         , x_mandatory_asset_flag       in varchar2
                         , x_rule_set_level             in varchar2
			 , x_permissible_levels		in number
		   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);



procedure UPDATE_ROW (
 			   x_rowid                      in out nocopy varchar2
                         , x_asset_hierarchy_purpose_id in  number
                         , x_name                       in varchar2
                         , x_purpose_type               in varchar2
                         , x_book_type_code             in varchar2
                         , x_default_rule_set_id        in number
                         , X_LAST_UPDATE_DATE           in date
                         , X_LAST_UPDATED_BY            in number
                         , X_LAST_UPDATE_LOGIN          in number
                         , x_description                in varchar2
                         , x_mandatory_asset_flag       in varchar2
                         , x_rule_set_level             in varchar2
			 , x_permissible_levels		in number
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null);


procedure DELETE_ROW (
  x_asset_hierarchy_purpose_id in number
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null);

end FA_CUA_HIERARCHY_PURPOSE_PKG;

/
