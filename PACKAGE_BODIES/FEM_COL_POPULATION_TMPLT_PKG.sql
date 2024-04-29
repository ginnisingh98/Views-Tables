--------------------------------------------------------
--  DDL for Package Body FEM_COL_POPULATION_TMPLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_COL_POPULATION_TMPLT_PKG" as
/* $Header: FEMCOLPOPB.pls 120.0 2005/06/06 21:20:56 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_COL_POP_TEMPLT_OBJ_DEF_ID in NUMBER,
  X_SOURCE_TABLE_NAME in VARCHAR2,
  X_TARGET_COLUMN_NAME in VARCHAR2,
  X_TARGET_TABLE_NAME in VARCHAR2,
  X_DATA_POPULATION_METHOD_CODE in VARCHAR2,
  X_SOURCE_COLUMN_NAME in VARCHAR2,
  X_DIMENSION_ID in NUMBER,
  X_ATTRIBUTE_ID in NUMBER,
  X_ATTRIBUTE_VERSION_ID in NUMBER,
  X_AGGREGATION_METHOD in VARCHAR2,
  X_CONSTANT_NUMERIC_VALUE in NUMBER,
  X_CONSTANT_ALPHANUMERIC_VALUE in VARCHAR2,
  X_CONSTANT_DATE_VALUE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SYSTEM_RESERVED_FLAG in VARCHAR2,
  X_ENG_PROC_PARAM in VARCHAR2,
  X_PARAMETER_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FEM_COL_POPULATION_TMPLT_B
    where COL_POP_TEMPLT_OBJ_DEF_ID = X_COL_POP_TEMPLT_OBJ_DEF_ID
    and SOURCE_TABLE_NAME = X_SOURCE_TABLE_NAME
    and TARGET_COLUMN_NAME = X_TARGET_COLUMN_NAME
    and TARGET_TABLE_NAME = X_TARGET_TABLE_NAME
    ;
begin
  insert into FEM_COL_POPULATION_TMPLT_B (
    COL_POP_TEMPLT_OBJ_DEF_ID,
    TARGET_TABLE_NAME,
    TARGET_COLUMN_NAME,
    DATA_POPULATION_METHOD_CODE,
    SOURCE_TABLE_NAME,
    SOURCE_COLUMN_NAME,
    DIMENSION_ID,
    ATTRIBUTE_ID,
    ATTRIBUTE_VERSION_ID,
    AGGREGATION_METHOD,
    CONSTANT_NUMERIC_VALUE,
    CONSTANT_ALPHANUMERIC_VALUE,
    CONSTANT_DATE_VALUE,
    OBJECT_VERSION_NUMBER,
    SYSTEM_RESERVED_FLAG,
    ENG_PROC_PARAM,
    PARAMETER_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_COL_POP_TEMPLT_OBJ_DEF_ID,
    X_TARGET_TABLE_NAME,
    X_TARGET_COLUMN_NAME,
    X_DATA_POPULATION_METHOD_CODE,
    X_SOURCE_TABLE_NAME,
    X_SOURCE_COLUMN_NAME,
    X_DIMENSION_ID,
    X_ATTRIBUTE_ID,
    X_ATTRIBUTE_VERSION_ID,
    X_AGGREGATION_METHOD,
    X_CONSTANT_NUMERIC_VALUE,
    X_CONSTANT_ALPHANUMERIC_VALUE,
    X_CONSTANT_DATE_VALUE,
    X_OBJECT_VERSION_NUMBER,
    X_SYSTEM_RESERVED_FLAG,
    X_ENG_PROC_PARAM,
    X_PARAMETER_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FEM_COL_POPULATION_TMPLT_TL (
    COL_POP_TEMPLT_OBJ_DEF_ID,
    TARGET_TABLE_NAME,
    TARGET_COLUMN_NAME,
    SOURCE_TABLE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_COL_POP_TEMPLT_OBJ_DEF_ID,
    X_TARGET_TABLE_NAME,
    X_TARGET_COLUMN_NAME,
    X_SOURCE_TABLE_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FEM_COL_POPULATION_TMPLT_TL T
    where T.COL_POP_TEMPLT_OBJ_DEF_ID = X_COL_POP_TEMPLT_OBJ_DEF_ID
    and T.SOURCE_TABLE_NAME = X_SOURCE_TABLE_NAME
    and T.TARGET_COLUMN_NAME = X_TARGET_COLUMN_NAME
    and T.TARGET_TABLE_NAME = X_TARGET_TABLE_NAME
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
  X_COL_POP_TEMPLT_OBJ_DEF_ID in NUMBER,
  X_SOURCE_TABLE_NAME in VARCHAR2,
  X_TARGET_COLUMN_NAME in VARCHAR2,
  X_TARGET_TABLE_NAME in VARCHAR2,
  X_DATA_POPULATION_METHOD_CODE in VARCHAR2,
  X_SOURCE_COLUMN_NAME in VARCHAR2,
  X_DIMENSION_ID in NUMBER,
  X_ATTRIBUTE_ID in NUMBER,
  X_ATTRIBUTE_VERSION_ID in NUMBER,
  X_AGGREGATION_METHOD in VARCHAR2,
  X_CONSTANT_NUMERIC_VALUE in NUMBER,
  X_CONSTANT_ALPHANUMERIC_VALUE in VARCHAR2,
  X_CONSTANT_DATE_VALUE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SYSTEM_RESERVED_FLAG in VARCHAR2,
  X_ENG_PROC_PARAM in VARCHAR2,
  X_PARAMETER_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      DATA_POPULATION_METHOD_CODE,
      SOURCE_COLUMN_NAME,
      DIMENSION_ID,
      ATTRIBUTE_ID,
      ATTRIBUTE_VERSION_ID,
      AGGREGATION_METHOD,
      CONSTANT_NUMERIC_VALUE,
      CONSTANT_ALPHANUMERIC_VALUE,
      CONSTANT_DATE_VALUE,
      OBJECT_VERSION_NUMBER,
      SYSTEM_RESERVED_FLAG,
      ENG_PROC_PARAM,
      PARAMETER_FLAG
    from FEM_COL_POPULATION_TMPLT_B
    where COL_POP_TEMPLT_OBJ_DEF_ID = X_COL_POP_TEMPLT_OBJ_DEF_ID
    and SOURCE_TABLE_NAME = X_SOURCE_TABLE_NAME
    and TARGET_COLUMN_NAME = X_TARGET_COLUMN_NAME
    and TARGET_TABLE_NAME = X_TARGET_TABLE_NAME
    for update of COL_POP_TEMPLT_OBJ_DEF_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FEM_COL_POPULATION_TMPLT_TL
    where COL_POP_TEMPLT_OBJ_DEF_ID = X_COL_POP_TEMPLT_OBJ_DEF_ID
    and SOURCE_TABLE_NAME = X_SOURCE_TABLE_NAME
    and TARGET_COLUMN_NAME = X_TARGET_COLUMN_NAME
    and TARGET_TABLE_NAME = X_TARGET_TABLE_NAME
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of COL_POP_TEMPLT_OBJ_DEF_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.DATA_POPULATION_METHOD_CODE = X_DATA_POPULATION_METHOD_CODE)
      AND ((recinfo.SOURCE_COLUMN_NAME = X_SOURCE_COLUMN_NAME)
           OR ((recinfo.SOURCE_COLUMN_NAME is null) AND (X_SOURCE_COLUMN_NAME is null)))
      AND ((recinfo.DIMENSION_ID = X_DIMENSION_ID)
           OR ((recinfo.DIMENSION_ID is null) AND (X_DIMENSION_ID is null)))
      AND ((recinfo.ATTRIBUTE_ID = X_ATTRIBUTE_ID)
           OR ((recinfo.ATTRIBUTE_ID is null) AND (X_ATTRIBUTE_ID is null)))
      AND ((recinfo.ATTRIBUTE_VERSION_ID = X_ATTRIBUTE_VERSION_ID)
           OR ((recinfo.ATTRIBUTE_VERSION_ID is null) AND (X_ATTRIBUTE_VERSION_ID is null)))
      AND ((recinfo.AGGREGATION_METHOD = X_AGGREGATION_METHOD)
           OR ((recinfo.AGGREGATION_METHOD is null) AND (X_AGGREGATION_METHOD is null)))
      AND ((recinfo.CONSTANT_NUMERIC_VALUE = X_CONSTANT_NUMERIC_VALUE)
           OR ((recinfo.CONSTANT_NUMERIC_VALUE is null) AND (X_CONSTANT_NUMERIC_VALUE is null)))
      AND ((recinfo.CONSTANT_ALPHANUMERIC_VALUE = X_CONSTANT_ALPHANUMERIC_VALUE)
           OR ((recinfo.CONSTANT_ALPHANUMERIC_VALUE is null) AND (X_CONSTANT_ALPHANUMERIC_VALUE is null)))
      AND ((recinfo.CONSTANT_DATE_VALUE = X_CONSTANT_DATE_VALUE)
           OR ((recinfo.CONSTANT_DATE_VALUE is null) AND (X_CONSTANT_DATE_VALUE is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.SYSTEM_RESERVED_FLAG = X_SYSTEM_RESERVED_FLAG)
      AND ((recinfo.ENG_PROC_PARAM = X_ENG_PROC_PARAM)
           OR ((recinfo.ENG_PROC_PARAM is null) AND (X_ENG_PROC_PARAM is null)))
      AND ((recinfo.PARAMETER_FLAG = X_PARAMETER_FLAG)
           OR ((recinfo.PARAMETER_FLAG is null) AND (X_PARAMETER_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_COL_POP_TEMPLT_OBJ_DEF_ID in NUMBER,
  X_SOURCE_TABLE_NAME in VARCHAR2,
  X_TARGET_COLUMN_NAME in VARCHAR2,
  X_TARGET_TABLE_NAME in VARCHAR2,
  X_DATA_POPULATION_METHOD_CODE in VARCHAR2,
  X_SOURCE_COLUMN_NAME in VARCHAR2,
  X_DIMENSION_ID in NUMBER,
  X_ATTRIBUTE_ID in NUMBER,
  X_ATTRIBUTE_VERSION_ID in NUMBER,
  X_AGGREGATION_METHOD in VARCHAR2,
  X_CONSTANT_NUMERIC_VALUE in NUMBER,
  X_CONSTANT_ALPHANUMERIC_VALUE in VARCHAR2,
  X_CONSTANT_DATE_VALUE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SYSTEM_RESERVED_FLAG in VARCHAR2,
  X_ENG_PROC_PARAM in VARCHAR2,
  X_PARAMETER_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FEM_COL_POPULATION_TMPLT_B set
    DATA_POPULATION_METHOD_CODE = X_DATA_POPULATION_METHOD_CODE,
    SOURCE_COLUMN_NAME = X_SOURCE_COLUMN_NAME,
    DIMENSION_ID = X_DIMENSION_ID,
    ATTRIBUTE_ID = X_ATTRIBUTE_ID,
    ATTRIBUTE_VERSION_ID = X_ATTRIBUTE_VERSION_ID,
    AGGREGATION_METHOD = X_AGGREGATION_METHOD,
    CONSTANT_NUMERIC_VALUE = X_CONSTANT_NUMERIC_VALUE,
    CONSTANT_ALPHANUMERIC_VALUE = X_CONSTANT_ALPHANUMERIC_VALUE,
    CONSTANT_DATE_VALUE = X_CONSTANT_DATE_VALUE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    SYSTEM_RESERVED_FLAG = X_SYSTEM_RESERVED_FLAG,
    ENG_PROC_PARAM = X_ENG_PROC_PARAM,
    PARAMETER_FLAG = X_PARAMETER_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where COL_POP_TEMPLT_OBJ_DEF_ID = X_COL_POP_TEMPLT_OBJ_DEF_ID
  and SOURCE_TABLE_NAME = X_SOURCE_TABLE_NAME
  and TARGET_COLUMN_NAME = X_TARGET_COLUMN_NAME
  and TARGET_TABLE_NAME = X_TARGET_TABLE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FEM_COL_POPULATION_TMPLT_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where COL_POP_TEMPLT_OBJ_DEF_ID = X_COL_POP_TEMPLT_OBJ_DEF_ID
  and SOURCE_TABLE_NAME = X_SOURCE_TABLE_NAME
  and TARGET_COLUMN_NAME = X_TARGET_COLUMN_NAME
  and TARGET_TABLE_NAME = X_TARGET_TABLE_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_COL_POP_TEMPLT_OBJ_DEF_ID in NUMBER,
  X_SOURCE_TABLE_NAME in VARCHAR2,
  X_TARGET_COLUMN_NAME in VARCHAR2,
  X_TARGET_TABLE_NAME in VARCHAR2
) is
begin
  delete from FEM_COL_POPULATION_TMPLT_TL
  where COL_POP_TEMPLT_OBJ_DEF_ID = X_COL_POP_TEMPLT_OBJ_DEF_ID
  and SOURCE_TABLE_NAME = X_SOURCE_TABLE_NAME
  and TARGET_COLUMN_NAME = X_TARGET_COLUMN_NAME
  and TARGET_TABLE_NAME = X_TARGET_TABLE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FEM_COL_POPULATION_TMPLT_B
  where COL_POP_TEMPLT_OBJ_DEF_ID = X_COL_POP_TEMPLT_OBJ_DEF_ID
  and SOURCE_TABLE_NAME = X_SOURCE_TABLE_NAME
  and TARGET_COLUMN_NAME = X_TARGET_COLUMN_NAME
  and TARGET_TABLE_NAME = X_TARGET_TABLE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FEM_COL_POPULATION_TMPLT_TL T
  where not exists
    (select NULL
    from FEM_COL_POPULATION_TMPLT_B B
    where B.COL_POP_TEMPLT_OBJ_DEF_ID = T.COL_POP_TEMPLT_OBJ_DEF_ID
    and B.SOURCE_TABLE_NAME = T.SOURCE_TABLE_NAME
    and B.TARGET_COLUMN_NAME = T.TARGET_COLUMN_NAME
    and B.TARGET_TABLE_NAME = T.TARGET_TABLE_NAME
    );

  update FEM_COL_POPULATION_TMPLT_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from FEM_COL_POPULATION_TMPLT_TL B
    where B.COL_POP_TEMPLT_OBJ_DEF_ID = T.COL_POP_TEMPLT_OBJ_DEF_ID
    and B.SOURCE_TABLE_NAME = T.SOURCE_TABLE_NAME
    and B.TARGET_COLUMN_NAME = T.TARGET_COLUMN_NAME
    and B.TARGET_TABLE_NAME = T.TARGET_TABLE_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.COL_POP_TEMPLT_OBJ_DEF_ID,
      T.SOURCE_TABLE_NAME,
      T.TARGET_COLUMN_NAME,
      T.TARGET_TABLE_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.COL_POP_TEMPLT_OBJ_DEF_ID,
      SUBT.SOURCE_TABLE_NAME,
      SUBT.TARGET_COLUMN_NAME,
      SUBT.TARGET_TABLE_NAME,
      SUBT.LANGUAGE
    from FEM_COL_POPULATION_TMPLT_TL SUBB, FEM_COL_POPULATION_TMPLT_TL SUBT
    where SUBB.COL_POP_TEMPLT_OBJ_DEF_ID = SUBT.COL_POP_TEMPLT_OBJ_DEF_ID
    and SUBB.SOURCE_TABLE_NAME = SUBT.SOURCE_TABLE_NAME
    and SUBB.TARGET_COLUMN_NAME = SUBT.TARGET_COLUMN_NAME
    and SUBB.TARGET_TABLE_NAME = SUBT.TARGET_TABLE_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FEM_COL_POPULATION_TMPLT_TL (
    COL_POP_TEMPLT_OBJ_DEF_ID,
    TARGET_TABLE_NAME,
    TARGET_COLUMN_NAME,
    SOURCE_TABLE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.COL_POP_TEMPLT_OBJ_DEF_ID,
    B.TARGET_TABLE_NAME,
    B.TARGET_COLUMN_NAME,
    B.SOURCE_TABLE_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FEM_COL_POPULATION_TMPLT_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FEM_COL_POPULATION_TMPLT_TL T
    where T.COL_POP_TEMPLT_OBJ_DEF_ID = B.COL_POP_TEMPLT_OBJ_DEF_ID
    and T.SOURCE_TABLE_NAME = B.SOURCE_TABLE_NAME
    and T.TARGET_COLUMN_NAME = B.TARGET_COLUMN_NAME
    and T.TARGET_TABLE_NAME = B.TARGET_TABLE_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FEM_COL_POPULATION_TMPLT_PKG;

/