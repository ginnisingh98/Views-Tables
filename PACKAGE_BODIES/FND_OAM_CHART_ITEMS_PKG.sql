--------------------------------------------------------
--  DDL for Package Body FND_OAM_CHART_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_CHART_ITEMS_PKG" AS
  /* $Header: AFOAMCIB.pls 120.1 2005/07/02 04:12:38 appldev noship $ */
  procedure LOAD_ROW (
  X_CHART_ITEM_SHORT_NAME in VARCHAR2,
  X_USER_ID in NUMBER,
  X_CHART_ID in NUMBER,
  X_SELECTED in VARCHAR2,
  X_OWNER in	VARCHAR2,
  X_CHART_ITEM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2) is
  begin

     FND_OAM_CHART_ITEMS_PKG.LOAD_ROW (
       X_CHART_ITEM_SHORT_NAME => X_CHART_ITEM_SHORT_NAME,
       X_USER_ID => X_USER_ID,
       X_CHART_ID => X_CHART_ID,
       X_SELECTED       => X_SELECTED,
       X_OWNER       => X_OWNER,
       X_CHART_ITEM_NAME => X_CHART_ITEM_NAME,
       X_DESCRIPTION => X_DESCRIPTION,
       x_custom_mode => '',
       x_last_update_date => '');

  end LOAD_ROW;

  procedure LOAD_ROW (
  X_CHART_ITEM_SHORT_NAME in VARCHAR2,
  X_USER_ID in NUMBER,
  X_CHART_ID in NUMBER,
  X_SELECTED in VARCHAR2,
  X_OWNER in	VARCHAR2,
  X_CHART_ITEM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  x_custom_mode         in      varchar2,
  x_last_update_date    in      varchar2) is

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
	select LAST_UPDATED_BY, LAST_UPDATE_DATE
	into db_luby, db_ludate
	from   fnd_oam_chart_items
    where  chart_item_short_name = X_CHART_ITEM_SHORT_NAME
      AND USER_ID = TO_NUMBER(X_USER_ID)
      AND CHART_ID = TO_NUMBER(X_CHART_ID);

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        FND_OAM_CHART_ITEMS_PKG.UPDATE_ROW (
          X_CHART_ITEM_SHORT_NAME => X_CHART_ITEM_SHORT_NAME,
          X_USER_ID => to_number(X_USER_ID),
          X_CHART_ID => to_number(X_CHART_ID),
          X_SELECTED => X_SELECTED,
          X_CHART_ITEM_NAME => X_CHART_ITEM_NAME,
          X_DESCRIPTION => X_DESCRIPTION,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
        end if;
      exception
        when NO_DATA_FOUND then

        FND_OAM_CHART_ITEMS_PKG.INSERT_ROW (
          X_ROWID => row_id,
          X_CHART_ITEM_SHORT_NAME => X_CHART_ITEM_SHORT_NAME,
          X_USER_ID => to_number(X_USER_ID),
          X_CHART_ID => to_number(X_CHART_ID),
          X_SELECTED => X_SELECTED,
          X_CHART_ITEM_NAME => X_CHART_ITEM_NAME,
          X_DESCRIPTION => X_DESCRIPTION,
          X_CREATION_DATE => f_ludate,
          X_CREATED_BY => f_luby,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
    end;
  end LOAD_ROW;

  procedure TRANSLATE_ROW (
    X_CHART_ITEM_SHORT_NAME in VARCHAR2,
    X_CHART_ITEM_NAME in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_OWNER in	VARCHAR2) is
  begin

  FND_OAM_CHART_ITEMS_PKG.translate_row(
    X_CHART_ITEM_SHORT_NAME => X_CHART_ITEM_SHORT_NAME,
    X_CHART_ITEM_NAME => X_CHART_ITEM_NAME,
    x_description => x_description,
    x_owner => x_owner,
    x_custom_mode => '',
    x_last_update_date => '');

  end TRANSLATE_ROW;


  procedure TRANSLATE_ROW (
    X_CHART_ITEM_SHORT_NAME in VARCHAR2,
    X_CHART_ITEM_NAME in VARCHAR2,
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
      from fnd_oam_chart_items_tl
      where chart_item_short_name = X_CHART_ITEM_SHORT_NAME
      and LANGUAGE = userenv('LANG');

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        update fnd_oam_chart_items_tl set
          chart_item_name    = nvl(X_CHART_ITEM_NAME, chart_item_name),
          description         = nvl(X_DESCRIPTION, description),
          source_lang         = userenv('LANG'),
          last_update_date    = f_ludate,
          last_updated_by     = f_luby,
          last_update_login   = 0
        where chart_item_short_name = X_CHART_ITEM_SHORT_NAME
          and userenv('LANG') in (language, source_lang);
      end if;
    exception
      when no_data_found then
        null;
    end;

  end TRANSLATE_ROW;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CHART_ITEM_SHORT_NAME in VARCHAR2,
  X_USER_ID in NUMBER,
  X_CHART_ID in NUMBER,
  X_SELECTED in VARCHAR2,
  X_CHART_ITEM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_OAM_CHART_ITEMS
    where CHART_ITEM_SHORT_NAME = X_CHART_ITEM_SHORT_NAME
    and USER_ID = X_USER_ID
    and CHART_ID = X_CHART_ID
    ;

begin
  insert into FND_OAM_CHART_ITEMS (
    CHART_ITEM_SHORT_NAME,
    USER_ID,
    CHART_ID,
    SELECTED,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) values (
    X_CHART_ITEM_SHORT_NAME,
    X_USER_ID,
    X_CHART_ID,
    X_SELECTED,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_OAM_CHART_ITEMS_TL (
    CHART_ITEM_SHORT_NAME,
    CHART_ITEM_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CHART_ITEM_SHORT_NAME,
    X_CHART_ITEM_NAME,
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
    from FND_OAM_CHART_ITEMS_TL T
    where T.CHART_ITEM_SHORT_NAME = X_CHART_ITEM_SHORT_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;


procedure UPDATE_ROW (
  X_CHART_ITEM_SHORT_NAME in VARCHAR2,
  X_USER_ID in NUMBER,
  X_CHART_ID in NUMBER,
  X_SELECTED in VARCHAR2,
  X_CHART_ITEM_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_OAM_CHART_ITEMS set
    SELECTED = X_SELECTED,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CHART_ITEM_SHORT_NAME = X_CHART_ITEM_SHORT_NAME
  and USER_ID = X_USER_ID
  and CHART_ID = X_CHART_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_OAM_CHART_ITEMS_TL set
    CHART_ITEM_NAME = X_CHART_ITEM_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CHART_ITEM_SHORT_NAME = X_CHART_ITEM_SHORT_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


procedure DELETE_ROW (
  X_CHART_ITEM_SHORT_NAME in VARCHAR2,
  X_USER_ID in NUMBER,
  X_CHART_ID in NUMBER
) is
begin
  delete from FND_OAM_CHART_ITEMS
  where CHART_ITEM_SHORT_NAME = X_CHART_ITEM_SHORT_NAME
  and USER_ID = X_USER_ID
  and CHART_ID = X_CHART_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_OAM_CHART_ITEMS_TL
  where CHART_ITEM_SHORT_NAME = X_CHART_ITEM_SHORT_NAME;

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
  delete from FND_OAM_CHART_ITEMS_TL T
  where not exists
    (select NULL
    from FND_OAM_CHART_ITEMS B
    where B.CHART_ITEM_SHORT_NAME = T.CHART_ITEM_SHORT_NAME
    );

  update FND_OAM_CHART_ITEMS_TL T set (
      CHART_ITEM_NAME,
      DESCRIPTION
    ) = (select
      B.CHART_ITEM_NAME,
      B.DESCRIPTION
    from FND_OAM_CHART_ITEMS_TL B
    where B.CHART_ITEM_SHORT_NAME = T.CHART_ITEM_SHORT_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CHART_ITEM_SHORT_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.CHART_ITEM_SHORT_NAME,
      SUBT.LANGUAGE
    from FND_OAM_CHART_ITEMS_TL SUBB, FND_OAM_CHART_ITEMS_TL SUBT
    where SUBB.CHART_ITEM_SHORT_NAME = SUBT.CHART_ITEM_SHORT_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CHART_ITEM_NAME <> SUBT.CHART_ITEM_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/
  insert into FND_OAM_CHART_ITEMS_TL (
    CHART_ITEM_SHORT_NAME,
    CHART_ITEM_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CHART_ITEM_SHORT_NAME,
    B.CHART_ITEM_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_OAM_CHART_ITEMS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_OAM_CHART_ITEMS_TL T
    where T.CHART_ITEM_SHORT_NAME = B.CHART_ITEM_SHORT_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_OAM_CHART_ITEMS_PKG;

/
