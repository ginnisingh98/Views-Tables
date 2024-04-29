--------------------------------------------------------
--  DDL for Package Body ALR_ACTION_SET_MEMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_ACTION_SET_MEMBERS_PKG" as
/* $Header: ALRASTMB.pls 120.3.12010000.1 2008/07/27 06:58:33 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ACTION_SET_MEMBER_ID in NUMBER,
  X_ACTION_SET_ID in NUMBER,
  X_ACTION_ID in NUMBER,
  X_ACTION_GROUP_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_SEQUENCE in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_SUMMARY_THRESHOLD in NUMBER,
  X_ABORT_FLAG in VARCHAR2,
  X_ERROR_ACTION_SEQUENCE in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ALR_ACTION_SET_MEMBERS
    where APPLICATION_ID = X_APPLICATION_ID
    and ACTION_SET_MEMBER_ID = X_ACTION_SET_MEMBER_ID
    ;
begin
  insert into ALR_ACTION_SET_MEMBERS (
    APPLICATION_ID,
    ACTION_SET_MEMBER_ID,
    ACTION_SET_ID,
    ACTION_ID,
    ACTION_GROUP_ID,
    ALERT_ID,
    SEQUENCE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    END_DATE_ACTIVE,
    ENABLED_FLAG,
    SUMMARY_THRESHOLD,
    ABORT_FLAG,
    ERROR_ACTION_SEQUENCE
  ) values (
    X_APPLICATION_ID,
    X_ACTION_SET_MEMBER_ID,
    X_ACTION_SET_ID,
    X_ACTION_ID,
    X_ACTION_GROUP_ID,
    X_ALERT_ID,
    X_SEQUENCE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_END_DATE_ACTIVE,
    X_ENABLED_FLAG,
    X_SUMMARY_THRESHOLD,
    X_ABORT_FLAG,
    X_ERROR_ACTION_SEQUENCE);

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
  X_ACTION_NAME in VARCHAR2,
  X_GROUP_NAME in VARCHAR2,
  X_GROUP_TYPE in VARCHAR2,
  X_SEQUENCE in VARCHAR2,
  X_END_DATE_ACTIVE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SUMMARY_THRESHOLD in VARCHAR2,
  X_ABORT_FLAG in VARCHAR2,
  X_ERROR_ACTION_SEQUENCE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
    l_user_id number := 0;
    l_app_id  number := 0;
    l_alert_id number := 0;
    l_action_id number := null; /* Can be a null value */
    l_action_set_id number := 0;
    l_action_group_id number := null; /* Can be a null value */
    l_action_set_member_id number := 0;
    l_row_id varchar2(64);

    f_luby    number;  -- entity owner in file
    f_ludate  date;    -- entity update date in file
    db_luby   number;  -- entity owner in db
    db_ludate date;    -- entity update date in db

begin

