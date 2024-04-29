--------------------------------------------------------
--  DDL for Package Body FA_CUA_HR_RULE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_HR_RULE_DETAILS_PKG" AS
/* $Header: FACHRRDMB.pls 120.1.12010000.3 2009/08/20 14:16:43 bridgway ship $ */

Procedure Insert_row (     x_rowid          			in out nocopy varchar2
                         , x_hierarchy_rule_set_id    		in number
                         , x_attribute_name           		in varchar2
			 , x_book_type_code			in varchar2
                         , x_include_hierarchy_flag   		in varchar2
                         , x_include_level            		in varchar2
                         , x_include_asset_catg_life_flag   	in varchar2
                         , x_include_catg_end_date_flag  	in varchar2
                         , x_include_asset_end_date_flag 	in varchar2
                         , x_include_lease_end_date_flag 	in varchar2
                         , x_basis_code			   	in varchar2
                         , x_precedence_level			in varchar2
                         , x_override_allowed_flag		in varchar2
                         , x_target_flag			in varchar2
                         , X_CREATION_DATE      		in date
                         , X_CREATED_BY         		in number
                         , X_LAST_UPDATE_DATE   		in date
                         , X_LAST_UPDATED_BY    		in number
                         , X_LAST_UPDATE_LOGIN  		in number
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)
	is
	   cursor C is select ROWID from FA_HIERARCHY_RULE_DETAILS
         where hierarchy_rule_set_id = X_hierarchy_rule_set_id
	   and attribute_name = x_attribute_name
	   and book_type_code = x_book_type_code ;
    begin
         Insert into FA_HIERARCHY_RULE_DETAILS
			 ( hierarchy_rule_set_id
                         , attribute_name
			 , book_type_code
                         , include_hierarchy_flag
                         , include_level
                         , include_asset_catg_life_flag
                         , include_catg_end_date_flag
                         , include_asset_end_date_flag
                         , include_lease_end_date_flag
                         , basis_code
                         , precedence_level
                         , override_allowed_flag
                         , target_flag
                         , CREATION_DATE
                         , CREATED_BY
                         , LAST_UPDATE_DATE
                         , LAST_UPDATED_BY
                         , LAST_UPDATE_LOGIN   )
		Values (   x_hierarchy_rule_set_id
                         , x_attribute_name
			 , x_book_type_code
                         , x_include_hierarchy_flag
                         , x_include_level
                         , x_include_asset_catg_life_flag
                         , x_include_catg_end_date_flag
                         , x_include_asset_end_date_flag
                         , x_include_lease_end_date_flag
                         , x_basis_code
                         , x_precedence_level
                         , x_override_allowed_flag
                         , x_target_flag
                         , X_CREATION_DATE
                         , X_CREATED_BY
                         , X_LAST_UPDATE_DATE
                         , X_LAST_UPDATED_BY
                         , X_LAST_UPDATE_LOGIN   );
		open c;
  		fetch c into X_ROWID;
  		if (c%notfound) then
    		close c;
    		raise no_data_found;
  		end if;
  		close c;
end INSERT_ROW;




