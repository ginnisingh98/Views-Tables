--------------------------------------------------------
--  DDL for Package Body ALR_ALERT_OUTPUTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_ALERT_OUTPUTS_PKG" as
/* $Header: ALRAOTPB.pls 120.5.12010000.1 2008/07/27 06:58:23 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_TITLE in VARCHAR2,
  X_DETAIL_MAX_LEN in NUMBER,
  X_SUMMARY_MAX_LEN in NUMBER,
  X_DEFAULT_SUPPRESS_FLAG in VARCHAR2,
  X_FORMAT_MASK in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ALR_ALERT_OUTPUTS
    where APPLICATION_ID = X_APPLICATION_ID
    and ALERT_ID = X_ALERT_ID
    and NAME = X_NAME
    ;
begin
  insert into ALR_ALERT_OUTPUTS (
    APPLICATION_ID,
    ALERT_ID,
    NAME,
    SEQUENCE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    ENABLED_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    TITLE,
    DETAIL_MAX_LEN,
    SUMMARY_MAX_LEN,
    DEFAULT_SUPPRESS_FLAG,
    FORMAT_MASK
  ) values (
    X_APPLICATION_ID,
    X_ALERT_ID,
    X_NAME,
    X_SEQUENCE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ENABLED_FLAG,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_TITLE,
    X_DETAIL_MAX_LEN,
    X_SUMMARY_MAX_LEN,
    X_DEFAULT_SUPPRESS_FLAG,
    X_FORMAT_MASK
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
  X_ALERT_NAME in VARCHAR2,
  X_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_SEQUENCE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in VARCHAR2,
  X_END_DATE_ACTIVE in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_DETAIL_MAX_LEN in VARCHAR2,
  X_SUMMARY_MAX_LEN in VARCHAR2,
  X_DEFAULT_SUPPRESS_FLAG in VARCHAR2,
  X_FORMAT_MASK in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
    l_user_id number := 0;
    l_app_id  number;
    l_alert_id number;
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

  select ALERT_ID into l_alert_id
  from ALR_ALERTS
  where APPLICATION_ID = l_app_id
  and ALERT_NAME = X_ALERT_NAME;

  select last_updated_by, last_update_date
  into  db_luby, db_ludate
  from ALR_ALERT_OUTPUTS
  where application_id = l_app_id
  and   alert_id = l_alert_id
  and   name = X_NAME;


  ALR_ALERT_OUTPUTS_PKG.UPDATE_ROW(
    X_APPLICATION_ID => l_app_id,
    X_ALERT_ID => l_alert_id,
    X_NAME => X_NAME,
    X_SEQUENCE => to_number(X_SEQUENCE),
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_START_DATE_ACTIVE =>
      to_date(X_START_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_END_DATE_ACTIVE =>
      to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_TITLE => X_TITLE,
    X_DETAIL_MAX_LEN => to_number(X_DETAIL_MAX_LEN),
    X_SUMMARY_MAX_LEN => to_number(X_SUMMARY_MAX_LEN),
    X_DEFAULT_SUPPRESS_FLAG => X_DEFAULT_SUPPRESS_FLAG,
    X_FORMAT_MASK => X_FORMAT_MASK,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

exception

  when NO_DATA_FOUND then

  ALR_ALERT_OUTPUTS_PKG.INSERT_ROW(
    X_ROWID => l_row_id,
    X_APPLICATION_ID => l_app_id,
    X_ALERT_ID => l_alert_id,
    X_NAME => X_NAME,
    X_SEQUENCE => to_number(X_SEQUENCE),
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_START_DATE_ACTIVE =>
      to_date(X_START_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_END_DATE_ACTIVE =>
      to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_TITLE => X_TITLE,
    X_DETAIL_MAX_LEN => to_number(X_DETAIL_MAX_LEN),
    X_SUMMARY_MAX_LEN => to_number(X_SUMMARY_MAX_LEN),
    X_DEFAULT_SUPPRESS_FLAG => X_DEFAULT_SUPPRESS_FLAG,
    X_FORMAT_MASK => X_FORMAT_MASK,
    X_CREATION_DATE => f_ludate,
    X_CREATED_BY => f_luby,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

end LOAD_ROW;

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_TITLE in VARCHAR2,
  X_DETAIL_MAX_LEN in NUMBER,
  X_SUMMARY_MAX_LEN in NUMBER,
  X_DEFAULT_SUPPRESS_FLAG in VARCHAR2,
  X_FORMAT_MASK in VARCHAR2
) is
  cursor c1 is select
      SEQUENCE,
      ENABLED_FLAG,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      TITLE,
      DETAIL_MAX_LEN,
      SUMMARY_MAX_LEN,
      DEFAULT_SUPPRESS_FLAG,
      FORMAT_MASK,
      APPLICATION_ID,
      ALERT_ID,
      NAME
    from ALR_ALERT_OUTPUTS
    where APPLICATION_ID = X_APPLICATION_ID
    and ALERT_ID = X_ALERT_ID
    and NAME = X_NAME
    for update of APPLICATION_ID nowait;
begin
  for recinfo in c1 loop
      if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
          AND (recinfo.ALERT_ID = X_ALERT_ID)
          AND (recinfo.NAME = X_NAME)
          AND (recinfo.SEQUENCE = X_SEQUENCE)
          AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
          AND (recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
          AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
               OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
          AND (recinfo.TITLE = X_TITLE)
          AND ((recinfo.DETAIL_MAX_LEN = X_DETAIL_MAX_LEN)
               OR ((recinfo.DETAIL_MAX_LEN is null) AND (X_DETAIL_MAX_LEN is null)))
          AND ((recinfo.SUMMARY_MAX_LEN = X_SUMMARY_MAX_LEN)
               OR ((recinfo.SUMMARY_MAX_LEN is null) AND (X_SUMMARY_MAX_LEN is null)))
          AND ((recinfo.DEFAULT_SUPPRESS_FLAG = X_DEFAULT_SUPPRESS_FLAG)
               OR ((recinfo.DEFAULT_SUPPRESS_FLAG is null) AND (X_DEFAULT_SUPPRESS_FLAG is null)))
          AND ((recinfo.FORMAT_MASK = X_FORMAT_MASK)
               OR ((recinfo.FORMAT_MASK is null) AND (X_FORMAT_MASK is null)))
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
  X_ALERT_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_SEQUENCE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_TITLE in VARCHAR2,
  X_DETAIL_MAX_LEN in NUMBER,
  X_SUMMARY_MAX_LEN in NUMBER,
  X_DEFAULT_SUPPRESS_FLAG in VARCHAR2,
  X_FORMAT_MASK in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ALR_ALERT_OUTPUTS set
    SEQUENCE = X_SEQUENCE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    TITLE = X_TITLE,
    DETAIL_MAX_LEN = X_DETAIL_MAX_LEN,
    SUMMARY_MAX_LEN = X_SUMMARY_MAX_LEN,
    DEFAULT_SUPPRESS_FLAG = X_DEFAULT_SUPPRESS_FLAG,
    FORMAT_MASK = X_FORMAT_MASK,
    APPLICATION_ID = X_APPLICATION_ID,
    ALERT_ID = X_ALERT_ID,
    NAME = X_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and ALERT_ID = X_ALERT_ID
  and NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_NAME in VARCHAR2
) is
begin
  delete from ALR_ALERT_OUTPUTS
  where APPLICATION_ID = X_APPLICATION_ID
  and ALERT_ID = X_ALERT_ID
  and NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


end ALR_ALERT_OUTPUTS_PKG;

/
