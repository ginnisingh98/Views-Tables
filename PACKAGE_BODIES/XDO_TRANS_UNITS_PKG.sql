--------------------------------------------------------
--  DDL for Package Body XDO_TRANS_UNITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDO_TRANS_UNITS_PKG" as
/* $Header: XDOTRUTB.pls 120.1 2005/07/02 05:05:42 appldev noship $ */

procedure INSERT_ROW (
          X_APPLICATION_SHORT_NAME in VARCHAR2,
          X_TEMPLATE_CODE in VARCHAR2,
          X_UNIT_ID in VARCHAR2,
          X_LANGUAGE in VARCHAR2,
          X_TERRITORY in VARCHAR2,
          X_VALUE in VARCHAR2,
          X_NOTE in VARCHAR2,
          X_CREATION_DATE in DATE,
          X_CREATED_BY in NUMBER,
          X_LAST_UPDATE_DATE in DATE,
          X_LAST_UPDATED_BY in NUMBER,
          X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into XDO_TRANS_UNITS (
           APPLICATION_SHORT_NAME,
           TEMPLATE_CODE,
           UNIT_ID,
           NOTE,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN
  ) values (
          X_APPLICATION_SHORT_NAME,
          X_TEMPLATE_CODE,
          X_UNIT_ID,
          X_NOTE,
          X_CREATION_DATE,
          X_CREATED_BY,
          X_LAST_UPDATE_DATE,
          X_LAST_UPDATED_BY,
          X_LAST_UPDATE_LOGIN
  );

  insert into XDO_TRANS_UNIT_VALUES (
           APPLICATION_SHORT_NAME,
           TEMPLATE_CODE,
           UNIT_ID,
           LANGUAGE,
           TERRITORY,
           VALUE,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN
  ) values (
     X_APPLICATION_SHORT_NAME,
     X_TEMPLATE_CODE,
     X_UNIT_ID,
     X_LANGUAGE,
     X_TERRITORY,
     X_VALUE,
     X_CREATION_DATE,
     X_CREATED_BY,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_LOGIN
  );

end INSERT_ROW;

procedure UPDATE_ROW (
          X_APPLICATION_SHORT_NAME in VARCHAR2,
          X_TEMPLATE_CODE in VARCHAR2,
          X_UNIT_ID in VARCHAR2,
          X_LANGUAGE in VARCHAR2,
          X_TERRITORY in VARCHAR2,
          X_VALUE in VARCHAR2,
          X_NOTE in VARCHAR2,
          X_LAST_UPDATE_DATE in DATE,
          X_LAST_UPDATED_BY in NUMBER,
          X_LAST_UPDATE_LOGIN in NUMBER)
is
begin
  update XDO_TRANS_UNITS
     set APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME,
        TEMPLATE_CODE = X_TEMPLATE_CODE,
        UNIT_ID = X_UNIT_ID,
        NOTE = nvl(X_NOTE, NOTE),
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
  and TEMPLATE_CODE = X_TEMPLATE_CODE
  and UNIT_ID = X_UNIT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update XDO_TRANS_UNIT_VALUES
     set VALUE = X_VALUE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
  and TEMPLATE_CODE = X_TEMPLATE_CODE
  and LANGUAGE = X_LANGUAGE
  and TERRITORY = X_TERRITORY
  and UNIT_ID = X_UNIT_ID;

  if (sql%notfound) then
    translate_row(x_application_short_name, x_template_code, x_unit_id, x_language, x_territory, x_value, 'FORCE', x_last_update_date, x_last_updated_by, x_last_update_login);
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_TEMPLATE_CODE in VARCHAR2,
  X_UNIT_ID in VARCHAR2
) is
begin
  delete from XDO_TRANS_UNIT_VALUES
  where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
  and TEMPLATE_CODE = X_TEMPLATE_CODE
  and UNIT_ID = X_UNIT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from XDO_TRANS_UNITS
  where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
  and TEMPLATE_CODE = X_TEMPLATE_CODE
  and UNIT_ID = UNIT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;



procedure TRANSLATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_TEMPLATE_CODE in VARCHAR2,
  X_UNIT_ID in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in VARCHAR2,
  X_LAST_UPDATE_LOGIN in VARCHAR2
) is

  l_lang VARCHAR2(2);
  l_terr VARCHAR2(2);

