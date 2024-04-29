--------------------------------------------------------
--  DDL for Package Body ALR_VALID_RESPONSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_VALID_RESPONSES_PKG" as
/* $Header: ALRVRSPB.pls 120.3.12010000.1 2008/07/27 06:59:05 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_RESPONSE_SET_ID in NUMBER,
  X_RESPONSE_ID in NUMBER,
  X_TYPE in VARCHAR2,
  X_RESPONSE_TEXT in LONG,
  X_RESPONSE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ALR_VALID_RESPONSES
    where APPLICATION_ID = X_APPLICATION_ID
    and ALERT_ID = X_ALERT_ID
    and RESPONSE_SET_ID = X_RESPONSE_SET_ID
    and RESPONSE_ID = X_RESPONSE_ID
    ;
begin
  insert into ALR_VALID_RESPONSES (
    APPLICATION_ID,
    RESPONSE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    ALERT_ID,
    RESPONSE_SET_ID,
    TYPE,
    RESPONSE_TEXT,
    LAST_UPDATE_LOGIN,
    RESPONSE_NAME
  ) values (
    X_APPLICATION_ID,
    X_RESPONSE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_ALERT_ID,
    X_RESPONSE_SET_ID,
    X_TYPE,
    X_RESPONSE_TEXT,
    X_LAST_UPDATE_LOGIN,
    X_RESPONSE_NAME);

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
  X_RESPONSE_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_RESPONSE_TEXT in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
    l_user_id number := 0;
    l_app_id  number := 0;
    l_alert_id number := 0;
    l_response_set_id number := 0;
    l_response_id number := 0;
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

  /* longs like response_text cannot be used in the where clause */
  /* response_name can be a null column */
  select response_id  into l_response_id from alr_valid_responses
  where application_id = l_app_id
  and alert_id = l_alert_id
  and response_set_id = l_response_set_id
  and type = X_TYPE
  and ((response_name  is null)
    or ((response_name is not null)
    and (response_name = X_RESPONSE_NAME)));

  select last_updated_by, last_update_date
  into  db_luby, db_ludate
  from ALR_VALID_RESPONSES
  where application_id = l_app_id
  and   alert_id = l_alert_id
  and   response_set_id = l_response_set_id
  and   response_id = l_response_id;

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                x_custom_mode)) then

  ALR_VALID_RESPONSES_PKG.UPDATE_ROW(
    X_APPLICATION_ID => l_app_id,
    X_ALERT_ID => l_alert_id,
    X_RESPONSE_SET_ID => l_response_set_id,
    X_RESPONSE_ID => l_response_id,
    X_TYPE => X_TYPE,
    X_RESPONSE_TEXT => X_RESPONSE_TEXT,
    X_RESPONSE_NAME => X_RESPONSE_NAME,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

  end if;

exception

  when NO_DATA_FOUND then

  select ALR_VALID_RESPONSES_S.nextval into l_response_id from DUAL;

  ALR_VALID_RESPONSES_PKG.INSERT_ROW(
    X_ROWID => l_row_id,
    X_APPLICATION_ID => l_app_id,
    X_ALERT_ID => l_alert_id,
    X_RESPONSE_SET_ID => l_response_set_id,
    X_RESPONSE_ID => l_response_id,
    X_TYPE => X_TYPE,
    X_RESPONSE_TEXT => X_RESPONSE_TEXT,
    X_RESPONSE_NAME => X_RESPONSE_NAME,
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
  X_RESPONSE_ID in NUMBER,
  X_TYPE in VARCHAR2,
  X_RESPONSE_TEXT in LONG,
  X_RESPONSE_NAME in VARCHAR2
) is
  cursor c1 is select
      TYPE,
      RESPONSE_TEXT,
      RESPONSE_NAME,
      APPLICATION_ID,
      ALERT_ID,
      RESPONSE_SET_ID,
      RESPONSE_ID
    from ALR_VALID_RESPONSES
    where APPLICATION_ID = X_APPLICATION_ID
    and ALERT_ID = X_ALERT_ID
    and RESPONSE_SET_ID = X_RESPONSE_SET_ID
    and RESPONSE_ID = X_RESPONSE_ID
    for update of APPLICATION_ID nowait;
begin
  for recinfo in c1 loop
      if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
          AND (recinfo.ALERT_ID = X_ALERT_ID)
          AND (recinfo.RESPONSE_SET_ID = X_RESPONSE_SET_ID)
          AND (recinfo.RESPONSE_ID = X_RESPONSE_ID)
          AND (recinfo.TYPE = X_TYPE)
          AND ((recinfo.RESPONSE_TEXT = X_RESPONSE_TEXT)
               OR ((recinfo.RESPONSE_TEXT is null) AND (X_RESPONSE_TEXT is null)))
          AND ((recinfo.RESPONSE_NAME = X_RESPONSE_NAME)
               OR ((recinfo.RESPONSE_NAME is null) AND (X_RESPONSE_NAME is null)))
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
  X_RESPONSE_ID in NUMBER,
  X_TYPE in VARCHAR2,
  X_RESPONSE_TEXT in LONG,
  X_RESPONSE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ALR_VALID_RESPONSES set
    TYPE = X_TYPE,
    RESPONSE_TEXT = X_RESPONSE_TEXT,
    RESPONSE_NAME = X_RESPONSE_NAME,
    APPLICATION_ID = X_APPLICATION_ID,
    ALERT_ID = X_ALERT_ID,
    RESPONSE_SET_ID = X_RESPONSE_SET_ID,
    RESPONSE_ID = X_RESPONSE_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and ALERT_ID = X_ALERT_ID
  and RESPONSE_SET_ID = X_RESPONSE_SET_ID
  and RESPONSE_ID = X_RESPONSE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ALERT_ID in NUMBER,
  X_RESPONSE_SET_ID in NUMBER,
  X_RESPONSE_ID in NUMBER
) is
begin
  delete from ALR_VALID_RESPONSES
  where APPLICATION_ID = X_APPLICATION_ID
  and ALERT_ID = X_ALERT_ID
  and RESPONSE_SET_ID = X_RESPONSE_SET_ID
  and RESPONSE_ID = X_RESPONSE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end ALR_VALID_RESPONSES_PKG;

/
