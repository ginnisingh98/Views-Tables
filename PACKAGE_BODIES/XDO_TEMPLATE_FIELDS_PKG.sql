--------------------------------------------------------
--  DDL for Package Body XDO_TEMPLATE_FIELDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDO_TEMPLATE_FIELDS_PKG" as
/* $Header: XDOTMFDB.pls 120.1 2005/07/02 05:05:32 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_TEMPLATE_CODE in VARCHAR2,
  X_FIELD_NAME in VARCHAR2,
  X_ALIAS_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is
    select ROWID
    from   XDO_TEMPLATE_FIELDS
    where  APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
    and    TEMPLATE_CODE = X_TEMPLATE_CODE
    and    FIELD_NAME = X_FIELD_NAME;
begin
  insert into xdo_template_fields (
    APPLICATION_SHORT_NAME,
    TEMPLATE_CODE,
    FIELD_NAME,
    ALIAS_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_SHORT_NAME,
    X_TEMPLATE_CODE,
    X_FIELD_NAME,
    X_ALIAS_NAME,
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

procedure LOCK_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_TEMPLATE_CODE in VARCHAR2,
  X_FIELD_NAME in VARCHAR2,
  X_ALIAS_NAME in VARCHAR2
) is
  cursor c is select
                    APPLICATION_SHORT_NAME,
                    TEMPLATE_CODE,
                    FIELD_NAME,
                    ALIAS_NAME
               from XDO_TEMPLATE_FIELDS
              where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
              and   TEMPLATE_CODE = X_TEMPLATE_CODE
              and   FIELD_NAME = X_FIELD_NAME
      for update of APPLICATION_SHORT_NAME, TEMPLATE_CODE, FIELD_NAME nowait;
  recinfo c%rowtype;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if  (recinfo.ALIAS_NAME = X_ALIAS_NAME) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;

end LOCK_ROW;

procedure UPDATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_TEMPLATE_CODE in VARCHAR2,
  X_FIELD_NAME in VARCHAR2,
  X_ALIAS_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XDO_TEMPLATE_FIELDS set
    ALIAS_NAME = X_ALIAS_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
  and TEMPLATE_CODE = X_TEMPLATE_CODE
  and   FIELD_NAME = X_FIELD_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_TEMPLATE_CODE in VARCHAR2,
  X_FIELD_NAME in VARCHAR2
) is
begin

  delete from XDO_TEMPLATE_FIELDS
   where  TEMPLATE_CODE=X_TEMPLATE_CODE
     and  APPLICATION_SHORT_NAME=X_APPLICATION_SHORT_NAME
     and  FIELD_NAME = X_FIELD_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

/* There is no translation for this entity */
-- procedure ADD_LANGUAGE;

-- procedure TRANSLATE_ROW;


procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_TEMPLATE_CODE          in VARCHAR2,
  X_FIELD_NAME             in VARCHAR2,
  X_ALIAS_NAME             in VARCHAR2,
  X_OWNER                  in VARCHAR2,
  X_LAST_UPDATE_DATE       in VARCHAR2,
  X_CUSTOM_MODE            in VARCHAR2
) is
  row_id varchar2(64);
  f_luby number;
  f_ludate date;
  db_luby   number; -- entity owner in db
  db_ludate date;   -- entity update in db
begin

    -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin

    select  LAST_UPDATED_BY, LAST_UPDATE_DATE
    into  db_luby, db_ludate
    from xdo_template_fields
    where application_short_name = x_application_short_name
    and   template_code = x_template_code
    and   field_name = x_field_name;

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date
    if (fnd_load_util.UPLOAD_TEST(
                p_file_id     => f_luby,
                p_file_lud     => f_ludate,
                p_db_id        => db_luby,
                p_db_lud       => db_ludate,
                p_custom_mode  => x_custom_mode))
    then
      XDO_TEMPLATE_FIELDS_PKG.UPDATE_ROW (
        X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
        X_TEMPLATE_CODE          => X_TEMPLATE_CODE,
        X_FIELD_NAME             => x_field_name,
        X_ALIAS_NAME             => x_alias_name,
        X_LAST_UPDATE_DATE       => f_ludate,
        X_LAST_UPDATED_BY        => f_luby,
        X_LAST_UPDATE_LOGIN      => 0
      );
    end if;
  exception when no_data_found then
      XDO_TEMPLATE_FIELDS_PKG.INSERT_ROW (
        X_ROWID             => row_id,
        X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
        X_TEMPLATE_CODE          => X_TEMPLATE_CODE,
        X_FIELD_NAME        => x_field_name,
        X_ALIAS_NAME        => x_alias_name,
        X_CREATION_DATE     => f_ludate,
        X_CREATED_BY        => f_luby,
        X_LAST_UPDATE_DATE  => f_ludate,
        X_LAST_UPDATED_BY   => f_luby,
        X_LAST_UPDATE_LOGIN => 0
    );
  end;
end LOAD_ROW;

end XDO_TEMPLATE_FIELDS_PKG;

/
