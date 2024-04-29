--------------------------------------------------------
--  DDL for Package Body FND_TIMEZONES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_TIMEZONES_PKG" as
/* $Header: AFTZTBB.pls 120.2 2005/10/21 07:32:04 dbowles ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TIMEZONE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_GMT_OFFSET in NUMBER,
  X_DAYLIGHT_SAVINGS_FLAG in VARCHAR2,
  X_ACTIVE_TIMEZONE_CODE in VARCHAR2,
  X_UPGRADE_TZ_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_TIMEZONES_B
    where TIMEZONE_CODE = X_TIMEZONE_CODE
    ;
begin
  insert into FND_TIMEZONES_B (
    TIMEZONE_CODE,
    ENABLED_FLAG,
    GMT_OFFSET,
    DAYLIGHT_SAVINGS_FLAG,
    ACTIVE_TIMEZONE_CODE,
    UPGRADE_TZ_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_TIMEZONE_CODE,
    X_ENABLED_FLAG,
    X_GMT_OFFSET,
    X_DAYLIGHT_SAVINGS_FLAG,
    X_ACTIVE_TIMEZONE_CODE,
    X_UPGRADE_TZ_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_TIMEZONES_TL (
    TIMEZONE_CODE,
    NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TIMEZONE_CODE,
    X_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_TIMEZONES_TL T
    where T.TIMEZONE_CODE = X_TIMEZONE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_TIMEZONE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_GMT_OFFSET in NUMBER,
  X_DAYLIGHT_SAVINGS_FLAG in VARCHAR2,
  X_ACTIVE_TIMEZONE_CODE in VARCHAR2,
  X_UPGRADE_TZ_ID in NUMBER,
  X_NAME in VARCHAR2
) is
  cursor c is select
      ENABLED_FLAG,
      GMT_OFFSET,
      DAYLIGHT_SAVINGS_FLAG,
      ACTIVE_TIMEZONE_CODE,
      UPGRADE_TZ_ID
    from FND_TIMEZONES_B
    where TIMEZONE_CODE = X_TIMEZONE_CODE
    for update of TIMEZONE_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_TIMEZONES_TL
    where TIMEZONE_CODE = X_TIMEZONE_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TIMEZONE_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.GMT_OFFSET = X_GMT_OFFSET)
      AND (recinfo.DAYLIGHT_SAVINGS_FLAG = X_DAYLIGHT_SAVINGS_FLAG)
      AND ((recinfo.ACTIVE_TIMEZONE_CODE = X_ACTIVE_TIMEZONE_CODE)
           OR ((recinfo.ACTIVE_TIMEZONE_CODE is null) AND (X_ACTIVE_TIMEZONE_CODE is null)))
      AND ((recinfo.UPGRADE_TZ_ID = X_UPGRADE_TZ_ID)
           OR ((recinfo.UPGRADE_TZ_ID is null) AND (X_UPGRADE_TZ_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_TIMEZONE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_GMT_OFFSET in NUMBER,
  X_DAYLIGHT_SAVINGS_FLAG in VARCHAR2,
  X_ACTIVE_TIMEZONE_CODE in VARCHAR2,
  X_UPGRADE_TZ_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_TIMEZONES_B set
    ENABLED_FLAG = X_ENABLED_FLAG,
    GMT_OFFSET = X_GMT_OFFSET,
    DAYLIGHT_SAVINGS_FLAG = X_DAYLIGHT_SAVINGS_FLAG,
    ACTIVE_TIMEZONE_CODE = X_ACTIVE_TIMEZONE_CODE,
    UPGRADE_TZ_ID = X_UPGRADE_TZ_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TIMEZONE_CODE = X_TIMEZONE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_TIMEZONES_TL set
    NAME = X_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TIMEZONE_CODE = X_TIMEZONE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TIMEZONE_CODE in VARCHAR2
) is
begin
  delete from FND_TIMEZONES_TL
  where TIMEZONE_CODE = X_TIMEZONE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_TIMEZONES_B
  where TIMEZONE_CODE = X_TIMEZONE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from FND_TIMEZONES_TL T
  where not exists
    (select NULL
    from FND_TIMEZONES_B B
    where B.TIMEZONE_CODE = T.TIMEZONE_CODE
    );

  update FND_TIMEZONES_TL T set (
      NAME
    ) = (select
      B.NAME
    from FND_TIMEZONES_TL B
    where B.TIMEZONE_CODE = T.TIMEZONE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TIMEZONE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.TIMEZONE_CODE,
      SUBT.LANGUAGE
    from FND_TIMEZONES_TL SUBB, FND_TIMEZONES_TL SUBT
    where SUBB.TIMEZONE_CODE = SUBT.TIMEZONE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));
*/

  insert into FND_TIMEZONES_TL (
    TIMEZONE_CODE,
    NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TIMEZONE_CODE,
    B.NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_TIMEZONES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_TIMEZONES_TL T
    where T.TIMEZONE_CODE = B.TIMEZONE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  	X_TIMEZONE_CODE in VARCHAR2,
  	X_NAME in VARCHAR2,
        X_OWNER in VARCHAR2,
        X_LAST_UPDATE_DATE in VARCHAR2,
        X_CUSTOM_MODE in VARCHAR2
) is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

 begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin

    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_TIMEZONES_TL
    where TIMEZONE_CODE = x_timezone_code
    and LANGUAGE = userenv('LANG');

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
         update FND_TIMEZONES_TL set
            NAME = X_NAME,
            LAST_UPDATE_DATE = f_ludate,
            LAST_UPDATED_BY = f_luby,
            LAST_UPDATE_LOGIN = 0,
            SOURCE_LANG = userenv('LANG')
          where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
          and TIMEZONE_CODE = x_TIMEZONE_CODE;
    end if;
  exception
    when no_data_found then
      null;
  end;
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_TIMEZONE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_GMT_OFFSET in NUMBER,
  X_DAYLIGHT_SAVINGS_FLAG in VARCHAR2,
  X_ACTIVE_TIMEZONE_CODE in VARCHAR2,
  X_UPGRADE_TZ_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
  user_id 	NUMBER;
  x_rowid 	VARCHAR2(64);
  f_luby    	number;  -- entity owner in file
  f_ludate  	date;    -- entity update date in file
  db_luby   	number;  -- entity owner in db
  db_ludate 	date;    -- entity update date in db

begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin

    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_TIMEZONES_B
    where TIMEZONE_CODE = X_TIMEZONE_CODE;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
  FND_TIMEZONES_PKG.UPDATE_ROW(
              x_timezone_code 		=> X_TIMEZONE_CODE,
              x_enabled_flag		=> X_ENABLED_FLAG,
              x_gmt_offset		=> X_GMT_OFFSET,
              x_daylight_savings_flag   => X_DAYLIGHT_SAVINGS_FLAG,
              x_active_timezone_code    => X_ACTIVE_TIMEZONE_CODE,
              x_upgrade_tz_id		=> X_UPGRADE_TZ_ID,
              x_name 			=> X_NAME,
              x_last_update_date	=> f_ludate,
              x_last_updated_by 	=> f_luby,
              x_last_update_login 	=> 0 );
	end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases
            Fnd_Timezones_Pkg.Insert_Row(
              x_rowid			=> x_rowid,
              x_timezone_code 		=> X_TIMEZONE_CODE,
              x_enabled_flag		=> X_ENABLED_FLAG,
              x_gmt_offset		=> X_GMT_OFFSET,
              x_daylight_savings_flag   => X_DAYLIGHT_SAVINGS_FLAG,
              x_active_timezone_code    => X_ACTIVE_TIMEZONE_CODE,
              x_upgrade_tz_id		=> X_UPGRADE_TZ_ID,
              x_name 			=> X_NAME,
	      x_creation_date		=> f_ludate,
              x_created_by              => f_luby,
              x_last_update_date	=> f_ludate,
              x_last_updated_by 	=> f_luby,
              x_last_update_login 	=> 0 );
  end;

end LOAD_ROW;

end FND_TIMEZONES_PKG;

/
