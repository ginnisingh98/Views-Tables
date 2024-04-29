--------------------------------------------------------
--  DDL for Package Body ALR_ALERT_INPUTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_ALERT_INPUTS_PKG" as
/* $Header: ALRAINPB.pls 120.5.12010000.1 2008/07/27 06:58:16 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_TITLE in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ALR_ALERT_INPUTS
    where APPLICATION_ID = X_APPLICATION_ID
    and ALERT_ID = X_ALERT_ID
    and NAME = X_NAME
    ;
begin
  insert into ALR_ALERT_INPUTS (
    LAST_UPDATED_BY,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    ENABLED_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    TITLE,
    DATA_TYPE,
    DEFAULT_VALUE,
    APPLICATION_ID,
    ALERT_ID,
    NAME,
    LAST_UPDATE_DATE,
    CREATION_DATE
  ) values (
    X_LAST_UPDATED_BY,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ENABLED_FLAG,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_TITLE,
    X_DATA_TYPE,
    X_DEFAULT_VALUE,
    X_APPLICATION_ID,
    X_ALERT_ID,
    X_NAME,
    X_LAST_UPDATE_DATE,
    X_CREATION_DATE
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
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in VARCHAR2,
  X_END_DATE_ACTIVE in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
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

  select APPLICATION_ID into l_app_id
  from FND_APPLICATION
  where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME;

  select ALERT_ID into l_alert_id
  from ALR_ALERTS
  where APPLICATION_ID = l_app_id
  and ALERT_NAME = X_ALERT_NAME;

   -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(X_OWNER);

 -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  select last_updated_by, last_update_date
  into  db_luby, db_ludate
  from ALR_ALERT_INPUTS
  where application_id = l_app_id
  and   alert_id = l_alert_id
  and   name = X_NAME;

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                x_custom_mode)) then

 ALR_ALERT_INPUTS_PKG.UPDATE_ROW(
    X_APPLICATION_ID => l_app_id,
    X_ALERT_ID => l_alert_id,
    X_NAME => X_NAME,
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_START_DATE_ACTIVE =>
      to_date(X_START_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_END_DATE_ACTIVE =>
      to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_TITLE => X_TITLE,
    X_DATA_TYPE => X_DATA_TYPE,
    X_DEFAULT_VALUE => X_DEFAULT_VALUE,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );
end if;

exception
  when NO_DATA_FOUND then

  ALR_ALERT_INPUTS_PKG.INSERT_ROW(
    X_ROWID => l_row_id,
    X_APPLICATION_ID => l_app_id,
    X_ALERT_ID => l_alert_id,
    X_NAME => X_NAME,
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_START_DATE_ACTIVE =>
      to_date(X_START_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_END_DATE_ACTIVE =>
      to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_TITLE => X_TITLE,
    X_DATA_TYPE => X_DATA_TYPE,
    X_DEFAULT_VALUE => X_DEFAULT_VALUE,
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
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_TITLE in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2
) is
  cursor c1 is select
      APPLICATION_ID,
      ALERT_ID,
      NAME,
      ENABLED_FLAG,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      TITLE,
      DATA_TYPE,
      DEFAULT_VALUE
    from ALR_ALERT_INPUTS
    where APPLICATION_ID = X_APPLICATION_ID
    and ALERT_ID = X_ALERT_ID
    and NAME = X_NAME
    for update of APPLICATION_ID nowait;
begin
  for recinfo in c1 loop
      if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
          AND (recinfo.ALERT_ID = X_ALERT_ID)
          AND (recinfo.NAME = X_NAME)
          AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
          AND (recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
          AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
               OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
          AND (recinfo.TITLE = X_TITLE)
          AND (recinfo.DATA_TYPE = X_DATA_TYPE)
          AND ((recinfo.DEFAULT_VALUE = X_DEFAULT_VALUE)
               OR ((recinfo.DEFAULT_VALUE is null) AND (X_DEFAULT_VALUE is null)))
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
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_TITLE in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ALR_ALERT_INPUTS set
    ENABLED_FLAG = X_ENABLED_FLAG,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    TITLE = X_TITLE,
    DATA_TYPE = X_DATA_TYPE,
    DEFAULT_VALUE = X_DEFAULT_VALUE,
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
  delete from ALR_ALERT_INPUTS
  where APPLICATION_ID = X_APPLICATION_ID
  and ALERT_ID = X_ALERT_ID
  and NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end ALR_ALERT_INPUTS_PKG;

/
