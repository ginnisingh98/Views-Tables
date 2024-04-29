--------------------------------------------------------
--  DDL for Package Body ALR_DISTRIBUTION_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_DISTRIBUTION_LISTS_PKG" as
/* $Header: ALRDLSTB.pls 120.4.12010000.1 2008/07/27 06:58:38 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_LIST_ID in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TO_RECIPIENTS in VARCHAR2,
  X_CC_RECIPIENTS in VARCHAR2,
  X_BCC_RECIPIENTS in VARCHAR2,
  X_PRINT_RECIPIENTS in VARCHAR2,
  X_PRINTER in VARCHAR2,
  X_REPLY_TO in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ALR_DISTRIBUTION_LISTS
    where APPLICATION_ID = X_APPLICATION_ID
    and LIST_ID = X_LIST_ID
    and ((end_date_active  is null)
    or ((end_date_active is not null)
    and (end_date_active =
      to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'))))
    ;
begin
  insert into ALR_DISTRIBUTION_LISTS (
    APPLICATION_ID,
    LIST_ID,
    NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    TO_RECIPIENTS,
    CC_RECIPIENTS,
    BCC_RECIPIENTS,
    PRINT_RECIPIENTS,
    PRINTER,
    REPLY_TO,
    END_DATE_ACTIVE,
    ENABLED_FLAG
  ) values (
    X_APPLICATION_ID,
    X_LIST_ID,
    X_NAME,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    X_TO_RECIPIENTS,
    X_CC_RECIPIENTS,
    X_BCC_RECIPIENTS,
    X_PRINT_RECIPIENTS,
    X_PRINTER,
    X_REPLY_TO,
    X_END_DATE_ACTIVE,
    X_ENABLED_FLAG );

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
  X_END_DATE_ACTIVE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TO_RECIPIENTS in VARCHAR2,
  X_CC_RECIPIENTS in VARCHAR2,
  X_BCC_RECIPIENTS in VARCHAR2,
  X_PRINT_RECIPIENTS in VARCHAR2,
  X_PRINTER in VARCHAR2,
  X_REPLY_TO in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
    l_user_id number := 0;
    l_app_id  number := 0;
    l_list_id number := 0;
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

  /* end_date_active can be null */
  select list_id into l_list_id from alr_distribution_lists
  where application_id = l_app_id
  and name = x_name
  and ((end_date_active  is null)
    or ((end_date_active is not null)
    and (end_date_active =
      to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'))));

  select last_updated_by, last_update_date
  into  db_luby, db_ludate
  from ALR_DISTRIBUTION_LISTS
  where application_id = l_app_id
  and   ((end_date_active  is null)
    or ((end_date_active is not null)
    and (end_date_active =
      to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'))))
  and   list_id = l_list_id;

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                x_custom_mode)) then


  ALR_DISTRIBUTION_LISTS_PKG.UPDATE_ROW(
    X_APPLICATION_ID => l_app_id,
    X_LIST_ID => l_list_id,
    X_END_DATE_ACTIVE => to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_NAME => X_NAME,
    X_DESCRIPTION => X_DESCRIPTION,
    X_TO_RECIPIENTS => X_TO_RECIPIENTS,
    X_CC_RECIPIENTS => X_CC_RECIPIENTS,
    X_BCC_RECIPIENTS => X_BCC_RECIPIENTS,
    X_PRINT_RECIPIENTS => X_PRINT_RECIPIENTS,
    X_PRINTER => X_PRINTER,
    X_REPLY_TO => X_REPLY_TO,
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

 end if;
exception
  when NO_DATA_FOUND then

  select alr_distribution_lists_s.nextval into l_list_id from dual;

  ALR_DISTRIBUTION_LISTS_PKG.INSERT_ROW(
    X_ROWID => l_row_id,
    X_APPLICATION_ID => l_app_id,
    X_LIST_ID => l_list_id,
    X_END_DATE_ACTIVE => to_date(X_END_DATE_ACTIVE,'YYYY/MM/DD HH24:MI:SS'),
    X_NAME => X_NAME,
    X_DESCRIPTION => X_DESCRIPTION,
    X_TO_RECIPIENTS => X_TO_RECIPIENTS,
    X_CC_RECIPIENTS => X_CC_RECIPIENTS,
    X_BCC_RECIPIENTS => X_BCC_RECIPIENTS,
    X_PRINT_RECIPIENTS => X_PRINT_RECIPIENTS,
    X_PRINTER => X_PRINTER,
    X_REPLY_TO => X_REPLY_TO,
    X_ENABLED_FLAG => X_ENABLED_FLAG,
    X_CREATION_DATE => f_ludate,
    X_CREATED_BY => f_luby,
    X_LAST_UPDATE_DATE => f_ludate,
    X_LAST_UPDATED_BY => f_luby,
    X_LAST_UPDATE_LOGIN => 0 );

end LOAD_ROW;

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_LIST_ID in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TO_RECIPIENTS in VARCHAR2,
  X_CC_RECIPIENTS in VARCHAR2,
  X_BCC_RECIPIENTS in VARCHAR2,
  X_PRINT_RECIPIENTS in VARCHAR2,
  X_PRINTER in VARCHAR2,
  X_REPLY_TO in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2
) is
  cursor c1 is select
      NAME,
      DESCRIPTION,
      TO_RECIPIENTS,
      CC_RECIPIENTS,
      BCC_RECIPIENTS,
      PRINT_RECIPIENTS,
      PRINTER,
      REPLY_TO,
      ENABLED_FLAG,
      APPLICATION_ID,
      LIST_ID,
      END_DATE_ACTIVE
    from ALR_DISTRIBUTION_LISTS
    where APPLICATION_ID = X_APPLICATION_ID
    and LIST_ID = X_LIST_ID
    and END_DATE_ACTIVE = X_END_DATE_ACTIVE
    for update of APPLICATION_ID nowait;
begin
  for recinfo in c1 loop
      if (    (recinfo.APPLICATION_ID = X_APPLICATION_ID)
          AND (recinfo.LIST_ID = X_LIST_ID)
          AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
               OR ((recinfo.END_DATE_ACTIVE is null)
               AND (X_END_DATE_ACTIVE is null)))
          AND (recinfo.NAME = X_NAME)
          AND ((recinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((recinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND ((recinfo.TO_RECIPIENTS = X_TO_RECIPIENTS)
               OR ((recinfo.TO_RECIPIENTS is null) AND (X_TO_RECIPIENTS is null)))
          AND ((recinfo.CC_RECIPIENTS = X_CC_RECIPIENTS)
               OR ((recinfo.CC_RECIPIENTS is null) AND (X_CC_RECIPIENTS is null)))
          AND ((recinfo.BCC_RECIPIENTS = X_BCC_RECIPIENTS)
               OR ((recinfo.BCC_RECIPIENTS is null) AND (X_BCC_RECIPIENTS is null)))
          AND ((recinfo.PRINT_RECIPIENTS = X_PRINT_RECIPIENTS)
               OR ((recinfo.PRINT_RECIPIENTS is null) AND (X_PRINT_RECIPIENTS is null)))
          AND ((recinfo.PRINTER = X_PRINTER)
               OR ((recinfo.PRINTER is null) AND (X_PRINTER is null)))
          AND ((recinfo.REPLY_TO = X_REPLY_TO)
               OR ((recinfo.REPLY_TO is null) AND (X_REPLY_TO is null)))
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
  X_APPLICATION_ID in NUMBER,
  X_LIST_ID in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TO_RECIPIENTS in VARCHAR2,
  X_CC_RECIPIENTS in VARCHAR2,
  X_BCC_RECIPIENTS in VARCHAR2,
  X_PRINT_RECIPIENTS in VARCHAR2,
  X_PRINTER in VARCHAR2,
  X_REPLY_TO in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  if (X_END_DATE_ACTIVE is null) then
  update ALR_DISTRIBUTION_LISTS set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    TO_RECIPIENTS = X_TO_RECIPIENTS,
    CC_RECIPIENTS = X_CC_RECIPIENTS,
    BCC_RECIPIENTS = X_BCC_RECIPIENTS,
    PRINT_RECIPIENTS = X_PRINT_RECIPIENTS,
    PRINTER = X_PRINTER,
    REPLY_TO = X_REPLY_TO,
    ENABLED_FLAG = X_ENABLED_FLAG,
    APPLICATION_ID = X_APPLICATION_ID,
    LIST_ID = X_LIST_ID,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and LIST_ID = X_LIST_ID
  and END_DATE_ACTIVE is null;
  else
  update ALR_DISTRIBUTION_LISTS set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    TO_RECIPIENTS = X_TO_RECIPIENTS,
    CC_RECIPIENTS = X_CC_RECIPIENTS,
    BCC_RECIPIENTS = X_BCC_RECIPIENTS,
    PRINT_RECIPIENTS = X_PRINT_RECIPIENTS,
    PRINTER = X_PRINTER,
    REPLY_TO = X_REPLY_TO,
    ENABLED_FLAG = X_ENABLED_FLAG,
    APPLICATION_ID = X_APPLICATION_ID,
    LIST_ID = X_LIST_ID,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and LIST_ID = X_LIST_ID
  and END_DATE_ACTIVE = X_END_DATE_ACTIVE;
  end if;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_LIST_ID in NUMBER,
  X_END_DATE_ACTIVE in DATE
) is
begin
  delete from ALR_DISTRIBUTION_LISTS
  where APPLICATION_ID = X_APPLICATION_ID
  and LIST_ID = X_LIST_ID
  and END_DATE_ACTIVE = X_END_DATE_ACTIVE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


end ALR_DISTRIBUTION_LISTS_PKG;

/
