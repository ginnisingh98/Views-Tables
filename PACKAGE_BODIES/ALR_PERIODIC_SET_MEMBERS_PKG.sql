--------------------------------------------------------
--  DDL for Package Body ALR_PERIODIC_SET_MEMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_PERIODIC_SET_MEMBERS_PKG" as
/* $Header: ALRPSTMB.pls 120.5.12010000.1 2008/07/27 06:58:53 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_PERIODIC_SET_ID in NUMBER,
  X_CHILD_APPLICATION_ID in NUMBER,
  X_CHILD_ALERT_ID in NUMBER,
  X_CHILD_PERIODIC_SET_ID in NUMBER,
  X_SEQUENCE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_END_DATE_ACTIVE in DATE,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  /* sequence, child_alert_id, and child_periodic_set_id can be null */
  cursor C is select ROWID from ALR_PERIODIC_SET_MEMBERS
    where APPLICATION_ID = X_APPLICATION_ID
    and PERIODIC_SET_ID = X_PERIODIC_SET_ID
    and CHILD_APPLICATION_ID = X_CHILD_APPLICATION_ID
    and ((CHILD_ALERT_ID is null)
      or ((CHILD_ALERT_ID is not null)
      and (CHILD_ALERT_ID = X_CHILD_ALERT_ID)))
    and ((CHILD_PERIODIC_SET_ID is null)
      or ((CHILD_PERIODIC_SET_ID is not null)
      and (CHILD_PERIODIC_SET_ID = X_CHILD_PERIODIC_SET_ID)))
    and ((SEQUENCE is null)
      or ((SEQUENCE is not null)
      and (SEQUENCE = X_SEQUENCE)))
    ;
