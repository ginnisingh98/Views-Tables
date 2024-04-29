--------------------------------------------------------
--  DDL for Package Body FA_CEILINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CEILINGS_PKG" as
/* $Header: faxiceib.pls 120.6.12010000.2 2009/07/19 13:20:25 glchen ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CEILING_NAME in VARCHAR2,
  X_START_DATE in DATE,
  X_YEAR_OF_LIFE in NUMBER,
  X_END_DATE in DATE,
  X_LIMIT in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

  CURSOR C is SELECT rowid FROM fa_ceilings
              WHERE  ceiling_name = X_Ceiling_Name
              AND    start_date   = X_Start_Date
              AND    nvl (year_of_life, -9999) = nvl (X_Year_Of_Life, -9999);

begin

  INSERT INTO fa_ceilings (
	ceiling_name,
	start_date,
	year_of_life,
	end_date,
	limit,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute_category_code,
	creation_date,
	created_by,
	last_update_date,
	last_updated_by,
	last_update_login
  ) VALUES (
	X_Ceiling_Name,
	X_Start_Date,
	X_Year_Of_Life,
	X_End_Date,
	X_Limit,
	X_Attribute1,
	X_Attribute2,
	X_Attribute3,
	X_Attribute4,
	X_Attribute5,
	X_Attribute6,
	X_Attribute7,
	X_Attribute8,
	X_Attribute9,
	X_Attribute10,
	X_Attribute11,
	X_Attribute12,
	X_Attribute13,
	X_Attribute14,
	X_Attribute15,
	X_Attribute_Category_Code,
	X_Creation_Date,
	X_Created_By,
	X_Last_Update_Date,
	X_Last_Updated_By,
	X_Last_Update_Login
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
     CLOSE C;
     Raise NO_DATA_FOUND;
  end if;
  CLOSE C;

exception
  when others then
        fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_ceilings_pkg.insert_row', p_log_level_rec => p_log_level_rec);
        raise;


end INSERT_ROW;

procedure LOCK_ROW (
  X_CEILING_NAME in VARCHAR2,
  X_START_DATE in DATE,
  X_YEAR_OF_LIFE in NUMBER,
  X_END_DATE in DATE,
  X_LIMIT in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

  CURSOR C is SELECT ceiling_name,
                     start_date,
                     year_of_life,
                     end_date,
                     limit,
                     attribute1,
                     attribute2,
                     attribute3,
                     attribute4,
                     attribute5,
                     attribute6,
                     attribute7,
                     attribute8,
                     attribute9,
                     attribute10,
                     attribute11,
                     attribute12,
                     attribute13,
                     attribute14,
                     attribute15,
                     attribute_category_code
              FROM   fa_ceilings
              WHERE  ceiling_name = X_Ceiling_Name
              AND    start_date   = X_Start_Date
              AND    nvl (year_of_life, -9999) = nvl (X_Year_Of_Life, -9999)
              FOR UPDATE of ceiling_name, start_date, year_of_life NOWAIT;
  Recinfo C%ROWTYPE;

begin

  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
  end if;
  CLOSE C;
  if (
          (Recinfo.Ceiling_Name = X_Ceiling_Name)
      AND (Recinfo.Start_Date = X_Start_Date)
      AND ((Recinfo.End_Date = X_End_Date)
          OR ((Recinfo.End_Date IS NULL)
          AND (X_End_Date IS NULL)))
      AND ((Recinfo.Year_Of_Life = X_Year_Of_Life)
          OR ((Recinfo.Year_Of_Life IS NULL)
          AND (X_Year_Of_Life IS NULL)))
      AND (Recinfo.Limit = X_Limit)
      AND ((Recinfo.Attribute1 = X_Attribute1)
          OR ((Recinfo.Attribute1 IS NULL)
          AND (X_Attribute1 IS NULL)))
      AND ((Recinfo.Attribute2 = X_Attribute2)
          OR ((Recinfo.Attribute2 IS NULL)
          AND (X_Attribute2 IS NULL)))
      AND ((Recinfo.Attribute3 = X_Attribute3)
          OR ((Recinfo.Attribute3 IS NULL)
          AND (X_Attribute3 IS NULL)))
      AND ((Recinfo.Attribute4 = X_Attribute4)
          OR ((Recinfo.Attribute4 IS NULL)
          AND (X_Attribute4 IS NULL)))
      AND ((Recinfo.Attribute5 = X_Attribute5)
          OR ((Recinfo.Attribute5 IS NULL)
          AND (X_Attribute5 IS NULL)))
      AND ((Recinfo.Attribute6 = X_Attribute6)
          OR ((Recinfo.Attribute6 IS NULL)
          AND (X_Attribute6 IS NULL)))
      AND ((Recinfo.Attribute7 = X_Attribute7)
          OR ((Recinfo.Attribute7 IS NULL)
          AND (X_Attribute7 IS NULL)))
      AND ((Recinfo.Attribute8 = X_Attribute8)
          OR ((Recinfo.Attribute8 IS NULL)
          AND (X_Attribute8 IS NULL)))
      AND ((Recinfo.Attribute9 = X_Attribute9)
          OR ((Recinfo.Attribute9 IS NULL)
          AND (X_Attribute9 IS NULL)))
      AND ((Recinfo.Attribute10 = X_Attribute10)
          OR ((Recinfo.Attribute10 IS NULL)
          AND (X_Attribute10 IS NULL)))
      AND ((Recinfo.Attribute11 = X_Attribute11)
          OR ((Recinfo.Attribute11 IS NULL)
          AND (X_Attribute11 IS NULL)))
      AND ((Recinfo.Attribute12 = X_Attribute12)
          OR ((Recinfo.Attribute12 IS NULL)
          AND (X_Attribute12 IS NULL)))
      AND ((Recinfo.Attribute13 = X_Attribute13)
          OR ((Recinfo.Attribute13 IS NULL)
          AND (X_Attribute13 IS NULL)))
      AND ((Recinfo.Attribute14 = X_Attribute14)
          OR ((Recinfo.Attribute14 IS NULL)
          AND (X_Attribute14 IS NULL)))
      AND ((Recinfo.Attribute15 = X_Attribute15)
          OR ((Recinfo.Attribute15 IS NULL)
          AND (X_Attribute15 IS NULL)))
      AND ((Recinfo.Attribute_Category_Code = X_Attribute_Category_Code)
          OR ((Recinfo.Attribute_Category_Code IS NULL)
          AND (X_Attribute_Category_Code IS NULL)))
     ) then
      return;
  else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
  end if;

end LOCK_ROW;

procedure UPDATE_ROW (
  X_CEILING_NAME in VARCHAR2,
  X_START_DATE in DATE,
  X_YEAR_OF_LIFE in NUMBER,
  X_END_DATE in DATE,
  X_LIMIT in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

begin

  UPDATE fa_ceilings
  SET    ceiling_name = X_Ceiling_Name,
         start_date = X_Start_Date,
         end_date = X_End_Date,
         year_of_life = X_Year_Of_Life,
         limit = X_Limit,
         attribute1 = X_Attribute1,
         attribute2 = X_Attribute2,
         attribute3 = X_Attribute3,
         attribute4 = X_Attribute4,
         attribute5 = X_Attribute5,
         attribute6 = X_Attribute6,
         attribute7 = X_Attribute7,
         attribute8 = X_Attribute8,
         attribute9 = X_Attribute9,
         attribute10 = X_Attribute10,
         attribute11 = X_Attribute11,
         attribute12 = X_Attribute12,
         attribute13 = X_Attribute13,
         attribute14 = X_Attribute14,
         attribute15 = X_Attribute15,
         last_update_date = X_Last_Update_Date,
         last_updated_by = X_Last_Updated_By,
         last_update_login = X_Last_Update_Login
  WHERE  ceiling_name = X_Ceiling_Name
  AND    start_date   = X_Start_Date
  AND    nvl (year_of_life, -9999) = nvl (X_Year_Of_Life, -9999);

  if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
  end if;

  exception
    when others then
        fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_ceilings_pkg.update_row', p_log_level_rec => p_log_level_rec);
        raise;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_CEILING_NAME in VARCHAR2,
  X_START_DATE in DATE,
  X_YEAR_OF_LIFE in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

begin

  DELETE FROM fa_ceilings
  WHERE  ceiling_name = X_Ceiling_Name
  AND    start_date   = X_Start_Date
  AND    nvl (year_of_life, -9999) = nvl (X_Year_Of_Life, -9999);

  if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
  end if;

  exception
    when others then
        fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_ceilings_pkg.delete_row', p_log_level_rec => p_log_level_rec);
        raise;

end DELETE_ROW;

procedure LOAD_ROW (
  X_CEILING_NAME in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_YEAR_OF_LIFE in NUMBER,
  X_OWNER in VARCHAR2,
  X_LIMIT in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

  h_record_exists       number(15);

  user_id               number;
  row_id                varchar2(64);

begin

  if (X_Owner = 'SEED') then
     user_id := 1;
  else
     user_id := 0;
  end if;

  select count(*)
  into   h_record_exists
  from   fa_ceilings
  where  ceiling_name = X_Ceiling_Name
  and    start_date = X_Start_Date
  and    nvl (year_of_life, -9999) = nvl (X_Year_Of_Life, -9999);


  if (h_record_exists > 0) then
     fa_ceilings_pkg.update_row (
	X_Ceiling_Name			=> X_Ceiling_Name,
	X_Start_Date			=> X_Start_Date,
	X_End_Date			=> X_End_Date,
	X_Year_Of_Life			=> X_Year_Of_Life,
	X_Limit				=> X_Limit,
	X_Attribute1			=> X_Attribute1,
	X_Attribute2			=> X_Attribute2,
	X_Attribute3			=> X_Attribute3,
	X_Attribute4			=> X_Attribute4,
	X_Attribute5			=> X_Attribute5,
	X_Attribute6			=> X_Attribute6,
	X_Attribute7			=> X_Attribute7,
	X_Attribute8			=> X_Attribute8,
	X_Attribute9			=> X_Attribute9,
	X_Attribute10			=> X_Attribute10,
	X_Attribute11			=> X_Attribute11,
	X_Attribute12			=> X_Attribute12,
	X_Attribute13			=> X_Attribute13,
	X_Attribute14			=> X_Attribute14,
	X_Attribute15			=> X_Attribute15,
	X_Attribute_Category_Code	=> X_Attribute_Category_Code,
	X_Last_Update_Date		=> sysdate,
	X_Last_Updated_By		=> user_id,
	X_Last_Update_Login		=> 0
     , p_log_level_rec => p_log_level_rec);
  else
     fa_ceilings_pkg.insert_row (
	X_Rowid				=> row_id,
	X_Ceiling_Name			=> X_Ceiling_Name,
	X_Start_Date			=> X_Start_Date,
	X_End_Date			=> X_End_Date,
	X_Year_Of_Life			=> X_Year_Of_Life,
	X_Limit				=> X_Limit,
	X_Attribute1			=> X_Attribute1,
	X_Attribute2			=> X_Attribute2,
	X_Attribute3			=> X_Attribute3,
	X_Attribute4			=> X_Attribute4,
	X_Attribute5			=> X_Attribute5,
	X_Attribute6			=> X_Attribute6,
	X_Attribute7			=> X_Attribute7,
	X_Attribute8			=> X_Attribute8,
	X_Attribute9			=> X_Attribute9,
	X_Attribute10			=> X_Attribute10,
	X_Attribute11			=> X_Attribute11,
	X_Attribute12			=> X_Attribute12,
	X_Attribute13			=> X_Attribute13,
	X_Attribute14			=> X_Attribute14,
	X_Attribute15			=> X_Attribute15,
	X_Attribute_Category_Code	=> X_Attribute_Category_Code,
	X_Creation_Date			=> sysdate,
	X_Created_By			=> user_id,
	X_Last_Update_Date		=> sysdate,
	X_Last_Updated_By		=> user_id,
	X_Last_Update_Login		=> 0
     , p_log_level_rec => p_log_level_rec);
  end if;

exception
  when others then
       FA_STANDARD_PKG.RAISE_ERROR(
                      CALLED_FN => 'fa_ceilings_pkg.load_row',
                      CALLING_FN => 'upload fa_ceilings', p_log_level_rec => p_log_level_rec);

end LOAD_ROW;

/*Bug 8355119 overloading function for release specific signatures*/
procedure LOAD_ROW (
  X_CUSTOM_MODE in VARCHAR2,
  X_CEILING_NAME in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_YEAR_OF_LIFE in NUMBER,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LIMIT in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2,
  p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) is

  h_record_exists       number(15);

  user_id               number;
  row_id                varchar2(64);

  db_last_updated_by    number;
  db_last_update_date   date;