--   EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context forever ,level 4''';

  DBMS_SESSION.SET_SQL_TRACE(FALSE);
  DBMS_SESSION.SET_SQL_TRACE(TRUE);

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

  if ((X_GROUP_NAME is not null) and (X_GROUP_TYPE is not null)) then
    select action_group_id into l_action_group_id
    from alr_action_groups
    where application_id = l_app_id
    and alert_id = l_alert_id
    and name = X_GROUP_NAME
    and group_type = X_GROUP_TYPE;
  end if;

  /* The X_ACTION_NAME can be null */
  if (X_ACTION_NAME is not null) then
  /* 3779021 since the action_id is hardcoded */
    if (X_ACTION_NAME = 'Exit Action Set Successfully') then
       l_action_id := -5;
  /* 3779021 */
    else
       select action_id into l_action_id
       from alr_actions
       where application_id = l_app_id
       and alert_id = l_alert_id
       and name = X_ACTION_NAME
       and ((end_date_active  is null) or
         ((end_date_active is not null) and (end_date_active =
         to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'))));
    end if;
  end if;

  /* Place the columns which can be null on the bottom */
  select distinct action_set_member_id into l_action_set_member_id
  from alr_action_set_members
  where application_id = l_app_id
  and action_set_id = l_action_set_id
  and alert_id = l_alert_id
  and sequence = to_number(X_SEQUENCE)
  and enabled_flag = X_ENABLED_FLAG
  and abort_flag = X_ABORT_FLAG
  and (((action_id is null)  and (l_action_id is null))
    or ((action_id is not null)
    and (action_id = l_action_id)))
  and (((action_group_id is null) and (l_action_group_id is null))
    or ((action_group_id is not null)
    and (action_group_id = l_action_group_id)))
  and (((end_date_active is null) and (X_END_DATE_ACTIVE is null))
    or ((end_date_active is not null)
    and (end_date_active =
      to_date (X_END_DATE_ACTIVE, 'YYYY/MM/DD HH24:MI:SS'))))
  and (((summary_threshold is null) and (X_SUMMARY_THRESHOLD is null))
    or ((summary_threshold is not null)
    and (summary_threshold = to_number(X_SUMMARY_THRESHOLD))))
  and (((error_action_sequence is null)
    and (X_ERROR_ACTION_SEQUENCE is null))
    or ((error_action_sequence is not null)
    and (error_action_sequence = to_number(X_ERROR_ACTION_SEQUENCE))));

  select last_updated_by, last_update_date
  into  db_luby, db_ludate
  from ALR_ACTION_SET_MEMBERS
  where application_id = l_app_id
  and   action_set_member_id = l_action_set_member_id;

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                x_custom_mode)) then

  ALR_ACTION_SET_MEMBERS_PKG.UPDATE_ROW(
    X_APPLICATION_ID => l_app_id,
    X_ACTION_SET_MEMBER_ID => l_action_set_member_id,
    X_ACTION_SET_ID => l_action_set_id,
    X_ACTION_ID => l_action_id,
    X_ACTION_GROUP_ID => l_action_group_id,
    X_ALERT_ID => l_alert_id,
    X_SEQUENCE => to_number(X_SEQUENCE),
    X_END_DATE_ACTIVE => to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_SUMMARY_THRESHOLD => to_number(X_SUMMARY_THRESHOLD),
    X_ABORT_FLAG => X_ABORT_FLAG,
    X_ERROR_ACTION_SEQUENCE => to_number(X_ERROR_ACTION_SEQUENCE),
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

  end if;

exception

  when NO_DATA_FOUND then

  select ALR_ACTION_SET_MEMBERS_S.nextval
    into l_action_set_member_id
    from dual;

  ALR_ACTION_SET_MEMBERS_PKG.INSERT_ROW(
    X_ROWID => l_row_id,
    X_APPLICATION_ID => l_app_id,
    X_ACTION_SET_MEMBER_ID => l_action_set_member_id,
    X_ACTION_SET_ID => l_action_set_id,
    X_ACTION_ID => l_action_id,
    X_ACTION_GROUP_ID => l_action_group_id,
    X_ALERT_ID => l_alert_id,
    X_SEQUENCE => to_number(X_SEQUENCE),
    X_END_DATE_ACTIVE => to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_SUMMARY_THRESHOLD => to_number(X_SUMMARY_THRESHOLD),
    X_ABORT_FLAG => X_ABORT_FLAG,
    X_ERROR_ACTION_SEQUENCE => to_number(X_ERROR_ACTION_SEQUENCE),
    X_CREATION_DATE => f_ludate,
    X_CREATED_BY => f_luby,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

end LOAD_ROW;

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ACTION_SET_MEMBER_ID in NUMBER,
  X_ACTION_SET_ID in NUMBER,
  X_ACTION_ID in NUMBER,
  X_ACTION_GROUP_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_SEQUENCE in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_SUMMARY_THRESHOLD in NUMBER,
  X_ABORT_FLAG in VARCHAR2,
  X_ERROR_ACTION_SEQUENCE in NUMBER
) is
  cursor c1 is select
      ACTION_SET_ID,
      ACTION_ID,
      ACTION_GROUP_ID,
      ALERT_ID,
      SEQUENCE,
      END_DATE_ACTIVE,
      ENABLED_FLAG,
      SUMMARY_THRESHOLD,
      ABORT_FLAG,
      ERROR_ACTION_SEQUENCE,
      APPLICATION_ID,
      ACTION_SET_MEMBER_ID
    from ALR_ACTION_SET_MEMBERS
    where APPLICATION_ID = X_APPLICATION_ID
    and ACTION_SET_MEMBER_ID = X_ACTION_SET_MEMBER_ID
    for update of APPLICATION_ID nowait;
begin
  for recinfo in c1 loop
      if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
          AND (recinfo.ACTION_SET_MEMBER_ID = X_ACTION_SET_MEMBER_ID)
          AND (recinfo.ACTION_SET_ID = X_ACTION_SET_ID)
          AND ((recinfo.ACTION_ID = X_ACTION_ID)
               OR ((recinfo.ACTION_ID is null) AND (X_ACTION_ID is null)))
          AND ((recinfo.ACTION_GROUP_ID = X_ACTION_GROUP_ID)
               OR ((recinfo.ACTION_GROUP_ID is null)
               AND (X_ACTION_GROUP_ID is null)))
          AND (recinfo.ALERT_ID = X_ALERT_ID)
          AND (recinfo.SEQUENCE = X_SEQUENCE)
          AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
               OR ((recinfo.END_DATE_ACTIVE is null)
               AND (X_END_DATE_ACTIVE is null)))
          AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
          AND ((recinfo.SUMMARY_THRESHOLD = X_SUMMARY_THRESHOLD)
               OR ((recinfo.SUMMARY_THRESHOLD is null)
               AND (X_SUMMARY_THRESHOLD is null)))
          AND (recinfo.ABORT_FLAG = X_ABORT_FLAG)
          AND ((recinfo.ERROR_ACTION_SEQUENCE = X_ERROR_ACTION_SEQUENCE)
               OR ((recinfo.ERROR_ACTION_SEQUENCE is null)
               AND (X_ERROR_ACTION_SEQUENCE is null)))
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
  X_ACTION_SET_MEMBER_ID in NUMBER,
  X_ACTION_SET_ID in NUMBER,
  X_ACTION_ID in NUMBER,
  X_ACTION_GROUP_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_SEQUENCE in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_SUMMARY_THRESHOLD in NUMBER,
  X_ABORT_FLAG in VARCHAR2,
  X_ERROR_ACTION_SEQUENCE in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ALR_ACTION_SET_MEMBERS set
    ACTION_SET_ID = X_ACTION_SET_ID,
    ACTION_ID = X_ACTION_ID,
    ACTION_GROUP_ID = X_ACTION_GROUP_ID,
    ALERT_ID = X_ALERT_ID,
    SEQUENCE = X_SEQUENCE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    SUMMARY_THRESHOLD = X_SUMMARY_THRESHOLD,
    ABORT_FLAG = X_ABORT_FLAG,
    ERROR_ACTION_SEQUENCE = X_ERROR_ACTION_SEQUENCE,
    APPLICATION_ID = X_APPLICATION_ID,
    ACTION_SET_MEMBER_ID = X_ACTION_SET_MEMBER_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and ACTION_SET_MEMBER_ID = X_ACTION_SET_MEMBER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ACTION_SET_MEMBER_ID in NUMBER
) is
begin
  delete from ALR_ACTION_SET_MEMBERS
  where APPLICATION_ID = X_APPLICATION_ID
  and ACTION_SET_MEMBER_ID = X_ACTION_SET_MEMBER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


end ALR_ACTION_SET_MEMBERS_PKG;

/