begin

    select lower(iso_language), iso_territory
     into l_lang, l_terr
     from fnd_languages
    where language_code = userenv('LANG');

    translate_row(x_application_short_name, x_template_code, x_unit_id, l_lang, l_terr, x_value, x_custom_mode, x_last_update_date, x_last_updated_by, x_last_update_login);

end translate_row;



procedure TRANSLATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_TEMPLATE_CODE in VARCHAR2,
  X_UNIT_ID in VARCHAR2,
  X_LANGUAGE in VARCHAR2,
  X_TERRITORY in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in VARCHAR2,
  X_LAST_UPDATE_LOGIN in VARCHAR2
) is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  xtu_ludate date;   -- lud in xdo_trans_units (to check the row exists)

begin

   -- Translate char last_update_date to date
   -- f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

   begin
     select LAST_UPDATED_BY, LAST_UPDATE_DATE
     into db_luby, db_ludate
     from XDO_TRANS_UNIT_VALUES
     where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
     and   TEMPLATE_CODE = X_TEMPLATE_CODE
     and   UNIT_ID = X_UNIT_ID
     and   language = X_LANGUAGE
     and   territory = X_TERRITORY;

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date
    if (fnd_load_util.UPLOAD_TEST(
                p_file_id     =>  x_last_updated_by,
                p_file_lud     => x_last_update_date,
                p_db_id        => db_luby,
                p_db_lud       => db_ludate,
                p_custom_mode  => x_custom_mode))
    then
       update XDO_TRANS_UNIT_VALUES
          set VALUE                 = X_VALUE,
              LAST_UPDATE_DATE      = X_LAST_UPDATE_DATE,
              LAST_UPDATED_BY       = X_LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN     = 0
        where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
          and   TEMPLATE_CODE = X_TEMPLATE_CODE
          and   UNIT_ID = X_UNIT_ID
          and   LANGUAGE = X_LANGUAGE
          and   TERRITORY = X_TERRITORY;
    end if;

  exception
    when no_data_found then

      -- Check first if this is a valid trans-unit that exists
      -- in XDO_TRANS_UNITS.
      -- We should not create any new trans-units from this
      -- procedure.
      begin
        select LAST_UPDATE_DATE
          into xtu_ludate
          from XDO_TRANS_UNITS
          where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
          and   TEMPLATE_CODE = X_TEMPLATE_CODE
          and   UNIT_ID = X_UNIT_ID;
      exception
        when no_data_found then
          return;
      end;

      insert into XDO_TRANS_UNIT_VALUES (
        APPLICATION_SHORT_NAME,
        TEMPLATE_CODE,
        UNIT_ID,
        LANGUAGE,
        TERRITORY,
        VALUE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        CREATION_DATE,
        CREATED_BY)
       values (
        X_APPLICATION_SHORT_NAME,
        X_TEMPLATE_CODE,
        X_UNIT_ID,
        X_LANGUAGE,
        X_TERRITORY,
        X_VALUE,
        X_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN,
        SYSDATE,
        X_LAST_UPDATED_BY);
   end;
end TRANSLATE_ROW;

procedure LOAD_ROW (
          X_APPLICATION_SHORT_NAME in VARCHAR2,
          X_TEMPLATE_CODE in VARCHAR2,
          X_UNIT_ID in VARCHAR2,
          X_VALUE in VARCHAR2,
          X_NOTE in VARCHAR2,
          X_CUSTOM_MODE in VARCHAR2,
          X_LAST_UPDATE_DATE in DATE,
          X_OWNER in VARCHAR2)
is

  f_luby NUMBER;
  f_ludate DATE;

  l_lang VARCHAR2(2);
  l_terr VARCHAR2(2);

  retval NUMBER;

begin

   select lower(iso_language), iso_territory
     into l_lang, l_terr
     from fnd_languages
    where language_code = userenv('LANG');

   -- Translate owner to last_updated_by
   f_luby := fnd_load_util.owner_id(x_owner);

   f_ludate := nvl(x_last_update_date, sysdate);

   retval := load_row(x_application_short_name,
            x_template_code,
            x_unit_id,
            l_lang,
            l_terr,
            x_value,
            x_note,
            x_custom_mode,
            f_ludate,
            f_luby,
            0);

end LOAD_ROW;

