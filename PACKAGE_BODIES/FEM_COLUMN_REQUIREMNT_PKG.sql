--------------------------------------------------------
--  DDL for Package Body FEM_COLUMN_REQUIREMNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_COLUMN_REQUIREMNT_PKG" as
/* $Header: fem_colrqmnt_pkb.plb 120.0 2005/06/06 21:39:13 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ACTIVITY_DIM_COMPONENT_FLAG in VARCHAR2,
  X_COST_OBJ_DIM_REQUIREMENT_COD in VARCHAR2,
  X_COST_OBJ_DIM_COMPONENT_FLAG in VARCHAR2,
  X_DATA_LENGTH in NUMBER,
  X_DATA_SCALE in NUMBER,
  X_DATA_PRECISION in NUMBER,
  X_UOM_COLUMN_NAME in VARCHAR2,
  X_DIMENSION_ID in NUMBER,
  X_FEM_DATA_TYPE_CODE in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_PROCESS_KEY_CANDIDATE_FLG in NUMBER,
  X_PROCESS_KEY_COL_ID in NUMBER,
  X_DISPLAY_SEQ in NUMBER,
  X_RESTRICTED_FLAG in VARCHAR2,
  X_ACTIVITY_DIM_REQUIREMENT_COD in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FEM_COLUMN_REQUIREMNT_B
    where COLUMN_NAME = X_COLUMN_NAME
    ;
begin
  insert into FEM_COLUMN_REQUIREMNT_B (
    OBJECT_VERSION_NUMBER,
    ACTIVITY_DIM_COMPONENT_FLAG,
    COST_OBJ_DIM_REQUIREMENT_CODE,
    COST_OBJ_DIM_COMPONENT_FLAG,
    DATA_LENGTH,
    DATA_SCALE,
    DATA_PRECISION,
    UOM_COLUMN_NAME,
    DIMENSION_ID,
    COLUMN_NAME,
    FEM_DATA_TYPE_CODE,
    DATA_TYPE,
    PROCESS_KEY_CANDIDATE_FLG,
    PROCESS_KEY_COL_ID,
    DISPLAY_SEQ,
    RESTRICTED_FLAG,
    ACTIVITY_DIM_REQUIREMENT_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_OBJECT_VERSION_NUMBER,
    X_ACTIVITY_DIM_COMPONENT_FLAG,
    X_COST_OBJ_DIM_REQUIREMENT_COD,
    X_COST_OBJ_DIM_COMPONENT_FLAG,
    X_DATA_LENGTH,
    X_DATA_SCALE,
    X_DATA_PRECISION,
    X_UOM_COLUMN_NAME,
    X_DIMENSION_ID,
    X_COLUMN_NAME,
    X_FEM_DATA_TYPE_CODE,
    X_DATA_TYPE,
    X_PROCESS_KEY_CANDIDATE_FLG,
    X_PROCESS_KEY_COL_ID,
    X_DISPLAY_SEQ,
    X_RESTRICTED_FLAG,
    X_ACTIVITY_DIM_REQUIREMENT_COD,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FEM_COLUMN_REQUIREMNT_TL (
    COLUMN_NAME,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_COLUMN_NAME,
    X_DISPLAY_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FEM_COLUMN_REQUIREMNT_TL T
    where T.COLUMN_NAME = X_COLUMN_NAME
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
  X_COLUMN_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ACTIVITY_DIM_COMPONENT_FLAG in VARCHAR2,
  X_COST_OBJ_DIM_REQUIREMENT_COD in VARCHAR2,
  X_COST_OBJ_DIM_COMPONENT_FLAG in VARCHAR2,
  X_DATA_LENGTH in NUMBER,
  X_DATA_SCALE in NUMBER,
  X_DATA_PRECISION in NUMBER,
  X_UOM_COLUMN_NAME in VARCHAR2,
  X_DIMENSION_ID in NUMBER,
  X_FEM_DATA_TYPE_CODE in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_PROCESS_KEY_CANDIDATE_FLG in NUMBER,
  X_PROCESS_KEY_COL_ID in NUMBER,
  X_DISPLAY_SEQ in NUMBER,
  X_RESTRICTED_FLAG in VARCHAR2,
  X_ACTIVITY_DIM_REQUIREMENT_COD in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      ACTIVITY_DIM_COMPONENT_FLAG,
      COST_OBJ_DIM_REQUIREMENT_CODE,
      COST_OBJ_DIM_COMPONENT_FLAG,
      DATA_LENGTH,
      DATA_SCALE,
      DATA_PRECISION,
      UOM_COLUMN_NAME,
      DIMENSION_ID,
      FEM_DATA_TYPE_CODE,
      DATA_TYPE,
      PROCESS_KEY_CANDIDATE_FLG,
      PROCESS_KEY_COL_ID,
      DISPLAY_SEQ,
      RESTRICTED_FLAG,
      ACTIVITY_DIM_REQUIREMENT_CODE
    from FEM_COLUMN_REQUIREMNT_B
    where COLUMN_NAME = X_COLUMN_NAME
    for update of COLUMN_NAME nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FEM_COLUMN_REQUIREMNT_TL
    where COLUMN_NAME = X_COLUMN_NAME
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of COLUMN_NAME nowait;
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
      AND (recinfo.ACTIVITY_DIM_COMPONENT_FLAG = X_ACTIVITY_DIM_COMPONENT_FLAG)
      AND ((recinfo.COST_OBJ_DIM_REQUIREMENT_CODE = X_COST_OBJ_DIM_REQUIREMENT_COD)
           OR ((recinfo.COST_OBJ_DIM_REQUIREMENT_CODE is null) AND (X_COST_OBJ_DIM_REQUIREMENT_COD is null)))
      AND (recinfo.COST_OBJ_DIM_COMPONENT_FLAG = X_COST_OBJ_DIM_COMPONENT_FLAG)
      AND ((recinfo.DATA_LENGTH = X_DATA_LENGTH)
           OR ((recinfo.DATA_LENGTH is null) AND (X_DATA_LENGTH is null)))
      AND ((recinfo.DATA_SCALE = X_DATA_SCALE)
           OR ((recinfo.DATA_SCALE is null) AND (X_DATA_SCALE is null)))
      AND ((recinfo.DATA_PRECISION = X_DATA_PRECISION)
           OR ((recinfo.DATA_PRECISION is null) AND (X_DATA_PRECISION is null)))
      AND ((recinfo.UOM_COLUMN_NAME = X_UOM_COLUMN_NAME)
           OR ((recinfo.UOM_COLUMN_NAME is null) AND (X_UOM_COLUMN_NAME is null)))
      AND ((recinfo.DIMENSION_ID = X_DIMENSION_ID)
           OR ((recinfo.DIMENSION_ID is null) AND (X_DIMENSION_ID is null)))
      AND (recinfo.FEM_DATA_TYPE_CODE = X_FEM_DATA_TYPE_CODE)
      AND (recinfo.DATA_TYPE = X_DATA_TYPE)
      AND (recinfo.PROCESS_KEY_CANDIDATE_FLG = X_PROCESS_KEY_CANDIDATE_FLG)
      AND ((recinfo.PROCESS_KEY_COL_ID = X_PROCESS_KEY_COL_ID)
           OR ((recinfo.PROCESS_KEY_COL_ID is null) AND (X_PROCESS_KEY_COL_ID is null)))
      AND ((recinfo.DISPLAY_SEQ = X_DISPLAY_SEQ)
           OR ((recinfo.DISPLAY_SEQ is null) AND (X_DISPLAY_SEQ is null)))
      AND (recinfo.RESTRICTED_FLAG = X_RESTRICTED_FLAG)
      AND ((recinfo.ACTIVITY_DIM_REQUIREMENT_CODE = X_ACTIVITY_DIM_REQUIREMENT_COD)
           OR ((recinfo.ACTIVITY_DIM_REQUIREMENT_CODE is null) AND (X_ACTIVITY_DIM_REQUIREMENT_COD is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
          AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_COLUMN_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ACTIVITY_DIM_COMPONENT_FLAG in VARCHAR2,
  X_COST_OBJ_DIM_REQUIREMENT_COD in VARCHAR2,
  X_COST_OBJ_DIM_COMPONENT_FLAG in VARCHAR2,
  X_DATA_LENGTH in NUMBER,
  X_DATA_SCALE in NUMBER,
  X_DATA_PRECISION in NUMBER,
  X_UOM_COLUMN_NAME in VARCHAR2,
  X_DIMENSION_ID in NUMBER,
  X_FEM_DATA_TYPE_CODE in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_PROCESS_KEY_CANDIDATE_FLG in NUMBER,
  X_PROCESS_KEY_COL_ID in NUMBER,
  X_DISPLAY_SEQ in NUMBER,
  X_RESTRICTED_FLAG in VARCHAR2,
  X_ACTIVITY_DIM_REQUIREMENT_COD in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FEM_COLUMN_REQUIREMNT_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ACTIVITY_DIM_COMPONENT_FLAG = X_ACTIVITY_DIM_COMPONENT_FLAG,
    COST_OBJ_DIM_REQUIREMENT_CODE = X_COST_OBJ_DIM_REQUIREMENT_COD,
    COST_OBJ_DIM_COMPONENT_FLAG = X_COST_OBJ_DIM_COMPONENT_FLAG,
    DATA_LENGTH = X_DATA_LENGTH,
    DATA_SCALE = X_DATA_SCALE,
    DATA_PRECISION = X_DATA_PRECISION,
    UOM_COLUMN_NAME = X_UOM_COLUMN_NAME,
    DIMENSION_ID = X_DIMENSION_ID,
    FEM_DATA_TYPE_CODE = X_FEM_DATA_TYPE_CODE,
    DATA_TYPE = X_DATA_TYPE,
    PROCESS_KEY_CANDIDATE_FLG = X_PROCESS_KEY_CANDIDATE_FLG,
    PROCESS_KEY_COL_ID = X_PROCESS_KEY_COL_ID,
    DISPLAY_SEQ = X_DISPLAY_SEQ,
    RESTRICTED_FLAG = X_RESTRICTED_FLAG,
    ACTIVITY_DIM_REQUIREMENT_CODE = X_ACTIVITY_DIM_REQUIREMENT_COD,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where COLUMN_NAME = X_COLUMN_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FEM_COLUMN_REQUIREMNT_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where COLUMN_NAME = X_COLUMN_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_COLUMN_NAME in VARCHAR2
) is
begin
  delete from FEM_COLUMN_REQUIREMNT_TL
  where COLUMN_NAME = X_COLUMN_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FEM_COLUMN_REQUIREMNT_B
  where COLUMN_NAME = X_COLUMN_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FEM_COLUMN_REQUIREMNT_TL T
  where not exists
    (select NULL
    from FEM_COLUMN_REQUIREMNT_B B
    where B.COLUMN_NAME = T.COLUMN_NAME
    );

  update FEM_COLUMN_REQUIREMNT_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from FEM_COLUMN_REQUIREMNT_TL B
    where B.COLUMN_NAME = T.COLUMN_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.COLUMN_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.COLUMN_NAME,
      SUBT.LANGUAGE
    from FEM_COLUMN_REQUIREMNT_TL SUBB, FEM_COLUMN_REQUIREMNT_TL SUBT
    where SUBB.COLUMN_NAME = SUBT.COLUMN_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into FEM_COLUMN_REQUIREMNT_TL (
    COLUMN_NAME,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.COLUMN_NAME,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FEM_COLUMN_REQUIREMNT_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FEM_COLUMN_REQUIREMNT_TL T
    where T.COLUMN_NAME = B.COLUMN_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_COLUMN_NAME in varchar2,
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
          from FEM_COLUMN_REQUIREMNT_TL
          where COLUMN_NAME = x_COLUMN_NAME
          and LANGUAGE = userenv('LANG');

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, x_custom_mode)) then
            -- Update translations for this language
            update FEM_COLUMN_REQUIREMNT_TL set
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
            and COLUMN_NAME = x_COLUMN_NAME;
         end if;
        exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
        end;
     end TRANSLATE_ROW;


end FEM_COLUMN_REQUIREMNT_PKG;

/
