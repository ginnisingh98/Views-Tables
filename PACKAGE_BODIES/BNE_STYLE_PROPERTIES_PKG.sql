--------------------------------------------------------
--  DDL for Package Body BNE_STYLE_PROPERTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_STYLE_PROPERTIES_PKG" as
/* $Header: bnestylepb.pls 120.3 2005/08/18 07:28:40 dagroves noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_STYLE_CODE in VARCHAR2,
  X_STYLE_PROPERTY_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VALUE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DATA_TYPE in VARCHAR2
) is
  cursor C is select ROWID from BNE_STYLE_PROPERTIES
    where APPLICATION_ID = X_APPLICATION_ID
    and STYLE_CODE = X_STYLE_CODE
    and STYLE_PROPERTY_NAME = X_STYLE_PROPERTY_NAME
    ;
begin
  insert into BNE_STYLE_PROPERTIES (
    APPLICATION_ID,
    STYLE_CODE,
    STYLE_PROPERTY_NAME,
    OBJECT_VERSION_NUMBER,
    VALUE,
    DATA_TYPE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE
  ) values (
    X_APPLICATION_ID,
    X_STYLE_CODE,
    X_STYLE_PROPERTY_NAME,
    X_OBJECT_VERSION_NUMBER,
    X_VALUE,
    X_DATA_TYPE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE
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
  X_APPLICATION_ID in NUMBER,
  X_STYLE_CODE in VARCHAR2,
  X_STYLE_PROPERTY_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VALUE in VARCHAR2,
  X_DATA_TYPE in VARCHAR2
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      VALUE,
      DATA_TYPE
    from BNE_STYLE_PROPERTIES
    where APPLICATION_ID = X_APPLICATION_ID
    and STYLE_CODE = X_STYLE_CODE
    and STYLE_PROPERTY_NAME = X_STYLE_PROPERTY_NAME
    for update of APPLICATION_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.VALUE = X_VALUE)
          AND (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
          AND ((tlinfo.DATA_TYPE = X_DATA_TYPE)
              OR ((tlinfo.DATA_TYPE is null) AND (X_DATA_TYPE is null)))
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
  X_STYLE_CODE in VARCHAR2,
  X_STYLE_PROPERTY_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_VALUE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DATA_TYPE in VARCHAR2
) is
begin
  update BNE_STYLE_PROPERTIES set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    VALUE = X_VALUE,
    DATA_TYPE = X_DATA_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and STYLE_CODE = X_STYLE_CODE
  and STYLE_PROPERTY_NAME = X_STYLE_PROPERTY_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_STYLE_CODE in VARCHAR2,
  X_STYLE_PROPERTY_NAME in VARCHAR2
) is
begin
  delete from BNE_STYLE_PROPERTIES
  where APPLICATION_ID = X_APPLICATION_ID
  and STYLE_CODE = X_STYLE_CODE
  and STYLE_PROPERTY_NAME = X_STYLE_PROPERTY_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  null;
end ADD_LANGUAGE;

procedure LOAD_ROW(
  x_style_asn             IN VARCHAR2,
  x_style_code            IN VARCHAR2,
  x_object_version_number IN VARCHAR2,
  x_style_property_name   IN VARCHAR2,
  x_value                 IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2,
  x_data_type             IN VARCHAR2
)
is
  l_app_id          number;
  l_row_id          varchar2(64);
  f_luby            number;  -- entity owner in file
  f_ludate          date;    -- entity update date in file
  db_luby           number;  -- entity owner in db
  db_ludate         date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id       := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_style_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_STYLE_PROPERTIES
    where APPLICATION_ID = l_app_id
    and   STYLE_CODE     = x_style_code
    and   STYLE_PROPERTY_NAME = x_style_property_name;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_STYLE_PROPERTIES_PKG.Update_Row(
        X_APPLICATION_ID        => l_app_id,
        X_STYLE_CODE            => x_style_code,
        X_STYLE_PROPERTY_NAME   => x_style_property_name,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_VALUE                 => x_value,
        X_DATA_TYPE             => x_data_type,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_STYLE_PROPERTIES_PKG.Insert_Row(
        X_ROWID                 => l_row_id,
        X_APPLICATION_ID        => l_app_id,
        X_STYLE_CODE            => x_style_code,
        X_STYLE_PROPERTY_NAME   => x_style_property_name,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_VALUE                 => x_value,
        X_DATA_TYPE             => x_data_type,
        X_CREATION_DATE         => f_ludate,
        X_CREATED_BY            => f_luby,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
  end;

end LOAD_ROW;


end BNE_STYLE_PROPERTIES_PKG;

/
