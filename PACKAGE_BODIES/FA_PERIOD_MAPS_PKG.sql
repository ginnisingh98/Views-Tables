--------------------------------------------------------
--  DDL for Package Body FA_PERIOD_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_PERIOD_MAPS_PKG" as
/* $Header: faxipdmb.pls 120.6.12010000.2 2009/07/19 10:30:10 glchen ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_QUARTER in NUMBER,
  X_QTR_FIRST_PERIOD in NUMBER,
  X_QTR_LAST_PERIOD in NUMBER,
  X_YEAR_FIRST_PERIOD in NUMBER,
  X_YEAR_LAST_PERIOD in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

  CURSOR C is SELECT rowid FROM fa_period_maps
              WHERE nvl (year_last_period, -9999) = nvl (X_Year_Last_Period, -9999);

begin

  INSERT INTO fa_period_maps (
	quarter,
	qtr_first_period,
	qtr_last_period,
	year_first_period,
	year_last_period,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login
  ) VALUES (
	X_Quarter,
	X_Qtr_First_Period,
	X_Qtr_Last_Period,
	X_Year_First_Period,
	X_Year_Last_Period,
	X_Created_By,
	X_Creation_Date,
	X_Last_Updated_By,
	X_Last_Update_Date,
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
                calling_fn => 'fa_period_maps_pkg.insert_row',  p_log_level_rec => p_log_level_rec);
        raise;

end INSERT_ROW;

procedure LOCK_ROW (
  X_QUARTER in NUMBER,
  X_QTR_FIRST_PERIOD in NUMBER,
  X_QTR_LAST_PERIOD in NUMBER,
  X_YEAR_FIRST_PERIOD in NUMBER,
  X_YEAR_LAST_PERIOD in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
  CURSOR C IS
      SELECT quarter,
             qtr_first_period,
             qtr_last_period,
             year_first_period,
             year_last_period
      FROM   fa_period_maps
      WHERE  nvl (year_last_period, -9999) = nvl (X_Year_Last_Period, -9999)
      FOR UPDATE of year_last_period NOWAIT;
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
          ((Recinfo.Quarter = X_Quarter)
	  OR ((Recinfo.Quarter IS NULL)
          AND (X_Quarter IS NULL)))
      AND ((Recinfo.Qtr_First_Period = X_Qtr_First_Period)
          OR ((Recinfo.Qtr_First_Period IS NULL)
          AND (X_Qtr_First_Period IS NULL)))
      AND ((Recinfo.Qtr_Last_Period = X_Qtr_Last_Period)
          OR ((Recinfo.Qtr_Last_Period IS NULL)
          AND (X_Qtr_Last_Period IS NULL)))
      AND ((Recinfo.Year_First_Period = X_Year_First_Period)
          OR ((Recinfo.Year_First_Period IS NULL)
          AND (X_Year_First_Period IS NULL)))
      AND ((Recinfo.Year_Last_Period = X_Year_Last_Period)
          OR ((Recinfo.Year_Last_Period IS NULL)
          AND (X_Year_Last_Period IS NULL)))
     ) then
      return;
  else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
  end if;

end LOCK_ROW;

procedure UPDATE_ROW (
  X_QUARTER in NUMBER,
  X_QTR_FIRST_PERIOD in NUMBER,
  X_QTR_LAST_PERIOD in NUMBER,
  X_YEAR_FIRST_PERIOD in NUMBER,
  X_YEAR_LAST_PERIOD in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

begin

  UPDATE fa_period_maps
  SET	 quarter		= X_Quarter,
	 qtr_first_period	= X_Qtr_First_Period,
	 qtr_last_period	= X_Qtr_Last_Period,
	 year_first_period	= X_Year_First_Period,
	 year_last_period	= X_Year_Last_Period,
	 last_update_date	= X_Last_Update_Date,
	 last_updated_by	= X_Last_Updated_By,
	 last_update_login	= X_Last_Update_Login
  WHERE  nvl (year_last_period, -9999) = nvl (X_Year_Last_Period, -9999);

  if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
  end if;

  exception
    when others then
        fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_period_maps_pkg.update_row',  p_log_level_rec => p_log_level_rec);
        raise;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_YEAR_LAST_PERIOD in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

begin

  DELETE FROM fa_period_maps
  WHERE nvl (year_last_period, -9999) = nvl (X_Year_Last_Period, -9999);

  if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
  end if;

exception
    when others then
        fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_period_maps_pkg.delete_row',  p_log_level_rec => p_log_level_rec);
        raise;

end DELETE_ROW;

procedure LOAD_ROW (
  X_OWNER in VARCHAR2,
  X_QUARTER in NUMBER,
  X_QTR_FIRST_PERIOD in NUMBER,
  X_QTR_LAST_PERIOD in NUMBER,
  X_YEAR_FIRST_PERIOD in NUMBER,
  X_YEAR_LAST_PERIOD in NUMBER
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
  from   fa_period_maps pm
  where  nvl (pm.year_last_period, -9999) = nvl (X_Year_Last_Period, -9999);

  if (h_record_exists > 0) then
     fa_period_maps_pkg.update_row (
	X_Quarter		=> X_Quarter,
	X_Qtr_First_Period	=> X_Qtr_First_Period,
	X_Qtr_Last_Period	=> X_Qtr_Last_Period,
	X_Year_First_Period	=> X_Year_First_Period,
	X_Year_Last_Period	=> X_Year_Last_Period,
	X_Last_Update_Date	=> sysdate,
	X_Last_Updated_By	=> user_id,
	X_Last_Update_Login	=> 0
     , p_log_level_rec => p_log_level_rec);
  else
     fa_period_maps_pkg.insert_row (
	X_Rowid			=> row_id,
	X_Quarter		=> X_Quarter,
	X_Qtr_First_Period	=> X_Qtr_First_Period,
	X_Qtr_Last_Period	=> X_Qtr_Last_Period,
	X_Year_First_Period	=> X_Year_First_Period,
	X_Year_Last_Period	=> X_Year_Last_Period,
	X_Creation_Date		=> sysdate,
	X_Created_By		=> user_id,
	X_Last_Update_Date	=> sysdate,
	X_Last_Updated_By	=> user_id,
	X_Last_Update_Login	=> 0
     , p_log_level_rec => p_log_level_rec);
  end if;

exception
  when others then
       FA_STANDARD_PKG.RAISE_ERROR(
                      CALLED_FN => 'fa_period_maps_pkg.load_row',
                      CALLING_FN => 'upload fa_period_maps', p_log_level_rec => p_log_level_rec);

end LOAD_ROW;
/*Bug 8355119 overloading function for release specific signatures*/
procedure LOAD_ROW (
  X_CUSTOM_MODE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_QUARTER in NUMBER,
  X_QTR_FIRST_PERIOD in NUMBER,
  X_QTR_LAST_PERIOD in NUMBER,
  X_YEAR_FIRST_PERIOD in NUMBER,
  X_YEAR_LAST_PERIOD in NUMBER,
  p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) is

  h_record_exists	number(15);

  user_id		number;
  row_id		varchar2(64);

  db_last_updated_by    number;
  db_last_update_date   date;

