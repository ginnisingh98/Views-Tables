--------------------------------------------------------
--  DDL for Package Body FND_OAM_CHARTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_CHARTS_PKG" AS
  /* $Header: AFOAMCTB.pls 115.1 2004/04/14 04:33:25 bhosingh noship $ */
  procedure LOAD_ROW (
  X_CHART_ID in NUMBER,
  X_CHART_GROUP_ID in NUMBER,
  X_DISPLAY_ORDER in NUMBER,
  X_ALLOW_CONFIG in VARCHAR2,
  X_REFRESH_INTERVAL in NUMBER,
  X_REFRESH_TYPE in VARCHAR2,
  X_CHART_TYPE in VARCHAR2,
  X_OWNER in	VARCHAR2,
  X_CHART_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2) is
  begin

     FND_OAM_CHARTS_PKG.LOAD_ROW (
       X_CHART_ID => X_CHART_ID,
       X_CHART_GROUP_ID => X_CHART_GROUP_ID,
       X_DISPLAY_ORDER => X_DISPLAY_ORDER,
       X_ALLOW_CONFIG       => X_ALLOW_CONFIG,
       X_REFRESH_INTERVAL       => X_REFRESH_INTERVAL,
       X_REFRESH_TYPE       => X_REFRESH_TYPE,
       X_CHART_TYPE       => X_CHART_TYPE,
       X_OWNER       => X_OWNER,
       X_CHART_NAME => X_CHART_NAME,
       X_DESCRIPTION => X_DESCRIPTION,
       x_custom_mode => '',
       x_last_update_date => '');

  end LOAD_ROW;

  procedure LOAD_ROW (
  X_CHART_ID in NUMBER,
  X_CHART_GROUP_ID in NUMBER,
  X_DISPLAY_ORDER in NUMBER,
  X_ALLOW_CONFIG in VARCHAR2,
  X_REFRESH_INTERVAL in NUMBER,
  X_REFRESH_TYPE in VARCHAR2,
  X_CHART_TYPE in VARCHAR2,
  X_OWNER in	VARCHAR2,
  X_CHART_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  x_custom_mode         in      varchar2,
  x_last_update_date    in      varchar2) is

      mgroup_id number;
      row_id varchar2(64);
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
	-- check if this chart id already exists.
	select chart_id, LAST_UPDATED_BY, LAST_UPDATE_DATE
	into mgroup_id, db_luby, db_ludate
	from   fnd_oam_charts
    where  chart_id = to_number(X_CHART_ID);

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        FND_OAM_CHARTS_PKG.UPDATE_ROW (
          X_CHART_ID => mgroup_id,
          X_CHART_GROUP_ID => to_number(X_CHART_GROUP_ID),
          X_DISPLAY_ORDER => to_number(X_DISPLAY_ORDER),
          X_ALLOW_CONFIG => X_ALLOW_CONFIG,
          X_REFRESH_INTERVAL => to_number(X_REFRESH_INTERVAL),
          X_REFRESH_TYPE => X_REFRESH_TYPE,
          X_CHART_TYPE => X_CHART_TYPE,
          X_CHART_NAME => X_CHART_NAME,
          X_DESCRIPTION => X_DESCRIPTION,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
        end if;
      exception
        when NO_DATA_FOUND then

        FND_OAM_CHARTS_PKG.INSERT_ROW (
          X_ROWID => row_id,
          X_CHART_ID => to_number(X_CHART_ID),
          X_CHART_GROUP_ID => to_number(X_CHART_GROUP_ID),
          X_DISPLAY_ORDER => to_number(X_DISPLAY_ORDER),
          X_ALLOW_CONFIG => X_ALLOW_CONFIG,
          X_REFRESH_INTERVAL => to_number(X_REFRESH_INTERVAL),
          X_REFRESH_TYPE => X_REFRESH_TYPE,
          X_CHART_TYPE => X_CHART_TYPE,
          X_CHART_NAME => X_CHART_NAME,
          X_DESCRIPTION => X_DESCRIPTION,
          X_CREATION_DATE => f_ludate,
          X_CREATED_BY => f_luby,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
    end;
  end LOAD_ROW;

  procedure TRANSLATE_ROW (
    X_CHART_ID in NUMBER,
    X_CHART_NAME in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_OWNER in	VARCHAR2) is
  begin

  FND_OAM_CHARTS_PKG.translate_row(
    X_CHART_ID => X_CHART_ID,
    X_CHART_NAME => X_CHART_NAME,
    x_description => x_description,
    x_owner => x_owner,
    x_custom_mode => '',
    x_last_update_date => '');

  end TRANSLATE_ROW;


  procedure TRANSLATE_ROW (
    X_CHART_ID in NUMBER,
    X_CHART_NAME in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_OWNER in	VARCHAR2,
    X_CUSTOM_MODE		in	VARCHAR2,
    X_LAST_UPDATE_DATE	in	VARCHAR2) is

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
      from fnd_oam_charts_tl
      where chart_id = to_number(X_CHART_ID)
      and LANGUAGE = userenv('LANG');

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        update fnd_oam_charts_tl set
          chart_name    = nvl(X_CHART_NAME, chart_name),
          description         = nvl(X_DESCRIPTION, description),
          source_lang         = userenv('LANG'),
          last_update_date    = f_ludate,
          last_updated_by     = f_luby,
          last_update_login   = 0
        where chart_id = to_number(X_CHART_ID)
          and userenv('LANG') in (language, source_lang);
      end if;
    exception
      when no_data_found then
        null;
    end;

  end TRANSLATE_ROW;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CHART_ID in NUMBER,
  X_CHART_GROUP_ID in NUMBER,
  X_DISPLAY_ORDER in NUMBER,
  X_ALLOW_CONFIG in VARCHAR2,
  X_REFRESH_INTERVAL in NUMBER,
  X_REFRESH_TYPE in VARCHAR2,
  X_CHART_TYPE in VARCHAR2,
  X_CHART_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_OAM_CHARTS
    where CHART_ID = X_CHART_ID
    ;
begin
  insert into FND_OAM_CHARTS (
    CHART_ID,
    CHART_GROUP_ID,
    DISPLAY_ORDER,
    ALLOW_CONFIG,
    REFRESH_INTERVAL,
    REFRESH_TYPE,
    CHART_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CHART_ID,
    X_CHART_GROUP_ID,
    X_DISPLAY_ORDER,
    X_ALLOW_CONFIG,
    X_REFRESH_INTERVAL,
    X_REFRESH_TYPE,
    X_CHART_TYPE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_OAM_CHARTS_TL (
    CHART_ID,
    CHART_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CHART_ID,
    X_CHART_NAME,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_OAM_CHARTS_TL T
    where T.CHART_ID = X_CHART_ID
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
  X_CHART_ID in NUMBER,
  X_CHART_GROUP_ID in NUMBER,
  X_DISPLAY_ORDER in NUMBER,
  X_ALLOW_CONFIG in VARCHAR2,
  X_REFRESH_INTERVAL in NUMBER,
  X_REFRESH_TYPE in VARCHAR2,
  X_CHART_TYPE in VARCHAR2,
  X_CHART_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      CHART_GROUP_ID,
      DISPLAY_ORDER,
      ALLOW_CONFIG,
      REFRESH_INTERVAL,
      REFRESH_TYPE,
      CHART_TYPE
    from FND_OAM_CHARTS
    where CHART_ID = X_CHART_ID
    for update of CHART_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CHART_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_OAM_CHARTS_TL
    where CHART_ID = X_CHART_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CHART_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.CHART_GROUP_ID = X_CHART_GROUP_ID)
      AND (recinfo.DISPLAY_ORDER = X_DISPLAY_ORDER)
      AND (recinfo.ALLOW_CONFIG = X_ALLOW_CONFIG)
      AND (recinfo.REFRESH_INTERVAL = X_REFRESH_INTERVAL)
      AND (recinfo.REFRESH_TYPE = X_REFRESH_TYPE)
      AND (recinfo.CHART_TYPE = X_CHART_TYPE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CHART_NAME = X_CHART_NAME)
          AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_CHART_ID in NUMBER,
  X_CHART_GROUP_ID in NUMBER,
  X_DISPLAY_ORDER in NUMBER,
  X_ALLOW_CONFIG in VARCHAR2,
  X_REFRESH_INTERVAL in NUMBER,
  X_REFRESH_TYPE in VARCHAR2,
  X_CHART_TYPE in VARCHAR2,
  X_CHART_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_OAM_CHARTS set
    CHART_GROUP_ID = X_CHART_GROUP_ID,
    DISPLAY_ORDER = X_DISPLAY_ORDER,
    ALLOW_CONFIG = X_ALLOW_CONFIG,
    REFRESH_INTERVAL = X_REFRESH_INTERVAL,
    REFRESH_TYPE = X_REFRESH_TYPE,
    CHART_TYPE = X_CHART_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CHART_ID = X_CHART_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_OAM_CHARTS_TL set
    CHART_NAME = X_CHART_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CHART_ID = X_CHART_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CHART_ID in NUMBER
) is
begin
  delete from FND_OAM_CHARTS_TL
  where CHART_ID = X_CHART_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_OAM_CHARTS
  where CHART_ID = X_CHART_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*
  delete from FND_OAM_CHARTS_TL T
  where not exists
    (select NULL
    from FND_OAM_CHARTS B
    where B.CHART_ID = T.CHART_ID
    );

  update FND_OAM_CHARTS_TL T set (
      CHART_NAME,
      DESCRIPTION
    ) = (select
      B.CHART_NAME,
      B.DESCRIPTION
    from FND_OAM_CHARTS_TL B
    where B.CHART_ID = T.CHART_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CHART_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CHART_ID,
      SUBT.LANGUAGE
    from FND_OAM_CHARTS_TL SUBB, FND_OAM_CHARTS_TL SUBT
    where SUBB.CHART_ID = SUBT.CHART_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CHART_NAME <> SUBT.CHART_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  */

  insert into FND_OAM_CHARTS_TL (
    CHART_ID,
    CHART_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CHART_ID,
    B.CHART_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_OAM_CHARTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_OAM_CHARTS_TL T
    where T.CHART_ID = B.CHART_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_OAM_CHARTS_PKG;

/
