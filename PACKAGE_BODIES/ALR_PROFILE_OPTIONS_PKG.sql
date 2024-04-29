--------------------------------------------------------
--  DDL for Package Body ALR_PROFILE_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_PROFILE_OPTIONS_PKG" as
/* $Header: ALRPOPTB.pls 120.3.12010000.1 2008/07/27 06:58:51 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PROFILE_OPTION_NAME in VARCHAR2,
  X_PROFILE_OPTION_VALUE in VARCHAR2,
  X_PROFILE_OPTION_LONG in LONG,
  X_DESCRIPTION in VARCHAR2,
  X_LONG_FLAG in VARCHAR2,
  X_ENCRYPTED_PASSWORD in VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ALR_PROFILE_OPTIONS
    where PROFILE_OPTION_NAME = X_PROFILE_OPTION_NAME
  ;
begin
  insert into ALR_PROFILE_OPTIONS (
    PROFILE_OPTION_NAME,
    PROFILE_OPTION_VALUE,
    PROFILE_OPTION_LONG,
    DESCRIPTION,
    LONG_FLAG,
    ENCRYPTED_PASSWORD,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LOOKUP_TYPE
  ) values (
    X_PROFILE_OPTION_NAME,
    X_PROFILE_OPTION_VALUE,
    X_PROFILE_OPTION_LONG,
    X_DESCRIPTION,
    X_LONG_FLAG,
    X_ENCRYPTED_PASSWORD,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LOOKUP_TYPE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOAD_ROW (
  X_PROFILE_OPTION_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_PROFILE_OPTION_VALUE in VARCHAR2,
  X_PROFILE_OPTION_LONG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LONG_FLAG in VARCHAR2,
  X_ENCRYPTED_PASSWORD in VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
  l_user_id number := 0;
  l_row_id varchar2(64);

  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  select last_updated_by, last_update_date
  into  db_luby, db_ludate
  from ALR_PROFILE_OPTIONS
  where profile_option_name = X_PROFILE_OPTION_NAME;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                x_custom_mode)) then

  ALR_PROFILE_OPTIONS_PKG.UPDATE_ROW(
    X_PROFILE_OPTION_NAME => X_PROFILE_OPTION_NAME,
    X_PROFILE_OPTION_VALUE => X_PROFILE_OPTION_VALUE,
    X_PROFILE_OPTION_LONG => X_PROFILE_OPTION_LONG,
    X_DESCRIPTION => X_DESCRIPTION,
    X_LONG_FLAG => X_LONG_FLAG,
    X_ENCRYPTED_PASSWORD => X_ENCRYPTED_PASSWORD,
    X_LOOKUP_TYPE => X_LOOKUP_TYPE,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

 end if;

exception
  when NO_DATA_FOUND then
  ALR_PROFILE_OPTIONS_PKG.INSERT_ROW(
    X_ROWID => l_row_id,
    X_PROFILE_OPTION_NAME => X_PROFILE_OPTION_NAME,
    X_PROFILE_OPTION_VALUE => X_PROFILE_OPTION_VALUE,
    X_PROFILE_OPTION_LONG => X_PROFILE_OPTION_LONG,
    X_DESCRIPTION => X_DESCRIPTION,
    X_LONG_FLAG => X_LONG_FLAG,
    X_ENCRYPTED_PASSWORD => X_ENCRYPTED_PASSWORD,
    X_LOOKUP_TYPE => X_LOOKUP_TYPE,
    X_CREATION_DATE => f_ludate,
    X_CREATED_BY => f_luby,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

end LOAD_ROW;

procedure LOCK_ROW (
  X_PROFILE_OPTION_NAME in VARCHAR2,
  X_PROFILE_OPTION_VALUE in VARCHAR2,
  X_PROFILE_OPTION_LONG in LONG,
  X_DESCRIPTION in VARCHAR2,
  X_LONG_FLAG in VARCHAR2,
  X_ENCRYPTED_PASSWORD in VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2
) is
  cursor c1 is select
      PROFILE_OPTION_VALUE,
      PROFILE_OPTION_LONG,
      DESCRIPTION,
      LONG_FLAG,
      ENCRYPTED_PASSWORD,
      LOOKUP_TYPE,
      PROFILE_OPTION_NAME
    from ALR_PROFILE_OPTIONS
    where PROFILE_OPTION_NAME = X_PROFILE_OPTION_NAME
    for update of PROFILE_OPTION_NAME nowait;
begin
  for recinfo in c1 loop
      if (    (recinfo.PROFILE_OPTION_NAME = X_PROFILE_OPTION_NAME)
          AND ((recinfo.PROFILE_OPTION_VALUE = X_PROFILE_OPTION_VALUE)
               OR ((recinfo.PROFILE_OPTION_VALUE is null) AND (X_PROFILE_OPTION_VALUE is null)))
          AND ((recinfo.PROFILE_OPTION_LONG = X_PROFILE_OPTION_LONG)
               OR ((recinfo.PROFILE_OPTION_LONG is null) AND (X_PROFILE_OPTION_LONG is null)))
          AND ((recinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((recinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND (recinfo.LONG_FLAG = X_LONG_FLAG)
          AND ((recinfo.ENCRYPTED_PASSWORD = X_ENCRYPTED_PASSWORD)
               OR ((recinfo.ENCRYPTED_PASSWORD is null) AND (X_ENCRYPTED_PASSWORD is null)))
          AND ((recinfo.LOOKUP_TYPE = X_LOOKUP_TYPE)
               OR ((recinfo.LOOKUP_TYPE is null) AND (X_LOOKUP_TYPE is null)))
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
  X_PROFILE_OPTION_NAME in VARCHAR2,
  X_PROFILE_OPTION_VALUE in VARCHAR2,
  X_PROFILE_OPTION_LONG in LONG,
  X_DESCRIPTION in VARCHAR2,
  X_LONG_FLAG in VARCHAR2,
  X_ENCRYPTED_PASSWORD in VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ALR_PROFILE_OPTIONS set
    PROFILE_OPTION_VALUE = X_PROFILE_OPTION_VALUE,
    PROFILE_OPTION_LONG = X_PROFILE_OPTION_LONG,
    DESCRIPTION = X_DESCRIPTION,
    LONG_FLAG = X_LONG_FLAG,
    ENCRYPTED_PASSWORD = X_ENCRYPTED_PASSWORD,
    LOOKUP_TYPE = X_LOOKUP_TYPE,
    PROFILE_OPTION_NAME = X_PROFILE_OPTION_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PROFILE_OPTION_NAME = X_PROFILE_OPTION_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PROFILE_OPTION_NAME in VARCHAR2
) is
begin
  delete from ALR_PROFILE_OPTIONS
  where PROFILE_OPTION_NAME = X_PROFILE_OPTION_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end ALR_PROFILE_OPTIONS_PKG;

/
