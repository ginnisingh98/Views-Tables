--------------------------------------------------------
--  DDL for Package Body XDO_CONFIG_PROPERTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDO_CONFIG_PROPERTIES_PKG" as
/* $Header: XDOCFGPB.pls 120.3 2006/05/23 19:50:38 jyeung noship $ */

procedure INSERT_ROW (
          P_PROPERTY_CODE in VARCHAR2,
          P_PROPERTY_NAME in VARCHAR2,
          P_CATEGORY      in VARCHAR2,
          P_XDO_CFG_NAME  in VARCHAR2,
          P_LOOKUP_TYPE   in VARCHAR2,
          P_SORT_ORDER    in NUMBER,
          P_CREATION_DATE in DATE,
          P_CREATED_BY in NUMBER,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into XDO_CONFIG_PROPERTIES_B (
          PROPERTY_CODE,
          CATEGORY,
          XDO_CFG_NAME,
          LOOKUP_TYPE,
          SORT_ORDER,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN
  ) values (
          P_PROPERTY_CODE,
          P_CATEGORY,
          P_XDO_CFG_NAME,
          P_LOOKUP_TYPE,
          P_SORT_ORDER,
          P_CREATION_DATE,
          P_CREATED_BY,
          P_LAST_UPDATE_DATE,
          P_LAST_UPDATED_BY,
          P_LAST_UPDATE_LOGIN
  );

  insert into XDO_CONFIG_PROPERTIES_TL (
    PROPERTY_CODE,
    PROPERTY_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select P_PROPERTY_CODE,
           P_PROPERTY_NAME,
           P_CREATION_DATE,
           P_CREATED_BY,
           P_LAST_UPDATE_DATE,
           P_LAST_UPDATED_BY,
           P_LAST_UPDATE_LOGIN,
           L.LANGUAGE_CODE,
           userenv('LANG')
     from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
      and not exists
          (select NULL
             from XDO_CONFIG_PROPERTIES_TL T
            where T.PROPERTY_CODE = P_PROPERTY_CODE
              and T.LANGUAGE = L.LANGUAGE_CODE);

end INSERT_ROW;

procedure UPDATE_ROW (
          P_PROPERTY_CODE in VARCHAR2,
          P_PROPERTY_NAME in VARCHAR2,
          P_CATEGORY      in VARCHAR2,
          P_XDO_CFG_NAME  in VARCHAR2,
          P_LOOKUP_TYPE   in VARCHAR2,
          P_SORT_ORDER    in NUMBER,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XDO_CONFIG_PROPERTIES_B
     set CATEGORY = P_CATEGORY,
         XDO_CFG_NAME = P_XDO_CFG_NAME,
         LOOKUP_TYPE = P_LOOKUP_TYPE,
         SORT_ORDER = P_SORT_ORDER,
         LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
         LAST_UPDATED_BY = P_LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where PROPERTY_CODE = P_PROPERTY_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update XDO_CONFIG_PROPERTIES_TL set
    PROPERTY_NAME = P_PROPERTY_NAME,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PROPERTY_CODE = P_PROPERTY_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


procedure ADD_LANGUAGE is
begin
  insert into XDO_CONFIG_PROPERTIES_TL (
    PROPERTY_CODE,
    PROPERTY_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.PROPERTY_CODE,
    B.PROPERTY_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XDO_CONFIG_PROPERTIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XDO_CONFIG_PROPERTIES_TL T
    where T.PROPERTY_CODE = B.PROPERTY_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure TRANSLATE_ROW (
          P_PROPERTY_CODE in VARCHAR2,
          P_PROPERTY_NAME in VARCHAR2,
          P_LAST_UPDATE_DATE in VARCHAR2,
          P_CUSTOM_MODE   in VARCHAR2,
          P_OWNER         in VARCHAR2
) is

  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin

   -- Translate owner to file_last_updated_by
   f_luby := fnd_load_util.OWNER_ID(p_owner);

   -- Translate char last_update_date to date
   f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

   begin
     select LAST_UPDATED_BY, LAST_UPDATE_DATE
     into db_luby, db_ludate
     from XDO_CONFIG_PROPERTIES_TL
     where PROPERTY_CODE = P_PROPERTY_CODE
     and LANGUAGE = userenv('LANG');

     -- Update record, honoring customization mode.
     -- Record should be updated only if:
     -- a. CUSTOM_MODE = FORCE, or
     -- b. file owner is USER, db owner is SEED
     -- c. owners are the same, and file_date > db_date
     if (fnd_load_util.UPLOAD_TEST(
                p_file_id     => f_luby,
                p_file_lud    => f_ludate,
                p_db_id       => db_luby,
                p_db_lud      => db_ludate,
                p_custom_mode => p_custom_mode))
     then
       update XDO_CONFIG_PROPERTIES_TL
          set PROPERTY_NAME = nvl(p_property_name, property_name),
         SOURCE_LANG         = userenv('LANG'),
         LAST_UPDATE_DATE    = f_ludate,
         LAST_UPDATED_BY     = f_luby,
         LAST_UPDATE_LOGIN   = 0
       where PROPERTY_CODE = P_PROPERTY_CODE
       and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
     end if;
   exception
    when no_data_found then
      null;
   end;
end TRANSLATE_ROW;


procedure LOAD_ROW (
          P_PROPERTY_CODE    in VARCHAR2,
          P_PROPERTY_NAME    in VARCHAR2,
          P_CATEGORY         in VARCHAR2,
          P_XDO_CFG_NAME     in VARCHAR2,
          P_LOOKUP_TYPE      in VARCHAR2,
          P_SORT_ORDER       in NUMBER,
          P_LAST_UPDATE_DATE in VARCHAR2,
          P_CUSTOM_MODE      in VARCHAR2,
          P_OWNER            in VARCHAR2
) is

  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(p_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
      into db_luby, db_ludate
      from xdo_config_properties_b
     where property_code = p_property_code;

     if (fnd_load_util.UPLOAD_TEST(p_file_id      => f_luby,
                                   p_file_lud     => f_ludate,
                                   p_db_id        => db_luby,
                                   p_db_lud       => db_ludate,
                                   p_custom_mode  => p_custom_mode))
     then
       UPDATE_ROW (
          P_PROPERTY_CODE => P_PROPERTY_CODE,
          P_PROPERTY_NAME => P_PROPERTY_NAME,
          P_CATEGORY      => P_CATEGORY,
          P_XDO_CFG_NAME  => P_XDO_CFG_NAME,
          P_LOOKUP_TYPE   => P_LOOKUP_TYPE,
          P_SORT_ORDER    => P_SORT_ORDER,
          P_LAST_UPDATE_DATE  => f_ludate,
          P_LAST_UPDATED_BY   => f_luby,
          P_LAST_UPDATE_LOGIN => 0
       );
     end if;

  exception when no_data_found then

      INSERT_ROW (
          P_PROPERTY_CODE => P_PROPERTY_CODE,
          P_PROPERTY_NAME => P_PROPERTY_NAME,
          P_CATEGORY      => P_CATEGORY,
          P_XDO_CFG_NAME  => P_XDO_CFG_NAME,
          P_LOOKUP_TYPE   => P_LOOKUP_TYPE,
          P_SORT_ORDER    => P_SORT_ORDER,
          P_CREATION_DATE => f_ludate,
          P_CREATED_BY    => f_luby,
          P_LAST_UPDATE_DATE  => f_ludate,
          P_LAST_UPDATED_BY   => f_luby,
          P_LAST_UPDATE_LOGIN => 0
      );

  end;

end LOAD_ROW;

end XDO_CONFIG_PROPERTIES_PKG;

/