begin

  user_id := fnd_load_util.owner_id (X_Owner);

  select count(*)
  into   h_record_exists
  from   fa_period_maps pm
  where  nvl (pm.year_last_period, -9999) = nvl (X_Year_Last_Period, -9999);

  if (h_record_exists > 0) then

     select last_updated_by, last_update_date
     into   db_last_updated_by, db_last_update_date
     from   fa_period_maps pm
     where  nvl (pm.year_last_period, -9999) = nvl (X_Year_Last_Period, -9999);

     if (fnd_load_util.upload_test(user_id, x_last_update_date,
                                   db_last_updated_by, db_last_update_date,
                                   X_CUSTOM_MODE)) then

        fa_period_maps_pkg.update_row (
           X_Quarter		=> X_Quarter,
           X_Qtr_First_Period	=> X_Qtr_First_Period,
           X_Qtr_Last_Period	=> X_Qtr_Last_Period,
           X_Year_First_Period	=> X_Year_First_Period,
           X_Year_Last_Period	=> X_Year_Last_Period,
           X_Last_Update_Date	=> sysdate,
           X_Last_Updated_By	=> user_id,
           X_Last_Update_Login	=> 0
           ,p_log_level_rec => p_log_level_rec);
     end if;
  else
     fa_period_maps_pkg.insert_row (
	X_Rowid			=> row_id,
	X_Quarter		=> X_Quarter,
	X_Qtr_First_Period	=> X_Qtr_First_Period,
	X_Qtr_Last_Period	=> X_Qtr_Last_Period,
	X_Year_First_Period	=> X_Year_First_Period,
	X_Year_Last_Period	=> X_Year_Last_Period,
	X_Creation_Date		=> sysdate,
	X_Created_By		=> user_id,
	X_Last_Update_Date	=> sysdate,
	X_Last_Updated_By	=> user_id,
	X_Last_Update_Login	=> 0
	,p_log_level_rec => p_log_level_rec);
  end if;

exception
  when others then
       FA_STANDARD_PKG.RAISE_ERROR(
                      CALLED_FN => 'fa_period_maps_pkg.load_row',
                      CALLING_FN => 'upload fa_period_maps'
                      ,p_log_level_rec => p_log_level_rec);

end LOAD_ROW;
/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/
procedure LOAD_SEED_ROW (
          x_upload_mode                 IN VARCHAR2,
          x_custom_mode                 IN VARCHAR2,
          x_owner                       IN VARCHAR2,
          x_last_update_date            IN DATE,
          x_quarter                     IN NUMBER,
          x_qtr_first_period            IN NUMBER,
          x_qtr_last_period             IN NUMBER,
          x_year_first_period           IN NUMBER,
          x_year_last_period            IN NUMBER) IS


BEGIN

      if (x_upload_mode = 'NLS') then
         null;
      else
        fa_period_maps_pkg.LOAD_ROW (
          x_custom_mode                 => x_custom_mode,
          x_owner                       => x_owner,
          x_last_update_date            => x_last_update_date,
          x_quarter                     => x_quarter,
          x_qtr_first_period            => x_qtr_first_period,
          x_qtr_last_period             => x_qtr_last_period,
          x_year_first_period           => x_year_first_period,
          x_year_last_period            => x_year_last_period);
      end if;

END LOAD_SEED_ROW;


END FA_PERIOD_MAPS_PKG;

/
