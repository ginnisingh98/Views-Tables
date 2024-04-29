--------------------------------------------------------
--  DDL for Package Body FRM_DOCUMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FRM_DOCUMENTS_PKG" as
/* $Header: frmdocb.pls 120.2 2005/09/29 00:09:02 ghooker noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DOCUMENT_ID in NUMBER,
  X_DIRECTORY_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_EXPANDED_FLAG in VARCHAR2,
  X_DS_APP_SHORT_NAME in VARCHAR2,
  X_DATA_SOURCE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FRM_DOCUMENTS_B
    where DOCUMENT_ID = X_DOCUMENT_ID
    ;
begin
  insert into FRM_DOCUMENTS_B (
    DOCUMENT_ID,
    DIRECTORY_ID,
    SEQUENCE_NUMBER,
    EXPANDED_FLAG,
    DS_APP_SHORT_NAME,
    DATA_SOURCE_CODE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_DOCUMENT_ID,
    X_DIRECTORY_ID,
    X_SEQUENCE_NUMBER,
    X_EXPANDED_FLAG,
    X_DS_APP_SHORT_NAME,
    X_DATA_SOURCE_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FRM_DOCUMENTS_TL (
    DOCUMENT_ID,
    USER_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DOCUMENT_ID,
    X_USER_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FRM_DOCUMENTS_TL T
    where T.DOCUMENT_ID = X_DOCUMENT_ID
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
  X_DOCUMENT_ID in NUMBER,
  X_DIRECTORY_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_EXPANDED_FLAG in VARCHAR2,
  X_DS_APP_SHORT_NAME in VARCHAR2,
  X_DATA_SOURCE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_NAME in VARCHAR2
) is
  cursor c is select
      DIRECTORY_ID,
      SEQUENCE_NUMBER,
      EXPANDED_FLAG,
      DS_APP_SHORT_NAME,
      DATA_SOURCE_CODE,
      OBJECT_VERSION_NUMBER
    from FRM_DOCUMENTS_B
    where DOCUMENT_ID = X_DOCUMENT_ID
    for update of DOCUMENT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FRM_DOCUMENTS_TL
    where DOCUMENT_ID = X_DOCUMENT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DOCUMENT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.DIRECTORY_ID = X_DIRECTORY_ID)
      AND (recinfo.SEQUENCE_NUMBER = X_SEQUENCE_NUMBER)
      AND ((recinfo.EXPANDED_FLAG = X_EXPANDED_FLAG)
           OR ((recinfo.EXPANDED_FLAG is null) AND (X_EXPANDED_FLAG is null)))
      AND ((recinfo.DS_APP_SHORT_NAME = X_DS_APP_SHORT_NAME)
           OR ((recinfo.DS_APP_SHORT_NAME is null) AND (X_DS_APP_SHORT_NAME is null)))
      AND ((recinfo.DATA_SOURCE_CODE = X_DATA_SOURCE_CODE)
           OR ((recinfo.DATA_SOURCE_CODE is null) AND (X_DATA_SOURCE_CODE is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
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
  X_DOCUMENT_ID in NUMBER,
  X_DIRECTORY_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_EXPANDED_FLAG in VARCHAR2,
  X_DS_APP_SHORT_NAME in VARCHAR2,
  X_DATA_SOURCE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FRM_DOCUMENTS_B set
    DIRECTORY_ID = X_DIRECTORY_ID,
    SEQUENCE_NUMBER = X_SEQUENCE_NUMBER,
    EXPANDED_FLAG = X_EXPANDED_FLAG,
    DS_APP_SHORT_NAME = X_DS_APP_SHORT_NAME,
    DATA_SOURCE_CODE = X_DATA_SOURCE_CODE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DOCUMENT_ID = X_DOCUMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FRM_DOCUMENTS_TL set
    USER_NAME = X_USER_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DOCUMENT_ID = X_DOCUMENT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DOCUMENT_ID in NUMBER
) is
begin
  delete from FRM_DOCUMENTS_TL
  where DOCUMENT_ID = X_DOCUMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FRM_DOCUMENTS_B
  where DOCUMENT_ID = X_DOCUMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FRM_DOCUMENTS_TL T
  where not exists
    (select NULL
    from FRM_DOCUMENTS_B B
    where B.DOCUMENT_ID = T.DOCUMENT_ID
    );

  update FRM_DOCUMENTS_TL T set (
      USER_NAME
    ) = (select
      B.USER_NAME
    from FRM_DOCUMENTS_TL B
    where B.DOCUMENT_ID = T.DOCUMENT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DOCUMENT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DOCUMENT_ID,
      SUBT.LANGUAGE
    from FRM_DOCUMENTS_TL SUBB, FRM_DOCUMENTS_TL SUBT
    where SUBB.DOCUMENT_ID = SUBT.DOCUMENT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_NAME <> SUBT.USER_NAME
  ));

  insert into FRM_DOCUMENTS_TL (
    DOCUMENT_ID,
    USER_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.DOCUMENT_ID,
    B.USER_NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FRM_DOCUMENTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FRM_DOCUMENTS_TL T
    where T.DOCUMENT_ID = B.DOCUMENT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--------------------------------------------------------------------------------
--  PROCEDURE:     LOAD_ROW                                                   --
--                                                                            --
--  DESCRIPTION:   Load a row into the FRM_DOCUMENTS entity.                  --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt --
--                        --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date        Username   Description                                        --
--  12-Jul-04   MLUETCHF   CREATED                                            --
--------------------------------------------------------------------------------

procedure LOAD_ROW (
  x_document_id           IN VARCHAR2,
  x_directory_id          IN VARCHAR2,
  x_sequence_number       IN VARCHAR2,
  x_expanded_flag         IN VARCHAR2,
  x_ds_app_short_name     IN VARCHAR2,
  x_data_source_code      IN VARCHAR2,
  x_object_version_number IN VARCHAR2,
  x_user_name             IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2
)
is
  l_row_id          varchar2(64);
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
    from FRM_DOCUMENTS_B
    where DOCUMENT_ID = x_document_id;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      FRM_DOCUMENTS_PKG.Update_Row(
        X_DOCUMENT_ID           => x_document_id,
        X_DIRECTORY_ID          => x_directory_id,
        X_SEQUENCE_NUMBER       => x_sequence_number,
        X_EXPANDED_FLAG         => x_expanded_flag,
        X_DS_APP_SHORT_NAME     => x_ds_app_short_name,
        X_DATA_SOURCE_CODE      => x_data_source_code,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_USER_NAME             => x_user_name,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      FRM_DOCUMENTS_PKG.Insert_Row(
        X_ROWID                 => l_row_id,
        X_DOCUMENT_ID           => x_document_id,
        X_DIRECTORY_ID          => x_directory_id,
        X_SEQUENCE_NUMBER       => x_sequence_number,
        X_EXPANDED_FLAG         => x_expanded_flag,
        X_DS_APP_SHORT_NAME     => x_ds_app_short_name,
        X_DATA_SOURCE_CODE      => x_data_source_code,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_USER_NAME             => x_user_name,
        X_CREATION_DATE         => f_ludate,
        X_CREATED_BY            => f_luby,
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0
      );
  end;
end LOAD_ROW;


--------------------------------------------------------------------------------
--  PROCEDURE:   TRANSLATE_ROW                                                --
--                                                                            --
--  DESCRIPTION: Load a translation into the FRM_DOCUMENTS entity.            --
--               This proc is called from the apps loader.                    --
--                                                                            --
--  SEE:   http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt   --
--                        --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date        Username   Description                                        --
--  12-Jul-04   MLUETCHF   CREATED                                            --
--------------------------------------------------------------------------------

procedure TRANSLATE_ROW(
  x_document_id           IN VARCHAR2,
  x_user_name             IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2
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
    from FRM_DOCUMENTS_TL
    where DOCUMENT_ID = x_document_id
    and   LANGUAGE       = userenv('LANG');

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then

      update FRM_DOCUMENTS_TL
      set USER_NAME         = x_user_name,
          LAST_UPDATE_DATE  = f_ludate,
          LAST_UPDATED_BY   = f_luby,
          LAST_UPDATE_LOGIN = 0,
          SOURCE_LANG       = userenv('LANG')
      where DOCUMENT_ID = x_document_id
      AND   userenv('LANG') in (LANGUAGE, SOURCE_LANG)
      ;
    end if;
  exception
    when no_data_found then
      -- Do not insert missing translations, skip this row
      null;
  end;
end TRANSLATE_ROW;

end FRM_DOCUMENTS_PKG;

/
