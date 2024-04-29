--------------------------------------------------------
--  DDL for Package Body BNE_USER_SETTINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_USER_SETTINGS_PKG" as
/* $Header: bneusersetb.pls 120.2 2005/06/29 03:41:12 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_USER_ID in NUMBER,
  X_SETTING_GROUP in VARCHAR2,
  X_SETTING_NAME in VARCHAR2,
  X_SETTING_VALUE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BNE_USER_SETTINGS
    where USER_ID = X_USER_ID
    and SETTING_GROUP = X_SETTING_GROUP
    and SETTING_NAME = X_SETTING_NAME
    ;
begin
  insert into BNE_USER_SETTINGS (
    USER_ID,
    SETTING_GROUP,
    SETTING_NAME,
    SETTING_VALUE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE
  ) values (
    X_USER_ID,
    X_SETTING_GROUP,
    X_SETTING_NAME,
    X_SETTING_VALUE,
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
  X_USER_ID in NUMBER,
  X_SETTING_GROUP in VARCHAR2,
  X_SETTING_NAME in VARCHAR2,
  X_SETTING_VALUE in VARCHAR2
) is
  cursor c1 is select
      SETTING_VALUE
    from BNE_USER_SETTINGS
    where USER_ID = X_USER_ID
    and SETTING_GROUP = X_SETTING_GROUP
    and SETTING_NAME = X_SETTING_NAME
    for update of USER_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.SETTING_VALUE = X_SETTING_VALUE)
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
  X_USER_ID in NUMBER,
  X_SETTING_GROUP in VARCHAR2,
  X_SETTING_NAME in VARCHAR2,
  X_SETTING_VALUE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BNE_USER_SETTINGS set
    SETTING_VALUE = X_SETTING_VALUE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where USER_ID = X_USER_ID
  and SETTING_GROUP = X_SETTING_GROUP
  and SETTING_NAME = X_SETTING_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_USER_ID in NUMBER,
  X_SETTING_GROUP in VARCHAR2,
  X_SETTING_NAME in VARCHAR2
) is
begin
  delete from BNE_USER_SETTINGS
  where USER_ID = X_USER_ID
  and SETTING_GROUP = X_SETTING_GROUP
  and SETTING_NAME = X_SETTING_NAME;

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
--  DESCRIPTION:   Load a row into the BNE_USER_SETTINGS entity.              --
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
  x_user_name                   in VARCHAR2,
  x_setting_group               in VARCHAR2,
  x_setting_name                in VARCHAR2,
  x_setting_value               in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
)
is
  l_user_id                     number;
  l_row_id                      varchar2(64);
  f_luby                        number;  -- entity owner in file
  f_ludate                      date;    -- entity update date in file
  db_luby                       number;  -- entity owner in db
  db_ludate                     date;    -- entity update date in db
begin
  -- translate values to IDs
  select user_id
  into   l_user_id
  from   fnd_user
  where user_name = x_user_name;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_USER_SETTINGS
    where USER_ID        = l_user_id
    and   SETTING_GROUP  = x_setting_group
    and   SETTING_NAME   = x_setting_name;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_USER_SETTINGS_PKG.Update_Row(
        X_USER_ID                      => l_user_id,
        X_SETTING_GROUP                => x_setting_group,
        X_SETTING_NAME                 => x_setting_name,
        X_SETTING_VALUE                => x_setting_value,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_USER_SETTINGS_PKG.Insert_Row(
        X_ROWID                        => l_row_id,
        X_USER_ID                      => l_user_id,
        X_SETTING_GROUP                => x_setting_group,
        X_SETTING_NAME                 => x_setting_name,
        X_SETTING_VALUE                => x_setting_value,
        X_CREATION_DATE                => f_ludate,
        X_CREATED_BY                   => f_luby,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0
      );
  end;
end LOAD_ROW;

end BNE_USER_SETTINGS_PKG;

/
