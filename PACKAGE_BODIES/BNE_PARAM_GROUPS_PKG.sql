--------------------------------------------------------
--  DDL for Package Body BNE_PARAM_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_PARAM_GROUPS_PKG" as
/* $Header: bnepargb.pls 120.2 2005/06/29 03:40:35 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_PARAM_LIST_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_APP_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_GROUP_RESOLVER in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BNE_PARAM_GROUPS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and PARAM_LIST_CODE = X_PARAM_LIST_CODE
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    ;
begin
  insert into BNE_PARAM_GROUPS_B (
    APPLICATION_ID,
    PARAM_LIST_CODE,
    SEQUENCE_NUM,
    OBJECT_VERSION_NUMBER,
    ATTRIBUTE_APP_ID,
    ATTRIBUTE_CODE,
    GROUP_RESOLVER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_PARAM_LIST_CODE,
    X_SEQUENCE_NUM,
    X_OBJECT_VERSION_NUMBER,
    X_ATTRIBUTE_APP_ID,
    X_ATTRIBUTE_CODE,
    X_GROUP_RESOLVER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into BNE_PARAM_GROUPS_TL (
    APPLICATION_ID,
    PARAM_LIST_CODE,
    SEQUENCE_NUM,
    USER_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_PARAM_LIST_CODE,
    X_SEQUENCE_NUM,
    X_USER_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BNE_PARAM_GROUPS_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.PARAM_LIST_CODE = X_PARAM_LIST_CODE
    and T.SEQUENCE_NUM = X_SEQUENCE_NUM
    and T.LANGUAGE = L.LANGUAGE_CODE);

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
  X_ATTRIBUTE_APP_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_GROUP_RESOLVER in VARCHAR2,
  X_USER_NAME in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      ATTRIBUTE_APP_ID,
      ATTRIBUTE_CODE,
      GROUP_RESOLVER
    from BNE_PARAM_GROUPS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and PARAM_LIST_CODE = X_PARAM_LIST_CODE
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BNE_PARAM_GROUPS_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and PARAM_LIST_CODE = X_PARAM_LIST_CODE
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of APPLICATION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.ATTRIBUTE_APP_ID = X_ATTRIBUTE_APP_ID)
           OR ((recinfo.ATTRIBUTE_APP_ID is null) AND (X_ATTRIBUTE_APP_ID is null)))
      AND ((recinfo.ATTRIBUTE_CODE = X_ATTRIBUTE_CODE)
           OR ((recinfo.ATTRIBUTE_CODE is null) AND (X_ATTRIBUTE_CODE is null)))
      AND ((recinfo.GROUP_RESOLVER = X_GROUP_RESOLVER)
           OR ((recinfo.GROUP_RESOLVER is null) AND (X_GROUP_RESOLVER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.USER_NAME = X_USER_NAME)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_PARAM_LIST_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_APP_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_GROUP_RESOLVER in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BNE_PARAM_GROUPS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ATTRIBUTE_APP_ID = X_ATTRIBUTE_APP_ID,
    ATTRIBUTE_CODE = X_ATTRIBUTE_CODE,
    GROUP_RESOLVER = X_GROUP_RESOLVER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and PARAM_LIST_CODE = X_PARAM_LIST_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BNE_PARAM_GROUPS_TL set
    USER_NAME = X_USER_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and PARAM_LIST_CODE = X_PARAM_LIST_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

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
  delete from BNE_PARAM_GROUPS_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and PARAM_LIST_CODE = X_PARAM_LIST_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BNE_PARAM_GROUPS_B
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
  delete from BNE_PARAM_GROUPS_TL T
  where not exists
    (select NULL
    from BNE_PARAM_GROUPS_B B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.PARAM_LIST_CODE = T.PARAM_LIST_CODE
    and B.SEQUENCE_NUM = T.SEQUENCE_NUM
    );

  update BNE_PARAM_GROUPS_TL T set (
      USER_NAME
    ) = (select
      B.USER_NAME
    from BNE_PARAM_GROUPS_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.PARAM_LIST_CODE = T.PARAM_LIST_CODE
    and B.SEQUENCE_NUM = T.SEQUENCE_NUM
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.PARAM_LIST_CODE,
      T.SEQUENCE_NUM,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.PARAM_LIST_CODE,
      SUBT.SEQUENCE_NUM,
      SUBT.LANGUAGE
    from BNE_PARAM_GROUPS_TL SUBB, BNE_PARAM_GROUPS_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.PARAM_LIST_CODE = SUBT.PARAM_LIST_CODE
    and SUBB.SEQUENCE_NUM = SUBT.SEQUENCE_NUM
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_NAME <> SUBT.USER_NAME
  ));

  insert into BNE_PARAM_GROUPS_TL (
    APPLICATION_ID,
    PARAM_LIST_CODE,
    SEQUENCE_NUM,
    USER_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.APPLICATION_ID,
    B.PARAM_LIST_CODE,
    B.SEQUENCE_NUM,
    B.USER_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BNE_PARAM_GROUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BNE_PARAM_GROUPS_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.PARAM_LIST_CODE = B.PARAM_LIST_CODE
    and T.SEQUENCE_NUM = B.SEQUENCE_NUM
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--------------------------------------------------------------------------------
--  PROCEDURE:   TRANSLATE_ROW                                                --
--                                                                            --
--  DESCRIPTION: Load a translation into the BNE_PARAM_GROUPS entity.         --
--               This proc is called from the apps loader.                    --
--                                                                            --
--  SEE:   http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt         --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  21-Apr-04  DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure TRANSLATE_ROW(
  x_param_list_asn        IN VARCHAR2,
  x_param_list_code       IN VARCHAR2,
  x_sequence_num          IN VARCHAR2,
  x_user_name             IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2
)
is
  l_app_id          number;
  f_luby            number;  -- entity owner in file
  f_ludate          date;    -- entity update date in file
  db_luby           number;  -- entity owner in db
  db_ludate         date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_param_list_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_PARAM_GROUPS_TL
    where APPLICATION_ID  = l_app_id
    and   PARAM_LIST_CODE = x_param_list_code
    and   SEQUENCE_NUM    = x_sequence_num
    and   LANGUAGE        = userenv('LANG');

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then

      update BNE_PARAM_GROUPS_TL
      set USER_NAME         = x_user_name,
          LAST_UPDATE_DATE  = f_ludate,
          LAST_UPDATED_BY   = f_luby,
          LAST_UPDATE_LOGIN = 0,
          SOURCE_LANG       = userenv('LANG')
      where APPLICATION_ID  = l_app_id
      AND   PARAM_LIST_CODE = x_param_list_code
      and   SEQUENCE_NUM    = x_sequence_num
      AND   userenv('LANG') in (LANGUAGE, SOURCE_LANG)
      ;
    end if;
  exception
    when no_data_found then
      -- Do not insert missing translations, skip this row
      null;
  end;
end TRANSLATE_ROW;



--------------------------------------------------------------------------------
--  PROCEDURE:     LOAD_ROW                                                   --
--                                                                            --
--  DESCRIPTION:   Load a row into the BNE_PARAM_GROUPS entity.               --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt       --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  21-Apr-04  DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure LOAD_ROW(
  x_param_list_asn        IN VARCHAR2,
  x_param_list_code       IN VARCHAR2,
  x_sequence_num          IN VARCHAR2,
  x_object_version_number IN VARCHAR2,
  x_attribute_asn         IN VARCHAR2,
  x_attribute_code        IN VARCHAR2,
  x_group_resolver        IN VARCHAR2,
  x_user_name             IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2
)
is
  l_app_id          number;
  l_attrib_app_id   number;
  l_row_id          varchar2(64);
  f_luby            number;  -- entity owner in file
  f_ludate          date;    -- entity update date in file
  db_luby           number;  -- entity owner in db
  db_ludate         date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_param_list_asn);
  l_attrib_app_id := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_attribute_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_PARAM_GROUPS_B
    where APPLICATION_ID  = l_app_id
    and   PARAM_LIST_CODE = x_param_list_code
    and   SEQUENCE_NUM    = x_sequence_num;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_PARAM_GROUPS_PKG.Update_Row(
        X_APPLICATION_ID        => l_app_id,
        X_PARAM_LIST_CODE       => x_param_list_code,
        X_SEQUENCE_NUM          => x_sequence_num,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_ATTRIBUTE_APP_ID      => l_attrib_app_id,
        X_ATTRIBUTE_CODE        => x_attribute_code,
        X_GROUP_RESOLVER        => x_group_resolver,
        X_USER_NAME             => x_user_name,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_PARAM_GROUPS_PKG.Insert_Row(
        X_ROWID                 => l_row_id,
        X_APPLICATION_ID        => l_app_id,
        X_PARAM_LIST_CODE       => x_param_list_code,
        X_SEQUENCE_NUM          => x_sequence_num,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_ATTRIBUTE_APP_ID      => l_attrib_app_id,
        X_ATTRIBUTE_CODE        => x_attribute_code,
        X_GROUP_RESOLVER        => x_group_resolver,
        X_USER_NAME             => x_user_name,
        X_CREATION_DATE         => f_ludate,
        X_CREATED_BY            => f_luby,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
  end;
end LOAD_ROW;

end BNE_PARAM_GROUPS_PKG;

/
