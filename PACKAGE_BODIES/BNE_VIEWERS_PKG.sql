--------------------------------------------------------
--  DDL for Package Body BNE_VIEWERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_VIEWERS_PKG" as
/* $Header: bneviewb.pls 120.3 2005/08/18 06:39:07 dagroves noship $ */

--------------------------------------------------------------------------------
--  Much of the following code was created using the tltblgen utility.        --
--                                                                            --
--  SEE: http://www-apps.us.oracle.com/atg/plans/r115/mldata.txt              --
--                        --
--                                                                            --
--------------------------------------------------------------------------------

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_VIEWER_CODE in VARCHAR2,
  X_PARAM_LIST_APP_ID in NUMBER,
  X_PARAM_LIST_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VIEWER_JAVA_CLASS in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CREATE_DOC_LIST_APP_ID in NUMBER,
  X_CREATE_DOC_LIST_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2
) is
  cursor C is select ROWID from BNE_VIEWERS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and VIEWER_CODE = X_VIEWER_CODE
    ;
begin
  insert into BNE_VIEWERS_B (
    PARAM_LIST_APP_ID,
    PARAM_LIST_CODE,
    APPLICATION_ID,
    VIEWER_CODE,
    OBJECT_VERSION_NUMBER,
    VIEWER_JAVA_CLASS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATE_DOC_LIST_APP_ID,
    CREATE_DOC_LIST_CODE,
    ENABLED_FLAG
  ) values (
    X_PARAM_LIST_APP_ID,
    X_PARAM_LIST_CODE,
    X_APPLICATION_ID,
    X_VIEWER_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_VIEWER_JAVA_CLASS,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATE_DOC_LIST_APP_ID,
    X_CREATE_DOC_LIST_CODE,
    X_ENABLED_FLAG
  );

  insert into BNE_VIEWERS_TL (
    APPLICATION_ID,
    VIEWER_CODE,
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
    X_VIEWER_CODE,
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
    from BNE_VIEWERS_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.VIEWER_CODE = X_VIEWER_CODE
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
  X_VIEWER_CODE in VARCHAR2,
  X_PARAM_LIST_APP_ID in NUMBER,
  X_PARAM_LIST_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VIEWER_JAVA_CLASS in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_CREATE_DOC_LIST_APP_ID in NUMBER,
  X_CREATE_DOC_LIST_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2
) is
  cursor c is select
      PARAM_LIST_APP_ID,
      PARAM_LIST_CODE,
      OBJECT_VERSION_NUMBER,
      VIEWER_JAVA_CLASS,
      CREATE_DOC_LIST_APP_ID,
      CREATE_DOC_LIST_CODE,
      ENABLED_FLAG
    from BNE_VIEWERS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and VIEWER_CODE = X_VIEWER_CODE
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BNE_VIEWERS_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and VIEWER_CODE = X_VIEWER_CODE
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
  if (    ((recinfo.PARAM_LIST_APP_ID = X_PARAM_LIST_APP_ID)
           OR ((recinfo.PARAM_LIST_APP_ID is null) AND (X_PARAM_LIST_APP_ID is null)))
      AND ((recinfo.PARAM_LIST_CODE = X_PARAM_LIST_CODE)
           OR ((recinfo.PARAM_LIST_CODE is null) AND (X_PARAM_LIST_CODE is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.VIEWER_JAVA_CLASS = X_VIEWER_JAVA_CLASS)
      AND ((recinfo.CREATE_DOC_LIST_APP_ID = X_CREATE_DOC_LIST_APP_ID)
           OR ((recinfo.CREATE_DOC_LIST_APP_ID is null) AND (X_CREATE_DOC_LIST_APP_ID is null)))
      AND ((recinfo.CREATE_DOC_LIST_CODE = X_CREATE_DOC_LIST_CODE)
           OR ((recinfo.CREATE_DOC_LIST_CODE is null) AND (X_CREATE_DOC_LIST_CODE is null)))
      AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
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
  X_VIEWER_CODE in VARCHAR2,
  X_PARAM_LIST_APP_ID in NUMBER,
  X_PARAM_LIST_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VIEWER_JAVA_CLASS in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CREATE_DOC_LIST_APP_ID in NUMBER,
  X_CREATE_DOC_LIST_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2
) is
begin
  update BNE_VIEWERS_B set
    PARAM_LIST_APP_ID = X_PARAM_LIST_APP_ID,
    PARAM_LIST_CODE = X_PARAM_LIST_CODE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    VIEWER_JAVA_CLASS = X_VIEWER_JAVA_CLASS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    CREATE_DOC_LIST_APP_ID = X_CREATE_DOC_LIST_APP_ID,
    CREATE_DOC_LIST_CODE = X_CREATE_DOC_LIST_CODE,
    ENABLED_FLAG = X_ENABLED_FLAG
  where APPLICATION_ID = X_APPLICATION_ID
  and VIEWER_CODE = X_VIEWER_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BNE_VIEWERS_TL set
    USER_NAME = X_USER_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and VIEWER_CODE = X_VIEWER_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_VIEWER_CODE in VARCHAR2
) is
begin
  delete from BNE_VIEWERS_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and VIEWER_CODE = X_VIEWER_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BNE_VIEWERS_B
  where APPLICATION_ID = X_APPLICATION_ID
  and VIEWER_CODE = X_VIEWER_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BNE_VIEWERS_TL T
  where not exists
    (select NULL
    from BNE_VIEWERS_B B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.VIEWER_CODE = T.VIEWER_CODE
    );

  update BNE_VIEWERS_TL T set (
      USER_NAME
    ) = (select
      B.USER_NAME
    from BNE_VIEWERS_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.VIEWER_CODE = T.VIEWER_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.VIEWER_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.VIEWER_CODE,
      SUBT.LANGUAGE
    from BNE_VIEWERS_TL SUBB, BNE_VIEWERS_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.VIEWER_CODE = SUBT.VIEWER_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_NAME <> SUBT.USER_NAME
  ));

  insert into BNE_VIEWERS_TL (
    APPLICATION_ID,
    VIEWER_CODE,
    USER_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.APPLICATION_ID,
    B.VIEWER_CODE,
    B.USER_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BNE_VIEWERS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BNE_VIEWERS_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.VIEWER_CODE = B.VIEWER_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--------------------------------------------------------------------------------
--  PROCEDURE:     LOAD_ROW                                                   --
--                                                                            --
--  DESCRIPTION:   Load a row into the BNE_VIEWERS entity.                    --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt --
--                        --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  1-Oct-02   DGROVES   CREATED                                              --
--------------------------------------------------------------------------------

procedure LOAD_ROW(
  x_viewer_asn            IN VARCHAR2,
  x_viewer_code           IN VARCHAR2,
  x_object_version_number IN VARCHAR2,
  x_viewer_java_class     IN VARCHAR2,
  x_param_list_asn        IN VARCHAR2,
  x_param_list_code       IN VARCHAR2,
  x_user_name             IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2,
  x_create_doc_list_asn   in VARCHAR2,
  x_create_doc_list_code  in VARCHAR2,
  x_enabled_flag          in VARCHAR2
)
is
  l_app_id          number;
  l_param_app_id    number;
  l_create_doc_list_app_id    number;
  l_meaning         varchar2(80);
  l_row_id          varchar2(64);
  f_luby            number;  -- entity owner in file
  f_ludate          date;    -- entity update date in file
  db_luby           number;  -- entity owner in db
  db_ludate         date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_viewer_asn);
  l_param_app_id := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_param_list_asn);
  l_create_doc_list_app_id   := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_create_doc_list_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_VIEWERS_B
    where APPLICATION_ID = l_app_id
    and   VIEWER_CODE    = x_viewer_code;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_VIEWERS_PKG.Update_Row(
        X_APPLICATION_ID        => l_app_id,
        X_VIEWER_CODE           => x_viewer_code,
        X_PARAM_LIST_APP_ID     => l_param_app_id,
        X_PARAM_LIST_CODE       => x_param_list_code,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_VIEWER_JAVA_CLASS     => x_viewer_java_class,
        X_USER_NAME             => x_user_name,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0,
        X_CREATE_DOC_LIST_APP_ID=> l_create_doc_list_app_id,
        X_CREATE_DOC_LIST_CODE  => x_create_doc_list_code,
        X_ENABLED_FLAG          => x_enabled_flag
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_VIEWERS_PKG.Insert_Row(
        X_ROWID                 => l_row_id,
        X_APPLICATION_ID        => l_app_id,
        X_VIEWER_CODE           => x_viewer_code,
        X_PARAM_LIST_APP_ID     => l_param_app_id,
        X_PARAM_LIST_CODE       => x_param_list_code,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_VIEWER_JAVA_CLASS     => x_viewer_java_class,
        X_USER_NAME             => x_user_name,
        X_CREATION_DATE         => f_ludate,
        X_CREATED_BY            => f_luby,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0,
        X_CREATE_DOC_LIST_APP_ID=> l_create_doc_list_app_id,
        X_CREATE_DOC_LIST_CODE  => x_create_doc_list_code,
        X_ENABLED_FLAG          => x_enabled_flag
      );
  end;
end LOAD_ROW;


--------------------------------------------------------------------------------
--  PROCEDURE:   TRANSLATE_ROW                                                --
--                                                                            --
--  DESCRIPTION: Load a translation into the BNE_VIEWERS entity.              --
--               This proc is called from the apps loader.                    --
--                                                                            --
--  SEE:   http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt   --
--                        --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  1-Oct-02   DGROVES   CREATED                                              --
--------------------------------------------------------------------------------

procedure TRANSLATE_ROW(
  x_viewer_asn            IN VARCHAR2,
  x_viewer_code           IN VARCHAR2,
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
  l_app_id        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_viewer_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_VIEWERS_TL
    where APPLICATION_ID = l_app_id
    and   VIEWER_CODE    = x_viewer_code
    and   LANGUAGE       = userenv('LANG');

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then

      update BNE_VIEWERS_TL
      set USER_NAME         = x_user_name,
          LAST_UPDATE_DATE  = f_ludate,
          LAST_UPDATED_BY   = f_luby,
          LAST_UPDATE_LOGIN = 0,
          SOURCE_LANG       = userenv('LANG')
      where APPLICATION_ID = l_app_id
      AND   VIEWER_CODE    = x_viewer_code
      AND   userenv('LANG') in (LANGUAGE, SOURCE_LANG)
      ;
    end if;
  exception
    when no_data_found then
      -- Do not insert missing translations, skip this row
      null;
  end;
end TRANSLATE_ROW;

end BNE_VIEWERS_PKG;

/
