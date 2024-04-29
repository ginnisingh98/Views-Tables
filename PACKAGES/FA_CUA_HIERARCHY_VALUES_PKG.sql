--------------------------------------------------------
--  DDL for Package FA_CUA_HIERARCHY_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUA_HIERARCHY_VALUES_PKG" AUTHID CURRENT_USER AS
/* $Header: FACHRAAMS.pls 120.1.12010000.3 2009/08/20 14:17:14 bridgway ship $ */

Procedure Insert_row (     x_rowid		in out nocopy varchar2
			 , x_asset_hierarchy_id in out nocopy number
			 , x_book_type_code	in varchar2
			 , x_asset_category_id  in number
			 , x_lease_id   	in number
			 , x_asset_key_ccid     in number
			 , x_serial_number	in varchar2
			 , x_life_end_date	in date
     		 , x_dist_set_id    in number
			 , X_CREATION_DATE	in date
			 , X_CREATED_BY		in number
			 , X_LAST_UPDATE_DATE	in date
			 , X_LAST_UPDATED_BY	in number
			 , X_LAST_UPDATE_LOGIN	in number
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);

   procedure create_attribute(
  -- Arguments required for Public APIs
			  x_err_code		 out nocopy Varchar2
			, x_err_stage    	 out nocopy Varchar2
			, x_err_stack		 out nocopy varchar2
  -- Arguments for Node Creation
			, x_asset_hierarchy_id in out nocopy number
                         , x_book_type_code     in varchar2
                         , x_asset_category_id        in number
                         , x_lease_id           in number
                         , x_asset_key_ccid     in number
                         , x_serial_number      in varchar2
                         , x_life_end_date      in date
                         , X_CREATION_DATE      in date
                         , X_CREATED_BY         in number
                         , X_LAST_UPDATE_DATE   in date
                         , X_LAST_UPDATED_BY    in number
                         , X_LAST_UPDATE_LOGIN  in number
  			, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);

procedure LOCK_ROW (       x_rowid		in varchar2
  			 , x_asset_hierarchy_id	in NUMBER
                         , x_book_type_code     in varchar2
                         , x_asset_category_id in number
                         , x_lease_id           in number
                         , x_asset_key_ccid     in number
                         , x_serial_number      in varchar2
                         , x_life_end_date      in date
                         , x_dist_set_id        in number
			, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);
procedure UPDATE_ROW (     x_rowid		in varchar2
                         , x_book_type_code     in varchar2
                         , x_asset_category_id  in number
                         , x_lease_id           in number
                         , x_asset_key_ccid     in number
                         , x_serial_number      in varchar2
                         , x_life_end_date      in date
                         , x_dist_set_id        in number
                         , X_LAST_UPDATE_DATE   in date
                         , X_LAST_UPDATED_BY    in number
                         , X_LAST_UPDATE_LOGIN  in number
  			, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);

procedure DELETE_ROW (
                         x_rowid      in varchar2
			, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null);

end FA_CUA_HIERARCHY_VALUES_PKG ;

/
