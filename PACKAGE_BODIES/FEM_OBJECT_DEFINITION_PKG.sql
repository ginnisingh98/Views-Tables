--------------------------------------------------------
--  DDL for Package Body FEM_OBJECT_DEFINITION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_OBJECT_DEFINITION_PKG" as
/* $Header: fem_objdef_pkb.plb 120.0 2005/06/06 21:26:57 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_OBJECT_DEFINITION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OBJECT_ID in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_EFFECTIVE_END_DATE in DATE,
  X_OBJECT_ORIGIN_CODE in VARCHAR2,
  X_APPROVAL_STATUS_CODE in VARCHAR2,
  X_OLD_APPROVED_COPY_FLAG in VARCHAR2,
  X_OLD_APPROVED_COPY_OBJ_DEF_ID in NUMBER,
  X_APPROVED_BY in NUMBER,
  X_APPROVAL_DATE in DATE,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FEM_OBJECT_DEFINITION_B
    where OBJECT_DEFINITION_ID = X_OBJECT_DEFINITION_ID
    ;
begin
  insert into FEM_OBJECT_DEFINITION_B (
    OBJECT_VERSION_NUMBER,
    OBJECT_DEFINITION_ID,
    OBJECT_ID,
    EFFECTIVE_START_DATE,
    EFFECTIVE_END_DATE,
    OBJECT_ORIGIN_CODE,
    APPROVAL_STATUS_CODE,
    OLD_APPROVED_COPY_FLAG,
    OLD_APPROVED_COPY_OBJ_DEF_ID,
    APPROVED_BY,
    APPROVAL_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_OBJECT_VERSION_NUMBER,
    X_OBJECT_DEFINITION_ID,
    X_OBJECT_ID,
    X_EFFECTIVE_START_DATE,
    X_EFFECTIVE_END_DATE,
    X_OBJECT_ORIGIN_CODE,
    X_APPROVAL_STATUS_CODE,
    X_OLD_APPROVED_COPY_FLAG,
    X_OLD_APPROVED_COPY_OBJ_DEF_ID,
    X_APPROVED_BY,
    X_APPROVAL_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FEM_OBJECT_DEFINITION_TL (
    OBJECT_DEFINITION_ID,
    OBJECT_ID,
    OLD_APPROVED_COPY_FLAG,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_OBJECT_DEFINITION_ID,
    X_OBJECT_ID,
    X_OLD_APPROVED_COPY_FLAG,
    X_DISPLAY_NAME,
    X_DESCRIPTION,
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
    from FEM_OBJECT_DEFINITION_TL T
    where T.OBJECT_DEFINITION_ID = X_OBJECT_DEFINITION_ID
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
  X_OBJECT_DEFINITION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OBJECT_ID in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_EFFECTIVE_END_DATE in DATE,
  X_OBJECT_ORIGIN_CODE in VARCHAR2,
  X_APPROVAL_STATUS_CODE in VARCHAR2,
  X_OLD_APPROVED_COPY_FLAG in VARCHAR2,
  X_OLD_APPROVED_COPY_OBJ_DEF_ID in NUMBER,
  X_APPROVED_BY in NUMBER,
  X_APPROVAL_DATE in DATE,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      OBJECT_ID,
      EFFECTIVE_START_DATE,
      EFFECTIVE_END_DATE,
      OBJECT_ORIGIN_CODE,
      APPROVAL_STATUS_CODE,
      OLD_APPROVED_COPY_FLAG,
      OLD_APPROVED_COPY_OBJ_DEF_ID,
      APPROVED_BY,
      APPROVAL_DATE
    from FEM_OBJECT_DEFINITION_B
    where OBJECT_DEFINITION_ID = X_OBJECT_DEFINITION_ID
    for update of OBJECT_DEFINITION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FEM_OBJECT_DEFINITION_TL
    where OBJECT_DEFINITION_ID = X_OBJECT_DEFINITION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of OBJECT_DEFINITION_ID nowait;
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
      AND (recinfo.OBJECT_ID = X_OBJECT_ID)
      AND (recinfo.EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE)
      AND (recinfo.EFFECTIVE_END_DATE = X_EFFECTIVE_END_DATE)
      AND (recinfo.OBJECT_ORIGIN_CODE = X_OBJECT_ORIGIN_CODE)
      AND (recinfo.APPROVAL_STATUS_CODE = X_APPROVAL_STATUS_CODE)
      AND (recinfo.OLD_APPROVED_COPY_FLAG = X_OLD_APPROVED_COPY_FLAG)
      AND ((recinfo.OLD_APPROVED_COPY_OBJ_DEF_ID = X_OLD_APPROVED_COPY_OBJ_DEF_ID)
           OR ((recinfo.OLD_APPROVED_COPY_OBJ_DEF_ID is null) AND (X_OLD_APPROVED_COPY_OBJ_DEF_ID is null)))
      AND ((recinfo.APPROVED_BY = X_APPROVED_BY)
           OR ((recinfo.APPROVED_BY is null) AND (X_APPROVED_BY is null)))
      AND ((recinfo.APPROVAL_DATE = X_APPROVAL_DATE)
           OR ((recinfo.APPROVAL_DATE is null) AND (X_APPROVAL_DATE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_OBJECT_DEFINITION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OBJECT_ID in NUMBER,
  X_EFFECTIVE_START_DATE in DATE,
  X_EFFECTIVE_END_DATE in DATE,
  X_OBJECT_ORIGIN_CODE in VARCHAR2,
  X_APPROVAL_STATUS_CODE in VARCHAR2,
  X_OLD_APPROVED_COPY_FLAG in VARCHAR2,
  X_OLD_APPROVED_COPY_OBJ_DEF_ID in NUMBER,
  X_APPROVED_BY in NUMBER,
  X_APPROVAL_DATE in DATE,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FEM_OBJECT_DEFINITION_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    OBJECT_ID = X_OBJECT_ID,
    EFFECTIVE_START_DATE = X_EFFECTIVE_START_DATE,
    EFFECTIVE_END_DATE = X_EFFECTIVE_END_DATE,
    OBJECT_ORIGIN_CODE = X_OBJECT_ORIGIN_CODE,
    APPROVAL_STATUS_CODE = X_APPROVAL_STATUS_CODE,
    OLD_APPROVED_COPY_FLAG = X_OLD_APPROVED_COPY_FLAG,
    OLD_APPROVED_COPY_OBJ_DEF_ID = X_OLD_APPROVED_COPY_OBJ_DEF_ID,
    APPROVED_BY = X_APPROVED_BY,
    APPROVAL_DATE = X_APPROVAL_DATE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where OBJECT_DEFINITION_ID = X_OBJECT_DEFINITION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FEM_OBJECT_DEFINITION_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where OBJECT_DEFINITION_ID = X_OBJECT_DEFINITION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_OBJECT_DEFINITION_ID in NUMBER
) is
begin
  delete from FEM_OBJECT_DEFINITION_TL
  where OBJECT_DEFINITION_ID = X_OBJECT_DEFINITION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FEM_OBJECT_DEFINITION_B
  where OBJECT_DEFINITION_ID = X_OBJECT_DEFINITION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FEM_OBJECT_DEFINITION_TL T
  where not exists
    (select NULL
    from FEM_OBJECT_DEFINITION_B B
    where B.OBJECT_DEFINITION_ID = T.OBJECT_DEFINITION_ID
    );

  update FEM_OBJECT_DEFINITION_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from FEM_OBJECT_DEFINITION_TL B
    where B.OBJECT_DEFINITION_ID = T.OBJECT_DEFINITION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.OBJECT_DEFINITION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.OBJECT_DEFINITION_ID,
      SUBT.LANGUAGE
    from FEM_OBJECT_DEFINITION_TL SUBB, FEM_OBJECT_DEFINITION_TL SUBT
    where SUBB.OBJECT_DEFINITION_ID = SUBT.OBJECT_DEFINITION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FEM_OBJECT_DEFINITION_TL (
    OBJECT_DEFINITION_ID,
    OBJECT_ID,
    OLD_APPROVED_COPY_FLAG,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.OBJECT_DEFINITION_ID,
    B.OBJECT_ID,
    B.OLD_APPROVED_COPY_FLAG,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FEM_OBJECT_DEFINITION_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FEM_OBJECT_DEFINITION_TL T
    where T.OBJECT_DEFINITION_ID = B.OBJECT_DEFINITION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_OBJECT_DEFINITION_ID in number,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_DISPLAY_NAME in varchar2,
        x_description in varchar2,
        x_custom_mode in varchar2) is

        owner_id number;
        ludate date;
        row_id varchar2(64);
        f_luby    number;  -- entity owner in file
        f_ludate  date;    -- entity update date in file
        db_luby   number;  -- entity owner in db
        db_ludate date;    -- entity update date in db
    begin


        -- Translate owner to file_last_updated_by
        f_luby := fnd_load_util.owner_id(x_owner);

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
        begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from FEM_OBJECT_DEFINITION_TL
          where OBJECT_DEFINITION_ID = x_OBJECT_DEFINITION_ID
          and LANGUAGE = userenv('LANG');

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, x_custom_mode)) then
            -- Update translations for this language
            update FEM_OBJECT_DEFINITION_TL set
              DISPLAY_NAME = decode(x_DISPLAY_NAME,
			       fnd_load_util.null_value, null, -- Real null
			       null, x_DISPLAY_NAME,                  -- No change
			       x_DISPLAY_NAME),
              DESCRIPTION = nvl(x_description, DESCRIPTION),
              LAST_UPDATE_DATE = f_ludate,
              LAST_UPDATED_BY = f_luby,
              LAST_UPDATE_LOGIN = 0,
              SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
            and OBJECT_DEFINITION_ID = x_OBJECT_DEFINITION_ID;
         end if;
        exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
        end;
     end TRANSLATE_ROW;


end FEM_OBJECT_DEFINITION_PKG;

/