procedure LOCK_ROW (	   x_rowid          		in varchar2
                         , x_hierarchy_rule_set_id    	in number
                         , x_attribute_name           	in varchar2
			 , x_book_type_code		in varchar2
                         , x_include_hierarchy_flag   	in varchar2
                         , x_include_level            	in varchar2
                         , x_include_asset_catg_life_flag   in varchar2
                         , x_include_catg_end_date_flag	in varchar2
                         , x_include_asset_end_date_flag in varchar2
                         , x_include_lease_end_date_flag in varchar2
                         , x_basis_code		   	in varchar2
                         , x_precedence_level		in varchar2
                         , x_override_allowed_flag	in varchar2
                         , x_target_flag		in varchar2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
is
cursor c1 is
select hierarchy_rule_set_id
      	, attribute_name
 	, book_type_code
        , include_hierarchy_flag
        , include_level
        , include_asset_catg_life_flag
        , include_catg_end_date_flag
        , include_asset_end_date_flag
        , include_lease_end_date_flag
        , basis_code
        , precedence_level
        , override_allowed_flag
        , target_flag
from fa_hierarchy_rule_details
where rowid = x_rowid
for update of hierarchy_rule_set_id nowait;
tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;
  if ( (tlinfo.attribute_name = X_attribute_name)
      AND (tlinfo.book_type_code = x_book_type_code)
      AND (tlinfo.include_hierarchy_flag = x_include_hierarchy_flag)
      AND ((tlinfo.include_level = X_include_level)
           OR ((tlinfo.include_level  is null)
               AND (X_include_level is null)))
      AND ((tlinfo.include_asset_catg_life_flag = X_include_asset_catg_life_flag )
           OR ((tlinfo.include_asset_catg_life_flag is null)
               AND (X_include_asset_catg_life_flag is null)))
	AND ((tlinfo.include_catg_end_date_flag = X_include_catg_end_date_flag )
           OR ((tlinfo.include_catg_end_date_flag is null)
               AND (X_include_catg_end_date_flag is null)))
	AND ((tlinfo.include_asset_end_date_flag = X_include_asset_end_date_flag )
           OR ((tlinfo.include_asset_end_date_flag is null)
               AND (X_include_asset_end_date_flag is null)))
	AND ((tlinfo.include_lease_end_date_flag = X_include_lease_end_date_flag )
           OR ((tlinfo.include_lease_end_date_flag is null)
               AND (X_include_lease_end_date_flag is null)))
	AND ((tlinfo.basis_code = X_basis_code )
           OR ((tlinfo.basis_code is null)
               AND (X_basis_code is null)))
	AND ((tlinfo.precedence_level = X_precedence_level )
           OR ((tlinfo.precedence_level is null)
               AND (X_precedence_level is null)))
	AND ((tlinfo.override_allowed_flag = X_override_allowed_flag )
           OR ((tlinfo.override_allowed_flag is null)
               AND (X_override_allowed_flag is null)))
	AND ((tlinfo.target_flag = X_target_flag )
           OR ((tlinfo.target_flag is null)
               AND (X_target_flag is null)))
	) then
        null;
     else
    	  fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    	  app_exception.raise_exception;
     end if;
     return;
end LOCK_ROW;





procedure UPDATE_ROW (
   			   x_rowid          		in varchar2
                         , x_hierarchy_rule_set_id    	in number
                         , x_attribute_name           	in varchar2
			 , x_book_type_code		in varchar2
                         , x_include_hierarchy_flag   	in varchar2
                         , x_include_level            	in varchar2
                         , x_include_asset_catg_life_flag   in varchar2
                         , x_include_catg_end_date_flag	in varchar2
                         , x_include_asset_end_date_flag in varchar2
                         , x_include_lease_end_date_flag in varchar2
                         , x_basis_code			in varchar2
                         , x_precedence_level		in varchar2
                         , x_override_allowed_flag	in varchar2
                         , x_target_flag		in varchar2
                         , X_LAST_UPDATE_DATE   	in date
                         , X_LAST_UPDATED_BY    	in number
                         , X_LAST_UPDATE_LOGIN  	in number
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
  is
  begin
	update fa_hierarchy_rule_details
	set 	  hierarchy_rule_set_id = x_hierarchy_rule_set_id
      		, attribute_name = x_attribute_name
		, book_type_code = x_book_type_code
		, include_hierarchy_flag = x_include_hierarchy_flag
		, include_level = x_include_level
		, include_asset_catg_life_flag = x_include_asset_catg_life_flag
		, include_catg_end_date_flag = x_include_catg_end_date_flag
		, include_asset_end_date_flag = x_include_asset_end_date_flag
		, include_lease_end_date_flag = x_include_lease_end_date_flag
		, basis_code = x_basis_code
		, precedence_level = x_precedence_level
		, override_allowed_flag = x_override_allowed_flag
		, target_flag = x_target_flag
		, LAST_UPDATE_DATE = X_LAST_UPDATE_DATE
		, LAST_UPDATED_BY = X_LAST_UPDATED_BY
		, LAST_UPDATE_LOGIN  = X_LAST_UPDATE_LOGIN
      where rowid = x_rowid;
	if (sql%notfound) then
    		raise no_data_found;
  	end if;
end UPDATE_ROW;



procedure DELETE_ROW (
  x_rowid          			in varchar2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) is
begin
  delete from FA_HIERARCHY_RULE_DETAILS
  where rowid = x_rowid;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end FA_CUA_HR_RULE_DETAILS_PKG;

/