function LOAD_ROW (
          X_APPLICATION_SHORT_NAME in VARCHAR2,
          X_TEMPLATE_CODE in VARCHAR2,
          X_UNIT_ID in VARCHAR2,
          X_LANGUAGE in VARCHAR2,
          X_TERRITORY in VARCHAR2,
          X_VALUE in VARCHAR2,
          X_NOTE in VARCHAR2,
          X_CUSTOM_MODE in VARCHAR2,
          X_LAST_UPDATE_DATE in DATE,
          X_LAST_UPDATED_BY in VARCHAR2,
          X_LAST_UPDATE_LOGIN in VARCHAR2) return number
is

  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin

  begin

    select LAST_UPDATED_BY, LAST_UPDATE_DATE
     into db_luby, db_ludate
     from XDO_TRANS_UNITS
     where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
     and   TEMPLATE_CODE = X_TEMPLATE_CODE
     and   UNIT_ID = X_UNIT_ID;

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date
    if (fnd_load_util.UPLOAD_TEST(
                p_file_id     =>  x_last_updated_by,
                p_file_lud     => x_last_update_date,
                p_db_id        => db_luby,
                p_db_lud       => db_ludate,
                p_custom_mode  => x_custom_mode))
    then

      XDO_TRANS_UNITS_PKG.UPDATE_ROW(
          X_APPLICATION_SHORT_NAME,
          X_TEMPLATE_CODE,
          X_UNIT_ID,
          X_LANGUAGE,
          X_TERRITORY,
          X_VALUE,
          X_NOTE,
          X_LAST_UPDATE_DATE,
          X_LAST_UPDATED_BY,
          X_LAST_UPDATE_LOGIN
      );

      return 1; -- row updated

    end if;

    return 0; -- row not updated due to custom mode

   exception when no_data_found then

      XDO_TRANS_UNITS_PKG.INSERT_ROW(
          X_APPLICATION_SHORT_NAME,
          X_TEMPLATE_CODE,
          X_UNIT_ID,
          X_LANGUAGE,
          X_TERRITORY,
          X_VALUE,
          X_NOTE,
          X_LAST_UPDATE_DATE,
          X_LAST_UPDATED_BY,
          X_LAST_UPDATE_DATE,
          X_LAST_UPDATED_BY,
          X_LAST_UPDATE_LOGIN
      );
     return 2;  -- row inserted
   end;

end LOAD_ROW;

procedure LOAD_TRANS_UNIT_PROP (
          X_APPLICATION_SHORT_NAME in VARCHAR2,
          X_TEMPLATE_CODE in VARCHAR2,
          X_UNIT_ID in VARCHAR2,
          X_PROP_TYPE in VARCHAR2,
          X_PROP_VALUE in VARCHAR2,
          X_CUSTOM_MODE in VARCHAR2,
          X_LAST_UPDATE_DATE in DATE,
          X_LAST_UPDATED_BY in VARCHAR2,
          X_LAST_UPDATE_LOGIN in VARCHAR2)
is

  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin

  begin

    select LAST_UPDATED_BY, LAST_UPDATE_DATE
     into db_luby, db_ludate
     from XDO_TRANS_UNIT_PROPS
     where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
     and   TEMPLATE_CODE = X_TEMPLATE_CODE
     and   UNIT_ID = X_UNIT_ID
     and   PROP_TYPE = X_PROP_TYPE;

    if (fnd_load_util.UPLOAD_TEST(
           p_file_id     =>  x_last_updated_by,
           p_file_lud     => x_last_update_date,
           p_db_id        => db_luby,
           p_db_lud       => db_ludate,
           p_custom_mode  => x_custom_mode))
    then

      update xdo_trans_unit_props
         set prop_value = X_PROP_VALUE,
             last_update_date = X_LAST_UPDATE_DATE,
             last_updated_by = X_LAST_UPDATED_BY,
             last_update_login = X_LAST_UPDATE_LOGIN
       where application_short_name = X_APPLICATION_SHORT_NAME
         and template_code = X_TEMPLATE_CODE
         and unit_id = X_UNIT_ID
         and prop_type = X_PROP_TYPE;

    end if;

  exception when no_data_found then

    insert into xdo_trans_unit_props
     (
      application_short_name,
      template_code,
      unit_id,
      prop_type,
      prop_value,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login )
    values
     (
      X_APPLICATION_SHORT_NAME,
      X_TEMPLATE_CODE,
      X_UNIT_ID,
      X_PROP_TYPE,
      X_PROP_VALUE,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN);

  end;

end LOAD_TRANS_UNIT_PROP;

end XDO_TRANS_UNITS_PKG;

/
