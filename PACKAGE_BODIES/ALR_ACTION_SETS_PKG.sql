--------------------------------------------------------
--  DDL for Package Body ALR_ACTION_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_ACTION_SETS_PKG" as
/* $Header: ALRASTSB.pls 120.3.12010000.1 2008/07/27 06:58:36 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ACTION_SET_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_ALERT_ID in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_RECIPIENTS_VIEW_ONLY_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SUPPRESS_FLAG in VARCHAR2,
  X_SUPPRESS_DAYS in NUMBER,
  X_SEQUENCE in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ALR_ACTION_SETS
    where APPLICATION_ID = X_APPLICATION_ID
    and ACTION_SET_ID = X_ACTION_SET_ID
    ;
begin
  insert into ALR_ACTION_SETS (
    APPLICATION_ID,
    ACTION_SET_ID,
    NAME,
    ALERT_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    END_DATE_ACTIVE,
    ENABLED_FLAG,
    RECIPIENTS_VIEW_ONLY_FLAG,
    DESCRIPTION,
    SUPPRESS_FLAG,
    SUPPRESS_DAYS,
    SEQUENCE
  ) values (
    X_APPLICATION_ID,
    X_ACTION_SET_ID,
    X_NAME,
    X_ALERT_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_END_DATE_ACTIVE,
    X_ENABLED_FLAG,
    X_RECIPIENTS_VIEW_ONLY_FLAG,
    X_DESCRIPTION,
    X_SUPPRESS_FLAG,
    X_SUPPRESS_DAYS,
    X_SEQUENCE);

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
  X_END_DATE_ACTIVE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_RECIPIENTS_VIEW_ONLY_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SUPPRESS_FLAG in VARCHAR2,
  X_SUPPRESS_DAYS in VARCHAR2,
  X_SEQUENCE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is

    l_user_id number := 0;
    l_app_id  number := 0;
    l_alert_id number := 0;
    l_action_set_id number := 0;
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

  select application_id into l_app_id
  from fnd_application
  where application_short_name = X_APPLICATION_SHORT_NAME;

  select alert_id into l_alert_id
  from alr_alerts
  where application_id = l_app_id
  and alert_name = X_ALERT_NAME;

  select action_set_id into l_action_set_id
  from alr_action_sets
  where application_id = l_app_id
  and alert_id = l_alert_id
  and name = X_NAME;

  select last_updated_by, last_update_date
  into  db_luby, db_ludate
  from ALR_ACTION_SETS
  where application_id = l_app_id
  and   action_set_id = l_action_set_id;

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                x_custom_mode)) then

  ALR_ACTION_SETS_PKG.UPDATE_ROW(
    X_APPLICATION_ID => l_app_id,
    X_ACTION_SET_ID => l_action_set_id,
    X_NAME => X_NAME,
    X_ALERT_ID => l_alert_id ,
    X_END_DATE_ACTIVE => to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_RECIPIENTS_VIEW_ONLY_FLAG => X_RECIPIENTS_VIEW_ONLY_FLAG,
    X_DESCRIPTION => X_DESCRIPTION,
    X_SUPPRESS_FLAG => X_SUPPRESS_FLAG,
    X_SUPPRESS_DAYS => to_number(X_SUPPRESS_DAYS),
    X_SEQUENCE => to_number(X_SEQUENCE),
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

end if;

exception

  when NO_DATA_FOUND then

  select alr_action_sets_s.nextval into l_action_set_id from dual;

  ALR_ACTION_SETS_PKG.INSERT_ROW(
    X_ROWID => l_row_id,
    X_APPLICATION_ID => l_app_id,
    X_ACTION_SET_ID => l_action_set_id,
    X_NAME => X_NAME,
    X_ALERT_ID => l_alert_id,
    X_END_DATE_ACTIVE =>
      to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_RECIPIENTS_VIEW_ONLY_FLAG => X_RECIPIENTS_VIEW_ONLY_FLAG,
    X_DESCRIPTION => X_DESCRIPTION,
    X_SUPPRESS_FLAG => X_SUPPRESS_FLAG,
    X_SUPPRESS_DAYS => to_number(X_SUPPRESS_DAYS),
    X_SEQUENCE => to_number(X_SEQUENCE),
    X_CREATION_DATE => f_ludate,
    X_CREATED_BY => f_luby,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

end LOAD_ROW;

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ACTION_SET_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_ALERT_ID in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_RECIPIENTS_VIEW_ONLY_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SUPPRESS_FLAG in VARCHAR2,
  X_SUPPRESS_DAYS in NUMBER,
  X_SEQUENCE in NUMBER
) is
  cursor c1 is select
      NAME,
      ALERT_ID,
      END_DATE_ACTIVE,
      ENABLED_FLAG,
      RECIPIENTS_VIEW_ONLY_FLAG,
      DESCRIPTION,
      SUPPRESS_FLAG,
      SUPPRESS_DAYS,
      SEQUENCE,
      APPLICATION_ID,
      ACTION_SET_ID
    from ALR_ACTION_SETS
    where APPLICATION_ID = X_APPLICATION_ID
    and ACTION_SET_ID = X_ACTION_SET_ID
    for update of APPLICATION_ID nowait;
begin
  for recinfo in c1 loop
      if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
          AND (recinfo.ACTION_SET_ID = X_ACTION_SET_ID)
          AND (recinfo.NAME = X_NAME)
          AND (recinfo.ALERT_ID = X_ALERT_ID)
          AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
               OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
          AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
          AND (recinfo.RECIPIENTS_VIEW_ONLY_FLAG = X_RECIPIENTS_VIEW_ONLY_FLAG)
          AND ((recinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((recinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND ((recinfo.SUPPRESS_FLAG = X_SUPPRESS_FLAG)
               OR ((recinfo.SUPPRESS_FLAG is null) AND (X_SUPPRESS_FLAG is null)))
          AND ((recinfo.SUPPRESS_DAYS = X_SUPPRESS_DAYS)
               OR ((recinfo.SUPPRESS_DAYS is null) AND (X_SUPPRESS_DAYS is null)))
          AND (recinfo.SEQUENCE = X_SEQUENCE)
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
  X_ACTION_SET_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_ALERT_ID in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_RECIPIENTS_VIEW_ONLY_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SUPPRESS_FLAG in VARCHAR2,
  X_SUPPRESS_DAYS in NUMBER,
  X_SEQUENCE in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ALR_ACTION_SETS set
    NAME = X_NAME,
    ALERT_ID = X_ALERT_ID,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    RECIPIENTS_VIEW_ONLY_FLAG = X_RECIPIENTS_VIEW_ONLY_FLAG,
    DESCRIPTION = X_DESCRIPTION,
    SUPPRESS_FLAG = X_SUPPRESS_FLAG,
    SUPPRESS_DAYS = X_SUPPRESS_DAYS,
    SEQUENCE = X_SEQUENCE,
    APPLICATION_ID = X_APPLICATION_ID,
    ACTION_SET_ID = X_ACTION_SET_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and ACTION_SET_ID = X_ACTION_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ACTION_SET_ID in NUMBER
) is
begin
  delete from ALR_ACTION_SETS
  where APPLICATION_ID = X_APPLICATION_ID
  and ACTION_SET_ID = X_ACTION_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end ALR_ACTION_SETS_PKG;

/
