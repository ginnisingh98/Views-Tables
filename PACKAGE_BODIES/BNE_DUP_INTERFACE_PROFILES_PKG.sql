--------------------------------------------------------
--  DDL for Package Body BNE_DUP_INTERFACE_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_DUP_INTERFACE_PROFILES_PKG" as
/* $Header: bnedupintprofb.pls 120.2 2005/06/29 03:39:51 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INTERFACE_APP_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_DUP_PROFILE_APP_ID in NUMBER,
  X_DUP_PROFILE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DUP_HANDLING_CODE in VARCHAR2,
  X_DEFAULT_RESOLVER_CLASSNAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BNE_DUP_INTERFACE_PROFILES
    where INTERFACE_APP_ID = X_INTERFACE_APP_ID
    and INTERFACE_CODE = X_INTERFACE_CODE
    and DUP_PROFILE_APP_ID = X_DUP_PROFILE_APP_ID
    and DUP_PROFILE_CODE = X_DUP_PROFILE_CODE
    ;
begin
  insert into BNE_DUP_INTERFACE_PROFILES (
    INTERFACE_APP_ID,
    INTERFACE_CODE,
    DUP_PROFILE_APP_ID,
    DUP_PROFILE_CODE,
    OBJECT_VERSION_NUMBER,
    DUP_HANDLING_CODE,
    DEFAULT_RESOLVER_CLASSNAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE
  ) values (
    X_INTERFACE_APP_ID,
    X_INTERFACE_CODE,
    X_DUP_PROFILE_APP_ID,
    X_DUP_PROFILE_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_DUP_HANDLING_CODE,
    X_DEFAULT_RESOLVER_CLASSNAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_INTERFACE_APP_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_DUP_PROFILE_APP_ID in NUMBER,
  X_DUP_PROFILE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DUP_HANDLING_CODE in VARCHAR2,
  X_DEFAULT_RESOLVER_CLASSNAME in VARCHAR2
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      DUP_HANDLING_CODE,
      DEFAULT_RESOLVER_CLASSNAME
    from BNE_DUP_INTERFACE_PROFILES
    where INTERFACE_APP_ID = X_INTERFACE_APP_ID
    and INTERFACE_CODE = X_INTERFACE_CODE
    and DUP_PROFILE_APP_ID = X_DUP_PROFILE_APP_ID
    and DUP_PROFILE_CODE = X_DUP_PROFILE_CODE
    for update of INTERFACE_APP_ID nowait;
begin
  for tlinfo in c1 loop
    if ((tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
        AND (tlinfo.DUP_HANDLING_CODE = X_DUP_HANDLING_CODE)
        AND ((tlinfo.DEFAULT_RESOLVER_CLASSNAME = X_DEFAULT_RESOLVER_CLASSNAME)
             OR ((tlinfo.DEFAULT_RESOLVER_CLASSNAME is null) AND (X_DEFAULT_RESOLVER_CLASSNAME is null)))
    ) then
      null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_INTERFACE_APP_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_DUP_PROFILE_APP_ID in NUMBER,
  X_DUP_PROFILE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DUP_HANDLING_CODE in VARCHAR2,
  X_DEFAULT_RESOLVER_CLASSNAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BNE_DUP_INTERFACE_PROFILES set
    OBJECT_VERSION_NUMBER      = X_OBJECT_VERSION_NUMBER,
    DUP_HANDLING_CODE          = X_DUP_HANDLING_CODE,
    DEFAULT_RESOLVER_CLASSNAME = X_DEFAULT_RESOLVER_CLASSNAME,
    LAST_UPDATE_DATE           = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY            = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN          = X_LAST_UPDATE_LOGIN
  where INTERFACE_APP_ID = X_INTERFACE_APP_ID
  and INTERFACE_CODE     = X_INTERFACE_CODE
  and DUP_PROFILE_APP_ID = X_DUP_PROFILE_APP_ID
  and DUP_PROFILE_CODE   = X_DUP_PROFILE_CODE
  ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_INTERFACE_APP_ID in NUMBER,
  X_INTERFACE_CODE in VARCHAR2,
  X_DUP_PROFILE_APP_ID in NUMBER,
  X_DUP_PROFILE_CODE in VARCHAR2
) is
begin
  delete from BNE_DUP_INTERFACE_PROFILES
  where INTERFACE_APP_ID = X_INTERFACE_APP_ID
  and INTERFACE_CODE = X_INTERFACE_CODE
  and DUP_PROFILE_APP_ID = X_DUP_PROFILE_APP_ID
  and DUP_PROFILE_CODE = X_DUP_PROFILE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  null;
end ADD_LANGUAGE;

--------------------------------------------------------------------------------
--  PROCEDURE:     LOAD_ROW                                                   --
--                                                                            --
--  DESCRIPTION:   Load a row into the BNE_DUP_INTERFACE_PROFILES entity.     --
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
  x_interface_asn               in VARCHAR2,
  x_interface_code              in VARCHAR2,
  x_dup_profile_asn             in VARCHAR2,
  x_dup_profile_code            in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_dup_handling_code           in VARCHAR2,
  x_default_resolver_classname  in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
) is
  l_interface_app_id          number;
  l_dup_profile_app_id        number;
  l_row_id                    varchar2(64);
  f_luby                      number;  -- entity owner in file
  f_ludate                    date;    -- entity update date in file
  db_luby                     number;  -- entity owner in db
  db_ludate                   date;    -- entity update date in db
begin
  -- translate values to IDs
  l_interface_app_id     := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_interface_asn);
  l_dup_profile_app_id   := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_dup_profile_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_DUP_INTERFACE_PROFILES
    where INTERFACE_APP_ID   = l_interface_app_id
    and   INTERFACE_CODE     = x_interface_code
    and   DUP_PROFILE_APP_ID = l_dup_profile_app_id
    and   DUP_PROFILE_CODE   = x_dup_profile_code
    ;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_DUP_INTERFACE_PROFILES_PKG.Update_Row(
        X_INTERFACE_APP_ID             => l_interface_app_id,
        X_INTERFACE_CODE               => x_interface_code,
        X_DUP_PROFILE_APP_ID           => l_dup_profile_app_id,
        X_DUP_PROFILE_CODE             => x_dup_profile_code,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_DUP_HANDLING_CODE            => x_dup_handling_code,
        X_DEFAULT_RESOLVER_CLASSNAME   => x_default_resolver_classname,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_DUP_INTERFACE_PROFILES_PKG.Insert_Row(
        X_ROWID                        => l_row_id,
        X_INTERFACE_APP_ID             => l_interface_app_id,
        X_INTERFACE_CODE               => x_interface_code,
        X_DUP_PROFILE_APP_ID           => l_dup_profile_app_id,
        X_DUP_PROFILE_CODE             => x_dup_profile_code,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_DUP_HANDLING_CODE            => x_dup_handling_code,
        X_DEFAULT_RESOLVER_CLASSNAME   => x_default_resolver_classname,
        X_CREATION_DATE                => f_ludate,
        X_CREATED_BY                   => f_luby,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0
      );
  end;
end LOAD_ROW;

end BNE_DUP_INTERFACE_PROFILES_PKG;

/
