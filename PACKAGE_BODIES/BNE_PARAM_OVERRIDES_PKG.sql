--------------------------------------------------------
--  DDL for Package Body BNE_PARAM_OVERRIDES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_PARAM_OVERRIDES_PKG" as
/* $Header: bneparamovb.pls 120.2 2005/06/29 03:40:30 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_PARAM_DEFN_CODE in VARCHAR2,
  X_LVL in NUMBER,
  X_OVERRIDE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUIRED_FLAG in VARCHAR2,
  X_VISIBLE_FLAG in VARCHAR2,
  X_USER_MODIFYABLE_FLAG in VARCHAR2,
  X_DEFAULT_DATE in DATE,
  X_DEFAULT_NUMBER in NUMBER,
  X_DEFAULT_BOOLEAN_FLAG in VARCHAR2,
  X_DEFAULT_FORMULA in VARCHAR2,
  X_DESC_VALUE in VARCHAR2,
  X_DEFAULT_STRING in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BNE_PARAM_OVERRIDES
    where APPLICATION_ID = X_APPLICATION_ID
    and PARAM_DEFN_CODE = X_PARAM_DEFN_CODE
    and LVL = X_LVL
    and OVERRIDE_ID = X_OVERRIDE_ID
    ;
begin
  insert into BNE_PARAM_OVERRIDES (
    APPLICATION_ID,
    PARAM_DEFN_CODE,
    LVL,
    OVERRIDE_ID,
    OBJECT_VERSION_NUMBER,
    REQUIRED_FLAG,
    VISIBLE_FLAG,
    USER_MODIFYABLE_FLAG,
    DEFAULT_STRING,
    DEFAULT_DATE,
    DEFAULT_NUMBER,
    DEFAULT_BOOLEAN_FLAG,
    DEFAULT_FORMULA,
    DESC_VALUE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_PARAM_DEFN_CODE,
    X_LVL,
    X_OVERRIDE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_REQUIRED_FLAG,
    X_VISIBLE_FLAG,
    X_USER_MODIFYABLE_FLAG,
    X_DEFAULT_STRING,
    X_DEFAULT_DATE,
    X_DEFAULT_NUMBER,
    X_DEFAULT_BOOLEAN_FLAG,
    X_DEFAULT_FORMULA,
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
  X_PARAM_DEFN_CODE in VARCHAR2,
  X_LVL in NUMBER,
  X_OVERRIDE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUIRED_FLAG in VARCHAR2,
  X_VISIBLE_FLAG in VARCHAR2,
  X_USER_MODIFYABLE_FLAG in VARCHAR2,
  X_DEFAULT_DATE in DATE,
  X_DEFAULT_NUMBER in NUMBER,
  X_DEFAULT_BOOLEAN_FLAG in VARCHAR2,
  X_DEFAULT_FORMULA in VARCHAR2,
  X_DESC_VALUE in VARCHAR2,
  X_DEFAULT_STRING in VARCHAR2
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      REQUIRED_FLAG,
      VISIBLE_FLAG,
      USER_MODIFYABLE_FLAG,
      DEFAULT_DATE,
      DEFAULT_NUMBER,
      DEFAULT_BOOLEAN_FLAG,
      DEFAULT_FORMULA,
      DESC_VALUE,
      DEFAULT_STRING
    from BNE_PARAM_OVERRIDES
    where APPLICATION_ID = X_APPLICATION_ID
    and PARAM_DEFN_CODE = X_PARAM_DEFN_CODE
    and LVL = X_LVL
    and OVERRIDE_ID = X_OVERRIDE_ID
    for update of APPLICATION_ID nowait;
begin
  for tlinfo in c1 loop
      if (    ((tlinfo.DEFAULT_STRING = X_DEFAULT_STRING)
               OR ((tlinfo.DEFAULT_STRING is null) AND (X_DEFAULT_STRING is null)))
          AND (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
          AND ((tlinfo.REQUIRED_FLAG = X_REQUIRED_FLAG)
               OR ((tlinfo.REQUIRED_FLAG is null) AND (X_REQUIRED_FLAG is null)))
          AND ((tlinfo.VISIBLE_FLAG = X_VISIBLE_FLAG)
               OR ((tlinfo.VISIBLE_FLAG is null) AND (X_VISIBLE_FLAG is null)))
          AND ((tlinfo.USER_MODIFYABLE_FLAG = X_USER_MODIFYABLE_FLAG)
               OR ((tlinfo.USER_MODIFYABLE_FLAG is null) AND (X_USER_MODIFYABLE_FLAG is null)))
          AND ((tlinfo.DEFAULT_DATE = X_DEFAULT_DATE)
               OR ((tlinfo.DEFAULT_DATE is null) AND (X_DEFAULT_DATE is null)))
          AND ((tlinfo.DEFAULT_NUMBER = X_DEFAULT_NUMBER)
               OR ((tlinfo.DEFAULT_NUMBER is null) AND (X_DEFAULT_NUMBER is null)))
          AND ((tlinfo.DEFAULT_BOOLEAN_FLAG = X_DEFAULT_BOOLEAN_FLAG)
               OR ((tlinfo.DEFAULT_BOOLEAN_FLAG is null) AND (X_DEFAULT_BOOLEAN_FLAG is null)))
          AND ((tlinfo.DEFAULT_FORMULA = X_DEFAULT_FORMULA)
               OR ((tlinfo.DEFAULT_FORMULA is null) AND (X_DEFAULT_FORMULA is null)))
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
  X_PARAM_DEFN_CODE in VARCHAR2,
  X_LVL in NUMBER,
  X_OVERRIDE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUIRED_FLAG in VARCHAR2,
  X_VISIBLE_FLAG in VARCHAR2,
  X_USER_MODIFYABLE_FLAG in VARCHAR2,
  X_DEFAULT_DATE in DATE,
  X_DEFAULT_NUMBER in NUMBER,
  X_DEFAULT_BOOLEAN_FLAG in VARCHAR2,
  X_DEFAULT_FORMULA in VARCHAR2,
  X_DESC_VALUE in VARCHAR2,
  X_DEFAULT_STRING in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BNE_PARAM_OVERRIDES set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    REQUIRED_FLAG = X_REQUIRED_FLAG,
    VISIBLE_FLAG = X_VISIBLE_FLAG,
    USER_MODIFYABLE_FLAG = X_USER_MODIFYABLE_FLAG,
    DEFAULT_DATE = X_DEFAULT_DATE,
    DEFAULT_NUMBER = X_DEFAULT_NUMBER,
    DEFAULT_BOOLEAN_FLAG = X_DEFAULT_BOOLEAN_FLAG,
    DEFAULT_FORMULA = X_DEFAULT_FORMULA,
    DESC_VALUE = X_DESC_VALUE,
    DEFAULT_STRING = X_DEFAULT_STRING,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and PARAM_DEFN_CODE = X_PARAM_DEFN_CODE
  and LVL = X_LVL
  and OVERRIDE_ID = X_OVERRIDE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_PARAM_DEFN_CODE in VARCHAR2,
  X_LVL in NUMBER,
  X_OVERRIDE_ID in NUMBER
) is
begin
  delete from BNE_PARAM_OVERRIDES
  where APPLICATION_ID = X_APPLICATION_ID
  and PARAM_DEFN_CODE = X_PARAM_DEFN_CODE
  and LVL = X_LVL
  and OVERRIDE_ID = X_OVERRIDE_ID;

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
--  DESCRIPTION:   Load a row into the BNE_PARAM_OBERRIDES entity.            --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt       --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  1-Oct-02   DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure LOAD_ROW(
  x_param_defn_asn        in VARCHAR2,
  x_param_defn_code       in VARCHAR2,
  x_lvl                   in VARCHAR2,
  x_override_id           in VARCHAR2,
  x_object_version_number in VARCHAR2,
  x_required_flag         in VARCHAR2,
  x_visible_flag          in VARCHAR2,
  x_user_modifyable_flag  in VARCHAR2,
  x_default_string        in VARCHAR2,
  x_default_date          in VARCHAR2,
  x_default_number        in VARCHAR2,
  x_default_boolean_flag  in VARCHAR2,
  x_default_formula       in VARCHAR2,
  x_desc_value            in VARCHAR2,
  x_owner                 in VARCHAR2,
  x_last_update_date      in VARCHAR2,
  x_custom_mode           in VARCHAR2
)
is
  l_app_id          number;
  l_row_id          varchar2(64);
  l_default_number  number;
  l_default_date    date;
  f_luby            number;  -- entity owner in file
  f_ludate          date;    -- entity update date in file
  db_luby           number;  -- entity owner in db
  db_ludate         date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id       := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_param_defn_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  l_default_number := null;
  l_default_date   := null;
  if x_default_number is not null
  then
    l_default_number := to_number(x_default_number);
  end if;
  if x_default_date is not null
    then
      l_default_date := to_date(x_default_date, 'YYYY/MM/DD-HH24:MI:SS');
  end if;

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_PARAM_OVERRIDES
    where APPLICATION_ID  = l_app_id
    and   PARAM_DEFN_CODE = x_param_defn_code
    and   LVL             = x_lvl
    and   OVERRIDE_ID     = x_override_id;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_PARAM_OVERRIDES_PKG.Update_Row(
        X_APPLICATION_ID        => l_app_id,
        X_PARAM_DEFN_CODE       => x_param_defn_code,
        X_LVL                   => x_lvl,
        X_OVERRIDE_ID           => x_override_id,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_REQUIRED_FLAG         => x_required_flag,
        X_VISIBLE_FLAG          => x_visible_flag,
        X_USER_MODIFYABLE_FLAG  => x_user_modifyable_flag,
        X_DEFAULT_DATE          => l_default_date,
        X_DEFAULT_NUMBER        => l_default_number,
        X_DEFAULT_BOOLEAN_FLAG  => x_default_boolean_flag,
        X_DEFAULT_FORMULA       => x_default_formula,
        X_DESC_VALUE            => x_desc_value,
        X_DEFAULT_STRING        => x_default_string,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_PARAM_OVERRIDES_PKG.Insert_Row(
        X_ROWID                 => l_row_id,
        X_APPLICATION_ID        => l_app_id,
        X_PARAM_DEFN_CODE       => x_param_defn_code,
        X_LVL                   => x_lvl,
        X_OVERRIDE_ID           => x_override_id,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_REQUIRED_FLAG         => x_required_flag,
        X_VISIBLE_FLAG          => x_visible_flag,
        X_USER_MODIFYABLE_FLAG  => x_user_modifyable_flag,
        X_DEFAULT_DATE          => l_default_date,
        X_DEFAULT_NUMBER        => l_default_number,
        X_DEFAULT_BOOLEAN_FLAG  => x_default_boolean_flag,
        X_DEFAULT_FORMULA       => x_default_formula,
        X_DESC_VALUE            => x_desc_value,
        X_DEFAULT_STRING        => x_default_string,
        X_CREATION_DATE         => f_ludate,
        X_CREATED_BY            => f_luby,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
  end;
end LOAD_ROW;



end BNE_PARAM_OVERRIDES_PKG;

/
