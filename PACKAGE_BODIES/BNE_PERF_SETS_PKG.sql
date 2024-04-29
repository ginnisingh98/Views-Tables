--------------------------------------------------------
--  DDL for Package Body BNE_PERF_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_PERF_SETS_PKG" as
/* $Header: bneperfsetb.pls 120.2 2005/06/29 03:40:42 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SET_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BNE_PERF_SETS_B
    where SET_CODE = X_SET_CODE
    ;
begin
  insert into BNE_PERF_SETS_B (
    SET_CODE,
    OBJECT_VERSION_NUMBER,
    ENABLED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SET_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_ENABLED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into BNE_PERF_SETS_TL (
    SET_CODE,
    USER_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_SET_CODE,
    X_USER_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BNE_PERF_SETS_TL T
    where T.SET_CODE = X_SET_CODE
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
  X_SET_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_USER_NAME in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      ENABLED_FLAG
    from BNE_PERF_SETS_B
    where SET_CODE = X_SET_CODE
    for update of SET_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BNE_PERF_SETS_TL
    where SET_CODE = X_SET_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SET_CODE nowait;
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
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
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
  X_SET_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BNE_PERF_SETS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ENABLED_FLAG = X_ENABLED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SET_CODE = X_SET_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BNE_PERF_SETS_TL set
    USER_NAME = X_USER_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SET_CODE = X_SET_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SET_CODE in VARCHAR2
) is
begin
  delete from BNE_PERF_SETS_TL
  where SET_CODE = X_SET_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BNE_PERF_SETS_B
  where SET_CODE = X_SET_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BNE_PERF_SETS_TL T
  where not exists
    (select NULL
    from BNE_PERF_SETS_B B
    where B.SET_CODE = T.SET_CODE
    );

  update BNE_PERF_SETS_TL T set (
      USER_NAME
    ) = (select
      B.USER_NAME
    from BNE_PERF_SETS_TL B
    where B.SET_CODE = T.SET_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SET_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.SET_CODE,
      SUBT.LANGUAGE
    from BNE_PERF_SETS_TL SUBB, BNE_PERF_SETS_TL SUBT
    where SUBB.SET_CODE = SUBT.SET_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_NAME <> SUBT.USER_NAME
  ));

  insert into BNE_PERF_SETS_TL (
    SET_CODE,
    USER_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.SET_CODE,
    B.USER_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BNE_PERF_SETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BNE_PERF_SETS_TL T
    where T.SET_CODE = B.SET_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--------------------------------------------------------------------------------
--  PROCEDURE:   TRANSLATE_ROW                                                --
--                                                                            --
--  DESCRIPTION: Load a translation into the BNE_PERF_SETS entity.           --
--               This proc is called from the apps loader.                    --
--                                                                            --
--  SEE:   http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt         --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  28-May-04  DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure TRANSLATE_ROW(
  x_set_code              in VARCHAR2,
  x_user_name             in VARCHAR2,
  x_owner                 in VARCHAR2,
  x_last_update_date      in VARCHAR2,
  x_custom_mode           in VARCHAR2
)
is
  f_luby            number;  -- entity owner in file
  f_ludate          date;    -- entity update date in file
  db_luby           number;  -- entity owner in db
  db_ludate         date;    -- entity update date in db
begin
  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_PERF_SETS_TL
    where SET_CODE  = x_set_code
    and   LANGUAGE  = userenv('LANG');

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then

      update BNE_PERF_SETS_TL
      set USER_NAME         = x_user_name,
          LAST_UPDATE_DATE  = f_ludate,
          LAST_UPDATED_BY   = f_luby,
          LAST_UPDATE_LOGIN = 0,
          SOURCE_LANG       = userenv('LANG')
      where SET_CODE  = x_set_code
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
--  DESCRIPTION:   Load a row into the BNE_PERF_SETS entity.                  --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt       --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  28-May-04  DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure LOAD_ROW(
  x_set_code                    in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_enabled_flag                in VARCHAR2,
  x_user_name                   in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
)
is
  l_row_id            varchar2(64);
  f_luby              number;  -- entity owner in file
  f_ludate            date;    -- entity update date in file
  db_luby             number;  -- entity owner in db
  db_ludate           date;    -- entity update date in db
begin
  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_PERF_SETS_B
    where SET_CODE  = x_set_code;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_PERF_SETS_PKG.Update_Row(
        X_SET_CODE                 => x_set_code,
        X_OBJECT_VERSION_NUMBER    => x_object_version_number,
        X_ENABLED_FLAG             => x_enabled_flag,
        X_USER_NAME                => x_user_name,
        X_LAST_UPDATE_DATE         => f_ludate,
        X_LAST_UPDATED_BY          => f_luby,
        X_LAST_UPDATE_LOGIN        => 0
      );

    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_PERF_SETS_PKG.Insert_Row(
        X_ROWID                    => l_row_id,
        X_SET_CODE                 => x_set_code,
        X_OBJECT_VERSION_NUMBER    => x_object_version_number,
        X_ENABLED_FLAG             => x_enabled_flag,
        X_USER_NAME                => x_user_name,
        X_CREATION_DATE            => f_ludate,
        X_CREATED_BY               => f_luby,
        X_LAST_UPDATE_DATE         => f_ludate,
        X_LAST_UPDATED_BY          => f_luby,
        X_LAST_UPDATE_LOGIN        => 0
      );
  end;
end LOAD_ROW;


end BNE_PERF_SETS_PKG;

/
