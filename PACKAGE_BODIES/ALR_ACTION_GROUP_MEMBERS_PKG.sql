--------------------------------------------------------
--  DDL for Package Body ALR_ACTION_GROUP_MEMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_ACTION_GROUP_MEMBERS_PKG" as
/* $Header: ALRAGRMB.pls 120.4.12010000.1 2008/07/27 06:58:11 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ACTION_GROUP_MEMBER_ID in NUMBER,
  X_ACTION_GROUP_ID in NUMBER,
  X_ACTION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_ACTION_LEVEL in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ALR_ACTION_GROUP_MEMBERS
    where APPLICATION_ID = X_APPLICATION_ID
    and ACTION_GROUP_MEMBER_ID = X_ACTION_GROUP_MEMBER_ID
    ;
begin
  insert into ALR_ACTION_GROUP_MEMBERS (
    APPLICATION_ID,
    ACTION_GROUP_MEMBER_ID,
    ACTION_GROUP_ID,
    ACTION_ID,
    ALERT_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    END_DATE_ACTIVE,
    ENABLED_FLAG,
    ACTION_LEVEL
  ) values (
    X_APPLICATION_ID,
    X_ACTION_GROUP_MEMBER_ID,
    X_ACTION_GROUP_ID,
    X_ACTION_ID,
    X_ALERT_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_END_DATE_ACTIVE,
    X_ENABLED_FLAG,
    X_ACTION_LEVEL
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
  X_GROUP_TYPE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_ACTION_NAME in VARCHAR2,
  X_END_DATE_ACTIVE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_ACTION_LEVEL in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
    l_user_id number := 0;
    l_app_id  number := 0;
    l_alert_id number := 0;
    l_action_id number := 0;
    l_action_group_id number := 0;
    l_action_group_member_id number := 0;
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

  select ACTION_ID into l_action_id
  from ALR_ACTIONS
  where APPLICATION_ID = l_app_id
  and ALERT_ID = l_alert_id
  and NAME = X_ACTION_NAME
  and (((END_DATE_ACTIVE is null)
     and (X_END_DATE_ACTIVE is null))
     or ((END_DATE_ACTIVE is not null)
     and (END_DATE_ACTIVE =
     to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'))));

  select ACTION_GROUP_ID into l_action_group_id
  from ALR_ACTION_GROUPS
  where APPLICATION_ID = l_app_id
  and ALERT_ID = l_alert_id
  and NAME = X_NAME
  and GROUP_TYPE = X_GROUP_TYPE;

  select ACTION_GROUP_MEMBER_ID into l_action_group_member_id
  from ALR_ACTION_GROUP_MEMBERS
  where APPLICATION_ID = l_app_id
  and ACTION_GROUP_ID = l_action_group_id
  and ACTION_ID = l_action_id
  and ALERT_ID = l_alert_id
  and ENABLED_FLAG = X_ENABLED_FLAG
  and (((ACTION_LEVEL is null)
     and (X_ACTION_LEVEL is null))
     or ((ACTION_LEVEL is not null)
     and (ACTION_LEVEL =
     to_number(X_ACTION_LEVEL))))
  and (((END_DATE_ACTIVE is null)
     and (X_END_DATE_ACTIVE is null))
     or ((END_DATE_ACTIVE is not null)
     and (END_DATE_ACTIVE =
     to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'))));

  select last_updated_by, last_update_date
  into  db_luby, db_ludate
  from ALR_ACTION_GROUP_MEMBERS
  where application_id = l_app_id
  and   action_group_member_id = l_action_group_member_id;

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                x_custom_mode)) then

  ALR_ACTION_GROUP_MEMBERS_PKG.UPDATE_ROW(
    X_APPLICATION_ID => l_app_id,
    X_ACTION_GROUP_MEMBER_ID =>  l_action_group_member_id,
    X_ACTION_GROUP_ID => l_action_group_id,
    X_ACTION_ID => l_action_id,
    X_ALERT_ID => l_alert_id,
    X_END_DATE_ACTIVE => to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_ACTION_LEVEL => to_number(X_ACTION_LEVEL),
    X_LAST_UPDATE_DATE => sysdate,
    X_LAST_UPDATED_BY => l_user_id,
    X_LAST_UPDATE_LOGIN => 0 );
end if;

exception

  when NO_DATA_FOUND then


  select ALR_ACTION_GROUP_MEMBERS_S.nextval into l_action_group_member_id
  from dual;

  ALR_ACTION_GROUP_MEMBERS_PKG.INSERT_ROW(
    X_ROWID => l_row_id,
    X_APPLICATION_ID => l_app_id,
    X_ACTION_GROUP_MEMBER_ID => l_action_group_member_id,
    X_ACTION_GROUP_ID => l_action_group_id,
    X_ACTION_ID => l_action_id,
    X_ALERT_ID => l_alert_id,
    X_END_DATE_ACTIVE => to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_ACTION_LEVEL => to_number(X_ACTION_LEVEL),
    X_CREATION_DATE => sysdate,
    X_CREATED_BY => l_user_id,
    X_LAST_UPDATE_DATE => sysdate,
    X_LAST_UPDATED_BY => l_user_id,
    X_LAST_UPDATE_LOGIN => 0 );

end LOAD_ROW;

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ACTION_GROUP_MEMBER_ID in NUMBER,
  X_ACTION_GROUP_ID in NUMBER,
  X_ACTION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_ACTION_LEVEL in NUMBER
) is
  cursor c1 is select
      ACTION_GROUP_ID,
      ACTION_ID,
      ALERT_ID,
      END_DATE_ACTIVE,
      ENABLED_FLAG,
      ACTION_LEVEL,
      APPLICATION_ID,
      ACTION_GROUP_MEMBER_ID
    from ALR_ACTION_GROUP_MEMBERS
    where APPLICATION_ID = X_APPLICATION_ID
    and ACTION_GROUP_MEMBER_ID = X_ACTION_GROUP_MEMBER_ID
    for update of APPLICATION_ID nowait;
begin
  for recinfo in c1 loop
      if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
          AND (recinfo.ACTION_GROUP_MEMBER_ID = X_ACTION_GROUP_MEMBER_ID)
          AND (recinfo.ACTION_GROUP_ID = X_ACTION_GROUP_ID)
          AND (recinfo.ACTION_ID = X_ACTION_ID)
          AND (recinfo.ALERT_ID = X_ALERT_ID)
          AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
               OR ((recinfo.END_DATE_ACTIVE is null)
               AND (X_END_DATE_ACTIVE is null)))
          AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
          AND ((recinfo.ACTION_LEVEL = X_ACTION_LEVEL)
               OR ((recinfo.ACTION_LEVEL is null) AND (X_ACTION_LEVEL is null)))
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
  X_ACTION_GROUP_MEMBER_ID in NUMBER,
  X_ACTION_GROUP_ID in NUMBER,
  X_ACTION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_ACTION_LEVEL in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ALR_ACTION_GROUP_MEMBERS set
    ACTION_GROUP_ID = X_ACTION_GROUP_ID,
    ACTION_ID = X_ACTION_ID,
    ALERT_ID = X_ALERT_ID,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    ACTION_LEVEL = X_ACTION_LEVEL,
    APPLICATION_ID = X_APPLICATION_ID,
    ACTION_GROUP_MEMBER_ID = X_ACTION_GROUP_MEMBER_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and ACTION_GROUP_MEMBER_ID = X_ACTION_GROUP_MEMBER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ACTION_GROUP_MEMBER_ID in NUMBER
) is
begin
  delete from ALR_ACTION_GROUP_MEMBERS
  where APPLICATION_ID = X_APPLICATION_ID
  and ACTION_GROUP_MEMBER_ID = X_ACTION_GROUP_MEMBER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


end ALR_ACTION_GROUP_MEMBERS_PKG;

/
