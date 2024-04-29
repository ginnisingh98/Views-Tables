--------------------------------------------------------
--  DDL for Package Body FA_CUA_HIERARCHY_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_HIERARCHY_VALUES_PKG" AS
/* $Header: FACHRAAMB.pls 120.1.12010000.3 2009/08/20 14:16:15 bridgway ship $ */

Procedure Insert_row (     x_rowid		in out nocopy varchar2
			 , x_asset_hierarchy_id in out nocopy number
			 , x_book_type_code	in varchar2
			 , x_asset_category_id  in number
			 , x_lease_id   	in number
			 , x_asset_key_ccid in number
			 , x_serial_number	in varchar2
			 , x_life_end_date	in date
             , x_dist_set_id    in number
			 , X_CREATION_DATE	in date
			 , X_CREATED_BY		in number
			 , X_LAST_UPDATE_DATE	in date
			 , X_LAST_UPDATED_BY	in number
			 , X_LAST_UPDATE_LOGIN	in number
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)
   is
    Cursor C1 is Select ROWID from FA_ASSET_HIERARCHY_VALUES
    where asset_hierarchy_id = x_asset_hierarchy_id
    and book_type_code = x_book_type_code;
   begin
    insert into FA_ASSET_HIERARCHY_VALUES
                     (     asset_hierarchy_id
                         , book_type_code
                         , asset_category_id
                         , lease_id
                         , asset_key_ccid
                         , serial_number
                         , life_end_date
                         , dist_set_id
                         , CREATION_DATE
                         , CREATED_BY
                         , LAST_UPDATE_DATE
                         , LAST_UPDATED_BY
                         , LAST_UPDATE_LOGIN
                      ) Values
                      (   x_asset_hierarchy_id
                         , x_book_type_code
                         , x_asset_category_id
                         , x_lease_id
                         , x_asset_key_ccid
                         , x_serial_number
                         , x_life_end_date
                         , x_dist_set_id
                         , X_CREATION_DATE
                         , X_CREATED_BY
                         , X_LAST_UPDATE_DATE
                         , X_LAST_UPDATED_BY
                         , X_LAST_UPDATE_LOGIN
			);

	Open C1;
	fetch C1 into x_rowid;
        if (C1%NOTFOUND) then
          close C1;
          raise no_data_found;
        end if;
        close C1;
   end INSERT_ROW;
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
  			, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)
  is
   begin
    null;
  end create_attribute;

procedure LOCK_ROW (       x_rowid		in varchar2
  			             , x_asset_hierarchy_id	in NUMBER
                         , x_book_type_code     in varchar2
                         , x_asset_category_id in number
                         , x_lease_id           in number
                         , x_asset_key_ccid     in number
                         , x_serial_number      in varchar2
                         , x_life_end_date      in date
                         , x_dist_set_id        in number
			, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)
 is
   Cursor C1 is
   Select book_type_code
        , asset_category_id
        , lease_id
        , asset_key_ccid
        , serial_number
        , life_end_date
        , dist_set_id
   from FA_ASSET_HIERARCHY_VALUES
   where rowid = x_rowid
   for update nowait;
   tlinfo C1%ROWTYPE;
 begin
   open C1;
   fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;
  if (
          (tlinfo.book_type_code = x_book_type_code)
      AND ((tlinfo.asset_category_id = x_asset_category_id)
           OR ((tlinfo.asset_category_id is null)
                AND (x_asset_category_id is null)))
      AND ((tlinfo.lease_id = X_lease_id)
           OR ((tlinfo.lease_id is null)
               AND (X_lease_id is null)))
      AND ((tlinfo.asset_key_ccid = X_asset_key_ccid)
           OR ((tlinfo.asset_key_ccid is null)
               AND (X_asset_key_ccid is null)))
      AND ((tlinfo.serial_number = X_serial_number)
           OR ((tlinfo.serial_number is null)
               AND (X_serial_number is null)))
      AND ((tlinfo.life_end_date = X_life_end_date)
           OR ((tlinfo.life_end_date is null)
               AND (X_life_end_date is null)))
      AND ((tlinfo.dist_set_id = X_dist_set_id)
           OR ((tlinfo.dist_set_id is null)
               AND (X_dist_set_id is null)))
    ) then
      null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
			               x_rowid 		        in varchar2
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
  			, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)
is
begin
  update FA_ASSET_HIERARCHY_VALUES
  set  book_type_code = x_book_type_code
     , asset_category_id = x_asset_category_id
     , lease_id = x_lease_id
     , asset_key_ccid = x_asset_key_ccid
     , serial_number = x_serial_number
     , life_end_date = x_life_end_date
     , dist_set_id   = x_dist_set_id
     , LAST_UPDATE_DATE = X_LAST_UPDATE_DATE
     , LAST_UPDATED_BY = X_LAST_UPDATED_BY
     , LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where rowid = x_rowid;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
			  x_rowid 	in VARCHAR2
			, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)
is
begin
 delete from FA_ASSET_HIERARCHY_VALUES
 where rowid = x_rowid;
 if (sql%notfound) then
    raise no_data_found;
 end if;
end DELETE_ROW;


end FA_CUA_HIERARCHY_VALUES_PKG ;

/
