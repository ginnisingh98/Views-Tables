--------------------------------------------------------
--  DDL for Package Body FEM_FUNC_DIM_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_FUNC_DIM_SETS_PKG" as
/* $Header: fem_funcds_pkb.plb 120.0 2006/05/08 11:55:33 rflippo noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FUNC_DIM_SET_ID in NUMBER,
  X_FUNC_DIM_SET_OBJ_DEF_ID in NUMBER,
  X_DIMENSION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FUNC_DIM_SET_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FEM_FUNC_DIM_SETS_B
    where FUNC_DIM_SET_ID = X_FUNC_DIM_SET_ID
    ;
begin
  insert into FEM_FUNC_DIM_SETS_B (
    FUNC_DIM_SET_OBJ_DEF_ID,
    FUNC_DIM_SET_ID,
    DIMENSION_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_FUNC_DIM_SET_OBJ_DEF_ID,
    X_FUNC_DIM_SET_ID,
    X_DIMENSION_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FEM_FUNC_DIM_SETS_TL (
    FUNC_DIM_SET_ID,
    FUNC_DIM_SET_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_FUNC_DIM_SET_ID,
    X_FUNC_DIM_SET_NAME,
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
    from FEM_FUNC_DIM_SETS_TL T
    where T.FUNC_DIM_SET_ID = X_FUNC_DIM_SET_ID
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
  X_FUNC_DIM_SET_ID in NUMBER,
  X_FUNC_DIM_SET_OBJ_DEF_ID in NUMBER,
  X_DIMENSION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FUNC_DIM_SET_NAME in VARCHAR2
) is
  cursor c is select
      FUNC_DIM_SET_OBJ_DEF_ID,
      DIMENSION_ID,
      OBJECT_VERSION_NUMBER
    from FEM_FUNC_DIM_SETS_B
    where FUNC_DIM_SET_ID = X_FUNC_DIM_SET_ID
    for update of FUNC_DIM_SET_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      FUNC_DIM_SET_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FEM_FUNC_DIM_SETS_TL
    where FUNC_DIM_SET_ID = X_FUNC_DIM_SET_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FUNC_DIM_SET_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.FUNC_DIM_SET_OBJ_DEF_ID = X_FUNC_DIM_SET_OBJ_DEF_ID)
      AND (recinfo.DIMENSION_ID = X_DIMENSION_ID)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.FUNC_DIM_SET_NAME = X_FUNC_DIM_SET_NAME)
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
  X_FUNC_DIM_SET_ID in NUMBER,
  X_FUNC_DIM_SET_OBJ_DEF_ID in NUMBER,
  X_DIMENSION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FUNC_DIM_SET_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FEM_FUNC_DIM_SETS_B set
    FUNC_DIM_SET_OBJ_DEF_ID = X_FUNC_DIM_SET_OBJ_DEF_ID,
    DIMENSION_ID = X_DIMENSION_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where FUNC_DIM_SET_ID = X_FUNC_DIM_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FEM_FUNC_DIM_SETS_TL set
    FUNC_DIM_SET_NAME = X_FUNC_DIM_SET_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FUNC_DIM_SET_ID = X_FUNC_DIM_SET_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FUNC_DIM_SET_ID in NUMBER
) is
begin
  delete from FEM_FUNC_DIM_SETS_TL
  where FUNC_DIM_SET_ID = X_FUNC_DIM_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FEM_FUNC_DIM_SETS_B
  where FUNC_DIM_SET_ID = X_FUNC_DIM_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FEM_FUNC_DIM_SETS_TL T
  where not exists
    (select NULL
    from FEM_FUNC_DIM_SETS_B B
    where B.FUNC_DIM_SET_ID = T.FUNC_DIM_SET_ID
    );

  update FEM_FUNC_DIM_SETS_TL T set (
      FUNC_DIM_SET_NAME
    ) = (select
      B.FUNC_DIM_SET_NAME
    from FEM_FUNC_DIM_SETS_TL B
    where B.FUNC_DIM_SET_ID = T.FUNC_DIM_SET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FUNC_DIM_SET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FUNC_DIM_SET_ID,
      SUBT.LANGUAGE
    from FEM_FUNC_DIM_SETS_TL SUBB, FEM_FUNC_DIM_SETS_TL SUBT
    where SUBB.FUNC_DIM_SET_ID = SUBT.FUNC_DIM_SET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.FUNC_DIM_SET_NAME <> SUBT.FUNC_DIM_SET_NAME
  ));

  insert into FEM_FUNC_DIM_SETS_TL (
    FUNC_DIM_SET_ID,
    FUNC_DIM_SET_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.FUNC_DIM_SET_ID,
    B.FUNC_DIM_SET_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FEM_FUNC_DIM_SETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FEM_FUNC_DIM_SETS_TL T
    where T.FUNC_DIM_SET_ID = B.FUNC_DIM_SET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_FUNC_DIM_SET_ID in number,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_FUNC_DIM_SET_NAME in varchar2,
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
          from FEM_FUNC_DIM_SETS_TL
          where FUNC_DIM_SET_ID = x_FUNC_DIM_SET_ID
          and LANGUAGE = userenv('LANG');

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, x_custom_mode)) then
            -- Update translations for this language
            update FEM_FUNC_DIM_SETS_TL set
              FUNC_DIM_SET_NAME = decode(x_FUNC_DIM_SET_NAME,
			       fnd_load_util.null_value, null, -- Real null
			       null, x_FUNC_DIM_SET_NAME,                  -- No change
			       x_FUNC_DIM_SET_NAME),
              LAST_UPDATE_DATE = f_ludate,
              LAST_UPDATED_BY = f_luby,
              LAST_UPDATE_LOGIN = 0,
              SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
            and FUNC_DIM_SET_ID = x_FUNC_DIM_SET_ID;
         end if;
        exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
        end;
     end TRANSLATE_ROW;


end FEM_FUNC_DIM_SETS_PKG;

/
