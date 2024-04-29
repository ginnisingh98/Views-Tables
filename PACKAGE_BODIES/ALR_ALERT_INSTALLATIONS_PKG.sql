--------------------------------------------------------
--  DDL for Package Body ALR_ALERT_INSTALLATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_ALERT_INSTALLATIONS_PKG" as
/* $Header: ALRAINSB.pls 120.4.12010000.1 2008/07/27 06:58:18 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_ORACLE_ID in NUMBER,
  X_DATA_GROUP_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

  /* oracle_id and data_group_id can be null */
  cursor C is select ROWID from ALR_ALERT_INSTALLATIONS
    where APPLICATION_ID = X_APPLICATION_ID
    and ALERT_ID = X_ALERT_ID
    and (((ORACLE_ID is null)
      and (X_ORACLE_ID is null))
      or ((ORACLE_ID is not null)
      and (ORACLE_ID = X_ORACLE_ID)))
    and (((DATA_GROUP_ID is null)
      and (X_DATA_GROUP_ID is null))
      or ((DATA_GROUP_ID is not null)
      and (DATA_GROUP_ID = X_DATA_GROUP_ID)))
    ;
begin
  insert into ALR_ALERT_INSTALLATIONS (
    APPLICATION_ID,
    ALERT_ID,
    ORACLE_ID,
    DATA_GROUP_ID,
    ENABLED_FLAG,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_ALERT_ID,
    X_ORACLE_ID,
    X_DATA_GROUP_ID,
    X_ENABLED_FLAG,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN
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
  X_ORACLE_USERNAME in VARCHAR2,
  X_DATA_GROUP_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
    l_user_id number := 0;
    l_app_id  number := 0;
    l_alert_id number := 0;
    l_oracle_id number := null;
    l_data_group_id number := null;
    l_row_id varchar2(64);

    f_luby    number;  -- entity owner in file
    f_ludate  date;    -- entity update date in file
    db_luby   number;  -- entity owner in db
    db_ludate date;    -- entity update date in db

begin
--  DBMS_SESSION.SET_SQL_TRACE(TRUE);
--  insert into applsys.nancy values  ('l_user_id', l_user_id);
--  commit;

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

  if (X_ORACLE_USERNAME is not null) then
    select ORACLE_ID into l_oracle_id
    from FND_ORACLE_USERID
    where ORACLE_USERNAME = X_ORACLE_USERNAME;
  end if;

  if (X_DATA_GROUP_NAME is not null) then
    select ORGANIZATION_ID into l_data_group_id
   from HR_OPERATING_UNITS
   where NAME = X_DATA_GROUP_NAME;
 end if;


  select last_updated_by, last_update_date
  into  db_luby, db_ludate
  from ALR_ALERT_INSTALLATIONS
  where application_id = l_app_id
  and   alert_id = l_alert_id
  and   ((data_group_id is null and l_data_group_id is null) or
        data_group_id = l_data_group_id)
  and   ((oracle_id is null and l_oracle_id is null) or
	oracle_id = l_oracle_id);

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                x_custom_mode)) then

  ALR_ALERT_INSTALLATIONS_PKG.UPDATE_ROW(
    X_APPLICATION_ID => l_app_id,
    X_ALERT_ID => l_alert_id,
    X_ORACLE_ID => l_oracle_id,
    X_DATA_GROUP_ID => l_data_group_id,
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

end if;

--  DBMS_SESSION.SET_SQL_TRACE(FALSE);
exception

  when NO_DATA_FOUND then

--  insert into applsys.nancy values  ('insert l_user_id', l_user_id);
--  commit;

  ALR_ALERT_INSTALLATIONS_PKG.INSERT_ROW(
    X_ROWID => l_row_id,
    X_APPLICATION_ID => l_app_id,
    X_ALERT_ID => l_alert_id,
    X_ORACLE_ID => l_oracle_id,
    X_DATA_GROUP_ID => l_data_group_id,
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_CREATION_DATE => f_ludate,
    X_CREATED_BY => f_luby,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

--  DBMS_SESSION.SET_SQL_TRACE(FALSE);
end LOAD_ROW;

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_ORACLE_ID in NUMBER,
  X_DATA_GROUP_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2
) is
  cursor c1 is select
      ENABLED_FLAG,
      APPLICATION_ID,
      ALERT_ID,
      ORACLE_ID,
      DATA_GROUP_ID
    from ALR_ALERT_INSTALLATIONS
    where APPLICATION_ID = X_APPLICATION_ID
    and ALERT_ID = X_ALERT_ID
    and (((ORACLE_ID is null)
      and (X_ORACLE_ID is null))
      or ((ORACLE_ID is not null)
      and (ORACLE_ID = X_ORACLE_ID)))
    and (((DATA_GROUP_ID is null)
      and (X_DATA_GROUP_ID is null))
      or ((DATA_GROUP_ID is not null)
      and (DATA_GROUP_ID = X_DATA_GROUP_ID)))
    for update of APPLICATION_ID nowait;
begin
  for recinfo in c1 loop
      if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
          AND (recinfo.ALERT_ID = X_ALERT_ID)
          AND ((recinfo.ORACLE_ID = X_ORACLE_ID)
               OR ((recinfo.ORACLE_ID is null) AND (X_ORACLE_ID is null)))
          AND ((recinfo.DATA_GROUP_ID = X_DATA_GROUP_ID)
               OR ((recinfo.DATA_GROUP_ID is null) AND (X_DATA_GROUP_ID is null)))
          AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
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
  X_ORACLE_ID in NUMBER,
  X_DATA_GROUP_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ALR_ALERT_INSTALLATIONS set
    ENABLED_FLAG = X_ENABLED_FLAG,
    APPLICATION_ID = X_APPLICATION_ID,
    ALERT_ID = X_ALERT_ID,
    ORACLE_ID = X_ORACLE_ID,
    DATA_GROUP_ID = X_DATA_GROUP_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and ALERT_ID = X_ALERT_ID
  and (((ORACLE_ID is null)
    and (X_ORACLE_ID is null))
    or ((ORACLE_ID is not null)
    and (ORACLE_ID = X_ORACLE_ID)))
  and (((DATA_GROUP_ID is null)
    and (X_DATA_GROUP_ID is null))
    or ((DATA_GROUP_ID is not null)
    and (DATA_GROUP_ID = X_DATA_GROUP_ID)));

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_ORACLE_ID in NUMBER,
  X_DATA_GROUP_ID in NUMBER
) is
begin
  delete from ALR_ALERT_INSTALLATIONS
  where APPLICATION_ID = X_APPLICATION_ID
  and ALERT_ID = X_ALERT_ID
  and (((ORACLE_ID is null)
    and (X_ORACLE_ID is null))
    or ((ORACLE_ID is not null)
    and (ORACLE_ID = X_ORACLE_ID)))
  and (((DATA_GROUP_ID is null)
    and (X_DATA_GROUP_ID is null))
    or ((DATA_GROUP_ID is not null)
    and (DATA_GROUP_ID = X_DATA_GROUP_ID)));

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end ALR_ALERT_INSTALLATIONS_PKG;

/
