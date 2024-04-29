--------------------------------------------------------
--  DDL for Package Body BNE_INTERFACES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_INTERFACES_PKG" as
/* $Header: bneintrb.pls 120.2 2005/06/29 03:40:09 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_INTERFACE_NAME in VARCHAR2,
  X_UPLOAD_TYPE in NUMBER,
  X_UPLOAD_OBJ_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_UPLOAD_PARAM_LIST_APP_ID in NUMBER,
  X_UPLOAD_PARAM_LIST_CODE in VARCHAR2,
  X_UPLOAD_ORDER in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BNE_INTERFACES_B
    where APPLICATION_ID = X_APPLICATION_ID
    and INTERFACE_CODE = X_INTERFACE_CODE
    ;
begin
  insert into BNE_INTERFACES_B (
    INTERFACE_NAME,
    UPLOAD_TYPE,
    UPLOAD_OBJ_NAME,
    APPLICATION_ID,
    INTERFACE_CODE,
    OBJECT_VERSION_NUMBER,
    INTEGRATOR_APP_ID,
    INTEGRATOR_CODE,
    UPLOAD_PARAM_LIST_APP_ID,
    UPLOAD_PARAM_LIST_CODE,
    UPLOAD_ORDER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_INTERFACE_NAME,
    X_UPLOAD_TYPE,
    X_UPLOAD_OBJ_NAME,
    X_APPLICATION_ID,
    X_INTERFACE_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_INTEGRATOR_APP_ID,
    X_INTEGRATOR_CODE,
    X_UPLOAD_PARAM_LIST_APP_ID,
    X_UPLOAD_PARAM_LIST_CODE,
    X_UPLOAD_ORDER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into BNE_INTERFACES_TL (
    APPLICATION_ID,
    INTERFACE_CODE,
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
    X_INTERFACE_CODE,
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
    from BNE_INTERFACES_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.INTERFACE_CODE = X_INTERFACE_CODE
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
  X_INTERFACE_CODE in VARCHAR2,
  X_INTERFACE_NAME in VARCHAR2,
  X_UPLOAD_TYPE in NUMBER,
  X_UPLOAD_OBJ_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_UPLOAD_PARAM_LIST_APP_ID in NUMBER,
  X_UPLOAD_PARAM_LIST_CODE in VARCHAR2,
  X_UPLOAD_ORDER in NUMBER,
  X_USER_NAME in VARCHAR2
) is
  cursor c is select
      INTERFACE_NAME,
      UPLOAD_TYPE,
      UPLOAD_OBJ_NAME,
      OBJECT_VERSION_NUMBER,
      INTEGRATOR_APP_ID,
      INTEGRATOR_CODE,
      UPLOAD_PARAM_LIST_APP_ID,
      UPLOAD_PARAM_LIST_CODE,
      UPLOAD_ORDER
    from BNE_INTERFACES_B
    where APPLICATION_ID = X_APPLICATION_ID
    and INTERFACE_CODE = X_INTERFACE_CODE
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BNE_INTERFACES_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and INTERFACE_CODE = X_INTERFACE_CODE
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
  if (    (recinfo.INTERFACE_NAME = X_INTERFACE_NAME)
      AND (recinfo.UPLOAD_TYPE = X_UPLOAD_TYPE)
      AND ((recinfo.UPLOAD_OBJ_NAME = X_UPLOAD_OBJ_NAME)
           OR ((recinfo.UPLOAD_OBJ_NAME is null) AND (X_UPLOAD_OBJ_NAME is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.INTEGRATOR_APP_ID = X_INTEGRATOR_APP_ID)
      AND (recinfo.INTEGRATOR_CODE = X_INTEGRATOR_CODE)
      AND ((recinfo.UPLOAD_PARAM_LIST_APP_ID = X_UPLOAD_PARAM_LIST_APP_ID)
           OR ((recinfo.UPLOAD_PARAM_LIST_APP_ID is null) AND (X_UPLOAD_PARAM_LIST_APP_ID is null)))
      AND ((recinfo.UPLOAD_PARAM_LIST_CODE = X_UPLOAD_PARAM_LIST_CODE)
           OR ((recinfo.UPLOAD_PARAM_LIST_CODE is null) AND (X_UPLOAD_PARAM_LIST_CODE is null)))
      AND ((recinfo.UPLOAD_ORDER = X_UPLOAD_ORDER)
           OR ((recinfo.UPLOAD_ORDER is null) AND (X_UPLOAD_ORDER is null)))
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
  X_INTERFACE_CODE in VARCHAR2,
  X_INTERFACE_NAME in VARCHAR2,
  X_UPLOAD_TYPE in NUMBER,
  X_UPLOAD_OBJ_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_UPLOAD_PARAM_LIST_APP_ID in NUMBER,
  X_UPLOAD_PARAM_LIST_CODE in VARCHAR2,
  X_UPLOAD_ORDER in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BNE_INTERFACES_B set
    INTERFACE_NAME = X_INTERFACE_NAME,
    UPLOAD_TYPE = X_UPLOAD_TYPE,
    UPLOAD_OBJ_NAME = X_UPLOAD_OBJ_NAME,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    INTEGRATOR_APP_ID = X_INTEGRATOR_APP_ID,
    INTEGRATOR_CODE = X_INTEGRATOR_CODE,
    UPLOAD_PARAM_LIST_APP_ID = X_UPLOAD_PARAM_LIST_APP_ID,
    UPLOAD_PARAM_LIST_CODE = X_UPLOAD_PARAM_LIST_CODE,
    UPLOAD_ORDER = X_UPLOAD_ORDER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and INTERFACE_CODE = X_INTERFACE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BNE_INTERFACES_TL set
    USER_NAME = X_USER_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and INTERFACE_CODE = X_INTERFACE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2
) is
begin
  delete from BNE_INTERFACES_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and INTERFACE_CODE = X_INTERFACE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BNE_INTERFACES_B
  where APPLICATION_ID = X_APPLICATION_ID
  and INTERFACE_CODE = X_INTERFACE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BNE_INTERFACES_TL T
  where not exists
    (select NULL
    from BNE_INTERFACES_B B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.INTERFACE_CODE = T.INTERFACE_CODE
    );

  update BNE_INTERFACES_TL T set (
      USER_NAME
    ) = (select
      B.USER_NAME
    from BNE_INTERFACES_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.INTERFACE_CODE = T.INTERFACE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.INTERFACE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.INTERFACE_CODE,
      SUBT.LANGUAGE
    from BNE_INTERFACES_TL SUBB, BNE_INTERFACES_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.INTERFACE_CODE = SUBT.INTERFACE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_NAME <> SUBT.USER_NAME
  ));

  insert into BNE_INTERFACES_TL (
    APPLICATION_ID,
    INTERFACE_CODE,
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
    B.INTERFACE_CODE,
    B.USER_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BNE_INTERFACES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BNE_INTERFACES_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.INTERFACE_CODE = B.INTERFACE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--------------------------------------------------------------------------------
--  PROCEDURE:   TRANSLATE_ROW                                                --
--                                                                            --
--  DESCRIPTION: Load a translation into the BNE_INTERFACES entity.           --
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
  x_interface_asn         in VARCHAR2,
  x_interface_code        in VARCHAR2,
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
  l_app_id        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_interface_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_INTERFACES_TL
    where APPLICATION_ID  = l_app_id
    and   INTERFACE_CODE  = x_interface_code
    and   LANGUAGE        = userenv('LANG');

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then

      update BNE_INTERFACES_TL
      set USER_NAME         = x_user_name,
          LAST_UPDATE_DATE  = f_ludate,
          LAST_UPDATED_BY   = f_luby,
          LAST_UPDATE_LOGIN = 0,
          SOURCE_LANG       = userenv('LANG')
      where APPLICATION_ID   = l_app_id
      AND   INTERFACE_CODE   = x_interface_code
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
--  DESCRIPTION:   Load a row into the BNE_INTERFACES entity.                 --
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
  x_interface_asn          in VARCHAR2,
  x_interface_code         in VARCHAR2,
  x_object_version_number  in VARCHAR2,
  x_integrator_asn         in VARCHAR2,
  x_integrator_code        in VARCHAR2,
  x_interface_name         in VARCHAR2,
  x_upload_type            in VARCHAR2,
  x_upload_obj_name        in VARCHAR2,
  x_upload_param_list_asn  in VARCHAR2,
  x_upload_param_list_code in VARCHAR2,
  x_upload_order           in VARCHAR2,
  x_user_name              in VARCHAR2,
  x_owner                  in VARCHAR2,
  x_last_update_date       in VARCHAR2,
  x_custom_mode            in VARCHAR2
)
is
  l_app_id                    number;
  l_integrator_app_id         number;
  l_upload_param_app_id       number;
  l_row_id                    varchar2(64);
  f_luby                      number;  -- entity owner in file
  f_ludate                    date;    -- entity update date in file
  db_luby                     number;  -- entity owner in db
  db_ludate                   date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id              := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_interface_asn);
  l_integrator_app_id   := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_integrator_asn);
  l_upload_param_app_id := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_upload_param_list_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_INTERFACES_B
    where APPLICATION_ID = l_app_id
    and   INTERFACE_CODE = x_interface_code;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_INTERFACES_PKG.Update_Row(
        X_APPLICATION_ID               => l_app_id,
        X_INTERFACE_CODE               => x_interface_code,
        X_INTERFACE_NAME               => x_interface_name,
        X_UPLOAD_TYPE                  => x_upload_type,
        X_UPLOAD_OBJ_NAME              => x_upload_obj_name,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_INTEGRATOR_APP_ID            => l_integrator_app_id,
        X_INTEGRATOR_CODE              => x_integrator_code,
        X_UPLOAD_PARAM_LIST_APP_ID     => l_upload_param_app_id,
        X_UPLOAD_PARAM_LIST_CODE       => x_upload_param_list_code,
        X_UPLOAD_ORDER                 => x_upload_order,
        X_USER_NAME                    => x_user_name,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_INTERFACES_PKG.Insert_Row(
        X_ROWID                        => l_row_id,
        X_APPLICATION_ID               => l_app_id,
        X_INTERFACE_CODE               => x_interface_code,
        X_INTERFACE_NAME               => x_interface_name,
        X_UPLOAD_TYPE                  => x_upload_type,
        X_UPLOAD_OBJ_NAME              => x_upload_obj_name,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_INTEGRATOR_APP_ID            => l_integrator_app_id,
        X_INTEGRATOR_CODE              => x_integrator_code,
        X_UPLOAD_PARAM_LIST_APP_ID     => l_upload_param_app_id,
        X_UPLOAD_PARAM_LIST_CODE       => x_upload_param_list_code,
        X_UPLOAD_ORDER                 => x_upload_order,
        X_USER_NAME                    => x_user_name,
        X_CREATION_DATE                => f_ludate,
        X_CREATED_BY                   => f_luby,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0
      );
  end;
end LOAD_ROW;


end BNE_INTERFACES_PKG;

/