begin

  user_id := fnd_load_util.owner_id (X_Owner);

  select count(*)
  into   h_record_exists
  from   fa_ceilings
  where  ceiling_name = X_Ceiling_Name
  and    start_date = X_Start_Date
  and    nvl (year_of_life, -9999) = nvl (X_Year_Of_Life, -9999);

  if (h_record_exists > 0) then

     select last_updated_by, last_update_date
     into   db_last_updated_by, db_last_update_date
     from   fa_ceilings
     where  ceiling_name = X_Ceiling_Name
     and    start_date = X_Start_Date
     and    nvl (year_of_life, -9999) = nvl (X_Year_Of_Life, -9999);

     if (fnd_load_util.upload_test(user_id, x_last_update_date,
                                   db_last_updated_by, db_last_update_date,
                                   X_CUSTOM_MODE)) then

        fa_ceilings_pkg.update_row (
           X_Ceiling_Name              => X_Ceiling_Name,
           X_Start_Date                => X_Start_Date,
           X_End_Date                  => X_End_Date,
           X_Year_Of_Life              => X_Year_Of_Life,
           X_Limit                     => X_Limit,
           X_Attribute1                => X_Attribute1,
           X_Attribute2                => X_Attribute2,
           X_Attribute3                => X_Attribute3,
           X_Attribute4                => X_Attribute4,
           X_Attribute5                => X_Attribute5,
           X_Attribute6                => X_Attribute6,
           X_Attribute7                => X_Attribute7,
           X_Attribute8                => X_Attribute8,
           X_Attribute9                => X_Attribute9,
           X_Attribute10               => X_Attribute10,
           X_Attribute11               => X_Attribute11,
           X_Attribute12               => X_Attribute12,
           X_Attribute13               => X_Attribute13,
           X_Attribute14               => X_Attribute14,
           X_Attribute15               => X_Attribute15,
           X_Attribute_Category_Code   => X_Attribute_Category_Code,
           X_Last_Update_Date		=> sysdate,
           X_Last_Updated_By		=> user_id,
           X_Last_Update_Login		=> 0
           ,p_log_level_rec => p_log_level_rec);
     end if;
  else
     fa_ceilings_pkg.insert_row (
	X_Rowid				=> row_id,
	X_Ceiling_Name			=> X_Ceiling_Name,
	X_Start_Date			=> X_Start_Date,
	X_End_Date			=> X_End_Date,
	X_Year_Of_Life			=> X_Year_Of_Life,
	X_Limit				=> X_Limit,
	X_Attribute1			=> X_Attribute1,
	X_Attribute2			=> X_Attribute2,
	X_Attribute3			=> X_Attribute3,
	X_Attribute4			=> X_Attribute4,
	X_Attribute5			=> X_Attribute5,
	X_Attribute6			=> X_Attribute6,
	X_Attribute7			=> X_Attribute7,
	X_Attribute8			=> X_Attribute8,
	X_Attribute9			=> X_Attribute9,
	X_Attribute10			=> X_Attribute10,
	X_Attribute11			=> X_Attribute11,
	X_Attribute12			=> X_Attribute12,
	X_Attribute13			=> X_Attribute13,
	X_Attribute14			=> X_Attribute14,
	X_Attribute15			=> X_Attribute15,
	X_Attribute_Category_Code	=> X_Attribute_Category_Code,
	X_Creation_Date			=> sysdate,
	X_Created_By			=> user_id,
	X_Last_Update_Date		=> sysdate,
	X_Last_Updated_By		=> user_id,
	X_Last_Update_Login		=> 0
	,p_log_level_rec => p_log_level_rec);
  end if;

