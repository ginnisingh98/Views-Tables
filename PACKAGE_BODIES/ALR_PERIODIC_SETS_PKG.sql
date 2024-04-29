--------------------------------------------------------
--  DDL for Package Body ALR_PERIODIC_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_PERIODIC_SETS_PKG" as
/* $Header: ALRPSTSB.pls 120.4.12010000.1 2008/07/27 06:58:55 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_PERIODIC_SET_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ALR_PERIODIC_SETS
    where APPLICATION_ID = X_APPLICATION_ID
    and PERIODIC_SET_ID = X_PERIODIC_SET_ID
    ;
begin
  insert into ALR_PERIODIC_SETS (
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    APPLICATION_ID,
    PERIODIC_SET_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY
  ) values (
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    X_NAME,
    X_DESCRIPTION,
    X_APPLICATION_ID,
    X_PERIODIC_SET_ID,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
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
  X_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is

  l_user_id number := 0;
  l_row_id varchar2(64);
  l_app_id number := 0;
  l_per_id number := 0;

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

/*  TSHORT 5251609 - Deleting children as
    primary key has sequence and can't be used
    to upload */

  delete ALR_PERIODIC_SET_MEMBERS
  where application_id = l_app_id
  and periodic_set_id = l_per_id;

  select last_updated_by, last_update_date
  into  db_luby, db_ludate
  from ALR_PERIODIC_SETS
  where application_id = l_app_id
  and   periodic_set_id = l_per_id;

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                x_custom_mode)) then


  ALR_PERIODIC_SETS_PKG.UPDATE_ROW(
    X_APPLICATION_ID => l_app_id,
    X_PERIODIC_SET_ID => l_per_id,
    X_NAME => X_NAME,
    X_DESCRIPTION => X_DESCRIPTION,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

 end if;
exception

  when NO_DATA_FOUND then

  select alr_periodic_sets_s.nextval into l_per_id from dual;

  ALR_PERIODIC_SETS_PKG.INSERT_ROW(
    X_ROWID => l_row_id,
    X_APPLICATION_ID => l_app_id,
    X_PERIODIC_SET_ID => l_per_id,
    X_NAME => X_NAME,
    X_DESCRIPTION => X_DESCRIPTION,
    X_CREATION_DATE => f_ludate,
    X_CREATED_BY => f_luby,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );


end LOAD_ROW;

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_PERIODIC_SET_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c1 is select
      NAME,
      DESCRIPTION,
      APPLICATION_ID,
      PERIODIC_SET_ID
    from ALR_PERIODIC_SETS
    where APPLICATION_ID = X_APPLICATION_ID
    and PERIODIC_SET_ID = X_PERIODIC_SET_ID
    for update of APPLICATION_ID nowait;
begin
  for recinfo in c1 loop
      if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
          AND (recinfo.PERIODIC_SET_ID = X_PERIODIC_SET_ID)
          AND (recinfo.NAME = X_NAME)
          AND ((recinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((recinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ALR_PERIODIC_SETS set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    APPLICATION_ID = X_APPLICATION_ID,
    PERIODIC_SET_ID = X_PERIODIC_SET_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and PERIODIC_SET_ID = X_PERIODIC_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_PERIODIC_SET_ID in NUMBER
) is
begin
  delete from ALR_PERIODIC_SETS
  where APPLICATION_ID = X_APPLICATION_ID
  and PERIODIC_SET_ID = X_PERIODIC_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


end ALR_PERIODIC_SETS_PKG;

/
