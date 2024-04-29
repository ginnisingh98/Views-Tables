--------------------------------------------------------
--  DDL for Package Body BNE_CACHE_DIRECTIVES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_CACHE_DIRECTIVES_PKG" as
/* $Header: bnecadb.pls 120.3 2005/06/29 03:39:41 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DIRECTIVE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MAX_AGE in VARCHAR2,
  X_MAX_SIZE in NUMBER,
  X_MAX_HITS in NUMBER,
  X_DISCRIMINATOR_TYPE in VARCHAR2,
  X_DISCRIMINATOR_VALUE in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BNE_CACHE_DIRECTIVES_B
    where APPLICATION_ID = X_APPLICATION_ID
    and DIRECTIVE_CODE = X_DIRECTIVE_CODE
    ;
begin
  insert into BNE_CACHE_DIRECTIVES_B (
    MAX_AGE,
    DISCRIMINATOR_TYPE,
    DISCRIMINATOR_VALUE,
    APPLICATION_ID,
    DIRECTIVE_CODE,
    OBJECT_VERSION_NUMBER,
    MAX_SIZE,
    MAX_HITS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_MAX_AGE,
    X_DISCRIMINATOR_TYPE,
    X_DISCRIMINATOR_VALUE,
    X_APPLICATION_ID,
    X_DIRECTIVE_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_MAX_SIZE,
    X_MAX_HITS,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into BNE_CACHE_DIRECTIVES_TL (
    APPLICATION_ID,
    DIRECTIVE_CODE,
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
    X_DIRECTIVE_CODE,
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
    from BNE_CACHE_DIRECTIVES_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.DIRECTIVE_CODE = X_DIRECTIVE_CODE
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
  X_DIRECTIVE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MAX_AGE in VARCHAR2,
  X_MAX_SIZE in NUMBER,
  X_MAX_HITS in NUMBER,
  X_DISCRIMINATOR_TYPE in VARCHAR2,
  X_DISCRIMINATOR_VALUE in VARCHAR2,
  X_USER_NAME in VARCHAR2
) is
  cursor c is select
      MAX_AGE,
      DISCRIMINATOR_TYPE,
      DISCRIMINATOR_VALUE,
      OBJECT_VERSION_NUMBER,
      MAX_SIZE,
      MAX_HITS
    from BNE_CACHE_DIRECTIVES_B
    where APPLICATION_ID = X_APPLICATION_ID
    and DIRECTIVE_CODE = X_DIRECTIVE_CODE
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BNE_CACHE_DIRECTIVES_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and DIRECTIVE_CODE = X_DIRECTIVE_CODE
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
  if (    (recinfo.MAX_AGE = X_MAX_AGE)
      AND ((recinfo.DISCRIMINATOR_TYPE = X_DISCRIMINATOR_TYPE)
           OR ((recinfo.DISCRIMINATOR_TYPE is null) AND (X_DISCRIMINATOR_TYPE is null)))
      AND ((recinfo.DISCRIMINATOR_VALUE = X_DISCRIMINATOR_VALUE)
           OR ((recinfo.DISCRIMINATOR_VALUE is null) AND (X_DISCRIMINATOR_VALUE is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.MAX_SIZE = X_MAX_SIZE)
           OR ((recinfo.MAX_SIZE is null) AND (X_MAX_SIZE is null)))
      AND (recinfo.MAX_HITS = X_MAX_HITS)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.USER_NAME = X_USER_NAME)
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
  X_DIRECTIVE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MAX_AGE in VARCHAR2,
  X_MAX_SIZE in NUMBER,
  X_MAX_HITS in NUMBER,
  X_DISCRIMINATOR_TYPE in VARCHAR2,
  X_DISCRIMINATOR_VALUE in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BNE_CACHE_DIRECTIVES_B set
    MAX_AGE = X_MAX_AGE,
    DISCRIMINATOR_TYPE = X_DISCRIMINATOR_TYPE,
    DISCRIMINATOR_VALUE = X_DISCRIMINATOR_VALUE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    MAX_SIZE = X_MAX_SIZE,
    MAX_HITS = X_MAX_HITS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and DIRECTIVE_CODE = X_DIRECTIVE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BNE_CACHE_DIRECTIVES_TL set
    USER_NAME = X_USER_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and DIRECTIVE_CODE = X_DIRECTIVE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DIRECTIVE_CODE in VARCHAR2
) is
begin
  delete from BNE_CACHE_DIRECTIVES_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and DIRECTIVE_CODE = X_DIRECTIVE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BNE_CACHE_DIRECTIVES_B
  where APPLICATION_ID = X_APPLICATION_ID
  and DIRECTIVE_CODE = X_DIRECTIVE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BNE_CACHE_DIRECTIVES_TL T
  where not exists
    (select NULL
    from BNE_CACHE_DIRECTIVES_B B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.DIRECTIVE_CODE = T.DIRECTIVE_CODE
    );

  update BNE_CACHE_DIRECTIVES_TL T set (
      USER_NAME
    ) = (select
      B.USER_NAME
    from BNE_CACHE_DIRECTIVES_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.DIRECTIVE_CODE = T.DIRECTIVE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.DIRECTIVE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.DIRECTIVE_CODE,
      SUBT.LANGUAGE
    from BNE_CACHE_DIRECTIVES_TL SUBB, BNE_CACHE_DIRECTIVES_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.DIRECTIVE_CODE = SUBT.DIRECTIVE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_NAME <> SUBT.USER_NAME
  ));

  insert into BNE_CACHE_DIRECTIVES_TL (
    APPLICATION_ID,
    DIRECTIVE_CODE,
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
    B.DIRECTIVE_CODE,
    B.USER_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BNE_CACHE_DIRECTIVES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BNE_CACHE_DIRECTIVES_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.DIRECTIVE_CODE = B.DIRECTIVE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--------------------------------------------------------------------------------
--  PROCEDURE:   TRANSLATE_ROW                                                --
--                                                                            --
--  DESCRIPTION: Load a translation into the BNE_CACHE_DIRECTIVES entity.     --
--               This proc is called from the apps loader.                    --
--                                                                            --
--  SEE:   http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt         --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  30-Mar-05  DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure TRANSLATE_ROW(
  x_directive_asn         in VARCHAR2,
  x_directive_code        in VARCHAR2,
  x_user_name             in VARCHAR2,
  x_owner                 in VARCHAR2,
  x_last_update_date      in VARCHAR2,
  x_custom_mode           in VARCHAR2
)
is
  l_app_id          number;
  f_luby            number;  -- entity owner in file
  f_ludate          date;    -- entity update date in file
  db_luby           number;  -- entity owner in db
  db_ludate         date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_directive_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_CACHE_DIRECTIVES_TL
    where APPLICATION_ID  = l_app_id
    and   DIRECTIVE_CODE  = x_directive_code
    and   LANGUAGE        = userenv('LANG');

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then

      update BNE_CACHE_DIRECTIVES_TL
      set USER_NAME         = x_user_name,
          LAST_UPDATE_DATE  = f_ludate,
          LAST_UPDATED_BY   = f_luby,
          LAST_UPDATE_LOGIN = 0,
          SOURCE_LANG       = userenv('LANG')
      where APPLICATION_ID   = l_app_id
      AND   DIRECTIVE_CODE   = x_directive_code
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
--  DESCRIPTION:   Load a row into the BNE_CACHE_DIRECTIVES entity.           --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt       --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  30-Mar-05  DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure LOAD_ROW(
  x_directive_asn               in VARCHAR2,
  x_directive_code              in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_max_age                     in VARCHAR2,
  x_max_size                    in NUMBER,
  x_max_hits                    in NUMBER,
  x_discriminator_type          in VARCHAR2,
  x_discriminator_value         in VARCHAR2,
  x_user_name                   in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
)
is
  l_app_id                    number;
  l_row_id                    varchar2(64);
  f_luby                      number;  -- entity owner in file
  f_ludate                    date;    -- entity update date in file
  db_luby                     number;  -- entity owner in db
  db_ludate                   date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id                   := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_directive_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_CACHE_DIRECTIVES_B
    where APPLICATION_ID  = l_app_id
    and   DIRECTIVE_CODE  = x_directive_code;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_CACHE_DIRECTIVES_PKG.Update_Row(
        X_APPLICATION_ID               => l_app_id,
        X_DIRECTIVE_CODE               => x_directive_code,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_MAX_AGE                      => x_max_age,
        X_MAX_SIZE                     => x_max_size,
        X_MAX_HITS                     => x_max_hits,
        X_DISCRIMINATOR_TYPE           => x_discriminator_type,
        X_DISCRIMINATOR_VALUE          => x_discriminator_value,
        X_USER_NAME                    => x_user_name,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_CACHE_DIRECTIVES_PKG.Insert_Row(
        X_ROWID                        => l_row_id,
        X_APPLICATION_ID               => l_app_id,
        X_DIRECTIVE_CODE               => x_directive_code,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_MAX_AGE                      => x_max_age,
        X_MAX_SIZE                     => x_max_size,
        X_MAX_HITS                     => x_max_hits,
        X_DISCRIMINATOR_TYPE           => x_discriminator_type,
        X_DISCRIMINATOR_VALUE          => x_discriminator_value,
        X_USER_NAME                    => x_user_name,
        X_CREATION_DATE                => f_ludate,
        X_CREATED_BY                   => f_luby,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0
      );
  end;
end LOAD_ROW;



end BNE_CACHE_DIRECTIVES_PKG;

/
