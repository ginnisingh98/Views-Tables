--------------------------------------------------------
--  DDL for Package Body FA_FLAT_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FLAT_RATES_PKG" as
/* $Header: faxiflrb.pls 120.6.12010000.2 2009/07/19 10:33:06 glchen ship $ */

procedure INSERT_ROW (
   X_ROWID in out nocopy VARCHAR2,
   X_METHOD_ID in NUMBER,
   X_BASIC_RATE in NUMBER,
   X_ADJUSTED_RATE in NUMBER,
   X_ADJUSTING_RATE in NUMBER,
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

  CURSOR C is SELECT rowid FROM fa_flat_rates
              where  method_id = X_Method_Id
              and    basic_rate = X_Basic_Rate
              and    adjusted_rate = X_Adjusted_Rate;

begin

   INSERT INTO fa_flat_rates (
	method_id,
	basic_rate,
	adjusted_rate,
	adjusting_rate,
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
	X_Method_ID,
        X_Basic_Rate,
        X_Adjusted_Rate,
        X_Adjusting_Rate,
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
	calling_fn => 'fa_flat_rates_pkg.insert_row', p_log_level_rec => p_log_level_rec);
   raise;

end INSERT_ROW;

procedure LOCK_ROW (
   X_METHOD_ID in NUMBER,
   X_BASIC_RATE in NUMBER,
   X_ADJUSTED_RATE in NUMBER,
   X_ADJUSTING_RATE in NUMBER,
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
  CURSOR C is
      	SELECT method_id,
               basic_rate,
               adjusted_rate,
               adjusting_rate,
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
         FROM  fa_flat_rates
         where  method_id = X_Method_Id
         and    basic_rate = X_Basic_Rate
         and    adjusted_rate = X_Adjusted_Rate
	 FOR UPDATE of method_id, basic_rate, adjusted_rate NOWAIT;
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
		(Recinfo.Method_ID = X_Method_ID)
	AND	(Recinfo.Basic_Rate = X_Basic_Rate)
	AND	(Recinfo.Adjusting_Rate = X_Adjusting_Rate)
	AND	(Recinfo.Adjusted_Rate = X_Adjusted_Rate)
	AND	((Recinfo.Attribute1 = X_Attribute1)
	    OR  ((Recinfo.Attribute1 IS NULL)
	    AND (X_Attribute1 IS NULL)))
        AND     ((Recinfo.Attribute2 = X_Attribute2)
            OR  ((Recinfo.Attribute2 IS NULL)
            AND (X_Attribute2 IS NULL)))
        AND     ((Recinfo.Attribute3 = X_Attribute3)
            OR  ((Recinfo.Attribute3 IS NULL)
            AND (X_Attribute3 IS NULL)))
        AND     ((Recinfo.Attribute4 = X_Attribute4)
            OR  ((Recinfo.Attribute4 IS NULL)
            AND (X_Attribute4 IS NULL)))
        AND     ((Recinfo.Attribute5 = X_Attribute5)
            OR  ((Recinfo.Attribute5 IS NULL)
            AND (X_Attribute5 IS NULL)))
        AND     ((Recinfo.Attribute6 = X_Attribute6)
            OR  ((Recinfo.Attribute6 IS NULL)
            AND (X_Attribute6 IS NULL)))
        AND     ((Recinfo.Attribute7 = X_Attribute7)
            OR  ((Recinfo.Attribute7 IS NULL)
            AND (X_Attribute7 IS NULL)))
        AND     ((Recinfo.Attribute8 = X_Attribute8)
            OR  ((Recinfo.Attribute8 IS NULL)
            AND (X_Attribute8 IS NULL)))
        AND     ((Recinfo.Attribute9 = X_Attribute9)
            OR  ((Recinfo.Attribute9 IS NULL)
            AND (X_Attribute9 IS NULL)))
        AND     ((Recinfo.Attribute10 = X_Attribute10)
            OR  ((Recinfo.Attribute10 IS NULL)
            AND (X_Attribute10 IS NULL)))
        AND     ((Recinfo.Attribute11 = X_Attribute11)
            OR  ((Recinfo.Attribute11 IS NULL)
            AND (X_Attribute11 IS NULL)))
        AND     ((Recinfo.Attribute12 = X_Attribute12)
            OR  ((Recinfo.Attribute12 IS NULL)
            AND (X_Attribute12 IS NULL)))
        AND     ((Recinfo.Attribute13 = X_Attribute13)
            OR  ((Recinfo.Attribute13 IS NULL)
            AND (X_Attribute13 IS NULL)))
        AND     ((Recinfo.Attribute14 = X_Attribute14)
            OR  ((Recinfo.Attribute14 IS NULL)
            AND (X_Attribute14 IS NULL)))
        AND     ((Recinfo.Attribute15 = X_Attribute15)
            OR  ((Recinfo.Attribute15 IS NULL)
            AND (X_Attribute15 IS NULL)))
	)   then
	    return;
  else
	FND_MESSAGE.set_Name('FND', 'FORM_RECORD_CHANGED');
	APP_EXCEPTION.Raise_Exception;
  end if;

end LOCK_ROW;

procedure UPDATE_ROW (
   X_METHOD_ID in NUMBER,
   X_BASIC_RATE in NUMBER,
   X_ADJUSTED_RATE in NUMBER,
   X_ADJUSTING_RATE in NUMBER,
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

   UPDATE fa_flat_rates
   SET  method_id		= X_Method_ID,
	basic_rate		= X_Basic_Rate,
	adjusted_rate		= X_Adjusted_Rate,
	adjusting_rate		= X_Adjusting_Rate,
	attribute1		= X_Attribute1,
	attribute2              = X_Attribute2,
        attribute3              = X_Attribute3,
        attribute4              = X_Attribute4,
        attribute5              = X_Attribute5,
        attribute6              = X_Attribute6,
        attribute7              = X_Attribute7,
        attribute8              = X_Attribute8,
        attribute9              = X_Attribute9,
        attribute10             = X_Attribute10,
        attribute11             = X_Attribute11,
        attribute12             = X_Attribute12,
        attribute13             = X_Attribute13,
        attribute14             = X_Attribute14,
        attribute15             = X_Attribute15
   where  method_id = X_Method_Id
   and    basic_rate = X_Basic_Rate
   and    adjusted_rate = X_Adjusted_Rate;

   if (SQL%NOTFOUND) then
           Raise NO_DATA_FOUND;
        end if;

exception
   when others then
        fa_srvr_msg.add_sql_error(
        calling_fn => 'fa_flat_rates_pkg.update_row',  p_log_level_rec => p_log_level_rec);
   raise;

end UPDATE_ROW;

procedure DELETE_ROW (
   X_METHOD_ID in NUMBER,
   X_BASIC_RATE in NUMBER,
   X_ADJUSTED_RATE in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

begin

   DELETE FROM fa_flat_rates
   where  method_id = X_Method_Id
   and    basic_rate = X_Basic_Rate
   and    adjusted_rate = X_Adjusted_Rate;

   if (SQL%NOTFOUND) then
           Raise NO_DATA_FOUND;
        end if;

exception
   when others then
        fa_srvr_msg.add_sql_error(
        calling_fn => 'fa_flat_rates_pkg.delete_row', p_log_level_rec => p_log_level_rec);
   raise;

end DELETE_ROW;

procedure LOAD_ROW (
   X_METHOD_ID in NUMBER,
   X_OWNER in VARCHAR2,
   X_BASIC_RATE in NUMBER,
   X_ADJUSTING_RATE in NUMBER,
   X_ADJUSTED_RATE in NUMBER,
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

   h_record_exists	number(15);

   user_id		number;
   row_id		varchar2(64);

begin

   if (X_Owner = 'SEED') then
      user_id := 1;
   else
      user_id := 0;
   end if;

   select count(*)
   into   h_record_exists
   from   fa_flat_rates fr
   where  fr.method_id = X_Method_Id
   and    fr.basic_rate = X_Basic_Rate
   and    fr.adjusted_rate = X_Adjusted_Rate;

if (h_record_exists > 0) then
 fa_flat_rates_pkg.update_row (
   X_Method_Id			=> X_Method_Id,
   X_Basic_Rate			=> X_Basic_Rate,
   X_Adjusted_Rate		=> X_Adjusted_Rate,
   X_Adjusting_Rate		=> X_Adjusting_Rate,
   X_Attribute1			=> X_Attribute1,
   X_Attribute2                 => X_Attribute2,
   X_Attribute3                 => X_Attribute3,
   X_Attribute4                 => X_Attribute4,
   X_Attribute5                 => X_Attribute5,
   X_Attribute6                 => X_Attribute6,
   X_Attribute7                 => X_Attribute7,
   X_Attribute8                 => X_Attribute8,
   X_Attribute9                 => X_Attribute9,
   X_Attribute10                => X_Attribute10,
   X_Attribute11                => X_Attribute11,
   X_Attribute12                => X_Attribute12,
   X_Attribute13                => X_Attribute13,
   X_Attribute14                => X_Attribute14,
   X_Attribute15                => X_Attribute15,
   X_Attribute_Category_Code	=> X_Attribute_Category_Code,
   X_Last_Update_Date		=> sysdate,
   X_Last_Updated_By		=> user_id,
   X_Last_Update_Login		=> 0
 , p_log_level_rec => p_log_level_rec);
else
 fa_flat_rates_pkg.insert_row (
   X_Rowid			=> row_id,
   X_Method_Id                  => X_Method_Id,
   X_Basic_Rate                 => X_Basic_Rate,
   X_Adjusted_Rate              => X_Adjusted_Rate,
   X_Adjusting_Rate             => X_Adjusting_Rate,
   X_Attribute1                 => X_Attribute1,
   X_Attribute2                 => X_Attribute2,
   X_Attribute3                 => X_Attribute3,
   X_Attribute4                 => X_Attribute4,
   X_Attribute5                 => X_Attribute5,
   X_Attribute6                 => X_Attribute6,
   X_Attribute7                 => X_Attribute7,
   X_Attribute8                 => X_Attribute8,
   X_Attribute9                 => X_Attribute9,
   X_Attribute10                => X_Attribute10,
   X_Attribute11                => X_Attribute11,
   X_Attribute12                => X_Attribute12,
   X_Attribute13                => X_Attribute13,
   X_Attribute14                => X_Attribute14,
   X_Attribute15                => X_Attribute15,
   X_Attribute_Category_Code    => X_Attribute_Category_Code,
   X_Creation_Date		=> sysdate,
   X_Created_By			=> user_id,
   X_Last_Update_Date           => sysdate,
   X_Last_Updated_By            => user_id,
   X_Last_Update_Login          => 0
 , p_log_level_rec => p_log_level_rec);
end if;

exception
  when others then
    FA_STANDARD_PKG.RAISE_ERROR(
		CALLED_FN => 'fa_flat_rates_pkg.load_row',
		CALLING_FN => 'upload fa_flat_rates', p_log_level_rec => p_log_level_rec);

end LOAD_ROW;
/*Bug 8355119 overloading function for release specific signatures*/
procedure LOAD_ROW (
   X_CUSTOM_MODE in VARCHAR2,
   X_METHOD_ID in NUMBER,
   X_DB_LAST_UPDATED_BY NUMBER,
   X_DB_LAST_UPDATE_DATE DATE,
   X_OWNER in VARCHAR2,
   X_LAST_UPDATE_DATE in DATE,
   X_BASIC_RATE in NUMBER,
   X_ADJUSTING_RATE in NUMBER,
   X_ADJUSTED_RATE in NUMBER,
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

   h_record_exists	number(15);

   user_id		number;
   row_id		varchar2(64);

begin

   user_id := fnd_load_util.owner_id (X_Owner);

   select count(*)
   into   h_record_exists
   from   fa_flat_rates fr
   where  fr.method_id = X_Method_Id
   and    fr.basic_rate = X_Basic_Rate
   and    fr.adjusted_rate = X_Adjusted_Rate;

   if (h_record_exists > 0) then
      if (fnd_load_util.upload_test(user_id, x_last_update_date,
                                    x_db_last_updated_by,x_db_last_update_date,
                                    X_CUSTOM_MODE )) then

         fa_flat_rates_pkg.update_row (
            X_Method_Id	                 => X_Method_Id,
            X_Basic_Rate                 => X_Basic_Rate,
            X_Adjusted_Rate              => X_Adjusted_Rate,
            X_Adjusting_Rate             => X_Adjusting_Rate,
            X_Attribute1                 => X_Attribute1,
            X_Attribute2                 => X_Attribute2,
            X_Attribute3                 => X_Attribute3,
            X_Attribute4                 => X_Attribute4,
            X_Attribute5                 => X_Attribute5,
            X_Attribute6                 => X_Attribute6,
            X_Attribute7                 => X_Attribute7,
            X_Attribute8                 => X_Attribute8,
            X_Attribute9                 => X_Attribute9,
            X_Attribute10                => X_Attribute10,
            X_Attribute11                => X_Attribute11,
            X_Attribute12                => X_Attribute12,
            X_Attribute13                => X_Attribute13,
            X_Attribute14                => X_Attribute14,
            X_Attribute15                => X_Attribute15,
            X_Attribute_Category_Code    => X_Attribute_Category_Code,
            X_Last_Update_Date	         => sysdate,
            X_Last_Updated_By	         => user_id,
            X_Last_Update_Login	         => 0
            ,p_log_level_rec => p_log_level_rec);
      end if;

   else

      fa_flat_rates_pkg.insert_row (
         X_Rowid		      => row_id,
         X_Method_Id                  => X_Method_Id,
         X_Basic_Rate                 => X_Basic_Rate,
         X_Adjusted_Rate              => X_Adjusted_Rate,
         X_Adjusting_Rate             => X_Adjusting_Rate,
         X_Attribute1                 => X_Attribute1,
         X_Attribute2                 => X_Attribute2,
         X_Attribute3                 => X_Attribute3,
         X_Attribute4                 => X_Attribute4,
         X_Attribute5                 => X_Attribute5,
         X_Attribute6                 => X_Attribute6,
         X_Attribute7                 => X_Attribute7,
         X_Attribute8                 => X_Attribute8,
         X_Attribute9                 => X_Attribute9,
         X_Attribute10                => X_Attribute10,
         X_Attribute11                => X_Attribute11,
         X_Attribute12                => X_Attribute12,
         X_Attribute13                => X_Attribute13,
         X_Attribute14                => X_Attribute14,
         X_Attribute15                => X_Attribute15,
         X_Attribute_Category_Code    => X_Attribute_Category_Code,
         X_Creation_Date	      => sysdate,
         X_Created_By		      => user_id,
         X_Last_Update_Date           => sysdate,
         X_Last_Updated_By            => user_id,
         X_Last_Update_Login          => 0
         ,p_log_level_rec => p_log_level_rec);
   end if;

exception
  when others then
    FA_STANDARD_PKG.RAISE_ERROR(
		CALLED_FN => 'fa_flat_rates_pkg.load_row',
		CALLING_FN => 'upload fa_flat_rates'
		,p_log_level_rec => p_log_level_rec);

end LOAD_ROW;

/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/
procedure LOAD_SEED_ROW (
               x_upload_mode             IN VARCHAR2,
               x_custom_mode             IN VARCHAR2,
               x_method_code             IN VARCHAR2,
               x_life_in_months          IN NUMBER,
               x_owner                   IN VARCHAR2,
               x_last_update_date        IN DATE,
               x_basic_rate              IN NUMBER,
               x_adjusting_rate          IN NUMBER,
               x_adjusted_rate           IN NUMBER,
               x_attribute1              IN VARCHAR2,
               x_attribute2              IN VARCHAR2,
               x_attribute3              IN VARCHAR2,
               x_attribute4              IN VARCHAR2,
               x_attribute5              IN VARCHAR2,
               x_attribute6              IN VARCHAR2,
               x_attribute7              IN VARCHAR2,
               x_attribute8              IN VARCHAR2,
               x_attribute9              IN VARCHAR2,
               x_attribute10             IN VARCHAR2,
               x_attribute11             IN VARCHAR2,
               x_attribute12             IN VARCHAR2,
               x_attribute13             IN VARCHAR2,
               x_attribute14             IN VARCHAR2,
               x_attribute15             IN VARCHAR2,
               x_attribute_category_code IN VARCHAR2
               ,p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

   methods_err           exception;
   h_method_id           number(15);
   h_last_update_date    date;
   h_last_updated_by     number;

   h_depr_last_year_flag boolean;
   h_rate_source_rule    varchar2(10);
   h_deprn_basis_rule    varchar2(4);
   h_excl_sal_val_flag   boolean;

BEGIN

   if (x_upload_mode = 'NLS') then
      null;
   else

      if not fa_cache_pkg.fazccmt (
         X_method                => x_method_code,
         X_life                  => x_life_in_months
         ,p_log_level_rec => p_log_level_rec) then
         raise methods_err;
      end if;

      h_method_id        := fa_cache_pkg.fazccmt_record.method_id;
      h_last_update_date := fa_cache_pkg.fazccmt_record.last_update_date;
      h_last_updated_by := fa_cache_pkg.fazccmt_record.last_updated_by;
      h_rate_source_rule := fa_cache_pkg.fazccmt_record.rate_source_rule;
      h_deprn_basis_rule := fa_cache_pkg.fazccmt_record.deprn_basis_rule;

      if fa_cache_pkg.fazccmt_record.exclude_salvage_value_flag = 'YES' then
         h_excl_sal_val_flag := TRUE;
      else
         h_excl_sal_val_flag := FALSE;
      end if;

      if fa_cache_pkg.fazccmt_record.depreciate_lastyear_flag = 'YES' then
         h_depr_last_year_flag := TRUE;
      else
         h_depr_last_year_flag := FALSE;
      end if;

      fa_flat_rates_pkg.LOAD_ROW (
               x_custom_mode             => x_custom_mode,
               x_method_id               => h_method_id,
               x_db_last_update_date     => h_last_update_date,
               x_db_last_updated_by      => h_last_updated_by,
               x_owner                   => x_owner,
               x_last_update_date        => x_last_update_date,
               x_basic_rate              => x_basic_rate,
               x_adjusting_rate          => x_adjusting_rate,
               x_adjusted_rate           => x_adjusted_rate,
               x_attribute1              => x_attribute1,
               x_attribute2              => x_attribute2,
               x_attribute3              => x_attribute3,
               x_attribute4              => x_attribute4,
               x_attribute5              => x_attribute5,
               x_attribute6              => x_attribute6,
               x_attribute7              => x_attribute7,
               x_attribute8              => x_attribute8,
               x_attribute9              => x_attribute9,
               x_attribute10             => x_attribute10,
               x_attribute11             => x_attribute11,
               x_attribute12             => x_attribute12,
               x_attribute13             => x_attribute13,
               x_attribute14             => x_attribute14,
               x_attribute15             => x_attribute15,
               x_attribute_category_code => x_attribute_category_code
               ,p_log_level_rec => p_log_level_rec);

   end if;

EXCEPTION
   WHEN methods_err THEN
      fa_srvr_msg.add_sql_error(
         calling_fn => 'updating flat_rates'
         ,p_log_level_rec => p_log_level_rec);

      fa_standard_pkg.raise_error(
         called_fn => 'farat.lct',
         calling_fn => 'fa_flat_rates_pkg.load_seed_row'
         ,p_log_level_rec => p_log_level_rec);

END LOAD_SEED_ROW;

END FA_FLAT_RATES_PKG;

/