exception
  when others then
       FA_STANDARD_PKG.RAISE_ERROR(
                      CALLED_FN => 'fa_ceilings_pkg.load_row',
                      CALLING_FN => 'upload fa_ceilings'
                      ,p_log_level_rec => p_log_level_rec);

end LOAD_ROW;

/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/
procedure load_seed_row (
          x_upload_mode                 IN VARCHAR2,
          x_custom_mode                 IN VARCHAR2,
          x_ceiling_name                IN VARCHAR2,
          x_start_date                  IN DATE,
          x_end_date                    IN DATE,
          x_year_of_life                IN NUMBER,
          x_owner                       IN VARCHAR2,
          x_last_update_date            IN DATE,
          x_limit                       IN NUMBER,
          x_attribute1                  IN VARCHAR2,
          x_attribute2                  IN VARCHAR2,
          x_attribute3                  IN VARCHAR2,
          x_attribute4                  IN VARCHAR2,
          x_attribute5                  IN VARCHAR2,
          x_attribute6                  IN VARCHAR2,
          x_attribute7                  IN VARCHAR2,
          x_attribute8                  IN VARCHAR2,
          x_attribute9                  IN VARCHAR2,
          x_attribute10                 IN VARCHAR2,
          x_attribute11                 IN VARCHAR2,
          x_attribute12                 IN VARCHAR2,
          x_attribute13                 IN VARCHAR2,
          x_attribute14                 IN VARCHAR2,
          x_attribute15                 IN VARCHAR2,
          x_attribute_category_code     IN VARCHAR2) IS


