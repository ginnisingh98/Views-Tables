--------------------------------------------------------
--  DDL for Package Body BNE_CONTENT_COLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_CONTENT_COLS_PKG" as
/* $Header: bnecntcb.pls 120.3 2005/07/27 03:17:21 dagroves noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_COL_NAME in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2
) is
  cursor C is select ROWID from BNE_CONTENT_COLS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and CONTENT_CODE = X_CONTENT_CODE
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    ;
begin
  insert into BNE_CONTENT_COLS_B (
    OBJECT_VERSION_NUMBER,
    COL_NAME,
    APPLICATION_ID,
    CONTENT_CODE,
    SEQUENCE_NUM,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    READ_ONLY_FLAG
  ) values (
    X_OBJECT_VERSION_NUMBER,
    X_COL_NAME,
    X_APPLICATION_ID,
    X_CONTENT_CODE,
    X_SEQUENCE_NUM,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_READ_ONLY_FLAG
  );

  insert into BNE_CONTENT_COLS_TL (
    APPLICATION_ID,
    CONTENT_CODE,
    SEQUENCE_NUM,
    USER_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_CONTENT_CODE,
    X_SEQUENCE_NUM,
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
    from BNE_CONTENT_COLS_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.CONTENT_CODE = X_CONTENT_CODE
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
  X_CONTENT_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_COL_NAME in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      COL_NAME,
      READ_ONLY_FLAG
    from BNE_CONTENT_COLS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and CONTENT_CODE = X_CONTENT_CODE
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BNE_CONTENT_COLS_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and CONTENT_CODE = X_CONTENT_CODE
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
      AND (recinfo.COL_NAME = X_COL_NAME)
      AND ((recinfo.READ_ONLY_FLAG = X_READ_ONLY_FLAG)
           OR ((recinfo.READ_ONLY_FLAG is null) AND (X_READ_ONLY_FLAG is null)))
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
  X_CONTENT_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_COL_NAME in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2
) is
begin
  update BNE_CONTENT_COLS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    COL_NAME = X_COL_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    READ_ONLY_FLAG = X_READ_ONLY_FLAG
  where APPLICATION_ID = X_APPLICATION_ID
  and CONTENT_CODE = X_CONTENT_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BNE_CONTENT_COLS_TL set
    USER_NAME = X_USER_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and CONTENT_CODE = X_CONTENT_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER
) is
begin
  delete from BNE_CONTENT_COLS_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and CONTENT_CODE = X_CONTENT_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BNE_CONTENT_COLS_B
  where APPLICATION_ID = X_APPLICATION_ID
  and CONTENT_CODE = X_CONTENT_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BNE_CONTENT_COLS_TL T
  where not exists
    (select NULL
    from BNE_CONTENT_COLS_B B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.CONTENT_CODE = T.CONTENT_CODE
    and B.SEQUENCE_NUM = T.SEQUENCE_NUM
    );

  update BNE_CONTENT_COLS_TL T set (
      USER_NAME
    ) = (select
      B.USER_NAME
    from BNE_CONTENT_COLS_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.CONTENT_CODE = T.CONTENT_CODE
    and B.SEQUENCE_NUM = T.SEQUENCE_NUM
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.CONTENT_CODE,
      T.SEQUENCE_NUM,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.CONTENT_CODE,
      SUBT.SEQUENCE_NUM,
      SUBT.LANGUAGE
    from BNE_CONTENT_COLS_TL SUBB, BNE_CONTENT_COLS_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.CONTENT_CODE = SUBT.CONTENT_CODE
    and SUBB.SEQUENCE_NUM = SUBT.SEQUENCE_NUM
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_NAME <> SUBT.USER_NAME
  ));

  insert into BNE_CONTENT_COLS_TL (
    APPLICATION_ID,
    CONTENT_CODE,
    SEQUENCE_NUM,
    USER_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.APPLICATION_ID,
    B.CONTENT_CODE,
    B.SEQUENCE_NUM,
    B.USER_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BNE_CONTENT_COLS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BNE_CONTENT_COLS_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.CONTENT_CODE = B.CONTENT_CODE
    and T.SEQUENCE_NUM = B.SEQUENCE_NUM
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--------------------------------------------------------------------------------
--  PROCEDURE:   TRANSLATE_ROW                                                --
--                                                                            --
--  DESCRIPTION: Load a translation into the BNE_CONTENT_COLS entity.         --
--               This proc is called from the apps loader.                    --
--                                                                            --
--  SEE:   http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt         --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  1-Oct-02   DGROVES   CREATED                                              --
--------------------------------------------------------------------------------
procedure TRANSLATE_ROW(
  x_content_asn           in VARCHAR2,
  x_content_code          in VARCHAR2,
  x_sequence_num          in VARCHAR2,
  x_user_name             in VARCHAR2,
  x_owner                 in VARCHAR2,
  x_last_update_date      in VARCHAR2,
  x_custom_mode           in VARCHAR2
)
is
  l_app_id          number;
  f_luby            number;  -- entity owner in file
  f_ludate          date;    -- entity update date in file
  db_luby           number;  -- entity owner in db
  db_ludate         date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_content_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_CONTENT_COLS_TL
    where APPLICATION_ID  = l_app_id
    and   CONTENT_CODE    = x_content_code
    and   SEQUENCE_NUM    = x_sequence_num
    and   LANGUAGE        = userenv('LANG');

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then

      update BNE_CONTENT_COLS_TL
      set USER_NAME         = x_user_name,
          LAST_UPDATE_DATE  = f_ludate,
          LAST_UPDATED_BY   = f_luby,
          LAST_UPDATE_LOGIN = 0,
          SOURCE_LANG       = userenv('LANG')
      where APPLICATION_ID   = l_app_id
      AND   CONTENT_CODE     = x_content_code
      AND   SEQUENCE_NUM     = x_sequence_num
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
--  DESCRIPTION:   Load a row into the BNE_CONTENTS entity.                   --
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
  x_content_asn           in VARCHAR2,
  x_content_code          in VARCHAR2,
  x_sequence_num          in VARCHAR2,
  x_object_version_number in VARCHAR2,
  x_col_name              in VARCHAR2,
  x_user_name             in VARCHAR2,
  x_owner                 in VARCHAR2,
  x_last_update_date      in VARCHAR2,
  x_custom_mode           in VARCHAR2,
  x_read_only_flag        in VARCHAR2
)
is
  l_app_id                    number;
  l_row_id                    varchar2(64);
  f_luby                      number;  -- entity owner in file
  f_ludate                    date;    -- entity update date in file
  db_luby                     number;  -- entity owner in db
  db_ludate                   date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id            := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_content_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_CONTENT_COLS_B
    where APPLICATION_ID  = l_app_id
    and   CONTENT_CODE    = x_content_code
    and   SEQUENCE_NUM    = x_sequence_num;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_CONTENT_COLS_PKG.Update_Row(
        X_APPLICATION_ID               => l_app_id,
        X_CONTENT_CODE                 => x_content_code,
        X_SEQUENCE_NUM                 => x_sequence_num,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_COL_NAME                     => x_col_name,
        X_USER_NAME                    => x_user_name,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0,
        X_READ_ONLY_FLAG               => x_read_only_flag
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_CONTENT_COLS_PKG.Insert_Row(
        X_ROWID                        => l_row_id,
        X_APPLICATION_ID               => l_app_id,
        X_CONTENT_CODE                 => x_content_code,
        X_SEQUENCE_NUM                 => x_sequence_num,
        X_OBJECT_VERSION_NUMBER        => x_object_version_number,
        X_COL_NAME                     => x_col_name,
        X_USER_NAME                    => x_user_name,
        X_CREATION_DATE                => f_ludate,
        X_CREATED_BY                   => f_luby,
        X_LAST_UPDATE_DATE             => f_ludate,
        X_LAST_UPDATED_BY              => f_luby,
        X_LAST_UPDATE_LOGIN            => 0,
        X_READ_ONLY_FLAG               => x_read_only_flag
      );
  end;
end LOAD_ROW;


end BNE_CONTENT_COLS_PKG;

/
