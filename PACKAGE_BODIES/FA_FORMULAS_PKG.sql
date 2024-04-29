--------------------------------------------------------
--  DDL for Package Body FA_FORMULAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FORMULAS_PKG" as
/* $Header: faxiforb.pls 120.9.12010000.2 2009/07/19 10:34:01 glchen ship $ */

procedure INSERT_ROW (
  X_ROWID             IN OUT NOCOPY VARCHAR2,
  X_METHOD_ID         IN NUMBER,
  X_FORMULA_ACTUAL    IN VARCHAR2,
  X_FORMULA_DISPLAYED IN VARCHAR2,
  X_FORMULA_PARSED    IN VARCHAR2,
  X_CREATION_DATE     IN DATE,
  X_CREATED_BY        IN NUMBER,
  X_LAST_UPDATE_DATE  IN DATE,
  X_LAST_UPDATED_BY   IN NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORIGINAL_RATE     IN NUMBER DEFAULT NULL,
  X_REVISED_RATE      IN NUMBER DEFAULT NULL,
  X_GUARANTEE_RATE    IN NUMBER DEFAULT NULL
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

  CURSOR C is SELECT rowid FROM fa_formulas
              where  method_id = X_Method_Id;

begin

   INSERT INTO fa_formulas (
	method_id,
        formula_actual,
	formula_displayed,
	formula_parsed,
	creation_date,
	created_by,
	last_update_date,
        last_updated_by,
        last_update_login,
        original_rate,
        revised_rate,
        guarantee_rate
   ) VALUES (
        X_Method_ID,
        X_Formula_Actual,
        X_Formula_Displayed,
        X_Formula_Parsed,
        X_Creation_Date,
        X_Created_By,
        X_Last_Update_Date,
        X_Last_Updated_By,
        X_Last_Update_Login,
        X_Original_Rate,
        X_Revised_Rate,
        X_Guarantee_Rate
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
        calling_fn => 'fa_formulas_pkg.insert_row',  p_log_level_rec => p_log_level_rec);
   raise;

end INSERT_ROW;

procedure LOCK_ROW (
  X_METHOD_ID         IN NUMBER,
  X_FORMULA_ACTUAL    IN VARCHAR2,
  X_FORMULA_DISPLAYED IN VARCHAR2,
  X_FORMULA_PARSED    IN VARCHAR2,
  X_ORIGINAL_RATE     IN NUMBER,
  X_REVISED_RATE      IN NUMBER,
  X_GUARANTEE_RATE    IN NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
  CURSOR C is
        SELECT method_id,
               formula_actual,
	       formula_displayed,
	       formula_parsed,
               original_rate,
               revised_rate,
               guarantee_rate
	 FROM  fa_formulas
         where  method_id = X_Method_Id
         FOR UPDATE of method_id NOWAIT;
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
        AND     (Recinfo.Formula_Actual = X_Formula_Actual)
        AND     (Recinfo.Formula_Displayed = X_Formula_Displayed)
        AND     (Recinfo.Formula_Parsed = X_Formula_Parsed)
        AND     (nvl(Recinfo.Original_Rate, -999) = nvl(X_Original_Rate,-999))
        AND     (nvl(Recinfo.Revised_Rate, -999) = nvl(X_Revised_Rate,-999))
        AND     (nvl(Recinfo.Guarantee_Rate, -999) = nvl(X_Guarantee_Rate,-999))
     )   then
         return;
  else
        FND_MESSAGE.set_Name('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.Raise_Exception;
  end if;

end LOCK_ROW;

procedure UPDATE_ROW (
  X_METHOD_ID         IN NUMBER,
  X_FORMULA_ACTUAL    IN VARCHAR2,
  X_FORMULA_DISPLAYED IN VARCHAR2,
  X_FORMULA_PARSED    IN VARCHAR2,
  X_LAST_UPDATE_DATE  IN DATE,
  X_LAST_UPDATED_BY   IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER,
  X_ORIGINAL_RATE     IN NUMBER,
  X_REVISED_RATE      IN NUMBER,
  X_GUARANTEE_RATE    IN NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

begin

   UPDATE fa_formulas
    SET formula_actual		= X_Formula_Actual,
        formula_displayed	= X_Formula_Displayed,
        formula_parsed		= X_Formula_Parsed,
        last_update_date	= X_Last_Update_Date,
        last_updated_by		= X_Last_Updated_By,
        last_update_login	= X_Last_Update_Login,
        original_rate           = X_Original_Rate,
        revised_rate            = X_Revised_Rate,
        guarantee_rate          = X_Guarantee_Rate
WHERE method_id = X_Method_ID;

exception
   when others then
        fa_srvr_msg.add_sql_error(
        calling_fn => 'fa_formulas_pkg.update_row',  p_log_level_rec => p_log_level_rec);
   raise;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_METHOD_ID in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

begin

   DELETE FROM fa_formulas
   where  method_id = X_Method_Id;

   if (SQL%NOTFOUND) then
           Raise NO_DATA_FOUND;
        end if;

exception
   when others then
        fa_srvr_msg.add_sql_error(
        calling_fn => 'fa_formulas_pkg.delete_row',  p_log_level_rec => p_log_level_rec);
   raise;

end DELETE_ROW;


procedure LOAD_ROW (
  X_METHOD_ID         IN NUMBER,
  X_OWNER             IN VARCHAR2,
  X_FORMULA_ACTUAL    IN VARCHAR2,
  X_FORMULA_DISPLAYED IN VARCHAR2,
  X_FORMULA_PARSED    IN VARCHAR2,
  X_ORIGINAL_RATE     IN NUMBER DEFAULT NULL,
  X_REVISED_RATE      IN NUMBER DEFAULT NULL,
  X_GUARANTEE_RATE    IN NUMBER DEFAULT NULL
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

  h_record_exists	number(15);

  user_id	number;
  row_id	varchar2(64);

begin

  if (X_Owner = 'SEED') then
      user_id := 1;
  else
      user_id := 0;
  end if;

  select count(*)
  into   h_record_exists
  from   fa_formulas
  where method_id = X_Method_ID;

if (h_record_exists > 0) then
  fa_formulas_pkg.update_row (
  X_Method_ID		=> X_Method_ID,
  X_Formula_Actual	=> X_Formula_Actual,
  X_Formula_Displayed	=> X_Formula_Displayed,
  X_Formula_Parsed	=> X_Formula_Parsed,
  X_Last_Update_Date	=> sysdate,
  X_Last_Updated_By	=> user_id,
  X_Last_Update_Login	=> 0,
  X_Original_Rate       => X_Original_Rate,   -- Replaced X_Method_ID with X_Original_Rate for bug 6372294
  X_Revised_Rate        => X_Revised_Rate,
  X_Guarantee_Rate      => X_Guarantee_Rate
, p_log_level_rec => p_log_level_rec);
else
  fa_formulas_pkg.insert_row (
  X_Rowid		=> row_id,
  X_Method_ID		=> X_Method_ID,
  X_Formula_Actual      => X_Formula_Actual,
  X_Formula_Displayed   => X_Formula_Displayed,
  X_Formula_Parsed      => X_Formula_Parsed,
  X_Creation_Date	=> sysdate,
  X_Created_By		=> user_id,
  X_Last_Update_Date	=> sysdate,
  X_Last_Updated_By	=> user_id,
  X_Last_Update_Login	=> 0,
  X_Original_Rate       => X_Original_Rate,
  X_Revised_Rate        => X_Revised_Rate,
  X_Guarantee_Rate      => X_Guarantee_Rate
, p_log_level_rec => p_log_level_rec);
end if;

exception
   when others then
      FA_STANDARD_PKG.RAISE_ERROR(
			CALLED_FN => 'fa_formulas_pkg.load_row',
			CALLING_FN => 'upload fa_formulas', p_log_level_rec => p_log_level_rec);

end LOAD_ROW;

procedure LOAD_ROW (
  X_CUSTOM_MODE in VARCHAR2,
  X_METHOD_ID in NUMBER,
  X_DB_LAST_UPDATED_BY NUMBER,
  X_DB_LAST_UPDATE_DATE DATE,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_FORMULA_ACTUAL in VARCHAR2,
  X_FORMULA_DISPLAYED in VARCHAR2,
  X_FORMULA_PARSED in VARCHAR2,
  X_ORIGINAL_RATE     IN NUMBER DEFAULT NULL,
  X_REVISED_RATE      IN NUMBER DEFAULT NULL,
  X_GUARANTEE_RATE    IN NUMBER DEFAULT NULL,
  p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) is

  h_record_exists	number(15);

  user_id	number;
  row_id	varchar2(64);

begin

   user_id := fnd_load_util.owner_id (X_Owner);

   select count(*)
   into   h_record_exists
   from   fa_formulas
   where method_id = X_Method_ID;

   if (h_record_exists > 0) then
      if (fnd_load_util.upload_test(user_id, x_last_update_date,
                                    x_db_last_updated_by,x_db_last_update_date,
                                    X_CUSTOM_MODE)) then

         fa_formulas_pkg.update_row (
            X_Method_ID            => X_Method_ID,
            X_Formula_Actual       => X_Formula_Actual,
            X_Formula_Displayed	   => X_Formula_Displayed,
            X_Formula_Parsed	   => X_Formula_Parsed,
            X_Last_Update_Date	   => sysdate,
            X_Last_Updated_By      => user_id,
            X_Last_Update_Login	   => 0,
            X_Original_Rate        => X_Original_Rate,
            X_Revised_Rate         => X_Revised_Rate,
            X_Guarantee_Rate       => X_Guarantee_Rate
         ,p_log_level_rec => p_log_level_rec);
      end if;
   else

     fa_formulas_pkg.insert_row (
        X_Rowid                 => row_id,
        X_Method_ID		=> X_Method_ID,
        X_Formula_Actual        => X_Formula_Actual,
        X_Formula_Displayed     => X_Formula_Displayed,
        X_Formula_Parsed        => X_Formula_Parsed,
        X_Creation_Date	        => sysdate,
        X_Created_By		=> user_id,
        X_Last_Update_Date	=> sysdate,
        X_Last_Updated_By	=> user_id,
        X_Last_Update_Login	=> 0,
        X_Original_Rate         => X_Original_Rate,
        X_Revised_Rate          => X_Revised_Rate,
        X_Guarantee_Rate        => X_Guarantee_Rate
        ,p_log_level_rec => p_log_level_rec);
   end if;

exception
   when others then

      FA_STANDARD_PKG.RAISE_ERROR(
			CALLED_FN => 'fa_formulas_pkg.load_row',
			CALLING_FN => 'upload fa_formulas'
			,p_log_level_rec => p_log_level_rec);

end LOAD_ROW;

procedure LOAD_SEED_ROW (
               x_upload_mode            IN VARCHAR2,
               x_custom_mode            IN VARCHAR2,
               x_method_code            IN VARCHAR2,
               x_life_in_months         IN NUMBER,
               x_owner                  IN VARCHAR2,
               x_last_update_date       IN DATE,
               x_formula_actual         IN VARCHAR2,
               x_formula_displayed      IN VARCHAR2,
               x_formula_parsed         IN VARCHAR2,
               x_original_rate          IN NUMBER DEFAULT NULL,
               x_revised_rate           IN NUMBER DEFAULT NULL,
               x_guarantee_rate         IN NUMBER DEFAULT NULL
) IS


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
         X_life                  => x_life_in_months) then
         h_method_id := null;
      end if;

      h_method_id        := fa_cache_pkg.fazccmt_record.method_id;
      h_last_update_date := fa_cache_pkg.fazccmt_record.last_update_date;
      h_last_updated_by  := fa_cache_pkg.fazccmt_record.last_updated_by;
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

      fa_formulas_pkg.LOAD_ROW (
               x_custom_mode            => x_custom_mode,
               x_method_id              => h_method_id,
               x_db_last_update_date    => h_last_update_date,
               x_db_last_updated_by     => h_last_updated_by,
               x_owner                  => x_owner,
               x_last_update_date       => x_last_update_date,
               x_formula_actual         => x_formula_actual,
               x_formula_displayed      => x_formula_displayed,
               x_formula_parsed         => x_formula_parsed,
               x_original_rate          => x_original_rate,
               x_revised_rate           => x_revised_rate,
               x_guarantee_rate         => x_guarantee_rate);
   end if;

EXCEPTION
   WHEN methods_err THEN

      fa_srvr_msg.add_sql_error(
         calling_fn => 'update fa_formulas');

      fa_standard_pkg.raise_error(
         called_fn => 'farat.lct',
         calling_fn => 'fa_formulas_pkg.load_seed_row');

END LOAD_SEED_ROW;

END FA_FORMULAS_PKG;

/
