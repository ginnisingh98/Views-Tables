--------------------------------------------------------
--  DDL for Package Body FA_CUA_HIERARCHY_PURPOSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_HIERARCHY_PURPOSE_PKG" AS
/* $Header: FACHRHPMB.pls 120.1.12010000.3 2009/08/20 14:17:23 bridgway ship $ */

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
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)
is
 cursor C is select ROWID from FA_ASSET_HIERARCHY_PURPOSE
      where asset_hierarchy_purpose_id = X_asset_hierarchy_purpose_id ;

      CURSOR C1 is Select FA_ASSET_HIERARCHY_PURPOSE_S.nextval from sys.dual;
    begin
     if X_asset_hierarchy_purpose_id is null then
        open C1;
        fetch C1 into X_asset_hierarchy_purpose_id ;
        close C1;
     end if;
     insert into FA_ASSET_HIERARCHY_PURPOSE
    (      asset_hierarchy_purpose_id
         , name
	 , purpose_type
         , book_type_code
         , default_rule_set_id
         , CREATION_DATE
         , CREATED_BY
         , LAST_UPDATE_DATE
         , LAST_UPDATED_BY
         , LAST_UPDATE_LOGIN
         , description
         , mandatory_asset_flag
         , rule_set_level
	 , permissible_levels
    )Values
   (	   x_asset_hierarchy_purpose_id
         , x_name
         , x_purpose_type
         , x_book_type_code
         , x_default_rule_set_id
         , x_CREATION_DATE
         , x_CREATED_BY
         , x_LAST_UPDATE_DATE
         , x_LAST_UPDATED_BY
         , x_LAST_UPDATE_LOGIN
         , x_description
         , x_mandatory_asset_flag
         , x_rule_set_level
	 , x_permissible_levels
   );
     open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
end INSERT_ROW;



procedure LOCK_ROW (       x_asset_hierarchy_purpose_id in number
			 , x_name                       in varchar2
                         , x_purpose_type               in varchar2
                         , x_book_type_code             in varchar2
                         , x_default_rule_set_id        in number
                         , x_description                in varchar2
                         , x_mandatory_asset_flag       in varchar2
                         , x_rule_set_level             in varchar2
			 , x_permissible_levels		in number
		   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)is
  cursor c1 is select
  name
, purpose_type
, book_type_code
, default_rule_set_id
, description
, mandatory_asset_flag
, rule_set_level
, permissible_levels
  from FA_ASSET_HIERARCHY_PURPOSE
    where asset_hierarchy_purpose_id = x_asset_hierarchy_purpose_id
    for update of asset_hierarchy_purpose_id nowait;
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
  if ( (tlinfo.NAME = X_NAME)
      AND (tlinfo.purpose_type = x_purpose_type)
      AND (tlinfo.book_type_code = x_book_type_code)
      AND (tlinfo.default_rule_set_id = x_default_rule_set_id)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
      AND ((tlinfo.mandatory_asset_flag = X_mandatory_asset_flag )
           OR ((tlinfo.mandatory_asset_flag  is null)
               AND (X_mandatory_asset_flag  is null)))
      AND (tlinfo.rule_set_level = x_rule_set_level)
      AND ((tlinfo.permissible_levels = X_permissible_levels )
           OR ((tlinfo.permissible_levels  is null)
               AND (X_permissible_levels  is null)))
     )then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;



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
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)
is
begin
   update FA_ASSET_HIERARCHY_PURPOSE
set
        name = x_name,
	purpose_type = x_purpose_type,
        book_type_code = x_book_type_code,
        default_rule_set_id  = x_default_rule_set_id,
        description = x_description,
        mandatory_asset_flag = x_mandatory_asset_flag,
        rule_set_level = x_rule_set_level,
	permissible_levels = x_permissible_levels
 where asset_hierarchy_purpose_id = x_asset_hierarchy_purpose_id;
if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


procedure DELETE_ROW (
  x_asset_hierarchy_purpose_id in number
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)
is
 begin
  delete from FA_ASSET_HIERARCHY_PURPOSE
  where asset_hierarchy_purpose_id = X_asset_hierarchy_purpose_id;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


end FA_CUA_HIERARCHY_PURPOSE_PKG;

/
