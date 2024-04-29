--------------------------------------------------------
--  DDL for Package Body ALR_ORACLE_MAIL_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_ORACLE_MAIL_ACCOUNTS_PKG" as
/* $Header: ALROMLAB.pls 120.3.12010000.1 2008/07/27 06:58:48 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ORACLE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_ENCRYPTED_PASSWORD in VARCHAR2,
  X_SENDMAIL_ACCOUNT in VARCHAR2,
  X_DEFAULT_RESPONSE_ACCOUNT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ALR_ORACLE_MAIL_ACCOUNTS
    where APPLICATION_ID = X_APPLICATION_ID
    and ORACLE_ID = X_ORACLE_ID
    ;
begin
  insert into ALR_ORACLE_MAIL_ACCOUNTS (
    LAST_UPDATE_LOGIN,
    APPLICATION_ID,
    ORACLE_ID,
    NAME,
    ENCRYPTED_PASSWORD,
    SENDMAIL_ACCOUNT,
    DEFAULT_RESPONSE_ACCOUNT,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY
  ) values (
    X_LAST_UPDATE_LOGIN,
    X_APPLICATION_ID,
    X_ORACLE_ID,
    X_NAME,
    X_ENCRYPTED_PASSWORD,
    X_SENDMAIL_ACCOUNT,
    X_DEFAULT_RESPONSE_ACCOUNT,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_ORACLE_USERNAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_NAME in VARCHAR2,
  X_ENCRYPTED_PASSWORD in VARCHAR2,
  X_SENDMAIL_ACCOUNT in VARCHAR2,
  X_DEFAULT_RESPONSE_ACCOUNT in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
  l_user_id number := 0;
  l_app_id  number := null;
  l_oracle_id number := null;
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

  select APPLICATION_ID into l_app_id
  from FND_APPLICATION
  where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME;

  select ORACLE_ID into l_oracle_id
  from FND_ORACLE_USERID
  where ORACLE_USERNAME = X_ORACLE_USERNAME;

  select last_updated_by, last_update_date
  into  db_luby, db_ludate
  from ALR_ORACLE_MAIL_ACCOUNTS
  where application_id = l_app_id
  and   oracle_id = l_oracle_id;

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                x_custom_mode)) then

  ALR_ORACLE_MAIL_ACCOUNTS_PKG.UPDATE_ROW(
    X_APPLICATION_ID => l_app_id,
    X_ORACLE_ID => l_oracle_id,
    X_NAME => X_NAME,
    X_ENCRYPTED_PASSWORD => X_ENCRYPTED_PASSWORD,
    X_SENDMAIL_ACCOUNT => X_SENDMAIL_ACCOUNT,
    X_DEFAULT_RESPONSE_ACCOUNT =>
      X_DEFAULT_RESPONSE_ACCOUNT,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

end if;

exception
  when no_data_found then
  ALR_ORACLE_MAIL_ACCOUNTS_PKG.INSERT_ROW(
    X_ROWID => l_row_id,
    X_APPLICATION_ID => l_app_id,
    X_ORACLE_ID => l_oracle_id,
    X_NAME => X_NAME,
    X_ENCRYPTED_PASSWORD => X_ENCRYPTED_PASSWORD,
    X_SENDMAIL_ACCOUNT => X_SENDMAIL_ACCOUNT,
    X_DEFAULT_RESPONSE_ACCOUNT =>
      X_DEFAULT_RESPONSE_ACCOUNT,
    X_CREATION_DATE => f_ludate,
    X_CREATED_BY => f_luby,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

end LOAD_ROW;

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ORACLE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_ENCRYPTED_PASSWORD in VARCHAR2,
  X_SENDMAIL_ACCOUNT in VARCHAR2,
  X_DEFAULT_RESPONSE_ACCOUNT in VARCHAR2
) is
  cursor c1 is select
      NAME,
      ENCRYPTED_PASSWORD,
      SENDMAIL_ACCOUNT,
      DEFAULT_RESPONSE_ACCOUNT,
      APPLICATION_ID,
      ORACLE_ID
    from ALR_ORACLE_MAIL_ACCOUNTS
    where APPLICATION_ID = X_APPLICATION_ID
    and ORACLE_ID = X_ORACLE_ID
    for update of APPLICATION_ID nowait;
begin
  for recinfo in c1 loop
      if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
          AND (recinfo.ORACLE_ID = X_ORACLE_ID)
          AND ((recinfo.NAME = X_NAME)
               OR ((recinfo.NAME is null) AND (X_NAME is null)))
          AND ((recinfo.ENCRYPTED_PASSWORD = X_ENCRYPTED_PASSWORD)
               OR ((recinfo.ENCRYPTED_PASSWORD is null) AND (X_ENCRYPTED_PASSWORD is null)))
          AND ((recinfo.SENDMAIL_ACCOUNT = X_SENDMAIL_ACCOUNT)
               OR ((recinfo.SENDMAIL_ACCOUNT is null) AND (X_SENDMAIL_ACCOUNT is null)))
          AND ((recinfo.DEFAULT_RESPONSE_ACCOUNT = X_DEFAULT_RESPONSE_ACCOUNT)
               OR ((recinfo.DEFAULT_RESPONSE_ACCOUNT is null) AND (X_DEFAULT_RESPONSE_ACCOUNT is null)))
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
  X_ORACLE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_ENCRYPTED_PASSWORD in VARCHAR2,
  X_SENDMAIL_ACCOUNT in VARCHAR2,
  X_DEFAULT_RESPONSE_ACCOUNT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ALR_ORACLE_MAIL_ACCOUNTS set
    NAME = X_NAME,
    ENCRYPTED_PASSWORD = X_ENCRYPTED_PASSWORD,
    SENDMAIL_ACCOUNT = X_SENDMAIL_ACCOUNT,
    DEFAULT_RESPONSE_ACCOUNT = X_DEFAULT_RESPONSE_ACCOUNT,
    APPLICATION_ID = X_APPLICATION_ID,
    ORACLE_ID = X_ORACLE_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and ORACLE_ID = X_ORACLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ORACLE_ID in NUMBER
) is
begin
  delete from ALR_ORACLE_MAIL_ACCOUNTS
  where APPLICATION_ID = X_APPLICATION_ID
  and ORACLE_ID = X_ORACLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end ALR_ORACLE_MAIL_ACCOUNTS_PKG;

/
