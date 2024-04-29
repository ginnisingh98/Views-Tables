--------------------------------------------------------
--  DDL for Package Body BNE_SECURED_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_SECURED_OBJECTS_PKG" as
/* $Header: bnesecuredobjb.pls 120.2 2005/06/29 03:40:57 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_CODE in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_RULE_APP_ID in NUMBER,
  X_SECURITY_RULE_CODE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BNE_SECURED_OBJECTS
    where APPLICATION_ID = X_APPLICATION_ID
    and OBJECT_CODE = X_OBJECT_CODE
    and OBJECT_TYPE = X_OBJECT_TYPE
    ;
begin
  insert into BNE_SECURED_OBJECTS (
    APPLICATION_ID,
    OBJECT_CODE,
    OBJECT_TYPE,
    OBJECT_VERSION_NUMBER,
    SECURITY_RULE_APP_ID,
    SECURITY_RULE_CODE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE
  ) values (
    X_APPLICATION_ID,
    X_OBJECT_CODE,
    X_OBJECT_TYPE,
    X_OBJECT_VERSION_NUMBER,
    X_SECURITY_RULE_APP_ID,
    X_SECURITY_RULE_CODE,
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
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_CODE in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_RULE_APP_ID in NUMBER,
  X_SECURITY_RULE_CODE in VARCHAR2
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      SECURITY_RULE_APP_ID,
      SECURITY_RULE_CODE
    from BNE_SECURED_OBJECTS
    where APPLICATION_ID = X_APPLICATION_ID
    and OBJECT_CODE = X_OBJECT_CODE
    and OBJECT_TYPE = X_OBJECT_TYPE
    for update of APPLICATION_ID nowait;
begin
  for tlinfo in c1 loop
    if (    (tlinfo.SECURITY_RULE_APP_ID = X_SECURITY_RULE_APP_ID)
        AND (tlinfo.SECURITY_RULE_CODE = X_SECURITY_RULE_CODE)
        AND (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
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
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_CODE in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_RULE_APP_ID in NUMBER,
  X_SECURITY_RULE_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BNE_SECURED_OBJECTS set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    SECURITY_RULE_APP_ID = X_SECURITY_RULE_APP_ID,
    SECURITY_RULE_CODE = X_SECURITY_RULE_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and OBJECT_CODE = X_OBJECT_CODE
  and OBJECT_TYPE = X_OBJECT_TYPE
  ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_CODE in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2
) is
begin
  delete from BNE_SECURED_OBJECTS
  where APPLICATION_ID = X_APPLICATION_ID
  and OBJECT_CODE = X_OBJECT_CODE
  and OBJECT_TYPE = X_OBJECT_TYPE;

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
--  DESCRIPTION:   Load a row into the BNE_SECURED_OBJECTS entity.            --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt       --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  7-Aug-04   DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure LOAD_ROW(
  x_secured_object_asn          in VARCHAR2,
  x_secured_object_code         in VARCHAR2,
  x_secured_object_type         in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_security_rule_app_id        in VARCHAR2,
  x_security_rule_code          in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
)
is
  l_app_id                      number;
  l_rule_app_id                 number;
  l_row_id                      varchar2(64);
  f_luby                        number;  -- entity owner in file
  f_ludate                      date;    -- entity update date in file
  db_luby                       number;  -- entity owner in db
  db_ludate                     date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id                        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_secured_object_asn);
  l_rule_app_id                   := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_security_rule_app_id);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_SECURED_OBJECTS
    where APPLICATION_ID = l_app_id
    and   OBJECT_CODE    = x_secured_object_code
    and   OBJECT_TYPE    = x_secured_object_type;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_SECURED_OBJECTS_PKG.Update_Row(
        X_APPLICATION_ID               => l_app_id,
        X_OBJECT_CODE                  => x_secured_object_code,
        X_OBJECT_TYPE                  => x_secured_object_type,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_SECURITY_RULE_APP_ID         => l_rule_app_id,
        X_SECURITY_RULE_CODE           => x_security_rule_code,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_SECURED_OBJECTS_PKG.Insert_Row(
        X_ROWID                        => l_row_id,
        X_APPLICATION_ID               => l_app_id,
        X_OBJECT_CODE                  => x_secured_object_code,
        X_OBJECT_TYPE                  => x_secured_object_type,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_SECURITY_RULE_APP_ID         => l_rule_app_id,
        X_SECURITY_RULE_CODE           => x_security_rule_code,
        X_CREATION_DATE                => f_ludate,
        X_CREATED_BY                   => f_luby,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0
      );
  end;
end LOAD_ROW;

end BNE_SECURED_OBJECTS_PKG;

/