BEGIN

      if (x_upload_mode = 'NLS') then
         null;
      else
        fa_ceilings_pkg.LOAD_ROW (
          x_custom_mode                 => x_custom_mode,
          x_ceiling_name                => x_ceiling_name,
          x_start_date                  => x_start_date,
          x_end_date                    => x_end_date,
          x_year_of_life                => x_year_of_life,
          x_owner                       => x_owner,
          x_last_update_date            => x_last_update_date,
          x_limit                       => x_limit,
          x_attribute1                  => x_attribute1,
          x_attribute2                  => x_attribute2,
          x_attribute3                  => x_attribute3,
          x_attribute4                  => x_attribute4,
          x_attribute5                  => x_attribute5,
          x_attribute6                  => x_attribute6,
          x_attribute7                  => x_attribute7,
          x_attribute8                  => x_attribute8,
          x_attribute9                  => x_attribute9,
          x_attribute10                 => x_attribute10,
          x_attribute11                 => x_attribute11,
          x_attribute12                 => x_attribute12,
          x_attribute13                 => x_attribute13,
          x_attribute14                 => x_attribute14,
          x_attribute15                 => x_attribute15,
          x_attribute_category_code     => x_attribute_category_code);
      end if;

END load_seed_row;

END FA_CEILINGS_PKG;

/
