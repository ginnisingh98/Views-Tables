--------------------------------------------------------
--  DDL for Package Body BNE_PARAM_LIST_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_PARAM_LIST_ITEMS_PKG" as
/* $Header: bneparamlib.pls 120.2 2005/06/29 03:40:28 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_PARAM_LIST_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARAM_DEFN_APP_ID in NUMBER,
  X_PARAM_DEFN_CODE in VARCHAR2,
  X_ATTRIBUTE_APP_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_STRING_VALUE in VARCHAR2,
  X_DATE_VALUE in DATE,
  X_NUMBER_VALUE in NUMBER,
  X_BOOLEAN_VALUE_FLAG in VARCHAR2,
  X_FORMULA_VALUE in VARCHAR2,
  X_DESC_VALUE in VARCHAR2,
  X_PARAM_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BNE_PARAM_LIST_ITEMS
    where APPLICATION_ID = X_APPLICATION_ID
    and PARAM_LIST_CODE = X_PARAM_LIST_CODE
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    ;
begin
  insert into BNE_PARAM_LIST_ITEMS (
    APPLICATION_ID,
    PARAM_LIST_CODE,
    SEQUENCE_NUM,
    OBJECT_VERSION_NUMBER,
    PARAM_DEFN_APP_ID,
    PARAM_DEFN_CODE,
    PARAM_NAME,
    ATTRIBUTE_APP_ID,
    ATTRIBUTE_CODE,
    STRING_VALUE,
    DATE_VALUE,
    NUMBER_VALUE,
    BOOLEAN_VALUE_FLAG,
    FORMULA_VALUE,
    DESC_VALUE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_PARAM_LIST_CODE,
    X_SEQUENCE_NUM,
    X_OBJECT_VERSION_NUMBER,
    X_PARAM_DEFN_APP_ID,
    X_PARAM_DEFN_CODE,
    X_PARAM_NAME,
    X_ATTRIBUTE_APP_ID,
    X_ATTRIBUTE_CODE,
    X_STRING_VALUE,
    X_DATE_VALUE,
    X_NUMBER_VALUE,
    X_BOOLEAN_VALUE_FLAG,
    X_FORMULA_VALUE,
    X_DESC_VALUE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
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
  X_APPLICATION_ID in NUMBER,
  X_PARAM_LIST_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARAM_DEFN_APP_ID in NUMBER,
  X_PARAM_DEFN_CODE in VARCHAR2,
  X_ATTRIBUTE_APP_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_STRING_VALUE in VARCHAR2,
  X_DATE_VALUE in DATE,
  X_NUMBER_VALUE in NUMBER,
  X_BOOLEAN_VALUE_FLAG in VARCHAR2,
  X_FORMULA_VALUE in VARCHAR2,
  X_DESC_VALUE in VARCHAR2,
  X_PARAM_NAME in VARCHAR2
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      PARAM_DEFN_APP_ID,
      PARAM_DEFN_CODE,
      ATTRIBUTE_APP_ID,
      ATTRIBUTE_CODE,
      STRING_VALUE,
      DATE_VALUE,
      NUMBER_VALUE,
      BOOLEAN_VALUE_FLAG,
      FORMULA_VALUE,
      DESC_VALUE,
      PARAM_NAME
    from BNE_PARAM_LIST_ITEMS
    where APPLICATION_ID = X_APPLICATION_ID
    and PARAM_LIST_CODE = X_PARAM_LIST_CODE
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    for update of APPLICATION_ID nowait;
begin
  for tlinfo in c1 loop
      if (    ((tlinfo.PARAM_NAME = X_PARAM_NAME)
               OR ((tlinfo.PARAM_NAME is null) AND (X_PARAM_NAME is null)))
          AND (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
          AND ((tlinfo.PARAM_DEFN_APP_ID = X_PARAM_DEFN_APP_ID)
               OR ((tlinfo.PARAM_DEFN_APP_ID is null) AND (X_PARAM_DEFN_APP_ID is null)))
          AND ((tlinfo.PARAM_DEFN_CODE = X_PARAM_DEFN_CODE)
               OR ((tlinfo.PARAM_DEFN_CODE is null) AND (X_PARAM_DEFN_CODE is null)))
          AND ((tlinfo.ATTRIBUTE_APP_ID = X_ATTRIBUTE_APP_ID)
               OR ((tlinfo.ATTRIBUTE_APP_ID is null) AND (X_ATTRIBUTE_APP_ID is null)))
          AND ((tlinfo.ATTRIBUTE_CODE = X_ATTRIBUTE_CODE)
               OR ((tlinfo.ATTRIBUTE_CODE is null) AND (X_ATTRIBUTE_CODE is null)))
          AND ((tlinfo.STRING_VALUE = X_STRING_VALUE)
               OR ((tlinfo.STRING_VALUE is null) AND (X_STRING_VALUE is null)))
          AND ((tlinfo.DATE_VALUE = X_DATE_VALUE)
               OR ((tlinfo.DATE_VALUE is null) AND (X_DATE_VALUE is null)))
          AND ((tlinfo.NUMBER_VALUE = X_NUMBER_VALUE)
               OR ((tlinfo.NUMBER_VALUE is null) AND (X_NUMBER_VALUE is null)))
          AND ((tlinfo.BOOLEAN_VALUE_FLAG = X_BOOLEAN_VALUE_FLAG)
               OR ((tlinfo.BOOLEAN_VALUE_FLAG is null) AND (X_BOOLEAN_VALUE_FLAG is null)))
          AND ((tlinfo.FORMULA_VALUE = X_FORMULA_VALUE)
               OR ((tlinfo.FORMULA_VALUE is null) AND (X_FORMULA_VALUE is null)))
          AND ((tlinfo.DESC_VALUE = X_DESC_VALUE)
               OR ((tlinfo.DESC_VALUE is null) AND (X_DESC_VALUE is null)))
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
  X_PARAM_LIST_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARAM_DEFN_APP_ID in NUMBER,
  X_PARAM_DEFN_CODE in VARCHAR2,
  X_ATTRIBUTE_APP_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_STRING_VALUE in VARCHAR2,
  X_DATE_VALUE in DATE,
  X_NUMBER_VALUE in NUMBER,
  X_BOOLEAN_VALUE_FLAG in VARCHAR2,
  X_FORMULA_VALUE in VARCHAR2,
  X_DESC_VALUE in VARCHAR2,
  X_PARAM_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BNE_PARAM_LIST_ITEMS set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    PARAM_DEFN_APP_ID = X_PARAM_DEFN_APP_ID,
    PARAM_DEFN_CODE = X_PARAM_DEFN_CODE,
    ATTRIBUTE_APP_ID = X_ATTRIBUTE_APP_ID,
    ATTRIBUTE_CODE = X_ATTRIBUTE_CODE,
    STRING_VALUE = X_STRING_VALUE,
    DATE_VALUE = X_DATE_VALUE,
    NUMBER_VALUE = X_NUMBER_VALUE,
    BOOLEAN_VALUE_FLAG = X_BOOLEAN_VALUE_FLAG,
    FORMULA_VALUE = X_FORMULA_VALUE,
    DESC_VALUE = X_DESC_VALUE,
    PARAM_NAME = X_PARAM_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and PARAM_LIST_CODE = X_PARAM_LIST_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM;


  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_PARAM_LIST_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER
) is
begin
  delete from BNE_PARAM_LIST_ITEMS
  where APPLICATION_ID = X_APPLICATION_ID
  and PARAM_LIST_CODE = X_PARAM_LIST_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
 null;
end ADD_LANGUAGE;

--------------------------------------------------------------------------------
--  PROCEDURE:     LOAD_ROW                                                   --
--                                                                            --
--  DESCRIPTION:   Load a row into the BNE_PARAM_LIST_ITEMS entity.           --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt       --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  1-Oct-02   DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure LOAD_ROW (
  x_param_list_asn        IN VARCHAR2,
  x_param_list_code       IN VARCHAR2,
  x_sequence_num          IN VARCHAR2,
  x_object_version_number IN VARCHAR2,
  x_param_defn_asn        IN VARCHAR2,
  x_param_defn_code       IN VARCHAR2,
  x_param_name            IN VARCHAR2,
  x_attribute_asn         IN VARCHAR2,
  x_attribute_code        IN VARCHAR2,
  x_string_value          IN VARCHAR2,
  x_date_value            IN VARCHAR2,
  x_number_value          IN VARCHAR2,
  x_boolean_value_flag    IN VARCHAR2,
  x_formula_value         IN VARCHAR2,
  x_desc_value            IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2
)
is
  l_app_id            number;
  l_param_defn_app_id number;
  l_attr_app_id       number;
  l_row_id            varchar2(64);
  l_number_value      number;
  l_date_value        date;
  f_luby              number;  -- entity owner in file
  f_ludate            date;    -- entity update date in file
  db_luby             number;  -- entity owner in db
  db_ludate           date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id            := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_param_list_asn);
  l_param_defn_app_id := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_param_defn_asn);
  l_attr_app_id       := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_attribute_asn);

  l_number_value := null;
  l_date_value   := null;
  if x_number_value is not null
  then
    l_number_value := to_number(x_number_value);
  end if;
  if x_date_value is not null
    then
      l_date_value := to_date(x_date_value, 'YYYY/MM/DD-HH24:MI:SS');
  end if;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_PARAM_LIST_ITEMS
    where APPLICATION_ID  = l_app_id
    and   PARAM_LIST_CODE = x_param_list_code
    and   SEQUENCE_NUM    = x_sequence_num;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_PARAM_LIST_ITEMS_PKG.Update_Row(
        X_APPLICATION_ID        => l_app_id,
        X_PARAM_LIST_CODE       => x_param_list_code,
        X_SEQUENCE_NUM          => x_sequence_num,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_PARAM_DEFN_APP_ID     => l_param_defn_app_id,
        X_PARAM_DEFN_CODE       => x_param_defn_code,
        X_ATTRIBUTE_APP_ID      => l_attr_app_id,
        X_ATTRIBUTE_CODE        => x_attribute_code,
        X_STRING_VALUE          => x_string_value,
        X_DATE_VALUE            => l_date_value,
        X_NUMBER_VALUE          => l_number_value,
        X_BOOLEAN_VALUE_FLAG    => x_boolean_value_flag,
        X_FORMULA_VALUE         => x_formula_value,
        X_DESC_VALUE            => x_desc_value,
        X_PARAM_NAME            => x_param_name,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_PARAM_LIST_ITEMS_PKG.Insert_Row(
        X_ROWID                 => l_row_id,
        X_APPLICATION_ID        => l_app_id,
        X_PARAM_LIST_CODE       => x_param_list_code,
        X_SEQUENCE_NUM          => x_sequence_num,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_PARAM_DEFN_APP_ID     => l_param_defn_app_id,
        X_PARAM_DEFN_CODE       => x_param_defn_code,
        X_ATTRIBUTE_APP_ID      => l_attr_app_id,
        X_ATTRIBUTE_CODE        => x_attribute_code,
        X_STRING_VALUE          => x_string_value,
        X_DATE_VALUE            => l_date_value,
        X_NUMBER_VALUE          => l_number_value,
        X_BOOLEAN_VALUE_FLAG    => x_boolean_value_flag,
        X_FORMULA_VALUE         => x_formula_value,
        X_DESC_VALUE            => x_desc_value,
        X_PARAM_NAME            => x_param_name,
        X_CREATION_DATE         => f_ludate,
        X_CREATED_BY            => f_luby,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
  end;
end LOAD_ROW;


end BNE_PARAM_LIST_ITEMS_PKG;

/