begin
  insert into ALR_PERIODIC_SET_MEMBERS (
    APPLICATION_ID,
    PERIODIC_SET_ID,
    SEQUENCE,
    CHILD_APPLICATION_ID,
    CHILD_ALERT_ID,
    CHILD_PERIODIC_SET_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    ENABLED_FLAG,
    END_DATE_ACTIVE
  ) values (
    X_APPLICATION_ID,
    X_PERIODIC_SET_ID,
    X_SEQUENCE,
    X_CHILD_APPLICATION_ID,
    X_CHILD_ALERT_ID,
    X_CHILD_PERIODIC_SET_ID,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    X_ENABLED_FLAG,
    X_END_DATE_ACTIVE);

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
  X_NAME in VARCHAR2,
  X_SEQUENCE in VARCHAR2,
  X_CHILD_APPLICATION_SHORT_NAME in VARCHAR2,
  X_CHILD_ALERT_NAME in VARCHAR2,
  X_CHILD_PERIODIC_SET_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_END_DATE_ACTIVE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
  l_user_id number := 0;
  l_row_id varchar2(64);
  l_app_id number := 0;
  l_per_id number := 0;
  l_child_app_id number := 0;
  l_child_alert_id number;
  l_child_per_id number;
  l_seq number := 0;

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

  select periodic_set_id into l_per_id
  from alr_periodic_sets
  where application_id = l_app_id
  and name = X_NAME;

  select application_id into l_child_app_id
  from fnd_application
  where application_short_name = X_CHILD_APPLICATION_SHORT_NAME;

  if X_CHILD_ALERT_NAME is not null then
  	select alert_id into l_child_alert_id
  	from alr_alerts
  	where application_id = l_child_app_id
  	and alert_name = X_CHILD_ALERT_NAME;
  end if;

  if X_CHILD_PERIODIC_SET_NAME is not null then
  	select periodic_set_id into l_child_per_id
  	from alr_periodic_sets
  	where application_id = l_child_app_id
  	and name = X_CHILD_PERIODIC_SET_NAME;
  end if;

  select last_updated_by, last_update_date
  into  db_luby, db_ludate
  from ALR_PERIODIC_SET_MEMBERS
  where application_id = l_app_id
  and   ((child_alert_id is not null
        and child_alert_id = l_child_alert_id)
        or  (child_alert_id is NULL and
        l_child_alert_id is null))
  and   child_application_id = l_child_app_id
  and   ((child_periodic_set_id is not null
         and child_periodic_set_id = l_child_per_id)
         or (child_periodic_set_id is null
         and l_child_per_id is null))
  and   periodic_set_id = l_per_id
  and   sequence = X_SEQUENCE;

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                x_custom_mode)) then

  ALR_PERIODIC_SET_MEMBERS_PKG.UPDATE_ROW(
    X_APPLICATION_ID => l_app_id,
    X_PERIODIC_SET_ID => l_per_id,
    X_CHILD_APPLICATION_ID => l_child_app_id,
    X_CHILD_ALERT_ID => l_child_alert_id,
    X_CHILD_PERIODIC_SET_ID => l_child_per_id,
    X_SEQUENCE => to_number(X_SEQUENCE),
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_END_DATE_ACTIVE => to_date(X_END_DATE_ACTIVE,
                         'YYYY/MM/DD HH24:MI:SS'),
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

end if;

exception
  when NO_DATA_FOUND then

  ALR_PERIODIC_SET_MEMBERS_PKG.INSERT_ROW(
    X_ROWID => l_row_id,
    X_APPLICATION_ID => l_app_id,
    X_PERIODIC_SET_ID => l_per_id,
    X_CHILD_APPLICATION_ID => l_child_app_id,
    X_CHILD_ALERT_ID => l_child_alert_id,
    X_CHILD_PERIODIC_SET_ID => l_child_per_id,
    X_SEQUENCE => to_number(X_SEQUENCE),
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_END_DATE_ACTIVE => to_date(X_END_DATE_ACTIVE,
                         'YYYY/MM/DD HH24:MI:SS'),
    X_CREATION_DATE => f_ludate,
    X_CREATED_BY => f_luby,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

end LOAD_ROW;

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_PERIODIC_SET_ID in NUMBER,
  X_CHILD_APPLICATION_ID in NUMBER,
  X_CHILD_ALERT_ID in NUMBER,
  X_CHILD_PERIODIC_SET_ID in NUMBER,
  X_SEQUENCE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_END_DATE_ACTIVE in DATE
) is
  cursor c1 is select
      ENABLED_FLAG,
      END_DATE_ACTIVE,
      APPLICATION_ID,
      PERIODIC_SET_ID,
      CHILD_APPLICATION_ID,
      CHILD_ALERT_ID,
      CHILD_PERIODIC_SET_ID,
      SEQUENCE
    from ALR_PERIODIC_SET_MEMBERS
    where APPLICATION_ID = X_APPLICATION_ID
    and PERIODIC_SET_ID = X_PERIODIC_SET_ID
    and CHILD_APPLICATION_ID = X_CHILD_APPLICATION_ID
    and CHILD_ALERT_ID = X_CHILD_ALERT_ID
    and CHILD_PERIODIC_SET_ID = X_CHILD_PERIODIC_SET_ID
    and SEQUENCE = X_SEQUENCE
    for update of APPLICATION_ID nowait;
begin
  for recinfo in c1 loop
      if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
          AND (recinfo.PERIODIC_SET_ID = X_PERIODIC_SET_ID)
          AND (recinfo.CHILD_APPLICATION_ID = X_CHILD_APPLICATION_ID)
          AND ((recinfo.CHILD_ALERT_ID = X_CHILD_ALERT_ID)
               OR ((recinfo.CHILD_ALERT_ID is null)
               AND (X_CHILD_ALERT_ID is null)))
          AND ((recinfo.CHILD_PERIODIC_SET_ID = X_CHILD_PERIODIC_SET_ID)
               OR ((recinfo.CHILD_PERIODIC_SET_ID is null)
               AND (X_CHILD_PERIODIC_SET_ID is null)))
          AND ((recinfo.SEQUENCE = X_SEQUENCE)
               OR ((recinfo.SEQUENCE is null) AND (X_SEQUENCE is null)))
          AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
          AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
               OR ((recinfo.END_DATE_ACTIVE is null)
               AND (X_END_DATE_ACTIVE is null)))
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
  X_PERIODIC_SET_ID in NUMBER,
  X_CHILD_APPLICATION_ID in NUMBER,
  X_CHILD_ALERT_ID in NUMBER,
  X_CHILD_PERIODIC_SET_ID in NUMBER,
  X_SEQUENCE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_END_DATE_ACTIVE in DATE,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ALR_PERIODIC_SET_MEMBERS set
    ENABLED_FLAG = X_ENABLED_FLAG,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    APPLICATION_ID = X_APPLICATION_ID,
    PERIODIC_SET_ID = X_PERIODIC_SET_ID,
    CHILD_APPLICATION_ID = X_CHILD_APPLICATION_ID,
    CHILD_ALERT_ID = X_CHILD_ALERT_ID,
    CHILD_PERIODIC_SET_ID = X_CHILD_PERIODIC_SET_ID,
    SEQUENCE = X_SEQUENCE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and PERIODIC_SET_ID = X_PERIODIC_SET_ID
  and CHILD_APPLICATION_ID = X_CHILD_APPLICATION_ID
  and ((CHILD_ALERT_ID is not null
	and CHILD_ALERT_ID = X_CHILD_ALERT_ID)
	or (CHILD_ALERT_ID is null and
	X_CHILD_ALERT_ID is null))
  and ((CHILD_PERIODIC_SET_ID is not null
	and CHILD_PERIODIC_SET_ID = X_CHILD_PERIODIC_SET_ID)
	or (CHILD_PERIODIC_SET_ID is null and
	X_CHILD_PERIODIC_SET_ID is null))
  and SEQUENCE = X_SEQUENCE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_PERIODIC_SET_ID in NUMBER,
  X_CHILD_APPLICATION_ID in NUMBER,
  X_CHILD_ALERT_ID in NUMBER,
  X_CHILD_PERIODIC_SET_ID in NUMBER,
  X_SEQUENCE in NUMBER
) is
begin
  delete from ALR_PERIODIC_SET_MEMBERS
  where APPLICATION_ID = X_APPLICATION_ID
  and PERIODIC_SET_ID = X_PERIODIC_SET_ID
  and CHILD_APPLICATION_ID = X_CHILD_APPLICATION_ID
  and CHILD_ALERT_ID = X_CHILD_ALERT_ID
  and CHILD_PERIODIC_SET_ID = X_CHILD_PERIODIC_SET_ID
  and SEQUENCE = X_SEQUENCE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end ALR_PERIODIC_SET_MEMBERS_PKG;

/
