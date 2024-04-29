--------------------------------------------------------
--  DDL for Package Body ALR_MESSAGE_SYSTEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_MESSAGE_SYSTEMS_PKG" as
/* $Header: ALRMSYSB.pls 120.3.12010000.1 2008/07/27 06:58:46 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_NAME in VARCHAR2,
  X_CODE in VARCHAR2,
  X_COMMAND in VARCHAR2,
  X_ARGUMENTS in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ALR_MESSAGE_SYSTEMS
    where NAME = X_NAME
    ;
begin
  insert into ALR_MESSAGE_SYSTEMS (
    NAME,
    CODE,
    COMMAND,
    ARGUMENTS,
    ENABLED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_NAME,
    X_CODE,
    X_COMMAND,
    X_ARGUMENTS,
    X_ENABLED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
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
  X_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CODE in VARCHAR2,
  X_COMMAND in VARCHAR2,
  X_ARGUMENTS in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
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
  from ALR_MESSAGE_SYSTEMS
  where name = X_NAME;

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                x_custom_mode)) then

  ALR_MESSAGE_SYSTEMS_PKG.UPDATE_ROW(
    X_NAME => X_NAME,
    X_CODE => X_CODE,
    X_COMMAND => X_COMMAND,
    X_ARGUMENTS => X_ARGUMENTS,
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

 end if;

exception
  when NO_DATA_FOUND then
  ALR_MESSAGE_SYSTEMS_PKG.INSERT_ROW(
    X_ROWID => l_row_id,
    X_NAME => X_NAME,
    X_CODE => X_CODE,
    X_COMMAND => X_COMMAND,
    X_ARGUMENTS => X_ARGUMENTS,
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_CREATION_DATE => f_ludate,
    X_CREATED_BY => f_luby,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );


end LOAD_ROW;

procedure LOCK_ROW (
  X_NAME in VARCHAR2,
  X_CODE in VARCHAR2,
  X_COMMAND in VARCHAR2,
  X_ARGUMENTS in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2
) is
  cursor c1 is select
      CODE,
      COMMAND,
      ARGUMENTS,
      ENABLED_FLAG,
      NAME
    from ALR_MESSAGE_SYSTEMS
    where NAME = X_NAME
    for update of NAME nowait;
begin
  for recinfo in c1 loop
      if (    (recinfo.NAME = X_NAME)
          AND (recinfo.CODE = X_CODE)
          AND ((recinfo.COMMAND = X_COMMAND)
               OR ((recinfo.COMMAND is null) AND (X_COMMAND is null)))
          AND ((recinfo.ARGUMENTS = X_ARGUMENTS)
               OR ((recinfo.ARGUMENTS is null) AND (X_ARGUMENTS is null)))
          AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
               OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
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
  X_NAME in VARCHAR2,
  X_CODE in VARCHAR2,
  X_COMMAND in VARCHAR2,
  X_ARGUMENTS in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ALR_MESSAGE_SYSTEMS set
    NAME = X_NAME,
    CODE = X_CODE,
    COMMAND = X_COMMAND,
    ARGUMENTS = X_ARGUMENTS,
    ENABLED_FLAG = X_ENABLED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_NAME in VARCHAR2
) is
begin
  delete from ALR_MESSAGE_SYSTEMS
  where NAME = X_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


end ALR_MESSAGE_SYSTEMS_PKG;

/
