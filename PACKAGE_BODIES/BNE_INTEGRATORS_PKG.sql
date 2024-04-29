--------------------------------------------------------
--  DDL for Package Body BNE_INTEGRATORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_INTEGRATORS_PKG" as
/* $Header: bneintegb.pls 120.3.12010000.2 2010/12/20 15:01:39 amgonzal ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_UPLOAD_PARAM_LIST_APP_ID in NUMBER,
  X_UPLOAD_PARAM_LIST_CODE in VARCHAR2,
  X_UPLOAD_SERV_PARAM_LIST_APP_I in NUMBER,
  X_UPLOAD_SERV_PARAM_LIST_CODE in VARCHAR2,
  X_IMPORT_PARAM_LIST_APP_ID in NUMBER,
  X_IMPORT_PARAM_LIST_CODE in VARCHAR2,
  X_UPLOADER_CLASS in VARCHAR2,
  X_DATE_FORMAT in VARCHAR2,
  X_IMPORT_TYPE in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_UPLOAD_TITLE_BAR in VARCHAR2,
  X_UPLOAD_HEADER in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CREATE_DOC_LIST_APP_ID in NUMBER,
  X_CREATE_DOC_LIST_CODE in VARCHAR2,
  X_NEW_SESSION_FLAG in VARCHAR2,
  X_LAYOUT_RESOLVER_CLASS in VARCHAR2,
  X_LAYOUT_VERIFIER_CLASS in VARCHAR2,
  X_SESSION_CONFIG_CLASS in VARCHAR2,
  X_SESSION_PARAM_LIST_APP_ID in NUMBER,
  X_SESSION_PARAM_LIST_CODE in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_SOURCE in VARCHAR2
) is
  cursor C is select ROWID from BNE_INTEGRATORS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and INTEGRATOR_CODE = X_INTEGRATOR_CODE
    ;
begin
  insert into BNE_INTEGRATORS_B (
    ENABLED_FLAG,
    OBJECT_VERSION_NUMBER,
    UPLOAD_PARAM_LIST_APP_ID,
    UPLOAD_PARAM_LIST_CODE,
    UPLOAD_SERV_PARAM_LIST_APP_ID,
    UPLOAD_SERV_PARAM_LIST_CODE,
    IMPORT_PARAM_LIST_APP_ID,
    IMPORT_PARAM_LIST_CODE,
    UPLOADER_CLASS,
    DATE_FORMAT,
    IMPORT_TYPE,
    APPLICATION_ID,
    INTEGRATOR_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATE_DOC_LIST_APP_ID,
    CREATE_DOC_LIST_CODE,
    NEW_SESSION_FLAG,
    LAYOUT_RESOLVER_CLASS,
    LAYOUT_VERIFIER_CLASS,
    SESSION_CONFIG_CLASS,
    SESSION_PARAM_LIST_APP_ID,
    SESSION_PARAM_LIST_CODE,
    DISPLAY_FLAG,
    SOURCE

  ) values (
    X_ENABLED_FLAG,
    X_OBJECT_VERSION_NUMBER,
    X_UPLOAD_PARAM_LIST_APP_ID,
    X_UPLOAD_PARAM_LIST_CODE,
    X_UPLOAD_SERV_PARAM_LIST_APP_I,
    X_UPLOAD_SERV_PARAM_LIST_CODE,
    X_IMPORT_PARAM_LIST_APP_ID,
    X_IMPORT_PARAM_LIST_CODE,
    X_UPLOADER_CLASS,
    X_DATE_FORMAT,
    X_IMPORT_TYPE,
    X_APPLICATION_ID,
    X_INTEGRATOR_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATE_DOC_LIST_APP_ID,
    X_CREATE_DOC_LIST_CODE,
    X_NEW_SESSION_FLAG,
    X_LAYOUT_RESOLVER_CLASS,
    X_LAYOUT_VERIFIER_CLASS,
    X_SESSION_CONFIG_CLASS,
    X_SESSION_PARAM_LIST_APP_ID,
    X_SESSION_PARAM_LIST_CODE,
    X_DISPLAY_FLAG,
    X_SOURCE
  );

  insert into BNE_INTEGRATORS_TL (
    APPLICATION_ID,
    INTEGRATOR_CODE,
    USER_NAME,
    UPLOAD_HEADER,
    UPLOAD_TITLE_BAR,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_INTEGRATOR_CODE,
    X_USER_NAME,
    X_UPLOAD_HEADER,
    X_UPLOAD_TITLE_BAR,
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
    from BNE_INTEGRATORS_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.INTEGRATOR_CODE = X_INTEGRATOR_CODE
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
  X_INTEGRATOR_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_UPLOAD_PARAM_LIST_APP_ID in NUMBER,
  X_UPLOAD_PARAM_LIST_CODE in VARCHAR2,
  X_UPLOAD_SERV_PARAM_LIST_APP_I in NUMBER,
  X_UPLOAD_SERV_PARAM_LIST_CODE in VARCHAR2,
  X_IMPORT_PARAM_LIST_APP_ID in NUMBER,
  X_IMPORT_PARAM_LIST_CODE in VARCHAR2,
  X_UPLOADER_CLASS in VARCHAR2,
  X_DATE_FORMAT in VARCHAR2,
  X_IMPORT_TYPE in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_UPLOAD_TITLE_BAR in VARCHAR2,
  X_UPLOAD_HEADER in VARCHAR2,
  X_CREATE_DOC_LIST_APP_ID in NUMBER,
  X_CREATE_DOC_LIST_CODE in VARCHAR2,
  X_NEW_SESSION_FLAG in VARCHAR2,
  X_LAYOUT_RESOLVER_CLASS in VARCHAR2,
  X_LAYOUT_VERIFIER_CLASS in VARCHAR2,
  X_SESSION_CONFIG_CLASS in VARCHAR2,
  X_SESSION_PARAM_LIST_APP_ID in NUMBER,
  X_SESSION_PARAM_LIST_CODE in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_SOURCE in VARCHAR2
) is
  cursor c is select
      ENABLED_FLAG,
      OBJECT_VERSION_NUMBER,
      UPLOAD_PARAM_LIST_APP_ID,
      UPLOAD_PARAM_LIST_CODE,
      UPLOAD_SERV_PARAM_LIST_APP_ID,
      UPLOAD_SERV_PARAM_LIST_CODE,
      IMPORT_PARAM_LIST_APP_ID,
      IMPORT_PARAM_LIST_CODE,
      UPLOADER_CLASS,
      DATE_FORMAT,
      IMPORT_TYPE,
      CREATE_DOC_LIST_APP_ID,
      CREATE_DOC_LIST_CODE,
      NEW_SESSION_FLAG,
      LAYOUT_RESOLVER_CLASS,
      LAYOUT_VERIFIER_CLASS,
      SESSION_CONFIG_CLASS,
      SESSION_PARAM_LIST_APP_ID,
      SESSION_PARAM_LIST_CODE,
      DISPLAY_FLAG,
      SOURCE
    from BNE_INTEGRATORS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and INTEGRATOR_CODE = X_INTEGRATOR_CODE
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_NAME,
      UPLOAD_TITLE_BAR,
      UPLOAD_HEADER,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BNE_INTEGRATORS_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and INTEGRATOR_CODE = X_INTEGRATOR_CODE
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
  if (    (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.UPLOAD_PARAM_LIST_APP_ID = X_UPLOAD_PARAM_LIST_APP_ID)
           OR ((recinfo.UPLOAD_PARAM_LIST_APP_ID is null) AND (X_UPLOAD_PARAM_LIST_APP_ID is null)))
      AND ((recinfo.UPLOAD_PARAM_LIST_CODE = X_UPLOAD_PARAM_LIST_CODE)
           OR ((recinfo.UPLOAD_PARAM_LIST_CODE is null) AND (X_UPLOAD_PARAM_LIST_CODE is null)))
      AND ((recinfo.UPLOAD_SERV_PARAM_LIST_APP_ID = X_UPLOAD_SERV_PARAM_LIST_APP_I)
           OR ((recinfo.UPLOAD_SERV_PARAM_LIST_APP_ID is null) AND (X_UPLOAD_SERV_PARAM_LIST_APP_I is null)))
      AND ((recinfo.UPLOAD_SERV_PARAM_LIST_CODE = X_UPLOAD_SERV_PARAM_LIST_CODE)
           OR ((recinfo.UPLOAD_SERV_PARAM_LIST_CODE is null) AND (X_UPLOAD_SERV_PARAM_LIST_CODE is null)))
      AND ((recinfo.IMPORT_PARAM_LIST_APP_ID = X_IMPORT_PARAM_LIST_APP_ID)
           OR ((recinfo.IMPORT_PARAM_LIST_APP_ID is null) AND (X_IMPORT_PARAM_LIST_APP_ID is null)))
      AND ((recinfo.IMPORT_PARAM_LIST_CODE = X_IMPORT_PARAM_LIST_CODE)
           OR ((recinfo.IMPORT_PARAM_LIST_CODE is null) AND (X_IMPORT_PARAM_LIST_CODE is null)))
      AND ((recinfo.UPLOADER_CLASS = X_UPLOADER_CLASS)
           OR ((recinfo.UPLOADER_CLASS is null) AND (X_UPLOADER_CLASS is null)))
      AND (recinfo.DATE_FORMAT = X_DATE_FORMAT)
      AND ((recinfo.IMPORT_TYPE = X_IMPORT_TYPE)
           OR ((recinfo.IMPORT_TYPE is null) AND (X_IMPORT_TYPE is null)))
      AND ((recinfo.CREATE_DOC_LIST_APP_ID = X_CREATE_DOC_LIST_APP_ID)
           OR ((recinfo.CREATE_DOC_LIST_APP_ID is null) AND (X_CREATE_DOC_LIST_APP_ID is null)))
      AND ((recinfo.CREATE_DOC_LIST_CODE = X_CREATE_DOC_LIST_CODE)
           OR ((recinfo.CREATE_DOC_LIST_CODE is null) AND (X_CREATE_DOC_LIST_CODE is null)))
      AND ((recinfo.NEW_SESSION_FLAG = X_NEW_SESSION_FLAG)
           OR ((recinfo.NEW_SESSION_FLAG is null) AND (X_NEW_SESSION_FLAG is null)))
      AND ((recinfo.LAYOUT_RESOLVER_CLASS = X_LAYOUT_RESOLVER_CLASS)
           OR ((recinfo.LAYOUT_RESOLVER_CLASS is null) AND (X_LAYOUT_RESOLVER_CLASS is null)))
      AND ((recinfo.LAYOUT_VERIFIER_CLASS = X_LAYOUT_VERIFIER_CLASS)
           OR ((recinfo.LAYOUT_VERIFIER_CLASS is null) AND (X_LAYOUT_VERIFIER_CLASS is null)))
      AND ((recinfo.SESSION_CONFIG_CLASS = X_SESSION_CONFIG_CLASS)
           OR ((recinfo.SESSION_CONFIG_CLASS is null) AND (X_SESSION_CONFIG_CLASS is null)))
      AND ((recinfo.SESSION_PARAM_LIST_APP_ID = X_SESSION_PARAM_LIST_APP_ID)
           OR ((recinfo.SESSION_PARAM_LIST_APP_ID is null) AND (X_SESSION_PARAM_LIST_APP_ID is null)))
      AND ((recinfo.SESSION_PARAM_LIST_CODE = X_SESSION_PARAM_LIST_CODE)
           OR ((recinfo.SESSION_PARAM_LIST_CODE is null) AND (X_SESSION_PARAM_LIST_CODE is null)))
      AND ((recinfo.SOURCE = X_SOURCE)
           OR ((recinfo.SOURCE is null) AND (X_SOURCE is null)))
      AND ((recinfo.DISPLAY_FLAG = X_DISPLAY_FLAG)
           OR ((recinfo.DISPLAY_FLAG is null) AND (X_DISPLAY_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.USER_NAME = X_USER_NAME)
          AND ((tlinfo.UPLOAD_TITLE_BAR = X_UPLOAD_TITLE_BAR)
               OR ((tlinfo.UPLOAD_TITLE_BAR is null) AND (X_UPLOAD_TITLE_BAR is null)))
          AND ((tlinfo.UPLOAD_HEADER = X_UPLOAD_HEADER)
               OR ((tlinfo.UPLOAD_HEADER is null) AND (X_UPLOAD_HEADER is null)))
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
  X_INTEGRATOR_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_UPLOAD_PARAM_LIST_APP_ID in NUMBER,
  X_UPLOAD_PARAM_LIST_CODE in VARCHAR2,
  X_UPLOAD_SERV_PARAM_LIST_APP_I in NUMBER,
  X_UPLOAD_SERV_PARAM_LIST_CODE in VARCHAR2,
  X_IMPORT_PARAM_LIST_APP_ID in NUMBER,
  X_IMPORT_PARAM_LIST_CODE in VARCHAR2,
  X_UPLOADER_CLASS in VARCHAR2,
  X_DATE_FORMAT in VARCHAR2,
  X_IMPORT_TYPE in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_UPLOAD_TITLE_BAR in VARCHAR2,
  X_UPLOAD_HEADER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_CREATE_DOC_LIST_APP_ID in NUMBER,
  X_CREATE_DOC_LIST_CODE in VARCHAR2,
  X_NEW_SESSION_FLAG in VARCHAR2,
  X_LAYOUT_RESOLVER_CLASS in VARCHAR2,
  X_LAYOUT_VERIFIER_CLASS in VARCHAR2,
  X_SESSION_CONFIG_CLASS in VARCHAR2,
  X_SESSION_PARAM_LIST_APP_ID in NUMBER,
  X_SESSION_PARAM_LIST_CODE in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_SOURCE in VARCHAR2
) is
begin
  update BNE_INTEGRATORS_B set
    ENABLED_FLAG = X_ENABLED_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    UPLOAD_PARAM_LIST_APP_ID = X_UPLOAD_PARAM_LIST_APP_ID,
    UPLOAD_PARAM_LIST_CODE = X_UPLOAD_PARAM_LIST_CODE,
    UPLOAD_SERV_PARAM_LIST_APP_ID = X_UPLOAD_SERV_PARAM_LIST_APP_I,
    UPLOAD_SERV_PARAM_LIST_CODE = X_UPLOAD_SERV_PARAM_LIST_CODE,
    IMPORT_PARAM_LIST_APP_ID = X_IMPORT_PARAM_LIST_APP_ID,
    IMPORT_PARAM_LIST_CODE = X_IMPORT_PARAM_LIST_CODE,
    UPLOADER_CLASS = X_UPLOADER_CLASS,
    DATE_FORMAT = X_DATE_FORMAT,
    IMPORT_TYPE = X_IMPORT_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    CREATE_DOC_LIST_APP_ID = X_CREATE_DOC_LIST_APP_ID,
    CREATE_DOC_LIST_CODE = X_CREATE_DOC_LIST_CODE,
    NEW_SESSION_FLAG = X_NEW_SESSION_FLAG,
    LAYOUT_RESOLVER_CLASS = X_LAYOUT_RESOLVER_CLASS,
    LAYOUT_VERIFIER_CLASS = X_LAYOUT_VERIFIER_CLASS,
    SESSION_CONFIG_CLASS = X_SESSION_CONFIG_CLASS,
    SESSION_PARAM_LIST_APP_ID = X_SESSION_PARAM_LIST_APP_ID,
    SESSION_PARAM_LIST_CODE = X_SESSION_PARAM_LIST_CODE,
    DISPLAY_FLAG = X_DISPLAY_FLAG,
    SOURCE = X_SOURCE
  where APPLICATION_ID = X_APPLICATION_ID
  and INTEGRATOR_CODE = X_INTEGRATOR_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BNE_INTEGRATORS_TL set
    USER_NAME = X_USER_NAME,
    UPLOAD_TITLE_BAR = X_UPLOAD_TITLE_BAR,
    UPLOAD_HEADER = X_UPLOAD_HEADER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and INTEGRATOR_CODE = X_INTEGRATOR_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2
) is
begin
  delete from BNE_INTEGRATORS_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and INTEGRATOR_CODE = X_INTEGRATOR_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BNE_INTEGRATORS_B
  where APPLICATION_ID = X_APPLICATION_ID
  and INTEGRATOR_CODE = X_INTEGRATOR_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BNE_INTEGRATORS_TL T
  where not exists
    (select NULL
    from BNE_INTEGRATORS_B B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.INTEGRATOR_CODE = T.INTEGRATOR_CODE
    );

  update BNE_INTEGRATORS_TL T set (
      USER_NAME,
      UPLOAD_TITLE_BAR,
      UPLOAD_HEADER
    ) = (select
      B.USER_NAME,
      B.UPLOAD_TITLE_BAR,
      B.UPLOAD_HEADER
    from BNE_INTEGRATORS_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.INTEGRATOR_CODE = T.INTEGRATOR_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.INTEGRATOR_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.INTEGRATOR_CODE,
      SUBT.LANGUAGE
    from BNE_INTEGRATORS_TL SUBB, BNE_INTEGRATORS_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.INTEGRATOR_CODE = SUBT.INTEGRATOR_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_NAME <> SUBT.USER_NAME
      or SUBB.UPLOAD_TITLE_BAR <> SUBT.UPLOAD_TITLE_BAR
      or (SUBB.UPLOAD_TITLE_BAR is null and SUBT.UPLOAD_TITLE_BAR is not null)
      or (SUBB.UPLOAD_TITLE_BAR is not null and SUBT.UPLOAD_TITLE_BAR is null)
      or SUBB.UPLOAD_HEADER <> SUBT.UPLOAD_HEADER
      or (SUBB.UPLOAD_HEADER is null and SUBT.UPLOAD_HEADER is not null)
      or (SUBB.UPLOAD_HEADER is not null and SUBT.UPLOAD_HEADER is null)
  ));

  insert into BNE_INTEGRATORS_TL (
    APPLICATION_ID,
    INTEGRATOR_CODE,
    USER_NAME,
    UPLOAD_HEADER,
    UPLOAD_TITLE_BAR,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.APPLICATION_ID,
    B.INTEGRATOR_CODE,
    B.USER_NAME,
    B.UPLOAD_HEADER,
    B.UPLOAD_TITLE_BAR,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BNE_INTEGRATORS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BNE_INTEGRATORS_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.INTEGRATOR_CODE = B.INTEGRATOR_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


--------------------------------------------------------------------------------
--  PROCEDURE:   TRANSLATE_ROW                                                --
--                                                                            --
--  DESCRIPTION: Load a translation into the BNE_INTEGRATORS entity.          --
--               This proc is called from the apps loader.                    --
--                                                                            --
--  SEE:   http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt         --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  1-Oct-02   DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure TRANSLATE_ROW(
  x_integrator_asn        in VARCHAR2,
  x_integrator_code       in VARCHAR2,
  x_user_name             in VARCHAR2,
  x_upload_header         in VARCHAR2,
  x_upload_title_bar      in VARCHAR2,
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
  l_app_id        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_integrator_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_INTEGRATORS_TL
    where APPLICATION_ID  = l_app_id
    and   INTEGRATOR_CODE = x_integrator_code
    and   LANGUAGE        = userenv('LANG');

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then

      update BNE_INTEGRATORS_TL
      set USER_NAME         = x_user_name,
          UPLOAD_HEADER     = x_upload_header,
          UPLOAD_TITLE_BAR  = x_upload_title_bar,
          LAST_UPDATE_DATE  = f_ludate,
          LAST_UPDATED_BY   = f_luby,
          LAST_UPDATE_LOGIN = 0,
          SOURCE_LANG       = userenv('LANG')
      where APPLICATION_ID   = l_app_id
      AND   INTEGRATOR_CODE  = x_integrator_code
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
--  DESCRIPTION:   Load a row into the BNE_INTEGRATORS entity.                --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt       --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  1-Oct-02   DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure LOAD_ROW(
  x_integrator_asn              in VARCHAR2,
  x_integrator_code             in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_enabled_flag                in VARCHAR2,
  x_upload_param_list_asn       in VARCHAR2,
  x_upload_param_list_code      in VARCHAR2,
  x_upload_serv_param_list_asn  in VARCHAR2,
  x_upload_serv_param_list_code in VARCHAR2,
  x_import_param_list_asn       in VARCHAR2,
  x_import_param_code           in VARCHAR2,
  x_date_format                 in VARCHAR2,
  x_import_type                 in VARCHAR2,
  x_uploader_class              in VARCHAR2,
  x_user_name                   in VARCHAR2,
  x_upload_header               in VARCHAR2,
  x_upload_title_bar            in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2,
  x_create_doc_list_asn         in VARCHAR2,
  x_create_doc_list_code        in VARCHAR2,
  x_new_session_flag            in VARCHAR2,
  x_layout_resolver_class       in VARCHAR2,
  x_layout_verifier_class       in VARCHAR2,
  x_session_config_class        in VARCHAR2,
  x_session_param_list_asn      in VARCHAR2,
  x_session_param_list_code     in VARCHAR2,
  x_display_flag                in VARCHAR2,
  x_source                in VARCHAR2 default null
)
is
  l_app_id                    number;
  l_upload_param_app_id       number;
  l_upload_serv_param_app_id  number;
  l_import_param_app_id       number;
  l_create_doc_list_app_id    number;
  l_session_param_list_app_id number;
  l_row_id                    varchar2(64);
  f_luby                      number;  -- entity owner in file
  f_ludate                    date;    -- entity update date in file
  db_luby                     number;  -- entity owner in db
  db_ludate                   date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id                    := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_integrator_asn);
  l_upload_param_app_id       := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_upload_param_list_asn);
  l_upload_serv_param_app_id  := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_upload_serv_param_list_asn);
  l_import_param_app_id       := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_import_param_list_asn);
  l_create_doc_list_app_id    := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_create_doc_list_asn);
  l_session_param_list_app_id := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_session_param_list_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_INTEGRATORS_B
    where APPLICATION_ID  = l_app_id
    and   INTEGRATOR_CODE = x_integrator_code;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_INTEGRATORS_PKG.Update_Row(
        X_APPLICATION_ID               => l_app_id,
        X_INTEGRATOR_CODE              => x_integrator_code,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_ENABLED_FLAG                 => x_enabled_flag,
        X_UPLOAD_PARAM_LIST_APP_ID     => l_upload_param_app_id,
        X_UPLOAD_PARAM_LIST_CODE       => x_upload_param_list_code,
        X_UPLOAD_SERV_PARAM_LIST_APP_I => l_upload_serv_param_app_id,
        X_UPLOAD_SERV_PARAM_LIST_CODE  => x_upload_serv_param_list_code,
        X_IMPORT_PARAM_LIST_APP_ID     => l_import_param_app_id,
        X_IMPORT_PARAM_LIST_CODE       => x_import_param_code,
        X_UPLOADER_CLASS               => x_uploader_class,
        X_DATE_FORMAT                  => x_date_format,
        X_IMPORT_TYPE                  => x_import_type,
        X_USER_NAME                    => x_user_name,
        X_UPLOAD_TITLE_BAR             => x_upload_title_bar,
        X_UPLOAD_HEADER                => x_upload_header,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0,
        X_CREATE_DOC_LIST_APP_ID       => l_create_doc_list_app_id,
        X_CREATE_DOC_LIST_CODE         => x_create_doc_list_code,
        X_NEW_SESSION_FLAG             => x_new_session_flag,
        X_LAYOUT_RESOLVER_CLASS        => x_layout_resolver_class,
        X_LAYOUT_VERIFIER_CLASS        => x_layout_verifier_class,
        X_SESSION_CONFIG_CLASS         => x_session_config_class,
        X_SESSION_PARAM_LIST_APP_ID    => l_session_param_list_app_id,
        X_SESSION_PARAM_LIST_CODE      => x_session_param_list_code,
        X_DISPLAY_FLAG                 => x_display_flag,
        X_SOURCE                 => x_source
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_INTEGRATORS_PKG.Insert_Row(
        X_ROWID                        => l_row_id,
        X_APPLICATION_ID               => l_app_id,
        X_INTEGRATOR_CODE              => x_INTEGRATOR_code,
        X_ENABLED_FLAG                 => x_enabled_flag,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_UPLOAD_PARAM_LIST_APP_ID     => l_upload_param_app_id,
        X_UPLOAD_PARAM_LIST_CODE       => x_upload_param_list_code,
        X_UPLOAD_SERV_PARAM_LIST_APP_I => l_upload_serv_param_app_id,
        X_UPLOAD_SERV_PARAM_LIST_CODE  => x_upload_serv_param_list_code,
        X_IMPORT_PARAM_LIST_APP_ID     => l_import_param_app_id,
        X_IMPORT_PARAM_LIST_CODE       => x_import_param_code,
        X_UPLOADER_CLASS               => x_uploader_class,
        X_DATE_FORMAT                  => x_date_format,
        X_IMPORT_TYPE                  => x_import_type,
        X_USER_NAME                    => x_user_name,
        X_UPLOAD_TITLE_BAR             => x_upload_title_bar,
        X_UPLOAD_HEADER                => x_upload_header,
        X_CREATION_DATE                => f_ludate,
        X_CREATED_BY                   => f_luby,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0,
        X_CREATE_DOC_LIST_APP_ID       => l_create_doc_list_app_id,
        X_CREATE_DOC_LIST_CODE         => x_create_doc_list_code,
        X_NEW_SESSION_FLAG             => x_new_session_flag,
        X_LAYOUT_RESOLVER_CLASS        => x_layout_resolver_class,
        X_LAYOUT_VERIFIER_CLASS        => x_layout_verifier_class,
        X_SESSION_CONFIG_CLASS         => x_session_config_class,
        X_SESSION_PARAM_LIST_APP_ID    => l_session_param_list_app_id,
        X_SESSION_PARAM_LIST_CODE      => x_session_param_list_code,
        X_DISPLAY_FLAG                 => x_display_flag,
        X_SOURCE                       => x_source
      );
  end;
end LOAD_ROW;


end BNE_INTEGRATORS_PKG;

/
