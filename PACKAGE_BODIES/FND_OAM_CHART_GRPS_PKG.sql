--------------------------------------------------------
--  DDL for Package Body FND_OAM_CHART_GRPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_CHART_GRPS_PKG" AS
  /* $Header: AFOAMCGB.pls 115.1 2004/04/14 04:32:49 bhosingh noship $ */
  procedure LOAD_ROW (
  X_CHART_GROUP_ID in NUMBER,
  X_CHART_GROUP_SHORT_NAME in VARCHAR2,
  X_PARENT_GROUP_ID in NUMBER,
  X_DISPLAY_ORDER in NUMBER,
  X_OWNER in	VARCHAR2,
  X_CHART_GROUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2) is
  begin

     FND_OAM_CHART_GRPS_PKG.LOAD_ROW (
       X_CHART_GROUP_ID => X_CHART_GROUP_ID,
       X_CHART_GROUP_SHORT_NAME => X_CHART_GROUP_SHORT_NAME,
       X_PARENT_GROUP_ID => X_PARENT_GROUP_ID,
       X_DISPLAY_ORDER => X_DISPLAY_ORDER,
       X_OWNER       => X_OWNER,
       X_CHART_GROUP_NAME => X_CHART_GROUP_NAME,
       X_DESCRIPTION => X_DESCRIPTION,
       x_custom_mode => '',
       x_last_update_date => '');

  end LOAD_ROW;

  procedure LOAD_ROW (
   X_CHART_GROUP_ID in NUMBER,
   X_CHART_GROUP_SHORT_NAME in VARCHAR2,
   X_PARENT_GROUP_ID in NUMBER,
   X_DISPLAY_ORDER in NUMBER,
   X_OWNER in	VARCHAR2,
   X_CHART_GROUP_NAME in VARCHAR2,
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
	-- check if this chart group id already exists.
	select chart_group_id, LAST_UPDATED_BY, LAST_UPDATE_DATE
	into mgroup_id, db_luby, db_ludate
	from   fnd_oam_chart_grps
    where  chart_group_id = to_number(X_CHART_GROUP_ID);

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        FND_OAM_CHART_GRPS_PKG.UPDATE_ROW (
          X_CHART_GROUP_ID => mgroup_id,
          X_CHART_GROUP_SHORT_NAME => X_CHART_GROUP_SHORT_NAME,
          X_PARENT_GROUP_ID => to_number(X_PARENT_GROUP_ID),
          X_DISPLAY_ORDER => to_number(X_DISPLAY_ORDER),
          X_CHART_GROUP_NAME => X_CHART_GROUP_NAME,
          X_DESCRIPTION => X_DESCRIPTION,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
        end if;
      exception
        when NO_DATA_FOUND then

        FND_OAM_CHART_GRPS_PKG.INSERT_ROW (
          X_ROWID => row_id,
          X_CHART_GROUP_ID => to_number(X_CHART_GROUP_ID),
          X_CHART_GROUP_SHORT_NAME => X_CHART_GROUP_SHORT_NAME,
          X_PARENT_GROUP_ID => to_number(X_PARENT_GROUP_ID),
          X_DISPLAY_ORDER => to_number(X_DISPLAY_ORDER),
          X_CHART_GROUP_NAME => X_CHART_GROUP_NAME,
          X_DESCRIPTION => X_DESCRIPTION,
          X_CREATION_DATE => f_ludate,
          X_CREATED_BY => f_luby,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
    end;
  end LOAD_ROW;

  procedure TRANSLATE_ROW (
    X_CHART_GROUP_ID in NUMBER,
    X_CHART_GROUP_NAME in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_OWNER in	VARCHAR2) is
  begin

  FND_OAM_CHART_GRPS_PKG.translate_row(
    X_CHART_GROUP_ID => X_CHART_GROUP_ID,
    X_CHART_GROUP_NAME => X_CHART_GROUP_NAME,
    x_description => x_description,
    x_owner => x_owner,
    x_custom_mode => '',
    x_last_update_date => '');

  end TRANSLATE_ROW;


  procedure TRANSLATE_ROW (
    X_CHART_GROUP_ID in NUMBER,
    X_CHART_GROUP_NAME in VARCHAR2,
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
      from fnd_oam_chart_grps_tl
      where chart_group_id = to_number(X_CHART_GROUP_ID)
      and LANGUAGE = userenv('LANG');

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        update fnd_oam_chart_grps_tl set
          chart_group_name    = nvl(X_CHART_GROUP_NAME, chart_group_name),
          description         = nvl(X_DESCRIPTION, description),
          source_lang         = userenv('LANG'),
          last_update_date    = f_ludate,
          last_updated_by     = f_luby,
          last_update_login   = 0
        where chart_group_id = to_number(X_CHART_GROUP_ID)
          and userenv('LANG') in (language, source_lang);
      end if;
    exception
      when no_data_found then
        null;
    end;

  end TRANSLATE_ROW;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CHART_GROUP_ID in NUMBER,
  X_CHART_GROUP_SHORT_NAME in VARCHAR2,
  X_PARENT_GROUP_ID in NUMBER,
  X_DISPLAY_ORDER in NUMBER,
  X_CHART_GROUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_OAM_CHART_GRPS
    where CHART_GROUP_ID = X_CHART_GROUP_ID
    ;
begin
  insert into FND_OAM_CHART_GRPS (
    CHART_GROUP_ID,
    CHART_GROUP_SHORT_NAME,
    PARENT_GROUP_ID,
    DISPLAY_ORDER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CHART_GROUP_ID,
    X_CHART_GROUP_SHORT_NAME,
    X_PARENT_GROUP_ID,
    X_DISPLAY_ORDER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_OAM_CHART_GRPS_TL (
    CHART_GROUP_ID,
    CHART_GROUP_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CHART_GROUP_ID,
    X_CHART_GROUP_NAME,
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
    from FND_OAM_CHART_GRPS_TL T
    where T.CHART_GROUP_ID = X_CHART_GROUP_ID
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
  X_CHART_GROUP_ID in NUMBER,
  X_CHART_GROUP_SHORT_NAME in VARCHAR2,
  X_PARENT_GROUP_ID in NUMBER,
  X_DISPLAY_ORDER in NUMBER,
  X_CHART_GROUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      CHART_GROUP_SHORT_NAME,
      PARENT_GROUP_ID,
      DISPLAY_ORDER
    from FND_OAM_CHART_GRPS
    where CHART_GROUP_ID = X_CHART_GROUP_ID
    for update of CHART_GROUP_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CHART_GROUP_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_OAM_CHART_GRPS_TL
    where CHART_GROUP_ID = X_CHART_GROUP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CHART_GROUP_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.CHART_GROUP_SHORT_NAME = X_CHART_GROUP_SHORT_NAME)
      AND ((recinfo.PARENT_GROUP_ID = X_PARENT_GROUP_ID)
           OR ((recinfo.PARENT_GROUP_ID is null) AND (X_PARENT_GROUP_ID is null)))
      AND (recinfo.DISPLAY_ORDER = X_DISPLAY_ORDER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CHART_GROUP_NAME = X_CHART_GROUP_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_CHART_GROUP_ID in NUMBER,
  X_CHART_GROUP_SHORT_NAME in VARCHAR2,
  X_PARENT_GROUP_ID in NUMBER,
  X_DISPLAY_ORDER in NUMBER,
  X_CHART_GROUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_OAM_CHART_GRPS set
    CHART_GROUP_SHORT_NAME = X_CHART_GROUP_SHORT_NAME,
    PARENT_GROUP_ID = X_PARENT_GROUP_ID,
    DISPLAY_ORDER = X_DISPLAY_ORDER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CHART_GROUP_ID = X_CHART_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_OAM_CHART_GRPS_TL set
    CHART_GROUP_NAME = X_CHART_GROUP_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CHART_GROUP_ID = X_CHART_GROUP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CHART_GROUP_ID in NUMBER
) is
begin
  delete from FND_OAM_CHART_GRPS_TL
  where CHART_GROUP_ID = X_CHART_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_OAM_CHART_GRPS
  where CHART_GROUP_ID = X_CHART_GROUP_ID;

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
  delete from FND_OAM_CHART_GRPS_TL T
  where not exists
    (select NULL
    from FND_OAM_CHART_GRPS B
    where B.CHART_GROUP_ID = T.CHART_GROUP_ID
    );

  update FND_OAM_CHART_GRPS_TL T set (
      CHART_GROUP_NAME,
      DESCRIPTION
    ) = (select
      B.CHART_GROUP_NAME,
      B.DESCRIPTION
    from FND_OAM_CHART_GRPS_TL B
    where B.CHART_GROUP_ID = T.CHART_GROUP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CHART_GROUP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CHART_GROUP_ID,
      SUBT.LANGUAGE
    from FND_OAM_CHART_GRPS_TL SUBB, FND_OAM_CHART_GRPS_TL SUBT
    where SUBB.CHART_GROUP_ID = SUBT.CHART_GROUP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CHART_GROUP_NAME <> SUBT.CHART_GROUP_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/
  insert into FND_OAM_CHART_GRPS_TL (
    CHART_GROUP_ID,
    CHART_GROUP_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CHART_GROUP_ID,
    B.CHART_GROUP_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_OAM_CHART_GRPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_OAM_CHART_GRPS_TL T
    where T.CHART_GROUP_ID = B.CHART_GROUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_OAM_CHART_GRPS_PKG;

/
