--------------------------------------------------------
--  DDL for Package Body BNE_STYLESHEETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_STYLESHEETS_PKG" as
/* $Header: bnesshtb.pls 120.3 2005/08/18 07:23:49 dagroves noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_STYLESHEET_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DEFAULT_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor C is select ROWID from BNE_STYLESHEETS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and STYLESHEET_CODE = X_STYLESHEET_CODE
    ;
begin
  insert into BNE_STYLESHEETS_B (
    OBJECT_VERSION_NUMBER,
    APPLICATION_ID,
    STYLESHEET_CODE,
	DEFAULT_FLAG,
	READ_ONLY_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_OBJECT_VERSION_NUMBER,
    X_APPLICATION_ID,
    X_STYLESHEET_CODE,
	X_DEFAULT_FLAG,
	X_READ_ONLY_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into BNE_STYLESHEETS_TL (
    APPLICATION_ID,
    STYLESHEET_CODE,
    USER_NAME,
	DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_STYLESHEET_CODE,
    X_USER_NAME,
	X_DESCRIPTION,
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
    from BNE_STYLESHEETS_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.STYLESHEET_CODE = X_STYLESHEET_CODE
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
  X_STYLESHEET_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
	  DEFAULT_FLAG,
	  READ_ONLY_FLAG
    from BNE_STYLESHEETS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and STYLESHEET_CODE = X_STYLESHEET_CODE
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_NAME, DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BNE_STYLESHEETS_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and STYLESHEET_CODE = X_STYLESHEET_CODE
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
      AND ((recinfo.DEFAULT_FLAG = X_DEFAULT_FLAG)
	      OR ((recinfo.DEFAULT_FLAG is null) AND (X_DEFAULT_FLAG is null)))
	  AND ((recinfo.READ_ONLY_FLAG = X_READ_ONLY_FLAG)
	      OR ((recinfo.READ_ONLY_FLAG is null) AND (X_READ_ONLY_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.USER_NAME = X_USER_NAME)
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
  X_APPLICATION_ID in NUMBER,
  X_STYLESHEET_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DEFAULT_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
begin
  update BNE_STYLESHEETS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
	DEFAULT_FLAG = X_DEFAULT_FLAG,
	READ_ONLY_FLAG = X_READ_ONLY_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and STYLESHEET_CODE = X_STYLESHEET_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BNE_STYLESHEETS_TL set
    USER_NAME = X_USER_NAME,
	DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and STYLESHEET_CODE = X_STYLESHEET_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_STYLESHEET_CODE in VARCHAR2
) is
begin
  delete from BNE_STYLESHEETS_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and STYLESHEET_CODE = X_STYLESHEET_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BNE_STYLESHEETS_B
  where APPLICATION_ID = X_APPLICATION_ID
  and STYLESHEET_CODE = X_STYLESHEET_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BNE_STYLESHEETS_TL T
  where not exists
    (select NULL
    from BNE_STYLESHEETS_B B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.STYLESHEET_CODE = T.STYLESHEET_CODE
    );

  update BNE_STYLESHEETS_TL T set (
      USER_NAME, DESCRIPTION
    ) = (select
      B.USER_NAME,
	  B.DESCRIPTION
    from BNE_STYLESHEETS_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.STYLESHEET_CODE = T.STYLESHEET_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.STYLESHEET_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.STYLESHEET_CODE,
      SUBT.LANGUAGE
    from BNE_STYLESHEETS_TL SUBB, BNE_STYLESHEETS_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.STYLESHEET_CODE = SUBT.STYLESHEET_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_NAME <> SUBT.USER_NAME)
	and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into BNE_STYLESHEETS_TL (
    APPLICATION_ID,
    STYLESHEET_CODE,
    USER_NAME,
	DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.APPLICATION_ID,
    B.STYLESHEET_CODE,
    B.USER_NAME,
	B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BNE_STYLESHEETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BNE_STYLESHEETS_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.STYLESHEET_CODE = B.STYLESHEET_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


--------------------------------------------------------------------------------
--  PROCEDURE:     LOAD_ROW                                                   --
--                                                                            --
--  DESCRIPTION:   Load a row into the BNE_STYLESHEETS entity.                 --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE: 	   http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt --
-- 									      --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  1-Oct-02   DGROVES   CREATED                                              --
--------------------------------------------------------------------------------

procedure LOAD_ROW(
  x_stylesheet_asn        IN VARCHAR2,
  x_stylesheet_code       IN VARCHAR2,
  x_object_version_number IN VARCHAR2,
  x_user_name             IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2,
  x_default_flag          IN VARCHAR2,
  x_read_only_flag        IN VARCHAR2,
  x_description           IN VARCHAR2
)
is
  l_app_id          number;
  l_meaning         varchar2(80);
  l_row_id          varchar2(64);
  f_luby            number;  -- entity owner in file
  f_ludate          date;    -- entity update date in file
  db_luby           number;  -- entity owner in db
  db_ludate         date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id       := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_stylesheet_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_STYLESHEETS_B
    where APPLICATION_ID = l_app_id
    and   STYLESHEET_CODE = x_stylesheet_code;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_STYLESHEETS_PKG.Update_Row(
        X_APPLICATION_ID        => l_app_id,
        X_STYLESHEET_CODE       => x_stylesheet_code,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
		X_USER_NAME             => x_user_name,
		X_DEFAULT_FLAG          => x_default_flag,
		X_READ_ONLY_FLAG        => x_read_only_flag,
        X_DESCRIPTION           => x_description,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_STYLESHEETS_PKG.Insert_Row(
        X_ROWID                 => l_row_id,
        X_APPLICATION_ID        => l_app_id,
        X_STYLESHEET_CODE       => x_stylesheet_code,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
		X_USER_NAME             => x_user_name,
		X_DEFAULT_FLAG          => x_default_flag,
		X_READ_ONLY_FLAG        => x_read_only_flag,
        X_DESCRIPTION           => x_description,
        X_CREATION_DATE         => f_ludate,
        X_CREATED_BY            => f_luby,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
  end;
end LOAD_ROW;


--------------------------------------------------------------------------------
--  PROCEDURE:   TRANSLATE_ROW                                                --
--                                                                            --
--  DESCRIPTION: Load a translation into the BNE_STYLESHEETS entity.           --
--               This proc is called from the apps loader.                    --
--                                                                            --
--  SEE: 	 http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt   --
-- 									      --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  1-Oct-02   DGROVES   CREATED                                              --
--------------------------------------------------------------------------------

procedure TRANSLATE_ROW(
  x_stylesheet_asn        IN VARCHAR2,
  x_stylesheet_code       IN VARCHAR2,
  x_user_name             IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2,
  x_description           IN VARCHAR2
)
is
  l_app_id          number;
  f_luby            number;  -- entity owner in file
  f_ludate          date;    -- entity update date in file
  db_luby           number;  -- entity owner in db
  db_ludate         date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_stylesheet_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_STYLESHEETS_TL
    where APPLICATION_ID = l_app_id
    and   STYLESHEET_CODE = x_stylesheet_code
    and   LANGUAGE       = userenv('LANG');

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then

      update BNE_STYLESHEETS_TL
      set USER_NAME         = x_user_name,
	      DESCRIPTION       = x_description,
          LAST_UPDATE_DATE  = f_ludate,
          LAST_UPDATED_BY   = f_luby,
          LAST_UPDATE_LOGIN = 0,
          SOURCE_LANG       = userenv('LANG')
      where APPLICATION_ID = l_app_id
      AND   STYLESHEET_CODE    = x_stylesheet_code
      AND   userenv('LANG') in (LANGUAGE, SOURCE_LANG)
      ;
    end if;
  exception
    when no_data_found then
      -- Do not insert missing translations, skip this row
      null;
  end;
end TRANSLATE_ROW;

end BNE_STYLESHEETS_PKG;

/
