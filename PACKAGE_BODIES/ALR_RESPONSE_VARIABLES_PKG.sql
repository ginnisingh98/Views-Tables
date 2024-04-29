--------------------------------------------------------
--  DDL for Package Body ALR_RESPONSE_VARIABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_RESPONSE_VARIABLES_PKG" as
/* $Header: ALRRVRBB.pls 120.3.12010000.1 2008/07/27 06:59:03 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_RESPONSE_SET_ID in NUMBER,
  X_VARIABLE_NUMBER in NUMBER,
  X_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_DETAIL_MAX_LEN in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ALR_RESPONSE_VARIABLES
    where APPLICATION_ID = X_APPLICATION_ID
    and ALERT_ID = X_ALERT_ID
    and RESPONSE_SET_ID = X_RESPONSE_SET_ID
    and VARIABLE_NUMBER = X_VARIABLE_NUMBER
    ;
begin
  insert into ALR_RESPONSE_VARIABLES (
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    TYPE,
    DEFAULT_VALUE,
    DATA_TYPE,
    DETAIL_MAX_LEN,
    APPLICATION_ID,
    ALERT_ID,
    RESPONSE_SET_ID,
    VARIABLE_NUMBER,
    NAME,
    DESCRIPTION
  ) values (
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_TYPE,
    X_DEFAULT_VALUE,
    X_DATA_TYPE,
    X_DETAIL_MAX_LEN,
    X_APPLICATION_ID,
    X_ALERT_ID,
    X_RESPONSE_SET_ID,
    X_VARIABLE_NUMBER,
    X_NAME,
    X_DESCRIPTION
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
  X_RESP_SET_NAME in VARCHAR2,
  X_RESP_VAR_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_DETAIL_MAX_LEN in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
    l_user_id number := 0;
    l_app_id  number := 0;
    l_alert_id number := 0;
    l_response_set_id number := 0;
    l_variable_number number := 0;
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

  select response_set_id into l_response_set_id
  from alr_response_sets
  where application_id = l_app_id
  and alert_id = l_alert_id
  and name = X_RESP_SET_NAME ;

  select variable_number into l_variable_number
  from alr_response_variables
  where application_id = l_app_id
  and alert_id = l_alert_id
  and response_set_id = l_response_set_id
  and name = X_RESP_VAR_NAME ;

  select last_updated_by, last_update_date
  into  db_luby, db_ludate
  from ALR_RESPONSE_VARIABLES
  where application_id = l_app_id
  and   alert_id = l_alert_id
  and   response_set_id = l_response_set_id
  and   variable_number = l_variable_number;

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                x_custom_mode)) then

  ALR_RESPONSE_VARIABLES_PKG.UPDATE_ROW(
    X_APPLICATION_ID => l_app_id,
    X_ALERT_ID => l_alert_id,
    X_RESPONSE_SET_ID => l_response_set_id,
    X_VARIABLE_NUMBER => l_variable_number,
    X_TYPE => X_TYPE,
    X_DEFAULT_VALUE => X_DEFAULT_VALUE,
    X_DATA_TYPE => X_DATA_TYPE,
    X_DETAIL_MAX_LEN => X_DETAIL_MAX_LEN,
    X_NAME => X_RESP_VAR_NAME,
    X_DESCRIPTION => X_DESCRIPTION,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

 end if;

exception

  when NO_DATA_FOUND then

  select ALR_RESPONSE_VARIABLES_S.nextval into l_variable_number from dual;

  ALR_RESPONSE_VARIABLES_PKG.INSERT_ROW(
    X_ROWID => l_row_id,
    X_APPLICATION_ID => l_app_id,
    X_ALERT_ID => l_alert_id,
    X_RESPONSE_SET_ID => l_response_set_id,
    X_VARIABLE_NUMBER => l_variable_number,
    X_TYPE => X_TYPE,
    X_DEFAULT_VALUE => X_DEFAULT_VALUE,
    X_DATA_TYPE => X_DATA_TYPE,
    X_DETAIL_MAX_LEN => X_DETAIL_MAX_LEN,
    X_NAME => X_RESP_VAR_NAME,
    X_DESCRIPTION => X_DESCRIPTION,
    X_CREATION_DATE => f_ludate,
    X_CREATED_BY => f_luby,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

end LOAD_ROW;

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_RESPONSE_SET_ID in NUMBER,
  X_VARIABLE_NUMBER in NUMBER,
  X_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_DETAIL_MAX_LEN in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c1 is select
      TYPE,
      DEFAULT_VALUE,
      DATA_TYPE,
      DETAIL_MAX_LEN,
      NAME,
      DESCRIPTION,
      APPLICATION_ID,
      ALERT_ID,
      RESPONSE_SET_ID,
      VARIABLE_NUMBER
    from ALR_RESPONSE_VARIABLES
    where APPLICATION_ID = X_APPLICATION_ID
    and ALERT_ID = X_ALERT_ID
    and RESPONSE_SET_ID = X_RESPONSE_SET_ID
    and VARIABLE_NUMBER = X_VARIABLE_NUMBER
    for update of APPLICATION_ID nowait;
begin
  for recinfo in c1 loop
      if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
          AND (recinfo.ALERT_ID = X_ALERT_ID)
          AND (recinfo.RESPONSE_SET_ID = X_RESPONSE_SET_ID)
          AND (recinfo.VARIABLE_NUMBER = X_VARIABLE_NUMBER)
          AND ((recinfo.TYPE = X_TYPE)
               OR ((recinfo.TYPE is null) AND (X_TYPE is null)))
          AND ((recinfo.DEFAULT_VALUE = X_DEFAULT_VALUE)
               OR ((recinfo.DEFAULT_VALUE is null)
               AND (X_DEFAULT_VALUE is null)))
          AND (recinfo.DATA_TYPE = X_DATA_TYPE)
          AND ((recinfo.DETAIL_MAX_LEN = X_DETAIL_MAX_LEN)
               OR ((recinfo.DETAIL_MAX_LEN is null)
               AND (X_DETAIL_MAX_LEN is null)))
          AND (recinfo.NAME = X_NAME)
          AND ((recinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((recinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
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
  X_RESPONSE_SET_ID in NUMBER,
  X_VARIABLE_NUMBER in NUMBER,
  X_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_DETAIL_MAX_LEN in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ALR_RESPONSE_VARIABLES set
    TYPE = X_TYPE,
    DEFAULT_VALUE = X_DEFAULT_VALUE,
    DATA_TYPE = X_DATA_TYPE,
    DETAIL_MAX_LEN = X_DETAIL_MAX_LEN,
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    APPLICATION_ID = X_APPLICATION_ID,
    ALERT_ID = X_ALERT_ID,
    RESPONSE_SET_ID = X_RESPONSE_SET_ID,
    VARIABLE_NUMBER = X_VARIABLE_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and ALERT_ID = X_ALERT_ID
  and RESPONSE_SET_ID = X_RESPONSE_SET_ID
  and VARIABLE_NUMBER = X_VARIABLE_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_RESPONSE_SET_ID in NUMBER,
  X_VARIABLE_NUMBER in NUMBER
) is
begin
  delete from ALR_RESPONSE_VARIABLES
  where APPLICATION_ID = X_APPLICATION_ID
  and ALERT_ID = X_ALERT_ID
  and RESPONSE_SET_ID = X_RESPONSE_SET_ID
  and VARIABLE_NUMBER = X_VARIABLE_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


end ALR_RESPONSE_VARIABLES_PKG;

/
