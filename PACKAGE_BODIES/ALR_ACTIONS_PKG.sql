--------------------------------------------------------
--  DDL for Package Body ALR_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_ACTIONS_PKG" as
/* $Header: ALRACTNB.pls 120.4.12010000.1 2008/07/27 06:58:09 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ACTION_ID in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_NAME in VARCHAR2,
  X_ALERT_ID in NUMBER,
  X_ACTION_TYPE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ACTION_LEVEL_TYPE in VARCHAR2,
  X_DATE_LAST_EXECUTED in DATE,
  X_FILE_NAME in VARCHAR2,
  X_ARGUMENT_STRING in VARCHAR2,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_CONCURRENT_PROGRAM_ID in NUMBER,
  X_LIST_APPLICATION_ID in NUMBER,
  X_LIST_ID in NUMBER,
  X_TO_RECIPIENTS in VARCHAR2,
  X_CC_RECIPIENTS in VARCHAR2,
  X_BCC_RECIPIENTS in VARCHAR2,
  X_PRINT_RECIPIENTS in VARCHAR2,
  X_PRINTER in VARCHAR2,
  X_SUBJECT in VARCHAR2,
  X_REPLY_TO in VARCHAR2,
  X_RESPONSE_SET_ID in NUMBER,
  X_FOLLOW_UP_AFTER_DAYS in NUMBER,
  X_COLUMN_WRAP_FLAG in VARCHAR2,
  X_MAXIMUM_SUMMARY_MESSAGE in NUMBER,
  X_BODY in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ALR_ACTIONS
    where APPLICATION_ID = X_APPLICATION_ID
    and ACTION_ID = X_ACTION_ID
    and (((END_DATE_ACTIVE is null)
      and (X_END_DATE_ACTIVE is null))
      or ((END_DATE_ACTIVE is not null)
      and (END_DATE_ACTIVE = X_END_DATE_ACTIVE)))
    ;
begin
  insert into ALR_ACTIONS (
    APPLICATION_ID,
    ACTION_ID,
    NAME,
    ALERT_ID,
    ACTION_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    END_DATE_ACTIVE,
    ENABLED_FLAG,
    DESCRIPTION,
    ACTION_LEVEL_TYPE,
    DATE_LAST_EXECUTED,
    FILE_NAME,
    ARGUMENT_STRING,
    PROGRAM_APPLICATION_ID,
    CONCURRENT_PROGRAM_ID,
    LIST_APPLICATION_ID,
    LIST_ID,
    TO_RECIPIENTS,
    CC_RECIPIENTS,
    BCC_RECIPIENTS,
    PRINT_RECIPIENTS,
    PRINTER,
    SUBJECT,
    REPLY_TO,
    RESPONSE_SET_ID,
    FOLLOW_UP_AFTER_DAYS,
    COLUMN_WRAP_FLAG,
    MAXIMUM_SUMMARY_MESSAGE_WIDTH,
    BODY,
    VERSION_NUMBER
  ) values (
    X_APPLICATION_ID,
    X_ACTION_ID,
    X_NAME,
    X_ALERT_ID,
    X_ACTION_TYPE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_END_DATE_ACTIVE,
    X_ENABLED_FLAG,
    X_DESCRIPTION,
    X_ACTION_LEVEL_TYPE,
    X_DATE_LAST_EXECUTED,
    X_FILE_NAME,
    X_ARGUMENT_STRING,
    X_PROGRAM_APPLICATION_ID,
    X_CONCURRENT_PROGRAM_ID,
    X_LIST_APPLICATION_ID,
    X_LIST_ID,
    X_TO_RECIPIENTS,
    X_CC_RECIPIENTS,
    X_BCC_RECIPIENTS,
    X_PRINT_RECIPIENTS,
    X_PRINTER,
    X_SUBJECT,
    X_REPLY_TO,
    X_RESPONSE_SET_ID,
    X_FOLLOW_UP_AFTER_DAYS,
    X_COLUMN_WRAP_FLAG,
    X_MAXIMUM_SUMMARY_MESSAGE,
    X_BODY,
    X_VERSION_NUMBER);

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
  X_ACTION_NAME in VARCHAR2,
  X_ACTION_END_DATE_ACTIVE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_ACTION_TYPE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ACTION_LEVEL_TYPE in VARCHAR2,
  X_DATE_LAST_EXECUTED in VARCHAR2,
  X_FILE_NAME in VARCHAR2,
  X_ARGUMENT_STRING in VARCHAR2,
  X_PROGRAM_APPLICATION_NAME in VARCHAR2,
  X_CONCURRENT_PROGRAM_NAME in VARCHAR2,
  X_LIST_APPLICATION_NAME in VARCHAR2,
  X_LIST_NAME in VARCHAR2,
  X_TO_RECIPIENTS in VARCHAR2,
  X_CC_RECIPIENTS in VARCHAR2,
  X_BCC_RECIPIENTS in VARCHAR2,
  X_PRINT_RECIPIENTS in VARCHAR2,
  X_PRINTER in VARCHAR2,
  X_SUBJECT in VARCHAR2,
  X_REPLY_TO in VARCHAR2,
  X_RESPONSE_SET_NAME in VARCHAR2,
  X_FOLLOW_UP_AFTER_DAYS in VARCHAR2,
  X_COLUMN_WRAP_FLAG in VARCHAR2,
  X_MAXIMUM_SUMMARY_MESSAGE in VARCHAR2,
  X_BODY in VARCHAR2,
  X_VERSION_NUMBER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is

    l_user_id number := 0;
    l_app_id  number := 0;
    l_alert_id number := 0;
    l_action_id number := 0;
    l_program_application_id  number := null;
    l_concurrent_program_id number := null;
    l_list_app_id  number := null;
    l_list_id  number := null;
    l_resp_set_id  number := null;
    l_row_id varchar2(64);

    f_luby    number;  -- entity owner in file
    f_ludate  date;    -- entity update date in file
    db_luby   number;  -- entity owner in db
    db_ludate date;    -- entity update date in db

begin
--DBMS_SESSION.SET_SQL_TRACE(TRUE);

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

  if (X_PROGRAM_APPLICATION_NAME is not null) then
    select APPLICATION_ID into l_program_application_id
    from FND_APPLICATION
    where APPLICATION_SHORT_NAME = X_PROGRAM_APPLICATION_NAME;
  end if;

  if (X_CONCURRENT_PROGRAM_NAME is not null) then
    select CONCURRENT_PROGRAM_ID into l_concurrent_program_id
    from FND_CONCURRENT_PROGRAMS
    where APPLICATION_ID = l_program_application_id
    and CONCURRENT_PROGRAM_NAME = X_CONCURRENT_PROGRAM_NAME;
  end if;

  if (X_LIST_APPLICATION_NAME is not null) then
    select APPLICATION_ID into l_list_app_id
    from FND_APPLICATION
    where APPLICATION_SHORT_NAME = X_LIST_APPLICATION_NAME;
  end if;

  if (X_LIST_NAME is not null) then
    select LIST_ID into l_list_id
    from ALR_DISTRIBUTION_LISTS
    where APPLICATION_ID = l_list_app_id
    and  NAME = X_LIST_NAME
    and (((END_DATE_ACTIVE  is null)
        and (X_ACTION_END_DATE_ACTIVE is null))
      or ((END_DATE_ACTIVE is not null)
        and (END_DATE_ACTIVE =
        to_date(X_ACTION_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'))));
  end if;

  if (X_RESPONSE_SET_NAME is not null) then
    select RESPONSE_SET_ID into l_resp_set_id
    from ALR_RESPONSE_SETS
    where APPLICATION_ID = l_app_id
    and ALERT_ID = l_alert_id
    and NAME = X_RESPONSE_SET_NAME;
  end if;

  select distinct ACTION_ID into l_action_id
  from ALR_ACTIONS
  where APPLICATION_ID = l_app_id
  and ALERT_ID = l_alert_id
  and NAME = X_ACTION_NAME
  and (((END_DATE_ACTIVE  is null)
    and (X_ACTION_END_DATE_ACTIVE is null))
    or ((END_DATE_ACTIVE is not null)
    and (END_DATE_ACTIVE =
    to_date(X_ACTION_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'))));

  select last_updated_by, last_update_date
  into  db_luby, db_ludate
  from ALR_ACTIONS
  where application_id = l_app_id
  and   action_id = l_action_id
  and (((END_DATE_ACTIVE  is null)
    and (X_ACTION_END_DATE_ACTIVE is null))
    or ((END_DATE_ACTIVE is not null)
    and (end_date_active =
  to_date(X_ACTION_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'))));

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                x_custom_mode)) then


  ALR_ACTIONS_PKG.UPDATE_ROW(
    X_APPLICATION_ID => l_app_id,
    X_ACTION_ID => l_action_id,
    X_END_DATE_ACTIVE =>
      to_date(X_ACTION_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_NAME => X_ACTION_NAME,
    X_ALERT_ID => l_alert_id,
    X_ACTION_TYPE => X_ACTION_TYPE,
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_DESCRIPTION => X_DESCRIPTION,
    X_ACTION_LEVEL_TYPE => X_ACTION_LEVEL_TYPE,
    X_DATE_LAST_EXECUTED =>
      to_date(X_DATE_LAST_EXECUTED,'YYYY/MM/DD HH24:MI:SS'),
    X_FILE_NAME => X_FILE_NAME,
    X_ARGUMENT_STRING => X_ARGUMENT_STRING,
    X_PROGRAM_APPLICATION_ID => l_program_application_id,
    X_CONCURRENT_PROGRAM_ID => l_concurrent_program_id,
    X_LIST_APPLICATION_ID => l_list_app_id,
    X_LIST_ID => l_list_id,
    X_TO_RECIPIENTS => X_TO_RECIPIENTS,
    X_CC_RECIPIENTS => X_CC_RECIPIENTS,
    X_BCC_RECIPIENTS => X_BCC_RECIPIENTS,
    X_PRINT_RECIPIENTS => X_PRINT_RECIPIENTS,
    X_PRINTER => X_PRINTER,
    X_SUBJECT => X_SUBJECT,
    X_REPLY_TO => X_REPLY_TO,
    X_RESPONSE_SET_ID => l_resp_set_id,
    X_FOLLOW_UP_AFTER_DAYS => X_FOLLOW_UP_AFTER_DAYS,
    X_COLUMN_WRAP_FLAG => X_COLUMN_WRAP_FLAG,
    X_MAXIMUM_SUMMARY_MESSAGE =>
      to_number(X_MAXIMUM_SUMMARY_MESSAGE),
    X_BODY => X_BODY,
    X_VERSION_NUMBER => X_VERSION_NUMBER,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

end if;

exception

  when NO_DATA_FOUND then

  select ALR_ACTIONS_S.nextval into l_action_id from dual;

  ALR_ACTIONS_PKG.INSERT_ROW(
    X_ROWID => l_row_id,
    X_APPLICATION_ID => l_app_id,
    X_ACTION_ID => l_action_id,
    X_END_DATE_ACTIVE =>
      to_date(X_ACTION_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_NAME => X_ACTION_NAME,
    X_ALERT_ID => l_alert_id,
    X_ACTION_TYPE => X_ACTION_TYPE,
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_DESCRIPTION => X_DESCRIPTION,
    X_ACTION_LEVEL_TYPE => X_ACTION_LEVEL_TYPE,
    X_DATE_LAST_EXECUTED =>
      to_date(X_DATE_LAST_EXECUTED,'YYYY/MM/DD HH24:MI:SS'),
    X_FILE_NAME => X_FILE_NAME,
    X_ARGUMENT_STRING => X_ARGUMENT_STRING,
    X_PROGRAM_APPLICATION_ID => l_program_application_id,
    X_CONCURRENT_PROGRAM_ID => l_concurrent_program_id,
    X_LIST_APPLICATION_ID => l_list_app_id,
    X_LIST_ID => l_list_id,
    X_TO_RECIPIENTS => X_TO_RECIPIENTS,
    X_CC_RECIPIENTS => X_CC_RECIPIENTS,
    X_BCC_RECIPIENTS => X_BCC_RECIPIENTS,
    X_PRINT_RECIPIENTS => X_PRINT_RECIPIENTS,
    X_PRINTER => X_PRINTER,
    X_SUBJECT => X_SUBJECT,
    X_REPLY_TO => X_REPLY_TO,
    X_RESPONSE_SET_ID => l_resp_set_id,
    X_FOLLOW_UP_AFTER_DAYS => X_FOLLOW_UP_AFTER_DAYS,
    X_COLUMN_WRAP_FLAG => X_COLUMN_WRAP_FLAG,
    X_MAXIMUM_SUMMARY_MESSAGE =>
      to_number(X_MAXIMUM_SUMMARY_MESSAGE),
    X_BODY => X_BODY,
    X_VERSION_NUMBER => X_VERSION_NUMBER,
    X_CREATION_DATE => f_ludate,
    X_CREATED_BY => f_luby,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );


end LOAD_ROW;

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ACTION_ID in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_NAME in VARCHAR2,
  X_ALERT_ID in NUMBER,
  X_ACTION_TYPE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ACTION_LEVEL_TYPE in VARCHAR2,
  X_DATE_LAST_EXECUTED in DATE,
  X_FILE_NAME in VARCHAR2,
  X_ARGUMENT_STRING in VARCHAR2,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_CONCURRENT_PROGRAM_ID in NUMBER,
  X_LIST_APPLICATION_ID in NUMBER,
  X_LIST_ID in NUMBER,
  X_TO_RECIPIENTS in VARCHAR2,
  X_CC_RECIPIENTS in VARCHAR2,
  X_BCC_RECIPIENTS in VARCHAR2,
  X_PRINT_RECIPIENTS in VARCHAR2,
  X_PRINTER in VARCHAR2,
  X_SUBJECT in VARCHAR2,
  X_REPLY_TO in VARCHAR2,
  X_RESPONSE_SET_ID in NUMBER,
  X_FOLLOW_UP_AFTER_DAYS in NUMBER,
  X_COLUMN_WRAP_FLAG in VARCHAR2,
  X_MAXIMUM_SUMMARY_MESSAGE in NUMBER,
  X_BODY in VARCHAR2,
  X_VERSION_NUMBER in NUMBER
) is
  cursor c1 is select
      NAME,
      ALERT_ID,
      ACTION_TYPE,
      ENABLED_FLAG,
      DESCRIPTION,
      ACTION_LEVEL_TYPE,
      DATE_LAST_EXECUTED,
      FILE_NAME,
      ARGUMENT_STRING,
      PROGRAM_APPLICATION_ID,
      CONCURRENT_PROGRAM_ID,
      LIST_APPLICATION_ID,
      LIST_ID,
      TO_RECIPIENTS,
      CC_RECIPIENTS,
      BCC_RECIPIENTS,
      PRINT_RECIPIENTS,
      PRINTER,
      SUBJECT,
      REPLY_TO,
      RESPONSE_SET_ID,
      FOLLOW_UP_AFTER_DAYS,
      COLUMN_WRAP_FLAG,
      MAXIMUM_SUMMARY_MESSAGE_WIDTH,
      BODY,
      VERSION_NUMBER,
      APPLICATION_ID,
      ACTION_ID,
      END_DATE_ACTIVE
    from ALR_ACTIONS
    where APPLICATION_ID = X_APPLICATION_ID
    and ACTION_ID = X_ACTION_ID
    and (((END_DATE_ACTIVE is null)
      and (X_END_DATE_ACTIVE is null))
      or ((END_DATE_ACTIVE is not null)
      and (END_DATE_ACTIVE = X_END_DATE_ACTIVE)))
    for update of APPLICATION_ID nowait;
begin
  for recinfo in c1 loop
      if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
          AND (recinfo.ACTION_ID = X_ACTION_ID)
          AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
               OR ((recinfo.END_DATE_ACTIVE is null)
               AND (X_END_DATE_ACTIVE is null)))
          AND (recinfo.NAME = X_NAME)
          AND (recinfo.ALERT_ID = X_ALERT_ID)
          AND (recinfo.ACTION_TYPE = X_ACTION_TYPE)
          AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
               OR ((recinfo.ENABLED_FLAG is null)
               AND (X_ENABLED_FLAG is null)))
          AND ((recinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((recinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
          AND ((recinfo.ACTION_LEVEL_TYPE = X_ACTION_LEVEL_TYPE)
               OR ((recinfo.ACTION_LEVEL_TYPE is null)
               AND (X_ACTION_LEVEL_TYPE is null)))
          AND ((recinfo.DATE_LAST_EXECUTED = X_DATE_LAST_EXECUTED)
               OR ((recinfo.DATE_LAST_EXECUTED is null)
               AND (X_DATE_LAST_EXECUTED is null)))
          AND ((recinfo.FILE_NAME = X_FILE_NAME)
               OR ((recinfo.FILE_NAME is null) AND (X_FILE_NAME is null)))
          AND ((recinfo.ARGUMENT_STRING = X_ARGUMENT_STRING)
               OR ((recinfo.ARGUMENT_STRING is null)
               AND (X_ARGUMENT_STRING is null)))
          AND ((recinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID)
               OR ((recinfo.PROGRAM_APPLICATION_ID is null)
               AND (X_PROGRAM_APPLICATION_ID is null)))
          AND ((recinfo.CONCURRENT_PROGRAM_ID = X_CONCURRENT_PROGRAM_ID)
               OR ((recinfo.CONCURRENT_PROGRAM_ID is null)
               AND (X_CONCURRENT_PROGRAM_ID is null)))
          AND ((recinfo.LIST_APPLICATION_ID = X_LIST_APPLICATION_ID)
               OR ((recinfo.LIST_APPLICATION_ID is null)
               AND (X_LIST_APPLICATION_ID is null)))
          AND ((recinfo.LIST_ID = X_LIST_ID)
               OR ((recinfo.LIST_ID is null) AND (X_LIST_ID is null)))
          AND ((recinfo.TO_RECIPIENTS = X_TO_RECIPIENTS)
               OR ((recinfo.TO_RECIPIENTS is null)
               AND (X_TO_RECIPIENTS is null)))
          AND ((recinfo.CC_RECIPIENTS = X_CC_RECIPIENTS)
               OR ((recinfo.CC_RECIPIENTS is null)
               AND (X_CC_RECIPIENTS is null)))
          AND ((recinfo.BCC_RECIPIENTS = X_BCC_RECIPIENTS)
               OR ((recinfo.BCC_RECIPIENTS is null)
               AND (X_BCC_RECIPIENTS is null)))
          AND ((recinfo.PRINT_RECIPIENTS = X_PRINT_RECIPIENTS)
               OR ((recinfo.PRINT_RECIPIENTS is null)
               AND (X_PRINT_RECIPIENTS is null)))
          AND ((recinfo.PRINTER = X_PRINTER)
               OR ((recinfo.PRINTER is null) AND (X_PRINTER is null)))
          AND ((recinfo.SUBJECT = X_SUBJECT)
               OR ((recinfo.SUBJECT is null) AND (X_SUBJECT is null)))
          AND ((recinfo.REPLY_TO = X_REPLY_TO)
               OR ((recinfo.REPLY_TO is null) AND (X_REPLY_TO is null)))
          AND ((recinfo.RESPONSE_SET_ID = X_RESPONSE_SET_ID)
               OR ((recinfo.RESPONSE_SET_ID is null)
               AND (X_RESPONSE_SET_ID is null)))
          AND ((recinfo.FOLLOW_UP_AFTER_DAYS = X_FOLLOW_UP_AFTER_DAYS)
               OR ((recinfo.FOLLOW_UP_AFTER_DAYS is null)
               AND (X_FOLLOW_UP_AFTER_DAYS is null)))
          AND ((recinfo.COLUMN_WRAP_FLAG = X_COLUMN_WRAP_FLAG)
               OR ((recinfo.COLUMN_WRAP_FLAG is null)
               AND (X_COLUMN_WRAP_FLAG is null)))
          AND ((recinfo.MAXIMUM_SUMMARY_MESSAGE_WIDTH =
               X_MAXIMUM_SUMMARY_MESSAGE)
               OR ((recinfo.MAXIMUM_SUMMARY_MESSAGE_WIDTH is null)
               AND (X_MAXIMUM_SUMMARY_MESSAGE is null)))
          AND ((recinfo.BODY = X_BODY)
               OR ((recinfo.BODY is null) AND (X_BODY is null)))
          AND (recinfo.VERSION_NUMBER = X_VERSION_NUMBER)
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
  X_ACTION_ID in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_NAME in VARCHAR2,
  X_ALERT_ID in NUMBER,
  X_ACTION_TYPE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ACTION_LEVEL_TYPE in VARCHAR2,
  X_DATE_LAST_EXECUTED in DATE,
  X_FILE_NAME in VARCHAR2,
  X_ARGUMENT_STRING in VARCHAR2,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_CONCURRENT_PROGRAM_ID in NUMBER,
  X_LIST_APPLICATION_ID in NUMBER,
  X_LIST_ID in NUMBER,
  X_TO_RECIPIENTS in VARCHAR2,
  X_CC_RECIPIENTS in VARCHAR2,
  X_BCC_RECIPIENTS in VARCHAR2,
  X_PRINT_RECIPIENTS in VARCHAR2,
  X_PRINTER in VARCHAR2,
  X_SUBJECT in VARCHAR2,
  X_REPLY_TO in VARCHAR2,
  X_RESPONSE_SET_ID in NUMBER,
  X_FOLLOW_UP_AFTER_DAYS in NUMBER,
  X_COLUMN_WRAP_FLAG in VARCHAR2,
  X_MAXIMUM_SUMMARY_MESSAGE in NUMBER,
  X_BODY in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin


  update ALR_ACTIONS set
    NAME = X_NAME,
    ALERT_ID = X_ALERT_ID,
    ACTION_TYPE = X_ACTION_TYPE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    DESCRIPTION = X_DESCRIPTION,
    ACTION_LEVEL_TYPE = X_ACTION_LEVEL_TYPE,
    DATE_LAST_EXECUTED = X_DATE_LAST_EXECUTED,
    FILE_NAME = X_FILE_NAME,
    ARGUMENT_STRING = X_ARGUMENT_STRING,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    CONCURRENT_PROGRAM_ID = X_CONCURRENT_PROGRAM_ID,
    LIST_APPLICATION_ID = X_LIST_APPLICATION_ID,
    LIST_ID = X_LIST_ID,
    TO_RECIPIENTS = X_TO_RECIPIENTS,
    CC_RECIPIENTS = X_CC_RECIPIENTS,
    BCC_RECIPIENTS = X_BCC_RECIPIENTS,
    PRINT_RECIPIENTS = X_PRINT_RECIPIENTS,
    PRINTER = X_PRINTER,
    SUBJECT = X_SUBJECT,
    REPLY_TO = X_REPLY_TO,
    RESPONSE_SET_ID = X_RESPONSE_SET_ID,
    FOLLOW_UP_AFTER_DAYS = X_FOLLOW_UP_AFTER_DAYS,
    COLUMN_WRAP_FLAG = X_COLUMN_WRAP_FLAG,
    MAXIMUM_SUMMARY_MESSAGE_WIDTH = X_MAXIMUM_SUMMARY_MESSAGE,
    BODY = X_BODY,
    VERSION_NUMBER = X_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and ACTION_ID = X_ACTION_ID
    and (((END_DATE_ACTIVE is null)
    and (X_END_DATE_ACTIVE is null))
      or ((END_DATE_ACTIVE is not null)
      and (END_DATE_ACTIVE = X_END_DATE_ACTIVE)));

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ACTION_ID in NUMBER,
  X_END_DATE_ACTIVE in DATE
) is
begin
  delete from ALR_ACTIONS
  where APPLICATION_ID = X_APPLICATION_ID
  and ACTION_ID = X_ACTION_ID
  and (((END_DATE_ACTIVE is null)
      and (X_END_DATE_ACTIVE is null))
      or ((END_DATE_ACTIVE is not null)
      and (END_DATE_ACTIVE = X_END_DATE_ACTIVE)));

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


end ALR_ACTIONS_PKG;

/
