--------------------------------------------------------
--  DDL for Package Body BNE_QUERIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_QUERIES_PKG" as
/* $Header: bnequeriesb.pls 120.2 2005/06/29 03:40:48 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_QUERY_CLASS in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DIRECTIVE_APP_ID in NUMBER DEFAULT NULL,
  X_DIRECTIVE_CODE in VARCHAR2 DEFAULT NULL
) is
  cursor C is select ROWID from BNE_QUERIES_B
    where APPLICATION_ID = X_APPLICATION_ID
    and QUERY_CODE = X_QUERY_CODE
    ;
begin
  insert into BNE_QUERIES_B (
    APPLICATION_ID,
    QUERY_CODE,
    OBJECT_VERSION_NUMBER,
    QUERY_CLASS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DIRECTIVE_APP_ID,
    DIRECTIVE_CODE
  ) values (
    X_APPLICATION_ID,
    X_QUERY_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_QUERY_CLASS,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DIRECTIVE_APP_ID,
    X_DIRECTIVE_CODE
  );

  insert into BNE_QUERIES_TL (
    APPLICATION_ID,
    QUERY_CODE,
    USER_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_QUERY_CODE,
    X_USER_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BNE_QUERIES_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.QUERY_CODE = X_QUERY_CODE
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
  X_APPLICATION_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_QUERY_CLASS in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_DIRECTIVE_APP_ID in NUMBER DEFAULT NULL,
  X_DIRECTIVE_CODE in VARCHAR2 DEFAULT NULL
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      QUERY_CLASS,
      DIRECTIVE_APP_ID,
      DIRECTIVE_CODE
    from BNE_QUERIES_B
    where APPLICATION_ID = X_APPLICATION_ID
    and QUERY_CODE = X_QUERY_CODE
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BNE_QUERIES_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and QUERY_CODE = X_QUERY_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of APPLICATION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.QUERY_CLASS = X_QUERY_CLASS)
      AND ((recinfo.DIRECTIVE_APP_ID = X_DIRECTIVE_APP_ID)
           OR ((recinfo.DIRECTIVE_APP_ID is null) AND (X_DIRECTIVE_APP_ID is null)))
      AND ((recinfo.DIRECTIVE_CODE = X_DIRECTIVE_CODE)
           OR ((recinfo.DIRECTIVE_CODE is null) AND (X_DIRECTIVE_CODE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.USER_NAME = X_USER_NAME)
               OR ((tlinfo.USER_NAME is null) AND (X_USER_NAME is null)))
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
  X_APPLICATION_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_QUERY_CLASS in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DIRECTIVE_APP_ID in NUMBER DEFAULT NULL,
  X_DIRECTIVE_CODE in VARCHAR2 DEFAULT NULL
) is
begin
  update BNE_QUERIES_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    QUERY_CLASS = X_QUERY_CLASS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    DIRECTIVE_APP_ID = X_DIRECTIVE_APP_ID,
    DIRECTIVE_CODE = X_DIRECTIVE_CODE
  where APPLICATION_ID = X_APPLICATION_ID
  and QUERY_CODE = X_QUERY_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BNE_QUERIES_TL set
    USER_NAME = X_USER_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and QUERY_CODE = X_QUERY_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2
) is
begin
  delete from BNE_QUERIES_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and QUERY_CODE = X_QUERY_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BNE_QUERIES_B
  where APPLICATION_ID = X_APPLICATION_ID
  and QUERY_CODE = X_QUERY_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BNE_QUERIES_TL T
  where not exists
    (select NULL
    from BNE_QUERIES_B B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.QUERY_CODE = T.QUERY_CODE
    );

  update BNE_QUERIES_TL T set (
      USER_NAME
    ) = (select
      B.USER_NAME
    from BNE_QUERIES_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.QUERY_CODE = T.QUERY_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.QUERY_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.QUERY_CODE,
      SUBT.LANGUAGE
    from BNE_QUERIES_TL SUBB, BNE_QUERIES_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.QUERY_CODE = SUBT.QUERY_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_NAME <> SUBT.USER_NAME
      or (SUBB.USER_NAME is null and SUBT.USER_NAME is not null)
      or (SUBB.USER_NAME is not null and SUBT.USER_NAME is null)
  ));

  insert into BNE_QUERIES_TL (
    APPLICATION_ID,
    QUERY_CODE,
    USER_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.APPLICATION_ID,
    B.QUERY_CODE,
    B.USER_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BNE_QUERIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BNE_QUERIES_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.QUERY_CODE = B.QUERY_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


--------------------------------------------------------------------------------
--  PROCEDURE:   TRANSLATE_ROW                                                --
--                                                                            --
--  DESCRIPTION: Load a translation into the BNE_QUERIES entity.              --
--               This proc is called from the apps loader.                    --
--                                                                            --
--  SEE:   http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt         --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  21-Apr-04  DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure TRANSLATE_ROW(
  x_query_asn             IN VARCHAR2,
  x_query_code            IN VARCHAR2,
  x_user_name             IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2
)
is
  l_app_id          number;
  f_luby            number;  -- entity owner in file
  f_ludate          date;    -- entity update date in file
  db_luby           number;  -- entity owner in db
  db_ludate         date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_query_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_QUERIES_TL
    where APPLICATION_ID  = l_app_id
    and   QUERY_CODE      = x_query_code
    and   LANGUAGE        = userenv('LANG');

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then

      update BNE_QUERIES_TL
      set USER_NAME         = x_user_name,
          LAST_UPDATE_DATE  = f_ludate,
          LAST_UPDATED_BY   = f_luby,
          LAST_UPDATE_LOGIN = 0,
          SOURCE_LANG       = userenv('LANG')
      where APPLICATION_ID  = l_app_id
      AND   QUERY_CODE      = x_query_code
      AND   userenv('LANG') in (LANGUAGE, SOURCE_LANG)
      ;
    end if;
  exception
    when no_data_found then
      -- Do not insert missing translations, skip this row
      null;
  end;
end TRANSLATE_ROW;


--------------------------------------------------------------------------------
--  PROCEDURE:     LOAD_ROW                                                   --
--                                                                            --
--  DESCRIPTION:   Load a row into the BNE_QUERIES entity.                    --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt       --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  21-Apr-04  DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure LOAD_ROW(
  x_query_asn             IN VARCHAR2,
  x_query_code            IN VARCHAR2,
  x_object_version_number IN VARCHAR2,
  x_query_class           IN VARCHAR2,
  x_user_name             IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2,
  x_directive_asn         IN VARCHAR2 DEFAULT NULL,
  x_directive_code        IN VARCHAR2 DEFAULT NULL
)
is
  l_app_id            number;
  l_directive_app_id  number;
  l_row_id            varchar2(64);
  f_luby              number;  -- entity owner in file
  f_ludate            date;    -- entity update date in file
  db_luby             number;  -- entity owner in db
  db_ludate           date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id             := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_query_asn);
  l_directive_app_id   := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_directive_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_QUERIES_B
    where APPLICATION_ID  = l_app_id
    and   QUERY_CODE      = x_query_code;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_QUERIES_PKG.Update_Row(
        X_APPLICATION_ID        => l_app_id,
        X_QUERY_CODE            => x_query_code,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_QUERY_CLASS           => x_query_class,
        X_USER_NAME             => x_user_name,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0,
        X_DIRECTIVE_APP_ID      => l_directive_app_id,
        X_DIRECTIVE_CODE        => x_directive_code
      );

    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_QUERIES_PKG.Insert_Row(
        X_ROWID                 => l_row_id,
        X_APPLICATION_ID        => l_app_id,
        X_QUERY_CODE            => x_query_code,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_QUERY_CLASS           => x_query_class,
        X_USER_NAME             => x_user_name,
        X_CREATION_DATE         => f_ludate,
        X_CREATED_BY            => f_luby,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0,
        X_DIRECTIVE_APP_ID      => l_directive_app_id,
        X_DIRECTIVE_CODE        => x_directive_code
      );
  end;
end LOAD_ROW;


end BNE_QUERIES_PKG;

/
