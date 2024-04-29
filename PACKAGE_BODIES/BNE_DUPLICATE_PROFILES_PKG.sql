--------------------------------------------------------
--  DDL for Package Body BNE_DUPLICATE_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_DUPLICATE_PROFILES_PKG" as
/* $Header: bnedupprofb.pls 120.2 2005/06/29 03:39:53 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DUP_PROFILE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BNE_DUPLICATE_PROFILES_B
    where APPLICATION_ID = X_APPLICATION_ID
    and DUP_PROFILE_CODE = X_DUP_PROFILE_CODE
    ;
begin
  insert into BNE_DUPLICATE_PROFILES_B (
    APPLICATION_ID,
    DUP_PROFILE_CODE,
    OBJECT_VERSION_NUMBER,
    INTEGRATOR_APP_ID,
    INTEGRATOR_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_DUP_PROFILE_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_INTEGRATOR_APP_ID,
    X_INTEGRATOR_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into BNE_DUPLICATE_PROFILES_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    APPLICATION_ID,
    DUP_PROFILE_CODE,
    USER_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    X_APPLICATION_ID,
    X_DUP_PROFILE_CODE,
    X_USER_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BNE_DUPLICATE_PROFILES_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.DUP_PROFILE_CODE = X_DUP_PROFILE_CODE
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
  X_DUP_PROFILE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_USER_NAME in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      INTEGRATOR_APP_ID,
      INTEGRATOR_CODE
    from BNE_DUPLICATE_PROFILES_B
    where APPLICATION_ID = X_APPLICATION_ID
    and DUP_PROFILE_CODE = X_DUP_PROFILE_CODE
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BNE_DUPLICATE_PROFILES_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and DUP_PROFILE_CODE = X_DUP_PROFILE_CODE
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
      AND (recinfo.INTEGRATOR_APP_ID = X_INTEGRATOR_APP_ID)
      AND (recinfo.INTEGRATOR_CODE = X_INTEGRATOR_CODE)
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
  X_DUP_PROFILE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_INTEGRATOR_APP_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BNE_DUPLICATE_PROFILES_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    INTEGRATOR_APP_ID = X_INTEGRATOR_APP_ID,
    INTEGRATOR_CODE = X_INTEGRATOR_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and DUP_PROFILE_CODE = X_DUP_PROFILE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BNE_DUPLICATE_PROFILES_TL set
    USER_NAME = X_USER_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and DUP_PROFILE_CODE = X_DUP_PROFILE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DUP_PROFILE_CODE in VARCHAR2
) is
begin
  delete from BNE_DUPLICATE_PROFILES_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and DUP_PROFILE_CODE = X_DUP_PROFILE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BNE_DUPLICATE_PROFILES_B
  where APPLICATION_ID = X_APPLICATION_ID
  and DUP_PROFILE_CODE = X_DUP_PROFILE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BNE_DUPLICATE_PROFILES_TL T
  where not exists
    (select NULL
    from BNE_DUPLICATE_PROFILES_B B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.DUP_PROFILE_CODE = T.DUP_PROFILE_CODE
    );

  update BNE_DUPLICATE_PROFILES_TL T set (
      USER_NAME
    ) = (select
      B.USER_NAME
    from BNE_DUPLICATE_PROFILES_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.DUP_PROFILE_CODE = T.DUP_PROFILE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.DUP_PROFILE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.DUP_PROFILE_CODE,
      SUBT.LANGUAGE
    from BNE_DUPLICATE_PROFILES_TL SUBB, BNE_DUPLICATE_PROFILES_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.DUP_PROFILE_CODE = SUBT.DUP_PROFILE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_NAME <> SUBT.USER_NAME
  ));

  insert into BNE_DUPLICATE_PROFILES_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    APPLICATION_ID,
    DUP_PROFILE_CODE,
    USER_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    B.APPLICATION_ID,
    B.DUP_PROFILE_CODE,
    B.USER_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BNE_DUPLICATE_PROFILES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BNE_DUPLICATE_PROFILES_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.DUP_PROFILE_CODE = B.DUP_PROFILE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


--------------------------------------------------------------------------------
--  PROCEDURE:   TRANSLATE_ROW                                                --
--                                                                            --
--  DESCRIPTION: Load a translation into the BNE_DUPLICATE_PROFILES entity.   --
--               This proc is called from the apps loader.                    --
--                                                                            --
--  SEE:   http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt         --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date        Username  Description                                          --
--  27-May-2004 DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure TRANSLATE_ROW(
  x_dup_profile_asn             in VARCHAR2,
  x_dup_profile_code            in VARCHAR2,
  x_user_name                   in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
)is
  l_app_id          number;
  f_luby            number;  -- entity owner in file
  f_ludate          date;    -- entity update date in file
  db_luby           number;  -- entity owner in db
  db_ludate         date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_dup_profile_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_DUPLICATE_PROFILES_TL
    where APPLICATION_ID    = l_app_id
    and   DUP_PROFILE_CODE  = x_dup_profile_code
    and   LANGUAGE          = userenv('LANG');

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then

      update BNE_DUPLICATE_PROFILES_TL
      set USER_NAME         = x_user_name,
          LAST_UPDATE_DATE  = f_ludate,
          LAST_UPDATED_BY   = f_luby,
          LAST_UPDATE_LOGIN = 0,
          SOURCE_LANG       = userenv('LANG')
      where APPLICATION_ID    = l_app_id
      AND   DUP_PROFILE_CODE  = x_dup_profile_code
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
--  DESCRIPTION:   Load a row into the BNE_DUPLICATE_PROFILES entity.         --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt       --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date        Username  Description                                         --
--  27-May-2004 DGROVES   CREATED                                             --
--------------------------------------------------------------------------------
procedure LOAD_ROW(
  x_dup_profile_asn             in VARCHAR2,
  x_dup_profile_code            in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_integrator_asn              in VARCHAR2,
  x_integrator_code             in VARCHAR2,
  x_user_name                   in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
) is
  l_app_id                    number;
  l_integrator_app_id         number;
  l_row_id                    varchar2(64);
  f_luby                      number;  -- entity owner in file
  f_ludate                    date;    -- entity update date in file
  db_luby                     number;  -- entity owner in db
  db_ludate                   date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id              := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_dup_profile_asn);
  l_integrator_app_id   := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_integrator_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_DUPLICATE_PROFILES_B
    where APPLICATION_ID   = l_app_id
    and   DUP_PROFILE_CODE = x_dup_profile_code;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_DUPLICATE_PROFILES_PKG.Update_Row(
        X_APPLICATION_ID               => l_app_id,
        X_DUP_PROFILE_CODE             => x_dup_profile_code,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_INTEGRATOR_APP_ID            => l_integrator_app_id,
        X_INTEGRATOR_CODE              => x_integrator_code,
        X_USER_NAME                    => x_user_name,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_DUPLICATE_PROFILES_PKG.Insert_Row(
        X_ROWID                        => l_row_id,
        X_APPLICATION_ID               => l_app_id,
        X_DUP_PROFILE_CODE             => x_dup_profile_code,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_INTEGRATOR_APP_ID            => l_integrator_app_id,
        X_INTEGRATOR_CODE              => x_integrator_code,
        X_USER_NAME                    => x_user_name,
        X_CREATION_DATE                => f_ludate,
        X_CREATED_BY                   => f_luby,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0
      );
  end;
end LOAD_ROW;

end BNE_DUPLICATE_PROFILES_PKG;

/
